class AddDiscriptionToCreateWhitelists < ActiveRecord::Migration[6.1]
  def change
    add_column :create_whitelists, :description, :text
    add_column :create_whitelists, :status, :integer
  end
end
