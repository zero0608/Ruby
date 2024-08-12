class PurchaseItem < ApplicationRecord
  belongs_to :line_item, optional: true
  belongs_to :purchase, optional: true
  belongs_to :order, optional: true
  belongs_to :product_variant, optional: true
  belongs_to :product, optional: true
  belongs_to :warehouse, optional: true

  has_many :container_purchases, dependent: :destroy
  has_many :containers, through: :container_purchases
  has_many :purchase_cancelreqs, dependent: :destroy

  enum status: [ :in_production, :container_ready, :not_started, :completed, :cancelled ], _default: :not_started

  audited allow_mass_assignment: true, associated_with: :purchase

  PurchaseItem.non_audited_columns = [:id, :product_id, :created_at, :updated_at, :etc_date, :comment_description]

  after_create do
    update_item_cbm
  end

  def update_item_cbm
    self.update(item_cbm: (self.product.carton_details.pluck(:cubic_meter).reject(&:blank?).map(&:to_f).sum * self.quantity)) if self.product.present? && self.product.carton_details.present?
  end

end
