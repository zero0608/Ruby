class OrderStatusmtoWorkerWorker
  include Sidekiq::Worker
  sidekiq_options queue: "order_status_mto"

  def perform(text1,text2)
    # ProductVariant.where(title: nil).all.each do |variant|
    #   if variant.store =='us'
    #     @bearer_token = Rails.application.credentials.magento[:us][:bearer_token]
    #     @base_uri = "#{Rails.application.credentials.magento[:us][:base_uri]}"
    #     @store_country = 'us'
    #   else
    #     @bearer_token = Rails.application.credentials.magento[:canada][:bearer_token]
    #     @base_uri = "#{Rails.application.credentials.magento[:canada][:base_uri]}"
    #     @store_country = 'canada'
    #   end
    #   @url = @base_uri+"products/id/#{variant.shopify_variant_id}"
    #   response = HTTParty.get(@url, :headers => {
    #     "Content-Type" => "application/json",
    #     "Authorization" => "Bearer #{@bearer_token}"
    #   }, :verify => false)
    #   variant.update(title: response['name'])
    #   puts "#{variant.sku}---  #{response['sku']}"
    #   puts response
    # end
    orders = Order.where(order_type: 'Unfulfillable').where.not(status: :pending_payment)
    if orders.present?
      orders.each do |order|
        order.send_status_to_m2_mto
      end
    end
  end
end
