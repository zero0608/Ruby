class CreateOrderAdjustments < ActiveRecord::Migration[6.1]
  def change
    create_table :order_adjustments do |t|
      t.references :order, null: false, foreign_key: true
      t.references :refund, null: false, foreign_key: true
      t.string :amount
      t.json :shop_money
      t.json :presentment_money
      t.string :kind
      t.string :reason
      t.string :tax_amount

      t.timestamps
    end
  end
end
