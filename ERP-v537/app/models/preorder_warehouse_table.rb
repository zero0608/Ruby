class PreorderWarehouseTable < ApplicationRecord
  after_update do
    remote = (war_type.downcase.include? "remote") ? true : false
    name = "pre_order"
    Magento::UpdateOrder.new(store).update_delivery_eta(self,name,remote)
  end
end
