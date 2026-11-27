# frozen_string_literal: true

# Lets the organizer close a poll and pick the final date.
class AddFinalOptionToPolls < ActiveRecord::Migration[8.1]
  def change
    add_column :polls, :closed_at, :datetime
    add_reference(
      :polls,
      :final_option,
      foreign_key: {to_table: :poll_options, on_delete: :nullify}
    )
  end
end
