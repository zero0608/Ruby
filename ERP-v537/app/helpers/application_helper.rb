module ApplicationHelper
  include Pagy::Frontend
  require 'pagy/extras/items'
  require 'pagy/extras/bootstrap'


  def column_css(column_name)
    return "text-dark selected" if column_name.to_s == @order_by
    "text-dark"
  end

  def arrow(column_name)
    return if column_name.to_s != @order_by
    @direction == "desc" ? "↑" : "↓"
  end

  def direction
    @direction == "asc" ? "desc" : "asc"
  end

  def pagy_get_params(params)
    params.merge query: @query, order_by: @order_by, direction: @direction
  end

  def prev_page
    @pagy.prev || 1
  end

  def next_page
    @pagy.next || @pagy.last
  end

  def active_class(link_path)
    if link_path == root_path
      current_page?(link_path) ? "active" : ""
    else
      (request.fullpath == link_path) ? "active" : ""
    end
  end

  def allow_admin_nav(controller, action)
    if ["admin/suppliers"].include? controller
      (["index", "new", "edit", "change_password", "add_user"].include? action)
    else
      (["admin/risk_indicators","admin/shipment_codes","admin/shipping_rates","admin/tax_rates","admin/categories", "admin/products", "admin/groups", "admin/users", "admin/pallets", "admin/carriers", "admin/state_days", "admin/create_whitelists", "admin/store_addresses", "admin/warehouses", "admin/white_glove_addresses"].include? controller)
    end
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
        render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '', class: "add_fields dripicons-plus icon-red-clay", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def flash_class(level)
    bootstrap_alert_class = {
      "success" => "alert-success",
      "error" => "alert-danger",
      "notice" => "alert-info",
      "alert" => "alert-danger",
      "warning" => "alert-warning"
    }
    bootstrap_alert_class[level]
  end

  def active_store(store)
    "active-store" if store == session[:store]
  end
  
  def show_svg(path)
    File.open("app/assets/icons/#{path}", "rb") do |file|
      raw file.read
    end
  end
end
