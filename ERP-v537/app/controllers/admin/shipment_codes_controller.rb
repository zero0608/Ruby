class Admin::ShipmentCodesController < ApplicationController
  def index
    @shipment_codes = ShipmentCode.all
  end

  def new
    @shipment_code = ShipmentCode.new
    if params[:variant_id].present?
      @product_variant = ProductVariant.find(params[:variant_id])
      @shipment_code = ShipmentCode.new(sku_for_discount: @product_variant.sku)
    end
  end

  def create
    @shipment_code = ShipmentCode.new(shipment_code_params)
    if @shipment_code.save
      redirect_to edit_admin_product_variant_path(params[:variant_id])
    else
      render :new
    end
  end

  def edit
    @shipment_code = ShipmentCode.find(params[:id])
    @product_variant = ProductVariant.find(params[:variant_id]) if params[:variant_id].present?
  end

  def update
    @shipment_code = ShipmentCode.find(params[:id])
    if @shipment_code.update(shipment_code_params)
      redirect_to edit_admin_product_variant_path(params[:variant_id])
    else
      render :edit
    end
  end

  def destroy
    ShipmentCode.find(params[:id]).destroy
    redirect_to admin_shipment_codes_path
  end

  private

  def shipment_code_params
    params.require(:shipment_code).permit(:sku_for_discount, :description)
  end
end
