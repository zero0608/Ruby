class Admin::TruckBrokersController < ApplicationController
  def index
    if current_user.user_group.admin_view
      @truck_brokers = TruckBroker.all
    else
      render "dashboard/unauthorized"
    end
  end

  def new
    @truck_broker = TruckBroker.new
  end
  
  def create
    @truck_broker = TruckBroker.new(truck_broker_params)
    if @truck_broker.save
      redirect_to admin_truck_brokers_path, success: "Truck broker created successfully."
    else
      render "new"
    end
  end

  def edit
    @truck_broker = TruckBroker.find_by(id: params[:id])
  end

  def update
    @truck_broker = TruckBroker.find_by(id: params[:id])
    @truck_broker.update(truck_broker_params)
    redirect_to admin_truck_brokers_path
  end

  def destroy
    @truck_broker = TruckBroker.find_by(id: params[:id])
    @truck_broker.destroy
    redirect_to admin_truck_brokers_path
  end

  private

  def truck_broker_params
    params.require(:truck_broker).permit(:name, :country)
  end
end