class ChecklistReflex < ApplicationReflex
  def create_checklist
    @employee = Employee.find_by(id: element.dataset[:employee_id])
    @checklist = @employee.checklists.create(checklist_params)
  end
  
  def delete_checklist
    @checklist = Checklist.find_by(id: element.dataset[:id])
    if @checklist.present?
      @checklist.destroy
    end
  end
  

  private
  def checklist_params
    params.require(:checklist).permit(:id, :employee_id, :description, :list_type, :is_checked, :is_default, :list_group_id)
  end
end