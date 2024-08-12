class CreateTaxRates < ActiveRecord::Migration[6.1]
  def change
    create_table :tax_rates do |t|
      t.string :state
      t.string :combined_rate

      t.timestamps
    end
  end
end
