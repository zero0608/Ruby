class AddWarehouseIdToTaxRate < ActiveRecord::Migration[6.1]
  def change
    add_reference :tax_rates, :warehouse, foreign_key: true
  end
end
