class AddEndVotingAtToPolls < ActiveRecord::Migration[8.0]
  def change
    add_column :polls, :end_voting_at, :datetime

    reversible do |dir|
      dir.up do
        Poll.update_all("end_voting_at = datetime(created_at, '+7 days')")
      end
    end

    change_column_null :polls, :end_voting_at, false
  end
end
