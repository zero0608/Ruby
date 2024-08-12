class AddTrackingNumberToShippingDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :tracking_number, :string
  end
end
