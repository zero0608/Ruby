class PalletShipping < ApplicationRecord
  belongs_to :order
  belongs_to :pallet, optional: true
  belongs_to :shipping_detail
  has_many :line_items

  enum pallet_type: [ :loose_box, :pallet]
end
