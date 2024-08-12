# frozen_string_literal: true

class ProductVariantReflex < ApplicationReflex
  include Pagy::Backend

  def build_location
    @current_user = User.find(element.dataset[:user_id])
    @product_variant = ProductVariant.find_by(id: element.dataset[:product_variant_id])
    @product_location = ProductLocation.create
    ProductVariantLocation.create(product_variant_id: @product_variant.id, product_location_id: @product_location.id)
  end
  
  def delete_carton
    carton = ProductCarton.find_by(id: element.dataset[:id])
    if carton.present?
      carton.destroy
    end
  end
  
  def delete_location
    location = ProductLocation.find_by(id: element.dataset[:id])
    if location.present?
      location.destroy
    end
  end

  def update_carton_value
    @variant = ProductVariant.find_by(id: element.dataset[:variant_id])    
    @product = Product.find_by(id: @variant.product_id) if @variant.product_id.present?
    @variant.update(product_variant_params)
  end
  
  def update
    @variant = ProductVariant.find_by(id: element.dataset[:variant_id])
    @product = Product.find_by(id: @variant.product_id)
    @variant.update(product_variant_params)
    @variants = ProductVariant.joins(:product).where("(products.store ILIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?) and (product_variants.sku NOT LIKE ?)", current_store, "%#{"warranty"}%", "WGS001", "HLD001", "HFE001")

    assigns = {
      variants: @variants
    }

    # uri = URI.parse([request.base_url, request.path].join)
    # uri.query = assigns.except(:orders, :pagy).to_query

    morph :nothing
    
    cable_ready
    .inner_html(selector: "#stock_result", html: render(partial: "stock_result", assigns: assigns))
    .push_state()
    .broadcast
  end
  
  def paginate
    params[:page] = element.dataset[:page].to_i
  end
  
  def search_variant
    params[:query] = element[:value].strip
    @query = params[:query]

    @product_variants = ProductVariant.where("(product_variants.store ILIKE ?) AND ((lower(product_variants.title) ILIKE ?) OR (lower(product_variants.option1) ILIKE ?) OR (lower(product_variants.sku) LIKE ?))", current_store, "%#{@query}%".downcase, "%#{@query}%".downcase, "%#{@query}%".downcase)

    assigns = {
      query: @query,
      product_variants: @product_variants
    }

    morph :nothing

    cable_ready
      .inner_html(selector: "#search-results", html: render(partial: "search_variant", assigns: assigns))
      .push_state()
      .broadcast
  end

  private

  def product_variant_params
	  params.require(:product_variant).permit(:shopify_variant_id, :title, :price, :sku, :position,
      :inventory_policy, :compare_at_price, :fulfillment_service, :inventory_management, :option1,
      :option2, :option3, :taxable, :barcode, :grams,:weight,:weight_unit,:inventory_item_id,
      :inventory_quantity, :old_inventory_quantity, :requires_shipping, :admin_graphql_api_id,
      :product_id, :image_id, :inventory_limit, :variant_fulfillable, :product_category,
      product_locations_attributes: [:id, :rack, :level, :bin, :quantity])
  end

end
