class Admin::CarriersController < ApplicationController
  load_and_authorize_resource
  before_action :find_carrier, only: [:edit, :update, :destroy]

  def index
    if current_user.user_group.admin_view
      @carriers = Carrier.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @carrier = Carrier.new
    @carrier.carrier_contacts.build
  end

  def create
    @carrier = Carrier.new(carrier_params)
    if @carrier.save
      redirect_to admin_carriers_path, success: "Carrier created successfully."
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
    if @carrier.update(carrier_params)
      redirect_to admin_carriers_path, success: "Carrier updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @carrier.destroy
    redirect_to admin_carriers_path
  end

  private

  def find_carrier
    @carrier = Carrier.find_by(id: params[:id])
  end

  def carrier_params
    params.require(:carrier).permit(:name, :country, :tracking_url, :carrierID, :tracking_method, :billing_method, :inactive, :truck_broker_id, carrier_contacts_attributes: [:id, :name, :number, :email, :_destroy])
  end
end
