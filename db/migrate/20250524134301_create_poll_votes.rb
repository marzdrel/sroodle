class CreatePollVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :poll_votes do |t|
      t.references :poll, null: false, foreign_key: true
      t.references :option, null: false, foreign_key: { to_table: :poll_options }
      t.references :user, null: false, foreign_key: true
      t.string :response, null: false

      t.timestamps

      t.check_constraint(
        "response IN ('yes', 'no', 'maybe')",
        name: "valid_response",
      )
    end

    add_index(
      :poll_votes,
      [
        :poll_id,
        :option_id,
        :user_id,
      ],
      unique: true,
      name: "index_poll_votes_on_poll_option_user",
    )
  end
end
