class AddTotalInvoiceAmountToExpenses < ActiveRecord::Migration[6.1]
  def change
    remove_column :expenses, :tax, :float
    add_column :expenses, :total_invoice_amount, :float
  end
end
