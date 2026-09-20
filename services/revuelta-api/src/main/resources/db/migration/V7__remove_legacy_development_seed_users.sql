-- Development accounts were historically created by common migrations.
-- Remove only the known seed identities so non-development environments do not
-- expose predictable credentials. Foreign-key restrictions intentionally stop
-- this migration instead of deleting audit/circulation history.
DELETE FROM user_roles ur
USING users u
WHERE ur.user_id = u.id
AND (u.id, u.username) IN (
    ('a0000000-0000-0000-0000-000000000001', 'admin'),
    ('a0000000-0000-0000-0000-000000000002', 'operator'),
    ('a0000000-0000-0000-0000-000000000003', 'student1')
);

DELETE FROM users
WHERE (id, username) IN (
    ('a0000000-0000-0000-0000-000000000001', 'admin'),
    ('a0000000-0000-0000-0000-000000000002', 'operator'),
    ('a0000000-0000-0000-0000-000000000003', 'student1')
);
