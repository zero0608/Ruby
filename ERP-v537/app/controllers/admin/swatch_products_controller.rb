class Admin::SwatchProductsController < ApplicationController
  def index
		@swatch_products = SwatchProduct.where(store: current_store)
	end

	def new
		@swatch_product = SwatchProduct.new
	end

	def create
		@swatch_product = SwatchProduct.new(swatch_products_params)
		if @swatch_product.save
			redirect_to admin_swatch_products_path
		else
			render 'new'
		end
	end

	def edit
		@swatch_product = SwatchProduct.find(params[:id])
	end

	def update
		@swatch_product = SwatchProduct.find(params[:id])
		if @swatch_product.update(swatch_products_params)
			redirect_to admin_swatch_products_path
		else
			render 'edit'
		end
	end

	private

	def swatch_products_params
		params.require(:swatch_product).permit(:material_list_id, :swatch_sku, :description, :store)
	end
end
