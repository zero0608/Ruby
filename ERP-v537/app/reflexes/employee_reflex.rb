class EmployeeReflex < ApplicationReflex
  def update
    @employee = Employee.find_by(id: element.dataset[:employee_id])
    @employee.update(employee_params)
  end

  private
  def employee_params
    params.require(:employee).permit(:id, checklists_attributes: [ :id, :description, :is_checked, group_members_attributes: [ :id,
      :description, :is_checked ]])
  end
end