class CreatePollOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :poll_options do |t|
      t.references :poll, null: false, foreign_key: true
      t.timestamp :start, null: false, index: { unique: true }
      t.integer :duration_minutes, null: false

      t.timestamps

      # SQLite check constraint must be added during table creation
      t.check_constraint "duration_minutes IN (30, 60, 90, 120, 1440)", name: "valid_duration_minutes"
    end

    add_index :poll_options, [:poll_id, :start], unique: true
  end
end
