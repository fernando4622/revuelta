package com.revuelta.api.infrastructure.security;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.revuelta.api.domain.user.UserId;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.UUID;
import org.junit.jupiter.api.Test;
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

    private HttpResponse<String> getContainers(String token) throws Exception {
        HttpRequest.Builder request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:" + serverPort + "/api/v1/containers"))
                .GET();
        if (token != null) {
            request.header("Authorization", "Bearer " + token);
        }
        return HttpClient.newHttpClient().send(request.build(), HttpResponse.BodyHandlers.ofString());
    }

    private void assertProblem(HttpResponse<String> response, int status, String code) throws Exception {
        assertEquals(status, response.statusCode());
        assertTrue(response.headers().firstValue("Content-Type").orElse("")
                .startsWith("application/problem+json"));

        JsonNode problem = objectMapper.readTree(response.body());
        assertEquals(status, problem.get("status").intValue());
        assertEquals(code, problem.get("code").stringValue());
        assertEquals("/api/v1/containers", problem.get("instance").stringValue());
        assertFalse(problem.get("traceId").stringValue().isBlank());
        assertFalse(problem.get("timestamp").stringValue().isBlank());
        assertTrue(problem.get("errors").isArray());
    }
}
