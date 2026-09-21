package com.revuelta.api.infrastructure.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.revuelta.api.domain.user.UserId;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("dev")
@Testcontainers
class SecurityErrorContractIntegrationTest {

    private static final String TEST_JWT_SECRET =
            "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";

    @Container
    static final PostgreSQLContainer postgres = new PostgreSQLContainer(
            DockerImageName.parse("postgres:16-alpine")
    );

    @DynamicPropertySource
    static void configureApplication(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("jwt.secret", () -> TEST_JWT_SECRET);
    }

    @LocalServerPort
    private int serverPort;

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void shouldReturnUnauthenticatedProblemWhenTokenIsMissing() throws Exception {
        HttpResponse<String> response = getContainers(null);

        assertProblem(response, 401, "UNAUTHENTICATED");
    }

    @Test
    void shouldReturnUnauthenticatedProblemWhenTokenIsInvalidOrExpired() throws Exception {
        HttpResponse<String> invalidResponse = getContainers("not-a-jwt");
        JwtTokenProvider expiredTokenProvider = new JwtTokenProvider(TEST_JWT_SECRET, -1);
        String expiredToken = expiredTokenProvider.issue(
                new UserId(UUID.randomUUID()),
                "expired-user",
                "ADMIN"
        );
        HttpResponse<String> expiredResponse = getContainers(expiredToken);

        assertProblem(invalidResponse, 401, "UNAUTHENTICATED");
        assertProblem(expiredResponse, 401, "UNAUTHENTICATED");
    }

    @Test
    void shouldReturnForbiddenProblemWhenRoleCannotAccessEndpoint() throws Exception {
        String participantToken = tokenProvider.issue(
                new UserId(UUID.randomUUID()),
                "student",
                "PARTICIPANT"
        );

        HttpResponse<String> response = getContainers(participantToken);

        assertProblem(response, 403, "FORBIDDEN_OPERATION");
    }

    @Test
    void shouldReplaceUntrustedClientCorrelationId() throws Exception {
        HttpResponse<String> response = getContainers(null, "client-controlled-value");

        assertProblem(response, 401, "UNAUTHENTICATED");
        String serverCorrelationId = response.headers()
                .firstValue("X-Correlation-ID")
                .orElseThrow();
        assertNotEquals("client-controlled-value", serverCorrelationId);
        UUID.fromString(serverCorrelationId);
    }

    @Test
    void shouldReturnTypedConflictWhenContainerCodeAlreadyExists() throws Exception {
        String adminToken = tokenProvider.issue(UserId.generate(), "admin", "ADMIN");
        String code = "HTTP-DUP-" + UUID.randomUUID();

        HttpResponse<String> created = postContainer(adminToken, code);
        HttpResponse<String> conflict = postContainer(adminToken, code);

        assertEquals(201, created.statusCode());
        assertProblem(conflict, 409, "CONTAINER_CODE_ALREADY_EXISTS");
    }

    @Test
    void shouldReturnTypedNotFoundProblemForUnknownContainer() throws Exception {
        String operatorToken = tokenProvider.issue(UserId.generate(), "operator", "OPERATOR");
        String path = "/api/v1/containers/" + UUID.randomUUID();
        HttpResponse<String> response = get(path, operatorToken);

        assertProblem(response, 404, "CONTAINER_NOT_FOUND", path);
    }

    @Test
    void shouldReturnValidationProblemForMalformedContainerIdentifier() throws Exception {
        String operatorToken = tokenProvider.issue(UserId.generate(), "operator", "OPERATOR");
        String path = "/api/v1/containers/not-a-uuid";
        HttpResponse<String> response = get(path, operatorToken);

        assertProblem(response, 400, "VALIDATION_ERROR", path);
    }

    @ParameterizedTest(name = "{0} authenticates as {1}")
    @MethodSource("developmentAccounts")
    void shouldAuthenticateEveryApprovedDevelopmentRole(String username, String role) throws Exception {
        HttpResponse<String> response = login(username, "password123");

        assertEquals(200, response.statusCode());
        JsonNode body = objectMapper.readTree(response.body());
        assertEquals(username, body.get("username").stringValue());
        assertEquals(role, body.get("role").stringValue());
        assertFalse(body.get("token").stringValue().isBlank());
    }

    @Test
    void shouldNotRevealWhetherUsernameOrPasswordWasInvalid() throws Exception {
        HttpResponse<String> unknownUsername = login("missing-account", "password123");
        HttpResponse<String> wrongPassword = login("student1", "wrong-password");

        assertProblem(unknownUsername, 401, "INVALID_CREDENTIALS", "/api/v1/auth/login");
        assertProblem(wrongPassword, 401, "INVALID_CREDENTIALS", "/api/v1/auth/login");

        JsonNode unknownProblem = objectMapper.readTree(unknownUsername.body());
        JsonNode passwordProblem = objectMapper.readTree(wrongPassword.body());
        assertEquals(unknownProblem.get("detail").stringValue(), passwordProblem.get("detail").stringValue());
    }

    @ParameterizedTest(name = "{0}")
    @MethodSource("sensitiveEndpoints")
    void shouldEnforceTheApprovedRoleMatrixOnEverySensitiveEndpoint(
            String description,
            EndpointAccess endpoint
    ) throws Exception {
        HttpResponse<String> unauthenticated = request(endpoint, null);
        assertProblem(unauthenticated, 401, "UNAUTHENTICATED", endpoint.path());

        for (String role : Set.of("PARTICIPANT", "OPERATOR", "ADMIN", "UNKNOWN")) {
            String token = tokenProvider.issue(UserId.generate(), role.toLowerCase(), role);
            HttpResponse<String> response = request(endpoint, token);

            if (endpoint.allowedRoles().contains(role)) {
                assertNotEquals(401, response.statusCode(), description + " rejected an authenticated role");
                assertNotEquals(403, response.statusCode(), description + " rejected an authorized role");
            } else {
                assertProblem(response, 403, "FORBIDDEN_OPERATION", endpoint.path());
            }
        }
    }

    private static Stream<Arguments> sensitiveEndpoints() {
        String containerId = UUID.randomUUID().toString();
        String circulationId = UUID.randomUUID().toString();
        return Stream.of(
                Arguments.of("register container", new EndpointAccess(
                        "POST", "/api/v1/containers", "{\"code\":\"AUTHZ-" + UUID.randomUUID() + "\"}",
                        Set.of("ADMIN")
                )),
                Arguments.of("activate container", new EndpointAccess(
                        "POST", "/api/v1/containers/" + containerId + "/activate", null,
                        Set.of("ADMIN")
                )),
                Arguments.of("inspect container", new EndpointAccess(
                        "GET", "/api/v1/containers/" + containerId, null,
                        Set.of("OPERATOR", "ADMIN")
                )),
                Arguments.of("list all containers", new EndpointAccess(
                        "GET", "/api/v1/containers", null,
                        Set.of("ADMIN")
                )),
                Arguments.of("deliver container", new EndpointAccess(
                        "POST", "/api/v1/circulations",
                        "{\"containerId\":\"" + containerId + "\",\"borrowerId\":\"" + UUID.randomUUID() + "\"}",
                        Set.of("OPERATOR")
                )),
                Arguments.of("return container", new EndpointAccess(
                        "POST", "/api/v1/circulations/" + circulationId + "/return", null,
                        Set.of("OPERATOR")
                )),
                Arguments.of("inspect full container history", new EndpointAccess(
                        "GET", "/api/v1/containers/" + containerId + "/history", null,
                        Set.of("ADMIN")
                ))
        );
    }

    private static Stream<Arguments> developmentAccounts() {
        return Stream.of(
                Arguments.of("student1", "PARTICIPANT"),
                Arguments.of("operator", "OPERATOR"),
                Arguments.of("admin", "ADMIN")
        );
    }

    private HttpResponse<String> getContainers(String token) throws Exception {
        return getContainers(token, null);
    }

    private HttpResponse<String> getContainers(String token, String correlationId) throws Exception {
        HttpRequest.Builder request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:" + serverPort + "/api/v1/containers"))
                .GET();
        if (token != null) {
            request.header("Authorization", "Bearer " + token);
        }
        if (correlationId != null) {
            request.header("X-Correlation-ID", correlationId);
        }
        return HttpClient.newHttpClient().send(request.build(), HttpResponse.BodyHandlers.ofString());
    }

    private HttpResponse<String> get(String path, String token) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:" + serverPort + path))
                .header("Authorization", "Bearer " + token)
                .GET()
                .build();
        return HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
    }

    private HttpResponse<String> postContainer(String token, String code) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:" + serverPort + "/api/v1/containers"))
                .header("Authorization", "Bearer " + token)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString("{\"code\":\"" + code + "\"}"))
                .build();
        return HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
    }

    private HttpResponse<String> login(String username, String password) throws Exception {
        String body = "{\"username\":\"" + username + "\",\"password\":\"" + password + "\"}";
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:" + serverPort + "/api/v1/auth/login"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();
        return HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
    }

    private HttpResponse<String> request(EndpointAccess endpoint, String token) throws Exception {
        HttpRequest.Builder request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:" + serverPort + endpoint.path()));
        if (token != null) {
            request.header("Authorization", "Bearer " + token);
        }
        if (endpoint.body() != null) {
            request.header("Content-Type", "application/json");
        }
        if ("GET".equals(endpoint.method())) {
            request.GET();
        } else {
            request.POST(endpoint.body() == null
                    ? HttpRequest.BodyPublishers.noBody()
                    : HttpRequest.BodyPublishers.ofString(endpoint.body()));
        }
        return HttpClient.newHttpClient().send(request.build(), HttpResponse.BodyHandlers.ofString());
    }

    private void assertProblem(HttpResponse<String> response, int status, String code) throws Exception {
        assertProblem(response, status, code, "/api/v1/containers");
    }

    private void assertProblem(
            HttpResponse<String> response,
            int status,
            String code,
            String expectedInstance
    ) throws Exception {
        assertEquals(status, response.statusCode());
        assertTrue(response.headers().firstValue("Content-Type").orElse("")
                .startsWith("application/problem+json"));

        JsonNode problem = objectMapper.readTree(response.body());
        assertEquals(status, problem.get("status").intValue());
        assertEquals(code, problem.get("code").stringValue());
        assertEquals(expectedInstance, problem.get("instance").stringValue());
        assertFalse(problem.get("traceId").stringValue().isBlank());
        assertEquals(
                response.headers().firstValue("X-Correlation-ID").orElseThrow(),
                problem.get("traceId").stringValue()
        );
        assertFalse(problem.get("timestamp").stringValue().isBlank());
        assertTrue(problem.get("errors").isArray());
    }

    private record EndpointAccess(String method, String path, String body, Set<String> allowedRoles) {}
}
