class Admin::DepartmentsController < ApplicationController

  def index
  end

  def new
    if current_user.user_group.hr_cru || current_user.employee.is_director
      @department = Department.new
    else
      render "dashboard/unauthorized"
    end
  end

  def create
    if current_user.user_group.hr_cru || current_user.employee.is_director
      @department = Department.new(department_params)
      if @department.save
        redirect_to admin_department_path(Department.order(:name).first.id), success: "Department created successfully."
      else
        render 'new'
      end
    else
      render "dashboard/unauthorized"
    end
  end

  def show
    if current_user.user_group.hr_view || current_user.employee.is_director
      @department = Department.find(params[:id])
      respond_to do |format|
        format.html
        format.csv do
          response.headers['Content-Disposition'] = "attachment; filename=" + @department.name + ".csv"
        end
      end
    else
      render "dashboard/unauthorized"
    end
  end

  def edit
    if current_user.user_group.hr_cru || current_user.employee.is_director
      @department = Department.find(params[:id])
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    @department = Department.find(params[:id])
    if @department.update(department_params)
      redirect_to admin_department_path(@department.id), success: "Department updated successfully."
    else
      render 'edit'
    end
  end

  def manager
    @department = Department.find(params[:id])
    @employee ||= nil
  end

  def manager_panel
    if current_user.user_group.manager_view || current_user.employee.is_director
      redirect_to manager_admin_department_path(Department.first.id)
    elsif current_user.employee.position.is_manager
      redirect_to manager_admin_department_path(current_user.employee.department.id)
    else
      render "dashboard/unauthorized"
    end
  end

  def leave_request
    if current_user.user_group.manager_cru || current_user.user_group.hr_cru || current_user.employee.is_director || current_user.employee.position.is_manager
      @department = Department.find(params[:id])
    else
      render "dashboard/unauthorized"
    end
  end

  def leave_upcoming
    if current_user.user_group.manager_cru || current_user.user_group.hr_cru || current_user.employee.is_director || current_user.employee.position.is_manager
      @department = Department.find(params[:id])
    else
      render "dashboard/unauthorized"
    end
  end

  def leave_current
    if current_user.user_group.manager_cru || current_user.user_group.hr_cru || current_user.employee.is_director || current_user.employee.position.is_manager
      @department = Department.find(params[:id])
    else
      render "dashboard/unauthorized"
    end
  end

  def leave_history
    if current_user.user_group.manager_cru || current_user.user_group.hr_cru || current_user.employee.is_director || current_user.employee.position.is_manager
      @department = Department.find(params[:id])
    else
      render "dashboard/unauthorized"
    end
  end

  def directory
    if current_user.user_group.overview_view || current_user.employee.is_director
    else
      render "dashboard/unauthorized"
    end
  end

  def expense_request
    if current_user.user_group.hr_view || current_user.employee.is_director
      @expenses = Expense.eager_load(:employee).where(status: ["Pending", nil], employees: { exit_date: nil })
      @expense = Expense.find_by(id: params[:expense_id]) if params[:expense_id].present?
    else
      render "dashboard/unauthorized"
    end
  end

  def expense_history
    if current_user.user_group.hr_view || current_user.employee.is_director
      @expenses = Expense.eager_load(:employee).where(status: ["Approved", "Declined"], employees: { exit_date: nil })
      @expense ||= nil
    else
      render "dashboard/unauthorized"
    end
  end

  def time_off_request
    if current_user.user_group.hr_view || current_user.employee.is_director
      @leaves = Leave.eager_load(:employee).where(status: "Pending", employees: { exit_date: nil })
    else
      render "dashboard/unauthorized"
    end
  end

  def time_off_history
    if current_user.user_group.hr_view || current_user.employee.is_director
      @leaves = Leave.eager_load(:employee).where(status: ["Approved", "Declined"], employees: { exit_date: nil })
    else
      render "dashboard/unauthorized"
    end
  end

  private

  def department_params
    params.require(:department).permit(:name, positions_attributes: [ :id, :department_id, :name, :is_manager ])
  end
end