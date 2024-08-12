# frozen_string_literal: true

class Order < ApplicationRecord
  include PgSearch::Model
  extend FriendlyId
  friendly_id :name
  validates :name, uniqueness: true

  belongs_to :customer, optional: true
  has_many :posting_sections
  has_many :review_sections
  has_many :record_sections

  has_one :billing_address, dependent: :destroy
  has_one :shipping_address, dependent: :destroy
  has_one :shipping_line, dependent: :destroy

  has_many :comments, as: :commentable
  has_many :refunds, dependent: :destroy
  has_many :fulfillments, dependent: :destroy
  has_many :line_items, dependent: :destroy
  has_many :shipping_details,  dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :order_transactions, dependent: :destroy
  has_many :order_adjustments, dependent: :destroy
  has_many :purchase_items, dependent: :destroy
  has_many :purchases, through: :purchase_items
  has_one :invoice_for_billing, dependent: :destroy
  has_one :invoice_for_wgd, dependent: :destroy

  has_many :pallet_shippings, dependent: :destroy

  has_many :returns, dependent: :destroy

  has_many :order_replacements, dependent: :destroy

  belongs_to :employee, optional: true

  has_one :invoice, dependent: :nullify

  accepts_nested_attributes_for :shipping_details, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :shipping_address

  scope :set_store, ->(store) { where(store: store) }

  enum status: { new_order: 0, in_progress: 1, cancel_confirmed: 2, delayed: 3, hold_confirmed: 4, completed: 5, cancel_request: 6, rejected: 7, hold_request: 8, pending_payment: 9 },
       _default: :new_order

  enum status_for_M2: { preparing: 0, in_production: 1, en_route: 2, PSR: 3 }

  enum status_for_shipping: { review: 0, approval: 1, posting: 2, record: 3 }


  pg_search_scope :search,
                  against: [:name],
                  associated_against: {
                    customer: [:first_name]
                  },
                  using: {
                    tsearch: {
                      prefix: true
                    }
                  }

  audited
  has_associated_audits
  Order.non_audited_columns = %i[id order_type hold_until_date customer_id updated_at created_at order_link shopify_order_id current_subtotal_price current_total_discounts current_total_tax discount_codes financial_status fulfillment_status store name currency contact_email tags tax_lines cancel_request_date cancelled_date cancel_reason hold_reason eta eta_data_from eta_data_to sent_mail kind_of_order line_items shipping_details]

  def update_order_status
    shipping_details.update_all(status: 'staging')
  end
  
  def attentive_status
    case self.try(:status)
      when "in_progress"
        if self.shipping_details.first.status == "ready_to_ship"
          "Ready to Ship"

        elsif self.shipping_details.first.status == "ready_for_pickup"
          "Ready for Pickup"

        end
      when "completed"
        "Shipped"
    end
  end

  def order_status
    if shipping_details.pluck(:status).uniq.size == 1
      shipping_details.first.status

    elsif shipping_details.pluck(:status).uniq.size > 1 && shipping_details.pluck(:status).any? { |status| status == "ready" }
      "partial_shipped"
    
    else
      "split_shipping"
    end
  end

  def total_amount
    self.line_items.where(order_from: nil).sum { |item| ((item&.price.to_f * item&.quantity.to_i) unless (item&.sku&.include?("mulberry") || item&.title&.include?("Mulberry") || item&.sku&.include?("custom") || ShipmentCode.pluck(:sku_for_discount)&.include?(item.sku))).to_f } - (self.discount_codes["discount_amount"].to_f.abs if self.discount_codes.present?).to_f + self&.shipping_line&.price.to_f + (self.line_items.sum { |item| ((item&.price.to_f * item&.quantity.to_i) if ShipmentCode.pluck(:sku_for_discount)&.include? item.sku).to_f }).to_f + (self.tax_lines["price"].to_f if self.tax_lines.present?).to_f + (self.refunds.sum { |re| self.order_adjustments.sum { |adj| adj.amount.to_f } } if self.refunds.present? && self.order_adjustments.present?).to_f
  end

  def send_status_to_m2_qs(status)
    return unless (((Date.today - 1)..Date.today).cover? created_at.to_date) && sent_mail != 0
    if status == "completed" && (sent_mail != 4)
      if shipping_line&.title&.downcase&.include? "white glove"
        comments.create(description: 'Email: complete_wgd ', commentable_type: 'Order')
        shipping_details.each {|ship| Magento::UpdateOrder.new(self.store).create_shipment(self,ship) }
        "complete_wgd"
      elsif shipping_line&.title&.downcase&.include? "curbside"
        comments.create(description: 'Email: complete_curbside ', commentable_type: 'Order')
        shipping_details.each {|ship| Magento::UpdateOrder.new(self.store).create_shipment(self,ship) }
        "complete_curbside"
      end
      update(sent_mail: 4)
    elsif status == "cancel_confirmed"
      comments.create(description: 'Email: canceled_cancelled ', commentable_type: 'Order')
      "canceled_cancelled"
    else
      status = 'processing_preparing'
      update(sent_mail: 0)
      comments.create(description: 'Email: processing_preparing ', commentable_type: 'Order')
      # Magento::UpdateOrder.new(self.store).update_status_for_M2(self.shopify_order_id, status)
      status
    end
  end

  def send_status_to_m2_mto(status)
    return if %w[cancel_request hold_request].include? status
    if (created_at.to_date == (Date.today - 6.days).to_date) && (shipping_details.all? do |item|
                                                                   item.status == 'not_ready'
                                                                 end)
      if (line_items.pluck(:status) & %w[not_started in_production container_ready]).none? && sent_mail != 2
        if (line_items.pluck(:status).include? 'en_route') && !(shipping_details.pluck(:status).include? 'shipped')
          status = 'processing_enroute'
          update(sent_mail: 2)
          comments.create(description: 'Email: processing_enroute ', commentable_type: 'Order')
          # Magento::UpdateOrder.new(self.store).update_status_for_M2(self.shopify_order_id, status)
          status
        end
      elsif !(line_items.pluck(:status).include? 'cancelled') && sent_mail != 1 && !(shipping_details.pluck(:status).include? 'shipped')
        status = 'processing_inproduction'
        update(sent_mail: 1)
        comments.create(description: 'Email: processing_inproduction ', commentable_type: 'Order')
        # Magento::UpdateOrder.new(self.store).update_status_for_M2(self.shopify_order_id, status)
        status
      end
    elsif (shipping_details.all? do |item|
             item.status == 'staging'
           end) && (sent_mail != 3) && !(shipping_details.pluck(:status).include? 'shipped')
      status = 'processing_psr'
      update(sent_mail: 3)
      comments.create(description: 'Email: processing_psr ', commentable_type: 'Order')
      # Magento::UpdateOrder.new(self.store).update_status_for_M2(self.shopify_order_id, status)
      status
    elsif (line_items.pluck(:status) & %w[not_started in_production container_ready]).none?
      if (line_items.pluck(:status).include? 'en_route') && sent_mail != 2 && !(shipping_details.pluck(:status).include? 'shipped')
        status = 'processing_enroute'
        update(sent_mail: 2)
        comments.create(description: 'Email: processing_enroute ', commentable_type: 'Order', user_id: 1)
        # Magento::UpdateOrder.new(self.store).update_status_for_M2(self.shopify_order_id, status)
        status
      end
    elsif %[hold_confirmed pending_payment].include? status
      comments.create(description: 'Email: processing_psr ', commentable_type: 'Order')
      status
    elsif status == "completed" && (sent_mail != 4)
      if shipping_line&.title&.downcase&.include? "white glove"
        comments.create(description: 'Email: complete_wgd ', commentable_type: 'Order')
        shipping_details.each {|ship| Magento::UpdateOrder.new(self.store).create_shipment(self,ship) }
        "complete_wgd"
      elsif shipping_line&.title&.downcase&.include? "curbside"
        comments.create(description: 'Email: complete_curbside ', commentable_type: 'Order')
        shipping_details.each {|ship| Magento::UpdateOrder.new(self.store).create_shipment(self,ship) }
        "complete_curbside"
      end
      update(sent_mail: 4)
    elsif status == "cancel_confirmed"
      comments.create(description: 'Email: canceled_cancelled ', commentable_type: 'Order')
      "canceled_cancelled"
    end
  end
end
