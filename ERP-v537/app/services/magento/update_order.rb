module Magento
  class UpdateOrder
    include HTTParty

    attr_accessor :bearer_token, :base_uri, :attentive_url, :attentive_token

    def initialize(store_type = 'us')
      if store_type =='us'
        @attentive_url = "#{Rails.application.credentials.magento[:us][:attentive_url]}"
        @bearer_token = Rails.application.credentials.magento[:us][:bearer_token]
        @base_uri = "#{Rails.application.credentials.magento[:us][:base_uri]}"
        @attentive_token = Rails.application.credentials.magento[:us][:attentive_token]
        @store_type = 'us'
      elsif store_type =='canada'
        @attentive_url = "#{Rails.application.credentials.magento[:canada][:attentive_url]}"
        @bearer_token = Rails.application.credentials.magento[:canada][:bearer_token]
        @base_uri = "#{Rails.application.credentials.magento[:canada][:base_uri]}"
        @attentive_token = Rails.application.credentials.magento[:canada][:attentive_token]
        @store_type = 'canada'
      end
    end

    def update_status(entity_id, status)
      @order = Order.find_by(shopify_order_id: entity_id, store: @store_type)
      if @order.present?
        status1 = nil
        if @order.kind_of_order == 'QS' && !(@order.sent_mail == 0)
          status1 = @order.send_status_to_m2_qs(status)
        elsif @order.kind_of_order == 'MTO'
          status1 = @order.send_status_to_m2_mto(status)
        end
        puts "#{entity_id}"
        puts "#{status1}"
        if !(status1.nil?) && !(@order.line_items.any? { |item| item.sku == "WAREHOUSE-HOLD" || item.sku == "RECONSIGNMENT-FEE" || item.sku == "SHIPPING-FOR-COM" || item.sku == "REMOTE-SHIPPING" || item.sku == "REDELIVERY-FEE" || item.sku == "HANDLING-FEE" || item.sku == "STORAGE-FEE" || item.sku == "WGS001" || item.sku == "E-PMNT" }) && !(@order.order_type == 'SW')
          response = HTTParty.post(@base_uri+"orders/#{@order.shopify_order_id}/comments",
                      :body => 
                        {
                          "statusHistory": {
                            "comment": "",
                            "is_customer_notified": 1,
                            "is_visible_on_front": 0,
                            "parent_id": "#{@order.shopify_order_id}",
                            "entity_name": "order",
                            "status": "#{status1}"
                          }
                        }.to_json,
                      :headers => {
                        "Content-Type" => "application/json",
                        "Authorization" => "Bearer #{@bearer_token}"
          }, :verify => false)
        
          puts response

        end

        @attentive_status = @order.attentive_status
        if @attentive_status.present?
          response = HTTParty.post(@attentive_url,
                      :body =>
                        {
                          "type": "#{@attentive_status}",
                          "user": {
                            "phone": "+16046266162",
                            "email": "hanson@northbanq.com"
                          }
                        }.to_json,
                        :headers => {
                          "Content-Type" => "application/json",
                          "Authorization" => "Bearer #{@attentive_token}"
            }, :verify => false)

            puts response
        end
      end
    end

    def update_status_for_M2(entity_id, status)
      puts "#{entity_id}"
      puts "#{status}"
      response = HTTParty.post(@base_uri+"orders",
                  :body => {
                    "entity": { "entity_id": "#{entity_id}", "status": "#{status}" } }.to_json,
                  :headers => {
                    "Content-Type" => "application/json",
                    "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      
      puts response
      
    end

    def update_quantity(variant)
      variant.warehouse_variants.each do |war_var|
      
      # source_code = variant.store == 'us' ? 'default' : 'CA'
        response = HTTParty.post(@base_uri+"inventory/source-items",
                    :body => { "sourceItems": [{ "sku": "#{variant.sku}", "source_code": "#{war_var.warehouse.code}", "quantity": "#{war_var.warehouse_quantity}", "status": 1 }]
                  }.to_json,
                    :headers => {
                      "Content-Type" => "application/json",
                      "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts response
        puts "#{variant.inventory_quantity}"
      end
      # source_code = variant.store == 'us' ? 'default' : 'CA'
      # response = HTTParty.post(@base_uri+"inventory/source-items",
      #             :body => { "sourceItems": [{ "sku": "#{variant.sku}", "source_code": "#{source_code}", "quantity": "#{variant.inventory_quantity}", "status": 1 }]
      #           }.to_json,
      #             :headers => {
      #               "Content-Type" => "application/json",
      #               "Authorization" => "Bearer #{@bearer_token}"
      # }, :verify => false)
      # puts response
      # puts "#{variant.inventory_quantity}"
      # response = HTTParty.put(@base_uri+"products/#{variant.sku.gsub(' ', '-')}/stockItems/#{variant.shopify_variant_id}",
      #             :body => { "stockItem": { "qty": "#{variant.inventory_quantity}" } }.to_json,
      #             :headers => {
      #               "Content-Type" => "application/json",
      #               "Authorization" => "Bearer #{@bearer_token}"
      # }, :verify => false)
      
      # puts response      
    end

    def update_inventory_stock(variant)
      if variant.stock == 'Inventory'
        @stock_value = 1
      elsif variant.stock == 'Non-Inventory'
        @stock_value = 1
      elsif variant.stock == 'Deactivated'
        @stock_value = 2
      elsif (variant.stock == 'Discontinued') && (variant.inventory_quantity.to_i > 0)
        @stock_value = 1
      elsif (variant.stock == 'Discontinued') && (variant.inventory_quantity.to_i == 0)
        @stock_value = 2
      end
      if !(@stock_value.nil?)
        # if (@stock_value == 2)
          response = HTTParty.put(@base_uri+"products/#{variant.sku.gsub(' ', '-')}",
                    :body => { "product": { "status": @stock_value } }.to_json,
                    :headers => {
                      "Content-Type" => "application/json",
                      "Authorization" => "Bearer #{@bearer_token}"
            }, :verify => false)
        # else
        #   response = HTTParty.put(@base_uri+"products/#{variant.sku.gsub(' ', '-')}",
        #             :body => { "product": { "custom_attributes": [{ "attribute_code": "custom_inventory", "value": @stock_value }] } }.to_json,
        #             :headers => {
        #               "Content-Type" => "application/json",
        #               "Authorization" => "Bearer #{@bearer_token}"
        #     }, :verify => false)
        # end
                          
        puts response
      end
      
    end

    def update_arriving_case_1_3(variant)
      if variant.sku.present? && variant.title.present? && !(variant.title.include? 'Swatch' or variant.sku.length < 3)
        if variant.try(:inventory_quantity).to_i > 0 && !(variant.try(:inventory_quantity).to_i == 0)
          if variant.try(:inventory_quantity).to_i < 10
            response = HTTParty.put(@base_uri+"products/#{variant.sku.gsub(' ', '-')}",
                    :body => { "product": { "custom_attributes": [{ "attribute_code": "arriving_date", "value": "#{variant.try(:inventory_quantity).to_i} In stock" }] } }.to_json,
                    :headers => {
                      "Content-Type" => "application/json",
                      "Authorization" => "Bearer #{@bearer_token}"
            }, :verify => false)
            update_arriving_quantity(variant)
            puts 'case 1..'
            puts response
          else
            response = HTTParty.put(@base_uri+"products/#{variant.sku.gsub(' ', '-')}",
                    :body => { "product": { "custom_attributes": [{ "attribute_code": "arriving_date", "value": "10+ In stock" }] } }.to_json,
                    :headers => {
                      "Content-Type" => "application/json",
                      "Authorization" => "Bearer #{@bearer_token}"
            }, :verify => false)
            update_arriving_quantity(variant)
            puts 'case 1..'
            puts response
          end
        elsif variant.try(:inventory_quantity).to_i == 0
          @b = @a = @c = 0
          if variant.purchase_items.where(line_item_id: nil).present?
            variant.purchase_items.where(line_item_id: nil).each do |item|
              if item.containers.present?
                item.containers.each do |cant|
                  @a = @a + item.try(:quantity).to_i if cant.arriving_to_dc.present? && !(cant.status == "arrived")
                  @b = @b + item.try(:quantity).to_i if !(cant.arriving_to_dc.present?) && !(cant.status == "arrived")
                  if cant.arriving_to_dc.present? && @container.present? && @container.arriving_to_dc.present?
                    if cant.arriving_to_dc > @container.arriving_to_dc
                      @container = cant
                    end
                  else cant.arriving_to_dc.present?
                    @container = cant
                  end
                end
              end
              # if (@a > 0)
              #   @a = @a - (LineItem.joins(:order).where(sku: variant.sku).where("orders.created_at >= ?", item.purchase.created_at).where.not(orders: { order_type: 'fulfillable' }).pluck(:quantity).reject(&:blank?).map(&:to_i).sum)
              # end
            end
            @c = variant.purchase_items.where(line_item_id: nil, status: :in_production).pluck(:quantity).reject(&:blank?).map(&:to_i).sum + variant.purchase_items.where(line_item_id: nil, status: :container_ready).pluck(:quantity).reject(&:blank?).map(&:to_i).sum
          end
          
          if (@a > 0)
            update_arriving_date(variant,@container,@a) if @container.present?
          elsif @c > 0
            response = HTTParty.put(@base_uri+"products/#{variant.sku.gsub(' ', '-')}",
                      :body => { "product": { "custom_attributes": [{ "attribute_code": "arriving_date", "value": "8-12weeks" }] } }.to_json,
                      :headers => {
                        "Content-Type" => "application/json",
                        "Authorization" => "Bearer #{@bearer_token}"
            }, :verify => false)
            puts 'case 4..' 
            puts response
          elsif @b == 0 || @b > 0
            response = HTTParty.put(@base_uri+"products/#{variant.sku.gsub(' ', '-')}",
              :body => { "product": { "custom_attributes": [{ "attribute_code": "arriving_date", "value": "8-12weeks" }] } }.to_json,
              :headers => {
                "Content-Type" => "application/json",
                "Authorization" => "Bearer #{@bearer_token}"
            }, :verify => false)
            puts 'case 3..'
            puts response
          end
          update_arriving_quantity(variant)
        end
      end
      update_quantity(variant)
    end

    def update_arriving_date(variant,container,a = 0)
      if variant.sku.present? && variant.title.present? && !(variant.title.include? 'Swatch' or variant.sku.length < 3) && container.present? && container.arriving_to_dc.present?
        response = HTTParty.put(@base_uri+"products/#{variant.sku.gsub(' ', '-')}",
                  :body => { "product": { "custom_attributes": [{ "attribute_code": "arriving_date", "value": "Ships After #{container.arriving_to_dc.to_date.strftime('%B %d, %Y')}" }] } }.to_json,
                  :headers => {
                    "Content-Type" => "application/json",
                    "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts 'case 2..' 
        puts response
      end
    end

    def update_arriving_quantity(variant)
      if variant.sku.present? && variant.title.present? && !(variant.title.include? 'Swatch' or variant.sku.length < 3)
        source_code = variant.store == 'us' ? 'default' : 'CA'
        response = HTTParty.post(@base_uri+"inventory/source-items",
                    :body => { "sourceItems": [{ "sku": "#{variant.sku}", "source_code": "#{source_code}", "quantity": "#{variant.inventory_quantity}", "status": 1 }]
                  }.to_json,
                    :headers => {
                      "Content-Type" => "application/json",
                      "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts response
        puts "#{variant.inventory_quantity}"
      end

      # if variant.sku.present? && variant.title.present? && !(variant.title.include? 'Swatch' or variant.sku.length < 3)
      #   response = HTTParty.put(@base_uri+"products/#{variant.sku.gsub(' ', '-')}/stockItems/#{variant.shopify_variant_id}",
      #               :body => { "stockItem": { "qty": "#{variant.inventory_quantity}" } }.to_json,
      #               :headers => {
      #                 "Content-Type" => "application/json",
      #                 "Authorization" => "Bearer #{@bearer_token}"
      #   }, :verify => false)
      #   puts response
      #   puts "#{variant.inventory_quantity}"
      # end
    end

    def create_shipment(order,shipping_detail)
      @arr = []
      shipping_detail.line_items.each do |item|
        @order_item_id = 0
        if item.parent_line_item_id.nil?
          Magento::OrderSync.new(order.store).fetch_parent_id(order.shopify_order_id)
          @order_item_id = item.parent_line_item_id.to_i if item.parent_line_item_id.present?
          @order_item_id = item.shopify_line_item_id.to_i if item.parent_line_item_id.nil?
        else
          @order_item_id = item.parent_line_item_id.to_i
        end
        @arr << { "order_item_id": @order_item_id, "qty": item.quantity.to_i }
      end
      response = HTTParty.post(@base_uri+"order/#{order.shopify_order_id}/ship", 
      :body => {
          "items": @arr,
          "notify": false,
          "tracks": [
            {
              "track_number": "#{shipping_detail.tracking_number}",
              "title": "#{shipping_detail.tracking_url_for_ship}",
              "carrier_code": "#{shipping_detail.carrier.name}"
            }
          ]
        }.to_json,
      :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      puts "#{response}"
    end

    def enabled_container(container)
      name = container.store == 'us' ? 'CTUS' : 'CTCA'
      response = HTTParty.post(@base_uri + "bss-erp/inventory_container/", 
        :body => {
            "inventoryContainer": {
                "container_code": "#{name}" + "#{container.container_number}",
                "source_code": "#{container&.warehouse&.code}",
                "name": "#{name}" + "#{container.container_number}",
                "container_eta": "#{container.port_eta}",
                "enabled": 0
            }
        
          }.to_json,
        :headers => {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts "#{response}"
    end

    def update_container(container)
      name = container.store == 'us' ? 'CTUS' : 'CTCA'
      response = HTTParty.post(@base_uri + "bss-erp/inventory_container/", 
        :body => {
            "inventoryContainer": {
                "container_code": "#{name}" + "#{container.container_number}",
                "source_code": "#{container&.warehouse&.code}",
                "name": "#{name}" + "#{container.container_number}",
                "container_eta": "#{container.port_eta}",
                "enabled": 1
            }
        
          }.to_json,
        :headers => {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts "#{response}"
        container.purchase_items.where(line_item_id: nil).each do |item|
          create_container_stock(item)
        end
    end

    def update_delivery_eta(delivery,name,remote)
      response = HTTParty.post(@base_uri + "bss-erp/delivery-eta", 
        :body => {
            "deliveryEta": {
              "id": delivery.id,
              "is_remote": remote,
              "delivery_method": delivery.delivery_method,
              "delivery_type": name,
              "eta_from_days": delivery.from_days,
              "eta_to_days": delivery.to_days,
              "terminal": delivery.terminal
            }
          }.to_json,
        :headers => {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts "#{response}"
    end

    def create_container_stock(item)
      name = item.purchase.store == 'us' ? 'CTUS' : 'CTCA'
      response = HTTParty.post(@base_uri + "bss-erp/inventory_container_stock", 
        :body => {
            "stockContainer":
            {
                "container_code": "#{name}" + "#{item.containers.first.container_number}",
                "sku": "#{item&.product_variant&.sku}",
                "quantity": "#{item.quantity}"
            }
          }.to_json,
        :headers => {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts "#{response}"
    end

    def create_zip_code(zipcode)
      response = HTTParty.post(@base_uri + "bss-erp/state-zipcode", 
        :body => {
            "stateZipcode": {
              "zipcode": "#{zipcode.zip_code}",
              "state": "#{zipcode.tax_rate.state}",
              "is_remote": "#{zipcode.remote}"
            }
          }.to_json,
        :headers => {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts "#{response}"
    end

    def create_city_code(city)
      response = HTTParty.post(@base_uri + "bss-erp/state-zipcode", 
        :body => {
            "stateZipcode": {
              "zipcode": "#{city.city}",
              "state": "#{city.tax_rate.state}",
              "is_remote": "0"
            }
          }.to_json,
        :headers => {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts "#{response}"
    end

    def create_state_source(state)
      response = HTTParty.post(@base_uri + "bss-erp/state-source", 
        :body => {
            "stateSource": {
              "state": "#{state&.tax_rate&.state}",
              "source_code": "#{state&.warehouse&.code}",
              "terminal": "#{state&.terminal}"
            }
          }.to_json,
        :headers => {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@bearer_token}"
        }, :verify => false)
        puts "#{response}"
    end

    def import_order_notes order
      response = HTTParty.get(@base_uri+"orders/#{order.shopify_order_id}/", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
      if response.code == 200 && response.present?
        order.update(order_notes: response["extension_attributes"]["swissup_checkout_fields"].find { |x| break x['value'] if x['code']=="order_note" }) if (response["extension_attributes"].present? && response["extension_attributes"]["swissup_checkout_fields"].present?)

        puts "#{order.name}"
      end
    end

    def cancel_order_to_m2 order
      response = HTTParty.post(@base_uri+"orders/#{order.shopify_order_id}/cancel", :headers => {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@bearer_token}"
      }, :verify => false)
    end
  end
end