class CreateRemoteShippingRates < ActiveRecord::Migration[6.1]
  def change
    create_table :remote_shipping_rates do |t|
      t.integer :order_min_price
      t.integer :order_max_price
      t.integer :discount
      t.string :shipping_method
      t.string :store

      t.timestamps
    end
  end
end
