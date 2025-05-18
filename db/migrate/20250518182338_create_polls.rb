class CreatePolls < ActiveRecord::Migration[8.0]
  def change
    create_table :polls do |t|
      t.string :name, null: false
      t.string :description

      t.references(
        :creator,
        null: false,
        foreign_key: { to_table: :users },
      )

      t.timestamps
    end
  end
end
