class Issue < ApplicationRecord
  belongs_to :order
  belongs_to :user, optional: true
  belongs_to :line_item, optional: true
  belongs_to :carrier, optional: true
  belongs_to :supplier, optional: true
  belongs_to :factory, optional: true

  has_many :return_products
  has_many :market_products

  has_many :returns, dependent: :destroy
  
  has_many :claims_refund_items, dependent: :destroy
  has_many :repair_services, dependent: :destroy
  has_many :issue_details, dependent: :destroy
  has_many :comments, as: :commentable
  has_many_attached :images

  accepts_nested_attributes_for :claims_refund_items
  accepts_nested_attributes_for :issue_details

  validate :validate_quantity

  def validate_quantity
    if return_quantity.present? && return_quantity > line_item.quantity.to_i
        errors.add(:return_quantity, 'Return QTY can not be greater than Quantity')
    end
  end

  ALLOWED_CONTENT_TYPES = %w[image/png image/jpg image/jpeg application/pdf].freeze

  validates :images, content_type: { in: ALLOWED_CONTENT_TYPES, message: 'of attached files is not valid' },
  size: { less_than: 10.megabytes , message: 'Size should be less than a 10MB' }

  enum issue_type: [ :returns, :product_claims, :shipping_claims, :chargeback ]

  enum status: [ :new_claim, :in_review, :closed, :assigned ]

  enum card: [ "Visa", "Mastercard", "AMEX", "Paypal", "Affirm" ]

  enum chargeback: [ "Product Not Received", "Product Unacceptable / Not as Described", "Fraudulent", "Credit Not Processed", "Duplicate", "inquiry" ]
  
  enum dispute: [ "Dispute - Lost", "Dispute - Won", "Dispute in Progress" ]

  enum resolution_type: [ "Replacement Part", "Repair/Service", "Full Refund", "Partial Refund", "Warranty", "Store Credit"]

  enum repair_service: ["Amazon Repair Kit", "Home Depot Repair Kit", "FSN Pro", "Task Rabbit", "Deliveright"]

  enum return_reason: ["Sizing does not work in my space", "The color is not what I want", "I don't like the looks of it", "It is not comfortable", "Timing Delay", "Damage/Defect", "Others"]

  enum claim_type: [:factory_defect, :packaging, :dye_lot, :fabric_issue, :production_error, :internal_error, :factory_mislabel, :shipping_lost, :shipping_damage]

  enum shipping_claim_type: [:damage, :loss, :shipping_delays]

  enum replacement_type: ["Factory Invoice", "EM Invoice"]

  audited
  has_associated_audits
  Issue.non_audited_columns = %i[id ticket title description created_by assign_to order_id user_id created_at updated_at line_item_id shipping_charges shipping_amount resolution_amount return_quantity carrier_id supplier_id order_link bill_of_lading claims_submission_date claims_reference pickup_date last_scanned_date assign_product claims_dispute dispute_amount invoice_pay dispute_type factory_id chargeback_id chargeback_reason win_likelihood chargeback_dispute outcome_notes discount_amount warranty_amount gorgias_ticket claim_type shipping_invoice chargback_date card_type restocking_fee repacking_fee]
end