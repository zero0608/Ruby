class CreateRefundLineItems < ActiveRecord::Migration[6.1]
  def change
    create_table :refund_line_items do |t|
      t.references :refund, null: false, foreign_key: true
      t.references :line_item, null: false, foreign_key: true
      t.string :location_id
      t.string :quantity
      t.string :restock_type
      t.string :subtotal
      t.json :subtotal_shop_money
      t.json :subtotal_presentment_money
      t.string :total_tax
      t.json :total_tax_shop_money
      t.json :total_tax_presentment_money
      t.json :line_item

      t.timestamps
    end
  end
end
