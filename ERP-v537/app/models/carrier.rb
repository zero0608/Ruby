# frozen_string_literal: true

class Carrier < ApplicationRecord
  belongs_to :truck_broker, optional: true
  
  has_many :carrier_contacts, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :shipping_quotes, dependent: :destroy
  accepts_nested_attributes_for :carrier_contacts, allow_destroy: true, reject_if: :all_blank

  scope :get_carriers, ->(country) { where(country: country) }
end
