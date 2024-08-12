class ProductUpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: "product_update"

  def perform(sku,store)
    product_sync = Magento::ProductSync.new(store)
    product_sync.get_product("sku",sku) if ProductVariant.find_by(sku: sku, store: store).nil?
    prod = Product.find_by(sku: sku, store: store)
    # Do something
  end
end
