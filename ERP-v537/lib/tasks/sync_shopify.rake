namespace :sync_shopify do
  desc "TODO"

  # task get_products: :environment do
  #   product_sync = ShopifyManager::ProductSync.new
  #   product_sync.get_products
  # end

  # task get_orders: :environment do
  #   order_sync = ShopifyManager::OrderSync.new
  #   order_sync.get_orders
  # end

  task get_products: :environment do
    product_sync = Magento::ProductSync.new
    product_sync.get_products
  end

  task get_orders: :environment do
    order_sync = Magento::OrderSync.new
    order_sync.get_orders
  end

  task all_orders: :environment do
    OrderUpdateWorker.perform_async
  end

  task update_variants: :environment do
    OrderStatusWorkerWorker.perform_async('variant')
  end

  task update_order_mto: :environment do
    OrderStatusmtoWorkerWorker.perform_async('6','unfulfillable')
  end

  # task update_arriving: :environment do
  #   SkuUpdateWorkerWorker.perform_async('var')
  # end

  task data_csv: :environment do
    filename = "public/Warehouse_Sale_Sku's_(1)_EMCA.csv"
    order_sync = Magento::ProductSync.new('canada')
    CSV.foreach(filename, headers: true) do |row|
      if !(row[2].nil?)
        variant = ProductVariant.find_by(sku: row[2].delete(' '))
        variant = ProductVariant.find_by(sku: row[2].delete(' ').downcase)
        order_sync.get_product('sku',row[2].delete(' ')) if variant.nil?
      end
    end
  end

  task data_csv: :environment do
    filename = "public/product_ca_new.csv"
    a = []
    CSV.foreach(filename, headers: true) do |row|
      if !(row[3].nil?) && !(row[0].nil?)
        variant = ProductVariant.where(store: 'canada').find_by('(lower(sku) = ?) and (shopify_variant_id = ?)', row[3].downcase, row[0])
        product = Product.where(m2_original: 'yes', store: 'canada').find_by('(lower(sku) = ?) and (shopify_product_id = ?)', row[3].downcase, row[0])
        if variant.present? && !(product.present?)
          variant.update(old_shopify_variant_id: variant.shopify_variant_id)
          variant.update(shopify_variant_id: row[2])
          puts "#{variant.sku} -- variant"
        elsif product.present?
          product.update(old_shopify_product_id: product.shopify_product_id)
          product.update(shopify_product_id: row[2])
          puts "#{product.sku} -- product"
        else
          pro = Magento::ProductSync.new('canada')
          pro.get_product("entity_id",row[2])
          a.push row[3]
        end
      end
    end
  end

  task data_csv: :environment do
    filename = "public/EMCA_Product_Details.csv"
    CSV.foreach(filename, headers: true) do |row|
      @sku = row[0].nil? ? @sku : row[0]
      if !(row[0].nil?)
        product = Product.find_by(m2_original: nil,sku: row[0].delete(' '), store: 'canada')
        product.carton_details.all.each do |carton_detail|
          carton_detail.product.product_variants.each do |variant|
            if !(variant.cartons.any? { |c| c.carton_detail_id == carton_detail.id })
              variant.cartons.create(received_quantity: variant.received_quantity, to_do_quantity: variant.to_do_quantity, carton_detail_id: carton_detail.id)
            end
          end
        end
        
      end
    end
  end

  task data_csv: :environment do
    filename = "public/Warehouse_Sale_SKU_6Apr_EMCA.csv"
    a,b,c = [],[],[]
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?)
        @variant = ProductVariant.set_store('canada').find_by('lower(sku) = ?', row[0].downcase)
        if @variant.present? && @variant.sku.present? && (@variant.sku.length > 3)
          if @variant.sku.upcase.include? 'WR'
            if Product.where(m2_original: nil, store: @variant.store).find_by(sku: @variant.sku.split('-')[1].upcase).present?
              @variant.update(product_id: Product.where(m2_original: nil, store: @variant.store).find_by(sku: @variant.sku.split('-')[1].upcase).id)
              a.push row[0]
            elsif @variant.product.present? && (@variant.product.m2_original == 'yes')
              @m2_product = @variant.product
              @new_product = Product.create(title: @m2_product.title, body_html: @m2_product.body_html, vendor: @m2_product.vendor, product_type: @m2_product.product_type, handle: @m2_product.handle, template_suffix: @m2_product.template_suffix, status: @m2_product.status, published_scope: @m2_product.published_scope, admin_graphql_api_id: @m2_product.admin_graphql_api_id, tags: @m2_product.tags, published_at: @m2_product.published_at, supplier_id: @m2_product.supplier_id, store: @variant.store, sku: @variant.sku.split('-')[1].upcase, quantity: @m2_product.quantity, uni_product_id: @m2_product.uni_product_id, category_id: @m2_product.category_id, factory: @m2_product.factory, subcategory_id: @m2_product.subcategory_id, m2_product_id: @m2_product.id, factory_id: @m2_product.factory_id, shopify_tag_list: @m2_product.shopify_tag_list)
              @variant.update(product_id: @new_product.id)
              b.push row[0]
            else
              created_product = Product.create(title: @variant.title, supplier_id: Supplier.find_by(name: 'Default').id, store: @variant.store, sku: @variant.sku.split('-')[1].upcase)        
              @variant.update(product_id: created_product.id, supplier_id: created_product&.supplier_id)
              c.push row[0]
            end
          end
          puts row[0]
        end
      end
    end
  end

  task data_csv: :environment do
    filename = "public/EMCA_Product_Details_2.csv"
    CSV.foreach(filename, headers: true).with_index do |row, i|
      next if i == 0
      @sku = row[0].nil? ? @sku : row[0]
      if !(row[0].nil?)
        product = Product.find_by(m2_original: nil,sku: row[0].delete(' '), store: 'canada')
        if product.nil?
          product = Product.create(sku: row[0], supplier_id: Supplier.find_by(name: 'Default').id, store: 'canada', title: "ERP created product for #{row[0]} variants")
        end
        if row[2].present?
          if product.carton_details.present? && product.carton_details.where(index: row[1]).present?
            product.carton_details.where(index: row[1]).first.update(length: row[2], width: row[3], height: row[4], weight: row[5])
          else
            product.carton_details.create(length: row[2], width: row[3], height: row[4], weight: row[5], index: row[1])
          end
        end
        if row[6].present?
          supplier = Supplier.find_by(name: row[6].to_s)
          product.update(supplier_id: supplier.id)
        end
        if row[7].present?
          factory = Factory.find_by(name: row[7].to_s) || Factory.create(name: row[7].to_s)
          product.update(factory_id: factory.id)
        end
        if row[8].present?
          category = Category.find_by(title: row[8].to_s) || Category.create(title: row[8].to_s)
          product.update(category_id: category.id)
        end
        product = Product.find_by(m2_original: nil,sku: row[0].delete(' '), store: 'canada')
        if product.m2_product_id.present?
          m2_prod = Product.find(product.m2_product_id)
          m2_prod.update(supplier_id: product.supplier_id, factory_id: product.factory_id, category_id: product.category_id)
        end
        product.product_variants.update_all(factory: product&.factory&.name, supplier_id: product&.supplier_id, category_id: product&.category_id)
        product.carton_details.all.each do |carton_detail|
          carton_detail.product.product_variants.each do |variant|
            if !(variant.cartons.any? { |c| c.carton_detail_id == carton_detail.id })
              variant.cartons.create(received_quantity: 0, to_do_quantity: 0, carton_detail_id: carton_detail.id)
            end
          end
        end
        puts product.sku
      elsif row[0].nil?
        product = Product.find_by(m2_original: nil,sku: @sku.delete(' '), store: 'canada')
        if row[2].present?
          if product.carton_details.present? && product.carton_details.where(index: row[1]).present?
            product.carton_details.where(index: row[1]).first.update(length: row[2], width: row[3], height: row[4], weight: row[5])
          else
            product.carton_details.create(length: row[2], width: row[3], height: row[4], weight: row[5], index: row[1])
          end
        end
        product.carton_details.all.each do |carton_detail|
          carton_detail.product.product_variants.each do |variant|
            if !(variant.cartons.any? { |c| c.carton_detail_id == carton_detail.id })
              variant.cartons.create(received_quantity: 0, to_do_quantity: 0, carton_detail_id: carton_detail.id)
            end
          end
        end
      end
    end
  end

  task data_csv: :environment do
    b = []
    filename = "public/EMUS_Variant_Details_2.csv"
    CSV.foreach(filename, headers: true) do |row|
      @sku = row[0].nil? ? @sku : row[0]
      if !(row[1].nil?)
        variant = ProductVariant.set_store('us').find_by('lower(sku) = ?', row[1].downcase)
        if variant.present?
          if variant.product.present? && variant.product.m2_original == 'yes'
            @m2_product = variant.product
            product = Product.where(m2_original: nil).find_by(sku: @sku.upcase, store: 'us')
            if product.nil?
              @m2_product = variant.product
              product = Product.create(title: @m2_product.title, body_html: @m2_product.body_html, vendor: @m2_product.vendor, product_type: @m2_product.product_type, handle: @m2_product.handle, template_suffix: @m2_product.template_suffix, status: @m2_product.status, published_scope: @m2_product.published_scope, admin_graphql_api_id: @m2_product.admin_graphql_api_id, tags: @m2_product.tags, published_at: @m2_product.published_at, supplier_id: @m2_product.supplier_id, store: 'us', sku: @sku.upcase, quantity: @m2_product.quantity, uni_product_id: @m2_product.uni_product_id, category_id: @m2_product.category_id, factory: @m2_product.factory, subcategory_id: @m2_product.subcategory_id, m2_product_id: @m2_product.id, factory_id: @m2_product.factory_id, shopify_tag_list: @m2_product.shopify_tag_list)
            end
            variant.update(product_id: product.id, m2_product_id: @m2_product.id, factory: product&.factory&.name, supplier_id: product&.supplier_id, category_id: product&.category_id)
          elsif !(variant.product.present?)
            product = Product.where(m2_original: nil).find_by(sku: @sku.upcase, store: 'us')
            if product.nil?
              product = Product.create(title: variant.title, supplier_id: Supplier.find_by(name: 'Default').id, store: 'us', sku: @sku.upcase)
            end          
            variant.update(product_id: product.id, factory: product&.factory&.name, supplier_id: product&.supplier_id, category_id: product&.category_id)
          end
          variant.update(unit_cost: row[3], stock: row[4].to_s, factory: variant.product&.factory&.name)
          puts variant.sku
        else
          b.push row[1]
          pro = Magento::ProductSync.new('us')
          pro.get_product("sku",row[1])
          variant = ProductVariant.set_store('us').find_by('lower(sku) = ?', row[1].downcase)
          if variant.present?
            if variant.product.present? && variant.product.m2_original == 'yes'
              @m2_product = variant.product
              product = Product.where(m2_original: nil).find_by(sku: @sku.upcase, store: 'us')
              if product.nil?
                @m2_product = variant.product
                product = Product.create(title: @m2_product.title, body_html: @m2_product.body_html, vendor: @m2_product.vendor, product_type: @m2_product.product_type, handle: @m2_product.handle, template_suffix: @m2_product.template_suffix, status: @m2_product.status, published_scope: @m2_product.published_scope, admin_graphql_api_id: @m2_product.admin_graphql_api_id, tags: @m2_product.tags, published_at: @m2_product.published_at, supplier_id: @m2_product.supplier_id, store: 'us', sku: @sku.upcase, quantity: @m2_product.quantity, uni_product_id: @m2_product.uni_product_id, category_id: @m2_product.category_id, factory: @m2_product.factory, subcategory_id: @m2_product.subcategory_id, m2_product_id: @m2_product.id, factory_id: @m2_product.factory_id, shopify_tag_list: @m2_product.shopify_tag_list)
              end
              variant.update(product_id: product.id, m2_product_id: @m2_product.id, factory: product&.factory&.name, supplier_id: product&.supplier_id, category_id: product&.category_id)
            elsif !(variant.product.present?)
              product = Product.where(m2_original: nil).find_by(sku: @sku.upcase, store: 'us')
              if product.nil?
                product = Product.create(title: variant.title, supplier_id: Supplier.find_by(name: 'Default').id, store: 'us', sku: @sku.upcase)
              end          
              variant.update(product_id: product.id, factory: product&.factory&.name, supplier_id: product&.supplier_id, category_id: product&.category_id)
            end
            variant.update(unit_cost: row[3], stock: row[4].to_s, factory: variant.product&.factory&.name)
            puts variant.sku
          end
        end
      end
    end
  end


  task quantity_update: :environment do
    filename = "public/Warehouse_Sale_Sku's_(1)_EMUS.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[2].nil?)
        if !(ProductVariant.find_by(sku: row[2].to_s, store: 'us').nil?)
          @variant = ProductVariant.find_by(sku: row[2].to_s, store: 'us')
          ProductVariant.find_by(sku: row[2].to_s, store: 'us').update(inventory_quantity: row[3].to_i)
          puts ProductVariant.find_by(sku: row[2].to_s, store: 'us').sku
          puts ProductVariant.find_by(sku: row[2].to_s, store: 'us').inventory_quantity
          @variant = ProductVariant.find_by(sku: row[2].to_s, store: 'us')
        elsif !(ProductVariant.find_by(sku: row[2].to_s.downcase, store: 'us').nil?)
          @variant = ProductVariant.find_by(sku: row[2].to_s.downcase, store: 'us')
          ProductVariant.find_by(sku: row[2].to_s.downcase, store: 'us').update(inventory_quantity: row[3].to_i)
          puts ProductVariant.find_by(sku: row[2].to_s, store: 'us').sku
          puts ProductVariant.find_by(sku: row[2].to_s, store: 'us').inventory_quantity
          @variant = ProductVariant.find_by(sku: row[2].to_s.downcase, store: 'us')
        end
        InventoryHistory.create(adjustment: 0, product_variant_id: @variant.id, quantity: @variant.inventory_quantity.to_i) if @variant.present?
        Magento::UpdateOrder.new(@variant.store).update_arriving_case_1_3(@variant) if @variant.present?
      end
    end
  end

  task quantity_update: :environment do
    filename = "public/EMCA_CSV_WR.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?)
        order_sync = Magento::ProductSync.new('canada')
        variant = ProductVariant.find_by(sku: row[0].to_s)
        variant = ProductVariant.find_by(sku: row[0].to_s.downcase)
        order_sync.get_product('sku',row[0]) if variant.nil?
        order_sync.update_qty('sku',row[0],row[1]) if variant.nil?
        @variant = ProductVariant.find_by(sku: row[0].to_s, store: 'canada')
        # ProductVariant.find_by(sku: row[0].to_s, store: 'us').update(inventory_quantity: row[1].to_i) if @variant.present?
        # InventoryHistory.create(adjustment: 0, product_variant_id: @variant.id, quantity: @variant.inventory_quantity.to_i) if @variant.present?
        # Magento::UpdateOrder.new(@variant.store).update_arriving_case_1_3(@variant) if @variant.present?
      end
    end
  end

  task quantity_update_magento: :environment do
    filename = "public/SKU_QTY_9NOV21.csv"
    CSV.foreach(filename, headers: true) do |row|
      variant = ProductVariant.find_by(sku: row[0]) if !(ProductVariant.find_by(sku: row[0]).nil?)
      Magento::UpdateOrder.new(variant.store).update_quantity(variant) if !(variant.nil?)
    end
  end

  task quantity_update_magento: :environment do
    filename = "public/updated_skus.csv"
    CSV.foreach(filename, headers: true) do |row|
      variant = ProductVariant.find_by(sku: row[1], store: 'canada')
      if !(variant.nil?)
        variant.update(sku: row[2])
      else
        order_sync = Magento::ProductSync.new('canada')
        order_sync.get_product('sku',row[2])
      end
      variant = ProductVariant.find_by(sku: row[1], store: 'canada')
      Magento::UpdateOrder.new(variant.store).update_arriving_case_1_3(variant) if variant.present?
    end
  end

  task add_state: :environment do
    filename = "public/Book_5.csv"
    CSV.foreach(filename, headers: true) do |row|
      @state = STATE_ABBR_TO_NAME(row[0])
      StateDay.create(state: @state, start_days: row[1], end_days: row[2])
      puts @state
    end
  end

  task add_state: :environment do
    filename = "public/EMCA_Aug_2021_orders_Part3.csv"
    CSV.foreach(filename, headers: true) do |row|
      if Order.find_by(name: row[0]).present?
        puts row[0]
        Order.find_by(name: row[0]).destroy
      end
    end
  end

  task add_state: :environment do
    filename = "public/emca_standard_shipping_rates.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[1].nil?)
        StandardShippingRate.create(order_min_price: row[0] , order_max_price: row[1], store: 'canada', shipping_method: row[3] , discount: row[2])
      end
    end
  end

  task add_state: :environment do
    filename = "public/emus_local_shipping_rates.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?)
        LocalCity.create(city: row[0] , store: 'us')
      end
    end
  end

  task data_csv: :environment do
    filename = "public/EMUC_CSV_WR.csv"
    order_sync = Magento::ProductSync.new('us')
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?)
        puts "#{row[0]} -- #{row[1]}"
        variant = ProductVariant.find_by(sku: row[0], store: 'us')
        variant = ProductVariant.find_by(sku: row[0].downcase, store: 'us') if variant.nil?
        order_sync.update_qty('sku',row[0],row[1])
        # variant.update(inventory_quantity: row[1].to_i) if !(variant.nil?)
        # InventoryHistory.create(adjustment: 0, product_variant_id: variant.id, quantity: variant.inventory_quantity.to_i) if variant.present?
        # Magento::UpdateOrder.new(variant.store).update_arriving_case_1_3(variant) if variant.present?
      end
    end
  end

  task data_csv: :environment do
    filename = "public/standard_Shipping_Charges_2022.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?)
        StandardShippingRate.create(order_min_price: row[0], order_max_price: row[1], discount: row[2], shipping_method: row[3], store: 'canada')
      end
    end
  end

  task data_csv: :environment do
    filename = "public/emca_variants.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?)
        variant = ProductVariant.find_by(sku: row[1].upcase, store: 'canada') || ProductVariant.find_by(sku: row[1].downcase, store: 'canada')
        if variant.present? && variant.sku.present?
          if Product.where(m2_original: nil).find_by(sku: row[0].upcase, store: 'canada').present?
            @erp_product = Product.where(m2_original: nil).find_by(sku: row[0].upcase, store: 'canada')
            variant.update(product_id: @erp_product.id)
          elsif variant.product.present?
            @m2_product = variant.product
            @product = Product.create(title: @m2_product.title, body_html: @m2_product.body_html, vendor: @m2_product.vendor, product_type: @m2_product.product_type, handle: @m2_product.handle, template_suffix: @m2_product.template_suffix, status: @m2_product.status, published_scope: @m2_product.published_scope, admin_graphql_api_id: @m2_product.admin_graphql_api_id, tags: @m2_product.tags, published_at: @m2_product.published_at, supplier_id: @m2_product.supplier_id, store: 'canada', sku: row[0].upcase, quantity: @m2_product.quantity, uni_product_id: @m2_product.uni_product_id, category_id: @m2_product.category_id, factory: @m2_product.factory, subcategory_id: @m2_product.subcategory_id, m2_product_id: @m2_product.id, factory_id: @m2_product.factory_id, shopify_tag_list: @m2_product.shopify_tag_list)
            variant.update(product_id: @product.id)
          end
        end
        puts row[0]
      end
    end
  end

  task data_csv: :environment do
    filename = "public/emca_parent.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?) && Product.where(m2_original: nil).find_by(sku: row[0].upcase, store: 'canada')
        @erp_product = Product.where(m2_original: nil).find_by(sku: row[0].upcase, store: 'canada')
        if row[2].present?
          carton = @erp_product.carton_details.create(length: row[2].to_i, width: row[3].to_i, height: row[4].to_i, weight: row[5].to_i)
          @erp_product.product_variants.each do |variant|
            variant.cartons.create(carton_detail_id: carton.id)
          end
        end
        puts row[0]
      end
    end
  end

  task data_csv: :environment do
    filename = "public/emca_parent_update.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[1].nil?) && !(row[7].nil?)
        product = Product.find_by(sku: row[1].upcase, store: 'canada', m2_original: nil) || Product.find_by(sku: row[1].downcase, store: 'canada', m2_original: nil)
        @factory1 = Factory.find_by(name: row[7].to_s)
        if @factory1.present?
          product.update(factory: @factory1.name, factory_id: @factory1.id) if product.present?
          product.product_variants.update_all(factory: factory.name.to_s)
        else
          @factory2 = Factory.create(name: row[7].to_s)
          product.update(factory: @factory2.name, factory_id: @factory2.id) if product.present?
        end
        puts row[7]
      end
    end
  end

  task data_csv: :environment do
    filename = "public/emca_parent_update.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?) && !(row[6].nil?) && (Product.where(m2_original: nil).find_by(sku: row[0].upcase, store: 'canada').present?)
        @erp_product = Product.where(m2_original: nil).find_by(sku: row[0].upcase, store: 'canada')
        supplier = Supplier.find_by(name: row[6].to_s)
        @erp_product.update(supplier_id: supplier.id)
        Product.find(@erp_product.m2_product_id).update(supplier_id: supplier.id)
        @erp_product.product_variants.update_all(supplier_id: supplier.id)
        puts row[6]
      end
    end
  end

  task data_csv: :environment do
    filename = "public/emca_variants.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[1].nil?) && !(row[3].nil?)
        variant = ProductVariant.find_by(sku: row[1].upcase, store: 'canada') || ProductVariant.find_by(sku: row[1].downcase, store: 'canada')
        variant.update(unit_cost: row[3].to_s) if variant.present?
        puts row[3]
      end
    end
  end

  task data_csv: :environment do
    filename = "public/emus_parent.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?) && !(row[7].nil?)
        @erp_product = Product.where(m2_original: nil).find_by(sku: row[0].upcase, store: 'us') 
        factory = Factory.find_by(name: row[7].to_s)
        if @erp_product.present?
          if factory.present? 
            @erp_product.update(factory_id: factory.id)
            Product.find(@erp_product.m2_product_id).update(factory_id: factory.id) if Product.find(@erp_product.m2_product_id)
            @erp_product.product_variants.update_all(factory: factory.name.to_s) if @erp_product.product_variants
          end
        elsif Product.find_by(sku: row[0].upcase, store: 'us')
          @m2_product = Product.find_by(sku: row[0].upcase, store: 'us')
          factory = Factory.find_by(name: row[7].to_s)
          if factory.present? 
            @m2_product.update(factory_id: factory.id)
            @m2_product.product_variants.update_all(factory: factory.name.to_s) if @m2_product.product_variants
          end
        end
        puts "#{row[7]} ----#{row[0]} "
      end
    end
  end

  task data_csv: :environment do
    filename = "public/emus_variants_update.csv"
    CSV.foreach(filename, headers: true) do |row|
      if !(row[0].nil?) && !(row[6].nil?)
        variant = ProductVariant.find_by(sku: row[1].upcase, store: 'us') || ProductVariant.find_by(sku: row[1].downcase, store: 'us')
        variant.update(inventory_limit: row[6].to_i, max_limit: row[5].to_i) if variant.present?
        puts row[6]
      end
    end
  end

end
