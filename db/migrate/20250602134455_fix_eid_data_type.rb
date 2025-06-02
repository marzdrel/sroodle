class FixEidDataType < ActiveRecord::Migration[8.0]
  def change
    tables = [:polls, :poll_votes, :poll_options]

    tables.each do |table|
      add_column table, :eid_new, :text
      execute "UPDATE #{table} SET eid_new = eid;"
      remove_column table, :eid
      rename_column table, :eid_new, :eid
    end
  end
end
