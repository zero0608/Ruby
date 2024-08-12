class Refund < ApplicationRecord
  belongs_to :order
  has_many :order_adjustments, dependent: :destroy
  has_many :order_transactions, dependent: :destroy
end
