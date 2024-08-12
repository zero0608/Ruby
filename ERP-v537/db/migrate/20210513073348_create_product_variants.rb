class CreateProductVariants < ActiveRecord::Migration[6.1]
  def change
    create_table :product_variants do |t|
      t.string :shopify_variant_id
      t.string :title
      t.string :price
      t.string :sku
      t.integer :position
      t.string :inventory_policy
      t.string :compare_at_price
      t.string :fulfillment_service
      t.string :inventory_management
      t.string :option1
      t.string :option2
      t.string :option3
      t.string :taxable
      t.string :barcode
      t.string :grams
      t.string :weight
      t.string :weight_unit
      t.string :inventory_item_id
      t.integer :inventory_quantity
      t.integer :old_inventory_quantity
      t.string :requires_shipping
      t.string :admin_graphql_api_id
      t.references :product, null: false, foreign_key: true
      t.string :image_id

      t.timestamps
    end
  end
end
