class AddUniqueIndexToEidFields < ActiveRecord::Migration[8.0]
  def change
    add_index :polls, :eid, unique: true
    add_index :poll_options, :eid, unique: true
    add_index :poll_votes, :eid, unique: true
  end
end
