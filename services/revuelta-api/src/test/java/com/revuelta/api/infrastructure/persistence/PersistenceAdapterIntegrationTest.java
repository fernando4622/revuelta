package com.revuelta.api.infrastructure.persistence;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.revuelta.api.application.failure.ApplicationFailureException;
import com.revuelta.api.application.failure.FailureCode;
import com.revuelta.api.application.circulation.DeliveryQrValidationService;
import com.revuelta.api.application.circulation.DeliverContainerUseCase;
import com.revuelta.api.application.circulation.ReturnContainerUseCase;
import com.revuelta.api.application.container.ActivateContainerUseCase;
import com.revuelta.api.application.container.GetContainerHistoryUseCase;
import com.revuelta.api.application.container.RegisterContainerUseCase;
import com.revuelta.api.application.qr.GenerateOperationQrUseCase;
import com.revuelta.api.application.qr.GetContainerQrUseCase;
import com.revuelta.api.application.port.CirculationRepositoryPort;
import com.revuelta.api.application.port.ContainerRepositoryPort;
import com.revuelta.api.application.port.CorrelationIdProviderPort;
import com.revuelta.api.application.port.OperationQrTokenRepositoryPort;
import com.revuelta.api.application.port.TransactionRunnerPort;
import com.revuelta.api.domain.container.ContainerStatus;
import com.revuelta.api.domain.event.ContainerEvent;
import com.revuelta.api.domain.event.ContainerEventRepositoryPort;
import com.revuelta.api.domain.participant.OperationQrPurpose;
import com.revuelta.api.domain.user.UserId;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
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
    @Autowired private GenerateOperationQrUseCase generateOperationQr;
    @Autowired private GetContainerQrUseCase getContainerQr;
    @Autowired private ReturnContainerUseCase returnContainer;
    @Autowired private GetContainerHistoryUseCase getHistory;
    @Autowired private DeliveryQrValidationService deliveryValidator;
    @Autowired private ContainerRepositoryPort containers;
    @Autowired private CirculationRepositoryPort circulations;
    @Autowired private OperationQrTokenRepositoryPort tokens;
    @Autowired private TransactionRunnerPort transactions;
    @Autowired private CorrelationIdProviderPort correlationIds;

    @Test
    void mutationsPersistPolicyVersionOptimisticStateAndCorrelatedAppendOnlyHistory() {
        var registered = registerContainer.execute("PERSIST-" + UUID.randomUUID(), ADMIN);
        var available = activateContainer.execute(registered.container().id(), ADMIN, "Initial activation");
        var participantQr = generateOperationQr.execute(PARTICIPANT, OperationQrPurpose.DELIVERY);
        var containerQr = getContainerQr.execute(available.id());
        var delivery = deliverContainer.execute(participantQr.payload(), containerQr.payload(), OPERATOR);
        var returned = returnContainer.execute(delivery.circulation().id(), OPERATOR);

        assertEquals(ContainerStatus.RETURNED, returned.container().status());
        assertNotNull(delivery.circulation().returnPolicyId());
        assertEquals(1, delivery.circulation().returnPolicyVersion());

        List<ContainerEvent> history = getHistory.execute(registered.container().id(), 0, 20);
        assertEquals(4, history.size());
        history.forEach(event -> {
            assertNotNull(event.actorId());
            assertNotNull(event.occurredAt());
            assertNotNull(event.eventType());
            assertNotNull(event.correlationId());
        });
        ContainerEvent deliveryEvent = history.stream()
                .filter(event -> event.circulationId() != null)
                .findFirst()
                .orElseThrow();
        assertEquals(PARTICIPANT.value(), deliveryEvent.participantId().value());
        assertEquals(delivery.circulation().id().value(), deliveryEvent.circulationId());
    }

    @Test
    void deliveryRollsBackContainerCirculationEventAndTokenWhenEventPersistenceFails() {
        var registered = registerContainer.execute("ROLLBACK-" + UUID.randomUUID(), ADMIN);
        var available = activateContainer.execute(registered.container().id(), ADMIN, "Initial activation");
        var participantQr = generateOperationQr.execute(PARTICIPANT, OperationQrPurpose.DELIVERY);
        var containerQr = getContainerQr.execute(available.id());
        ContainerEventRepositoryPort failingEvents = new ContainerEventRepositoryPort() {
            @Override
            public void save(ContainerEvent event) {
                throw new IllegalStateException("simulated event persistence failure");
            }

            @Override
            public List<ContainerEvent> findByContainerId(
                    com.revuelta.api.domain.container.ContainerId containerId,
                    int page,
                    int size
            ) {
                return List.of();
            }
        };
        DeliverContainerUseCase failingDelivery = new DeliverContainerUseCase(
                deliveryValidator,
                containers,
                circulations,
                tokens,
                failingEvents,
                transactions,
                correlationIds
        );

        assertThrows(IllegalStateException.class, () -> failingDelivery.execute(
                participantQr.payload(), containerQr.payload(), OPERATOR
        ));

        assertEquals(ContainerStatus.AVAILABLE, containers.findById(available.id()).orElseThrow().status());
        assertFalse(circulations.hasActiveCirculation(available.id()));
        assertFalse(tokens.findById(participantQr.tokenRef()).orElseThrow().isConsumed());
        assertEquals(2, getHistory.execute(available.id(), 0, 20).size());
    }

    @Test
    void concurrentDeliveryHasOneWinnerAndOneStableConflict() throws Exception {
        var registered = registerContainer.execute("RACE-" + UUID.randomUUID(), ADMIN);
        var available = activateContainer.execute(registered.container().id(), ADMIN, "Initial activation");
        var firstQr = generateOperationQr.execute(PARTICIPANT, OperationQrPurpose.DELIVERY);
        var secondQr = generateOperationQr.execute(PARTICIPANT, OperationQrPurpose.DELIVERY);
        var containerQr = getContainerQr.execute(available.id());
        CountDownLatch ready = new CountDownLatch(2);
        CountDownLatch start = new CountDownLatch(1);
        ExecutorService executor = Executors.newFixedThreadPool(2);

        try {
            Future<Object> first = executor.submit(() -> concurrentDelivery(firstQr.payload(), containerQr.payload(), ready, start));
            Future<Object> second = executor.submit(() -> concurrentDelivery(secondQr.payload(), containerQr.payload(), ready, start));
            assertTrue(ready.await(10, TimeUnit.SECONDS));
            start.countDown();

            Object firstResult = first.get(15, TimeUnit.SECONDS);
            Object secondResult = second.get(15, TimeUnit.SECONDS);
            long successes = List.of(firstResult, secondResult).stream()
                    .filter(DeliverContainerUseCase.DeliveryResult.class::isInstance)
                    .count();
            List<FailureCode> failures = List.of(firstResult, secondResult).stream()
                    .filter(FailureCode.class::isInstance)
                    .map(FailureCode.class::cast)
                    .toList();

            assertEquals(1, successes);
            assertEquals(1, failures.size());
            assertTrue(Set.of(
                    FailureCode.ACTIVE_CIRCULATION_EXISTS,
                    FailureCode.CONTAINER_NOT_AVAILABLE,
                    FailureCode.INVALID_STATE_TRANSITION
            ).contains(failures.get(0)));
            assertTrue(circulations.hasActiveCirculation(available.id()));
            assertEquals(ContainerStatus.IN_USE, containers.findById(available.id()).orElseThrow().status());
            assertEquals(3, getHistory.execute(available.id(), 0, 20).size());
            long consumed = List.of(firstQr.tokenRef(), secondQr.tokenRef()).stream()
                    .map(tokens::findById)
                    .map(Optional::orElseThrow)
                    .filter(com.revuelta.api.domain.participant.OperationQrToken::isConsumed)
                    .count();
            assertEquals(1, consumed);
        } finally {
            executor.shutdownNow();
        }
    }

    private Object concurrentDelivery(
            String participantPayload,
            String containerPayload,
            CountDownLatch ready,
            CountDownLatch start
    ) throws InterruptedException {
        ready.countDown();
        start.await(10, TimeUnit.SECONDS);
        try {
            return deliverContainer.execute(participantPayload, containerPayload, OPERATOR);
        } catch (ApplicationFailureException failure) {
            return failure.code();
        }
    }
}
