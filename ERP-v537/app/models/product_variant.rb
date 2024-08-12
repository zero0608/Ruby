class ProductVariant < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :subcategory, optional: true
  belongs_to :product, optional: true
  belongs_to :product_image, optional: true, class_name: 'ProductImage', foreign_key: 'image_id'
  belongs_to :supplier, optional: true

  has_many :line_items, foreign_key: "variant_id", dependent: :nullify
  has_many :container_orders, dependent: :destroy

  has_many :purchase_items, dependent: :destroy
  has_many :purchases, through: :purchase_items
  has_many :inventory_histories, dependent: :destroy
  has_many :location_histories, dependent: :destroy
  has_many :product_variant_locations, dependent: :nullify
  has_many :product_locations, through: :product_variant_locations
  has_many :warehouse_variants, dependent: :nullify
  has_many :warehouses, through: :warehouse_variants, dependent: :nullify

  has_many :cartons,  dependent: :destroy
  
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :invoice_line_items, dependent: :destroy

  belongs_to :product_part, optional: true
  has_many :replacement_references, dependent: :nullify

  accepts_nested_attributes_for :product_variant_locations

  audited
  ProductVariant.non_audited_columns = %i[id inventory_quantity old_inventory_quantity created_at updated_at]

  extend FriendlyId
  friendly_id :title, :use => :slugged

  scope :set_store, ->(store) { where(store: store) }

  scope :first_variant, -> {where(position: 2).first}

  after_update do
    if (self.inventory_quantity.to_i == 0) && (self.stock == 'Discontinued') && (self.stock_update.to_i == 0)
      Magento::UpdateOrder.new(self.store).update_inventory_stock(self)
      self.update(stock_update: 1)
    else
      Magento::UpdateOrder.new(self.store).update_inventory_stock(self)
    end
  end

  def self.import(file,store)
    CSV.foreach(file.path, headers: true) do |row|
      if !(row[0].nil?)
        product_variant = ProductVariant.find_by(sku: row[0].to_s, store: store) || ProductVariant.find_by(sku: row[0].downcase, store: store)
        product_variant.update(inventory_quantity: row[1].to_i) if row[1].present?
        product_variant.update(unit_cost: row[2].to_i) if row[2].present?
        product_variant.update(stock: row[3].to_s) if row[3].present?
        product_variant.update(inventory_limit: row[4].to_i) if row[4].present?
      end
    end
  end

  def self.import_image(file)
    CSV.foreach(file.path, headers: true) do |row|
      if !(row[0].nil?)
        product_variant = ProductVariant.where("lower(sku) = ?", row[0].to_s.downcase)
        product_variant.update_all(image_url: row[1].to_s) if row[1].present?
      end
    end
  end
end
