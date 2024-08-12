class Purchase < ApplicationRecord
  belongs_to :supplier, optional: true
  belongs_to :order, optional: true
  has_many :purchase_items, dependent: :destroy
  has_many :purchase_cancelreqs, dependent: :destroy
  has_many :line_items, through: :purchase_items
  has_many :product_variants, through: :purchase_items
  has_many :products, through: :purchase_items
  has_many :orders, through: :purchase_items
  has_many :comments, as: :commentable

  scope :set_store, ->(store) { where(store: store) }

  accepts_nested_attributes_for :purchase_items, allow_destroy: true, reject_if: :all_blank

  has_associated_audits
end
