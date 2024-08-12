class DepartmentReflex < ApplicationReflex
  def build_position
    @department = Department.find_by(id: element.dataset[:department_id])
    @position = @department.positions.create
    @position.update(department_id: @department.id)
  end

  def destroy_position
    @position = Position.find_by(id: element.dataset[:position_id])
    if @position.present?
      if @position.employee.any?
        flash[:alert] = "An employee is still assigned to this position"
      else
        @position.destroy
      end
    end
  end

  def update
    @department = Department.find_by(id: element.dataset[:department_id])
    @department.update(department_params)
  end

  def approve_leave
    @leave = Leave.find_by(id: element.dataset[:leave_id])
    @leave.update(status: "Approved", approval_date: Date.today, approved_by_id: element.dataset[:user_id])
    case @leave.leave_type
      when "PTO"
        @leave.employee.update(pto_remain: @leave.employee.pto_remain - @leave.duration)
      when "Personal"
        @leave.employee.update(personal_remain: @leave.employee.personal_remain - @leave.duration)
      when "Sick"
        @leave.employee.update(sick_remain: @leave.employee.sick_remain - @leave.duration)
      when "Unpaid"
        @leave.employee.update(unpaid_days: @leave.employee.unpaid_days + @leave.duration)
    end
    if @leave.employee.users.present?
      UserNotification.with(order: "nil", issue: "nil", user: @leave.employee.users.first, container: "nil", content: "leave_update", message: @leave.status).deliver(@leave.employee.users)
    end
  end

  def decline_leave
    @leave = Leave.find_by(id: element.dataset[:leave_id])
    @leave.update(status: "Declined", approval_date: Date.today, approved_by_id: element.dataset[:user_id])
    if @leave.employee.users.present?
      UserNotification.with(order: "nil", issue: "nil", user: @leave.employee.users.first, container: "nil", content: "leave_update", message: @leave.status).deliver(@leave.employee.users)
    end
  end
  
  def show_employee
    @employee = Employee.find_by(id: element.dataset[:employee_id])
  end
  
  private

  def department_params
    params.require(:department).permit(:id, :name, positions_attributes: [ :id, :department_id, :name, :is_manager ])
  end
end