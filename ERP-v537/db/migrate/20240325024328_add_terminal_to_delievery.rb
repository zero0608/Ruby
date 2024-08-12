class AddTerminalToDelievery < ActiveRecord::Migration[6.1]
  def change
    add_column :instock_warehouse_tables, :terminal, :string
    add_column :preorder_warehouse_tables, :terminal, :string
    add_column :preorder_from_another_warehouse_tables, :terminal, :string
    add_column :mto_warehouse_tables, :terminal, :string
    add_column :wgd_warehouse_tables, :terminal, :string
  end
end
