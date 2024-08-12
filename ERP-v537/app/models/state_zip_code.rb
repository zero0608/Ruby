class StateZipCode < ApplicationRecord
  belongs_to :tax_rate

  after_update do
    Magento::UpdateOrder.new(self.tax_rate.store).create_zip_code(self)
  end
end
