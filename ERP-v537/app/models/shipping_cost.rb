class ShippingCost < ApplicationRecord
  belongs_to :shipping_detail, optional: true
end