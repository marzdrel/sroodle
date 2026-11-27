# frozen_string_literal: true

# The organizer's time zone, used to end voting at the end of the chosen day
# in their local time instead of the server's (UTC).
class AddTimeZoneToPolls < ActiveRecord::Migration[8.1]
  def change
    add_column :polls, :time_zone, :string, null: false, default: "UTC"
  end
end
