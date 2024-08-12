class CreatePallets < ActiveRecord::Migration[6.1]
  def change
    create_table :pallets do |t|
      t.string :pallet_size
      t.string :pallet_height
      t.string :pallet_width
      t.string :pallet_length
      t.string :pallet_weight
      t.string :slug

      t.timestamps
    end
  end
end
