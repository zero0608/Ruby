class Admin::StateDaysController < ApplicationController
  def index
    @state_days = StateDay.all
  end

  def new
    @state_day = StateDay.new
  end

  def create
    @state_day = StateDay.new state_days_params
    if @state_day.save
      redirect_to admin_state_days_path
    else
      render 'new'
    end
  end

  def edit
    @state_day = StateDay.find(params[:id])
  end

  def update
    @state_day = StateDay.find(params[:id])
    if @state_day.update(state_days_params)
      redirect_to admin_state_days_path
    else
      render "edit"
    end
  end

  def destroy
    StateDay.find(params[:id]).destroy
    redirect_to admin_state_days_path
  end

  private

  def state_days_params
    params.require(:state_day).permit(:name, :state, :region, :start_days, :end_days)
  end
end
