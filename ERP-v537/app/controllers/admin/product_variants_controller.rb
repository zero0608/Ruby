class Admin::ProductVariantsController < ApplicationController
  include Pagy::Backend
  require 'pagy/extras/items'

  before_action :find_product_variant, only: [:show, :edit, :update, :update_arriving]
  before_action :find_product, only: [:update, :destroy, :create, :new]

  def new
    @product_variant = ProductVariant.new
  end

  def create
    @product_variant = @product.product_variants.new(product_variant_params)
    if @product_variant.save
      redirect_to edit_admin_product_path(@product)
    else
      render 'new'
    end 
  end
  
  def show
    if current_user.user_group.inventory_view && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
      @pagy, @histories = pagy(@product_variant.try(:inventory_histories).order(created_at: :desc), items: 10)
    else
      render "dashboard/unauthorized"
    end
  end

  def edit
    if current_user.user_group.inventory_cru && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
      # Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
      # Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    @old_quantity = @product_variant.inventory_quantity
    if @product_variant.update(product_variant_params)
      Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
      Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
      Magento::UpdateOrder.new(@product_variant.store).update_inventory_stock(@product_variant)
      if @product_variant.inventory_quantity != @old_quantity
        @product_variant.inventory_histories.create(adjustment: 0, quantity:  @old_quantity) if !(@product_variant.inventory_histories.present?)
        @product_variant.inventory_histories.create(user_id: current_user.id, event: "ProductVariant updated", adjustment: (@product_variant.inventory_quantity.to_i - @old_quantity.to_i), quantity: @product_variant.inventory_quantity.to_i) if @product_variant.inventory_histories.present?
      end
      @product_variant.product_locations.each do |location|
        if !(location.location_histories.present?)
          LocationHistory.create(product_variant_id: @product_variant.id, product_location_id: location.id, user_id: @current_user.id, event: 'location created', rack: location.rack, level: location.level, bin: location.bin, adjustment: 0, quantity: location.quantity)
        end
      end
      redirect_to admin_product_variant_path(id: @product_variant.id), success: "Product updated successfully."
    else
      redirect_to admin_product_variant_path(id: @product_variant.id), warning: "Product failed to update."
    end
  end

  def destroy
    @product_variant = ProductVariant.find_by(id: params[:id])
    @product = @product_variant.product
    @product_variant.destroy
    if @product.present?
      redirect_to edit_admin_product_path(@product.id)
    else
      redirect_to stock_admin_orders_path
    end
  end

  def update_arriving
    Magento::UpdateOrder.new(@product_variant.store).update_quantity(@product_variant)
    Magento::UpdateOrder.new(@product_variant.store).update_arriving_case_1_3(@product_variant)
    Magento::UpdateOrder.new(@product_variant.store).update_inventory_stock(@product_variant)
    redirect_to admin_product_variant_path(id: @product_variant.id), success: "Product synced successfully."
  end

  def import
    ProductVariant.import(params[:file], current_store)
    redirect_to stock_admin_orders_path
  end

  def import_image
    ProductVariant.import_image(params[:file])
    redirect_to stock_admin_orders_path
  end

  def replacement
    @product_variants = ProductVariant.set_store(current_store).where.not(product_part_id: nil)
  end

  def new_replacement
  end

  def create_replacement
    ProductVariant.create(title: params[:title], sku: (ProductPart.find_by(id: params[:product_part_id]).name.to_s + "-" + params[:title].to_s)&.parameterize&.upcase, product_part_id: params[:product_part_id], old_inventory_quantity: params[:quantity],inventory_quantity: params[:quantity], store: current_store)
    redirect_to replacement_admin_product_variants_path
  end

  def edit_replacement
    @product_variant = ProductVariant.find_by(id: params[:id])
  end

  def update_replacement
    @product_variant = ProductVariant.find_by(id: params[:id])
    @product_variant.update(title: params[:title], product_part_id: params[:product_part_id], old_inventory_quantity: @product_variant.inventory_quantity, inventory_quantity: params[:quantity])
    redirect_to replacement_admin_product_variants_path
  end

  def delete_replacement
    ProductVariant.find_by(id: params[:id]).destroy
    redirect_to replacement_admin_product_variants_path
  end

  def warehouse_variant
    @warehouse_variant = WarehouseVariant.find(params[:warehouse_variant_id])
    @product_variant = @warehouse_variant.product_variant
  end

  private

  def find_product_variant
    @product_variant = ProductVariant.find_by(id: params[:id])
  end

  def find_product
    @product = Product.find_by(id: params[:product_id]) if params[:product_id].present?
  end

  def product_variant_params
    params.require(:product_variant).permit(:stock, :unit_cost, :category_id,:shopify_variant_id, :title, :supplier_price, :price, :sku, :position, :inventory_policy, :compare_at_price, :fulfillment_service, :inventory_management, :option1, :option2, :option3, :taxable, :barcode, :grams, :weight, :weight_unit, :inventory_item_id, :inventory_quantity, :old_inventory_quantity, :requires_shipping, :admin_graphql_api_id, :product_id, :image_id, :inventory_limit, :variant_fulfillable, :supplier_id, :carton, :height, :width, :length, :product_category, :max_limit, :image_url, product_locations_attributes: [:id, :rack, :level, :bin, :quantity, :store])
  end
end
