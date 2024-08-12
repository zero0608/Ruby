class Expense < ApplicationRecord
  belongs_to :employee
  belongs_to :approver, class_name: "Employee", optional: true
  belongs_to :expense_category, optional: true
  belongs_to :expense_subcategory, optional: true
  belongs_to :expense_type, optional: true
  belongs_to :expense_payment_method, optional: true

  has_one :expense_posting, dependent: :destroy

  scope :set_store, ->(store) { where(store: store) }

  has_many_attached :files
  
 audited
 has_associated_audits
end