class MtoWarehouseTable < ApplicationRecord
  after_update do
    remote = (war_type.downcase.include? "remote") ? true : false
    name = "mto"
    Magento::UpdateOrder.new(store).update_delivery_eta(self,name,remote)
  end
end
