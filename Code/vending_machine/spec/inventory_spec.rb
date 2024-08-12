require 'inventory'
require 'product'
require 'date'

RSpec.describe Inventory do
  let(:product) { Product.new('Chips', 10000) }
  let(:inventory) { Inventory.new }

  before do
    inventory.add_product(product, 10, Date.new(2024, 12, 31))
  end

  it 'adds a product to the inventory' do
    expect(inventory.product_available?('Chips')).to be(true)
  end

  it 'lists products in inventory' do
    expect { inventory.list_products }.to output(/Product: Chips/).to_stdout
  end

  it 'restocks a product' do
    inventory.restock_product('Chips', 5)
    expect(inventory.get_product('Chips').price).to eq(10000)
  end

  it 'checks product expiration' do
    expect(inventory.check_expiration('Chips')).to eq(10000)
  end

  it 'dispenses a product' do
    inventory.dispense_product('Chips')
    expect(inventory.get_product('Chips')).not_to be_nil
  end
end
