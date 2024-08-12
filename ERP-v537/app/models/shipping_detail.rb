class ShippingDetail < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :carrier, optional: true
  has_many :posting_sections, dependent: :destroy
  has_many :review_sections, dependent: :destroy
  has_many :record_sections, dependent: :destroy
  
  belongs_to :consolidation, optional: true

  has_many :line_items
  has_many :pallet_shippings, dependent: :destroy
  has_many :shipping_costs, dependent: :destroy
  has_many :shipping_quotes, dependent: :destroy
  
  belongs_to :white_glove_directory, optional: true
  belongs_to :white_glove_address, optional: true

  has_one :invoice_for_billing, dependent: :nullify
  has_one :invoice_for_wgd, dependent: :nullify

  has_many_attached :files

  ALLOWED_CONTENT_TYPES = %w[application/pdf].freeze
  validates :files, content_type: { in: ALLOWED_CONTENT_TYPES, message: 'of attached files is not valid' },
  size: { less_than: 10.megabytes , message: 'Size should be less than 10MB' }

  accepts_nested_attributes_for :pallet_shippings, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :white_glove_address, :reject_if => proc { |attr| attr[:contact].blank? && attr[:company].blank? && attr[:address1].blank? && attr[:address2].blank? && attr[:city].blank? && attr[:country].blank? && attr[:zip].blank? && attr[:phone].blank? && attr[:email].blank? && attr[:notes].blank? }
  accepts_nested_attributes_for :shipping_costs
  accepts_nested_attributes_for :shipping_quotes

  enum status: [:not_ready, :staging, :ready_to_ship, :booked, :ready_for_pickup, :shipped, :unbooked, :cancelled, :hold, :closed], _default: :not_ready

  enum upgrade: [ :not_started, :pending, :accepted, :declined ], _default: :not_started

  enum status_for_shipping: { review: 0, approval: 1, posting: 2, record: 3 }

  audited associated_with: :order

  ShippingDetail.non_audited_columns = [ :id, :order_id, :carrier_id, :estimated_shipping_cost, :date_booked, :hold_until_date, :white_glove_delivery, :shipping_notes, :created_at, :updated_at, :name, :local_delivery, :printed_bol, :printed_packing_slip, :tracking_number, :actual_invoiced, :white_glove_fee, :local_white_glove_delivery, :additional_charges, :additional_fees, :upgrade ]
end