class ChangeCartonLocations < ActiveRecord::Migration[6.1]
  def change
    remove_column :cartons, :product_id, :bigint
    add_reference :cartons, :product_variant, foreign_key: true
    remove_column :carton_locations, :product_variant_id, :bigint
    remove_column :carton_locations, :product_variant_location_id, :bigint
    add_reference :carton_locations, :product_location, foreign_key: true
  end
end
