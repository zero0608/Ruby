class AddIsCardToExpensePaymentmethod < ActiveRecord::Migration[6.1]
  def change
    add_column :expense_payment_methods, :company_card, :integer
  end
end
