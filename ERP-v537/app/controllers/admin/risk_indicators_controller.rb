class Admin::RiskIndicatorsController < ApplicationController
  def index
    @risk_indicators = RiskIndicator.all
  end

  def new
    @risk_indicator = RiskIndicator.new
  end

  def create
    @risk_indicator = RiskIndicator.create(risk_indicator_params)
    redirect_to admin_risk_indicators_path
  end

  def edit
    @risk_indicator = RiskIndicator.find(params[:id])
  end

  def update
    @risk_indicator = RiskIndicator.find(params[:id])
    @risk_indicator.update(risk_indicator_params)
    redirect_to admin_risk_indicators_path
  end

  def destroy
    @risk_indicator = RiskIndicator.find(params[:id])
    @risk_indicator.destroy
    redirect_to admin_risk_indicators_path
  end

  private
  
  def risk_indicator_params
    params.require(:risk_indicator).permit(:risk_type, :assigned_status)
  end
end
