FactoryBot.define do
  factory :purchase do
    line_item { nil }
    supplier { nil }
    order { nil }
    quantity { 1 }
  end
end
