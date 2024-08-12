module ShopifyManager
  class OrderSync
    include HTTParty

    attr_accessor :api_key, :api_password, :store_name, :api_version, :base_uri, :store_country

    def initialize(store_type = 'us')
      if store_type =='us'
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

    def order_count
      response = self.class.get(@base_uri+"orders/count.json")
      if response.code == 200 && response['count'].present?
        response['count']
      else
        0
      end
    end

    def get_order(id)
      response = self.class.get(@base_uri+"orders/#{id}.json")
      if response.code == 200 && response['order'].present?
        save_order(response['order'])
      end
    end

    def get_orders(limit=25)
      response = self.class.get(@base_uri+"orders.json?limit=#{limit}")
      if response.code == 200 && response['orders'].present?
        store_orders(response['orders'])
      end      
    end

    def store_orders orders
      orders.each do |order|
        save_order order
      end
    end

    def save_order order
      @flag = @count1 = @count2 = @count11 = @count21 = @count12 = @count22 = 0
      ::Audited.store[:current_user] = User.first
      @get_order_type = []
      if Order.pluck(:shopify_order_id).include? order['id'].to_s
        @flag = 1
      end
      @order = Order.find_or_create_by(shopify_order_id: order['id'])
      @count11 = @order.try(:audits).count
      @count21 = @order.try(:associated_audits).count

      @order.shopify_order_id = order['id']
      @order.attributes.keys.each do |k|
        @order.send((k + "="), order[k]) unless ['shopify_order_id', 'id', 'created_at', 'updated_at'].include? k
      end
      @order.created_at = order['created_at'].to_datetime
      puts @order.created_at
      @order.store = @store_country
      @order.status = 'new_order'
      @order.save
      if @order.shipping_details.present?
        @shipping_detail = @order.shipping_details.first
      else
        @shipping_detail = @order.shipping_details.build
      end
      puts 'shipping..'
      puts @order.errors.messages
      store_fulfillments order['fulfillments'] if order['fulfillments'].present?
      save_customer order['customer'] if order['customer'].present?
      store_refunds order['refunds'] if order['refunds'].present?
      save_billing_address order['billing_address'] if order['billing_address'].present?
      save_shipping_address order['shipping_address'] if order['shipping_address'].present?
      store_shipping_lines order['shipping_lines'] if order['shipping_lines'].present?
      store_line_items order['line_items'] if order['line_items'].present?
      puts "order--"
      
      if @flag == 0
        a = Order.find(@order.id)
        a.audits.destroy_all
        a.associated_audits.destroy_all 
      end

      # @order.audits.where(action: 'create').destroy_all
      # @order.associated_audits.where(action: 'create').destroy_all

      @count12 = @order.try(:audits).count
      @count22 = @order.try(:associated_audits).count

      @count1 = (@count12.to_i > @count11.to_i) ? (@count12.to_i - @count11.to_i) : nil
      @count2 = (@count22.to_i > @count21.to_i) ? (@count22.to_i - @count21.to_i) : nil
      if !(@count1.nil?)
        loop do
          @count1 = @count1 - 1
          a = Order.find(@order.id)
          a.audits.last.destroy       
          if @count1 == 0
            break
          end
        end
      end
      if !(@count2.nil?)
        loop do
          @count2 = @count2 - 1
          a = Order.find(@order.id)
          a.associated_audits.last.destroy          
          if @count2 == 0
            break
          end
        end
      end

      puts @order.errors.messages
    end

    def save_customer cust
      customer = Customer.find_or_create_by(shopify_customer_id: cust['id'])
      customer.shopify_customer_id = cust['id']
      customer.last_order_id = @order.id
      customer.attributes.keys.each do |k|
        customer.send((k + "="), cust[k]) unless ['shopify_customer_id','id', 'last_order_id', 'created_at', 'updated_at'].include? k
      end
      customer.save
      @order.update(customer_id: customer.id)
    end

    def save_billing_address bill
      unless @order.billing_address.present?
        billing_address = @order.build_billing_address
      else
        billing_address = @order.billing_address
      end
      billing_address.attributes.keys.each do |k|
        billing_address.send((k + "="), bill[k]) unless ['id', 'order_id', 'created_at', 'updated_at'].include? k
      end
      
      billing_address.save
    end

    def save_shipping_address bill
      unless @order.shipping_address.present?
        shipping_address = @order.build_shipping_address
      else
        shipping_address = @order.shipping_address
      end
      shipping_address.attributes.keys.each do |k|
        shipping_address.send((k + "="), bill[k]) unless ['id', 'order_id', 'created_at', 'updated_at'].include? k
      end
      
      shipping_address.save
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
      shipping_line.attributes.keys.each do |k|
        shipping_line.send((k + "="), line[k]) unless ['id', 'order_id', 'created_at', 'updated_at'].include? k
      end
      puts 'shipping lines..'
      
      shipping_line.save
    end


    def store_fulfillments fulfillments
      fulfillments.each do |ful|
        save_fulfillment ful
      end
    end

    def save_fulfillment ful
      fulfillment = Fulfillment.find_or_create_by(shopify_fulfillment_id: ful['id'])
      fulfillment.shopify_fulfillment_id = ful['id']
      fulfillment.order_id = @order.id
      fulfillment.attributes.keys.each do |k|
        fulfillment.send((k + "="), ful[k]) unless ['shopify_fulfillment_id', 'id', 'order_id', 'created_at', 'updated_at'].include? k
      end
      
      fulfillment.save
    end

    
    def store_refunds refunds
      refunds.each do |ref|
        save_refund ref
      end
    end

    def save_refund ref      
      @refund = Refund.find_or_create_by(shopify_refund_id: ref['id'])
      @refund.shopify_refund_id = ref['id']
      @refund.order_id = @order.id
      @refund.attributes.keys.each do |k|
        @refund.send((k + "="), ref[k]) unless ['shopify_refund_id','id', 'order_id', 'created_at', 'updated_at'].include? k
      end
      
      @refund.save
      store_order_adjustments ref['order_adjustments'] if ref['order_adjustments'].present?
      store_transactions ref['order_adjustments'] if ref['order_adjustments'].present?
    end

    def store_order_adjustments adjs
      adjs.each do |adj|
        save_order_adjustment adj
      end
    end

    def save_order_adjustment adj
      order_adj = OrderAdjustment.find_or_create_by(refund_id: @refund.id)
      order_adj.refund_id = @refund.id
      order_adj.order_id = @order.id
      order_adj.attributes.keys.each do |k|
        order_adj.send((k + "="), adj[k]) unless ['id', 'order_id', 'refund_id', 'created_at', 'updated_at'].include? k
      end
      order_adj.save
    end

    def store_transactions trans
      trans.each do |tran|
        save_transaction tran
      end
    end

    def save_transaction tran
      transaction = OrderTransaction.find_or_create_by(refund_id: @refund.id)
      transaction.refund_id = @refund.id
      transaction.order_id = @order.id
      transaction.attributes.keys.each do |k|
        transaction.send((k + "="), tran[k]) unless ['id', 'order_id', 'refund_id', 'created_at', 'updated_at'].include? k
      end
      transaction.save
    end

    def store_line_items items
      items.each do |item|
        save_line_item item
      end
      puts @get_order_type
      @order.update(order_type: @get_order_type.uniq.reject(&:blank?).first)
      @order.update_order_status
    end

    def save_line_item item
      @line_item = LineItem.find_or_create_by(shopify_line_item_id: item['id'])
      @line_item.shopify_line_item_id = item['id']
      @line_item.order_id = @order.id
      prod = Product.find_by(shopify_product_id: item['product_id'])  
      vard = ProductVariant.find_by(shopify_variant_id: item['variant_id'])
      if prod.nil?
        prod = get_product(item['product_id'])
        @line_item.product_id = prod&.id
        if vard.present?
          @line_item.variant_id = vard.id
        end
      else
        @line_item.product_id = prod.id
        if vard.present?
          @line_item.variant_id = vard.id
        end
      end
      
      @line_item.attributes.keys.each do |k|
        @line_item.send((k + "="), item[k]) unless ['id', 'shopify_line_item_id', 'order_id', 'product_id', 'fulfillment_id', 'variant_id', 'created_at', 'updated_at'].include? k
      end
      @line_item.shipping_detail_id = @shipping_detail.id
      @line_item.save
      @line_item.update(status: 'not_started')
      
      @get_order_type.push 'Unfulfillable' if @line_item.title.start_with? 'COM'
      @get_order_type.push order_type(item, prod) if prod.present?
      puts "line item--"
      puts @line_item.errors.messages
    end

    def get_product(product_id)
      response = self.class.get(@base_uri+"products/#{product_id}.json")
      if response.code == 200 && response['product'].present?
        product_sync = ShopifyManager::ProductSync.new(@store_country)
        product_sync.save_product(response['product'])
      end
      puts "products.."
      Product.find_by(shopify_product_id: product_id)
    end

    def order_type(item, prod)
      variant = prod.product_variants.find_by(sku: item['sku'])
      unless variant.present?
        prod = get_product(item['product_id'])
        variant = prod.product_variants.find_by(sku: item['sku'])
      end
      if !(variant.nil?)
        puts "#{@order.id}-- #{@order.name} -- #{variant.try(:id)}"
        if item['title'].include? 'Mulberry'
          nil
        elsif item['title'].include? 'Swatch'
          @line_item.update(status: 'ready')
          'SW'
        elsif !item['title'].include? 'Mulberry'
          if item['quantity'].to_i > variant.inventory_quantity
            'Unfulfillable'
          else
            @line_item.update(status: 'ready')
            'Fulfillable'
          end
        end
      end
    end
  end
end
