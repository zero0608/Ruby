class AddFieldsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :slug, :string
    add_index :users, :slug, unique: true
    add_reference :users, :user_group, foreign_key: true
  end
end
