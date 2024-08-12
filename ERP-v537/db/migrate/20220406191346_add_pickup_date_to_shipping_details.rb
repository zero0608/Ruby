class AddPickupDateToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :pickup_start_date, :date
    add_column :shipping_details, :pickup_end_date, :date
    add_column :shipping_details, :pickup_start_time, :time
    add_column :shipping_details, :pickup_end_time, :time
    add_column :shipping_details, :delivery_start_date, :date
    add_column :shipping_details, :delivery_end_date, :date
    add_column :shipping_details, :delivery_start_time, :time
    add_column :shipping_details, :delivery_end_time, :time
  end
end
