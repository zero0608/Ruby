require 'rails_helper'

RSpec.describe ProductImage, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'ProductImage association' do
   it 'belongs_to product' do
      assc = described_class.reflect_on_association(:product)
      expect(assc.macro).to eq :belongs_to
   end
   it 'has_many product_variants' do
      assc = described_class.reflect_on_association(:product_variants)
      expect(assc.macro).to eq :has_many
   end
  end
end
