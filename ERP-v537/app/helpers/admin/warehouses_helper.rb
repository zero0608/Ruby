module Admin::WarehousesHelper
  def redirect
    case request.path
      when search_sku_admin_warehouses_path
        outstanding_admin_warehouses_path
      when outstanding_admin_warehouses_path
        outstanding_admin_warehouses_path
      when search_location_admin_warehouses_path
        outstanding_admin_warehouses_path
      when variant_search_admin_warehouses_path
        outstanding_admin_warehouses_path

      when outstanding_pick_admin_warehouses_path
        outstanding_admin_warehouses_path
      when outstanding_put_admin_warehouses_path
        outstanding_admin_warehouses_path

      when variant_pick_admin_warehouses_path
        outstanding_pick_admin_warehouses_path

      when variant_put_admin_warehouses_path
        outstanding_put_admin_warehouses_path

      when search_admin_sku_admin_warehouses_path
        search_location_admin_warehouses_path
      when unassigned_locations_admin_warehouses_path
        search_location_admin_warehouses_path
      when show_location_admin_warehouses_path
        search_location_admin_warehouses_path

      when aisle_location_admin_warehouses_path
        unassigned_locations_admin_warehouses_path

      when variant_admin_search_admin_warehouses_path
        search_admin_sku_admin_warehouses_path

      else
        outstanding_admin_warehouses_path
    end
  end
end
