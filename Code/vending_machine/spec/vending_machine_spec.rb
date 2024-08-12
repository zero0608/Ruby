require 'vending_machine'
require 'product'
require 'date'

RSpec.describe VendingMachine do
  let(:vending_machine) { VendingMachine.new }
  let(:product) { Product.new('Candy', 5000) }

  before do
    vending_machine.add_product(product, 10, Date.new(2024, 12, 31))
  end

  it 'adds and restocks products' do
    vending_machine.restock_product('Candy', 5)
    expect(vending_machine.inventory.get_product('Candy')).to eq(product)
  end

  it 'inserts money and selects a product' do
    vending_machine.insert_money(5000)
    expect { vending_machine.select_product('Candy') }.to output("Dispensing Candy. Remaining: 14.\n").to_stdout
  end

  it 'handles insufficient balance' do
    vending_machine.insert_money(2000)
    expect { vending_machine.select_product('Candy') }.to output("Insufficient balance. Please insert 3000 VND more.\n").to_stdout
  end

  it 'refunds money' do
    vending_machine.insert_money(10000)
    expect(vending_machine.refund).to eq(10000)
  end

  it 'handles product not found' do
    expect { vending_machine.select_product('Nonexistent') }.to output("Product not found.\n").to_stdout
  end
end
