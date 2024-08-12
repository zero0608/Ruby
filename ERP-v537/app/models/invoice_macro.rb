class InvoiceMacro < ApplicationRecord
  has_many :invoices, dependent: :nullify
end