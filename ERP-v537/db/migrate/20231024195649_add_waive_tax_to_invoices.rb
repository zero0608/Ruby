class AddWaiveTaxToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :waive_tax, :boolean, default: false
  end
end
