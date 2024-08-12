class HardWorker
  include Sidekiq::Worker

  def perform(store)
    puts 'clone..'
    if store.present? 
      order = Magento::OrderSync.new(store)
      latest_order_ids = order.clone_orders
      # a = !(Order.nil?) ? Order.pluck(:shopify_order_id).map(&:to_i).max : 22897
      if !(latest_order_ids.nil?)
        latest_order_ids = latest_order_ids.map {|a| a.to_s} - Order.where(store: store).pluck(:shopify_order_id)
        # latest_order_ids = latest_order_ids.select{|a| a > Order.last.shopify_order_id.to_i}
        latest_order_ids.each do |i|
          order.get_order i
        end
      end
    else
      store = 'us'
      order = Magento::OrderSync.new(store)
      latest_order_ids = order.clone_orders
      # a = !(Order.nil?) ? Order.pluck(:shopify_order_id).map(&:to_i).max : 22897
      if !(latest_order_ids.nil?)
        latest_order_ids = latest_order_ids.map {|a| a.to_s} - Order.where(store: 'us').pluck(:shopify_order_id) - Order.where(store: 'canada').pluck(:shopify_order_id)
        # latest_order_ids = latest_order_ids.select{|a| a > Order.last.shopify_order_id.to_i}
        latest_order_ids.each do |i|
          order.get_order i
        end
      end
      store = 'canada'
      order = Magento::OrderSync.new(store)
      latest_order_ids = order.clone_orders
      # a = !(Order.nil?) ? Order.pluck(:shopify_order_id).map(&:to_i).max : 22897
      if !(latest_order_ids.nil?)
        latest_order_ids = latest_order_ids.map {|a| a.to_s} - Order.where(store: store).pluck(:shopify_order_id)
        # latest_order_ids = latest_order_ids.select{|a| a > Order.last.shopify_order_id.to_i}
        latest_order_ids.each do |i|
          order.get_order i
        end
      end
    end
  end
end