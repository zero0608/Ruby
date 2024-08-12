require 'rails_helper'

RSpec.describe Product, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'Product association' do
   it 'has_many product_variants' do
      assc = described_class.reflect_on_association(:product_variants)
      expect(assc.macro).to eq :has_many
   end
   it 'has_many product_images' do
      assc = described_class.reflect_on_association(:product_images)
      expect(assc.macro).to eq :has_many
   end
   it 'has_many cartons' do
      assc = described_class.reflect_on_association(:cartons)
      expect(assc.macro).to eq :has_many
   end
   it 'belongs_to supplier' do
      assc = described_class.reflect_on_association(:supplier)
      expect(assc.macro).to eq :belongs_to
   end
  end
end
