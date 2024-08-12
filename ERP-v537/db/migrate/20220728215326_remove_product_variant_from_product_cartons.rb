class RemoveProductVariantFromProductCartons < ActiveRecord::Migration[6.1]
  def change
    remove_column :product_locations, :product_variant_id, :bigint
    remove_column :product_locations, :quantity, :string
  end
end
