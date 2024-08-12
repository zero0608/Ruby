module Magento
  class OrderSync
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

    def get_orders
      response = HTTParty.get(@base_uri+"orders/23058/", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      if response.code == 200 && response.present?
        save_order(response)
      end
    end

    def clone_orders
      response = HTTParty.get(@base_uri+"orders?searchCriteria[filter_groups][0][filters][0][field]=created_at&searchCriteria[filter_groups][0][filters][0][value]=#{(Date.today - 1.day).to_date.strftime('%Y/%m/%d')}&searchCriteria[filter_groups][0][filters][0][condition_type]=from&searchCriteria[filter_groups][1][filters][0][field]=created_at&searchCriteria[filter_groups][1][filters][0][value]=#{(Date.today + 1.day).to_date.strftime('%Y/%m/%d')}&searchCriteria[filter_groups][1][filters][0][condition_type]=to&searchCriteria[currentPage]=1&searchCriteria[pageSize]=300", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)

      response["items"].pluck("entity_id") if response["items"].present?
    end

    def get_order(id)
      response = HTTParty.get(@base_uri+"orders/#{id}/", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      puts response.code
      if response.code == 200 && response.present?
        save_order(response)
      elsif response.code == 404
        get_order(id)
      end
    end

    def store_orders orders
      orders.each do |order|
        save_order order
      end
    end

    def set_order(id)
      response = HTTParty.get(@base_uri+"orders/#{id}/", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      puts response.code
      if response.code == 200 && response.present? && response['state'].present?
        update_order_status(response)
      end
      puts 'set order... '
    end

    def update_order_status order
      @order = Order.find_by(shopify_order_id: order.fetch("entity_id"), store: @store_country)
      unless (@order.status == 'cancel_confirmed') || (@order.status == 'cancel_request') || (@order.status == 'hold_confirmed') || (@order.status == 'hold_request')
        @order.update(status: 'in_progress') if order['state'] == 'processing' 
      end
      if order['state'] == 'complete' && !((@order.status == 'cancel_confirmed') || (@order.status == 'cancel_request') || (@order.status == 'hold_confirmed') || (@order.status == 'hold_request')) && @order.line_items.pluck(:sku).all? { |sku| sku == 'warranty' || sku == 'WGS001' || sku == 'HLD001' || sku == 'HFE001' || sku == 'Handling Fee'}
        @order.update(status: 'completed')
        Magento::UpdateOrder.new(@order.store).update_status("#{@order.shopify_order_id}", "#{@order.status}")
      end
      puts 'update order... '
    end

    def fetch_parent_id(id)
      response = HTTParty.get(@base_uri+"orders/#{id}/", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      puts response.code
      if response.code == 200 && response.present?
        response['items'].each do |item|
          if !(item["product_type"] == 'configurable') && (item['sku'].present?)
            @line_item = LineItem.find_by(shopify_line_item_id: item["item_id"], store: @store_country)
            @line_item.update(parent_line_item_id: item['parent_item_id'])
          end
        end
      end
    end

    # def fetch_parent_id(id)
    #   response = HTTParty.get(@base_uri+"orders/#{id}/", :headers => {
    #     "Content-Type" => "application/json",
    #     "Authorization" => "Bearer #{@bearer_token}"
    #   }, :verify => false)
    #   puts response.code
    #   if response.code == 200 && response.present?
    #     response['items'].each do |item|
    #       if !(item["product_type"] == 'configurable') && (item['sku'].present?)
    #         @order = Order.find_by(name: response['increment_id'])
    #         @line_item = @order.line_items.find_by(sku: item["sku"], store: @store_country)
    #         if @line_item.present?
    #           @line_item.update(shopify_line_item_id: item['item_id'])
    #           @line_item.update(parent_line_item_id: item['parent_item_id'])
    #         end
    #       end
    #     end
    #   end
    # end

    def save_order order
      store_initial = @store_country == 'us' ? 'EMUS' : 'EMCA'
      if !(Order.find_by(shopify_order_id: order.fetch("entity_id"), store: @store_country)) && (order["increment_id"].include? store_initial)
        @flag = @count1 = @count2 = @count11 = @count21 = @count12 = @count22 = 0
        @get_order_type = []
        ::Audited.store[:current_user] = User.find_by(email: 'admin@eternity-erp.com')
        if Order.pluck(:shopify_order_id).include? order["entity_id"].to_s
          @flag = 1
        end
        @order = Order.find_or_create_by(shopify_order_id: order["entity_id"], store: @store_country)

        @count11 = @order.try(:audits).count
        @count21 = @order.try(:associated_audits).count

        @order.shopify_order_id = order["entity_id"]
        @order.currency = order["order_currency_code"]
        @order.current_total_discounts = order["base_discount_amount"]
        @order.current_subtotal_price = order["base_subtotal"]
        @order.current_total_tax = order["base_tax_amount"]
        @method = order['extension_attributes']['payment_additional_info'].find {|x| break x['value'] if x['key'] == "method_title"} if (order['extension_attributes']['payment_additional_info'].present?) && !((order['extension_attributes']['payment_additional_info'].find {|x| x['key'] == "method_title"}).nil?)
        @order.eta_data_from = order['extension_attributes']['eta_from'] if order['extension_attributes']['eta_from'].present?
        @order.eta_data_to = order['extension_attributes']['eta_to'] if order['extension_attributes']['eta_to'].present?
        @order.payment_method = @method if @method.present?
        @order.discount_codes = { "discount_description" => "#{order['discount_description']}", "discount_amount" => "#{order['discount_amount']}"}
        @order.tax_lines = { "price" => "#{order['tax_amount']}"}
        if @store_country == 'us'
          @order.store = "us"
        elsif @store_country == 'canada'
          @order.store = "canada"
        end
        @order.name = order["increment_id"]
        @order.store_credit =  order['extension_attributes']['credit_amount'] if  order['extension_attributes']['credit_amount'].present?
        @order.order_notes = order["extension_attributes"]["swissup_checkout_fields"].find { |x| break x['value'] if x['code']=="order_note" } if (order["extension_attributes"].present? && order["extension_attributes"]["swissup_checkout_fields"].present?)
        @order.created_at = order['created_at']
        @order.attributes.keys.each do |k|
          @order.send((k + "="), order[k]) unless ['created_at','order_notes','order_type','tax_lines','discount_codes','shopify_order_id', 'name', 'status', 'currency', 'id', 'customer_id', 'current_total_discounts', 'current_subtotal_price', 'current_total_tax', 'store','store_credit','payment_method', 'eta_data_from', 'eta_data_to'].include? k
        end

        @order.save
        
        if order['state'] == 'processing'
          @order.update(status: 'in_progress')
        elsif order['state'] == 'complete'
          @order.update(status: 'completed')
          Magento::UpdateOrder.new(@order.store).update_status("#{@order.shopify_order_id}", "#{@order.status}")
        end
        
        if @order.shipping_details.present?
          @shipping_detail = @order.shipping_details.first
        else
          @shipping_detail = @order.shipping_details.create
        end

        @order.shipping_details.update_all(eta_from: @order.eta_data_from, eta_to: @order.eta_data_to)
        
        @order.update(order_notes: order["extension_attributes"]["swissup_checkout_fields"].find { |x| break x['value'] if x['code']=="order_note" }) if (order["extension_attributes"].present? && order["extension_attributes"]["swissup_checkout_fields"].present? && @order.order_notes.nil?)

        save_customer order if order.present?
        save_billing_address order["billing_address"] if order["billing_address"].present?
        store_shipping_address order["extension_attributes"]["shipping_assignments"] if (order["extension_attributes"].present? && order["extension_attributes"]["shipping_assignments"].present?)
        save_shipping_line order if order.present?

        store_line_items order['items'] if order['items'].present?

        # if @flag == 0
          a = Order.find_by(shopify_order_id: order["entity_id"], store: @store_country)
          a.audits.destroy_all
          a.associated_audits.destroy_all
        # end

        @count12 = @order.try(:audits).count
        @count22 = @order.try(:associated_audits).count

        @count1 = (@count12.to_i > @count11.to_i) ? (@count12.to_i - @count11.to_i) : nil
        @count2 = (@count22.to_i > @count21.to_i) ? (@count22.to_i - @count21.to_i) : nil
        if !(@count1.nil?)
          loop do
            @count1 = @count1 - 1
            a = Order.find(@order.id)
            a.audits.last.destroy if a.audits.present?    
            if @count1 == 0
              break
            end
          end
        end
        if !(@count2.nil?)
          loop do
            @count2 = @count2 - 1
            a = Order.find(@order.id)
            a.associated_audits.last.destroy  if a.associated_audits.present?      
            if @count2 == 0
              break
            end
          end
        end
        (@get_order_type.include? 'Unfulfillable') ? @order.update(order_type: 'Unfulfillable', kind_of_order: 'MTO') : @order.update(order_type: @get_order_type.uniq.reject(&:blank?).first)
        @order.shipping_details.update_all(status: :staging) if @order.order_type == 'Fulfillable' && @order.line_items.all? { |item| item.status == "ready" }

        com = @order.comments.create(description: "Order Imported", commentable_id: @order.id, commentable_type: "Order")
        # @order.update(created_at: com.created_at) if (com.created_at.year == @order.created_at.year)

        store_comments order["status_histories"] if order["status_histories"].present?

        if order['state'] == 'new' || order['state'] == 'pending' || order['state'] == 'payment_review' || order['state'] == 'pending_payment'
          @order.update(status: :pending_payment)
        end

        if @order.order_type == 'Unfulfillable'
          @order.update(kind_of_order: 'MTO')
        elsif @order.order_type == 'Fulfillable'
          @order.update(kind_of_order: 'QS')
          @order.update(staging_date: Date.today)
        end

        puts @order.errors.messages
        @order = Order.find_by(shopify_order_id: order["entity_id"], store: @store_country)
        if order['state'] == 'holded'
          @order.update(cancel_request_date: Time.now, status: :cancel_request, cancel_reason: "Order identified as high risk" )
        end
        @customer = @order.customer
        @billing_address = @order.billing_address
        if (@order.status != 'pending_payment') && (@order.store == 'canada') && ((@order.shipping_address.address2.titleize == 'Quebec') || (@order.shipping_address.address2.titleize == 'QC'))
          @order.update(status: :hold_request, hold_reason: "Billing address different than shipping address, verify customer.")
          @order.comments.create(description: "Hold reason: Billing address different than shipping address, verify customer.", commentable_id: @order.id, commentable_type: "Order")
        end
        if !(order['status_histories'][0].nil?) && (order['status_histories'][0]['comment'].include? 'shopify_payments')
          @order.update(status: :cancel_confirmed)
          @order.line_items.update_all(status: :cancelled)
          @order.shipping_details.update_all(status: :cancelled)
        end
        # Magento::UpdateOrder.new(@order.store).update_status("#{@order.shopify_order_id}", "#{@order.status}")
      end
    end

    def save_customer cust
      email = cust["customer_email"]
      customer = Customer.find_or_create_by(email: email)
      if cust["customer_firstname"].present?
        customer.first_name = cust["customer_firstname"]
      else
        customer.first_name = "Guest"
      end
      customer.last_name = cust["customer_lastname"]
      # customer.note =  cust.fetch("customer_note")
      customer.last_order_id = @order.id
      customer.attributes.keys.each do |k|
        customer.send((k + "="), cust[k]) unless ['id','email','first_name','last_name','note','last_order_id', 'created_at', 'updated_at'].include? k
      end
      customer.save
      puts 'customer..'
      @order.update(customer_id: customer.id)
    end

    def save_billing_address bill
      billing_address = @order.billing_address || @order.build_billing_address
      customer_billing_address = @order.customer.customer_billing_address || @order.customer.build_customer_billing_address
      billing_address.address1 = bill["street"]
      customer_billing_address.address = bill["street"]
      billing_address.address2 = bill["region"]
      customer_billing_address.state = bill["region"]
      billing_address.city = bill["city"]
      customer_billing_address.city = bill["city"]
      billing_address.country = bill["country_id"]
      customer_billing_address.country = bill["country_id"]
      billing_address.zip = bill["postcode"]
      customer_billing_address.zip = bill["postcode"]
      billing_address.company = bill["company"] if bill.include? "company"
      billing_address.first_name = bill["firstname"]
      billing_address.last_name = bill["lastname"]
      billing_address.phone = bill["telephone"] 

      billing_address.attributes.keys.each do |k|
        billing_address.send((k + "="), bill[k]) unless ['id', 'order_id', 'created_at', 'updated_at', 'address1','address2','city','country','zip','company','first_name','last_name', 'phone'].include? k
      end

      billing_address.save
      customer_billing_address.save
    end

    def store_shipping_address shipping_address
      shipping_address.each do |bill|
        save_shipping_address bill["shipping"]["address"] if (bill["shipping"].present? && bill["shipping"]["address"].present?)
      end
    end

    def save_shipping_address ship
      shipping_address = @order.shipping_address || @order.build_shipping_address
      customer_shipping_address = @order.customer.customer_shipping_address || @order.customer.build_customer_shipping_address
      shipping_address.address1 = ship["street"]
      customer_shipping_address.address = ship["street"]
      shipping_address.address2 = ship["region"]
      customer_shipping_address.state = ship["region"]
      shipping_address.city = ship["city"]
      customer_shipping_address.city = ship["city"]
      shipping_address.country = ship["country_id"]
      customer_shipping_address.country = ship["country_id"]
      shipping_address.company = ship["company"] if ship.include? "company"
      shipping_address.first_name = ship["firstname"]
      customer_shipping_address.first_name = ship["firstname"]
      shipping_address.last_name = ship["lastname"]
      customer_shipping_address.last_name = ship["lastname"]
      shipping_address.zip = ship["postcode"]
      customer_shipping_address.zip = ship["zip"]
      shipping_address.phone = ship["telephone"] 
      customer_shipping_address.phone = ship["telephone"]

      shipping_address.attributes.keys.each do |k|
        shipping_address.send((k + "="), ship[k]) unless ['id', 'order_id', 'created_at', 'updated_at','address1','address2','city','country','company','first_name','last_name','zip','phone'].include? k
      end

      shipping_address.save
      customer_shipping_address.save
    end

    def store_shipping_lines shipping_lines
      shipping_lines.each do |line|
        save_shipping_line line
      end
    end

    def save_shipping_line line
      unless @order.shipping_line.present?
        shipping_line = @order.build_shipping_line
      else
        shipping_line = @order.shipping_line
      end
      
      shipping_line.price = line['base_shipping_amount']
      shipping_line.title = line['shipping_description']

      shipping_line.attributes.keys.each do |k|
        shipping_line.send((k + "="), line[k]) unless ['price','title','id', 'order_id', 'created_at', 'updated_at'].include? k
      end
      puts 'shipping lines..'
      
      shipping_line.save
    end

    def store_comments comments
      comments.each do |com|
        save_comments com
      end
    end

    def save_comments com
      comment = @order.comments.new
      comment.description = com['comment']
      comment.commentable_id = @order.id
      comment.commentable_type = "Order"
      comment.created_at = com['created_at']

      comment.attributes.keys.each do |k|
        comment.send((k + "="), com[k]) unless ['description','commentable_id','commentable_type', 'created_at'].include? k
      end

      puts 'comments..'
      comment.save
    end

    def store_line_items items
      items.each do |item|
        if !(item["product_type"] == 'configurable') && (item['sku'].present?)
          save_line_item item
        end
      end
      puts @get_order_type

      @order.update(order_type: @get_order_type.uniq.reject(&:blank?).first)
    end

    def save_line_item item
      if !(LineItem.find_by(shopify_line_item_id: item["item_id"], store: @order.store).present?)
        pro = Magento::ProductSync.new(@order.store)
        @line_item = @order.line_items.find_or_create_by(shopify_line_item_id: item["item_id"], store: @order.store)        
        @line_item.title = item["name"]
        @line_item.price = item["parent_item"].present? ? item["parent_item"]["price"] : item["price"]
        @line_item.grams = item["weight"]
        @line_item.store = @order.store
        @line_item.quantity = item["qty_ordered"]
        @line_item.parent_line_item_id = item['parent_item_id']
        prod = Product.find_by(shopify_product_id: item['parent_item']['product_id'], store: @order.store) if item['parent_item'].present?
        vard = ProductVariant.find_by(shopify_variant_id: item['product_id'], store: @order.store)
        if vard.nil?
          pro = Magento::ProductSync.new(@order.store)
          pro.get_product("entity_id",item['product_id'])
          vard = ProductVariant.find_by(shopify_variant_id: item['product_id'], store: @order.store)
        end
        if prod.nil?
          pro = Magento::ProductSync.new(@order.store)
          pro.get_product("entity_id",item['parent_item']['product_id']) if item['parent_item'].present?
          prod = Product.find_by(shopify_product_id: item['parent_item']['product_id'], store: @order.store) if item['parent_item'].present?
          @line_item.product_id = prod&.id
          vard = ProductVariant.find_by(shopify_variant_id: item['product_id'], store: @order.store)
          @line_item.variant_id = vard.id if vard.present?
        else
          @line_item.product_id = prod&.id
          @line_item.variant_id = vard.id if vard.present?
        end
        @line_item.reserve = false
      
        @line_item.attributes.keys.each do |k|
          @line_item.send((k + "="), item[k]) unless ['id', 'title','price','grams','quantity', 'shopify_line_item_id', 'order_id', 'product_id', 'fulfillment_id', 'variant_id', 'created_at', 'updated_at', 'store', 'reserve','parent_line_item_id'].include? k
        end
        @line_item.shipping_detail_id = @shipping_detail.id
        puts "line................ item............."
        @line_item.save
        puts @line_item.id
        @line_item.update(status: 'not_started')
        @get_order_type.push 'Unfulfillable' if @line_item.title.start_with? 'COM'
        vard = ProductVariant.find_by(shopify_variant_id: item['product_id'], store: @order.store)
        @get_order_type.push order_ty(item, prod) if vard.present?

        if !(@line_item.title.include? 'Swatch' or @line_item.sku.length < 3) && @line_item.variant_id.present?
          vard = ProductVariant.find_by(id: @line_item.variant_id, store: @order.store)
          if !(vard.inventory_histories.present?)
            InventoryHistory.create(adjustment: 0, product_variant_id: @line_item.variant_id, quantity: vard.inventory_quantity.to_i)
          end
          if (vard.present?) && !(item['parent_item'].nil?) && !(item['parent_item']['extension_attributes'].nil?) && !(item['parent_item']['extension_attributes']['container_code'].nil?) && (item['parent_item']['extension_attributes'].fetch_values('container_code').present?)
            code = item['parent_item']['extension_attributes'].fetch_values('container_code')[0]
            if code.include? 'CTUS'
              container = Container.find_by(store: 'us', container_number: code.split( /CTUS*/ )[1])
            elsif code.include? 'CTCA'
              container = Container.find_by(store: 'canada', container_number: code.split( /CTCA*/ )[1])
            end
          
            if container.present?
              purchase_item = container.purchase_items.find_by(product_variant_id: @line_item.variant_id)
              if purchase_item.present?
                @line_item.update(purchase_item_id: purchase_item.id)
                @line_item.update(container_id: container.id)
                @line_item.update(purchase_id: purchase_item.purchase.id)
                purchase_item.update(quantity: purchase_item.try(:quantity).to_i - @line_item.quantity.to_i)
                purchase_item = PurchaseItem.find(purchase_item.id)
                Magento::UpdateOrder.new(container.store).create_container_stock(purchase_item)
              end
              @line_item.update(status: container.status)
              InventoryHistory.create(order_id: @order.id, product_variant_id: @line_item.variant_id, user_id: User.first.id, event: "Order Created", container_id: container.id, adjustment: ((ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i) - (@line_item.quantity.to_i + ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i)), quantity: ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i)

            end
          elsif vard.present? && (vard.inventory_quantity.to_i > 0)
            @qty = 0
            if (vard.inventory_quantity.to_i > @line_item.quantity.to_i)
              vard.update(inventory_quantity: (vard.inventory_quantity.to_i - @line_item.quantity.to_i))
              @line_item.update(status: 'ready')

              if vard.cartons.present?
                vard.update(to_do_quantity: (vard.to_do_quantity.to_i + @line_item.quantity.to_i))
                vard.cartons.each do |carton|
                  carton.update(to_do_quantity: (carton.to_do_quantity.to_i + @line_item.quantity.to_i))
                end
              else
                vard.update(to_do_quantity: (vard.to_do_quantity.to_i + @line_item.quantity.to_i))
              end              
              InventoryHistory.create(order_id: @order.id, product_variant_id: @line_item.variant_id, user_id: User.first.id, event: "Order Created", adjustment: ((ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i) - (@line_item.quantity.to_i + ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i)), quantity: ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i)
            elsif (vard.inventory_quantity.to_i == @line_item.quantity.to_i)
              @qty = vard.inventory_quantity.to_i - @line_item.quantity.to_i
              ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).update(inventory_quantity: @qty)
              @line_item.update(status: 'ready')
              InventoryHistory.create(order_id: @order.id, product_variant_id: @line_item.variant_id, user_id: User.first.id, event: "Order Created", adjustment: ((ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i) - (@line_item.quantity.to_i + ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i)), quantity: ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i)
            elsif (vard.inventory_quantity.to_i < @line_item.quantity.to_i)
              #if container is present in order info. in API
              #find container and purchase_item ans update related values
              if !(item['parent_item'].nil?) && !(item['parent_item']['extension_attributes'].nil?) && !(item['parent_item']['extension_attributes']['container_code'].nil?) && (item['parent_item']['extension_attributes'].fetch_values('container_code').present?)
                code = item['parent_item']['extension_attributes'].fetch_values('container_code')[0]
                if code.include? 'CTUS'
                  container = Container.find_by(store: 'us', container_number: code.split( /CTUS*/ )[1])
                elsif code.include? 'CTCA'
                  container = Container.find_by(store: 'canada', container_number: code.split( /CTCA*/ )[1])
                end
              end
              if container.present?
                purchase_item = container.purchase_items.find_by(product_variant_id: @line_item.variant_id)
                if purchase_item.present?
                  @line_item.update(purchase_item_id: purchase_item.id)
                  @line_item.update(container_id: container.id)
                  purchase_item.update(quantity: purchase_item.try(:quantity).to_i - @line_item.quantity.to_i)
                  purchase_item = PurchaseItem.find(purchase_item.id)
                  Magento::UpdateOrder.new(container.store).create_container_stock(purchase_item)
                end
              elsif vard&.purchase_items.where.not(status: :cancelled).present? && vard&.purchase_items.where(line_item_id: nil).present? && (vard&.purchase_items.where.not(status: :cancelled).joins(:containers).where(line_item_id: nil).where.not(containers: { arriving_to_dc: nil, status: 'arrived' }).present?)
              @pen = 0
                vard&.purchase_items.where.not(status: :cancelled).joins(:containers).where(line_item_id: nil).where.not(quantity: 0,containers: { arriving_to_dc: nil, status: 'arrived' }).order(id: :asc).each do |purchase_item|
                  @qt = 0
                  if purchase_item.line_item_id.nil? && !(purchase_item.status == 'cancelled')
                    purchase_item.containers.where.not(arriving_to_dc: nil, status: 'arrived').each do |container|
                      if !(container.arriving_to_dc.nil?) && !(container.status == 'arrived')
                        @qt = @qt + purchase_item.try(:quantity).to_i
                        if (@qt > 0) && (@qt > @line_item.quantity.to_i) && (@line_item.order.created_at > purchase_item.purchase.created_at)
                          @qt = @qt - @line_item.quantity.to_i
                          purchase_item.update(quantity: purchase_item.try(:quantity).to_i - @line_item.quantity.to_i)
                          @line_item.update(status: 'en_route')
                          @line_item.update(purchase_item_id: purchase_item.id)
                          @line_item.update(container_id: container.id)
                          @pen = 1
                          puts 'container qty...'
                        elsif (@qt > 0) && (@qt == @line_item.quantity.to_i) && (@line_item.order.created_at > purchase_item.purchase.created_at)
                          @qt = @qt - @line_item.quantity.to_i
                          purchase_item.update(quantity: purchase_item.try(:quantity).to_i - @line_item.quantity.to_i)
                          @line_item.update(status: 'en_route')
                          @line_item.update(purchase_item_id: purchase_item.id)
                          @line_item.update(container_id: container.id)
                          @pen = 1
                          puts 'container qty...'
                        end
                      end
                    end
                    break if @pen == 1
                  end
                end
                if !(@pen == 1) && (vard&.inventory_quantity.to_i == 0) && vard&.purchase_items.present? && vard&.purchase_items.where(line_item_id: nil).present?
                  @en = 0
                  vard&.purchase_items.where(line_item_id: nil).order(id: :asc).each do |purchase_item|
                    @pqt = 0
                    if !(purchase_item.containers.present?) && purchase_item.status != 'not_started' && purchase_item.status != 'completed' && !(purchase_item.status == 'cancelled') && (purchase_item&.quantity.to_i > @line_item.quantity.to_i)
                      @pqt = purchase_item.try(:quantity).to_i - @line_item.quantity.to_i
                      purchase_item.update(quantity: @pqt)
                      @line_item.update(status: purchase_item.status)
                      @line_item.update(purchase_id: purchase_item.purchase_id)
                      @line_item.update(purchase_item_id: purchase_item.id)
                      @en = 1
                      puts 'purchase qty...'
                    end
                    break if @en == 1
                  end
                end
              end
              InventoryHistory.create(order_id: @order.id, product_variant_id: ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).id, user_id: User.first.id, event: "Order Created", adjustment: ((ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i) - (@line_item.quantity.to_i + ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i)), quantity: ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i)
            end
          elsif vard.present? && (@line_item.quantity.to_i > vard&.inventory_quantity.to_i) && !(@line_item.quantity.to_i == vard&.inventory_quantity.to_i)
            if (vard&.inventory_quantity.to_i == 0) && vard&.purchase_items.where.not(status: :cancelled).present? && vard&.purchase_items.where(line_item_id: nil).present? && (vard&.purchase_items.where.not(status: :cancelled).joins(:containers).where(line_item_id: nil).where.not(containers: { arriving_to_dc: nil, status: 'arrived' }).present?)
            @pen = 0
              vard&.purchase_items.where.not(status: :cancelled).joins(:containers).where(line_item_id: nil).where.not(quantity: 0,containers: { arriving_to_dc: nil, status: 'arrived' }).order(id: :asc).each do |purchase_item|
                @qt = 0
                if purchase_item.line_item_id.nil? && !(purchase_item.status == 'cancelled')
                  purchase_item.containers.where.not(arriving_to_dc: nil, status: 'arrived').each do |container|
                    if !(container.arriving_to_dc.nil?) && !(container.status == 'arrived')
                      @qt = @qt + purchase_item.try(:quantity).to_i
                      if (@qt > 0) && (@qt > @line_item.quantity.to_i) && (@line_item.order.created_at > purchase_item.purchase.created_at)
                        @qt = @qt - @line_item.quantity.to_i
                        purchase_item.update(quantity: purchase_item.try(:quantity).to_i - @line_item.quantity.to_i)
                        @line_item.update(status: 'en_route')
                        @line_item.update(purchase_item_id: purchase_item.id)
                        @line_item.update(container_id: container.id)
                        @pen = 1
                        puts 'container qty...'
                      elsif (@qt > 0) && (@qt == @line_item.quantity.to_i) && (@line_item.order.created_at > purchase_item.purchase.created_at)
                        @qt = @qt - @line_item.quantity.to_i
                        purchase_item.update(quantity: purchase_item.try(:quantity).to_i - @line_item.quantity.to_i)
                        @line_item.update(status: 'en_route')
                        @line_item.update(purchase_item_id: purchase_item.id)
                        @line_item.update(container_id: container.id)
                        @pen = 1
                        puts 'container qty...'
                      end
                    end
                  end
                  break if @pen == 1
                end
              end
              if !(@pen == 1) && (vard&.inventory_quantity.to_i == 0) && vard&.purchase_items.present? && vard&.purchase_items.where(line_item_id: nil).present?
                @en = 0
                vard&.purchase_items.where(line_item_id: nil).order(id: :asc).each do |purchase_item|
                  @pqt = 0
                  if !(purchase_item.containers.present?) && purchase_item.status != 'not_started' && purchase_item.status != 'completed' && !(purchase_item.status == 'cancelled') && (purchase_item&.quantity.to_i > @line_item.quantity.to_i)
                    @pqt = purchase_item.try(:quantity).to_i - @line_item.quantity.to_i
                    purchase_item.update(quantity: @pqt)
                    @line_item.update(status: purchase_item.status)
                    @line_item.update(purchase_id: purchase_item.purchase_id)
                    @line_item.update(purchase_item_id: purchase_item.id)
                    @en = 1
                    puts 'purchase qty...'
                  end
                  break if @en == 1
                end
              end
            elsif (vard&.inventory_quantity.to_i == 0) && vard&.purchase_items.present? && vard&.purchase_items.where(line_item_id: nil).present?
              @en = 0
              vard&.purchase_items.where(line_item_id: nil).order(id: :asc).each do |purchase_item|
                @pqt = 0
                if !(purchase_item.containers.present?) && purchase_item.status != 'not_started' && purchase_item.status != 'completed' && !(purchase_item.status == 'cancelled') && (purchase_item&.quantity.to_i > @line_item.quantity.to_i)
                  @pqt = purchase_item.try(:quantity).to_i - @line_item.quantity.to_i
                  purchase_item.update(quantity: @pqt)
                  @line_item.update(status: purchase_item.status)
                  @line_item.update(purchase_id: purchase_item.purchase_id)
                  @line_item.update(purchase_item_id: purchase_item.id)
                  @en = 1
                  puts 'purchase qty...'
                end
                break if @en == 1
              end
            end
            InventoryHistory.create(order_id: @order.id, product_variant_id: ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).id, user_id: User.first.id, event: "Order Created", adjustment: ((ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i) - (@line_item.quantity.to_i + ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).inventory_quantity.to_i)), quantity: 0)
          end
          vard = ProductVariant.find_by(id: @line_item.variant_id, store: @order.store)

          #if warehouse is present
          if !(item['parent_item'].nil?) && !(item['parent_item']['extension_attributes'].nil?) && (item['parent_item']['extension_attributes'].fetch_values('source_code').present?)
            @warehouse = Warehouse.find_by(code: item['parent_item']['extension_attributes'].fetch_values('source_code')[0])
            if @warehouse.present?
              if (item['parent_item']['extension_attributes']['container_code'].present?) && (item['parent_item']['extension_attributes'].fetch_values('container_code').present?)
                @warehouse_variant = @line_item.variant.warehouse_variants.where(warehouse_id: @warehouse.id).first
                @line_item.update(warehouse_id: @warehouse.id)
                @line_item.update(warehouse_variant_id: @warehouse_variant.id)
                InventoryHistory.find_by(order_id: @order.id, product_variant_id: @line_item.variant_id).update(warehouse_id: @warehouse.id, warehouse_adjustment: InventoryHistory.find_by(order_id: @order.id, product_variant_id: @line_item.variant_id).adjustment.to_i, warehouse_quantity: WarehouseVariant.find(@warehouse_variant.id).warehouse_quantity.to_i)
              else
                @warehouse_variant = @line_item.variant.warehouse_variants.where(warehouse_id: @warehouse.id).first
                if @warehouse_variant.present? && (@warehouse_variant.warehouse_quantity.to_i >= @line_item.quantity.to_i)
                  @line_item.update(warehouse_id: @warehouse.id)
                  @line_item.update(warehouse_variant_id: @warehouse_variant.id)
                  @warehouse_variant.update(warehouse_quantity: (@warehouse_variant.warehouse_quantity.to_i - @line_item.quantity.to_i))
                  InventoryHistory.find_by(order_id: @order.id, product_variant_id: @line_item.variant_id).update(warehouse_id: @warehouse.id, warehouse_adjustment: InventoryHistory.find_by(order_id: @order.id, product_variant_id: @line_item.variant_id).adjustment.to_i, warehouse_quantity: WarehouseVariant.find(@warehouse_variant.id).warehouse_quantity.to_i)
                end
              end
            end
          end
          Magento::UpdateOrder.new(ProductVariant.find_by(id: @line_item.variant_id, store: @order.store).store).update_arriving_case_1_3(ProductVariant.find_by(id: @line_item.variant_id, store: @order.store)) if vard.present?
        end

        puts "line item--"
        puts @line_item.errors.messages
      end
    end

    def order_ty(item, prod)
      if item['sku'].present?
        variant = ProductVariant.find_by(shopify_variant_id: item['product_id'], store: @order.store)
        if !(variant.nil?)
          puts "#{@order.shopify_order_id}-- #{@order.id}-- #{@order.name} -- #{variant.try(:id)}"
          if item['name'].include? 'Mulberry'
            nil
          elsif (item['name'].include? 'Swatch' or item['sku'].length < 3)
            @line_item.update(status: 'ready')
            'SW'
          elsif !item['name'].include? 'Mulberry'
            if (item["qty_ordered"].to_i > variant.inventory_quantity.to_i) && !(item["qty_ordered"].to_i == variant.inventory_quantity.to_i)
              'Unfulfillable'
            else
              @order.update(status: 'in_progress')
              @line_item.update(status: 'ready')
              'Fulfillable'
            end
          end
        end
      else
        if item['name'].include? 'Mulberry'
          nil
        elsif (item['name'].include? 'Swatch' or item['sku'].length < 3)
          @line_item.update(status: 'ready')
          'SW'
        end
      end
    end

    def inventory_history(vard, item)
      puts "inventory_history"
      vard = ProductVariant.find_by(id: vard.id, store: vard.store)
      @line_item = LineItem.find_by(id: item.id)
      if vard.present? && vard.inventory_histories.present?
        if vard.inventory_quantity == 0
          puts "history qty1 #{vard.inventory_histories.last.quantity.to_i}"
          puts "history qty1 #{ProductVariant.find_by(id: vard.id, store: vard.store).inventory_histories.last.quantity.to_i}"
          @int_qty = (- @line_item.quantity.to_i + ProductVariant.find_by(id: vard.id, store: vard.store).inventory_histories.last.quantity.to_i)
          puts "int_qty #{@int_qty}"
          InventoryHistory.create(order_id: @order.id, product_variant_id: @line_item.variant_id, user_id: User.first.id, event: "Order Created", adjustment: ((vard.inventory_quantity.to_i) - (@line_item.quantity.to_i + vard.inventory_quantity.to_i)), quantity: @int_qty)
        else
          puts "history qty1 #{vard.inventory_histories.last.quantity.to_i}"
          puts "history qty1 #{ProductVariant.find_by(id: vard.id, store: vard.store).inventory_histories.last.quantity.to_i}"
          InventoryHistory.create(order_id: @order.id, product_variant_id: @line_item.variant_id, user_id: User.first.id, event: "Order Created", adjustment: ((vard.inventory_quantity.to_i) - (@line_item.quantity.to_i + vard.inventory_quantity.to_i)), quantity: ProductVariant.find_by(id: vard.id, store: vard.store).inventory_quantity.to_i)
        end
      end
    end
  end
end
