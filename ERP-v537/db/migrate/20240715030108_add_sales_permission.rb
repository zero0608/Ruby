class AddSalesPermission < ActiveRecord::Migration[6.1]
  def change
    remove_column :employees, :sales_permission, :boolean
    add_column :employees, :sales_permission, :boolean
  end
end
