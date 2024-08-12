class Admin::ExpensesController < ApplicationController
  def create
    @expense = Expense.new(expense_params)
    @expense.employee_id = current_user.employee_id
    @expense.status = "Pending"
    if @expense.save
      if @expense.expense_payment_method.company_card?
        @expense.update(status: "Posting", approve_amount: @expense.amount.to_f)
        @posting = ExpensePosting.create(expense_id: @expense.id, store: current_store, status: "posting")
      end
      UserNotification.with(order: "nil", issue: "nil", user: current_user, container: "nil", content: "expense_create").deliver(User.where(deactivate: [false, nil]).joins(:user_group).where(user_groups: {hr_cru: true}))
      redirect_to admin_tasks_path, success: "Expense request created successfully."
    end
  end
  
  def create_claims_expense
    @expense = Expense.new(expense_params)
    @expense.employee_id = current_user.employee_id
    @expense.status = "Posting"
    @expense.save
    @expense.update(claims_expense: true, approve_amount: @expense.amount.to_f)
    ExpensePosting.create(expense_id: @expense.id, store: current_store, status: "posting")
    RepairService.create(issue_id: params[:issue_id], repair_type: params[:repair_service], amount: @expense.amount.to_f, expense_id: @expense.id)
    redirect_to edit_admin_issue_path(params[:issue_id])
  end

  def update
    @expense = Expense.find_by(id: params[:id])
    @expense.update(expense_params)
    redirect_to request.referrer
  end

  def approve
    @expense = Expense.find_by(id: params[:id])
    @expense.update(status: "Approved", approver_id: expense_params[:approver_id], approve_date: Date.today, approve_amount: expense_params[:approve_amount], notes: expense_params[:notes])
    @posting = ExpensePosting.create(expense_id: @expense.id, store: current_store, status: "posting")
    if @expense.employee.users.present?
      UserNotification.with(order: "nil", issue: "nil", user: @expense.employee.users.first , container: "nil", content: "expense_update", message: @expense.status).deliver(@expense.employee.users)
    end
    redirect_to expense_request_admin_departments_path
  end

  def expense_posting
    if params[:posting_id].present?
      @posting = ExpensePosting.find(params[:posting_id])
      if params[:reject].present?
        @posting.expense.update(status: "Pending", approver_id: nil, approve_date: nil, approve_amount: nil)
        @posting.destroy
      else
        @posting.update(expense_posting_params)
      end
      redirect_to expense_posting_admin_expenses_path
    else
      @postings = ExpensePosting.where(status: "posting")
    end
  end

  def expense_record
    if params[:posting_id].present?
      @posting = ExpensePosting.find(params[:posting_id])
      @posting.update(status: "posting")
      redirect_to expense_record_admin_expenses_path
    else
      @postings = ExpensePosting.where(status: "record").where("expense_postings.created_at > ?", Date.today - 13.months)
    end
  end

  private

  def expense_params
    params.require(:expense).permit(:id, :employee_id, :category, :expense_date, :amount, :status, :comment, :notes, :expense_type_id, :expense_category_id, :expense_subcategory_id, :expense_payment_method_id, :gst, :pst, :tips, :store, :approver_id, :approve_date, :approve_amount, files: [])
  end

  def expense_posting_params
    params.require(:expense_posting).permit(:status, :reason)
  end
end