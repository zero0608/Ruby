class Return < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :issue, optional: true
  belongs_to :carrier, optional: true
  
  has_many :posting_sections
  has_many :review_sections
  has_many :record_sections
  
  has_one :invoice_for_billing, dependent: :destroy
  has_one :invoice_for_wgd, dependent: :destroy
  
  belongs_to :white_glove_directory, optional: true
  belongs_to :white_glove_address, optional: true

  has_many :return_line_items, dependent: :destroy

  has_many :comments, as: :commentable

  has_many_attached :files

  ALLOWED_CONTENT_TYPES = %w[application/pdf].freeze
  validates :files, content_type: { in: ALLOWED_CONTENT_TYPES, message: 'of attached files is not valid' }, size: { less_than: 10.megabytes , message: 'Size should be less than 10MB' }

  audited
  has_associated_audits
  Return.non_audited_columns = %i[customer_return disposal return_reason return_date return_carrier return_number return_quote return_company return_contact return_address return_city return_state return_country return_zip_code order_id issue_id carrier_id white_glove_id shipping_cost created_at updated_at]

  enum status: { pending: 0, complete: 1, cancelled: 2 }
end