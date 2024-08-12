class Consolidation < ApplicationRecord
  has_many :shipping_details
  
  has_many :posting_sections, dependent: :destroy
  has_many :review_sections, dependent: :destroy
  has_many :record_sections, dependent: :destroy
  
  has_one :invoice_for_billing, dependent: :destroy
  has_one :invoice_for_wgd, dependent: :destroy

  has_many :comments, as: :commentable

  audited
  has_associated_audits
end