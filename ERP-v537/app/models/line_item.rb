class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :fulfillment, optional: true
  belongs_to :product, optional: true
  belongs_to :variant, class_name: 'ProductVariant', optional: true
  belongs_to :shipping_detail, optional: true
  belongs_to :container, optional: true
  belongs_to :warehouse, optional: true
  belongs_to :warehouse_variant, optional: true

  belongs_to :pallet_shipping, optional: true
  has_many :claims_refund_items, dependent: :destroy
  has_many :return_line_items, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :purchase_items, dependent: :destroy
  has_many :purchases, through: :purchase_items

  has_many :reserve_items, dependent: :destroy

  scope :non_swatches, -> { where("LENGTH(sku) > 2") }

  scope :swatches, -> { where("LENGTH(sku) < 3") }

  scope :set_store, ->(store) { where(store: store) }

  enum status: [ :not_started, :in_production, :container_ready, :ready, :shipped, :en_route, :cancelled, :returned_order ], _default: :not_started

  enum cancel_request_check: [ :requested, :item_cancelled, :partial_cancelled ]

  audited associated_with: :order

  def formatted_title
    "#{title} | #{sku}"
  end

  LineItem.non_audited_columns = [:id, :fulfillment_id, :product_id, :variant_id, :shopify_line_item_id,
                                 :fulfillable_quantity, :fulfillment_service, :fulfillment_status, :grams,
                                 :price, :quantity, :requires_shipping, :sku, :title, :variant_title, 
                                 :vendor, :name, :gift_card, :price_set, :properties, :taxable, :tax_lines,
                                 :total_discount, :total_discount_set, :origin_location, :admin_graphql_api_id,
                                 :created_at, :updated_at, :shipping_detail_id, :pallet_shipping_id, :order_from,
                                 :clear_swatch, :parent_line_item_id ]

end
