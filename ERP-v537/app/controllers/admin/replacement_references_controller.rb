class Admin::ReplacementReferencesController < ApplicationController
  def create
    @replacement_reference = ReplacementReference.new()
    @replacement_reference.product_variant_id = params[:replacement_id]
    var = ProductVariant.where(store: current_store).find_by(sku: params[:variant_search])
    @replacement_reference.name = @replacement_reference.product_variant.product_part.name&.parameterize&.upcase + "-" + var.sku&.upcase

    if @replacement_reference.save
      redirect_to edit_replacement_admin_product_variant_path(@replacement_reference.product_variant_id), success: "Reference created successfully."
    else
      redirect_to edit_replacement_admin_product_variant_path(@replacement_reference.product_variant_id), warning: "Reference failed to be created."
    end
  end
  
  def destroy
    @reference = ReplacementReference.find_by(id: params[:id])
    @replacement_id = @reference.product_variant_id
    @reference.destroy
    redirect_to edit_replacement_admin_product_variant_path(@replacement_id)
  end
end