class AddTempuserToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :tempuserid, :integer
  end
end
