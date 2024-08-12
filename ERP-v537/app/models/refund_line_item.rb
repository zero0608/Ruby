class RefundLineItem < ApplicationRecord
  belongs_to :refund
  belongs_to :line_item
end
