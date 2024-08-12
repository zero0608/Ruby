class Admin::ReturnsController < ApplicationController
  def index
    if params[:status] == "pending"
      @returns = Return.where(status: "pending")
    else
      @returns = Return.where.not(status: "pending")
    end
  end

  def new
  end

  def create
    @return = Return.new(return_params)
    @return.status = "pending"
    @return.name = (@return.customer_return ? "CRT-" : "RT-") + @return.order.name + "-" + (@return.order.returns.where(customer_return: @return.customer_return).order(created_at: :desc).index(@return).to_i + 1).to_s.rjust(2, "0")
    @issue = Issue.find(return_params[:issue_id])
    if @issue.claims_refund_items.sum { |item| item.quantity.to_i } > 0
      if @return.save
        @issue.claims_refund_items.each do |item|
          if item.quantity.to_i > 0
            @return.return_line_items.create(status: :pending, line_item_id: item.line_item_id, quantity: item.quantity)
          end
        end

        if @return.white_glove_address_id.present?
          @review = ReviewSection.create(return_id: @return.id, store: @return.order.store, invoice_type: @return&.white_glove_directory&.company_name, white_glove: true)
          @return.create_invoice_for_wgd
        elsif @return.carrier_id.present?
          @review  = ReviewSection.create(return_id: @return.id, store: @return.order.store, invoice_type: @return.carrier.name, white_glove: false)
          @return.create_invoice_for_billing
        end
      end
      redirect_to edit_admin_issue_path(@issue.id)
    else
      flash[:alert] = "Failed to create return order. Item quantity information has not been entered."
      redirect_to edit_admin_issue_path(@issue.id)
    end
  end

  def edit
    @return = Return.find_by(id: params[:id])
    if params[:line_item_id].present?
      @return_line_item = ReturnLineItem.find_by(id: params[:line_item_id])
    end
  end

  def update
    @return = Return.find_by(id: params[:id])
    @return.update(return_params)

    unless @return.review_sections.where(white_glove: true).present?
      if @return.white_glove_address.present?
        @review = ReviewSection.create(return_id: @return.id, store: @return.order.store, invoice_type: @return&.white_glove_directory&.company_name, white_glove: true)
        @return.create_invoice_for_wgd
      end
    end
      
    unless @return.review_sections.where(white_glove: false).present?
      if @return.carrier_id.present?
        @review = ReviewSection.create(return_id: @return.id, store: @return.order.store, invoice_type: @return&.carrier&.name, white_glove: false)
        @return.create_invoice_for_billing
      end
    end
  end

  def update_address
    @return = Return.find_by(id: params[:id])
    @return.update(return_params)
    redirect_to edit_admin_return_path(@return.id)
  end

  private

  def return_params
    params.require(:return).permit(:id, :order_id, :issue_id, :customer_return, :disposal, :return_reason, :return_date, :return_carrier, :return_number, :return_quote, :return_company, :return_contact, :return_address, :return_city, :return_state, :return_country, :return_zip_code, :truck_broker_id, :carrier_id, :white_glove_address, :white_glove_directory_id, :white_glove_address_id, :shipping_cost, files: [])
  end
end