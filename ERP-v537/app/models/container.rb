# frozen_string_literal: true

class Container < ApplicationRecord
  belongs_to :supplier, optional: true
  belongs_to :ocean_carrier, optional: true
  belongs_to :container_posting, optional: true
  belongs_to :container_record, optional: true
  belongs_to :warehouse, optional: true
  has_many :container_purchases, dependent: :destroy
  has_many :container_costs, dependent: :destroy
  has_many :container_charges, dependent: :destroy
  has_many :purchase_items, through: :container_purchases
  has_many :line_items, dependent: :destroy
  has_many :comments, as: :commentable

  accepts_nested_attributes_for :container_purchases, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :container_costs, allow_destroy: true
  accepts_nested_attributes_for :container_charges, allow_destroy: true

  enum status: { arrived: 0, en_route: 1, container_ready: 2 }, _default: :container_ready

  audited
  has_associated_audits
  Container.non_audited_columns = %i[id supplier_id container_number shipping_date port_eta arriving_to_dc
                                     created_at updated_at store ocean_carrier freight_carrier carrier_serial_number container_comment received_date ocean_carrier_id warehouse_id]

  def count_container_cost
    self.purchase_items.each do |item|
      item.update_item_cbm
      item.update(container_cost: cost_of_each_sku(item))
    end
  end

  def cost_of_each_sku(item)
    if item.product_variant.product.present?
      ((item.item_cbm.to_f)/self.purchase_items.pluck(:item_cbm).reject(&:blank?).map(&:to_f).sum) * (self.container_charges.sum(:quote))
    elsif item.product.present?
      ((item.item_cbm.to_f)/self.purchase_items.pluck(:item_cbm).reject(&:blank?).map(&:to_f).sum) * (self.container_charges.sum(:quote))
    end
  end

end
