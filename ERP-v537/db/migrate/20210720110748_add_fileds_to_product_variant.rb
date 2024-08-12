class AddFiledsToProductVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :inventory_limit, :integer
    add_column :product_variants, :variant_fulfillable, :boolean
  end
end
