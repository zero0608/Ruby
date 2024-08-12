module Magento
  class ProductSync
    include HTTParty

    attr_accessor :bearer_token, :base_uri, :store_country

    def initialize(store_type = 'us')
      if store_type =='us'
        @bearer_token = Rails.application.credentials.magento[:us][:bearer_token]
        @base_uri = "#{Rails.application.credentials.magento[:us][:base_uri]}"
        @store_country = 'us'
      else
        @bearer_token = Rails.application.credentials.magento[:canada][:bearer_token]
        @base_uri = "#{Rails.application.credentials.magento[:canada][:base_uri]}"
        @store_country = 'canada'
      end
    end

    # def get_product(type, value)
    #   response = HTTParty.get(@base_uri+"products?searchCriteria[filterGroups][0][filters][0][field]=#{type}&searchCriteria[filterGroups][0][filters][0][value]=#{value}&searchCriteria[filterGroups][0][filters][0][condition_type]=eq", :headers => {
    #     "Content-Type" => "application/json",
    #     "Authorization" => "Bearer #{@bearer_token}"
    #   })
    #   if response.code == 200 && response.present?
    #     if response['type_id'] == 'configurable'
    #       save_product response
    #     else
    #       save_variant response
    #     end
    #   end   
    # end

    def get_product(type, value)
      if type == 'entity_id'
        @url = @base_uri+"products/id/#{value}"
      else type == 'sku'
        @url = @base_uri+"products/#{value}"
      end
      response = HTTParty.get(@url, :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      if response.code == 200 && response.present? && !(response.empty?)
        if response['type_id'] == 'configurable'
          save_product response
        else
          save_variant response
        end
      end   
    end

    def update_product(type, value)
      if type == 'entity_id'
        @url = @base_uri+"products/id/#{value}"
      else type == 'sku'
        @url = @base_uri+"products/#{value}"
      end
      response = HTTParty.get(@url, :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      if response.code == 200 && response.present? && !(response.empty?)
        if response['type_id'] == 'configurable'
          # save_product response
        else
          @variant = ProductVariant.find_by(shopify_variant_id: response["id"], store: @store_country)
          @variant.update(special_price: (response['custom_attributes'].find {|x| break x['value'] if x['attribute_code'] == "special_price"})) if response['custom_attributes'].present?
          puts "#{@variant.sku}"
        end
      end   
    end

    def update_qty(type, value, qty)
      if type == 'entity_id'
        @url = @base_uri+"products/id/#{value}"
      else type == 'sku'
        @url = @base_uri+"products/#{value}"
      end
      response = HTTParty.get(@url, :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      if response.code == 200 && response.present? && !(response.empty?)
        if response['type_id'] == 'configurable'
          # save_product response
        else
          @variant = ProductVariant.find_by(shopify_variant_id: response['id'], store: @store_country)
          @variant.update(sku: response["sku"], inventory_quantity: qty)
          InventoryHistory.create(adjustment: 0, product_variant_id: @variant.id, quantity: @variant.inventory_quantity.to_i) if @variant.present?
          Magento::UpdateOrder.new(@variant.store).update_arriving_case_1_3(@variant) if @variant.present?
        end
      end   
    end

    def update_product_quantity(sku)
      response = HTTParty.get(@base_uri + "/inventory/source-items?searchCriteria[filter_groups][0][filters][0][field]=sku&searchCriteria[filter_groups][0][filters][0][value]=#{sku}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      if @store_country == 'us' && !(response['items'].nil?) && !(response['items'].select {|item| item["source_code"] == 'default' }.nil?) && !(response['items'].select {|item| item["source_code"] == 'default' }[0].nil?)
        response['items'].select {|item| item["source_code"] == 'default' }[0]['quantity']
      elsif @store_country == 'canada' && !(response['items'].nil?) && !(response['items'].select {|item| item["source_code"] == 'CA' }.nil?) && !(response['items'].select {|item| item["source_code"] == 'CA' }[0].nil?)
        response['items'].select {|item| item["source_code"] == 'CA' }[0]['quantity']
      end
    end

    def save_product pro
      if !(Product.find_by(shopify_product_id: pro.fetch("id"), store: @store_country).present?)
        @product = Product.find_or_create_by(shopify_product_id: pro.fetch("id"), store: @store_country)
        @product.shopify_product_id = pro.fetch("id")
        @product.title = pro["name"]
        @product.sku = pro["sku"]
        # @product.quantity = 0
        # @product.quantity = pro["extension_attributes"]["stock_item"]["qty"] if (pro["extension_attributes"].present?) && (pro["extension_attributes"]["stock_item"].present?)
        @product.attributes.keys.each do |k|
          @product.send((k + "="), pro[k]) unless ['sku','quantity','title','shopify_product_id', 'id', 'shopify_tag_list', 'created_at', 'updated_at'].include? k
        end
        supplier = Supplier.find_by(name: 'Default')
        @product.supplier = supplier
        if @store_country == 'us'
          @product.store = "us"
        elsif @store_country == 'canada'
          @product.store = "canada"
        end
        @product.save

        store_variants pro["extension_attributes"]["configurable_product_links"] if pro["extension_attributes"].present?
        store_product_images pro["extension_attributes"]["product_images"] if pro["extension_attributes"].present? && pro["extension_attributes"]["product_images"].present?
        puts @product.errors.messages

        pro["extension_attributes"]["product_images"] if pro["extension_attributes"].present?

        @product.update(m2_original: 'yes')
      else
        @product = Product.find_by(shopify_product_id: pro.fetch("id"), store: @store_country)
        @product.title = pro["name"]
        @product.sku = pro["sku"]
        store_variants pro["extension_attributes"]["configurable_product_links"] if pro["extension_attributes"].present?

        @product.save
      end
    end

    def store_product_images images
      images.each do |img| 
        save_product_images img
      end
    end

    def save_product_images img
      product_image = ProductImage.create
      # product_image.shopify_image_id = img['id']
      product_image.product_id = @product.id
      product_image.src = img
      product_image.attributes.keys.each do |k|
        product_image.send((k + "="), img[k]) unless ['src','shopify_image_id', 'id', 'product_id', 'created_at', 'updated_at'].include? k
      end   
      product_image.save  
    end

    def add_inventory_quantity(variant)
      response = HTTParty.get(@base_uri+"inventory/source-items?searchCriteria[filter_groups][0][filters][0][field]=sku&searchCriteria[filter_groups][0][filters][0][value]='#{variant.sku}'&searchCriteria[filter_groups][0][filters][0][condition_type]=eq", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      puts response.code
      if response['items'].present? && response['items'][0].present? && response['items'][0]['quantity'].present?
        variant.update(inventory_quantity: response['items'][0]['quantity'])
      else
        variant.update(inventory_quantity: 0)
      end
    end

    def store_variants variants
      variants.each do |var_id|
        get_product('entity_id', var_id)
      end
    end

    def save_variant var
      if !(ProductVariant.find_by(shopify_variant_id: var["id"], store: @store_country).present?)
        @variant = ProductVariant.find_or_create_by(shopify_variant_id: var["id"], store: @store_country)
        @variant.shopify_variant_id = var["id"]
        @variant.title = var["name"]
        @variant.price = var["price"]
        @variant.sku = var["sku"]
        @variant.weight = var["weight"]
        @variant.grams = var["weight"]
        @variant.special_price = var['custom_attributes'].find {|x| break x['value'] if x['attribute_code'] == "special_price"}
        # @variant.inventory_quantity = update_product_quantity(var["sku"])
        @variant.c2c_swatch = 'yes' if (var['custom_attributes'].find {|x| x['attribute_code'] == "c2c_swatch"}.present?)
        # @variant.inventory_quantity = var["extension_attributes"]["stock_item"]["qty"] if (var["extension_attributes"].present?) && (var["extension_attributes"]["stock_item"].present?) 
        @variant.position = var.fetch("media_gallery_entries").first.fetch("position") if var.fetch("media_gallery_entries").present? 
        if var.fetch("extension_attributes").present? && (var.fetch("extension_attributes").keys.include? "parent_ids")
          product_id = var["extension_attributes"]["parent_ids"].first
          prod = Product.find_by(shopify_product_id: product_id, store: @store_country)
          unless prod.present?
            response = get_product('entity_id', product_id)
            prod = Product.find_by(shopify_product_id: product_id, store: @store_country)
          end
          @variant.product_id = prod.try(:id)
        end
        if @product.present?
          @variant.product_id = @product.id
        end
        @variant.attributes.keys.each do |k|
          @variant.send((k + "="), var[k]) unless ['title','price','sku','weight','grams','inventory_quantity','position','product_id','shopify_variant_id', 'id', 'product_id', 'created_at', 'updated_at','special_price', 'c2c_swatch'].include? k
        end
        if @store_country == 'us'
          @variant.store = "us"
        elsif @store_country == 'canada'
          @variant.store = "canada"
        end
        @variant.save
        add_inventory_quantity(@variant)
        if @variant.product.present?
          @variant.update(m2_product_id: @variant.product.id) 
          @variant.product.update(m2_original: 'yes') 
        end
        # if (@variant.present?) && (@variant.sku.present?) && @variant.product.present?
        #   if (@variant.sku.include? '-')
        #     @variant.product.update(var_sku: @variant.sku.split('-').first)
        #   else
        #     @variant.product.update(var_sku: @variant.sku)
        #   end
        # end
        if @variant.sku.present? && (@variant.sku.length > 2)
          if @variant.sku.upcase.include? 'WR'
            if Product.where(m2_original: nil, store: @variant.store).find_by(sku: @variant.sku.split('-')[1].upcase).present?
              @variant.update(product_id: Product.where(m2_original: nil, store: @variant.store).find_by(sku: @variant.sku.split('-')[1].upcase).id)
            elsif @variant.product.present? && (@variant.product.m2_original == 'yes')
              @m2_product = @variant.product
              @new_product = Product.create(title: @m2_product.title, body_html: @m2_product.body_html, vendor: @m2_product.vendor, product_type: @m2_product.product_type, handle: @m2_product.handle, template_suffix: @m2_product.template_suffix, status: @m2_product.status, published_scope: @m2_product.published_scope, admin_graphql_api_id: @m2_product.admin_graphql_api_id, tags: @m2_product.tags, published_at: @m2_product.published_at, supplier_id: @m2_product.supplier_id, store: @variant.store, sku: @variant.sku.split('-')[1].upcase, quantity: @m2_product.quantity, uni_product_id: @m2_product.uni_product_id, category_id: @m2_product.category_id, factory: @m2_product.factory, subcategory_id: @m2_product.subcategory_id, m2_product_id: @m2_product.id, factory_id: @m2_product.factory_id, shopify_tag_list: @m2_product.shopify_tag_list)
              @variant.update(product_id: @new_product.id)
            else
              created_product = Product.create(title: @variant.title, supplier_id: Supplier.find_by(name: 'Default').id, store: @variant.store, sku: @variant.sku.split('-')[1].upcase)        
              @variant.update(product_id: created_product.id, supplier_id: created_product&.supplier_id)
            end
          elsif Product.where(m2_original: nil, store: @variant.store).find_by(sku: @variant.sku.split('-')[0].upcase).present?
            @variant.update(product_id: Product.where(m2_original: nil, store: @variant.store).find_by(sku: @variant.sku.split('-')[0].upcase).id)
          elsif @variant.product.present? && (@variant.product.m2_original == 'yes')
            @m2_product = @variant.product
            @new_product = Product.create(title: @m2_product.title, body_html: @m2_product.body_html, vendor: @m2_product.vendor, product_type: @m2_product.product_type, handle: @m2_product.handle, template_suffix: @m2_product.template_suffix, status: @m2_product.status, published_scope: @m2_product.published_scope, admin_graphql_api_id: @m2_product.admin_graphql_api_id, tags: @m2_product.tags, published_at: @m2_product.published_at, supplier_id: @m2_product.supplier_id, store: @variant.store, sku: @variant.sku.split('-')[0].upcase, quantity: @m2_product.quantity, uni_product_id: @m2_product.uni_product_id, category_id: @m2_product.category_id, factory: @m2_product.factory, subcategory_id: @m2_product.subcategory_id, m2_product_id: @m2_product.id, factory_id: @m2_product.factory_id, shopify_tag_list: @m2_product.shopify_tag_list)
            @variant.update(product_id: @new_product.id)
          else
            created_product = Product.create(title: @variant.title, supplier_id: Supplier.find_by(name: 'Default').id, store: @variant.store, sku: @variant.sku.split('-')[0].upcase)        
            @variant.update(product_id: created_product.id, supplier_id: created_product&.supplier_id)
          end
        elsif @variant.sku.present? && @variant.c2c_swatch == 'yes'
          if Product.find_by(sku: 'c2c_swatch', store: @variant.store).present?
            @product = Product.find_by(sku: 'c2c_swatch', store: @variant.store)
            @variant.update(product_id: @product.id)
          end
        end
        puts @variant.errors.messages
        puts 'variant..'
        Warehouse.where(store: @variant.store).each do |warehouse|
          WarehouseVariant.create(product_variant_id: @variant.id, warehouse_id: warehouse.id, warehouse_quantity: @variant.inventory_quantity, store: @variant.store)
        end
        if !(@variant.inventory_histories.present?)
          InventoryHistory.create(adjustment: 0, product_variant_id: @variant.id, quantity: @variant.inventory_quantity.to_i, warehouse_id:  Warehouse.where(store: @variant.store).first.id, warehouse_adjustment: 0, warehouse_quantity: @variant.inventory_quantity.to_i)
        end
        Magento::UpdateOrder.new(@variant.store).update_arriving_case_1_3(@variant) if @variant.present?
      # else
      #   @variant = ProductVariant.find_by(shopify_variant_id: var["id"], store: @store_country)
      #   @variant.price = var["price"]
      #   # @variant.sku = var["sku"]
      #   @variant.special_price = var['custom_attributes'].find {|x| break x['value'] if x['attribute_code'] == "special_price"}
      #   if var.fetch("extension_attributes").present? && (var.fetch("extension_attributes").keys.include? "parent_ids")
      #     product_id = var["extension_attributes"]["parent_ids"].first
      #     prod = Product.find_by(shopify_product_id: product_id, store: @store_country)
      #     unless prod.present?
      #       response = get_product('entity_id', product_id)
      #       prod = Product.find_by(shopify_product_id: product_id, store: @store_country)
      #     end
      #     @variant.product_id = prod.try(:id)
      #   end
      #   if @product.present?
      #     @variant.product_id = @product.id
      #   end
      #   @variant.save
      end
    end

  end 
end