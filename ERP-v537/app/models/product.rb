class Product < ApplicationRecord

  include PgSearch::Model

  has_many :carton_details, dependent: :destroy
  has_many :product_variants,  dependent: :destroy
  has_many :product_images,  dependent: :destroy
  belongs_to :category, optional: true
  belongs_to :subcategory, optional: true
  belongs_to :supplier
  belongs_to :factory, optional: true
  has_many :line_items, dependent: :destroy

  has_many :purchase_items, dependent: :destroy
  has_many :purchases, through: :purchase_items

  acts_as_taggable_on :shopify_tags

  audited
  has_associated_audits
  
  Product.non_audited_columns = %i[id oversized created_at updated_at]

  pg_search_scope :search,
                against: [:title],
                associated_against: {
                  product_variants: [ :sku, :price ],
                  supplier: [ :name ]                   
                },
                using: {
                    tsearch: {
                        prefix: true
                    }
                }
  scope :set_store, ->(store){where(store: store)}

  accepts_nested_attributes_for :carton_details
  
  extend FriendlyId
  friendly_id :title, :use => :slugged

  def self.import(file,store)
    CSV.foreach(file.path, headers: true) do |row|
      if !(row[0].nil?)
        product = Product.find_by(var_sku: row[0], store: store) || Product.find_by(sku: row[0], store: store)
        supplier = Supplier.find_by(name: row[2].to_s) if row[2].to_s.present?
        category = Category.find_by(title: row[3].to_s) if row[3].to_s.present?
        subcategory = Subcategory.find_by(name: row[4].to_s) if row[4].to_s.present?
        product.update(factory: row[1].to_s)
        product.update(supplier_id: supplier.id) if supplier.present?
        product.update(category_id: category.id) if category.present?
        product.update(subcategory_id: subcategory.id) if subcategory.present?
        product.product_variants.update_all(category_id: product&.category_id, subcategory_id: product&.subcategory_id, supplier_id: product&.supplier_id,factory: product&.factory&.name, oversized: product&.oversized)
      end
    end
  end

end
