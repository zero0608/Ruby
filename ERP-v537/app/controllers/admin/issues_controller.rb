class Admin::IssuesController < ApplicationController
	before_action :find_issue, only: [:edit, :update, :destroy, :delete_upload]
	before_action :find_order, only: [:edit, :update, :destroy, :new]

  def index
    if current_user.user_group.issues_view && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
      if params[:issue_status] == 'assigned'
        @issues = Issue.eager_load(:order).joins(:order).where("(assign_to = ? or assign_to = ? or assign_to LIKE ?) and orders.store = ?", current_user.full_name, current_user.username, "%,#{current_user.id.to_s},%", current_store).where.not(status: "closed")
      elsif params[:issue_status] == "returns"
        @issues = Issue.joins(:order).where(issue_type: :returns).where("orders.store = ?", current_store).where.not(status: "closed")
      elsif params[:issue_status] == "do_not_pay"
        @issues = Issue.joins(:order).where(invoice_pay: false).where("orders.store = ?", current_store).where.not(status: "closed")
      elsif params[:issue_status] == "product_claims"
        @issues = Issue.joins(:order).where(issue_type: :product_claims).where("orders.store = ?", current_store).where.not(status: "closed")
      elsif params[:issue_status] == "shipping_claims"
        @issues = Issue.joins(:order).where(issue_type: :shipping_claims).where("orders.store = ?", current_store).where.not(status: "closed")
      elsif params[:issue_status] == "chargeback"
        @issues = Issue.joins(:order).where(issue_type: :chargeback).where("orders.store = ?", current_store).where.not(status: "closed")
      else
        @issues = Issue.eager_load(:order).joins(:order).where(orders: { store: current_store }).where.not(status: "closed")
      end
    else
      render "dashboard/unauthorized"
    end
  end

  def edit
    if current_user.user_group.issues_cru && ((current_user.user_group.permission_us && current_store == "us") || (current_user.user_group.permission_ca && current_store == "canada"))
      @order = @issue.order
      @expense = Expense.new
      @return = Return.new
      unless @issue.claims_refund_items.present?
        @order.line_items.where(order_from: nil).each do |li|
          @issue.claims_refund_items.create(line_item_id: li.id, quantity: 0)
        end
      end
      @part_id ||= nil
    else
      render "dashboard/unauthorized"
    end
  end

  def update
    if @issue.update(issue_params)
      redirect_to edit_admin_issue_path(@issue)
    else
      render 'edit'
    end
  end
   
  def delete_upload
    attachment = ActiveStorage::Attachment.find_by(id: params[:doc_id])
    attachment.purge if attachment.present?
    redirect_to edit_admin_issue_path(params[:id])
  end

  def report
    @issues = Issue.eager_load(order: [:customer]).joins(:order).where(orders: { store: current_store }).where("issues.created_at > ?", Date.parse("2023-01-01")).where(issue_type: params[:issue_type])

    @issue_type = params[:issue_type]

    if params[:start_date].present?
      @issues = @issues.where("issues.created_at > ?", params[:start_date])
    end

    if params[:end_date].present?
      @issues = @issues.where("issues.created_at < ?", params[:end_date])
    end
  end

  private

  def find_issue
    @issue = Issue.find_by(id: params[:id])
  end
  
  def find_order
  	@order = Order.find_by(name: params[:order_name])
  end

  def issue_params
    params.require(:issue).permit(:id, :title, :description, :factory_id, :created_by, :assign_to, :order_id, :user_id, :status, :line_item_id, :issue_type, :shipping_charges, :resolution_type, :shipping_amount, :resolution_amount, :return_quantity, :carrier_id, :supplier_id, images: [], issue_details_attributes: [ :id, :issue_id, :main_type, :sub_type, :amount, :_destroy, images: []])
  end
end