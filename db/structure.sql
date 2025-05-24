CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "email" varchar NOT NULL, "encrypted_password" varchar(128) NOT NULL, "confirmation_token" varchar(128), "remember_token" varchar(128) NOT NULL);
CREATE INDEX "index_users_on_email" ON "users" ("email") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_users_on_confirmation_token" ON "users" ("confirmation_token") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_users_on_remember_token" ON "users" ("remember_token") /*application='Sroodle'*/;
CREATE TABLE IF NOT EXISTS "polls" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "description" varchar, "creator_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "eid" uuid NOT NULL, CONSTRAINT "fk_rails_8697722fce"
FOREIGN KEY ("creator_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_polls_on_creator_id" ON "polls" ("creator_id") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_polls_on_eid" ON "polls" ("eid") /*application='Sroodle'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20250519211503'),
('20250518182338'),
('20250518141646');

