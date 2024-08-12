class AddSoldValueToMarketProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :market_products, :sold_value, :float
    add_column :market_products, :sold_date, :date
    add_column :market_products, :notes, :string
  end
end
