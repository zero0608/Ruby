class AddStoreToTaxRates < ActiveRecord::Migration[6.1]
  def change
    add_column :tax_rates, :store, :string
  end
end
