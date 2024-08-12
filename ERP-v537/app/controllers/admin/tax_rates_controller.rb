class Admin::TaxRatesController < ApplicationController
  load_and_authorize_resource

  def index
    if current_user.user_group.admin_view
      @tax_rates = TaxRate.where(store: current_store)
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @tax_rate = TaxRate.new
  end

  def create
    @tax_rate = TaxRate.new(tax_rate_params)
    if @tax_rate.save
      redirect_to admin_tax_rates_path, success: "Store created successfully."
    else
      render 'new'
    end
  end

  def edit
    if current_user.user_group.admin_cru
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    if @tax_rate.update(tax_rate_params)
      redirect_to admin_tax_rates_path, success: "Store updated successfully."
    else
      render "new"
    end
  end

  def warehouse_deliveries
    @in_stocks = InstockWarehouseTable.all
    @pre_orders = PreorderWarehouseTable.all
    @transfer_pre_orders = PreorderFromAnotherWarehouseTable.all
    @transfer_tables = TransferTable.all
    @mtos = MtoWarehouseTable.all
    @wgds = WgdWarehouseTable.all
  end

  def destroy
    @tax_rate.destroy
    redirect_to admin_tax_rates_path
  end

  def zip_code_page
    @codes = StateZipCode.all
  end

  private

  def tax_rate_params
    params.require(:tax_rate).permit(:state, :combined_rate, :store, :warehouse_id, :to_zip_code, :from_zip_code)
  end
end
