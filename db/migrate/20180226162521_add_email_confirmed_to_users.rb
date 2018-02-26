class AddEmailConfirmedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email_confirmed, :boolean, :default => false
    add_column :users, :confirm_code, :string, :default => (0...8).map { (65 + rand(26)).chr }.join
  end
end
