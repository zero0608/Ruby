class CreateShippingDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :shipping_details do |t|
      t.references :order, null: true, foreign_key: true
      t.references :carrier, null: true, foreign_key: true
      t.string :fuel_surcharge
      t.string :estimated_shipping_cost
      t.date :date_booked
      t.date :hold_until_date
      t.string :white_glove_delivery
      t.string :shipping_notes

      t.timestamps
    end
  end
end
