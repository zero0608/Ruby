class RemoveQuoteGeneratedFromInvoices < ActiveRecord::Migration[6.1]
  def change
    remove_column :invoices, :invoice_generated, :boolean
  end
end
