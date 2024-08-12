class CreateShippingLines < ActiveRecord::Migration[6.1]
  def change
    create_table :shipping_lines do |t|
      t.references :order, null: false, foreign_key: true
      t.string :carrier_identifier
      t.string :code
      t.string :delivery_category
      t.string :discounted_price
      t.json :discount_price_set     
      t.string :phone
      t.string :price
      t.json :price_set
      t.string :requested_fulfillment_service_id
      t.string :source
      t.string :title
      t.string :tax_lines, array: true, default: []
      t.string :discount_allocations, array: true, default: []


      t.timestamps
    end
  end
end