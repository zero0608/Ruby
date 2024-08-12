class OrderTransaction < ApplicationRecord
  belongs_to :order
  belongs_to :refund, optional: true
end