class CreateWarehouseAndTaxRates < ActiveRecord::Migration[6.1]
  def change
    create_table :warehouse_and_tax_rates do |t|
      t.references :warehouse, null: true, foreign_key: true
      t.references :tax_rate, null: true, foreign_key: true
      t.string :terminal


      t.timestamps
    end
  end
end
