class Admin::ProductsController < ApplicationController
  include Pagy::Backend
  require 'pagy/extras/items'

  protect_from_forgery except: %i[shopify_product_sync,shopify_product_update_sync]
  skip_before_action :authenticate_user!, :only => [:shopify_product_sync,:shopify_product_update_sync]

  before_action :find_product, only: [:edit, :update, :destroy, :show]

  def index
    @pagy, @products = pagy(Product.eager_load(:supplier, :product_variants).references(:supplier).where(store: 'us', m2_original: nil).order(:sku), items_param: :per_page, max_items: 100)
    # @pagy, @products = pagy(Product.eager_load(:supplier, :product_variants).references(:supplier).where("products.store = 'us' AND (products.m2_original IS NULL OR products.sku NOT LIKE ?)", "6%"), items_param: :per_page, max_items: 100)
  end

  def emca_products
    @pagy, @products = pagy(Product.eager_load(:supplier, :product_variants).references(:supplier).where(store: 'canada', m2_original: nil).order(:sku), items_param: :per_page, max_items: 100)
    # @pagy, @products = pagy(Product.eager_load(:supplier, :product_variants).references(:supplier).where("products.store = 'canada' AND (products.m2_original IS NULL OR products.sku NOT LIKE ?)", "6%"), items_param: :per_page, max_items: 100)
  end

  def new
    @product = Product.new
    @m2_product = Product.find(params[:m2_product_id]) if params[:m2_product_id].present?
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_products_path
    else
      render 'new'
    end
  end

  def edit;end

  def update
    if @product.update(product_params)
      # Magento::UpdateOrder.new(@product.store).update_quantity("#{@product.sku}", "#{@product.quantity}", "#{@product.shopify_product_id}")
      @product.product_variants.update_all(category_id: @product&.category_id, subcategory_id: @product&.subcategory_id, supplier_id: @product&.supplier_id,factory: @product&.factory&.name, oversized: @product&.oversized)

      if @product.m2_product_id.present?
        Product.find_by(id: @product.m2_product_id).update(sku: params[:m2_product_sku])
      end

      redirect_to edit_admin_product_path(@product.id)
    else
      redirect_to edit_admin_product_path(@product.id)
    end
  end

  def destroy
    Product.find(params[:id]).destroy
    redirect_to admin_products_path
  end

  def pdf
    @products = Product.eager_load(:supplier, :category, :subcategory, :carton_details).where(store: current_store, m2_original: nil)
  end

  def inventory
    # @pagy, @variants = pagy(ProductVariant.eager_load(:product, :purchase_items).joins(:product).where("(products.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", current_store, "%#{"warranty"}%", "WGS001", "HLD001", "HFE001").order(title: :asc), items_param: :per_page, max_items: 100)
    @pagy, @variants = pagy(ProductVariant.eager_load(:purchase_items).where("(product_variants.store LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", 'us', "%#{"warranty"}%", "WGS001", "HLD001", "HFE001").order(title: :asc), items_param: :per_page, max_items: 100)
    # @product_variant = ProductVariant.find_by(slug: params[:slug])
  end

  def emca_inventory
    # @pagy, @variants = pagy(ProductVariant.eager_load(:product, :purchase_items).joins(:product).where("(products.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", current_store, "%#{"warranty"}%", "WGS001", "HLD001", "HFE001").order(title: :asc), items_param: :per_page, max_items: 100)
    @pagy, @variants = pagy(ProductVariant.eager_load(:purchase_items).where("(product_variants.store LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", 'canada', "%#{"warranty"}%", "WGS001", "HLD001", "HFE001").order(title: :asc), items_param: :per_page, max_items: 100)
    # @product_variant = ProductVariant.find_by(slug: params[:slug])
  end

  def shopify_product_sync
    print "prod webhook.. started..."
    data = request.body.read
    @store = store_country
    return head 403 unless webhook_verified?
    ProductUpdateWorker.perform_async(JSON.parse(request.body.read).fetch("sku"), @store) if (JSON.parse(data).key?("sku")) && !(ProductVariant.find_by(sku: JSON.parse(request.body.read).fetch("sku"), store: @store).present?) && @store.present?
    render json: {status: 200, time: "#{Time.now.getutc}"}
    print "prod webhook.. stopped..."
  end
  
  def shopify_product_update_sync
    print "prod webhook.. started..."
    data = request.body.read
    @store = store_country
    return head 403 unless webhook_verified?
    SkuUpdateWorker.perform_async(JSON.parse(request.body.read).fetch("sku"), @store) if (JSON.parse(data).key?("sku")) && (ProductVariant.find_by(sku: JSON.parse(request.body.read).fetch("sku"), store: @store).present?) && @store.present?
    render json: {status: 200, time: "#{Time.now.getutc}"}
    print "prod webhook.. stopped..."
  end

  def show
  end

  def import
    Product.import(params[:file],current_store)
    redirect_to admin_products_path
  end

  def assign
    @product = Product.find(params[:product_id])
    if params[:var_ids].present?
      params[:var_ids].each do |id|
        @variant = ProductVariant.find(id.to_i)
        @variant.update(product_id: @product.id, m2_product_id: @product.m2_product_id)
      end
      redirect_to edit_admin_product_path(@product.id)
    end
  end

  def update_quantity
    Product.where.missing(:carton_details).each do |p|
      p.carton_details.create(index: 1)
    end

    CartonDetail.all.each do |carton_detail|
      carton_detail.product.product_variants.each do |variant|
        if !(variant.cartons.any? { |c| c.carton_detail_id == carton_detail.id })
          variant.cartons.create(received_quantity: 0, to_do_quantity: 0, carton_detail_id: carton_detail.id)
        end
      end
    end
    redirect_to admin_products_path
  end

  private

  def find_product
    @product = Product.find_by(id: params[:id])
  end

  def product_params
    params.require(:product).permit(:id, :category_id, :subcategory_id, :factory_id,:m2_product_id, :sku, :quantity, :store, :shopify_product_id, :oversized, :title, :body_html, :vendor, :factory, :product_type, :published_at, :created_at, :updated_at, :handle, :template_suffix, :status, :published_scope, :admin_graphql_api_id, :tags, :shopify_tag_list, :supplier_id, carton_details_attributes: [:id, :product_id, :length, :width, :height, :weight, :index, :_destroy])
  end

end
