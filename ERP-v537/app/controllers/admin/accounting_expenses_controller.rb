class Admin::AccountingExpensesController < ApplicationController

  def index
    @expenses = AccountingExpense.set_store(current_store).all
  end

  def new
    @account_expense = AccountingExpense.new
  end

  def create
    @account_expense = AccountingExpense.new accounting_expense_params
    if @account_expense.save
      redirect_to admin_accounting_expenses_path
    else
      render 'new'
    end
  end

  def accounting
    @expense_types = ExpenseType.where(store: current_store)
  end

  def expense_page
  end

  def create_type
    @expense_type = ExpenseType.new
    if params[:expense_type].present?
      ExpenseType.create(expense_type_params)
      redirect_to accounting_admin_accounting_expenses_path
    else
      render "create_type"
    end
  end

  def edit_type
    @expense_type = ExpenseType.find_by(id: params[:id])
  end

  private
  
  def expense_type_params
    params.require(:expense_type).permit(:title, :id, :store, expense_categories_attributes: [:id, :title, expense_subcategories_attributes: [:id, :title, expense_payment_relations_attributes: [:id, :expense_payment_method_id]]])
  end

  def accounting_expense_params
    params.require(:accounting_expense).permit(:expense_type_id, :expense_category_id, :expense_subcategory_id, :expense_payment_method_id, :gst, :pst, :store)
  end
end
