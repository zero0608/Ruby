class InvoiceForBilling < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :shipping_detail, optional: true
  belongs_to :return, optional: true
  belongs_to :consolidation, optional: true
  has_many_attached :files

  ALLOWED_CONTENT_TYPES = %w[image/png image/jpg image/jpeg application/pdf].freeze
  validates :files, content_type: { in: ALLOWED_CONTENT_TYPES, message: 'of attached files is not valid' },
  size: { less_than: 10.megabytes , message: 'Size should be less than a 10MB' }
end