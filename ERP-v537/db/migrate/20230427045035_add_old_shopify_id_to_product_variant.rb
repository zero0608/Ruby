class AddOldShopifyIdToProductVariant < ActiveRecord::Migration[6.1]
  def change
    add_column :product_variants, :old_shopify_variant_id, :string
  end
end
