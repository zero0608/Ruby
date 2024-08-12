class AddLocalWhiteGloveDeliveryToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :local_white_glove_delivery, :float, default: 0
  end
end
