-- Seed Default Return Policy (48 hours)
INSERT INTO return_policies (id, name, duration_hours, active, created_at) VALUES
('c0000000-0000-0000-0000-000000000001', 'Default Pilot 48h Policy', 48, TRUE, NOW())
ON CONFLICT DO NOTHING;
