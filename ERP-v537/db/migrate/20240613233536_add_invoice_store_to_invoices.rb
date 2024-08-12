class AddInvoiceStoreToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :store, :string
  end
end
