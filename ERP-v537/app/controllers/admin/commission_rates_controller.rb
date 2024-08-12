class Admin::CommissionRatesController < ApplicationController
  def index
    @employees = Employee.where(exit_date: nil).where.not(sales_permission: nil).order(:first_name)
  end

  def new
    @employee = Employee.find_by(id: params[:employee_id])
    @commission_rate = @employee.commission_rates.new
  end

  def create
    @commission_rate = CommissionRate.new(commission_rate_params)
    if @commission_rate.save
      redirect_to admin_commission_rates_path, success: "Commission rate created successfully."
    else
      render "new"
    end
  end

  def edit
    @commission_rate = CommissionRate.find_by(id: params[:id])
  end

  def update
    @commission_rate = CommissionRate.find_by(id: params[:id])
    if @commission_rate.update(commission_rate_params)
      redirect_to admin_commission_rates_path, success: "Commission rate updated successfully."
    else
      render "edit"
    end
  end

  def destroy
    @commission_rate = CommissionRate.find_by(id: params[:id])
    @commission_rate.destroy
    redirect_to admin_commission_rates_path
  end

  private

  def commission_rate_params
    params.require(:commission_rate).permit(:id, :employee_id, :lower_range, :upper_range, :rate)
  end
end