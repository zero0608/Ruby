class ExpensePosting < ApplicationRecord
  belongs_to :expense, optional: true

  enum status: { posting: 0, record: 1 }
  
  audited associated_with: :expense
end
