class RemoveColumnOverhangFromPalletShippings < ActiveRecord::Migration[6.1]
  def change
    remove_column :pallet_shippings, :overhang, :boolean
  end
end
