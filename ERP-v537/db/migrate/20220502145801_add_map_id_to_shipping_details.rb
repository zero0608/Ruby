class AddMapIdToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :map_id, :string
  end
end
