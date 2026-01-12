-- Professional Portfolio Dashboard - Seed Data
-- Target: PostgreSQL
--
-- Requirements covered:
-- - default admin user (admin@example.com / admin / role=admin) with bcrypt hash for
--   placeholder password 'ChangeMe_Admin123!'
-- - at least 2 skills
-- - 1 sample project linked to admin
-- - project_skills linking that project to skills
-- - 1 sample contact message

-- Admin user
INSERT INTO users (email, username, password_hash, role)
VALUES (
  'admin@example.com',
  'admin',
  crypt('ChangeMe_Admin123!', gen_salt('bf')),
  'admin'
)
ON CONFLICT (email) DO NOTHING;

-- Admin profile
INSERT INTO profiles (user_id, full_name, bio, avatar_url, location, website, socials)
SELECT
  u.id,
  'Admin User',
  'Administrator account for the Professional Portfolio Dashboard.',
  'https://example.com/avatar.png',
  'Remote',
  'https://example.com',
  '{"github":"https://github.com/admin","linkedin":"https://linkedin.com/in/admin"}'::jsonb
FROM users u
WHERE u.email = 'admin@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- Skills
INSERT INTO skills (name, category, level)
VALUES ('FastAPI', 'Backend', 4)
ON CONFLICT (name) DO NOTHING;

INSERT INTO skills (name, category, level)
VALUES ('React', 'Frontend', 4)
ON CONFLICT (name) DO NOTHING;

-- Sample project linked to admin
INSERT INTO projects (owner_user_id, title, description, repo_url, live_url, status)
SELECT
  u.id,
  'Sample Portfolio Project',
  'A sample project seeded for the admin user.',
  'https://github.com/example/sample-portfolio-project',
  'https://example.com/sample-portfolio-project',
  'published'
FROM users u
WHERE u.email = 'admin@example.com'
RETURNING id;

-- Link project to skills (best-effort; safe if rerun)
INSERT INTO project_skills (project_id, skill_id)
SELECT
  p.id,
  s.id
FROM projects p
JOIN users u ON u.id = p.owner_user_id
JOIN skills s ON s.name = 'FastAPI'
WHERE u.email = 'admin@example.com'
ORDER BY p.id DESC
LIMIT 1
ON CONFLICT DO NOTHING;

INSERT INTO project_skills (project_id, skill_id)
SELECT
  p.id,
  s.id
FROM projects p
JOIN users u ON u.id = p.owner_user_id
JOIN skills s ON s.name = 'React'
WHERE u.email = 'admin@example.com'
ORDER BY p.id DESC
LIMIT 1
ON CONFLICT DO NOTHING;

-- Sample contact message
INSERT INTO contact_messages (sender_name, sender_email, subject, message, status)
VALUES (
  'Jane Doe',
  'jane.doe@example.com',
  'Hello',
  'Just testing the contact form.',
  'new'
);
