class AddDepositToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :deposit, :float
    add_column :invoices, :additional_payment_method, :integer
    add_column :invoices, :additional_deposit, :float
    add_column :invoices, :additional_notes, :string
  end
end
