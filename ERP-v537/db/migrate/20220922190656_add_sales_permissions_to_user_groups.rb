class AddSalesPermissionsToUserGroups < ActiveRecord::Migration[6.1]
  def change
    rename_column :user_groups, :sales_view, :orders_view
    rename_column :user_groups, :sales_cru, :orders_cru
    add_column :user_groups, :sales_view, :boolean
    add_column :user_groups, :sales_cru, :boolean
  end
end
