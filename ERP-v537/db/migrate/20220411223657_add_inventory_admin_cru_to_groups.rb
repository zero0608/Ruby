class AddInventoryAdminCruToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :user_groups, :inventory_admin_cru, :boolean, default: "true"
  end
end