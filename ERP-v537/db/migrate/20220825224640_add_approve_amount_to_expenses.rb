class AddApproveAmountToExpenses < ActiveRecord::Migration[6.1]
  def change
    add_column :expenses, :approve_amount, :float
  end
end
