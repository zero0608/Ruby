# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_07_15_165559) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounting_expenses", force: :cascade do |t|
    t.bigint "expense_type_id"
    t.bigint "expense_category_id"
    t.bigint "expense_subcategory_id"
    t.bigint "expense_payment_method_id"
    t.string "gst"
    t.string "pst"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expense_category_id"], name: "index_accounting_expenses_on_expense_category_id"
    t.index ["expense_payment_method_id"], name: "index_accounting_expenses_on_expense_payment_method_id"
    t.index ["expense_subcategory_id"], name: "index_accounting_expenses_on_expense_subcategory_id"
    t.index ["expense_type_id"], name: "index_accounting_expenses_on_expense_type_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "topic"
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "employee_id"
    t.bigint "showroom_id"
    t.date "appointment_date"
    t.time "appointment_time"
    t.integer "appointment_type"
    t.string "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id"], name: "index_appointments_on_customer_id"
    t.index ["employee_id"], name: "index_appointments_on_employee_id"
    t.index ["showroom_id"], name: "index_appointments_on_showroom_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "billing_addresses", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "country"
    t.string "company"
    t.string "country_code"
    t.string "first_name"
    t.string "last_name"
    t.string "latitude"
    t.string "longitude"
    t.string "name"
    t.string "phone"
    t.string "province"
    t.string "province_code"
    t.string "zip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_billing_addresses_on_order_id"
  end

  create_table "board_pages", force: :cascade do |t|
    t.string "name"
    t.string "content"
    t.string "tag", default: [], array: true
    t.bigint "board_section_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.index ["board_section_id"], name: "index_board_pages_on_board_section_id"
  end

  create_table "board_sections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "main_board"
    t.integer "position"
  end

  create_table "carrier_contacts", force: :cascade do |t|
    t.bigint "carrier_id", null: false
    t.string "name"
    t.string "number"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["carrier_id"], name: "index_carrier_contacts_on_carrier_id"
  end

  create_table "carriers", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "tracking_url"
    t.string "carrierID"
    t.string "tracking_method"
    t.string "billing_method"
    t.boolean "inactive", default: false
    t.bigint "truck_broker_id"
    t.index ["truck_broker_id"], name: "index_carriers_on_truck_broker_id"
  end

  create_table "carton_details", force: :cascade do |t|
    t.bigint "product_id"
    t.string "length"
    t.string "width"
    t.string "height"
    t.string "weight"
    t.integer "index"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "cubic_meter"
    t.index ["product_id"], name: "index_carton_details_on_product_id"
  end

  create_table "carton_locations", force: :cascade do |t|
    t.bigint "carton_id"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "product_location_id"
    t.index ["carton_id"], name: "index_carton_locations_on_carton_id"
    t.index ["product_location_id"], name: "index_carton_locations_on_product_location_id"
  end

  create_table "cartons", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "quantity"
    t.bigint "product_variant_id"
    t.integer "received_quantity"
    t.integer "to_do_quantity"
    t.bigint "carton_detail_id"
    t.index ["carton_detail_id"], name: "index_cartons_on_carton_detail_id"
    t.index ["product_variant_id"], name: "index_cartons_on_product_variant_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "charges", force: :cascade do |t|
    t.bigint "receipt_id", null: false
    t.string "object"
    t.string "amount"
    t.string "application_fee"
    t.string "balance_transaction"
    t.string "captured"
    t.string "currency"
    t.string "failure_code"
    t.string "failure_message"
    t.json "fraud_details"
    t.string "livemode"
    t.string "paid"
    t.string "payment_intent"
    t.string "payment_method"
    t.string "refunded"
    t.string "source"
    t.string "status"
    t.json "mit_params"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["receipt_id"], name: "index_charges_on_receipt_id"
  end

  create_table "checklists", force: :cascade do |t|
    t.bigint "employee_id"
    t.string "description"
    t.string "list_type"
    t.boolean "is_checked"
    t.boolean "is_default"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "list_group_id"
    t.index ["employee_id"], name: "index_checklists_on_employee_id"
    t.index ["list_group_id"], name: "index_checklists_on_list_group_id"
  end

  create_table "claims_refund_items", force: :cascade do |t|
    t.integer "quantity"
    t.bigint "issue_id"
    t.bigint "line_item_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_id"], name: "index_claims_refund_items_on_issue_id"
    t.index ["line_item_id"], name: "index_claims_refund_items_on_line_item_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "description"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "tag_user_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "commission_rates", force: :cascade do |t|
    t.bigint "employee_id"
    t.float "lower_range"
    t.float "upper_range"
    t.float "rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["employee_id"], name: "index_commission_rates_on_employee_id"
  end

  create_table "consolidations", force: :cascade do |t|
    t.string "name"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "container_charges", force: :cascade do |t|
    t.bigint "container_id", null: false
    t.string "carrier_type"
    t.string "charge"
    t.float "quote"
    t.float "invoice_amount"
    t.float "invoice_difference"
    t.float "tax_amount"
    t.boolean "posted"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "invoice_number"
    t.index ["container_id"], name: "index_container_charges_on_container_id"
  end

  create_table "container_costs", force: :cascade do |t|
    t.bigint "container_id", null: false
    t.string "carrier_type"
    t.string "name"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["container_id"], name: "index_container_costs_on_container_id"
  end

  create_table "container_orders", force: :cascade do |t|
    t.bigint "product_variant_id"
    t.bigint "order_id"
    t.bigint "line_item_id"
    t.string "name"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_item_id"], name: "index_container_orders_on_line_item_id"
    t.index ["order_id"], name: "index_container_orders_on_order_id"
    t.index ["product_variant_id"], name: "index_container_orders_on_product_variant_id"
  end

  create_table "container_postings", force: :cascade do |t|
    t.bigint "container_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.integer "responded"
    t.index ["container_id"], name: "index_container_postings_on_container_id"
  end

  create_table "container_purchases", force: :cascade do |t|
    t.bigint "container_id", null: false
    t.bigint "purchase_item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["container_id"], name: "index_container_purchases_on_container_id"
    t.index ["purchase_item_id"], name: "index_container_purchases_on_purchase_item_id"
  end

  create_table "container_records", force: :cascade do |t|
    t.bigint "container_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.integer "responded"
    t.index ["container_id"], name: "index_container_records_on_container_id"
  end

  create_table "containers", force: :cascade do |t|
    t.bigint "supplier_id"
    t.integer "container_number"
    t.date "shipping_date"
    t.date "port_eta"
    t.date "arriving_to_dc"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.string "ocean_carrier"
    t.string "carrier_serial_number"
    t.date "received_date"
    t.string "freight_carrier"
    t.string "container_comment"
    t.bigint "ocean_carrier_id"
    t.bigint "container_posting_id"
    t.bigint "container_record_id"
    t.bigint "warehouse_id"
    t.index ["container_posting_id"], name: "index_containers_on_container_posting_id"
    t.index ["container_record_id"], name: "index_containers_on_container_record_id"
    t.index ["ocean_carrier_id"], name: "index_containers_on_ocean_carrier_id"
    t.index ["supplier_id"], name: "index_containers_on_supplier_id"
    t.index ["warehouse_id"], name: "index_containers_on_warehouse_id"
  end

  create_table "create_whitelists", force: :cascade do |t|
    t.string "ip_address"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.integer "status"
  end

  create_table "curbside_cities", force: :cascade do |t|
    t.bigint "tax_rate_id"
    t.string "city"
    t.string "city_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tax_rate_id"], name: "index_curbside_cities_on_tax_rate_id"
  end

  create_table "customer_billing_addresses", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "zip"
    t.bigint "customer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.index ["customer_id"], name: "index_customer_billing_addresses_on_customer_id"
  end

  create_table "customer_shipping_addresses", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "zip"
    t.bigint "customer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.index ["customer_id"], name: "index_customer_shipping_addresses_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "shopify_customer_id"
    t.string "email"
    t.string "accpts_marketing"
    t.string "first_name"
    t.string "last_name"
    t.string "orders_count"
    t.string "state"
    t.string "total_spent"
    t.string "last_order_id"
    t.string "note"
    t.string "verified_email"
    t.string "multipass_identifier"
    t.string "tax_exempt"
    t.string "phone"
    t.string "tags"
    t.string "last_order_name"
    t.string "currency"
    t.string "accepts_marketing_updated_at"
    t.string "marketing_opt_in_level"
    t.string "tax_exemptions", default: [], array: true
    t.string "admin_graphql_api_id"
    t.json "default_address"
    t.json "metfield"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "risk_indicator_id"
    t.string "risk_reason"
    t.string "trade_name"
    t.string "trade_number"
    t.bigint "employee_id"
    t.index ["employee_id"], name: "index_customers_on_employee_id"
    t.index ["risk_indicator_id"], name: "index_customers_on_risk_indicator_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "department_id"
    t.bigint "position_id"
    t.bigint "manager_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.date "dob"
    t.string "employment_type"
    t.string "health_number"
    t.string "emergency_contact"
    t.string "emergency_number"
    t.boolean "work_mon"
    t.boolean "work_tue"
    t.boolean "work_wed"
    t.boolean "work_thu"
    t.boolean "work_fri"
    t.boolean "work_sat"
    t.boolean "work_sun"
    t.date "start_date"
    t.date "exit_date"
    t.boolean "voluntary_exit"
    t.float "salary"
    t.float "bonus"
    t.float "pto_days"
    t.float "personal_days"
    t.float "sick_days"
    t.string "hr_notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "pay_type"
    t.float "unpaid_days"
    t.float "pto_remain"
    t.float "personal_remain"
    t.float "sick_remain"
    t.boolean "is_director", default: false
    t.boolean "is_billing", default: false
    t.bigint "showroom_id"
    t.integer "sales_permission"
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["manager_id"], name: "index_employees_on_manager_id"
    t.index ["position_id"], name: "index_employees_on_position_id"
    t.index ["showroom_id"], name: "index_employees_on_showroom_id"
  end

  create_table "expense_categories", force: :cascade do |t|
    t.bigint "expense_type_id"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expense_type_id"], name: "index_expense_categories_on_expense_type_id"
  end

  create_table "expense_payment_methods", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "company_card"
    t.boolean "deactivate", default: false
  end

  create_table "expense_payment_relations", force: :cascade do |t|
    t.bigint "expense_subcategory_id"
    t.bigint "expense_payment_method_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expense_payment_method_id"], name: "index_expense_payment_relations_on_expense_payment_method_id"
    t.index ["expense_subcategory_id"], name: "index_expense_payment_relations_on_expense_subcategory_id"
  end

  create_table "expense_postings", force: :cascade do |t|
    t.bigint "expense_id"
    t.string "reason"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "posting", default: false
    t.integer "status", default: 0
    t.index ["expense_id"], name: "index_expense_postings_on_expense_id"
  end

  create_table "expense_subcategories", force: :cascade do |t|
    t.bigint "expense_category_id"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expense_category_id"], name: "index_expense_subcategories_on_expense_category_id"
  end

  create_table "expense_types", force: :cascade do |t|
    t.string "title"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "expenses", force: :cascade do |t|
    t.bigint "employee_id"
    t.date "expense_date"
    t.float "amount"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "comment"
    t.string "notes"
    t.bigint "approver_id"
    t.date "approve_date"
    t.float "approve_amount"
    t.bigint "expense_type_id"
    t.bigint "expense_category_id"
    t.bigint "expense_subcategory_id"
    t.bigint "expense_payment_method_id"
    t.string "store"
    t.float "gst"
    t.float "pst"
    t.boolean "claims_expense", default: false
    t.float "tips"
    t.index ["approver_id"], name: "index_expenses_on_approver_id"
    t.index ["employee_id"], name: "index_expenses_on_employee_id"
    t.index ["expense_category_id"], name: "index_expenses_on_expense_category_id"
    t.index ["expense_payment_method_id"], name: "index_expenses_on_expense_payment_method_id"
    t.index ["expense_subcategory_id"], name: "index_expenses_on_expense_subcategory_id"
    t.index ["expense_type_id"], name: "index_expenses_on_expense_type_id"
  end

  create_table "factories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "fulfillments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "shopify_fulfillment_id"
    t.string "admin_graphql_api_id"
    t.string "location_id"
    t.string "name"
    t.json "receipt"
    t.string "service"
    t.string "shipment_status"
    t.string "status"
    t.string "tracking_company"
    t.string "tracking_numbers", default: [], array: true
    t.string "tracking_urls", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_fulfillments_on_order_id"
  end

  create_table "holidays", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "instock_warehouse_tables", force: :cascade do |t|
    t.string "war_type"
    t.integer "from_days"
    t.integer "to_days"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.string "terminal"
    t.string "delivery_method"
  end

  create_table "inventory_histories", force: :cascade do |t|
    t.bigint "product_variant_id", null: false
    t.bigint "order_id"
    t.bigint "user_id"
    t.bigint "container_id"
    t.string "event"
    t.integer "adjustment"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "warehouse_id"
    t.integer "warehouse_adjustment"
    t.integer "warehouse_quantity"
    t.index ["container_id"], name: "index_inventory_histories_on_container_id"
    t.index ["order_id"], name: "index_inventory_histories_on_order_id"
    t.index ["product_variant_id"], name: "index_inventory_histories_on_product_variant_id"
    t.index ["user_id"], name: "index_inventory_histories_on_user_id"
    t.index ["warehouse_id"], name: "index_inventory_histories_on_warehouse_id"
  end

  create_table "invoice_for_billings", force: :cascade do |t|
    t.bigint "order_id"
    t.string "invoice_number"
    t.float "invoice_amount"
    t.date "invoice_date"
    t.date "invoice_due_date"
    t.string "invoice_difference"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "return_id"
    t.bigint "consolidation_id"
    t.float "tax"
    t.float "qst"
    t.bigint "shipping_detail_id"
    t.index ["consolidation_id"], name: "index_invoice_for_billings_on_consolidation_id"
    t.index ["order_id"], name: "index_invoice_for_billings_on_order_id"
    t.index ["return_id"], name: "index_invoice_for_billings_on_return_id"
    t.index ["shipping_detail_id"], name: "index_invoice_for_billings_on_shipping_detail_id"
  end

  create_table "invoice_for_wgds", force: :cascade do |t|
    t.bigint "order_id"
    t.string "invoice_number"
    t.float "invoice_amount"
    t.date "invoice_date"
    t.date "invoice_due_date"
    t.string "invoice_difference"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "return_id"
    t.bigint "consolidation_id"
    t.float "tax"
    t.float "qst"
    t.bigint "shipping_detail_id"
    t.index ["consolidation_id"], name: "index_invoice_for_wgds_on_consolidation_id"
    t.index ["order_id"], name: "index_invoice_for_wgds_on_order_id"
    t.index ["return_id"], name: "index_invoice_for_wgds_on_return_id"
    t.index ["shipping_detail_id"], name: "index_invoice_for_wgds_on_shipping_detail_id"
  end

  create_table "invoice_line_items", force: :cascade do |t|
    t.bigint "invoice_id"
    t.bigint "product_variant_id"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "price"
    t.boolean "mto", default: false
    t.string "additional_notes"
    t.integer "return_id"
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
    t.index ["product_variant_id"], name: "index_invoice_line_items_on_product_variant_id"
  end

  create_table "invoice_macros", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "order_id"
    t.string "invoice_number"
    t.integer "status"
    t.string "notes"
    t.string "discount"
    t.float "discount_amount"
    t.float "tax_amount"
    t.string "shipping_method"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "employee_id"
    t.string "shipping_type"
    t.string "order_name"
    t.bigint "customer_id"
    t.integer "source"
    t.integer "payment_method"
    t.float "deposit"
    t.integer "additional_payment_method"
    t.float "additional_deposit"
    t.string "additional_notes"
    t.bigint "invoice_macro_id"
    t.date "deposit_date"
    t.date "additional_deposit_date"
    t.string "no_sale_notes"
    t.float "shipping_amount"
    t.boolean "waive_tax", default: false
    t.string "store"
    t.string "lead_note"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["employee_id"], name: "index_invoices_on_employee_id"
    t.index ["invoice_macro_id"], name: "index_invoices_on_invoice_macro_id"
    t.index ["order_id"], name: "index_invoices_on_order_id"
  end

  create_table "issue_details", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.string "main_type"
    t.string "sub_type"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["issue_id"], name: "index_issue_details_on_issue_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string "ticket"
    t.string "title"
    t.text "description"
    t.string "created_by"
    t.string "assign_to"
    t.bigint "order_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status"
    t.bigint "line_item_id"
    t.integer "issue_type"
    t.integer "shipping_charges"
    t.integer "resolution_type"
    t.string "shipping_amount"
    t.string "resolution_amount"
    t.integer "return_quantity"
    t.bigint "carrier_id"
    t.bigint "supplier_id"
    t.string "order_link"
    t.string "bill_of_lading"
    t.date "claims_submission_date"
    t.string "claims_reference"
    t.date "pickup_date"
    t.date "last_scanned_date"
    t.integer "claims_dispute"
    t.float "dispute_amount"
    t.boolean "invoice_pay"
    t.string "dispute_type"
    t.bigint "factory_id"
    t.string "chargeback_id"
    t.string "chargeback_reason"
    t.string "win_likelihood"
    t.integer "chargeback_dispute"
    t.string "outcome_notes"
    t.boolean "full_refund", default: false
    t.float "discount_amount"
    t.float "warranty_amount"
    t.string "gorgias_ticket"
    t.integer "claim_type"
    t.string "shipping_invoice"
    t.date "chargeback_date"
    t.integer "card_type"
    t.float "restocking_fee"
    t.float "repacking_fee"
    t.boolean "restocking_changed", default: false
    t.integer "return_reason"
    t.integer "shipping_claim_type"
    t.string "shipping_curbside"
    t.string "shipping_wgd"
    t.float "store_credit"
    t.integer "replacement_type"
    t.index ["carrier_id"], name: "index_issues_on_carrier_id"
    t.index ["factory_id"], name: "index_issues_on_factory_id"
    t.index ["line_item_id"], name: "index_issues_on_line_item_id"
    t.index ["order_id"], name: "index_issues_on_order_id"
    t.index ["supplier_id"], name: "index_issues_on_supplier_id"
    t.index ["user_id"], name: "index_issues_on_user_id"
  end

  create_table "leaves", force: :cascade do |t|
    t.bigint "employee_id"
    t.string "leave_type"
    t.date "start_date"
    t.date "end_date"
    t.float "duration"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "approval_date"
    t.integer "approved_by_id"
    t.index ["employee_id"], name: "index_leaves_on_employee_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "fulfillment_id"
    t.bigint "product_id"
    t.bigint "variant_id"
    t.string "shopify_line_item_id"
    t.string "fulfillable_quantity"
    t.string "fulfillment_service"
    t.string "fulfillment_status"
    t.string "grams"
    t.string "price"
    t.string "quantity"
    t.string "requires_shipping"
    t.string "sku"
    t.string "title"
    t.string "variant_title"
    t.string "vendor"
    t.string "name"
    t.string "gift_card"
    t.json "price_set"
    t.string "properties", default: [], array: true
    t.string "taxable"
    t.string "tax_lines", default: [], array: true
    t.string "total_discount"
    t.json "total_discount_set"
    t.json "origin_location"
    t.string "admin_graphql_api_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "shipping_detail_id"
    t.integer "status"
    t.bigint "pallet_shipping_id"
    t.string "order_from"
    t.bigint "container_id"
    t.integer "purchase_id"
    t.integer "purchase_item_id"
    t.boolean "reserve"
    t.boolean "clear_swatch"
    t.string "store"
    t.string "uni_line_item_id"
    t.integer "cancel_request_check"
    t.string "parent_line_item_id"
    t.bigint "replacement_reference_id"
    t.boolean "swatch_status", default: true
    t.string "additional_notes"
    t.bigint "warehouse_id"
    t.bigint "warehouse_variant_id"
    t.index ["container_id"], name: "index_line_items_on_container_id"
    t.index ["fulfillment_id"], name: "index_line_items_on_fulfillment_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["pallet_shipping_id"], name: "index_line_items_on_pallet_shipping_id"
    t.index ["product_id"], name: "index_line_items_on_product_id"
    t.index ["replacement_reference_id"], name: "index_line_items_on_replacement_reference_id"
    t.index ["shipping_detail_id"], name: "index_line_items_on_shipping_detail_id"
    t.index ["variant_id"], name: "index_line_items_on_variant_id"
    t.index ["warehouse_id"], name: "index_line_items_on_warehouse_id"
    t.index ["warehouse_variant_id"], name: "index_line_items_on_warehouse_variant_id"
  end

  create_table "local_cities", force: :cascade do |t|
    t.string "city"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "local_shipping_rates", force: :cascade do |t|
    t.integer "order_min_price"
    t.integer "order_max_price"
    t.integer "discount"
    t.string "shipping_method"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "location_histories", force: :cascade do |t|
    t.bigint "product_variant_id", null: false
    t.bigint "product_location_id"
    t.bigint "user_id"
    t.string "event"
    t.integer "adjustment"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "rack"
    t.integer "level"
    t.integer "bin"
    t.index ["product_location_id"], name: "index_location_histories_on_product_location_id"
    t.index ["product_variant_id"], name: "index_location_histories_on_product_variant_id"
    t.index ["user_id"], name: "index_location_histories_on_user_id"
  end

  create_table "market_products", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "issue_id"
    t.bigint "line_item_id"
    t.integer "status"
    t.integer "quantity"
    t.float "quote_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "sold_value"
    t.date "sold_date"
    t.string "notes"
    t.index ["issue_id"], name: "index_market_products_on_issue_id"
    t.index ["line_item_id"], name: "index_market_products_on_line_item_id"
    t.index ["order_id"], name: "index_market_products_on_order_id"
  end

  create_table "material_categories", force: :cascade do |t|
    t.string "name"
    t.string "grade"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "material_lists", force: :cascade do |t|
    t.string "material_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "merge_packing_slips", force: :cascade do |t|
    t.integer "index"
    t.string "store"
    t.integer "order_id", array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mto_warehouse_tables", force: :cascade do |t|
    t.string "war_type"
    t.integer "from_days"
    t.integer "to_days"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.string "terminal"
    t.string "delivery_method"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "type"
    t.json "params"
    t.datetime "read_at"
    t.datetime "clear_at"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "ocean_carriers", force: :cascade do |t|
    t.string "name"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "order_adjustments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "refund_id", null: false
    t.string "amount"
    t.json "shop_money"
    t.json "presentment_money"
    t.string "kind"
    t.string "reason"
    t.string "tax_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_order_adjustments_on_order_id"
    t.index ["refund_id"], name: "index_order_adjustments_on_refund_id"
  end

  create_table "order_replacements", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "replacement_reference_id"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_order_replacements_on_order_id"
    t.index ["replacement_reference_id"], name: "index_order_replacements_on_replacement_reference_id"
  end

  create_table "order_transactions", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "refund_id"
    t.string "shopify_transaction_id"
    t.string "admin_graphql_api_id"
    t.string "amount"
    t.string "authorization"
    t.string "currency"
    t.string "device_id"
    t.string "error_code"
    t.string "gateway"
    t.string "kind"
    t.string "location_id"
    t.string "message"
    t.string "parent_id"
    t.string "source_name"
    t.string "status"
    t.string "test"
    t.string "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_order_transactions_on_order_id"
    t.index ["refund_id"], name: "index_order_transactions_on_refund_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "shopify_order_id"
    t.string "contact_email"
    t.string "currency"
    t.string "current_subtotal_price"
    t.string "current_total_discounts"
    t.string "current_total_tax"
    t.string "financial_status"
    t.string "fulfillment_status"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "customer_id"
    t.string "store"
    t.integer "status"
    t.string "order_type"
    t.string "tags"
    t.json "discount_codes"
    t.json "tax_lines"
    t.datetime "hold_until_date"
    t.datetime "cancel_request_date"
    t.datetime "cancelled_date"
    t.string "cancel_reason"
    t.text "order_notes"
    t.string "uni_order_id"
    t.string "hold_reason"
    t.integer "status_for_M2"
    t.integer "sent_mail"
    t.string "kind_of_order"
    t.date "eta"
    t.integer "order_link", array: true
    t.date "staging_date"
    t.integer "pending_payment_notification"
    t.string "payment_method"
    t.string "store_credit"
    t.integer "status_for_shipping"
    t.string "old_shopify_order_id"
    t.bigint "employee_id"
    t.string "eta_from"
    t.string "eta_to"
    t.datetime "eta_data_from"
    t.datetime "eta_data_to"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["employee_id"], name: "index_orders_on_employee_id"
  end

  create_table "pallet_shippings", force: :cascade do |t|
    t.bigint "pallet_id"
    t.bigint "order_id", null: false
    t.bigint "shipping_detail_id", null: false
    t.string "height"
    t.string "length"
    t.string "weight"
    t.string "width"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "pallet_type"
    t.boolean "auto_calc", default: true
    t.index ["order_id"], name: "index_pallet_shippings_on_order_id"
    t.index ["pallet_id"], name: "index_pallet_shippings_on_pallet_id"
    t.index ["shipping_detail_id"], name: "index_pallet_shippings_on_shipping_detail_id"
  end

  create_table "pallets", force: :cascade do |t|
    t.string "pallet_size"
    t.string "pallet_height"
    t.string "pallet_width"
    t.string "pallet_length"
    t.string "pallet_weight"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "payment_method_details", force: :cascade do |t|
    t.bigint "charge_id", null: false
    t.json "card"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["charge_id"], name: "index_payment_method_details_on_charge_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "positions", force: :cascade do |t|
    t.bigint "department_id"
    t.string "name"
    t.boolean "is_manager"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id"], name: "index_positions_on_department_id"
  end

  create_table "posting_sections", force: :cascade do |t|
    t.bigint "order_id"
    t.string "dispute_pay_reason"
    t.string "dispute_not_paid_reason"
    t.string "amount"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "shipping_detail_id"
    t.integer "responded"
    t.boolean "posted"
    t.integer "status"
    t.string "invoice_type"
    t.bigint "return_id"
    t.bigint "consolidation_id"
    t.boolean "white_glove"
    t.index ["consolidation_id"], name: "index_posting_sections_on_consolidation_id"
    t.index ["order_id"], name: "index_posting_sections_on_order_id"
    t.index ["return_id"], name: "index_posting_sections_on_return_id"
    t.index ["shipping_detail_id"], name: "index_posting_sections_on_shipping_detail_id"
  end

  create_table "preorder_from_another_warehouse_tables", force: :cascade do |t|
    t.string "war_type"
    t.integer "from_days"
    t.integer "to_days"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.string "terminal"
    t.string "delivery_method"
  end

  create_table "preorder_warehouse_tables", force: :cascade do |t|
    t.string "war_type"
    t.integer "from_days"
    t.integer "to_days"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.string "terminal"
    t.string "delivery_method"
  end

  create_table "product_images", force: :cascade do |t|
    t.string "shopify_image_id"
    t.integer "position"
    t.string "alt"
    t.string "width"
    t.string "height"
    t.string "src"
    t.text "variant_ids", default: [], array: true
    t.string "admin_graphql_api_id"
    t.bigint "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_locations", force: :cascade do |t|
    t.string "rack"
    t.string "level"
    t.string "bin"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
  end

  create_table "product_parts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "product_variant_locations", force: :cascade do |t|
    t.bigint "product_variant_id"
    t.bigint "product_location_id"
    t.integer "product_quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_location_id"], name: "index_product_variant_locations_on_product_location_id"
    t.index ["product_variant_id"], name: "index_product_variant_locations_on_product_variant_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "shopify_variant_id"
    t.string "title"
    t.string "price"
    t.string "sku"
    t.integer "position"
    t.string "inventory_policy"
    t.string "compare_at_price"
    t.string "fulfillment_service"
    t.string "inventory_management"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.string "taxable"
    t.string "barcode"
    t.string "grams"
    t.string "weight"
    t.string "weight_unit"
    t.string "inventory_item_id"
    t.integer "inventory_quantity"
    t.integer "old_inventory_quantity"
    t.string "requires_shipping"
    t.string "admin_graphql_api_id"
    t.bigint "product_id"
    t.string "image_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "fabric_use"
    t.string "unit_cost"
    t.string "slug"
    t.string "store"
    t.integer "inventory_limit"
    t.boolean "variant_fulfillable"
    t.integer "carton"
    t.integer "height"
    t.integer "width"
    t.integer "length"
    t.bigint "supplier_id"
    t.string "uni_variant_id"
    t.string "product_category"
    t.string "stock"
    t.string "factory"
    t.string "discounted_price"
    t.integer "received_quantity"
    t.integer "to_do_quantity"
    t.bigint "category_id"
    t.string "container_count"
    t.bigint "subcategory_id"
    t.string "special_price"
    t.integer "m2_product_id"
    t.integer "max_limit"
    t.integer "supplier_price"
    t.string "c2c_swatch"
    t.boolean "oversized"
    t.string "old_shopify_variant_id"
    t.bigint "product_part_id"
    t.bigint "material_category_id"
    t.string "image_url"
    t.integer "stock_update"
    t.index ["category_id"], name: "index_product_variants_on_category_id"
    t.index ["material_category_id"], name: "index_product_variants_on_material_category_id"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["product_part_id"], name: "index_product_variants_on_product_part_id"
    t.index ["slug"], name: "index_product_variants_on_slug", unique: true
    t.index ["subcategory_id"], name: "index_product_variants_on_subcategory_id"
    t.index ["supplier_id"], name: "index_product_variants_on_supplier_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "shopify_product_id"
    t.string "title"
    t.text "body_html"
    t.string "vendor"
    t.string "product_type"
    t.string "handle"
    t.string "template_suffix"
    t.string "status"
    t.string "published_scope"
    t.string "admin_graphql_api_id"
    t.text "tags"
    t.datetime "published_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "supplier_id"
    t.string "slug"
    t.string "store"
    t.string "sku"
    t.integer "quantity"
    t.string "uni_product_id"
    t.bigint "category_id"
    t.string "factory"
    t.string "var_sku"
    t.bigint "subcategory_id"
    t.integer "m2_product_id"
    t.bigint "factory_id"
    t.string "m2_original"
    t.boolean "oversized"
    t.string "old_shopify_product_id"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["factory_id"], name: "index_products_on_factory_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["subcategory_id"], name: "index_products_on_subcategory_id"
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "purchase_cancelreqs", force: :cascade do |t|
    t.bigint "purchase_id", null: false
    t.bigint "purchase_item_id", null: false
    t.integer "cancel_quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status"
    t.index ["purchase_id"], name: "index_purchase_cancelreqs_on_purchase_id"
    t.index ["purchase_item_id"], name: "index_purchase_cancelreqs_on_purchase_item_id"
  end

  create_table "purchase_items", force: :cascade do |t|
    t.bigint "line_item_id"
    t.bigint "purchase_id"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "product_id"
    t.bigint "product_variant_id"
    t.string "purchase_type"
    t.integer "status"
    t.datetime "etc_date"
    t.text "comment_description"
    t.bigint "order_id"
    t.float "container_cost"
    t.float "item_cbm"
    t.bigint "warehouse_id"
    t.string "state"
    t.integer "preorder_quantity"
    t.index ["line_item_id"], name: "index_purchase_items_on_line_item_id"
    t.index ["order_id"], name: "index_purchase_items_on_order_id"
    t.index ["product_id"], name: "index_purchase_items_on_product_id"
    t.index ["product_variant_id"], name: "index_purchase_items_on_product_variant_id"
    t.index ["purchase_id"], name: "index_purchase_items_on_purchase_id"
    t.index ["warehouse_id"], name: "index_purchase_items_on_warehouse_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "supplier_id"
    t.bigint "order_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.index ["order_id"], name: "index_purchases_on_order_id"
    t.index ["supplier_id"], name: "index_purchases_on_supplier_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.bigint "transactions_id", null: false
    t.string "amount"
    t.json "balance_transaction"
    t.string "object"
    t.string "reason"
    t.string "status"
    t.string "created"
    t.string "currency"
    t.json "payment_method_details"
    t.json "mit_params"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transactions_id"], name: "index_receipts_on_transactions_id"
  end

  create_table "record_sections", force: :cascade do |t|
    t.bigint "order_id"
    t.string "reason"
    t.string "amount"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "shipping_detail_id"
    t.integer "responded"
    t.boolean "posted"
    t.integer "status"
    t.string "invoice_type"
    t.bigint "return_id"
    t.bigint "consolidation_id"
    t.boolean "white_glove"
    t.index ["consolidation_id"], name: "index_record_sections_on_consolidation_id"
    t.index ["order_id"], name: "index_record_sections_on_order_id"
    t.index ["return_id"], name: "index_record_sections_on_return_id"
    t.index ["shipping_detail_id"], name: "index_record_sections_on_shipping_detail_id"
  end

  create_table "refund_line_items", force: :cascade do |t|
    t.bigint "refund_id", null: false
    t.bigint "line_item_id", null: false
    t.string "location_id"
    t.string "quantity"
    t.string "restock_type"
    t.string "subtotal"
    t.json "subtotal_shop_money"
    t.json "subtotal_presentment_money"
    t.string "total_tax"
    t.json "total_tax_shop_money"
    t.json "total_tax_presentment_money"
    t.json "line_item"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_item_id"], name: "index_refund_line_items_on_line_item_id"
    t.index ["refund_id"], name: "index_refund_line_items_on_refund_id"
  end

  create_table "refunds", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "shopify_refund_id"
    t.string "admin_graphql_api_id"
    t.string "note"
    t.string "restock"
    t.string "duties", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_refunds_on_order_id"
  end

  create_table "remote_postal_codes", force: :cascade do |t|
    t.string "postal_code"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "remote_shipping_rates", force: :cascade do |t|
    t.integer "order_min_price"
    t.integer "order_max_price"
    t.integer "discount"
    t.string "shipping_method"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "repair_services", force: :cascade do |t|
    t.string "repair_type"
    t.float "amount"
    t.bigint "issue_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "expense_id"
    t.index ["issue_id"], name: "index_repair_services_on_issue_id"
  end

  create_table "replacement_references", force: :cascade do |t|
    t.bigint "product_variant_id"
    t.string "name"
    t.index ["product_variant_id"], name: "index_replacement_references_on_product_variant_id"
  end

  create_table "reserve_items", force: :cascade do |t|
    t.bigint "line_item_id"
    t.bigint "carton_id"
    t.integer "quantity"
    t.index ["carton_id"], name: "index_reserve_items_on_carton_id"
    t.index ["line_item_id"], name: "index_reserve_items_on_line_item_id"
  end

  create_table "return_line_items", force: :cascade do |t|
    t.integer "status"
    t.integer "quantity"
    t.boolean "package_condition", default: false
    t.boolean "product_condition", default: false
    t.boolean "new_packaging", default: false
    t.float "market_value"
    t.string "notes"
    t.bigint "return_id"
    t.bigint "line_item_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_item_id"], name: "index_return_line_items_on_line_item_id"
    t.index ["return_id"], name: "index_return_line_items_on_return_id"
  end

  create_table "return_products", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "issue_id"
    t.bigint "line_item_id"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "quantity"
    t.string "store"
    t.bigint "product_variant_id"
    t.index ["issue_id"], name: "index_return_products_on_issue_id"
    t.index ["line_item_id"], name: "index_return_products_on_line_item_id"
    t.index ["order_id"], name: "index_return_products_on_order_id"
    t.index ["product_variant_id"], name: "index_return_products_on_product_variant_id"
  end

  create_table "returns", force: :cascade do |t|
    t.integer "status"
    t.boolean "customer_return", default: false
    t.boolean "disposal", default: false
    t.string "return_reason"
    t.date "return_date"
    t.string "return_carrier"
    t.string "return_number"
    t.float "return_quote"
    t.string "return_company"
    t.string "return_contact"
    t.string "return_address"
    t.string "return_city"
    t.string "return_state"
    t.string "return_country"
    t.string "return_zip_code"
    t.bigint "order_id"
    t.bigint "issue_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "shipping_cost"
    t.bigint "carrier_id"
    t.string "white_glove_address"
    t.integer "truck_broker_id"
    t.string "name"
    t.bigint "white_glove_directory_id"
    t.bigint "white_glove_address_id"
    t.index ["carrier_id"], name: "index_returns_on_carrier_id"
    t.index ["issue_id"], name: "index_returns_on_issue_id"
    t.index ["order_id"], name: "index_returns_on_order_id"
    t.index ["white_glove_address_id"], name: "index_returns_on_white_glove_address_id"
    t.index ["white_glove_directory_id"], name: "index_returns_on_white_glove_directory_id"
  end

  create_table "review_sections", force: :cascade do |t|
    t.bigint "order_id"
    t.string "reason"
    t.string "amount"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "shipping_detail_id"
    t.integer "responded"
    t.string "invoice_type"
    t.bigint "return_id"
    t.bigint "consolidation_id"
    t.boolean "white_glove"
    t.index ["consolidation_id"], name: "index_review_sections_on_consolidation_id"
    t.index ["order_id"], name: "index_review_sections_on_order_id"
    t.index ["return_id"], name: "index_review_sections_on_return_id"
    t.index ["shipping_detail_id"], name: "index_review_sections_on_shipping_detail_id"
  end

  create_table "risk_indicators", force: :cascade do |t|
    t.string "risk_type"
    t.integer "assigned_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "shipment_codes", force: :cascade do |t|
    t.string "sku_for_discount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
  end

  create_table "shipping_addresses", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "country"
    t.string "company"
    t.string "country_code"
    t.string "first_name"
    t.string "last_name"
    t.string "latitude"
    t.string "longitude"
    t.string "name"
    t.string "phone"
    t.string "province"
    t.string "province_code"
    t.string "zip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.index ["order_id"], name: "index_shipping_addresses_on_order_id"
  end

  create_table "shipping_costs", force: :cascade do |t|
    t.bigint "shipping_detail_id", null: false
    t.string "cost_type"
    t.string "name"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipping_detail_id"], name: "index_shipping_costs_on_shipping_detail_id"
  end

  create_table "shipping_details", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "carrier_id"
    t.string "estimated_shipping_cost"
    t.date "date_booked"
    t.date "hold_until_date"
    t.boolean "white_glove_delivery"
    t.text "shipping_notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.integer "status"
    t.string "local_pickup"
    t.boolean "printed_bol"
    t.boolean "printed_packing_slip"
    t.string "tracking_number"
    t.datetime "shipped_date"
    t.string "actual_invoiced"
    t.string "white_glove_fee"
    t.json "additional_charges"
    t.json "additional_fees"
    t.integer "upgrade", default: 0
    t.date "pickup_start_date"
    t.date "pickup_end_date"
    t.time "pickup_start_time"
    t.time "pickup_end_time"
    t.date "delivery_start_date"
    t.date "delivery_end_date"
    t.time "delivery_start_time"
    t.time "delivery_end_time"
    t.string "map_id"
    t.string "tracking_url_for_ship"
    t.string "error_notes"
    t.bigint "white_glove_address_id"
    t.string "remote"
    t.string "overhang"
    t.string "note"
    t.integer "status_for_shipping"
    t.float "local_white_glove_delivery", default: 0.0
    t.bigint "consolidation_id"
    t.bigint "white_glove_directory_id"
    t.date "eta_from"
    t.date "eta_to"
    t.index ["carrier_id"], name: "index_shipping_details_on_carrier_id"
    t.index ["consolidation_id"], name: "index_shipping_details_on_consolidation_id"
    t.index ["order_id"], name: "index_shipping_details_on_order_id"
    t.index ["white_glove_address_id"], name: "index_shipping_details_on_white_glove_address_id"
    t.index ["white_glove_directory_id"], name: "index_shipping_details_on_white_glove_directory_id"
  end

  create_table "shipping_lines", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "carrier_identifier"
    t.string "code"
    t.string "delivery_category"
    t.string "discounted_price"
    t.json "discount_price_set"
    t.string "phone"
    t.string "price"
    t.json "price_set"
    t.string "requested_fulfillment_service_id"
    t.string "source"
    t.string "title"
    t.string "tax_lines", default: [], array: true
    t.string "discount_allocations", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "editable", default: false
    t.index ["order_id"], name: "index_shipping_lines_on_order_id"
  end

  create_table "shipping_quotes", force: :cascade do |t|
    t.bigint "shipping_detail_id"
    t.bigint "carrier_id"
    t.float "amount"
    t.boolean "selected"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "truck_broker_id"
    t.index ["carrier_id"], name: "index_shipping_quotes_on_carrier_id"
    t.index ["shipping_detail_id"], name: "index_shipping_quotes_on_shipping_detail_id"
    t.index ["truck_broker_id"], name: "index_shipping_quotes_on_truck_broker_id"
  end

  create_table "showroom_manage_permissions", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "showroom_id"
    t.boolean "permission", default: false
    t.index ["employee_id"], name: "index_showroom_manage_permissions_on_employee_id"
    t.index ["showroom_id"], name: "index_showroom_manage_permissions_on_showroom_id"
  end

  create_table "showrooms", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "warehouse_id"
    t.index ["warehouse_id"], name: "index_showrooms_on_warehouse_id"
  end

  create_table "standard_shipping_rates", force: :cascade do |t|
    t.integer "order_min_price"
    t.integer "order_max_price"
    t.integer "discount"
    t.string "shipping_method"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "state_days", force: :cascade do |t|
    t.string "state"
    t.string "start_days"
    t.string "end_days"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "region"
    t.string "name"
  end

  create_table "state_zip_codes", force: :cascade do |t|
    t.bigint "tax_rate_id"
    t.string "zip_code"
    t.boolean "remote"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tax_rate_id"], name: "index_state_zip_codes_on_tax_rate_id"
  end

  create_table "store_addresses", force: :cascade do |t|
    t.string "store"
    t.text "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "city"
    t.string "state"
    t.string "zip"
    t.float "exchange_rate"
  end

  create_table "subcategories", force: :cascade do |t|
    t.bigint "category_id"
    t.text "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_subcategories_on_category_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
  end

  create_table "swatch_products", force: :cascade do |t|
    t.string "description"
    t.string "swatch_sku"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "material_list_id"
    t.index ["material_list_id"], name: "index_swatch_products_on_material_list_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "owner_id"
    t.date "due_date"
    t.integer "priority"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status"
    t.string "title"
    t.string "tag_user_id"
    t.string "tag_order_id"
    t.date "reminder_date"
    t.index ["owner_id"], name: "index_tasks_on_owner_id"
  end

  create_table "tax_rates", force: :cascade do |t|
    t.string "state"
    t.string "combined_rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.bigint "warehouse_id"
    t.integer "to_zip_code"
    t.integer "from_zip_code"
    t.index ["warehouse_id"], name: "index_tax_rates_on_warehouse_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "title"
    t.string "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "transfer_tables", force: :cascade do |t|
    t.string "war_type"
    t.integer "from_days"
    t.integer "to_days"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "terminal"
    t.string "store"
    t.string "delivery_method"
  end

  create_table "truck_brokers", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.string "name"
    t.string "permissions"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "overview_view", default: true
    t.boolean "overview_cru", default: true
    t.boolean "orders_view", default: true
    t.boolean "orders_cru", default: true
    t.boolean "inventory_view", default: true
    t.boolean "inventory_cru", default: true
    t.boolean "dc_view", default: true
    t.boolean "dc_cru", default: true
    t.boolean "issues_view", default: true
    t.boolean "issues_cru", default: true
    t.boolean "admin_view", default: true
    t.boolean "admin_cru", default: true
    t.boolean "hr_view", default: true
    t.boolean "hr_cru", default: true
    t.boolean "manager_view", default: true
    t.boolean "manager_cru", default: true
    t.boolean "permission_us", default: true
    t.boolean "permission_ca", default: true
    t.boolean "inventory_admin_cru", default: true
    t.boolean "billing_view"
    t.boolean "billing_cru"
    t.boolean "board_view"
    t.boolean "board_cru"
    t.boolean "replacement_view"
    t.boolean "replacement_cru"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "slug"
    t.bigint "user_group_id"
    t.bigint "supplier_id"
    t.json "notification_setting", default: {}
    t.boolean "deactivate"
    t.string "username"
    t.bigint "employee_id"
    t.bigint "warehouse_id"
    t.integer "deal_view_id"
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.string "otp_backup_codes", default: [], array: true
    t.datetime "last_otp_verify_date"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["employee_id"], name: "index_users_on_employee_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["supplier_id"], name: "index_users_on_supplier_id"
    t.index ["user_group_id"], name: "index_users_on_user_group_id"
    t.index ["warehouse_id"], name: "index_users_on_warehouse_id"
  end

  create_table "warehouse_addresses", force: :cascade do |t|
    t.bigint "warehouse_id", null: false
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "country"
    t.string "country_code"
    t.string "latitude"
    t.string "longitude"
    t.string "name"
    t.string "phone"
    t.string "province"
    t.string "zip"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["warehouse_id"], name: "index_warehouse_addresses_on_warehouse_id"
  end

  create_table "warehouse_and_tax_rates", force: :cascade do |t|
    t.bigint "warehouse_id"
    t.bigint "tax_rate_id"
    t.string "terminal"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tax_rate_id"], name: "index_warehouse_and_tax_rates_on_tax_rate_id"
    t.index ["warehouse_id"], name: "index_warehouse_and_tax_rates_on_warehouse_id"
  end

  create_table "warehouse_permissions", force: :cascade do |t|
    t.bigint "user_group_id"
    t.bigint "warehouse_id"
    t.boolean "permission", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_group_id"], name: "index_warehouse_permissions_on_user_group_id"
    t.index ["warehouse_id"], name: "index_warehouse_permissions_on_warehouse_id"
  end

  create_table "warehouse_transfer_items", force: :cascade do |t|
    t.bigint "product_variant_id"
    t.bigint "warehouse_variant_id"
    t.string "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "warehouse_transfer_order_id"
    t.string "store"
    t.index ["product_variant_id"], name: "index_warehouse_transfer_items_on_product_variant_id"
    t.index ["warehouse_transfer_order_id"], name: "index_warehouse_transfer_items_on_warehouse_transfer_order_id"
    t.index ["warehouse_variant_id"], name: "index_warehouse_transfer_items_on_warehouse_variant_id"
  end

  create_table "warehouse_transfer_orders", force: :cascade do |t|
    t.bigint "from_warehouse_id"
    t.bigint "to_warehouse_id"
    t.string "name"
    t.integer "status"
    t.date "etc_date"
    t.string "customer_name"
    t.string "from_store"
    t.string "to_store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["from_warehouse_id"], name: "index_warehouse_transfer_orders_on_from_warehouse_id"
    t.index ["to_warehouse_id"], name: "index_warehouse_transfer_orders_on_to_warehouse_id"
  end

  create_table "warehouse_variants", force: :cascade do |t|
    t.bigint "product_variant_id"
    t.bigint "product_variant_location_id"
    t.bigint "warehouse_id"
    t.string "warehouse_quantity"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_variant_id"], name: "index_warehouse_variants_on_product_variant_id"
    t.index ["product_variant_location_id"], name: "index_warehouse_variants_on_product_variant_location_id"
    t.index ["warehouse_id"], name: "index_warehouse_variants_on_warehouse_id"
  end

  create_table "warehouses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.bigint "store_address_id"
    t.bigint "tax_rate_id"
    t.string "code"
    t.index ["store_address_id"], name: "index_warehouses_on_store_address_id"
    t.index ["tax_rate_id"], name: "index_warehouses_on_tax_rate_id"
  end

  create_table "wgd_warehouse_tables", force: :cascade do |t|
    t.string "war_type"
    t.integer "from_days"
    t.integer "to_days"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "store"
    t.string "terminal"
    t.string "delivery_method"
  end

  create_table "white_glove_addresses", force: :cascade do |t|
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "country"
    t.string "company"
    t.string "contact"
    t.string "phone"
    t.string "zip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.string "notes"
    t.boolean "delivery_notification"
    t.string "receiving_hours"
    t.bigint "white_glove_directory_id"
    t.index ["white_glove_directory_id"], name: "index_white_glove_addresses_on_white_glove_directory_id"
  end

  create_table "white_glove_directories", force: :cascade do |t|
    t.string "company_name"
    t.string "store"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "accounting_expenses", "expense_categories"
  add_foreign_key "accounting_expenses", "expense_payment_methods"
  add_foreign_key "accounting_expenses", "expense_subcategories"
  add_foreign_key "accounting_expenses", "expense_types"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "announcements", "users"
  add_foreign_key "appointments", "customers"
  add_foreign_key "appointments", "employees"
  add_foreign_key "appointments", "showrooms"
  add_foreign_key "billing_addresses", "orders"
  add_foreign_key "board_pages", "board_sections"
  add_foreign_key "carrier_contacts", "carriers"
  add_foreign_key "carriers", "truck_brokers"
  add_foreign_key "carton_details", "products"
  add_foreign_key "carton_locations", "cartons"
  add_foreign_key "carton_locations", "product_locations"
  add_foreign_key "cartons", "carton_details"
  add_foreign_key "cartons", "product_variants"
  add_foreign_key "charges", "receipts"
  add_foreign_key "checklists", "checklists", column: "list_group_id"
  add_foreign_key "checklists", "employees"
  add_foreign_key "claims_refund_items", "issues"
  add_foreign_key "claims_refund_items", "line_items"
  add_foreign_key "comments", "users"
  add_foreign_key "commission_rates", "employees"
  add_foreign_key "container_charges", "containers"
  add_foreign_key "container_costs", "containers"
  add_foreign_key "container_orders", "line_items"
  add_foreign_key "container_orders", "orders"
  add_foreign_key "container_orders", "product_variants"
  add_foreign_key "container_postings", "containers"
  add_foreign_key "container_purchases", "containers"
  add_foreign_key "container_purchases", "purchase_items"
  add_foreign_key "container_records", "containers"
  add_foreign_key "containers", "container_postings"
  add_foreign_key "containers", "container_records"
  add_foreign_key "containers", "ocean_carriers"
  add_foreign_key "containers", "suppliers"
  add_foreign_key "containers", "warehouses"
  add_foreign_key "curbside_cities", "tax_rates"
  add_foreign_key "customer_billing_addresses", "customers"
  add_foreign_key "customer_shipping_addresses", "customers"
  add_foreign_key "customers", "employees"
  add_foreign_key "customers", "risk_indicators"
  add_foreign_key "employees", "departments"
  add_foreign_key "employees", "employees", column: "manager_id"
  add_foreign_key "employees", "positions"
  add_foreign_key "employees", "showrooms"
  add_foreign_key "expense_categories", "expense_types"
  add_foreign_key "expense_payment_relations", "expense_payment_methods"
  add_foreign_key "expense_payment_relations", "expense_subcategories"
  add_foreign_key "expense_postings", "expenses"
  add_foreign_key "expense_subcategories", "expense_categories"
  add_foreign_key "expenses", "employees"
  add_foreign_key "expenses", "employees", column: "approver_id"
  add_foreign_key "expenses", "expense_categories"
  add_foreign_key "expenses", "expense_payment_methods"
  add_foreign_key "expenses", "expense_subcategories"
  add_foreign_key "expenses", "expense_types"
  add_foreign_key "fulfillments", "orders"
  add_foreign_key "inventory_histories", "containers"
  add_foreign_key "inventory_histories", "orders"
  add_foreign_key "inventory_histories", "product_variants"
  add_foreign_key "inventory_histories", "users"
  add_foreign_key "inventory_histories", "warehouses"
  add_foreign_key "invoice_for_billings", "consolidations"
  add_foreign_key "invoice_for_billings", "orders"
  add_foreign_key "invoice_for_billings", "returns"
  add_foreign_key "invoice_for_billings", "shipping_details"
  add_foreign_key "invoice_for_wgds", "consolidations"
  add_foreign_key "invoice_for_wgds", "orders"
  add_foreign_key "invoice_for_wgds", "returns"
  add_foreign_key "invoice_for_wgds", "shipping_details"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoice_line_items", "product_variants"
  add_foreign_key "invoices", "customers"
  add_foreign_key "invoices", "employees"
  add_foreign_key "invoices", "invoice_macros"
  add_foreign_key "invoices", "orders"
  add_foreign_key "issue_details", "issues"
  add_foreign_key "issues", "carriers"
  add_foreign_key "issues", "factories"
  add_foreign_key "issues", "line_items"
  add_foreign_key "issues", "orders"
  add_foreign_key "issues", "suppliers"
  add_foreign_key "issues", "users"
  add_foreign_key "leaves", "employees"
  add_foreign_key "line_items", "containers"
  add_foreign_key "line_items", "fulfillments"
  add_foreign_key "line_items", "orders"
  add_foreign_key "line_items", "pallet_shippings"
  add_foreign_key "line_items", "product_variants", column: "variant_id"
  add_foreign_key "line_items", "products"
  add_foreign_key "line_items", "replacement_references"
  add_foreign_key "line_items", "shipping_details"
  add_foreign_key "line_items", "warehouse_variants"
  add_foreign_key "line_items", "warehouses"
  add_foreign_key "location_histories", "product_locations"
  add_foreign_key "location_histories", "product_variants"
  add_foreign_key "location_histories", "users"
  add_foreign_key "market_products", "issues"
  add_foreign_key "market_products", "line_items"
  add_foreign_key "market_products", "orders"
  add_foreign_key "order_adjustments", "orders"
  add_foreign_key "order_adjustments", "refunds"
  add_foreign_key "order_replacements", "orders"
  add_foreign_key "order_replacements", "replacement_references"
  add_foreign_key "order_transactions", "orders"
  add_foreign_key "order_transactions", "refunds"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "employees"
  add_foreign_key "pallet_shippings", "orders"
  add_foreign_key "pallet_shippings", "pallets"
  add_foreign_key "pallet_shippings", "shipping_details"
  add_foreign_key "payment_method_details", "charges"
  add_foreign_key "positions", "departments"
  add_foreign_key "posting_sections", "consolidations"
  add_foreign_key "posting_sections", "orders"
  add_foreign_key "posting_sections", "returns"
  add_foreign_key "posting_sections", "shipping_details"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_variant_locations", "product_locations"
  add_foreign_key "product_variant_locations", "product_variants"
  add_foreign_key "product_variants", "categories"
  add_foreign_key "product_variants", "material_categories"
  add_foreign_key "product_variants", "product_parts"
  add_foreign_key "product_variants", "products"
  add_foreign_key "product_variants", "subcategories"
  add_foreign_key "product_variants", "suppliers"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "factories"
  add_foreign_key "products", "subcategories"
  add_foreign_key "purchase_cancelreqs", "purchase_items"
  add_foreign_key "purchase_cancelreqs", "purchases"
  add_foreign_key "purchase_items", "line_items"
  add_foreign_key "purchase_items", "orders"
  add_foreign_key "purchase_items", "product_variants"
  add_foreign_key "purchase_items", "products"
  add_foreign_key "purchase_items", "purchases"
  add_foreign_key "purchase_items", "warehouses"
  add_foreign_key "purchases", "orders"
  add_foreign_key "purchases", "suppliers"
  add_foreign_key "receipts", "order_transactions", column: "transactions_id"
  add_foreign_key "record_sections", "consolidations"
  add_foreign_key "record_sections", "orders"
  add_foreign_key "record_sections", "returns"
  add_foreign_key "record_sections", "shipping_details"
  add_foreign_key "refund_line_items", "line_items"
  add_foreign_key "refund_line_items", "refunds"
  add_foreign_key "refunds", "orders"
  add_foreign_key "repair_services", "issues"
  add_foreign_key "replacement_references", "product_variants"
  add_foreign_key "reserve_items", "cartons"
  add_foreign_key "reserve_items", "line_items"
  add_foreign_key "return_line_items", "line_items"
  add_foreign_key "return_line_items", "returns"
  add_foreign_key "return_products", "issues"
  add_foreign_key "return_products", "line_items"
  add_foreign_key "return_products", "orders"
  add_foreign_key "return_products", "product_variants"
  add_foreign_key "returns", "carriers"
  add_foreign_key "returns", "issues"
  add_foreign_key "returns", "orders"
  add_foreign_key "returns", "white_glove_addresses"
  add_foreign_key "returns", "white_glove_directories"
  add_foreign_key "review_sections", "consolidations"
  add_foreign_key "review_sections", "orders"
  add_foreign_key "review_sections", "returns"
  add_foreign_key "review_sections", "shipping_details"
  add_foreign_key "shipping_addresses", "orders"
  add_foreign_key "shipping_costs", "shipping_details"
  add_foreign_key "shipping_details", "carriers"
  add_foreign_key "shipping_details", "consolidations"
  add_foreign_key "shipping_details", "orders"
  add_foreign_key "shipping_details", "white_glove_addresses"
  add_foreign_key "shipping_details", "white_glove_directories"
  add_foreign_key "shipping_lines", "orders"
  add_foreign_key "shipping_quotes", "carriers"
  add_foreign_key "shipping_quotes", "shipping_details"
  add_foreign_key "shipping_quotes", "truck_brokers"
  add_foreign_key "showroom_manage_permissions", "employees"
  add_foreign_key "showroom_manage_permissions", "showrooms"
  add_foreign_key "showrooms", "warehouses"
  add_foreign_key "state_zip_codes", "tax_rates"
  add_foreign_key "subcategories", "categories"
  add_foreign_key "swatch_products", "material_lists"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tasks", "users", column: "owner_id"
  add_foreign_key "tax_rates", "warehouses"
  add_foreign_key "users", "employees"
  add_foreign_key "users", "suppliers"
  add_foreign_key "users", "user_groups"
  add_foreign_key "users", "warehouses"
  add_foreign_key "warehouse_addresses", "warehouses"
  add_foreign_key "warehouse_and_tax_rates", "tax_rates"
  add_foreign_key "warehouse_and_tax_rates", "warehouses"
  add_foreign_key "warehouse_permissions", "user_groups"
  add_foreign_key "warehouse_permissions", "warehouses"
  add_foreign_key "warehouse_transfer_items", "product_variants"
  add_foreign_key "warehouse_transfer_items", "warehouse_transfer_orders"
  add_foreign_key "warehouse_transfer_items", "warehouse_variants"
  add_foreign_key "warehouse_transfer_orders", "warehouses", column: "from_warehouse_id"
  add_foreign_key "warehouse_transfer_orders", "warehouses", column: "to_warehouse_id"
  add_foreign_key "warehouse_variants", "product_variant_locations"
  add_foreign_key "warehouse_variants", "product_variants"
  add_foreign_key "warehouse_variants", "warehouses"
  add_foreign_key "warehouses", "store_addresses"
  add_foreign_key "warehouses", "tax_rates"
  add_foreign_key "white_glove_addresses", "white_glove_directories"
end
