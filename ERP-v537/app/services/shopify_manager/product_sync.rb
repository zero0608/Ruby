module ShopifyManager
  class ProductSync
    include HTTParty

    attr_accessor :api_key, :api_password, :store_name, :api_version, :base_uri
    
    def initialize(store_type = 'us')
      if store_type == 'us'
        @api_key = Rails.application.credentials.shopify[:us_store][:api_key]
        @api_password = Rails.application.credentials.shopify[:us_store][:api_password]
        @store_name = Rails.application.credentials.shopify[:us_store][:store_name]
        @api_version = Rails.application.credentials.shopify[:api_version]
        @base_uri = "https://#{@api_key}:#{@api_password}@#{@store_name}.myshopify.com/admin/api/#{@api_version}/"
        @store_country = 'us'
      else
        @api_key = Rails.application.credentials.shopify[:canada_store][:api_key]
        @api_password = Rails.application.credentials.shopify[:canada_store][:api_password]
        @store_name = Rails.application.credentials.shopify[:canada_store][:store_name]
        @api_version = Rails.application.credentials.shopify[:api_version]
        @base_uri = "https://#{@api_key}:#{@api_password}@#{@store_name}.myshopify.com/admin/api/#{@api_version}/"
        @store_country = 'canada'
      end
    end

    def product_count
      response = self.class.get(@base_uri+"products/count.json")
      if response.code == 200 && response['count'].present?
        response['count']
      else
        0
      end
    end
    

    def get_products(limit=10)
      # product_count
      # trigger = (product_count/250)+1
      # for i in 1..trigger do
      #   if i == 1
      #     response = self.class.get(@base_uri+"products.json?limit=#{limit}")
      #   else
      #     page_info = response.headers['link'].split('json?')[1].split('>;')[0]
      #     response = self.class.get(@base_uri+"products.json?#{page_info}")
      #   end
      #   if response.code == 200 && response['products'].present?
      #     store_products(response['products'])
      #   end
      # end
      response = self.class.get(@base_uri+"products.json?ids=6692595859538")
      if response.code == 200 && response['products'].present?
        store_products(response['products'])
      end      
    end

    def store_products products
      products.each do |pro|
        save_product pro
      end
    end

    def save_product pro
      @product = Product.find_or_create_by(shopify_product_id: pro['id'])
      @product.shopify_product_id = pro['id']
      @product.attributes.keys.each do |k|
        @product.send((k + "="), pro[k]) unless ['shopify_product_id', 'id', 'shopify_tag_list', 'created_at', 'updated_at'].include? k
      end
      @product.shopify_tag_list = pro['tags']
      supplier = Supplier.find_by(name: 'Default')
      @product.supplier = supplier
      @product.store = @store_country
      @product.save
      store_variants pro['variants'] if pro['variants'].present?
      store_product_images pro['images'] if pro['images'].present?
      puts @product.errors.messages
    end

    def store_variants variants
      variants.each do |var|
        save_variant var
      end
    end

    def save_variant var
      variant = ProductVariant.find_or_create_by(shopify_variant_id: var['id'])
      variant.shopify_variant_id = var['id']
      variant.product_id = @product.id
      variant.attributes.keys.each do |k|
        variant.send((k + "="), var[k]) unless ['shopify_variant_id', 'id', 'product_id', 'created_at', 'updated_at'].include? k
      end
      # binding.pry
      variant.save
    end

    def store_product_images images
      images.each do |img| 
        save_product_images img
      end
    end

    def save_product_images img
      product_image = ProductImage.find_or_create_by(shopify_image_id: img['id'])
      product_image.shopify_image_id = img['id']
      product_image.product_id = @product.id
      product_image.attributes.keys.each do |k|
        product_image.send((k + "="), img[k]) unless ['shopify_image_id', 'id', 'product_id', 'created_at', 'updated_at'].include? k
      end
      # binding.pry    
      product_image.save  
    end
  end
end