class AddPalletIdToLineItem < ActiveRecord::Migration[6.1]
  def change
    add_reference :line_items, :pallet_shipping, foreign_key: true
  end
end
