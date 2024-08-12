class Admin::LeavesController < ApplicationController
  def create
    @leave = Leave.new(leave_params)
    @leave.employee_id = current_user.employee_id
    if @leave.leave_type == "Personal" || @leave.leave_type == "PTO" || @leave.leave_type == "Sick" || @leave.leave_type == "Unpaid"
      
      if @leave.leave_type == "Personal"
        @remain = current_user.employee.personal_remain - current_user.employee.leaves.where(leave_type: "Personal", status: "Pending").sum(:duration)
      elsif @leave.leave_type == "PTO"
        @remain = current_user.employee.pto_remain - current_user.employee.leaves.where(leave_type: "PTO", status: "Pending").sum(:duration)
      elsif @leave.leave_type == "Sick"
        @remain = current_user.employee.sick_remain - current_user.employee.leaves.where(leave_type: "Sick", status: "Pending").sum(:duration)
      end

      if ((@leave.leave_type == "Personal" || @leave.leave_type == "PTO" || @leave.leave_type == "Sick") && @remain >= @leave.duration.to_f) || @leave.leave_type == "Unpaid"
        @leave.status = "Pending"
        if @leave.save
          UserNotification.with(order: "nil", issue: "nil", user: current_user, container: "nil", content: "leave_create", message: @leave.leave_type).deliver(User.where(employee_id: @leave.employee.manager_id))
          redirect_to admin_tasks_path, success: "Leave request created successfully."
        end
      else
        redirect_to admin_tasks_path, alert: "You don't have enough leave balance for this request. Please contact your department manager."
      end
    else
      @leave.save
      redirect_to admin_tasks_path, success: "Event created successfully."
    end
  end

  def update
    ::Audited.store[:current_user] = current_user
    @remain = leave_params[:duration].to_f
    if leave_params[:leave_type] == "Personal"
      @remain = current_user.employee.personal_remain - current_user.employee.leaves.where(leave_type: "Personal", status: "Pending").sum(:duration) + leave_params[:duration].to_f
    elsif leave_params[:leave_type] == "PTO"
      @remain = current_user.employee.pto_remain - current_user.employee.leaves.where(leave_type: "PTO", status: "Pending").sum(:duration) + leave_params[:duration].to_f
    elsif leave_params[:leave_type] == "Sick"
      @remain = current_user.employee.sick_remain - current_user.employee.leaves.where(leave_type: "Sick", status: "Pending").sum(:duration) + leave_params[:duration].to_f
    end

    if ((leave_params[:leave_type] == "Personal" || leave_params[:leave_type] == "PTO" || leave_params[:leave_type] == "Sick") && @remain >= leave_params[:duration].to_f) || leave_params[:leave_type] == "Unpaid"
      @leave = Leave.find_by(id: params[:id])
      if @leave.update(leave_params)
        redirect_to admin_tasks_path, success: "Leave request updated successfully."
      end
    else
      redirect_to admin_tass_path, alert: "You don't have enough leave balance for this request. Please contact your department manager."
    end
  end
  
  def cancel_leave
    leave = Leave.find_by(id: params[:id])
    employee = Employee.find_by(id: leave.employee_id)
    if leave.leave_type == "PTO"
      employee.update(pto_remain: employee.pto_remain + leave.duration)
    elsif leave.leave_type == "Personal"
      employee.update(personal_remain: employee.personal_remain + leave.duration)
    elsif leave.leave_type == "Sick"
      employee.update(sick_remain: employee.sick_remain + leave.duration)
    elsif leave.leave_type == "Unpaid"
      employee.update(unpaid_days: employee.unpaid_days - leave.duration)
    end
    leave.update(status: "Declined")
    redirect_to request.referrer
  end
  
  def update_calendar
    index = 0
    while params[:update_calendar][index.to_s + "-name"].present? && params[:update_calendar][index.to_s + "-date"].present?
      name = params[:update_calendar][index.to_s + "-name"]
      date = params[:update_calendar][index.to_s + "-date"]
      if Leave.where(leave_type: name, start_date: date.to_date).empty?
        Leave.create(employee_id: current_user.employee_id, leave_type: name, start_date: date.to_date, end_date: date.to_date)
      end
      index += 1
    end

    if params[:update_calendar][:birthday] == "1"
      Employee.where(exit_date: nil).where.not(dob: nil).each do |employee|
        type = employee.first_name + "'s Birthday"
        date = Date.new(Date.today.year, employee.dob.month, employee.dob.day)
        if Leave.where(leave_type: type, start_date: date).empty?
          Leave.create(employee_id: employee.id, leave_type: type, start_date: date, end_date: date)
        end
      end
    end
    
    if params[:update_calendar][:pto] == "1"
      Employee.where(exit_date: nil).each do |employee|
        if employee.pto_remain >= 5
          employee.update(pto_remain: employee.pto_days.to_f + 5)
        else
          employee.update(pto_remain: employee.pto_days.to_f + employee.pto_remain.to_f)
        end
        employee.update(personal_remain: employee.personal_days.to_f)
        employee.update(sick_remain: employee.sick_days.to_f)
      end
    end
    redirect_to admin_tasks_path, success: "Calendar updated."
  end

  private

  def leave_params
    params.require(:leave).permit(:id, :employee_id, :leave_type, :start_date, :end_date, :duration)
  end
end