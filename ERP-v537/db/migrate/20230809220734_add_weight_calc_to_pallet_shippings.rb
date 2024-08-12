class AddWeightCalcToPalletShippings < ActiveRecord::Migration[6.1]
  def change
    add_column :pallet_shippings, :auto_calc, :boolean, default: true
  end
end
