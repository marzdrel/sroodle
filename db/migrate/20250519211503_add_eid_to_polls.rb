class AddEidToPolls < ActiveRecord::Migration[8.0]
  def change
    add_column :polls, :eid, :uuid, null: false
    add_index :polls, :eid, unique: true
  end
end
