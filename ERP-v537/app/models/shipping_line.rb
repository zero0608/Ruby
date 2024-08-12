class ShippingLine < ApplicationRecord
  belongs_to :order

  audited associated_with: :order
  
  ShippingLine.non_audited_columns = %i[id order_id carrier_identifier code delivery_category discounted_price discount_price_set phone price_set requested_fulfillment_service_id source tax_lines dicount_allocations created_at updated_at]
end