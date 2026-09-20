package com.revuelta.api.infrastructure.persistence;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import com.revuelta.api.application.circulation.DeliverContainerUseCase;
import com.revuelta.api.application.circulation.ReturnContainerUseCase;
import com.revuelta.api.application.container.ActivateContainerUseCase;
import com.revuelta.api.application.container.GetContainerHistoryUseCase;
import com.revuelta.api.application.container.RegisterContainerUseCase;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.user.UserId;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;

@SpringBootTest
@ActiveProfiles("dev")
@Testcontainers
class PersistenceAdapterIntegrationTest {

    private static final UserId ADMIN = new UserId(
            UUID.fromString("a0000000-0000-0000-0000-000000000001")
    );
    private static final UserId OPERATOR = new UserId(
            UUID.fromString("a0000000-0000-0000-0000-000000000002")
    );
    private static final UserId PARTICIPANT = new UserId(
            UUID.fromString("a0000000-0000-0000-0000-000000000003")
    );

    @Container
    static final PostgreSQLContainer postgres = new PostgreSQLContainer(
            DockerImageName.parse("postgres:16-alpine")
    );

    @DynamicPropertySource
    static void configureApplication(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add(
                "jwt.secret",
                () -> "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970"
        );
    }

    @Autowired private RegisterContainerUseCase registerContainer;
    @Autowired private ActivateContainerUseCase activateContainer;
    @Autowired private DeliverContainerUseCase deliverContainer;
    @Autowired private ReturnContainerUseCase returnContainer;
    @Autowired private GetContainerHistoryUseCase getHistory;

    @Test
    void mutationsPersistPolicyVersionOptimisticStateAndCorrelatedAppendOnlyHistory() {
        var registered = registerContainer.execute("PERSIST-" + UUID.randomUUID());
        var available = activateContainer.execute(registered.id(), ADMIN, "Initial activation");
        var delivery = deliverContainer.execute(available.id(), PARTICIPANT, OPERATOR);
        var returned = returnContainer.execute(delivery.circulation().id(), OPERATOR);

        assertEquals(ContainerStatus.RETURNED, returned.container().status());
        assertNotNull(delivery.circulation().returnPolicyId());
        assertEquals(1, delivery.circulation().returnPolicyVersion());

        List<ContainerEvent> history = getHistory.execute(registered.id(), 0, 20);
        assertEquals(3, history.size());
        history.forEach(event -> {
            assertNotNull(event.actorId());
            assertNotNull(event.occurredAt());
            assertNotNull(event.eventType());
            assertNotNull(event.correlationId());
        });
    }
}
