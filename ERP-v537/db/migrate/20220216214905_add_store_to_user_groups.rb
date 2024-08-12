class AddStoreToUserGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :user_groups, :store, :string
  end
end
