package com.revuelta.api.infrastructure.persistence;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;

@Testcontainers
@TestMethodOrder(OrderAnnotation.class)
class MigrationProfileIsolationTest {

    private static final String DEVELOPMENT_USERS = "'admin', 'operator', 'student1'";

    @Container
    static final PostgreSQLContainer postgres = new PostgreSQLContainer(
            DockerImageName.parse("postgres:16-alpine")
    );

    @Test
    @Order(1)
    void commonMigrationsMustNotLeaveDevelopmentAccounts() throws SQLException {
        migrate("classpath:db/migration");

        assertEquals(0, countDevelopmentUsers());
    }

    @Test
    @Order(2)
    void developmentLocationSeedsExactlyTheThreeApprovedAccounts() throws SQLException {
        migrate("classpath:db/migration", "classpath:db/dev");

        assertEquals(3, countDevelopmentUsers());
        assertEquals(3, countDevelopmentRoleAssignments());
        assertDevelopmentPasswordsMatchDocumentedCredential();
    }

    private void migrate(String... locations) {
        Flyway.configure()
                .dataSource(postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword())
                .locations(locations)
                .load()
                .migrate();
    }

    private long countDevelopmentUsers() throws SQLException {
        return queryForCount("SELECT COUNT(*) FROM users WHERE username IN (" + DEVELOPMENT_USERS + ")");
    }

    private long countDevelopmentRoleAssignments() throws SQLException {
        return queryForCount("""
                SELECT COUNT(*)
                FROM user_roles ur
                JOIN users u ON u.id = ur.user_id
                WHERE u.username IN (""" + DEVELOPMENT_USERS + ")");
    }

    private long queryForCount(String sql) throws SQLException {
        try (Connection connection = DriverManager.getConnection(
                postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword());
                Statement statement = connection.createStatement();
                ResultSet result = statement.executeQuery(sql)) {
            result.next();
            return result.getLong(1);
        }
    }

    private void assertDevelopmentPasswordsMatchDocumentedCredential() throws SQLException {
        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

        try (Connection connection = DriverManager.getConnection(
                postgres.getJdbcUrl(), postgres.getUsername(), postgres.getPassword());
                Statement statement = connection.createStatement();
                ResultSet result = statement.executeQuery(
                        "SELECT password_hash FROM users WHERE username IN (" + DEVELOPMENT_USERS + ")")) {
            int matchedPasswords = 0;
            while (result.next()) {
                assertTrue(passwordEncoder.matches("password123", result.getString("password_hash")));
                matchedPasswords++;
            }
            assertEquals(3, matchedPasswords);
        }
    }
}
