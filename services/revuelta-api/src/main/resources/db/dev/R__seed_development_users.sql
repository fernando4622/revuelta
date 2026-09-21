-- Development-only accounts. This location is loaded exclusively by the dev
-- Spring profile and must never be enabled in pilot/production.
INSERT INTO users (id, username, password_hash, email, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000001', 'admin', '$2a$10$uL9eB4pkS0h6eEcInDFz9OilDolTy56TDV6df.8A5ukq.BP3uvl/O', 'admin@revuelta.app', NOW(), NOW()),
('a0000000-0000-0000-0000-000000000002', 'operator', '$2a$10$uL9eB4pkS0h6eEcInDFz9OilDolTy56TDV6df.8A5ukq.BP3uvl/O', 'operator@revuelta.app', NOW(), NOW()),
('a0000000-0000-0000-0000-000000000003', 'student1', '$2a$10$uL9eB4pkS0h6eEcInDFz9OilDolTy56TDV6df.8A5ukq.BP3uvl/O', 'student1@university.edu', NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
    username = EXCLUDED.username,
    password_hash = EXCLUDED.password_hash,
    email = EXCLUDED.email,
    updated_at = NOW();

INSERT INTO user_roles (user_id, role_id) VALUES
('a0000000-0000-0000-0000-000000000001', 'b3b3a1a1-0000-0000-0000-000000000002'),
('a0000000-0000-0000-0000-000000000002', 'b3b3a1a1-0000-0000-0000-000000000001'),
('a0000000-0000-0000-0000-000000000003', 'b3b3a1a1-0000-0000-0000-000000000003')
ON CONFLICT DO NOTHING;

-- Development-only account-to-participant association for the F4 demo.
-- The participant shares the UUID with student1 only as deterministic seed data;
-- productive provisioning must create and associate identities explicitly.
INSERT INTO participants (id, active, created_at) VALUES
('a0000000-0000-0000-0000-000000000003', TRUE, NOW())
ON CONFLICT (id) DO UPDATE SET active = EXCLUDED.active;

INSERT INTO participant_accounts (user_id, participant_id) VALUES
('a0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000003')
ON CONFLICT (user_id) DO UPDATE SET participant_id = EXCLUDED.participant_id;
