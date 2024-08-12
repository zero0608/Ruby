class SkuUpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: "sku_update"

  def perform(sku,store)
    product_sync = Magento::ProductSync.new(store)
    product_sync.get_product("sku",sku)
    prod = Product.find_by(sku: sku, store: store)
    # product_sync = Magento::ProductSync.new(store)
    # product_sync.update_product("sku",sku) if ProductVariant.find_by(sku: sku, store: store).present?
    # prod = Product.find_by(sku: sku, store: store)
    # # puts 'update var'
    # # ProductVariant.all.each do |variant|
    # #   Magento::UpdateOrder.new.update_arriving_case_1_3(variant)
    # # end
  end
end
