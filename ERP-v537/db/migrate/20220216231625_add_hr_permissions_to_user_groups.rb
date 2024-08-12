class AddHrPermissionsToUserGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :user_groups, :hr_view, :boolean, default: 'true'
    add_column :user_groups, :hr_cru, :boolean, default: 'true'
    add_column :user_groups, :manager_view, :boolean, default: 'true'
    add_column :user_groups, :manager_cru, :boolean, default: 'true'
  end
end
