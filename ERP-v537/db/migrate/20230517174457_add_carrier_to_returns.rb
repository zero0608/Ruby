class AddCarrierToReturns < ActiveRecord::Migration[6.1]
  def change
    add_column :returns, :shipping_carrier, :string
    add_column :returns, :shipping_cost, :float
  end
end
