Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  root 'dashboard#index'

  get 'dashboard/index'
  get "dashboard/redirect_store"
  get "dashboard/redirect_showroom"
  devise_for :users, :skip => [:registrations], controllers: { sessions: 'users/sessions' }
                                      
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  namespace :admin do
    get 'admin/notifications/:id/read', to: 'notifications#read', as: :read_notification

    resources :warehouse_transfer_orders do
      collection do
        get :add_product
        post :add_product
        get :clear_array
        get :shipped_transfer
        post :shipped_transfer
      end
    end
    
    resources :users, param: :slug do
      member do
        get :change_password
        patch :update_password
        get :enable_2fa
        get :verify_qrcode
      end
    end
    resources :documents do
      collection do
        get :bol
        get :doc_ids
      end
    end
    resources :accounting_expenses do
      collection do
        get :accounting
        get :expense_page
        get :create_type
        post :create_type
        get :edit_type
        post :edit_type
      end
    end
    resources :finance_containers do
      collection do
        get :container_posting
        get :container_record
        post :container_posting
        post :container_record
      end
    end
    resources :ocean_carriers
    resources :risk_indicators
    resources :groups, param: :slug
    resources :categories
    resources :swatch_products
    resources :tax_rates do
      collection do
        get :warehouse_deliveries
        get :zip_code_page
      end
    end
    resources :shipment_codes
    resources :billing_sections do
      collection do
        get :review
        get :posting
        get :records
        post :review
        post :posting
        post :records
        post :upload_doc
        post :report_invoice
        post :posting_all
        delete :delete_upload
      end
    end
    resources :shipping_rates do
      collection do
        get :remote_shipping_rate
        get :standard_shipping_rate
        get :local_shipping_rate
        post :remote_shipping_rate
        post :standard_shipping_rate
        post :local_shipping_rate
        delete :delete_rate
        get :update_rate
        post :update_rate
      end
    end
    resources :products, param: :id do
      resources :product_variants, param: :id
      collection do
        post :shopify_product_sync
        post :shopify_product_update_sync
        get :emca_inventory
        get :inventory
        get :assign
        post :assign
        post :import
        get :update_quantity
        get :emca_products
        get :pdf
      end
    end
    resources :product_variants, param: :id do
      collection do
        get :emca_inventory
        get :inventory
        get :update_arriving
        post :import
        post :import_image
        get :replacement
        get :new_replacement
        post :create_replacement
      end
      member do
        get :edit_replacement
        post :update_replacement
        get :delete_replacement
      end
    end

    resources :line_items
    resources :create_whitelists
    resources :create_whitelists do
      resources :comments, module: :create_whitelists
    end
    resources :orders, param: :name do
      resources :comments, module: :orders
      resources :order_fulfillments
      member do
        delete :delete_upload
      end
      resources :issues do
        resources :comments, module: :issues
      end
      collection do
        post :index
        get :emca_stock
        post :shopify_order_sync
        post :shopify_order_update_sync
        get :project_44_api
        post :project_44_api
        get :shipping_list
        get :stock
        post :stock
        get :warehouse_inventories
        get :emca_warehouse_inventories
        get :alert
        get :return
        get :container
        get :pre_order
        get :cancel_request
        get :hold_request
        get :cancel_confirmed
        get :hold_confirmed
        get :order_status
        get :completed
        get :pdf
        get :get_all_orders
        get :update_arriving
        get :archive
        get :pending
        get :custom_orders
        get :tracking
        get :track_your_order
        get :tracking_order
        post :tracking_order 
        get :order_tracking
        post :order_tracking
        get :reserved_skus
        get :error
        get :swatches_page
        get :print_swatch_table
        get :pending_payment_section
        get :update_order_status_to_m2
        get :update_order_status_to_m2_mto
        get :unfulfillable
        get :report
        post :report
        get :create_shipment
        get :merge_packing_slip
        get :report_logistics
        get :report_logistics_export
        post :report_logistics_export
        get :report_orders
        get :bestseller_skus
        post :bestseller_skus
        get :bestseller_swatches
        post :bestseller_swatches
        post :create_replacement_order
        get :orders_per_date
      end
    end
    resources :purchases do
      resources :comments, module: :purchases
      collection do
        get :add_item
        get :add_product
        get :add_variant
        get :assign_order
        get :complete
        get :cancel_request
        get :pre_order
        get :item_order
        get :supplier_index
        get :emca_index
      end
      member do
        get :assign_order
        get :add_item
        get :add_product
        get :add_variant
        get :item_order
      end
    end
    resources :containers do
      resources :comments, module: :containers
      collection do
        get :arriving
        get :pdf
        get :split_item
        post :split_item
        get :mearge_item
        post :mearge_item
        get :assign_order
        get :emca_container_index
        get :container_posting
        get :container_record
        post :container_posting
        post :container_record
        get :add_item  
      end
      member do
        get :reassign_variant
        get :assign_order
      end
    end

    resources :warehouses do
      collection do
        get :sync_warehouse_information
        post :sync_warehouse_information
        get :all_warehouse_data
        post :all_warehouse_data
      end
      member do
        get :add_user
      end
      collection do
        get :search_sku
        get :search_admin_sku
        get :search_location
        get :outstanding
        get :outstanding_put
        get :outstanding_pick
        get :outstanding_reserve
        get :outstanding_preorder
        get :variant_pick
        get :variant_quantity_pick
        get :variant_put
        get :variant_quantity_put
        get :preorder_quantity_pick
        get :reserve_variant_pick
        get :reserve_quantity_pick
        get :container_orders
        get :container_quantity_pick
        post :quantity_put
        post :quantity_pick
        post :reserve_pick
        post :preorder_pick
        get :received_quantity_pick
        post :received_quantity_pick
        get :to_do_quantity_put
        post :to_do_quantity_put
        get :create_location
        post :create_location
        get :aisle_location
        get :unassigned_locations
        post :unassigned_locations
        get :add_product
        post :add_product
        get :variant_admin_search
        get :variant_search
        post :variant_admin_search
        post :variant_search
        post :variant_pick
        post :variant_put
        get :show_location
        get :search_location_results
        post :quantity_admin_pick
        post :quantity_admin_put
        post :assign_location_to_product
        post :assign_admin_location_to_product
        get :admin
        get :new_location
        get :edit_location
        get :edit_selected_location
        post :update_location
        get :admin_variant
        post :variant_quantity_adjust
        get :add_inventory_to_location
      end
    end
    resources :suppliers, param: :slug do
      member do
        get :add_user
        get :purchase
      end
    end
    resources :pallets
    resources :carriers
    resources :state_days
    resources :issues do
       member do
        delete :delete_upload
      end
      collection do
        get :report
        post :report
      end
    end 
    resources :announcements
    resources :store_addresses
    resources :departments do
      resources :employees do
        resources :checklists
      end
      member do
        get :manager
        get :leave_request
        get :leave_upcoming
        get :leave_current
        get :leave_history
      end
      collection do
        get :manager_panel
        get :directory
        get :expense_request
        get :time_off_request
        get :expense_history
        get :time_off_history
      end
    end
    resources :positions
    resources :employees do
      member do
        get :list
        get :reset_checklist
        delete :delete_upload
      end
      collection do
        get :reset_all_checklists
      end
      resources :checklists
    end
    resources :templates
    resources :expenses do
      member do
        post :approve
      end
      collection do
        get :expense_posting
        get :expense_record
        post :expense_posting
        post :expense_record
        post :create_claims_expense
      end
    end
    resources :expense_payment_methods
    resources :leaves do
      collection do
        post :update_calendar
      end
      member do
        get :cancel_leave
      end
    end
    resources :holidays
    resources :tasks do
      resources :comments, module: :tasks
      collection do
        delete :delete_upload
      end
    end
    resources :white_glove_directories do
      collection do
        post :update_packing_slip
      end
    end
    resources :white_glove_addresses
    resources :invoices do
      resources :invoice_line_items
      collection do
        post :no_sale
        post :create_order
        post :additional_payment
        get :commission
        post :add_cem
      end
      member do
        get :pdf
      end
    end
    resources :factories
    resources :returns do
      resources :comments, module: :returns
      member do
        post :update_address
      end
    end
    resources :return_line_items
    resources :market_products
    resources :truck_brokers
    resources :board_sections do
      collection do
        get :edit_board
        post :new_sub_board
        get :delete_board
        post :delete_board
      end
    end
    resources :board_pages
    resources :product_parts
    resources :replacement_references
    resources :customers do
      collection do
        get :report
        post :report
        post :create_customer_lead
      end
    end
    resources :commission_rates
    resources :invoice_macros
    resources :sales
    resources :appointments do
      collection do
        post :create_customer_appointment
      end
    end
    resources :showrooms
  end  
end
