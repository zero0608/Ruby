class CreateInventoryHistory < ActiveRecord::Migration[6.1]
  def change
    create_table :inventory_histories do |t|
      t.references :product_variant, null: false, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.references :container, null: true, foreign_key: true

      t.string :event
      t.integer :adjustment
      t.integer :quantity

      t.timestamps
    end
  end
end
