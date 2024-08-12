class ExpensePaymentRelation < ApplicationRecord
  belongs_to :expense_subcategory, optional: true
  belongs_to :expense_payment_method, optional: true
end