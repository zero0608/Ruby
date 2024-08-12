class ExpenseReflex < ApplicationReflex
  def update
    @expense = Expense.find_by(id: element.dataset[:expense_id])
    @expense.update(expense_params)
  end

  def approve_expense
    @expense = Expense.find_by(id: element.dataset[:expense_id])
    @expense.update(status: "Approved", approver_id: element.dataset[:approver_id], approve_date: Date.today, approve_amount: expense_params[:approve_amount])
    if @expense.employee.users.present?
      UserNotification.with(order: "nil", issue: "nil", user: @expense.employee.users.first, container: "nil", content: "expense_update", message: @expense.status).deliver(@expense.employee.users)
    end
  end

  def decline_expense
    @expense = Expense.find_by(id: element.dataset[:expense_id])
    @expense.update(status: "Declined")
    if @expense.employee.users.present?
      UserNotification.with(order: "nil", issue: "nil", user: @expense.employee.users.first, container: "nil", content: "expense_update", message: @expense.status).deliver(@expense.employee.users)
    end
  end
  
  def show_expense
    @expense = Expense.find_by(id: element.dataset[:expense_id])
  end
  

  private

  def expense_params
    params.require(:expense).permit(:id, :notes, :approve_amount)
  end

end