CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "poll_options" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "poll_id" integer NOT NULL, "start" datetime(6) NOT NULL, "duration_minutes" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "eid" text, CONSTRAINT "fk_rails_aa85becb42"
FOREIGN KEY ("poll_id")
  REFERENCES "polls" ("id")
, CONSTRAINT valid_duration_minutes CHECK (duration_minutes IN (30, 60, 90, 120, 1440)));
CREATE INDEX "index_poll_options_on_poll_id" ON "poll_options" ("poll_id") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_poll_options_on_poll_id_and_start" ON "poll_options" ("poll_id", "start") /*application='Sroodle'*/;
CREATE INDEX "index_poll_options_on_start" ON "poll_options" ("start") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_poll_options_on_eid" ON "poll_options" ("eid") /*application='Sroodle'*/;
CREATE TABLE "poll_participants" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "poll_id" integer NOT NULL, "name" varchar NOT NULL, "email" varchar, "token" varchar NOT NULL, "eid" text NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_d5d8b76b96"
FOREIGN KEY ("poll_id")
  REFERENCES "polls" ("id")
);
CREATE INDEX "index_poll_participants_on_poll_id" ON "poll_participants" ("poll_id") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_poll_participants_on_token" ON "poll_participants" ("token") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_poll_participants_on_eid" ON "poll_participants" ("eid") /*application='Sroodle'*/;
CREATE TABLE "poll_votes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "poll_id" integer NOT NULL, "option_id" integer NOT NULL, "response" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "eid" text, "participant_id" integer NOT NULL, CONSTRAINT "fk_rails_8edb557f38"
FOREIGN KEY ("participant_id")
  REFERENCES "poll_participants" ("id")
, CONSTRAINT "fk_rails_a6e6974b7e"
FOREIGN KEY ("poll_id")
  REFERENCES "polls" ("id")
, CONSTRAINT "fk_rails_826ebfbbb3"
FOREIGN KEY ("option_id")
  REFERENCES "poll_options" ("id")
, CONSTRAINT valid_response CHECK (response IN ('yes', 'no', 'maybe')));
CREATE INDEX "index_poll_votes_on_poll_id" ON "poll_votes" ("poll_id") /*application='Sroodle'*/;
CREATE INDEX "index_poll_votes_on_option_id" ON "poll_votes" ("option_id") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_poll_votes_on_eid" ON "poll_votes" ("eid") /*application='Sroodle'*/;
CREATE INDEX "index_poll_votes_on_participant_id" ON "poll_votes" ("participant_id") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_poll_votes_on_option_participant" ON "poll_votes" ("option_id", "participant_id") /*application='Sroodle'*/;
CREATE TABLE "polls" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "description" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "end_voting_at" datetime(6) NOT NULL, "eid" text, "admin_token" varchar NOT NULL, "organizer_name" varchar NOT NULL, "organizer_email" varchar);
CREATE UNIQUE INDEX "index_polls_on_eid" ON "polls" ("eid") /*application='Sroodle'*/;
CREATE UNIQUE INDEX "index_polls_on_admin_token" ON "polls" ("admin_token") /*application='Sroodle'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20261127140000'),
('20250602135050'),
('20250602134455'),
('20250602132543'),
('20250531170940'),
('20250531133418'),
('20250527170501'),
('20250527134023'),
('20250524190423'),
('20250524134301'),
('20250524132821'),
('20250519211503'),
('20250518182338'),
('20250518141646');

