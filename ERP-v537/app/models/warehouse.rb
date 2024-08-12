class Warehouse < ApplicationRecord
  belongs_to :store_address, optional: true
  has_one :warehouse_address
  has_many :warehouse_and_tax_rates, dependent: :destroy
  has_many :tax_rates, through: :warehouse_and_tax_rates
  has_many :warehouse_variants, dependent: :destroy
  has_many :product_variants, through: :warehouse_variants
  has_many :users
  has_many :containers

  has_many :showrooms, dependent: :nullify

  has_many :warehouse_permissions, dependent: :destroy
  # validate :state_should_be_in_region

  accepts_nested_attributes_for :users, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :warehouse_address, allow_destroy: true, reject_if: :all_blank

  after_create do
    if Warehouse.where(store: self.store).first == self
      ProductVariant.where(store: self.store).each do |variant|
        WarehouseVariant.create(product_variant_id: variant.id, warehouse_id: self.id, store: self.store)
      end
    end
  end

  before_destroy do
    self.users.update_all(warehouse_id: nil, deactivate: true)
  end

  #validate state while creation
  # def state_should_be_in_region
  #   unless TaxRate.find(self.tax_rate_id).store == self.store
  #     errors.add(:base, "State should be within country")
  #   end
  # end
end

#after creation of first warehouse all variants will be assigned to that warehouse
#bedore destroy all warehouse users will be deactivated