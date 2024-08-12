FactoryBot.define do
  factory :notification do
    user { nil }
    order { nil }
    status { 1 }
  end
end
