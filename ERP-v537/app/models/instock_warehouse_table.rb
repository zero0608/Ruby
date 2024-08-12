class InstockWarehouseTable < ApplicationRecord
  after_update do
    remote = (war_type.downcase.include? "remote") ? true : false
    name = "in_stock"
    Magento::UpdateOrder.new(store).update_delivery_eta(self,name,remote)
  end
end
