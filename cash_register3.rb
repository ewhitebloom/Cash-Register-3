require 'csv'
require 'pry'

def prompt(output)
  puts "#{output}"
  input = gets.chomp
  input.to_i
end

def csvdata
  counter = 0
  menuarray = []
  CSV.foreach('cash_register3_data.csv', headers: true) do |row|
    menuarray[counter] = {}
    menuarray[counter][:type] = "#{row[0]}"
    menuarray[counter][:buy_price] = "#{row[1]}"
    menuarray[counter][:sell_price] = "#{row[2]}"
    menuarray[counter][:sku] = "#{row[3]}"
    counter += 1
  end
  menuarray
end

def display_menu(menuarray)
  counter = 1
  menuarray.each do |product|
    puts "#{counter}) Add item - $#{product[:sell_price]} - #{product[:type]}"
counter += 1
end
puts "4) Complete Sale"
puts "5) Reporting"
end

def selection
  prompt("Make a selection:")
end

def selection_index(input)
  index = input.to_i - 1
  index.to_i
end

def selection_name(csvdata, selection_index)
  csvdata[selection_index][:type]
end

def selection_price(menuarray, selection_index)
  price = menuarray[selection_index][:sell_price]
  price.to_f
end

def quantity_of_selection
  prompt("How many?")
end

def item_subtotal(quantity_of_selection, selection_price)
  quantity_of_selection * selection_price
end

def receipt(receipt_array, selection_name, item_subtotal, quantity_of_selection)
  if receipt_array.any?{ |h| h[:item] == selection_name }
   index = receipt_array.index{|h| h[:item] == selection_name}
   receipt_array[index][:item_subtotal] += item_subtotal.to_f
   receipt_array[index][:item_quantity] += quantity_of_selection.to_i
 else
   receipt_array << {item: selection_name ,item_subtotal: item_subtotal.to_f, item_quantity: quantity_of_selection.to_i }
 end
 receipt_array
end

def grand_total(receipt)
  totals = 0
  receipt.each do |item|
   item_price = item[:item_subtotal].to_f
   totals += item_price
 end
 totals
end

def list_item_prices(array)
  puts "Here are your item prices:", ""
  array.each { |x| puts "$#{format_currency(x)}"}
end

def format_currency(currency)
  sprintf('%.2f', currency)
end

def change_due_successful_output(amount_tendered, total)
  puts "===Thank You!==="
  puts "The total change due is $#{format_currency(amount_tendered - total)}"
  puts ""
  puts "#{Time.now.strftime("%F %I:%M %p")}"
end

def change_due_failure_output(amount_tendered, total)
  puts "WARNING: Customer still owes $#{format_currency(total - amount_tendered)}! Exiting..."
end

def ordering_session
  selection_output = nil
  until selection_output == 4
    receipt_array = []
    selection_output = selection
    break if selection_output == 4
    quantity_of_selection_output = quantity_of_selection

    item_subtotal = item_subtotal(quantity_of_selection_output,selection_price(csvdata, selection_index(selection_output)))
    selection_name = selection_name( csvdata, selection_index(selection_output))

    receipt = receipt(receipt_array, selection_name(csvdata, selection_index(selection_output)), item_subtotal(quantity_of_selection_output,selection_price(csvdata, selection_index(selection_output))), quantity_of_selection_output)

    grand_totals = grand_total(receipt)
    puts "Subtotal: $#{grand_totals}"
  end
  puts "==Sale Complete=="
  final_receipt_storage = receipt(selection_name(csvdata,selection_index(selection_output)),item_subtotal(quantity_of_selection_output, selection_price(selection_index(selection_output), csvdata)))
  final_receipt_storage.each do |item_transactions|
   puts "$#{item_transactions[:item_subtotal]} - #{item_transactions[:item_quantity]} #{item_transactions[:item_type]}"
 end
 puts "Total: $#{final_totals}"
end

puts "Welcome to James' coffee emporium!"
display_menu(csvdata)
ordering_session
# sold_item_prices = []
# list_item_prices(sold_item_prices)
# total = subtotal(sold_item_prices)
# puts "The total amount due is $#{format_currency(total)}"
# amount_tendered = prompt("What is the amount tendered?").to_f

# if amount_tendered >= total
#   change_due_successful_output(amount_tendered, total)
# else
#   change_due_failure_output(amount_tendered, total)
# end
