package com.revuelta.api.infrastructure.persistence;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;

@Testcontainers
class DataIntegrityPostgresIntegrationTest {

    private static final UUID BORROWER_ID = UUID.fromString("20000000-0000-0000-0000-000000000001");
    private static final UUID OPERATOR_ID = UUID.fromString("20000000-0000-0000-0000-000000000002");
    private static final UUID POLICY_ID = UUID.fromString("c0000000-0000-0000-0000-000000000001");

    @Container
    static final PostgreSQLContainer postgres = new PostgreSQLContainer(
            DockerImageName.parse("postgres:16-alpine")
    );

    @BeforeAll
    static void migrateAndSeedActors() throws SQLException {
        Flyway.configure()
                .dataSource(postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword())
                .locations("classpath:db/migration")
                .load()
                .migrate();

        try (Connection connection = connection();
                PreparedStatement insert = connection.prepareStatement("""
                        INSERT INTO users (id, username, password_hash, created_at, updated_at)
                        VALUES (?, ?, 'not-used-by-integration-test', NOW(), NOW())
                        """)) {
            insertUser(insert, BORROWER_ID, "constraint-borrower");
            insertUser(insert, OPERATOR_ID, "constraint-operator");
        }
    }

    @Test
    void concurrentDeliveryAllowsExactlyOneActiveCirculationForAContainer() throws Exception {
        UUID containerId = insertContainer("CONCURRENT-" + UUID.randomUUID(), "AVAILABLE");
        CountDownLatch ready = new CountDownLatch(2);
        CountDownLatch start = new CountDownLatch(1);
        AtomicReference<SQLException> failure = new AtomicReference<>();
        ExecutorService executor = Executors.newFixedThreadPool(2);

        try {
            Future<Boolean> first = executor.submit(() -> insertActiveCirculationConcurrently(
                    containerId,
                    ready,
                    start,
                    failure
            ));
            Future<Boolean> second = executor.submit(() -> insertActiveCirculationConcurrently(
                    containerId,
                    ready,
                    start,
                    failure
            ));

            ready.await(10, TimeUnit.SECONDS);
            start.countDown();

            int committed = (first.get(15, TimeUnit.SECONDS) ? 1 : 0)
                    + (second.get(15, TimeUnit.SECONDS) ? 1 : 0);
            assertEquals(1, committed);
            assertNotNull(failure.get());
            assertEquals("23505", failure.get().getSQLState());
            assertEquals(1, countActiveCirculations(containerId));
        } finally {
            executor.shutdownNow();
        }
    }

    @Test
    void oneParticipantMayHoldMultipleDifferentContainers() throws SQLException {
        UUID firstContainer = insertContainer("MULTI-A-" + UUID.randomUUID(), "AVAILABLE");
        UUID secondContainer = insertContainer("MULTI-B-" + UUID.randomUUID(), "AVAILABLE");

        insertActiveCirculation(firstContainer);
        insertActiveCirculation(secondContainer);

        assertEquals(2, countActiveCirculationsForBorrower(BORROWER_ID, firstContainer, secondContainer));
    }

    @Test
    void lifecyclePolicyAndHistoryConstraintsRejectInconsistentRowsAndDeletion() throws SQLException {
        UUID containerId = insertContainer("HISTORY-" + UUID.randomUUID(), "RETURNED");
        UUID correlationId = UUID.randomUUID();
        insertEvent(containerId, correlationId);

        SQLException deleteFailure = assertThrows(SQLException.class, () -> deleteContainer(containerId));
        assertEquals("23503", deleteFailure.getSQLState());

        SQLException lifecycleFailure = assertThrows(
                SQLException.class,
                () -> insertCompletedCirculationWithoutReturnFields(containerId)
        );
        assertEquals("23514", lifecycleFailure.getSQLState());

        SQLException correlationFailure = assertThrows(
                SQLException.class,
                () -> insertEventWithoutCorrelation(insertContainer("NO-CORR-" + UUID.randomUUID(), "AVAILABLE"))
        );
        assertEquals("23502", correlationFailure.getSQLState());
    }

    private static void insertUser(PreparedStatement insert, UUID id, String username) throws SQLException {
        insert.setObject(1, id);
        insert.setString(2, username);
        insert.executeUpdate();
    }

    private boolean insertActiveCirculationConcurrently(
            UUID containerId,
            CountDownLatch ready,
            CountDownLatch start,
            AtomicReference<SQLException> failure
    ) {
        try (Connection connection = connection()) {
            connection.setAutoCommit(false);
            ready.countDown();
            start.await(10, TimeUnit.SECONDS);
            insertActiveCirculation(connection, containerId);
            connection.commit();
            return true;
        } catch (SQLException exception) {
            failure.compareAndSet(null, exception);
            return false;
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException(exception);
        }
    }

    private void insertActiveCirculation(UUID containerId) throws SQLException {
        try (Connection connection = connection()) {
            insertActiveCirculation(connection, containerId);
        }
    }

    private void insertActiveCirculation(Connection connection, UUID containerId) throws SQLException {
        try (PreparedStatement insert = connection.prepareStatement("""
                INSERT INTO circulations (
                    id, container_id, borrower_id, delivered_by, delivered_at, due_at,
                    status, created_at, return_policy_id, return_policy_version
                ) VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE', ?, ?, 1)
                """)) {
            Instant deliveredAt = Instant.parse("2026-09-20T18:00:00Z");
            insert.setObject(1, UUID.randomUUID());
            insert.setObject(2, containerId);
            insert.setObject(3, BORROWER_ID);
            insert.setObject(4, OPERATOR_ID);
            insert.setTimestamp(5, Timestamp.from(deliveredAt));
            insert.setTimestamp(6, Timestamp.from(deliveredAt.plusSeconds(48 * 60 * 60)));
            insert.setTimestamp(7, Timestamp.from(deliveredAt));
            insert.setObject(8, POLICY_ID);
            insert.executeUpdate();
        }
    }

    private UUID insertContainer(String code, String status) throws SQLException {
        UUID id = UUID.randomUUID();
        try (Connection connection = connection();
                PreparedStatement insert = connection.prepareStatement("""
                        INSERT INTO containers (id, code, status, created_at, updated_at)
                        VALUES (?, ?, ?, NOW(), NOW())
                        """)) {
            insert.setObject(1, id);
            insert.setString(2, code);
            insert.setString(3, status);
            insert.executeUpdate();
        }
        return id;
    }

    private void insertEvent(UUID containerId, UUID correlationId) throws SQLException {
        try (Connection connection = connection();
                PreparedStatement insert = connection.prepareStatement("""
                        INSERT INTO container_events (
                            id, container_id, event_type, actor_id, occurred_at,
                            previous_status, new_status, reason, correlation_id
                        ) VALUES (?, ?, 'RETURNED', ?, NOW(), 'IN_USE', 'RETURNED', 'Received', ?)
                        """)) {
            insert.setObject(1, UUID.randomUUID());
            insert.setObject(2, containerId);
            insert.setObject(3, OPERATOR_ID);
            insert.setObject(4, correlationId);
            insert.executeUpdate();
        }
    }

    private void insertEventWithoutCorrelation(UUID containerId) throws SQLException {
        try (Connection connection = connection();
                PreparedStatement insert = connection.prepareStatement("""
                        INSERT INTO container_events (
                            id, container_id, event_type, actor_id, occurred_at,
                            previous_status, new_status, reason
                        ) VALUES (?, ?, 'ACTIVATED', ?, NOW(), 'REGISTERED', 'AVAILABLE', 'Activated')
                        """)) {
            insert.setObject(1, UUID.randomUUID());
            insert.setObject(2, containerId);
            insert.setObject(3, OPERATOR_ID);
            insert.executeUpdate();
        }
    }

    private void insertCompletedCirculationWithoutReturnFields(UUID containerId) throws SQLException {
        try (Connection connection = connection();
                PreparedStatement insert = connection.prepareStatement("""
                        INSERT INTO circulations (
                            id, container_id, borrower_id, delivered_by, delivered_at, due_at,
                            status, created_at, return_policy_id, return_policy_version
                        ) VALUES (?, ?, ?, ?, NOW(), NOW() + INTERVAL '48 hours',
                                  'COMPLETED', NOW(), ?, 1)
                        """)) {
            insert.setObject(1, UUID.randomUUID());
            insert.setObject(2, containerId);
            insert.setObject(3, BORROWER_ID);
            insert.setObject(4, OPERATOR_ID);
            insert.setObject(5, POLICY_ID);
            insert.executeUpdate();
        }
    }

    private void deleteContainer(UUID containerId) throws SQLException {
        try (Connection connection = connection();
                PreparedStatement delete = connection.prepareStatement("DELETE FROM containers WHERE id = ?")) {
            delete.setObject(1, containerId);
            delete.executeUpdate();
        }
    }

    private long countActiveCirculations(UUID containerId) throws SQLException {
        try (Connection connection = connection();
                PreparedStatement query = connection.prepareStatement("""
                        SELECT COUNT(*) FROM circulations
                        WHERE container_id = ? AND status = 'ACTIVE'
                        """)) {
            query.setObject(1, containerId);
            try (ResultSet result = query.executeQuery()) {
                result.next();
                return result.getLong(1);
            }
        }
    }

    private long countActiveCirculationsForBorrower(UUID borrowerId, UUID first, UUID second) throws SQLException {
        try (Connection connection = connection();
                PreparedStatement query = connection.prepareStatement("""
                        SELECT COUNT(*) FROM circulations
                        WHERE borrower_id = ? AND status = 'ACTIVE' AND container_id IN (?, ?)
                        """)) {
            query.setObject(1, borrowerId);
            query.setObject(2, first);
            query.setObject(3, second);
            try (ResultSet result = query.executeQuery()) {
                result.next();
                return result.getLong(1);
            }
        }
    }

    private static Connection connection() throws SQLException {
        return DriverManager.getConnection(postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword());
    }
}
