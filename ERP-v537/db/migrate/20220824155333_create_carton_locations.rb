class CreateCartonLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :carton_locations do |t|
      t.references :product_variant, null: true, foreign_key: true
      t.references :carton, null: true, foreign_key: true
      t.references :product_variant_location, null: true, foreign_key: true
      t.integer :quantity


      t.timestamps
    end
  end
end
