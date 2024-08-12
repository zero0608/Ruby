class Employee < ApplicationRecord
  belongs_to :department
  belongs_to :position
  belongs_to :manager, class_name: "Employee", optional: true
  has_many :associates, class_name: "Employee", foreign_key: "manager_id", dependent: :nullify
  has_many :checklists, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :leaves, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :approved_expenses, class_name: "Expense", foreign_key: "approver_id", dependent: :destroy

  has_many :customers, dependent: :nullify
  has_many :invoices, dependent: :nullify
  has_many :orders, dependent: :nullify
  
  has_many :commission_rates, dependent: :destroy
  
  belongs_to :showroom, optional: true
  has_many :appointments, dependent: :nullify
  has_many :showroom_manage_permissions, dependent: :destroy
  
  has_many_attached :documents
  
  accepts_nested_attributes_for :checklists, allow_destroy: true
  accepts_nested_attributes_for :showroom_manage_permissions

  enum sales_permission: [ :sales, :manager ]

  ALLOWED_CONTENT_TYPES = %w[application/pdf].freeze
  validates :documents, content_type: { in: ALLOWED_CONTENT_TYPES, message: 'of attached files is not valid' },
  size: { less_than: 10.megabytes , message: 'Size should be less than a 10MB' }

  def full_name
    if first_name.present? && last_name.present?
      first_name + ' ' + last_name
    end
  end
end