class ExpenseRecord < ApplicationRecord
  belongs_to :expense, optional: true
end
