class ExpenseSubcategory < ApplicationRecord
  belongs_to :expense_category, optional: true
  has_many :expense_payment_relations

  accepts_nested_attributes_for :expense_payment_relations, allow_destroy: true, reject_if: :all_blank
end
