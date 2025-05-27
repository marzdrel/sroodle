class AddEidToVotes < ActiveRecord::Migration[8.0]
  def change
    add_column :poll_votes, :eid, :uuid

    reversible do |dir|
      dir.up do
        Poll::Vote.all.each do
          it.update!(eid: UUID7.generate(timestamp: it.created_at))
        end
      end
    end

    change_column_null :poll_votes, :eid, false
    add_index :poll_votes, :eid, unique: true
  end
end
