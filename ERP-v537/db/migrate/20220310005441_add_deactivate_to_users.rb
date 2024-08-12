class AddDeactivateToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :deactivate, :boolean
  end
end
