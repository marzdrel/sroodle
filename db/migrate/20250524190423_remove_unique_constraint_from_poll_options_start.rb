class RemoveUniqueConstraintFromPollOptionsStart < ActiveRecord::Migration[8.0]
  def change
    # Remove the unique index on start column alone
    remove_index :poll_options, :start
    
    # Add a non-unique index on start column for performance
    add_index :poll_options, :start
  end
end
