class AddDeactivateToExpensePaymentMethods < ActiveRecord::Migration[6.1]
  def change
    add_column :expense_payment_methods, :deactivate, :boolean, default: "false"
  end
end
