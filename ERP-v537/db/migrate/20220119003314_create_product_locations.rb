class CreateProductLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :product_locations do |t|
      t.references :product_variant, null: false, foreign_key: true

      t.string :aisle
      t.string :rack
      t.string :bin
      t.string :quantity

      t.timestamps
    end
  end
end
