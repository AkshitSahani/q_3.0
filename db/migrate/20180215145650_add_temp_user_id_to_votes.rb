class AddTempUserIdToVotes < ActiveRecord::Migration[5.0]
  def change
    add_column :votes, :temp_user_id, :integer
  end
end
