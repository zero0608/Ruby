# frozen_string_literal: true

class IssueReflex < ApplicationReflex

  def update
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @order = Order.find_by(id: element.dataset[:order_id])
    @issue = Issue.find(params[:id])
    @issue.update(issue_params)

    if element.id == "issue_full_refund"
      if @issue.full_refund
        @issue.update(resolution_type: "Full Refund")
      else
        @issue.update(resolution_type: nil)
      end
    end

    if element.id == "issue_resolution_type"
      if issue_params[:resolution_type] == "Full Refund"
        @issue.update(full_refund: true)
      else
        @issue.update(full_refund: false)
      end
    end

    if @issue.full_refund
      @issue.claims_refund_items.each do |refund_item|
        refund_item.update(quantity: refund_item.line_item.quantity.to_i)
      end

    else  
      @issue.claims_refund_items.each do |refund_item|
        refund_item.update(quantity: refund_item.line_item.quantity.to_i) if refund_item.quantity.to_i > refund_item.line_item.quantity.to_i
      end
    end

    unless @issue.restocking_changed
      issue_amount = @issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i }
      @issue.update(restocking_fee: (issue_amount * 0.2).round(2))
    end
  end

  def update_restocking_fee
    @issue = Issue.find(params[:id])
    unless element[:value] == ""
      @issue.update(restocking_fee: element[:value], restocking_changed: true)
    else
      issue_amount = @issue.claims_refund_items.sum { |refund_item| refund_item.line_item.price.to_f * refund_item.quantity.to_i }
      @issue.update(restocking_fee: (issue_amount * 0.2).round(2), restocking_changed: false)
    end
  end

  def submit
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    @order = Order.find_by(id: element.dataset[:order_id])
    @issue = @order.issues.new(issue_params)
    @issue.save

    @order.line_items.where(order_from: nil).each do |li|
      @issue.claims_refund_items.create(line_item_id: li.id, quantity: 0)
    end

    if @issue.issue_type == 'returns'
      @return = ReturnProduct.new
      @return.issue_id = @issue.id
      @return.order_id = @issue.order_id
      @return.line_item_id = @issue.line_item_id
      @return.status = 'pending'
      @return.save
    end
    
    list = @issue&.assign_to&.split(",").uniq.reject { |s| s.to_s.empty? }
    list.each do |id|
      if id != element.dataset[:user_id]
        UserNotification.with(order: @order, issue: @issue, user: User.find(element.dataset[:user_id]), content: 'tag_issue', container: 'nil').deliver(User.find_by(id: id))
      end
    end
    
  	assigns = {
      order: @order,
      issues: @issue
    }

    cable_ready.
    inner_html(
    	selector: "#issue-listing", html: render(partial: "admin/orders/issue_listing", assigns: assigns, f: @order)).push_state()
    .broadcast
  end
  
  def create_charges
    @issue = Issue.find_by(id: element.dataset[:id])
    @issue.issue_details.create(main_type: "Shipping Charges")
  end
  
  def create_resolution
    @issue = Issue.find_by(id: element.dataset[:id])
    @issue.issue_details.create(main_type: "Resolution Type")
  end

  def delete_detail
    @issue_detail = IssueDetail.find_by(id: element.dataset[:id])
    @issue_detail.destroy
  end

  def search_order
    @que = element[:value].strip
    @issue_id = element.dataset[:issue_id]
    @orders = Order.where("name ILIKE ?", "%#{@que}%") if @que.present?
    assigns = {
      issue_id: @issue_id,
      query: @que,
      orders: @orders.uniq
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#issue-search-edit-results", html: render(partial: "search_order", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_variant
    @que = element[:value].strip
    @issue_id = element.dataset[:issue_id]
    @product_variants = ProductVariant.where("(title ILIKE ? OR sku ILIKE ?) AND store = ?", "%#{@que}%", "%#{@que}%", Issue.find_by(id: @issue_id).order.store) if @que.present?
    assigns = {
      issue_id: @issue_id,
      query: @que,
      product_variants: @product_variants
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#variant-search-edit-results", html: render(partial: "search_variant", assigns: assigns))
      .push_state()
      .broadcast
  end

  def search_replacement
    @que = element[:value].strip
    @part_id = element.dataset[:part_id].to_i
    @replacement_references = ReplacementReference.eager_load(:product_variant).where("product_variants.product_part_id = ? AND (product_variants.title ILIKE ? OR replacement_references.name ILIKE ?)", @part_id, "%#{@que}%", "%#{@que}%") if @que.present?

    assigns = {
      query: @que,
      part_id: @part_id,
      replacement_references: @replacement_references
    }
    
    morph :nothing

    cable_ready
      .inner_html(selector: "#replacement-search-results", html: render(partial: "search_replacement", assigns: assigns))
      .push_state()
      .broadcast
  end

  def add_tag_order
    user_id = element.dataset[:id]
    issue = Issue.find_by(id: element.dataset[:issue_id])
    issue.update(order_link: issue.order_link.to_s + "," + user_id)
  end

  def remove_tag_order
    order_id = element.dataset[:order_id]
    issue = Issue.find_by(id: element.dataset[:issue_id])
    if issue.order_link.present?
      new_list = ","
      list = issue.order_link&.split(",").uniq.reject { |s| s.to_s.empty? }
      list.each do |id|
        if id != order_id
          new_list += id + ","
        end
      end
      issue.update(order_link: new_list)
    end
  end

  def search_tag_user
    @que = element[:value].strip
    @issue_id = element.dataset[:issue_id]
    @users = User.joins(employee: :department).where("(users.username ILIKE ? OR departments.name ILIKE ?)", "%#{@que}%", "%#{@que}%").where(deactivate: [false, nil]).where.not(username: ["", nil]) if @que.present?
    assigns = {
      issue_id: @issue_id,
      query: @que,
      users: @users.uniq
    }
    morph :nothing

    cable_ready
      .inner_html(selector: "#user-search-tag-results", html: render(partial: "search_user", assigns: assigns))
      .push_state()
      .broadcast
  end

  def add_tag_user
    user_id = element.dataset[:id]
    issue = Issue.find_by(id: element.dataset[:issue_id])
    issue.update(assign_to: issue.assign_to.to_s + "," + user_id)
  end

  def remove_tag_user
    user_id = element.dataset[:user_id]
    issue = Issue.find_by(id: element.dataset[:issue_id])
    new_list = ","
    if issue.assign_to.include? ","
      list = issue.assign_to&.split(",").uniq.reject { |s| s.to_s.empty? }
      list.each do |id|
        if id != user_id
          new_list += id + ","
        end
      end
      issue.update(assign_to: new_list)
    end
  end

  def select_issue_product
    issue = Issue.find_by(id: element.dataset[:issue_id])
    sku = element.dataset[:sku]
    if issue.assign_product.has_key?(sku)
      if element.dataset[:type] == "quantity"
        issue.assign_product[sku][0] = element.value
      else
        issue.assign_product[sku][1] = element.checked
      end
      issue.save
    end
  end

  def update_replacement
    @part_id = element.value
  end

  def delete_repair_service
    repair = RepairService.find_by(id: element.dataset[:repair_id])
    expense = Expense.find_by(id: repair.expense_id)
    repair&.destroy
    expense&.destroy
  end

  private

  def issue_params
    params.require(:issue).permit(:id, :title, :description, :created_by, :assign_to, :order_id, :user_id, :status, :line_item_id, :issue_type, :shipping_charges, :resolution_type, :shipping_amount, :resolution_amount, :return_quantity, :carrier_id, :supplier_id, :order_link, :bill_of_lading, :claims_submission_date, :claims_reference, :pickup_date, :last_scanned_date, :claims_dispute, :dispute_amount, :shipping_invoice, :invoice_pay, :dispute_type, :factory_id, :chargeback_id, :chargeback_reason, :win_likelihood, :chargeback_dispute, :chargeback_date, :card_type, :outcome_notes, :full_refund, :discount_amount, :warranty_amount, :store_credit, :gorgias_ticket, :claim_type, :shipping_claim_type, :restocking_fee, :repacking_fee, :resolution_type, :return_reason, :shipping_curbside, :shipping_wgd, :replacement_type, issue_details_attributes: [ :id, :issue_id, :main_type, :sub_type, :amount, :_destroy ], claims_refund_items_attributes: [ :id, :quantity ])
  end
end