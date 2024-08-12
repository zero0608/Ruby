class RenamePalletNameToPalletType < ActiveRecord::Migration[6.1]
  def change
    rename_column :pallet_shippings, :pallet_name, :pallet_type
  end
end
