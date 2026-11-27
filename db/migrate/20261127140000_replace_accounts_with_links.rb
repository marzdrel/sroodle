# frozen_string_literal: true

# Replaces user accounts with link-based access (see issue #118):
#
# - polls get a secret admin_token plus the organizer's name and email
# - votes belong to a poll participant instead of a user
# - the users table and its Clearance columns go away
#
# Existing data is kept: every user who voted on a poll becomes a participant
# of that poll, and the poll creator becomes the organizer.
class ReplaceAccountsWithLinks < ActiveRecord::Migration[8.1]
  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  class MigrationPoll < ActiveRecord::Base
    self.table_name = "polls"
  end

  class MigrationParticipant < ActiveRecord::Base
    self.table_name = "poll_participants"
  end

  class MigrationVote < ActiveRecord::Base
    self.table_name = "poll_votes"
  end

  def up
    add_column :polls, :admin_token, :string
    add_column :polls, :organizer_name, :string
    add_column :polls, :organizer_email, :string

    create_table :poll_participants do |t|
      t.references :poll, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email
      t.string :token, null: false
      t.text :eid, null: false
      t.timestamps
    end

    add_index :poll_participants, :token, unique: true
    add_index :poll_participants, :eid, unique: true

    add_reference(
      :poll_votes,
      :participant,
      foreign_key: {to_table: :poll_participants}
    )

    backfill_polls
    backfill_participants

    change_column_null :polls, :admin_token, false
    change_column_null :polls, :organizer_name, false
    add_index :polls, :admin_token, unique: true

    remove_index :poll_votes, name: "index_poll_votes_on_poll_option_user"
    remove_reference :poll_votes, :user, foreign_key: true, index: true
    change_column_null :poll_votes, :participant_id, false
    add_index(
      :poll_votes,
      [:option_id, :participant_id],
      unique: true,
      name: "index_poll_votes_on_option_participant"
    )

    remove_reference :polls, :creator, foreign_key: {to_table: :users}, index: true
    drop_table :users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def backfill_polls
    MigrationPoll.reset_column_information

    MigrationPoll.find_each do |poll|
      creator = MigrationUser.find_by(id: poll.creator_id)
      email = creator&.email

      poll.update_columns(
        admin_token: SecureRandom.base58(24),
        organizer_name: email.to_s.split("@").first.presence || "Organizer",
        organizer_email: email
      )
    end
  end

  def backfill_participants
    MigrationParticipant.reset_column_information
    MigrationVote.reset_column_information

    pairs = MigrationVote.distinct.pluck(:poll_id, :user_id)

    pairs.each do |poll_id, user_id|
      email = MigrationUser.find_by(id: user_id)&.email

      participant = MigrationParticipant.create!(
        poll_id: poll_id,
        name: email.to_s.split("@").first.presence || "Participant",
        email: email,
        token: SecureRandom.base58(24),
        eid: UUID7.generate
      )

      MigrationVote
        .where(poll_id: poll_id, user_id: user_id)
        .update_all(participant_id: participant.id)
    end
  end
end
