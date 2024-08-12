class PurchaseCancelreq < ApplicationRecord
  belongs_to :purchase
  belongs_to :purchase_item

  enum status: [ :ongoing, :completed, :rejected ], _default: :ongoing

  audited associated_with: :purchase
end
