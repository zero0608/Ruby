class ClaimsRefundItem < ApplicationRecord
  belongs_to :issue
  belongs_to :line_item, optional: true
end