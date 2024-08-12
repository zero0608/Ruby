require 'date'

class Inventory
  def initialize
    @products = {}
  end

  def add_product(product, quantity, expiration_date = nil)
    @products[product.name] = { product: product, quantity: quantity, expiration: expiration_date }
  end

    def list_products
    if @products.empty?
      puts "No products in inventory."
    else
      @products.each do |name, details|
        product = details[:product]
        quantity = details[:quantity]
        expiration = details[:expiration] ? details[:expiration].strftime("%Y-%m-%d") : "None"
        puts "Product: #{name}, Price: #{product.price} VND, Quantity: #{quantity}, Expiration: #{expiration}"
      end
    end
  end

  def restock_product(product_name, quantity)
    if @products.key?(product_name)
      @products[product_name][:quantity] += quantity
      puts "#{quantity} units of #{product_name} added. New stock: #{@products[product_name][:quantity]}."
    else
      puts "Product not found."
    end
  end

  def product_available?(product_name)
    @products.key?(product_name) && @products[product_name][:quantity] > 0
  end

  def get_product(product_name)
    if product_available?(product_name)
      @products[product_name][:product]
    else
      nil
    end
  end

  def check_expiration(product_name)
    return nil unless @products[product_name]

    expiration = @products[product_name][:expiration]
    return nil unless expiration

    if expiration < Date.today
      puts "#{product_name} has expired!"
      @products[product_name][:quantity] = 0
    elsif expiration <= Date.today + 2
      puts "#{product_name} is expiring soon. Discount applied!"
      return @products[product_name][:product].price * 0.5
    end

    @products[product_name][:product].price
  end

  def dispense_product(product_name)
    if product_available?(product_name)
      @products[product_name][:quantity] -= 1
      puts "Dispensing #{product_name}. Remaining: #{@products[product_name][:quantity]}."
    else
      puts "Product not available."
    end
  end
end
