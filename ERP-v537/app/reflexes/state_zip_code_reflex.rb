class StateZipCodeReflex < ApplicationReflex
  def build_code
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    TaxRate.find_by(id: element.dataset[:type_id]).state_zip_codes.create(remote: true)
  end

  def build_warehouse
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    TaxRate.find_by(id: element.dataset[:type_id]).warehouse_and_tax_rates.create
  end

  def build_city
    ::Audited.store[:current_user] = User.find(element.dataset[:user_id])
    TaxRate.find_by(id: element.dataset[:type_id]).curbside_cities.create(city_type: 'Local')
  end

  def update
    TaxRate.find_by(id: element.dataset[:type_id]).update(tax_rate_params)
  end

  def in_stock
    InstockWarehouseTable.find_by(id: element.dataset[:stock_id]).update(in_stocks_params)
  end

  def pre_stock
    PreorderWarehouseTable.find_by(id: element.dataset[:stock_id]).update(pre_stocks_params)
  end

  def transfer_stock
    PreorderFromAnotherWarehouseTable.find_by(id: element.dataset[:stock_id]).update(transfer_stock_params)
  end

  def mto_stock
    MtoWarehouseTable.find_by(id: element.dataset[:stock_id]).update(mto_stocks_params)
  end

  def wgd_stock
    WgdWarehouseTable.find_by(id: element.dataset[:stock_id]).update(wgd_stocks_params)
  end
  
  private

  def tax_rate_params
    params.require(:tax_rate).permit(:state, :combined_rate, :store, :warehouse_id, state_zip_codes_attributes: [:id, :zip_code], curbside_cities_attributes: [:id, :city, :city_type], warehouse_and_tax_rates_attributes: [:id, :warehouse_id, :tax_rate_id, :terminal])
  end

  def in_stocks_params
    params.require(:instock_warehouse_table).permit(:id, :terminal, :to_days, :from_days, :war_type)
  end

  def pre_stocks_params
    params.require(:preorder_warehouse_table).permit(:id, :terminal, :to_days, :from_days, :war_type)
  end

  def transfer_stock_params
    params.require(:preorder_from_another_warehouse_table).permit(:id, :terminal, :to_days, :from_days, :war_type)
  end

  def mto_stocks_params
    params.require(:mto_warehouse_table).permit(:id, :terminal, :to_days, :from_days, :war_type)
  end

  def wgd_stocks_params
    params.require(:wgd_warehouse_table).permit(:id, :terminal, :to_days, :from_days, :war_type)
  end
end