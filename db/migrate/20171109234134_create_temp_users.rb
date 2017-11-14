class CreateTempUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :temp_users do |t|
      t.string :firstname

      t.timestamps
    end
  end
end
