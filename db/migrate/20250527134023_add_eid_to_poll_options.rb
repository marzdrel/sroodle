class AddEidToPollOptions < ActiveRecord::Migration[8.0]
  def change
    add_column :poll_options, :eid, :uuid

    reversible do |dir|
      dir.up do
        Poll::Option.all.each do
          it.update!(eid: UUID7.generate(timestamp: it.created_at))
        end
      end
    end

    change_column_null :poll_options, :eid, false
    add_index :poll_options, :eid, unique: true
  end
end
