class EditLocalDeliveryInShippingDetails < ActiveRecord::Migration[6.1]
  def change
    rename_column :shipping_details, :local_delivery, :local_pickup
  end
end
