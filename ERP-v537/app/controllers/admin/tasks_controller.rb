class Admin::TasksController < ApplicationController
  def index
    if current_user.user_group.overview_view
      if current_user.employee_id.present?
        @task = Task.new
        @tasks = Task.where("tag_user_id like ?", "%," + current_user.id.to_s + ",%")

        @leave = Leave.new
        @leaves = Leave.where(employee_id: current_user.employee_id).where.not(status: nil)

        @expense = Expense.new

        @holiday = Leave.new
        @holidays = Leave.eager_load(:employee).where(employees: { exit_date: nil }).where(status: ["Approved", nil]).order(duration: :asc)
      end
      
      @announcement_notifications = current_user.notifications.where("params ->> 'content' = 'announcement'").where(clear_at: nil).newest_first
    else
      render "dashboard/unauthorized"
    end
  end

  def create
    ::Audited.store[:current_user] = current_user
    @task = Task.new(task_params)
    @task.owner_id = current_user.id
    @task.status = "to_do"
    if @task.save
      @task.tag_user_id.split(",").uniq.reject { |s| s.to_s.empty? }.each do | id |
        if current_user.id.to_s != id
          UserNotification.with(order: "nil", issue: "nil", user: current_user, content: "create_task", message: @task.description, container: "nil").deliver(User.find_by(id: id))
        end
      end
      redirect_to request.referrer, success: "Task created successfully."
    end
  end

  def update
    ::Audited.store[:current_user] = current_user
    task = Task.find_by(id: task_params[:id])
    task.update(task_params)
    task.tag_user_id.split(",").uniq.reject { |s| s.to_s.empty? }.each do | id |
      if current_user.id.to_s != id
        UserNotification.with(order: "nil", issue: "nil", user: current_user, content: "update_task", message: task.title, container: "nil").deliver(User.find_by(id: id))
      end
    end
    redirect_to admin_tasks_path(task_id: task.id)
  end

  def destroy
    @task = Task.find_by(id: params[:id])
    @task.audits.destroy_all
    Notification.where("params ->> 'task_id' = '?'", @task.id).destroy_all
    @task.destroy
    redirect_to admin_tasks_path
  end
  
  def delete_upload
    attachment = ActiveStorage::Attachment.find_by(id: params[:doc_id])
    attachment.purge if attachment.present?
    redirect_to request.referrer
  end

  private

  def task_params
    params.require(:task).permit(:id, :tag_user_id, :tag_order_id, :owner_id, :due_date, :priority, :title, :description, :status, :reminder_date, files: [])
  end
end