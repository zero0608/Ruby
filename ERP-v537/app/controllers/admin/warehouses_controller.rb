class Admin::WarehousesController < ApplicationController
  include Pagy::Backend

  protect_from_forgery except: %i[sync_warehouse_information all_warehouse_data]
  skip_before_action :authenticate_user!,
                      only: %i[sync_warehouse_information all_warehouse_data]
  def index
    @warehouses = Warehouse.all
    UserGroup.all.each do |g|
      unless g.warehouse_permissions.present?
        Warehouse.all.each do |warehouse|
          g.warehouse_permissions.create(warehouse_id: warehouse.id)
        end
      end
    end
  end

  def new
    @warehouse = Warehouse.new
    @warehouse.build_warehouse_address
  end

  def create
    @warehouse = Warehouse.new(warehouse_params)
    if @warehouse.save
      @warehouse.update(store_address_id: StoreAddress.find_by(store: @warehouse.store).id)
      UserGroup.all.each do |group|
        @warehouse.warehouse_permissions.create(user_group_id: group.id)
      end
      redirect_to admin_warehouses_path, success: "warehouse created successfully."
    else
      render 'new'
    end
  end

  def edit
    if current_user.user_group.admin_cru
      @warehouse = Warehouse.find(params[:id])
      @warehouse.build_warehouse_address unless @warehouse.warehouse_address.present?
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    @warehouse = Warehouse.find(params[:id])
    if @warehouse.update(warehouse_params)
      @warehouse.update(store_address_id: StoreAddress.find_by(store: @warehouse.store).id)
      redirect_to admin_warehouses_path, success: "warehouse updated successfully."
    else
      render 'edit'
    end
  end

  def add_user
    @warehouse = Warehouse.find(params[:id])
  end

  def search_sku
    render :layout => "warehouse"
  end

  def search_admin_sku
    @product_variants = ProductVariant.where("(product_variants.title ILIKE ?) OR (lower(product_variants.sku) ILIKE ?)","%#{params[:search]}%","%#{params[:search]}%").where(store: @current_user.warehouse.store) if params[:search]
    render :layout => "warehouse"
  end

  def search_location 
    render :layout => "warehouse"
  end

  def search_location_results
    @product_location = ProductLocation.find_by(rack: params[:rack], level: params[:level], bin: params[:bin], store: current_user.warehouse.store)

    if @product_location.nil?
      redirect_to search_location_admin_warehouses_path(search: "search")
    else
      redirect_to show_location_admin_warehouses_path(location_id: @product_location.id)
    end
  end

  def outstanding
    @container_items = PurchaseItem.where.not(order_id: nil).eager_load(:containers).where(containers: { store: current_user.warehouse.store, status: [:en_route, :container_ready] })

    @product_variants = ProductVariant.where(store: current_user.warehouse.store).where("length(sku) > 2").where.not(product_id: nil)

    @to_be_reserved = LineItem.where("length(sku) > 2").eager_load(:order).where(status: :ready, orders: { store: current_user.warehouse.store, order_type: "Unfulfillable" }).where.not(orders: { status: "cancel_confirmed" }).joins(:shipping_detail).where(shipping_details: { status: "not_ready" }).where("(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)","%#{"Get Your Swatches"}%", "%#{"warranty"}%","WGS001", "HLD001", "HFE001", "Handling Fee", "Cotton", "Wheat", "velvet", "Weave", "Performance").where.not(quantity: [nil, "0"]).where(reserve: false)

    render :layout => "warehouse"
  end

  def outstanding_put
    @product_variants = ProductVariant.where(store: current_user.warehouse.store).where("length(sku) > 2").where.not(product_id: nil).where("product_variants.received_quantity > 0")
    render :layout => "warehouse"
  end

  def outstanding_pick
    @product_variants = ProductVariant.where(store: current_user.warehouse.store).where("length(sku) > 2").where.not(product_id: nil).where("product_variants.to_do_quantity > 0")
    @pagy, @product_picks = pagy(@product_variants, items_param: :per_page, max_items: 100)
    render :layout => "warehouse"
  end

  def outstanding_reserve
    @line_items = LineItem.where("length(sku) > 2").eager_load(:order).where(status: :ready, orders: { store: current_user.warehouse.store, order_type: "Unfulfillable" }).where.not(orders: { status: "cancel_confirmed" }).joins(:shipping_detail).where(shipping_details: { status: "not_ready" }).where("length(sku) > 2").where("(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)","%Get Your Swatches%", "%warranty%","WGS001", "HLD001", "HFE001", "Handling Fee", "Cotton", "Wheat", "velvet", "Weave", "Performance").where.not(quantity: [nil, "0"]).where(reserve: false)
    @pagy, @reserved = pagy(@line_items, items_param: :per_page, max_items: 100)
    render :layout => "warehouse"
  end

  def outstanding_preorder
    @container_items = PurchaseItem.where.not(order_id: nil).eager_load(:containers).where(containers: { store: current_user.warehouse.store, status: [:en_route, :container_ready] })
    @pagy, @preorders = pagy(@container_items, items_param: :per_page, max_items: 100)
    render :layout => "warehouse"
  end

  def container_orders
    @product_variants = ProductVariant.where(store: current_user.warehouse.store).where("length(sku) > 2").where.not(product_id: nil)
    @pagy, @product_puts = pagy(@product_variants, items_param: :per_page, max_items: 100)
    render :layout => "warehouse"
  end

  def container_quantity_pick
    @container_order = ContainerOrder.find(params[:container_order_id])
    @variant = ProductVariant.find(params[:variant_id])
    @variant.update(container_count: (@variant.container_count.to_i - @container_order.quantity.to_i))
    @container_order.line_item.update(reserve: true)

    LocationHistory.create(product_variant_id: @variant.id, user_id: @current_user.id, event: "picked from container order #{@container_order.name}", adjustment: "-#{@container_order.quantity.to_i}", quantity: @variant.container_count.to_i)
    @container_order.destroy
    redirect_to container_orders_admin_warehouses_path

  end

  def quantity_put
    product_location = ProductLocation.find_by(rack: params[:rack], level: params[:level], bin: params[:bin], store: current_user.warehouse.store) || ProductLocation.create(rack: params[:rack], level: params[:level], bin: params[:bin], store: current_user.warehouse.store)

    carton_location = CartonLocation.find_by(carton_id: params[:carton_id], product_location_id: product_location.id) || CartonLocation.create(carton_id: params[:carton_id], product_location_id: product_location.id, quantity: 0)

    carton_location.update(quantity: carton_location.quantity.to_i + params[:quantity].to_i)
    carton_location.carton.update(received_quantity: carton_location.carton.received_quantity.to_i - params[:quantity].to_i)
    carton_location.carton.product_variant.update(received_quantity: carton_location.carton.product_variant.cartons.maximum(:received_quantity))
    LocationHistory.create(product_variant_id: carton_location.carton.product_variant.id, product_location_id: product_location.id, user_id: @current_user.id, event: "put (" + carton_location.carton.carton_detail.index.to_s + " / " + carton_location.carton.carton_detail.product.carton_details.maximum(:index).to_s + ") quantity", adjustment: "#{params[:quantity].to_i}", quantity: carton_location.quantity)
    redirect_to variant_put_admin_warehouses_path(variant_id: carton_location.carton.product_variant.id)
  end

  def quantity_admin_put
    if params[:loc_id].present?
      if params[:carton_id].present?
        @carton_location = CartonLocation.find(params[:loc_id].keys.first.to_i)
        @carton = Carton.find(params[:carton_id].keys.first.to_i)
        @carton_location.update(quantity: (@carton_location.quantity + params[:loc_id].values.first.to_i))
        LocationHistory.create(product_variant_id: @carton.product_variant_id, product_location_id: @carton_location.product_location_id, user_id: @current_user.id, event: "admin put (" + @carton.carton_detail.index.to_s + " / " + @carton.carton_detail.product.carton_details.maximum(:index).to_s + ") quantity", adjustment: params[:loc_id].values.first.to_i, quantity: @carton_location.quantity)
      else
        @variant_location = ProductVariantLocation.find(params[:loc_id].keys.first.to_i)
        @product_variant = ProductVariant.find(params[:variant_id].keys.first.to_i)
        @variant_location.update(product_quantity: (@variant_location.product_quantity + params[:loc_id].values.first.to_i))
        LocationHistory.create(product_variant_id: @product_variant.id, product_location_id: @variant_location.product_location_id, user_id: @current_user.id, event: 'admin put quantity', adjustment: params[:loc_id].values.first.to_i, quantity: @variant_location.product_quantity)
      end
      redirect_to request.referrer
    end
  end

  def quantity_pick
    @carton_location = CartonLocation.find_by(id: params[:carton_location_id])
    @carton_location.update(quantity: @carton_location.quantity.to_i - params[:quantity].to_i)
    @carton_location.carton.update(to_do_quantity: @carton_location.carton.to_do_quantity.to_i - params[:quantity].to_i)
    @carton_location.carton.product_variant.update(to_do_quantity: @carton_location.carton.product_variant.cartons.maximum(:to_do_quantity))
    LocationHistory.create(product_variant_id: @carton_location.carton.product_variant.id, product_location_id: @carton_location.product_location.id, user_id: @current_user.id, event: "pick (" + @carton_location.carton.carton_detail.index.to_s + " / " + @carton_location.carton.carton_detail.product.carton_details.maximum(:index).to_s + ") quantity", adjustment: "-#{params[:quantity].to_i}", quantity: @carton_location.quantity)
    if @carton_location.quantity <= 0
      @carton_location.destroy
    end
    redirect_to variant_pick_admin_warehouses_path(variant_id: @carton_location.carton.product_variant.id)
  end

  def reserve_pick
    @carton_location = CartonLocation.find_by(id: params[:carton_location_id])
    @carton_location.update(quantity: @carton_location.quantity.to_i - params[:quantity].to_i)
    @carton_location.carton.update(to_do_quantity: @carton_location.carton.to_do_quantity.to_i - params[:quantity].to_i)
    @carton_location.carton.product_variant.update(to_do_quantity: @carton_location.carton.product_variant.cartons.maximum(:to_do_quantity))
    LocationHistory.create(product_variant_id: @carton_location.carton.product_variant.id, product_location_id: @carton_location.product_location.id, user_id: @current_user.id, event: "reserve (" + @carton_location.carton.carton_detail.index.to_s + " / " + @carton_location.carton.carton_detail.product.carton_details.maximum(:index).to_s + ") quantity", adjustment: "-#{params[:quantity].to_i}", quantity: @carton_location.quantity)
    if @carton_location.quantity <= 0
      @carton_location.destroy
    end

    @line_item = LineItem.find_by(id: params[:line_item_id])
    @carton = Carton.find_by(id: params[:carton_id])
    if @line_item.reserve_items.count < 1
      @line_item.variant.cartons.each do |carton|
        @line_item.reserve_items.create(carton_id: carton.id, quantity: 0)
      end
    end

    reserve = @line_item.reserve_items.find_by(carton_id: params[:carton_id])
    reserve.update(quantity: reserve.quantity.to_i + params[:quantity].to_i)

    if @line_item.reserve_items.pluck(:quantity).min.to_i >= @line_item.quantity.to_i
      @line_item.update(reserve: true)
    end

    redirect_to reserve_variant_pick_admin_warehouses_path(line_item_id: @line_item.id)
  end

  def preorder_pick
    @purchase_item = PurchaseItem.find_by(id: params[:item_id])
    @purchase_item.update(preorder_quantity: @purchase_item.preorder_quantity.to_i - params[:quantity].to_i)
    redirect_to outstanding_preorder_admin_warehouses_path
  end

  def quantity_admin_pick
    if params[:loc_id].present?
      if params[:carton_id].present?
        @carton_location = CartonLocation.find(params[:loc_id].keys.first.to_i)
        @carton = Carton.find(params[:carton_id].keys.first.to_i)
        @carton_location.update(quantity: (@carton_location.quantity - params[:loc_id].values.first.to_i))
        LocationHistory.create(product_variant_id: @carton.product_variant_id, product_location_id: @carton_location.product_location_id, user_id: @current_user.id, event: "admin pick (" + @carton.carton_detail.index.to_s + " / " + @carton.carton_detail.product.carton_details.maximum(:index).to_s + ") quantity", adjustment: "-#{params[:loc_id].values.first.to_i}", quantity: @carton_location.quantity)
        if @carton_location.quantity <= 0
          @carton_location.destroy
        end
      else
        @variant_location = ProductVariantLocation.find(params[:loc_id].keys.first.to_i)
        @product_variant = ProductVariant.find(params[:variant_id].keys.first.to_i)
        @variant_location.update(product_quantity: (@variant_location.product_quantity - params[:loc_id].values.first.to_i))
        LocationHistory.create(product_variant_id: @product_variant.id, product_location_id: @variant_location.product_location_id, user_id: @current_user.id, event: 'admin pick quantity', adjustment: "-#{params[:loc_id].values.first.to_i}", quantity: @variant_location.product_quantity)
        if @variant_location.product_quantity <= 0
          @variant_location.destroy
        end
      end
      redirect_to request.referrer
    end
  end

  def received_quantity_pick
    if params[:loc_id].present? && params[:received_quantity].present? && params[:received_quantity] == 'pick'
      if params[:carton_id].present?
        @carton = Carton.find(params[:loc_id].keys.first.to_i)
        @carton.update(received_quantity: (@carton.received_quantity.to_i - params[:loc_id].values.first.to_i))
        @carton.update(to_do_quantity: (@carton.to_do_quantity.to_i - params[:loc_id].values.first.to_i))
        LocationHistory.create(product_variant_id: @carton.product_variant_id, user_id: @current_user.id, event: "pick (" + @carton.carton_detail.index.to_s + " / " + @carton.carton_detail.product.carton_details.maximum(:index).to_s + ") from received", adjustment: "-#{params[:loc_id].values.first.to_i}", quantity: @carton.received_quantity.to_i)
      else
        @variant = ProductVariant.find(params[:loc_id].keys.first.to_i)
        @variant.update(received_quantity: (@variant.received_quantity.to_i - params[:loc_id].values.first.to_i))
        @variant.update(to_do_quantity: (@variant.to_do_quantity.to_i - params[:loc_id].values.first.to_i))
        LocationHistory.create(product_variant_id: @variant.id, user_id: @current_user.id, event: 'pick from received', adjustment: "-#{params[:loc_id].values.first.to_i}", quantity: @variant.received_quantity.to_i)
      end
      redirect_to request.referrer

    elsif params[:loc_id].present? && params[:received_quantity].present? && params[:received_quantity] == 'put'
      @variant = ProductVariant.find(params[:loc_id].keys.first.to_i)
      @variant.update(received_quantity: (@variant.received_quantity.to_i + params[:loc_id].values.first.to_i))
      LocationHistory.create(product_variant_id: @variant.id, user_id: @current_user.id, event: 'Put from received', adjustment: "-#{params[:loc_id].values.first.to_i}", quantity: @variant.received_quantity.to_i)
      redirect_to request.referrer

    else
      @variant = ProductVariant.find(params[:variant_id])
    end
  end

  def to_do_quantity_put
    if params[:loc_id].present? && params[:to_do_quantity].present? && params[:to_do_quantity] == 'pick'
      @variant = ProductVariant.find(params[:loc_id].keys.first.to_i)
      @variant.update(to_do_quantity: (@variant.to_do_quantity.to_i - params[:loc_id].values.first.to_i))
      LocationHistory.create(product_variant_id: @variant.id, user_id: @current_user.id, event: 'pick from received', adjustment: "-#{params[:loc_id].values.first.to_i}", quantity: @variant.to_do_quantity.to_i)
      redirect_to request.referrer

    elsif params[:loc_id].present? && params[:to_do_quantity].present? && params[:to_do_quantity] == 'put'
      @variant = ProductVariant.find(params[:loc_id].keys.first.to_i)
      @variant.update(to_do_quantity: (@variant.to_do_quantity.to_i + params[:loc_id].values.first.to_i))
      LocationHistory.create(product_variant_id: @variant.id, user_id: @current_user.id, event: 'Put from received', adjustment: "-#{params[:loc_id].values.first.to_i}", quantity: @variant.to_do_quantity.to_i)
      redirect_to request.referrer

    else
      @variant = ProductVariant.find(params[:variant_id])
    end
  end

  def create_location
    if params[:rack].present? && params[:level].present? && params[:bin].present? && current_user.present?
      if ProductLocation.where(rack: params[:rack], level: params[:level], bin: params[:bin]).empty?
        @location = ProductLocation.create(rack: params[:rack], level: params[:level], bin: params[:bin], store: current_user.warehouse.store)
      end
      redirect_to aisle_location_admin_warehouses_path(rack: params[:rack])
    else
      render :layout => "warehouse"
    end
  end

  def unassigned_locations
    if params[:location_id].present? && params[:quantity].present?
      @product_location = ProductLocation.find(params[:location_id])

      if params[:product_id].present?
        params[:product_id].keys().each do |id|
          if params[:quantity][id].present?
            product_variant = ProductVariant.find_by(id: params[:product_id][id])
            variant_location = ProductVariantLocation.find_by(product_variant_id: product_variant.id, product_location_id: @product_location.id)
            
            if variant_location.present?
              variant_location.update(product_quantity: variant_location.product_quantity.to_i + params[:quantity][id].to_i)
            else
              ProductVariantLocation.create(product_variant_id: product_variant.id, product_location_id: @product_location.id, product_quantity: params[:quantity][id].to_i)
            end

            LocationHistory.create(product_variant_id: product_variant.id, product_location_id: @product_location.id, user_id: @current_user.id, event: 'location assigned', rack: @product_location.rack, level: @product_location.level, bin: @product_location.bin, adjustment: 0, quantity: params[:quantity][id])
          end
        end
      end

      if params[:carton_id].present?
        params[:carton_id].keys().each do |id|
          if params[:quantity][id].present?
            carton = Carton.find_by(id: params[:carton_id][id])
            carton_location = CartonLocation.find_by(carton_id: carton.id, product_location_id: @product_location.id)

            if carton_location.present?
              carton_location.update(quantity: carton_location.quantity.to_i + params[:quantity][id].to_i)
            else
              CartonLocation.create(carton_id: carton.id, product_location_id: @product_location.id, quantity: params[:quantity][id].to_i)
            end

            LocationHistory.create(product_variant_id: carton.product_variant.id, product_location_id: @product_location.id, user_id: @current_user.id, event: "location assigned (" + carton.carton_detail.index.to_s + " / " + carton.carton_detail.product.carton_details.maximum(:index).to_s + ")", rack: @product_location.rack, level: @product_location.level, bin: @product_location.bin, adjustment: 0, quantity: params[:quantity][id])
          end
        end
      end

      redirect_to show_location_admin_warehouses_path(location_id: @product_location.id)
    else
      @rack_list = ProductLocation.where(store: current_user.warehouse.store).order(:rack).pluck(:rack).uniq
      render :layout => "warehouse"
    end
  end

  def aisle_location
    @product_locations = ProductLocation.where(store: current_user.warehouse.store, rack: params[:rack])
    render :layout => "warehouse"
  end

  def add_product
    @product_location = ProductLocation.find(params[:location_id])
  end

  def show
  end

  def destroy
    Warehouse.find(params[:id]).destroy
    redirect_to admin_warehouses_path
  end

  def assign_location_to_product
    if params[:location_id].present? && params[:product_id].present? && params[:quantity].present?
      if params[:carton_id].present?
        @product_location = ProductLocation.find(params[:location_id])
        @carton = Carton.find(params[:carton_id])
        carton_location = CartonLocation.find_by(carton_id: @carton.id, product_location_id: @product_location.id)
        if carton_location.present?
          carton_location.update(quantity: carton_location.quantity + params[:quantity].to_i)
        else
          CartonLocation.create(carton_id: @carton.id, product_location_id: @product_location.id, quantity: params[:quantity].to_i)
        end

        @carton.update(received_quantity: @carton.received_quantity - params[:quantity].to_i)
        @carton.product_variant.update(received_quantity: @carton.product_variant.cartons.maximum(:received_quantity))

        LocationHistory.create(product_variant_id: @carton.product_variant_id, product_location_id: @product_location.id, user_id: @current_user.id, event: "product (" + @carton.carton_detail.index.to_s + " / " + @carton.carton_detail.product.carton_details.maximum(:index).to_s + ") assigned", rack: @product_location.rack, level: @product_location.level, bin: @product_location.bin, adjustment: 0, quantity: params[:quantity])

      else
        @product_location = ProductLocation.find(params[:location_id])
        @product_variant = ProductVariant.find(params[:product_id])

        variant_location = ProductVariantLocation.find_by(product_variant_id: @product_variant.id, product_location_id: @product_location.id)
        if variant_location.present?
          variant_location.update(product_quantity: variant_location.product_quantity.to_i + params[:quantity].to_i)
        else
          ProductVariantLocation.create(product_variant_id: @product_variant.id, product_location_id: @product_location.id, product_quantity: params[:quantity])
        end

        @product_variant.update(received_quantity: @product_variant.received_quantity.to_i - params[:quantity].to_i)

        LocationHistory.create(product_variant_id: @product_variant.id, product_location_id: @product_location.id, user_id: @current_user.id, event: "product assigned", rack: @product_location.rack, level: @product_location.level, bin: @product_location.bin, adjustment: 0, quantity: params[:quantity])
      end
    end

    redirect_to request.referrer
  end

  def assign_admin_location_to_product
    if params[:location_id].present? && params[:carton_id].present? && params[:quantity].present?

      @product_location = ProductLocation.find(params[:location_id])
      @carton = Carton.find(params[:carton_id])
      
      @carton_location = CartonLocation.find_by(product_location_id: @product_location.id, carton_id: @carton.id)

      if @carton_location.present?
        @carton_location.update(quantity: @carton_location.quantity.to_i + params[:quantity].to_i)
      else
        @carton_location = CartonLocation.create(product_location_id: @product_location.id, carton_id: @carton.id, quantity: params[:quantity].to_i)
      end

      LocationHistory.create(product_variant_id: @carton.product_variant_id, product_location_id: @product_location.id, user_id: @current_user.id, event: "product (" + @carton.carton_detail.index.to_s + " / " + @carton.carton_detail.product.carton_details.maximum(:index).to_s + ") assigned (warehouse admin)", rack: @product_location.rack, level: @product_location.level, bin: @product_location.bin, adjustment: params[:quantity].to_i, quantity: @carton_location.quantity.to_i)
    end

    redirect_to show_location_admin_warehouses_path(location_id: params[:location_id])
  end

  def variant_admin_search
    @product_variant = ProductVariant.find(params[:variant_id])
    if @product_variant.cartons.count > 1
      @active_carton ||= nil
      render :layout => "warehouse"

    elsif @product_variant.cartons.count == 1
      @active_carton = @product_variant.cartons.first
      render :layout => "warehouse"

    else
      redirect_to request.referrer, alert: "Carton needs to be created for this product."
    end
  end

  def variant_search
    @product_variant = ProductVariant.find(params[:variant_id])
    @product_variant_locations = ProductVariantLocation.where(product_variant_id: @product_variant.id)
    if params[:rack].present? && params[:level].present? && params[:bin].present?
      @search_location = ProductLocation.find_by(rack: params[:rack], level: params[:level], bin: params[:bin], store: current_user.warehouse.store)
      if @search_location.nil?
        @not_found = "Location not found."
      end
    end
    @active_carton ||= params[:active_carton_id].present? ? Carton.find_by(id: params[:active_carton_id]) : @product_variant.cartons.order(:id).first
    if @active_carton.present?
      @carton_locations ||= CartonLocation.where(carton_id: @active_carton.id)
      render :layout => "warehouse"
    else
      redirect_to request.referrer, alert: "Carton needs to be created for this product."
    end
  end

  def variant_pick
    @product_variant = ProductVariant.find(params[:variant_id])
    if @product_variant.cartons.count > 1
      render :layout => "warehouse"

    elsif @product_variant.cartons.count == 1
      redirect_to variant_quantity_pick_admin_warehouses_path(carton_id: @product_variant.cartons.first.id)

    else
      redirect_to request.referrer, alert: "Carton needs to be created for this product."
    end
  end

  def variant_quantity_pick
    @carton = Carton.find(params[:carton_id])
    render :layout => "warehouse"
  end

  def variant_put
    @product_variant = ProductVariant.find(params[:variant_id])
    if @product_variant.cartons.count > 1
      render :layout => "warehouse"

    elsif @product_variant.cartons.count == 1
      redirect_to variant_quantity_put_admin_warehouses_path(carton_id: @product_variant.cartons.first.id)

    else
      redirect_to request.referrer, alert: "Carton needs to be created for this product."
    end
  end

  def variant_quantity_put
    @carton = Carton.find(params[:carton_id])
    render :layout => "warehouse"
  end

  def preorder_quantity_pick
    @item = PurchaseItem.find(params[:item_id])
    render :layout => "warehouse"
  end

  def reserve_variant_pick
    @line_item = LineItem.find(params[:line_item_id])
    if @line_item.variant.cartons.count > 1
      render :layout => "warehouse"

    elsif @line_item.variant.cartons.count == 1
      redirect_to reserve_quantity_pick_admin_warehouses_path(carton_id: @line_item.variant.cartons.first.id, line_item_id: @line_item.id)

    else
      redirect_to request.referrer, alert: "Carton needs to be created for this product."
    end
  end

  def reserve_quantity_pick
    @line_item = LineItem.find(params[:line_item_id])
    @carton = Carton.find(params[:carton_id])
    render :layout => "warehouse"
  end

  def show_location
    @product_location = ProductLocation.find(params[:location_id])
    @product_variant_locations = ProductVariantLocation.where(product_location_id: @product_location.id)
    @carton_locations = CartonLocation.where(product_location_id: @product_location.id)
    render :layout => "warehouse"
  end

  def sync_warehouse_information
    warehouse_id = JSON.parse(request.body.read).fetch("warehouse_id")
    if Warehouse.where(id: warehouse_id).present?
      @warehouse = Warehouse.find(warehouse_id)
      render json: @warehouse.to_json(include: {  containers: {}, warehouse_address: {}, tax_rates: { include: { state_zip_codes: {} } }})
    else
      render json: { status: 200, message: "incorrect ID", request: request.url }
      # render json: { status: "incorrect ID"}
    end
  end

  def all_warehouse_data
    print 'warehouse API...'
    store = store_country
    @warehouses = Warehouse.where(store: store)
    render json: @warehouses.joins(:containers).to_json(include: { containers: {}, warehouse_address: {},  warehouse_variants: { include: { product_variant: {} }}, tax_rates: { include: { state_zip_codes: {} } }})
  end

  def admin
    render :layout => "warehouse"
  end

  def new_location
    render :layout => "warehouse"
  end

  def edit_location
    @rack_list = ProductLocation.where(store: current_user.warehouse.store).order(:rack).pluck(:rack).uniq
    render :layout => "warehouse"
  end

  def edit_selected_location
    @product_locations = ProductLocation.where(store: current_user.warehouse.store, rack: params[:rack])
    render :layout => "warehouse"
  end

  def update_location
    params[:location].each do |location|
      ProductLocation.find_by(id: location[0]).update(rack: params[:rack], level: location[1][:level], bin: location[1][:bin])
    end
    redirect_to edit_location_admin_warehouses_path
  end

  def admin_variant
    @carton_location = CartonLocation.find(params[:carton_location_id])
    render :layout => "warehouse"
  end

  def variant_quantity_adjust
    @carton_location = CartonLocation.find_by(id: params[:carton_location_id])
    @product_location = @carton_location.product_location
    if params[:type] == "add"
      @carton_location.update(quantity: @carton_location.quantity.to_i + params[:quantity].to_i)
      LocationHistory.create(product_variant_id: @carton_location.carton.product_variant_id, product_location_id: @product_location.id, user_id: @current_user.id, event: "product (" + @carton_location.carton.carton_detail.index.to_s + " / " + @carton_location.carton.carton_detail.product.carton_details.maximum(:index).to_s + ") added (warehouse admin)", rack: @product_location.rack, level: @product_location.level, bin: @product_location.bin, adjustment: params[:quantity].to_i, quantity: @carton_location.quantity.to_i)

    elsif params[:type] == "deduct"
      @carton_location.update(quantity: @carton_location.quantity.to_i - params[:quantity].to_i)
      LocationHistory.create(product_variant_id: @carton_location.carton.product_variant_id, product_location_id: @product_location.id, user_id: @current_user.id, event: "product (" + @carton_location.carton.carton_detail.index.to_s + " / " + @carton_location.carton.carton_detail.product.carton_details.maximum(:index).to_s + ") deducted (warehouse admin)", rack: @product_location.rack, level: @product_location.level, bin: @product_location.bin, adjustment: -params[:quantity].to_i, quantity: @carton_location.quantity.to_i)
    end

    if @carton_location.quantity <= 0
      @carton_location.destroy
    end
    redirect_to show_location_admin_warehouses_path(location_id: @product_location.id)
  end

  def add_inventory_to_location
    @product_location = ProductLocation.find(params[:location_id])
    render :layout => "warehouse"
  end

  private

  def warehouse_params
    params.require(:warehouse).permit(:name, :store, :code, warehouse_address_attributes: %i[id address1 address2 city country country_code latitude longitude name phone province email zip])
  end
end
