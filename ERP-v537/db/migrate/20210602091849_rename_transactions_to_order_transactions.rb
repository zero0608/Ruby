class RenameTransactionsToOrderTransactions < ActiveRecord::Migration[6.1]
  def change
    rename_table :transactions, :order_transactions
  end
end
