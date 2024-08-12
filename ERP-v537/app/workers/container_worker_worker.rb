class ContainerWorkerWorker
  include Sidekiq::Worker
  sidekiq_options queue: "container_creation"

  def perform(container_id, purchase_item_ids)
    @container = Container.find(container_id)
    purchase_item_ids.each do |id|
      unless @container.purchase_items.where(id: id).present?
        @container_purchase = @container.container_purchases.build
        @container_purchase.purchase_item_id = id
        @container_purchase.save
        @container_purchase.purchase_item.update(status: :completed)
        PurchaseItem.find(id).line_item.update(status: :container_ready) if PurchaseItem.find(id).line_item.present?
        LineItem.where(purchase_item_id: id, purchase_id: PurchaseItem.find(id).purchase_id).update_all(container_id: @container.id) if LineItem.where(purchase_item_id: id, purchase_id: PurchaseItem.find(id).purchase_id).present?
        if PurchaseItem.find(id).product_variant_id.present? && !(PurchaseItem.find(id).line_item_id.present?)
          Magento::UpdateOrder.new(@container.store).update_arriving_case_1_3(PurchaseItem.find(id).product_variant)
          Magento::UpdateOrder.new(@container.store).create_container_stock(PurchaseItem.find(id))
        end
      end
    end
  end
end
