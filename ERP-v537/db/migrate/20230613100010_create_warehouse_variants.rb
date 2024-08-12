class CreateWarehouseVariants < ActiveRecord::Migration[6.1]
  def change
    create_table :warehouse_variants do |t|
      t.references :product_variant, foreign_key: true
      t.references :product_variant_location, foreign_key: true
      t.references :warehouse, foreign_key: true
      t.string :warehouse_quantity
      t.string :store

      t.timestamps
    end
  end
end
