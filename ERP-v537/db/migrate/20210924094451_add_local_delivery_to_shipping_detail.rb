class AddLocalDeliveryToShippingDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :local_delivery, :string
  end
end
