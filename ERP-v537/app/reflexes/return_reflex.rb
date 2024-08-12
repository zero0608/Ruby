class ReturnReflex < ApplicationReflex
  def update
    re = Return.find_by(id: element.dataset[:return_id])
    re.update(return_params)

    if re.white_glove_directory_id.present? && re.white_glove_address_id.present? && re.white_glove_address.white_glove_directory_id != re.white_glove_directory_id
      re.update(white_glove_address_id: nil)
    end

    if !re.review_sections.present?
      if re.white_glove_address.present?
        ReviewSection.create(return_id: re.id, store: re.order.store, invoice_type: re&.white_glove_directory&.company_name, white_glove: true)
        re.create_invoice_for_wgd
      elsif re.carrier_id.present?
        ReviewSection.create(return_id: re.id, store: re.order.store, invoice_type: re&.carrier&.name, white_glove: false)
        re.create_invoice_for_billing
      end
    end
  end

  def cancel_return
    re = Return.find_by(id: element.dataset[:return_id])
    re.update(status: 2)
  end
  
  private

  def return_params
    params.require(:return).permit(:id, :truck_broker_id, :carrier_id, :return_quote, :white_glove_address, :shipping_cost, :white_glove_directory_id, :white_glove_address_id, :disposal)
  end
end