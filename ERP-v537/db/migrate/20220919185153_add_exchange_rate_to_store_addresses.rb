class AddExchangeRateToStoreAddresses < ActiveRecord::Migration[6.1]
  def change
    add_column :store_addresses, :exchange_rate, :float
  end
end
