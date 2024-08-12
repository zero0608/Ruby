require 'rails_helper'

RSpec.describe ProductVariant, type: :model do
	# pending "add some examples to (or delete) #{__FILE__}"
	describe 'ProductVariant association' do
   it 'belongs_to product' do
    assc = described_class.reflect_on_association(:product)
    expect(assc.macro).to eq :belongs_to
   end
   it 'belongs_to product_image' do
    assc = described_class.reflect_on_association(:product_image)
    expect(assc.macro).to eq :belongs_to
   end
	end
end
