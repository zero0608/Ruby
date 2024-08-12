class InventoryHistory < ApplicationRecord
  belongs_to :product_variant
  belongs_to :order, optional: true
  belongs_to :user, optional: true
  belongs_to :container, optional: true
end
