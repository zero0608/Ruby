class CreateShippingCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :shipping_costs do |t|
      t.references :shipping_detail, null: false, foreign_key: true
      t.string :cost_type
      t.string :name
      t.float :amount

      t.timestamps
    end
  end
end
