class NewOrderWorker
  include Sidekiq::Worker
  sidekiq_options queue: "new_order"

  def perform(order_id,store)
    print "#{order_id}"
    if order_id.length > 3
      order_sync = Magento::OrderSync.new(store)
      order_sync.get_order order_id.to_i
      ord = Order.find_by(shopify_order_id: order_id, store: store)
    end
  end
end
