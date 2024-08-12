# frozen_string_literal: true

class CommentReflex < ApplicationReflex

  def submit
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    if params[:controller] == "admin/issues"
      @issue = Issue.find(params[:id])
      @comment = @issue.comments.new comment_params
      @comment.user_id = element.dataset[:user_id]
      @comment.save
      if @comment.tag_user_id.present?
        @comment.tag_user_id.split(",").uniq.each do | id |
          UserNotification.with(order: 'nil', issue: @issue, user: User.find_by(id: @comment.user_id), content: 'tag_issue', message: @comment.description, container: 'nil').deliver(User.find_by(id: id))
        end
      end

      assigns = {
        issue: @issue,
        comments: @comment,
        user: @user
      }

      cable_ready.
      inner_html(
        selector: "#issue-comment-results", html: render(partial: "admin/comments/form",assigns: assigns, f: @issue)).push_state()
      .broadcast

    elsif params[:controller] == "admin/finance_containers"
      @container = Container.find(element.dataset[:container_id])
      @comment = @container.comments.new comment_params
      @comment.user_id = element.dataset[:user_id]
      @comment.save

      assigns = {
        container: @container,
        comments: @comment,
        user: @user
      }

      cable_ready.
      inner_html(
        selector: "#container-comment-results", html: render(partial: "admin/comments/containers",assigns: assigns, f: @container)).push_state()
      .broadcast

    elsif params[:controller] == "admin/purchases"
      @purchase = Purchase.find(params[:id])
      @comment = @purchase.comments.new comment_params
      @comment.user_id = element.dataset[:user_id]
      @comment.save
      if @comment.tag_user_id.present?
        @comment.tag_user_id.split(",").uniq.each do | id |
          UserNotification.with(order: 'nil', issue: 'nil', purchase: @purchase, user: User.find_by(id: @comment.user_id), content: 'tag_purchase', message: @comment.description, container: 'nil').deliver(User.find_by(id: id))
        end
      end

      assigns = {
        purchase: @purchase,
        comments: @comment,
        user: @user
      }

      cable_ready.
      inner_html(
        selector: "#purchase-comment-results", html: render(partial: "admin/comments/purchase",assigns: assigns, f: @purchase)).push_state()
      .broadcast

    elsif params[:controller] == "admin/tasks"
      @task = Task.find(element.dataset[:task_id])
      @comment = @task.comments.new comment_params
      @comment.user_id = element.dataset[:user_id]
      @comment.save
      @task.tag_user_id.split(",").uniq.reject { |s| s.to_s.empty? }.each do | id |
        UserNotification.with(order: "nil", issue: "nil", user: User.find_by(id: @comment.user_id), content: "update_task", message: @task.title, container: "nil").deliver(User.find_by(id: id))
      end

    elsif params[:controller] == "admin/create_whitelists"
      @whitelist_ip = CreateWhitelist.find(params[:id])
      @comment = @whitelist_ip.comments.new comment_params
      @comment.user_id = element.dataset[:user_id]
      @comment.save

      assigns = {
        whitelist_ip: @whitelist_ip,
        comments: @comment,
        user: @user
      }

      cable_ready.
      inner_html(
        selector: "#whitelist-comment-results", html: render(partial: "admin/comments/create_whitelists",assigns: assigns, f: @whitelist_ip)).push_state()
      .broadcast

    elsif params[:controller] == "admin/product_variants"
      @product_variant = ProductVariant.find(params[:id])
      @comment = @product_variant.comments.new comment_params
      @comment.user_id = element.dataset[:user_id]
      @comment.save
      if @comment.tag_user_id.present?
        @comment.tag_user_id.split(",").uniq.each do | id |
          UserNotification.with(order: "nil", issue: "nil", purchase: "nil", user: User.find_by(id: @comment.user_id), content: 'tag_product_variant', message: @comment.description, container: "nil", product_variant: @product_variant.id).deliver(User.find_by(id: id))
        end
      end

      assigns = {
        product_variant: @product_variant,
        comments: @comment,
        user: @user
      }

      cable_ready.
      inner_html(
        selector: "#product-variant-comment-results", html: render(partial: "admin/comments/product_variant",assigns: assigns, f: @product_variant)).push_state()
      .broadcast

    elsif params[:controller] == "admin/returns"
      @return = Return.find(params[:id])
      @comment = @return.comments.new comment_params
      @comment.user_id = element.dataset[:user_id]
      @comment.save
      if @comment.tag_user_id.present?
        @comment.tag_user_id.split(",").uniq.each do | id |
          UserNotification.with(order: @return.order_id, issue: @return.issue_id, purchase: "nil", user: User.find_by(id: @comment.user_id), content: 'tag_return', message: @comment.description, container: "nil", return: @return.id).deliver(User.find_by(id: id))
        end
      end

      assigns = {
        return: @return,
        comments: @comment,
        user: @user
      }

      cable_ready.
      inner_html(
        selector: "#return-comment-results", html: render(partial: "admin/comments/return",assigns: assigns, f: @return)).push_state()
      .broadcast

    else
      @order = Order.find_by(name: params[:name])
      @comment = @order.comments.new comment_params
      @comment.user_id = element.dataset[:user_id]
      @comment.save
      if @comment.tag_user_id.present?
        @comment.tag_user_id.split(",").uniq.each do | id |
          if id.include? "d-"
            department = Department.find_by(id: id[2..-1])
            department.employees.each do |employee|
              employee.users.where(deactivate: [false, nil]).each do |user|
                UserNotification.with(order: @order, issue: "nil", user: User.find_by(id: @comment.user_id), content: "tag_comment", message: @comment.description, container: "nil").deliver(user)
              end
            end
          else
            UserNotification.with(order:  @order, issue: 'nil', user: User.find_by(id: @comment.user_id), content: 'tag_comment', message: @comment.description, container: 'nil').deliver(User.find_by(id: id))
          end
        end
      end

      assigns = {
        order: @order,
        comments: @comment,
        user: @user
      }

      cable_ready.
      inner_html(
        selector: "#comment-results", html: render(partial: "admin/comments/order",assigns: assigns, f: @order)).push_state()
      .broadcast
    end
  end 

  private

  def comment_params
    params.require(:comment).permit(:description, :tag_user_id)
  end

end
