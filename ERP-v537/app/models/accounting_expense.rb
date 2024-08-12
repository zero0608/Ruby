class AccountingExpense < ApplicationRecord
  belongs_to :expense_category, optional: true
  belongs_to :expense_subcategory, optional: true
  belongs_to :expense_type, optional: true

  scope :set_store, ->(store) { where(store: store) }
end
