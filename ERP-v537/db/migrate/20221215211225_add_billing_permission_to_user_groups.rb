class AddBillingPermissionToUserGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :user_groups, :billing_view, :boolean
    add_column :user_groups, :billing_cru, :boolean
  end
end
