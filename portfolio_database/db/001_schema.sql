-- Professional Portfolio Dashboard - Schema
-- Target: PostgreSQL
--
-- Notes:
-- - This project already had some tables/types in the running DB. This file reflects
--   the REQUIRED target schema from the task request.
-- - In environments where an earlier schema exists, apply needed ALTERs carefully.
-- - Password hashes are produced using pgcrypto (bcrypt via crypt/gen_salt).
--
-- Requirements covered:
-- 1) Tables: users, profiles, projects, skills, project_skills, contact_messages
-- 2) Indexes: users(email), users(username), projects(owner_user_id),
--             contact_messages(sender_email), contact_messages(status, created_at)
-- 3) Constraints + FKs with ON DELETE CASCADE where sensible
-- 4) Enums for users.role, projects.status, contact_messages.status

-- Extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enum types
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('user','admin');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_status') THEN
    CREATE TYPE project_status AS ENUM ('draft','published');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contact_message_status') THEN
    CREATE TYPE contact_message_status AS ENUM ('new','read','archived');
  END IF;
END $$;

-- users
CREATE TABLE IF NOT EXISTS users (
  id            BIGSERIAL PRIMARY KEY,
  email         TEXT NOT NULL UNIQUE,
  username      TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role          user_role NOT NULL DEFAULT 'user',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- profiles (1:1 with users)
CREATE TABLE IF NOT EXISTS profiles (
  id         BIGSERIAL PRIMARY KEY,
  user_id    BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  full_name  TEXT,
  bio        TEXT,
  avatar_url TEXT,
  location   TEXT,
  website    TEXT,
  socials    JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- projects
CREATE TABLE IF NOT EXISTS projects (
  id            BIGSERIAL PRIMARY KEY,
  owner_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title         TEXT NOT NULL,
  description   TEXT,
  repo_url      TEXT,
  live_url      TEXT,
  status        project_status NOT NULL DEFAULT 'draft',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- skills
CREATE TABLE IF NOT EXISTS skills (
  id         BIGSERIAL PRIMARY KEY,
  name       TEXT NOT NULL UNIQUE,
  category   TEXT,
  level      INT NOT NULL CHECK (level BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- project_skills (many-to-many)
CREATE TABLE IF NOT EXISTS project_skills (
  project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  skill_id   BIGINT NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  PRIMARY KEY (project_id, skill_id)
);

-- contact_messages
CREATE TABLE IF NOT EXISTS contact_messages (
  id           BIGSERIAL PRIMARY KEY,
  sender_name  TEXT NOT NULL,
  sender_email TEXT NOT NULL,
  subject      TEXT,
  message      TEXT NOT NULL,
  status       contact_message_status NOT NULL DEFAULT 'new',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes (explicit, even though UNIQUE also creates indexes; required by task)
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_projects_owner_user_id ON projects(owner_user_id);
CREATE INDEX IF NOT EXISTS idx_contact_messages_sender_email ON contact_messages(sender_email);
CREATE INDEX IF NOT EXISTS idx_contact_messages_status_created_at ON contact_messages(status, created_at);
