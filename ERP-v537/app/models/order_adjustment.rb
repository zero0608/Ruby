class OrderAdjustment < ApplicationRecord
  belongs_to :order
  belongs_to :refund
end
