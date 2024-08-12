# lib/money_handler.rb

class MoneyHandler
  attr_reader :balance, :cash_reserve

  DENOMINATIONS = [500, 200, 100, 50, 20, 10, 5, 2, 1]

  def initialize
    @balance = 0
    @cash_reserve = DENOMINATIONS.each_with_object({}) { |denom, hash| hash[denom] = 0 }
  end

  def insert_money(amount)
    if @cash_reserve.key?(amount)
      @balance += amount
      @cash_reserve[amount] += 1
      puts "You inserted #{amount} VND. Current balance: #{@balance} VND."
    else
      puts "Invalid denomination. Please insert valid money."
    end
  end

  def can_make_change?(amount)
    temp_balance = amount
    reserve_copy = @cash_reserve.dup

    DENOMINATIONS.sort.reverse.each do |denom|
      while temp_balance >= denom && reserve_copy[denom] > 0
        temp_balance -= denom
        temp_balance = temp_balance.round(2)
        reserve_copy[denom] -= 1
      end
    end

    temp_balance == 0
  end

  def deduct(amount)
    if @balance >= amount
      change_needed = @balance - amount

      if can_make_change?(change_needed)
        give_change(change_needed)
        @balance = 0
        puts "Purchase successful. Dispensed change: #{change_needed} VND."
        true
      else
        puts "Cannot make exact change. Transaction canceled."
        false
      end
    else
      puts "Insufficient balance. Please insert #{amount - @balance} VND more."
      false
    end
  end

  def give_change(amount)
    DENOMINATIONS.sort.reverse.each do |denom|
      while amount >= denom && @cash_reserve[denom] > 0
        amount -= denom
        amount = amount.round(2)
        @cash_reserve[denom] -= 1
        puts "Returning #{denom} VND as change."
      end
    end
  end

  def refund
    puts "Refunding #{@balance} VND."
    refunded_amount = @balance
    @balance = 0
    refunded_amount
  end
end
