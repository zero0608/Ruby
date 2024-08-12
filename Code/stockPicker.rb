def stock_picker(prices)
  return [] if prices.length < 2 

  min_price = prices[0]
  min_index = 0
  max_profit = 0
  best_days = [0, 0]

  prices.each_with_index do |price, day|
    next if day == 0

    # Update min price and index
    if price < min_price
      min_price = price
      min_index = day
    end

    # Calculate profit if selling today
    profit = price - min_price
    if profit > max_profit
      max_profit = profit
      best_days = [min_index, day]
    end
  end

  best_days
end

puts stock_picker([17,3,6,9,15,8,6,1,20,10]).inspect