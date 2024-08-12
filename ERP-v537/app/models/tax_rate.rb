class TaxRate < ApplicationRecord
  belongs_to :warehouse, optional: true
  has_many :warehouse_and_tax_rates, dependent: :destroy
  has_many :warehouses, through: :warehouse_and_tax_rates
  has_many :state_zip_codes, dependent: :destroy
  has_many :curbside_cities, dependent: :destroy

  accepts_nested_attributes_for :state_zip_codes, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :curbside_cities, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :warehouse_and_tax_rates, allow_destroy: true, reject_if: :all_blank
end
