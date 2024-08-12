class MarketProduct < ApplicationRecord
  belongs_to :order
  belongs_to :issue, optional: true
  belongs_to :line_item

  enum status: [ :pending, :sold ]
end