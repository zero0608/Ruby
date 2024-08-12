class Customer < ApplicationRecord
  has_many :orders
  has_many :invoices

  has_one :customer_billing_address
  has_one :customer_shipping_address

  belongs_to :risk_indicator, optional: true
  belongs_to :employee, optional: true

  has_many :appointments, dependent: :nullify

  accepts_nested_attributes_for :customer_billing_address
  accepts_nested_attributes_for :customer_shipping_address

  def full_name
    if first_name.present? && last_name.present?
      first_name + " " + last_name
    elsif first_name.present?
      first_name
    end
  end
end
