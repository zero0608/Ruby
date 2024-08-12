class Admin::ExpensePaymentMethodsController < ApplicationController
  def index
    @payment_methods = ExpensePaymentMethod.all
  end

  def new
    @payment_method = ExpensePaymentMethod.new
  end

  def create
    @payment_method = ExpensePaymentMethod.new(expense_payment_method_params)
    if @payment_method.save
      redirect_to admin_expense_payment_methods_path, success: "Payment method created successfully."
    else
      render "new"
    end
  end

  def edit
    @payment_method = ExpensePaymentMethod.find(params[:id])
  end

  def update
    @payment_method = ExpensePaymentMethod.find(params[:id])
    if @payment_method.update(expense_payment_method_params)
      redirect_to admin_expense_payment_methods_path, success: "Payment method updated successfully."
    else
      render "edit"
    end
  end

  private
  
  def expense_payment_method_params
    params.require(:expense_payment_method).permit(:id, :title, :company_card, :deactivate)
  end 
end