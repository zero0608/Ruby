class Admin::FinanceContainersController < ApplicationController
  def index
  end

  def update
    @container = Container.find(params[:container_id])
    @container.update container_params
    if params[:finance].present? && params[:finance] == 'posting'
      redirect_to container_posting_admin_finance_containers_path
    else
      redirect_to container_record_admin_finance_containers_path
    end
  end

  def container_posting
    if params[:paid].present?
      @container = Container.find(params[:container_id])
      @posting = ContainerPosting.find(params[:posting_id])
      if ContainerRecord.create(container_id: @container.id, store: current_store)
        @posting.update(responded: true)
      end
      redirect_to container_posting_admin_finance_containers_path
    end
    @postings = ContainerPosting.where(store: current_store, responded: nil).all
  end

  def container_record
    @records = ContainerRecord.where(store: current_store, responded: nil).all
  end
  private

  def container_params
    params.require(:container).permit(:ocean_carrier_id, :supplier_id, :container_number, :shipping_date, :port_eta, :arriving_to_dc, :status, :ocean_carrier, :freight_carrier, :carrier_serial_number, :container_comment, :received_date, container_purchases_attributes: [:container_id, :purchase_item_id, :id], container_charges_attributes: [:id, :container_id, :charge, :quote, :invoice_amount, :tax_amount, :invoice_difference, :posted, files: []], container_costs_attributes: [:id, :container_id, :name, :amount])
  end
end
