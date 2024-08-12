class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      
      t.string :shopify_order_id
      t.string :contact_email
      t.string :currency
      t.string :current_subtotal_price
      t.string :current_total_discounts
      t.string :current_total_tax
      t.string :discount_codes, array: true, default: []
      t.string :financial_status
      t.string :fulfillment_status
      t.string :name
      

      t.timestamps
    end
  end
end
