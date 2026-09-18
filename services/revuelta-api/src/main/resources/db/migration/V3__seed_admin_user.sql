-- Seed Initial Users (Password for all seed users: password123)
-- Valid Spring Security BCrypt Hash (cost factor 10) for 'password123':
-- $2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xD0m1bCua0ElwuIQ

-- Admin User
INSERT INTO users (id, username, password_hash, email, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000001', 'admin', '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xD0m1bCua0ElwuIQ', 'admin@revuelta.app', NOW(), NOW())
ON CONFLICT (username) DO UPDATE SET password_hash = '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xD0m1bCua0ElwuIQ';

INSERT INTO user_roles (user_id, role_id) VALUES
('a0000000-0000-0000-0000-000000000001', 'b3b3a1a1-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

-- Operator User
INSERT INTO users (id, username, password_hash, email, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000002', 'operator', '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xD0m1bCua0ElwuIQ', 'operator@revuelta.app', NOW(), NOW())
ON CONFLICT (username) DO UPDATE SET password_hash = '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xD0m1bCua0ElwuIQ';

INSERT INTO user_roles (user_id, role_id) VALUES
('a0000000-0000-0000-0000-000000000002', 'b3b3a1a1-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

-- Student Borrower User (DL-002)
INSERT INTO users (id, username, password_hash, email, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000003', 'student1', '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xD0m1bCua0ElwuIQ', 'student1@university.edu', NOW(), NOW())
ON CONFLICT (username) DO UPDATE SET password_hash = '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xD0m1bCua0ElwuIQ';
