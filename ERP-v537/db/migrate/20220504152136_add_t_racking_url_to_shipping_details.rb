class AddTRackingUrlToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :tracking_url_for_ship, :string
  end
end
