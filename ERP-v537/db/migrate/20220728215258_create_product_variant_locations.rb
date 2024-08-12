class CreateProductVariantLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :product_variant_locations do |t|
      t.references :product_variant, null: true, foreign_key: true
      t.references :product_location, null: true, foreign_key: true
      t.integer :product_quantity

      t.timestamps
    end
  end
end
