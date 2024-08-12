class AddRemoteToShippingDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :remote, :string
    add_column :shipping_details, :overhang, :string
  end
end
