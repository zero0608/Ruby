class Invoice < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :order, optional: true
  has_many :invoice_line_items, dependent: :destroy

  belongs_to :employee, optional: true

  belongs_to :invoice_macro, optional: true

  enum status: [ :new_lead, :quote_offered, :deposit, :full_payment, :no_sale ]

  enum payment_method: [ "Credit Card", "Cash", "Trade Cheque", "Credit Card Deposit", "Cash Deposit", "Trade Cheque Deposit", "Stripe Payment Link" ]

  enum additional_payment_method: [ "Credit Card Balance", "Cash Balance", "Cheque Balance", "Wire Balance" ]

  enum source: [ :showroom, :trade, :warehouse_sale, :proactive_sale ]

  accepts_nested_attributes_for :invoice_line_items

  audited associated_with: :order
  Invoice.non_audited_columns = [:id, :order_id, :invoice_number, :status, :notes, :discount, :discount_amount, :tax_amount, :shipping_method, :created_at, :updated_at, :employee_id, :shipping_type, :order_name, :customer_id, :source, :invoice_generate, :payment_method, :deposit]

  def full_amount
    subtotal = self.invoice_line_items.sum { |li| li.price.present? ? (li&.quantity.to_i * li&.price.to_f) : (li&.quantity.to_i * (li.product_variant&.m2_product_id.present? ? li.product_variant&.special_price.to_f : li.product_variant&.price.to_f)) }
    discount = self.discount_amount.present? ? subtotal * self&.discount_amount.to_f * 0.01 : 0
  
    shipping_amount = 0
    if self.shipping_type == "Standard"
      shipping_amount = StandardShippingRate.where("shipping_method ILIKE ?", "%#{self.shipping_method}%").where("order_min_price < ? AND order_max_price >= ?", subtotal + discount, subtotal + discount)&.first&.discount.to_f
    elsif self.shipping_type == "Local"
      if self.shipping_method == "Curbside Delivery - Waive Fee"
        shipping_amount = 0
      else
        shipping_amount = LocalShippingRate.where("shipping_method ILIKE ?", "%#{self.shipping_method}%").where("order_min_price < ? AND order_max_price >= ?", subtotal + discount, subtotal + discount)&.first&.discount.to_f
      end
    elsif self.shipping_type == "Remote"
      shipping_amount = RemoteShippingRate.where("shipping_method ILIKE ?", "%#{self.shipping_method}%").where("order_min_price < ? AND order_max_price >= ?", subtotal + discount, subtotal + discount)&.first&.discount.to_f
    elsif self.shipping_type == "Admin"
      shipping_amount = self.shipping_amount.to_f
    end

    tax = self.tax_amount.present? ? (subtotal - discount + shipping_amount) * self&.tax_amount.to_f * 0.01 : 0

    subtotal - discount + tax + shipping_amount
  end
end