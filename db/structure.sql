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
CREATE TABLE IF NOT EXISTS "poll_options" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "poll_id" integer NOT NULL, "start" datetime(6) NOT NULL, "duration_minutes" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_aa85becb42"
FOREIGN KEY ("poll_id")
  REFERENCES "polls" ("id")
, CONSTRAINT valid_duration_minutes CHECK (duration_minutes IN (30, 60, 90, 120, 1440)));
CREATE INDEX "index_poll_options_on_poll_id" ON "poll_options" ("poll_id") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_poll_options_on_poll_id_and_start" ON "poll_options" ("poll_id", "start") /*application='Sroodle'*/;
CREATE TABLE IF NOT EXISTS "poll_votes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "poll_id" integer NOT NULL, "option_id" integer NOT NULL, "user_id" integer NOT NULL, "response" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_a6e6974b7e"
FOREIGN KEY ("poll_id")
  REFERENCES "polls" ("id")
, CONSTRAINT "fk_rails_826ebfbbb3"
FOREIGN KEY ("option_id")
  REFERENCES "poll_options" ("id")
, CONSTRAINT "fk_rails_b64de9b025"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT valid_response CHECK (response IN ('yes', 'no', 'maybe')));
CREATE INDEX "index_poll_votes_on_poll_id" ON "poll_votes" ("poll_id") /*application='Sroodle'*/;
CREATE INDEX "index_poll_votes_on_option_id" ON "poll_votes" ("option_id") /*application='Sroodle'*/;
CREATE INDEX "index_poll_votes_on_user_id" ON "poll_votes" ("user_id") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_poll_votes_on_poll_option_user" ON "poll_votes" ("poll_id", "option_id", "user_id") /*application='Sroodle'*/;
CREATE INDEX "index_poll_options_on_start" ON "poll_options" ("start") /*application='Sroodle'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20250524190423'),
('20250524134301'),
('20250524132821'),
('20250519211503'),
('20250518182338'),
('20250518141646');

