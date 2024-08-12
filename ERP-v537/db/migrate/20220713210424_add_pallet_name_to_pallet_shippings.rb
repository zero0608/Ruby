class AddPalletNameToPalletShippings < ActiveRecord::Migration[6.1]
  def change
    add_column :pallet_shippings, :pallet_name, :integer
  end
end
