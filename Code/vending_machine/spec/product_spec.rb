require 'product'

RSpec.describe Product do
  it 'creates a product with a name and price' do
    product = Product.new('Soda', 15000)
    expect(product.name).to eq('Soda')
    expect(product.price).to eq(15000)
  end
end
