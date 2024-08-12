class AddShippingAmount2Invoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :shipping_amount, :float
    remove_column :user_groups, :sales_view, :boolean
    remove_column :user_groups, :sales_cru, :boolean
    add_column :employees, :sales_manager_permission, :boolean
  end
end
