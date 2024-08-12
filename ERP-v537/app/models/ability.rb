# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    
    alias_action :create, :read, :update, :destroy, :add_user, :update_arriving, :emca_inventory, :import, :assign, :warehouse_deliveries, :zip_code_page, to: :cruds
    alias_action :read, :update, :destroy, :complete, :cancel_request, :supplier_index, :search_orders, :show, to: :rud
    alias_action :read, :update, :destroy, :create, :append_ids,
                 :add_item, :add_product, :add_variant, :paginate,
                 :paginate_item, :search_item, :search_product,
                 :search_variant, :delete_upload, :shipping_list,
                 :stock, :alert, :return, :container, :search, :assign,
                 :carrier, :build_pallet_shipping, :build_shipping_detail,
                 :delete_shipping_detail, :delete_shipping_pallet, :submit,
                 :pre_order, :item_order, :search_orders, :emca_inventory,
                 :assign_order, :emca_index, :emca_container_index, :project_44_api,
                 :read, :index, to: :all
    alias_action :read, :index, :update, :create, :add_user, :front_page, :search_sku,
                 :search_location, :outstanding, :outstanding_put, :outstanding_pick,
                 :quantity_pick, :quantity_put, :received_quantity_pick,
                 :to_do_quantity_put, :create_location, :unassigned_locations,
                 :add_product, :show, :destroy, to: :warehouse_admin
    alias_action :read, :index, :update, :create, :add_user, :front_page, :search_sku,
                 :outstanding, :outstanding_put, :outstanding_pick,
                 :quantity_pick, :quantity_put, :received_quantity_pick,
                 :to_do_quantity_put, :unassigned_locations,
                 :add_product, :show, :destroy, to: :warehouse_staff

    if user.user_group.admin_view
      can :cruds, [Product, Category, UserGroup, User, Supplier, Pallet, Carrier, StoreAddress, TaxRate]
      can :all, [Warehouse, Purchase, Issue, Order, Comment]
    end

    can :warehouse_admin, [Warehouse] if user.warehouse_admin?

    can :warehouse_staff, [Warehouse] if user.warehouse_staff?

    if user.supplier?
      can :rud, [Purchase]
      cannot :all, [Issue, Order, Comment]
    else
      can :all, [Purchase, Issue, Order, Comment]
    end
  end
end
