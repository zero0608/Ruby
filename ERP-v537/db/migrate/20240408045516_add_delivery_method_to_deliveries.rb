class AddDeliveryMethodToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :instock_warehouse_tables, :delivery_method, :string
    add_column :preorder_warehouse_tables, :delivery_method, :string
    add_column :preorder_from_another_warehouse_tables, :delivery_method, :string
    add_column :mto_warehouse_tables, :delivery_method, :string
    add_column :wgd_warehouse_tables, :delivery_method, :string
  end
end
