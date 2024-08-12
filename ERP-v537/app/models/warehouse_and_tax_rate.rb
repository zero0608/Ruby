class WarehouseAndTaxRate < ApplicationRecord
  belongs_to :warehouse, optional: true
  belongs_to :tax_rate

  after_update do
    if WarehouseAndTaxRate.where(tax_rate_id: self.tax_rate_id, terminal: "Primary").count.to_i > 1
      raise ActiveRecord::Rollback
    end
    Magento::UpdateOrder.new(self.tax_rate.store).create_state_source(self)
  end

  after_save do
    Magento::UpdateOrder.new(self.tax_rate.store).create_state_source(self)
  end
end
