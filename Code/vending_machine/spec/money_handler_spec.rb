require 'money_handler'

RSpec.describe MoneyHandler do
  let(:money_handler) { MoneyHandler.new }

  it 'inserts money and updates balance' do
    money_handler.insert_money(5000)
    expect(money_handler.balance).to eq(5000)
  end

  it 'handles valid and invalid denominations' do
    # Valid denomination test
    expect { money_handler.insert_money(200) }.to output("You inserted 200 VND. Current balance: 200 VND.\n").to_stdout
    expect(money_handler.balance).to eq(200)

    # Invalid denomination test
    expect { money_handler.insert_money(3) }.to output("Invalid denomination. Please insert valid money.\n").to_stdout
    expect(money_handler.balance).to eq(200)  # Balance should remain unchanged
  end

  it 'deducts amount and gives change if possible' do
    money_handler.insert_money(10000)
    expect(money_handler.deduct(5000)).to be(true)
    expect(money_handler.balance).to eq(5000)
  end

  it 'refunds balance' do
    money_handler.insert_money(10000)
    expect(money_handler.refund).to eq(10000)
    expect(money_handler.balance).to eq(0)
  end
end
