FactoryBot.define do
  factory :warehouse_variant do
    product_variant { nil }
    product_variant_location { nil }
    warehouse { nil }
  end
end
