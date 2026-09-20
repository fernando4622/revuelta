-- Development/MVP role for the Alumno/Maestro experience.
-- Participant is intentionally separate from the Cafeteria and ReVuelta staff roles.
INSERT INTO roles (id, name) VALUES
('b3b3a1a1-0000-0000-0000-000000000003', 'PARTICIPANT')
ON CONFLICT (name) DO NOTHING;

INSERT INTO user_roles (user_id, role_id) VALUES
('a0000000-0000-0000-0000-000000000003', 'b3b3a1a1-0000-0000-0000-000000000003')
ON CONFLICT DO NOTHING;
