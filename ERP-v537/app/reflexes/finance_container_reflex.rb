# frozen_string_literal: true

class FinanceContainerReflex < ApplicationReflex

  def charges_update
    @container = Container.find(element.dataset[:container_id])
    @container.update(container_params)
  end

  private

  def container_params
    params.require(:container).permit(:ocean_carrier_id, :supplier_id, :container_number, :shipping_date, :port_eta, :arriving_to_dc, :status, :ocean_carrier, :freight_carrier, :carrier_serial_number, :container_comment, :received_date, container_purchases_attributes: [:container_id, :purchase_item_id, :id], container_charges_attributes: [:id, :container_id, :charge, :quote], container_costs_attributes: [:id, :container_id, :name, :amount])
  end

end