require_relative 'money_handler'
require_relative 'inventory'
require_relative 'product'

class VendingMachine
  attr_reader :money_handler, :inventory

  def initialize
    @money_handler = MoneyHandler.new
    @inventory = Inventory.new
  end

  def add_product(product, quantity, expiration_date = nil)
    @inventory.add_product(product, quantity, expiration_date)
  end

  def restock_product(product_name, quantity)
    @inventory.restock_product(product_name, quantity)
  end

  def insert_money(amount)
    @money_handler.insert_money(amount)
  end

  def select_product(product_name)
    product = @inventory.get_product(product_name)

    if product.nil?
      puts "Product not found."
    else
      price = @inventory.check_expiration(product_name)
      if @money_handler.deduct(price)
        @inventory.dispense_product(product_name)
      end
    end
  end

  def refund
    @money_handler.refund
  end
end