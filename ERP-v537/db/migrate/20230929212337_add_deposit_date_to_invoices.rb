class AddDepositDateToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :deposit_date, :date
    add_column :invoices, :additional_deposit_date, :date
    add_column :invoices, :no_sale_notes, :string
    change_column :invoices, :shipping_method, :string
  end
end
