-- V5: Update password hashes for seed users to valid BCrypt hash for 'password123'
UPDATE users 
SET password_hash = '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xD0m1bCua0ElwuIQ'
WHERE username IN ('admin', 'operator', 'student1');
