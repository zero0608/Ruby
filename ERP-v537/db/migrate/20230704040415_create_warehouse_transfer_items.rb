class CreateWarehouseTransferItems < ActiveRecord::Migration[6.1]
  def change
    create_table :warehouse_transfer_items do |t|
      t.references :product_variant, null: true, foreign_key: true
      t.references :warehouse_variant, null: true, foreign_key: true
      t.string :quantity

      t.timestamps
    end
  end
end
