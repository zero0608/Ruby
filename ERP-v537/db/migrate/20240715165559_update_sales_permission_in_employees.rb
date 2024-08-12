class UpdateSalesPermissionInEmployees < ActiveRecord::Migration[6.1]
  def change
    remove_column :employees, :sales_manager_permission, :boolean
    remove_column :employees, :sales_permission, :boolean
    add_column :employees, :sales_permission, :integer
  end
end