package com.revuelta.api.infrastructure.persistence;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.UUID;
import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.MigrationVersion;
import org.junit.jupiter.api.Test;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;

@Testcontainers
class MigrationUpgradePathTest {

    @Container
    static final PostgreSQLContainer postgres = new PostgreSQLContainer(
            DockerImageName.parse("postgres:16-alpine")
    );

    @Test
    void shouldUpgradePreviousSchemaAndPreserveRepresentativeData() throws SQLException {
        migrateToVersion("9");
        UUID containerId = UUID.randomUUID();
        insertRepresentativeContainer(containerId);

        migrateToLatest();

        assertEquals("10", queryForString("""
                SELECT version
                FROM flyway_schema_history
                WHERE success = TRUE
                ORDER BY installed_rank DESC
                LIMIT 1
                """));
        assertEquals(1, queryForLong(
                "SELECT COUNT(*) FROM containers WHERE id = '" + containerId + "'"
        ));
        assertEquals(2, queryForLong("""
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema = 'public'
                  AND table_name = 'container_events'
                  AND column_name IN ('participant_id', 'circulation_id')
                """));
    }

    private void migrateToVersion(String version) {
        Flyway.configure()
                .dataSource(postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword())
                .locations("classpath:db/migration")
                .target(MigrationVersion.fromVersion(version))
                .load()
                .migrate();
    }

    private void migrateToLatest() {
        Flyway.configure()
                .dataSource(postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword())
                .locations("classpath:db/migration")
                .load()
                .migrate();
    }

    private void insertRepresentativeContainer(UUID containerId) throws SQLException {
        execute("""
                INSERT INTO containers (
                    id, code, status, created_at, updated_at, lock_version, qr_generation
                ) VALUES (
                    '%s', 'F9-UPGRADE-CONTAINER', 'AVAILABLE', NOW(), NOW(), 0, 1
                )
                """.formatted(containerId));
    }

    private void execute(String sql) throws SQLException {
        try (Connection connection = connection(); Statement statement = connection.createStatement()) {
            statement.execute(sql);
        }
    }

    private long queryForLong(String sql) throws SQLException {
        try (Connection connection = connection();
                Statement statement = connection.createStatement();
                ResultSet result = statement.executeQuery(sql)) {
            result.next();
            return result.getLong(1);
        }
    }

    private String queryForString(String sql) throws SQLException {
        try (Connection connection = connection();
                Statement statement = connection.createStatement();
                ResultSet result = statement.executeQuery(sql)) {
            result.next();
            return result.getString(1);
        }
    }

    private Connection connection() throws SQLException {
        return DriverManager.getConnection(
                postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword()
        );
    }
}
