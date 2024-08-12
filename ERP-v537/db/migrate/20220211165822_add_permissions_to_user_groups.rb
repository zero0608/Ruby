class AddPermissionsToUserGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :user_groups, :overview_view, :boolean, default: 'true'
    add_column :user_groups, :overview_cru, :boolean, default: 'true'
    add_column :user_groups, :sales_view, :boolean, default: 'true'
    add_column :user_groups, :sales_cru, :boolean, default: 'true'
    add_column :user_groups, :inventory_view, :boolean, default: 'true'
    add_column :user_groups, :inventory_cru, :boolean, default: 'true'
    add_column :user_groups, :dc_view, :boolean, default: 'true'
    add_column :user_groups, :dc_cru, :boolean, default: 'true'
    add_column :user_groups, :issues_view, :boolean, default: 'true'
    add_column :user_groups, :issues_cru, :boolean, default: 'true'
    add_column :user_groups, :admin_view, :boolean, default: 'true'
    add_column :user_groups, :admin_cru, :boolean, default: 'true'
  end
end
