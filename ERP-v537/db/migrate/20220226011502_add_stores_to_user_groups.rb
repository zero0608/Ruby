class AddStoresToUserGroups < ActiveRecord::Migration[6.1]
  def change
    remove_column :user_groups, :store, :string
    add_column :user_groups, :permission_us, :boolean
    add_column :user_groups, :permission_ca, :boolean
  end
end
