class ExpensePaymentMethod < ApplicationRecord
  has_many :expense_payment_relations
end
