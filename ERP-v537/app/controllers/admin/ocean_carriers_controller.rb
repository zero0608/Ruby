class Admin::OceanCarriersController < ApplicationController
  def index
    @ocean_carriers = OceanCarrier.set_store(current_store).all
  end

  def new
    @ocean_carrier =  OceanCarrier.new
  end

  def create
    @ocean_carrier =  OceanCarrier.new ocean_carrier_params
    if @ocean_carrier.save
      redirect_to admin_ocean_carriers_path
    else
      render 'new'
    end
  end

  def edit
    @ocean_carrier =  OceanCarrier.find(params[:id])
  end

  def update
    @ocean_carrier =  OceanCarrier.find(params[:id])
    if @ocean_carrier.update(ocean_carrier_params)
      redirect_to admin_ocean_carriers_path
    else
      render 'edit'
    end
  end

  def show
  end

  private

  def ocean_carrier_params
    params.require(:ocean_carrier).permit(:name, :id, :store)
  end
end
