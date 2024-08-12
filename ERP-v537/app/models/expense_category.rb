class ExpenseCategory < ApplicationRecord
  belongs_to :expense_type, optional: true
  has_many :expense_subcategories, dependent: :destroy

  accepts_nested_attributes_for :expense_subcategories, allow_destroy: true, reject_if: :all_blank
end
