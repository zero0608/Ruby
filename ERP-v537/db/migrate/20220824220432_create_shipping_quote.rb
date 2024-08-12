class CreateShippingQuote < ActiveRecord::Migration[6.1]
  def change
    create_table :shipping_quotes do |t|
      t.references :shipping_detail, foreign_key: true
      t.references :carrier, foreign_key: true
      t.string :name
      t.float :amount
      t.boolean :selected

      t.timestamps
    end
  end
end
