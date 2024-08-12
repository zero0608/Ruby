class AddTaxToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoice_for_billings, :tax, :float
    add_column :invoice_for_billings, :qst, :float
    add_column :invoice_for_wgds, :tax, :float
    add_column :invoice_for_wgds, :qst, :float
  end
end
