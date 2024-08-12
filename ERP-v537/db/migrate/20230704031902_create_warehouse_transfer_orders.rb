class CreateWarehouseTransferOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :warehouse_transfer_orders do |t|
      t.references :from_warehouse, null: true, foreign_key: {to_table: :warehouses}
      t.references :to_warehouse, null: true, foreign_key: {to_table: :warehouses}
      t.string :name
      t.integer :status
      t.date :etc_date
      t.string :customer_name
      t.string :from_store
      t.string :to_store

      t.timestamps
    end
  end
end
