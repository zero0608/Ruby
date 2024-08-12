class RemoveTotalInvoiceAmountFromExpenses < ActiveRecord::Migration[6.1]
  def change
    remove_column :expenses, :total_invoice_amount, :float
    add_column :expenses, :tips, :float
  end
end