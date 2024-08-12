class AddCityToStoreAddresses < ActiveRecord::Migration[6.1]
  def change
    rename_column :store_addresses, :full_address, :address
    add_column :store_addresses, :city, :string
    add_column :store_addresses, :state, :string
    add_column :store_addresses, :zip, :string
  end
end
