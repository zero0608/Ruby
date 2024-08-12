class CreateLocationHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :location_histories do |t|
      t.references :product_variant, null: false, foreign_key: true
      t.references :product_location, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.string :event
      t.integer :adjustment
      t.integer :quantity

      t.timestamps
    end
  end
end
