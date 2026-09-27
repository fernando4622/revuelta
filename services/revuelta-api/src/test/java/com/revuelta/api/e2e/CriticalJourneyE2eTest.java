package com.revuelta.api.e2e;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.time.Instant;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
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
class CriticalJourneyE2eTest {

    private static final HttpClient HTTP = HttpClient.newHttpClient();
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
    private ObjectMapper objectMapper;

    @Test
    void shouldCompleteApprovedDualQrJourneyWithMultipleContainersAndHistory() throws Exception {
        String adminToken = login("admin");
        String operatorToken = login("operator");
        String participantToken = login("student1");

        PreparedContainer first = prepareContainer(adminToken, "E2E-A-");
        PreparedContainer second = prepareContainer(adminToken, "E2E-B-");

        JsonNode firstDelivery = deliver(participantToken, operatorToken, first.qrPayload());
        JsonNode secondDelivery = deliver(participantToken, operatorToken, second.qrPayload());

        assertEquals("IN_USE", firstDelivery.get("container").get("state").stringValue());
        assertEquals("IN_USE", secondDelivery.get("container").get("state").stringValue());
        assertEquals(48, firstDelivery.get("policy").get("durationHours").intValue());

        Instant deliveredAt = Instant.parse(firstDelivery.get("deliveredAt").stringValue());
        Instant dueAt = Instant.parse(firstDelivery.get("dueAt").stringValue());
        assertEquals(Duration.ofHours(48), Duration.between(deliveredAt, dueAt));

        JsonNode active = json(get("/api/v1/me/circulations?status=ACTIVE", participantToken), 200);
        assertEquals(2, active.get("items").size());

        String replayPayload = operationQr(participantToken, "DELIVERY");
        JsonNode thirdPreview = json(post(
                "/api/v1/delivery-previews",
                operatorToken,
                Map.of(
                        "participantQrPayload", replayPayload,
                        "containerQrPayload", first.qrPayload()
                )
        ), 409);
        assertEquals("ACTIVE_CIRCULATION_EXISTS", thirdPreview.get("code").stringValue());

        String returnQr = operationQr(participantToken, "RETURN");
        JsonNode returned = json(post(
                "/api/v1/circulation-returns",
                operatorToken,
                Map.of(
                        "participantQrPayload", returnQr,
                        "containerQrPayload", first.qrPayload()
                )
        ), 200);
        assertEquals("RETURNED", returned.get("container").get("state").stringValue());

        JsonNode replayedReturn = json(post(
                "/api/v1/circulation-returns",
                operatorToken,
                Map.of(
                        "participantQrPayload", returnQr,
                        "containerQrPayload", first.qrPayload()
                )
        ), 409);
        assertEquals("QR_ALREADY_USED", replayedReturn.get("code").stringValue());

        JsonNode pendingWashes = json(get("/api/v1/operator/pending-washes", operatorToken), 200);
        assertTrue(itemsContain(pendingWashes, "containerId", first.id()));

        JsonNode washed = json(post(
                "/api/v1/containers/" + first.id() + "/wash-completions",
                operatorToken,
                null
        ), 200);
        assertEquals("AVAILABLE", washed.get("container").get("state").stringValue());

        JsonNode completed = json(get("/api/v1/me/circulations?status=COMPLETED", participantToken), 200);
        assertEquals(1, completed.get("items").size());
        assertEquals(first.id(), completed.get("items").get(0).get("containerId").stringValue());

        JsonNode remainingActive = json(get("/api/v1/me/circulations?status=ACTIVE", participantToken), 200);
        assertEquals(1, remainingActive.get("items").size());
        assertEquals(second.id(), remainingActive.get("items").get(0).get("containerId").stringValue());

        JsonNode history = json(get(
                "/api/v1/containers/" + first.id() + "/history?size=20",
                adminToken
        ), 200);
        assertEquals(
                Set.of("REGISTERED", "ACTIVATED", "DELIVERED", "RETURNED", "WASH_COMPLETED"),
                eventTypes(history)
        );
    }

    private PreparedContainer prepareContainer(String adminToken, String prefix) throws Exception {
        JsonNode registered = json(post(
                "/api/v1/containers",
                adminToken,
                Map.of("code", prefix + UUID.randomUUID())
        ), 201);
        String id = registered.get("id").stringValue();
        String qrPayload = registered.get("qrPayload").stringValue();

        JsonNode activated = json(post(
                "/api/v1/containers/" + id + "/activate",
                adminToken,
                Map.of("reason", "F9 E2E activation")
        ), 200);
        assertEquals("AVAILABLE", activated.get("status").stringValue());
        return new PreparedContainer(id, qrPayload);
    }

    private JsonNode deliver(
            String participantToken,
            String operatorToken,
            String containerQrPayload
    ) throws Exception {
        String participantQrPayload = operationQr(participantToken, "DELIVERY");
        return json(post(
                "/api/v1/circulations",
                operatorToken,
                Map.of(
                        "participantQrPayload", participantQrPayload,
                        "containerQrPayload", containerQrPayload
                )
        ), 201);
    }

    private String operationQr(String participantToken, String purpose) throws Exception {
        JsonNode qr = json(post(
                "/api/v1/me/operation-qrs",
                participantToken,
                Map.of("purpose", purpose)
        ), 201);
        return qr.get("payload").stringValue();
    }

    private String login(String username) throws Exception {
        JsonNode response = json(post(
                "/api/v1/auth/login",
                null,
                Map.of("username", username, "password", "password123")
        ), 200);
        return response.get("token").stringValue();
    }

    private HttpResponse<String> get(String path, String token) throws Exception {
        HttpRequest request = authorizedRequest(path, token).GET().build();
        return HTTP.send(request, HttpResponse.BodyHandlers.ofString());
    }

    private HttpResponse<String> post(String path, String token, Object body) throws Exception {
        HttpRequest.BodyPublisher publisher = body == null
                ? HttpRequest.BodyPublishers.noBody()
                : HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(body));
        HttpRequest.Builder request = authorizedRequest(path, token)
                .header("Content-Type", "application/json")
                .POST(publisher);
        return HTTP.send(request.build(), HttpResponse.BodyHandlers.ofString());
    }

    private HttpRequest.Builder authorizedRequest(String path, String token) {
        HttpRequest.Builder request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:" + serverPort + path));
        if (token != null) {
            request.header("Authorization", "Bearer " + token);
        }
        return request;
    }

    private JsonNode json(HttpResponse<String> response, int expectedStatus) throws Exception {
        assertEquals(expectedStatus, response.statusCode(), response.body());
        return objectMapper.readTree(response.body());
    }

    private boolean itemsContain(JsonNode page, String field, String value) {
        for (JsonNode item : page.get("items")) {
            if (value.equals(item.get(field).stringValue())) {
                return true;
            }
        }
        return false;
    }

    private Set<String> eventTypes(JsonNode page) {
        Set<String> types = new HashSet<>();
        for (JsonNode item : page.get("items")) {
            types.add(item.get("eventType").stringValue());
        }
        return types;
    }

    private record PreparedContainer(String id, String qrPayload) {}
}
