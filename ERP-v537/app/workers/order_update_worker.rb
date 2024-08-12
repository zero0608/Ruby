class OrderUpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: "order_update"

  def perform(order_id,store)
    print "#{order_id}"
    order_sync = Magento::OrderSync.new(store)
    if (Order.find_by(shopify_order_id: order_id.to_i, store: store)).present?
      order_sync.set_order order_id.to_i
    # else
    #   order_sync.get_order order_id.to_i
    end
    ord = Order.find_by(shopify_order_id: order_id, store: store)
  end
end
