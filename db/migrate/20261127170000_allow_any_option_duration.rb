# frozen_string_literal: true

# Timed options (see issue #127) can last anywhere from 15 minutes to a full
# day, so the fixed list of durations is replaced by a range.
class AllowAnyOptionDuration < ActiveRecord::Migration[8.1]
  def up
    remove_check_constraint :poll_options, name: "valid_duration_minutes"
    add_check_constraint(
      :poll_options,
      "duration_minutes BETWEEN 15 AND 1440",
      name: "valid_duration_minutes"
    )
  end

  def down
    remove_check_constraint :poll_options, name: "valid_duration_minutes"
    add_check_constraint(
      :poll_options,
      "duration_minutes IN (30, 60, 90, 120, 1440)",
      name: "valid_duration_minutes"
    )
  end
end
