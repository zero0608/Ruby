class ShippingQuote < ApplicationRecord
  belongs_to :shipping_detail, optional: true
  belongs_to :truck_broker, optional: true
  belongs_to :carrier, optional: true
end