class ChangeFirstName < ActiveRecord::Migration[5.0]
  def change
    rename_column :temp_users, :firstname, :first_name
  end
end
