class AddEmailToShippingAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_addresses, :email, :string
    add_column :white_glove_addresses, :email, :string
  end
end
