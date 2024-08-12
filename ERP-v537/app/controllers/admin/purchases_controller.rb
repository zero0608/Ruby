class Admin::PurchasesController < ApplicationController
  include Admin::PurchasesHelper
  include Pagy::Backend
  require 'pagy/extras/items'

  load_and_authorize_resource
  before_action :find_purchase, only: [:edit, :update, :show, :destroy]

  def index
    if current_user.supplier? 
      @purchases = Purchase.eager_load(:purchase_items, :supplier).where(supplier: current_user.supplier).order(created_at: :desc)
      # @pagy, @purchases = pagy(Purchase.eager_load(:purchase_items, :supplier).where(supplier: current_user.supplier).order(created_at: :desc), items_param: :per_page, max_items: 100)
    else
      if current_user.user_group.inventory_view && current_user.user_group.permission_us
        # @purchases = Purchase.eager_load(:purchase_items, :supplier).where(store: current_store).order(created_at: :desc)
        # @purchases = Purchase.eager_load(:purchase_items, :supplier).order(created_at: :desc)
        @pagy, @purchases = pagy(Purchase.eager_load(:purchase_items, :supplier).where(store: 'us').order(created_at: :desc), items_param: :per_page, max_items: 100)
      else
        render "dashboard/unauthorized"
      end
    end
    purchase_del
  end

  def emca_index
    if current_user.user_group.inventory_view && current_user.user_group.permission_ca
      @pagy, @purchases = pagy(Purchase.eager_load(:purchase_items, :supplier).where(store: 'canada').order(created_at: :desc), items_param: :per_page, max_items: 100)
      purchase_del
    else
      render "dashboard/unauthorized"
    end
  end

  def supplier_index
    # @pagy, @purchases = pagy(Purchase.eager_load(:purchase_items, :supplier).where(supplier: current_user.supplier).order(created_at: :desc), items_param: :per_page, max_items: 100)
    @purchases = Purchase.eager_load(:purchase_items, :supplier).where(supplier: current_user.supplier).order(created_at: :desc)
    purchase_del
  end

  def new
    @purchase = Purchase.create
    redirect_to edit_admin_purchase_path(@purchase)
  end

  def create
  end

  def edit
    if current_user.user_group.inventory_cru && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    ::Audited.store[:current_user] = current_user
    if params[:purchase].present? && params[:purchase][:variant_ids].present?
      params[:purchase][:variant_ids].each do |var_id|
        params[:purchase][:quantity].each_pair do |key, value|
          if var_id == key
            if ProductVariant.find(var_id).store == @purchase.store
              @purchase_item = @purchase.purchase_items.build
              @purchase_item.product_variant_id = key
              @purchase_item.quantity = value[0]
              @product = ProductVariant.find(var_id).try(:product)
              if @product.store == 'us'
                @purchase_item.purchase_type = 'TUS'
              elsif @product.store == 'canada'
                @purchase_item.purchase_type = 'TCA'
              end
              @purchase_item.save
            end                  
          end
        end
      end
      redirect_to edit_admin_purchase_path(id: @purchase.id)

    elsif params[:purchase].present? && params[:purchase][:item_ids].present?
      params[:purchase][:item_ids].each do |item_id|
        if @purchase.purchase_items.find_by(line_item_id: item_id).nil?
          @purchase_item = @purchase.purchase_items.build
          @purchase_item.line_item_id = item_id
          @purchase_item.product_variant_id = LineItem.find(item_id).try(:variant).try(:id)
          @purchase_item.quantity = LineItem.find(item_id).try(:quantity)
          @order = LineItem.find(item_id).try(:order)
          @purchase_item.purchase_type = @order.name
          @purchase_item.order_id = @order.id
          @purchase_item.comment_description = LineItem.find(item_id)&.additional_notes
          @purchase_item.save
        end
      end
      redirect_to edit_admin_purchase_path(id: @purchase.id)

    elsif params[:purchase].present? && params[:purchase][:product_ids].present?
      params[:purchase][:product_ids].each do |prod_id|
        params[:purchase][:quantity].each_pair do |key, value|
          if prod_id == key
            @variant = ProductVariant.find(key)
            if (@variant.store == current_store)
              @purchase_item = @purchase.purchase_items.build
              @purchase_item.product_variant_id = key
              @purchase_item.quantity = value[0]
              @variant = ProductVariant.find(key)
              if @variant.product_id.present?
                @product = Product.find(@variant.product_id)
                @purchase_item.product_id = @product.id
              end
              if @variant.store == 'us'
                @purchase_item.purchase_type = 'TUS'
              elsif @variant.store == 'canada'
                @purchase_item.purchase_type = 'TCA'
              end
              @purchase_item.save
            end
          end
        end
      end
      redirect_to edit_admin_purchase_path(id: @purchase.id)

    elsif params[:purchase].present? && params[:purchase_items].present? && params[:purchase_items][:p_ids].present?
      params[:purchase_items][:p_ids].each do |id|
        @purchase_item = PurchaseItem.find(id)
        params[:purchase_items][:cancel_quantity].each_pair do |key, value|
          if (id == key) && !(value[0].to_i > @purchase_item.quantity.to_i)
            @purchase_cancelre = @purchase.purchase_cancelreqs.build
            @purchase_cancelre.purchase_item_id = key
            @purchase_cancelre.cancel_quantity = value[0]
            @purchase_cancelre.save
          end
        end
      end
      redirect_to admin_purchase_path(id: @purchase.id)
    elsif params[:assign_orders].present? && params[:assign_orders][:ids].present?
      @purchase = Purchase.find(params[:id]) if params[:id]
      @purchase_item = PurchaseItem.find(params[:purchase_item_id])
      params[:assign_orders][:ids].each do |id|
        @line_item = LineItem.find(id)
        if @purchase_item.quantity.to_i >= @line_item.quantity.to_i
          @purchase_item.update(quantity: (@purchase_item.quantity.to_i - @line_item.quantity.to_i))
          @line_item.update(status: @purchase_item.status)
          @line_item.update(purchase_id: @purchase_item.purchase_id)
          @line_item.update(purchase_item_id: @purchase_item.id)
        end
        Magento::UpdateOrder.new(@line_item.try(:variant).store).update_arriving_case_1_3(@line_item.try(:variant))
      end
      redirect_to admin_purchase_path(id: @purchase.id)
    end

    @purchase.update(store: current_store)
  end

  def add_item
    @purchase = Purchase.find(params[:format])
    # @line_items = LineItem.joins(:order).where(order_from: nil, status: :not_started, orders: { store: current_store })
    @line_items = LineItem.eager_load(:order).joins(:order).where(order_from: nil, status: :not_started, orders: { store: current_store}).where.not(orders: {order_type: 'SW', status: :cancel_confirmed})
    @line_items = @line_items.where("(line_items.title NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?) and (line_items.sku NOT LIKE ?)","%#{"Get Your Swatches"}%", "%#{"warranty"}%","WGS001", "HLD001", "HFE001", "Handling Fee")
    # @pagy, @line_items = pagy(@line_items, items_param: :per_page, max_items: 100)
  end

  def add_product
    @purchase = Purchase.find(params[:format])
  end

  def add_variant
    @purchase = Purchase.find(params[:format])
    @variants = ProductVariant.where(ProductVariant.arel_table[:inventory_limit].gt(ProductVariant.arel_table[:inventory_quantity]))
    @pagy, @variants = pagy(@variants.joins(:product).where(products: { store: current_store }, variant_fulfillable: true).order(created_at: :desc), items_param: :per_page, max_items: 5)
  end

  def assign_order
    ::Audited.store[:current_user] = current_user
    @purchase = Purchase.find(params[:purchase_id])
    @purchase_item = PurchaseItem.find(params[:purchase_item_id])
  end

  def show
    if (current_user.user_group.inventory_view && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))) || current_user.supplier?
      ::Audited.store[:current_user] = current_user
    else
      render "dashboard/unauthorized"
    end
  end

  def destroy
    ::Audited.store[:current_user] = current_user
    @purchase.purchase_items.destroy_all
    @purchase.destroy
    redirect_to purchase_admin_supplier_path(Supplier.order(:name).first)
  end

  def complete
    @purchases = Purchase.where(supplier_id: current_user.supplier.id)
  end

  def cancel_request
    ::Audited.store[:current_user] = current_user
    if params[:req_id].present? && params[:accept].present?
      @purchase_cancelreq = PurchaseCancelreq.find(params[:req_id])
      @purchase_item = PurchaseItem.find(params[:purchase_item_id])
      if @purchase_item.line_item.present?
        @purchase_item.line_item.update(status: :not_started)
        @purchase_item.line_item_id = nil
        @purchase_item.update(status: :cancelled)
      else
        quantity = @purchase_item.quantity - @purchase_cancelreq.cancel_quantity
        @purchase_item.update(quantity: quantity)
        LineItem.where(purchase_item_id: @purchase_item.id).update_all(purchase_item_id: nil, container_id: nil, status: :not_started)
        @purchase_item.update(status: :cancelled) if (quantity == 0)
      end
      @purchase_cancelreq.update(status: :completed)
      redirect_to cancel_request_admin_purchases_path(req_status: 'ongoing')
    elsif params[:req_id].present? && params[:reject].present?
      @purchase_cancelreq = PurchaseCancelreq.find(params[:req_id])
      @purchase_cancelreq.update(status: :rejected)
      redirect_to cancel_request_admin_purchases_path(req_status: 'ongoing')
    else
      if params[:req_status] == "ongoing"
        @purchase_cancelreqs = PurchaseCancelreq.joins(:purchase).where(status: "ongoing", purchases: { supplier_id: current_user.supplier.id })
      else
        @purchase_cancelreqs = PurchaseCancelreq.joins(:purchase).where(purchases: { supplier_id: current_user.supplier.id }).where.not(status: "ongoing")
      end
    end
  end

  def pre_order
    if current_user.user_group.orders_view && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
      @purchase_items = PurchaseItem.eager_load(:purchase).joins(:purchase).where(purchases: { store: current_store})
      @purchase_items = @purchase_items.eager_load(:containers).joins(:containers).where.not(containers: {status: :arrived}, containers: {arriving_to_dc: nil})
      # @pagy, @purchase_items = pagy(@purchase_items.eager_load(:containers).joins(:containers).where.not(containers: {status: :arrived}, containers: {arriving_to_dc: nil}), items_param: :per_page, max_items: 100)
      # @line_items = LineItem.eager_load(:order).joins(:order).where(order_from: nil, orders: { store: current_store, order_type: 'Unfulfillable' })
    else
      render "dashboard/unauthorized"
    end
  end

  def item_order
    if params[:product_id].present? && params[:variant_id].present? && !(params[:purchase_item_id].nil?)
      @product_variant = ProductVariant.find(params[:variant_id])
      @product = Product.find(params[:product_id])
      @purchase_item = PurchaseItem.find(params[:purchase_item_id])
      @orders = Order.joins(:line_items).where(store: current_store, order_type: 'Unfulfillable', line_items: { sku: @product_variant.sku, order_from: nil })
    end
  end

  private

  def find_purchase
    @purchase = Purchase.find(params[:format]) if params[:format]
    @purchase = Purchase.find(params[:id]) if params[:id]
  end

  def purchase_params
    params.require(:purchase).permit(:id, :store, :order_id, :supplier_id, purchase_items_attributes: [:line_item_id, :quantity, :product_id, :product_variant_id, :purchase_type, :status, :id])
  end

end
