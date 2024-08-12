class CreatePalletShippings < ActiveRecord::Migration[6.1]
  def change
    create_table :pallet_shippings do |t|
      t.references :pallet, null: true, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.references :shipping_detail, null: false, foreign_key: true
      t.string :height
      t.string :depth
      t.string :weight
      t.string :width

      t.timestamps
    end
  end
end
