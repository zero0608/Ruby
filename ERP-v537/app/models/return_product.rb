class ReturnProduct < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :issue, optional: true
  belongs_to :line_item, optional: true
  belongs_to :product_variant, optional: true

  enum status: [ :pending, :restock, :overstock ]
end