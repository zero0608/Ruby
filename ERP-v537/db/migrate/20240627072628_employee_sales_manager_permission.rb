class EmployeeSalesManagerPermission < ActiveRecord::Migration[6.1]
  def change
    # remove_column :employees, :sales_manager_permission, :boolean
    add_column :employees, :sales_manager_permission, :boolean
  end
end
