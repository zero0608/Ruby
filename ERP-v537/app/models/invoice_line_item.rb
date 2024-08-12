class InvoiceLineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :product_variant, optional: true
end