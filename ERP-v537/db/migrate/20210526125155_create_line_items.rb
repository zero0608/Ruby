class CreateLineItems < ActiveRecord::Migration[6.1]
  def change
    create_table :line_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :fulfillment, null: true, foreign_key: true
      t.references :product, null: true, foreign_key: true
      t.references :variant, null: true, foreign_key: { to_table: :product_variants }
      t.string :shopify_line_item_id
      t.string :fulfillable_quantity
      t.string :fulfillment_service
      t.string :fulfillment_status
      t.string :grams
      t.string :price
      t.string :quantity
      t.string :requires_shipping
      t.string :sku
      t.string :title
      t.string :variant_title
      t.string :vendor
      t.string :name
      t.string :gift_card
      t.json :price_set
      t.string :properties, array: true, default: []
      t.string :taxable
      t.string :tax_lines, array: true, default: []      
      t.string :total_discount
      t.json :total_discount_set
      t.json :origin_location
      t.string :admin_graphql_api_id


      t.timestamps
    end
  end
end
