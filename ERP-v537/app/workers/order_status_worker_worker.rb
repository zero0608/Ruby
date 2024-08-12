class OrderStatusWorkerWorker
  include Sidekiq::Worker
  sidekiq_options queue: "order_status"

  def perform(text1)
    ProductVariant.all.each do |variant|
      Magento::UpdateOrder.new(variant.store).update_arriving_case_1_3(variant)
      Magento::UpdateOrder.new(variant.store).update_inventory_stock(variant)
      puts "#{variant.sku}"
    end
    # ProductVariant.all.each do |variant|
    #   Magento::UpdateOrder.new(variant.store).update_arriving_case_1_3(variant)
    #   puts variant.sku
    # end
    # orders = Order.where("created_at::date = ?", Date.today - 24.hours)
    # orders = orders.where(order_type: 'Fulfillable', sent_mail: nil).where.not(status: :pending_payment)
    # if orders.present?
    #   orders.each do |order|
    #     order.send_status_to_m2_qs
    #   end
    # end
  end
end
