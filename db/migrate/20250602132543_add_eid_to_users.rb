class AddEidToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :eid, :text

    reversible do |dir|
      dir.up do
        User.all.each do
          it.update!(eid: UUID7.generate(timestamp: it.created_at))
        end
      end
    end

    change_column_null :users, :eid, false
    add_index :users, :eid, unique: true
  end
end
