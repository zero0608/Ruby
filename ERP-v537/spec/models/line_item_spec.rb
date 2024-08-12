require 'rails_helper'

RSpec.describe LineItem, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'LineItem association' do
   it 'belongs_to order' do
    assc = described_class.reflect_on_association(:order)
    expect(assc.macro).to eq :belongs_to
   end

   it 'belongs_to fulfillment' do
    assc = described_class.reflect_on_association(:fulfillment)
    expect(assc.macro).to eq :belongs_to
   end

   it 'belongs_to product' do
    assc = described_class.reflect_on_association(:product)
    expect(assc.macro).to eq :belongs_to
   end

   it 'belongs_to product_variant' do
    assc = described_class.reflect_on_association(:product_variant)
    expect(assc.macro).to eq :belongs_to
   end

   it 'belongs_to shipping_detail' do
    assc = described_class.reflect_on_association(:shipping_detail)
    expect(assc.macro).to eq :belongs_to
   end
  end
end
