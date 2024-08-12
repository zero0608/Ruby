class TaskReflex < ApplicationReflex
  def delete
    @task = Task.find_by(id: element.dataset[:task_id])
    @task.destroy
  end

  def update_status
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @task = Task.find_by(id: element.dataset[:task_id])
    @task.update(status: element.dataset[:status])
  end

  def search_user
    id = element.dataset[:task_id]
    @que = element[:value].strip
    @users = User.joins(employee: :department).where("(users.username ILIKE ? OR departments.name ILIKE ?)", "%#{@que}%", "%#{@que}%") if @que.present?

    assigns = {
      query: @que,
      users: @users.uniq
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#user-search-edit-results-" + id, html: render(partial: "search_user", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_user_comment
    id = element.dataset[:task_id]
    @que = element[:value].strip
    @users = User.joins(employee: :department).where("(users.username ILIKE ? OR departments.name ILIKE ?)", "%#{@que}%", "%#{@que}%") if @que.present?

    assigns = {
      query: @que,
      users: @users.uniq
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#user-search-edit-results-comment-" + id, html: render(partial: "search_user", assigns: assigns))
      .push_state()
      .broadcast
  end
  
  def search_task_order
    id = element.dataset[:task_id]
    @que = element[:value].strip
    @orders = Order.where("name ILIKE ?", "%#{@que}%") if @que.present?

    assigns = {
      query: @que,
      orders: @orders.uniq
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#order-search-edit-results-" + id, html: render(partial: "search_order", assigns: assigns))
      .push_state()
      .broadcast
  end
  
  private

  def task_params
	  params.require(:task).permit(:id, :status)
  end
end
