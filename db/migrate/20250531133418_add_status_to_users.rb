class AddStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :status, :string

    add_check_constraint(
      :users,
      "status IN ('pending', 'active', 'blocked')",
      name: "check_status_values",
    )

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE users
          SET status = 'pending'
          WHERE status IS NULL;
        SQL
      end
    end

    change_column_null :users, :status, false
  end
end
