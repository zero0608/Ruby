class Product
  attr_reader :name, :price

  def initialize(name, price)
    @name = name
    @price = price
  end
end

class Inventory
  attr_accessor :products

  def initialize
    @products = []
  end

  def add_product(product, quantity)
    quantity.times { @products << product }
  end
end

class MoneyHandler
  attr_accessor :balance

  def initialize(amount)
    @balance = 0
  end

  def insert_money(amount)
    @balance += amount
  end

  def deduct_money(amount)
    @balance -= amount
  end
end

class VendingMachine
  def initialize
    @inventory = Inventory.new
    @money_handler = MoneyHandler.new(0)
    @selected_product = nil
  end

  def select_product(product_name)
    @selected_product = @inventory.products.keys.find { |product| product.name == product_name }
  end

  def insert_money(amount)
    @money_handler.insert_money(amount)
  end

  def purchase
    if @seleccted_product && @money_handler.balance >= @selected_product.price
      @money_handler.deduct_money(@selected_product.price)
      @inventory.remove_product(@selected_product)
      return "Successfully purchased #{@selected_product.name}"
    else
      return "Insufficient funds or product not selected."
    end
  end

  def return_change
    change = @money_handler.balance
    @money_handler.balance = 0
    return "Change returned: #{change}."
  end
end

cola = Product.new("Cola", 1.50)
vending_machine = VendingMachine.new
vending_machine.select_product("Cola")
vending_machine.insert_money(2)
puts vending_machine.purchase # Output: Successfully purchased Cola.
puts vending_machine.return_change # Output: Change returned: 0.5.