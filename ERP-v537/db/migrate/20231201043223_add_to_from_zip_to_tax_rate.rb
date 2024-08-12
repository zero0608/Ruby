class AddToFromZipToTaxRate < ActiveRecord::Migration[6.1]
  def change
    add_column :tax_rates, :to_zip_code, :integer
    add_column :tax_rates, :from_zip_code, :integer
  end
end
