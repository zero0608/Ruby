class ExpenseType < ApplicationRecord
  has_many :expense_categories, dependent: :destroy

  accepts_nested_attributes_for :expense_categories, allow_destroy: true, reject_if: :all_blank
end
