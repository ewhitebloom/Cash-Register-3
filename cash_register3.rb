require 'csv'
require 'pry'
require 'date'

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
    menuarray[counter][:item_revenue] = 0
    menuarray[counter][:date] = nil
    menuarray[counter][:item_quantity] = 0
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
  format_currency(quantity_of_selection * selection_price)
end

def receipt(menuarray, selection_name, item_subtotal, quantity_of_selection)
  if menuarray.any?{ |h| h[:type] == selection_name }
   index = menuarray.index{|h| h[:type] == selection_name}
   menuarray[index][:item_type] = selection_name
   menuarray[index][:item_revenue] += item_subtotal.to_f
   menuarray[index][:date] = Time.now.strftime("%m/%d/%Y")
   menuarray[index][:item_quantity] += quantity_of_selection.to_i
 end
 menuarray
end

def grand_total(receipt)
  totals = 0
  receipt.each do |item|
   item_price = item[:item_revenue].to_f
   totals += item_price
 end
 totals.to_f
end

def write_CSV(receipt)
  CSV.open('cash_register3_receipts.csv', "ab", headers: true) do |row|
    receipt.each do |item|
      row << [item[:item_type],item[:buy_price], item[:sell_price], item[:sku], item[:item_revenue], item[:date], item[:item_quantity]]
    end
  end
end

def read_CSV_receipt
  puts "What date would you like reports for? (MM/DD/YYYY)"
  input = gets.chomp.to_s
  totals = []
  CSV.foreach('cash_register3_receipts.csv', headers: true) do |row|
    counter = 0
    if row["date"] == input
      csv_row_type = row["item_type"]
       if totals.any?{ |h| h[0] == csv_row_type}
         index = totals.index{ |h| h[0] == csv_row_type}
         totals[index][4] = totals[index][4].to_f + row["item_revenue"].to_f
         totals[index][6] = totals[index][6].to_f + row["item_quantity"].to_f
       else
         totals << [row["item_type"], row["buy_price"], row["sell_price"], row["sku"], row["item_revenue"], row["date"], row["item_quantity"]]
       end
    end
   counter += 1
 end
 puts "On #{input} we sold:"
 totals
end

def CSV_report(totals)
     total_sales = 0
     total_profit = 0
    totals.each do |item|
     profit = item[4].to_f - item[1].to_f * item[6].to_f
     puts "SKU # #{item[3]}, Name: #{item[0]}, Quantity: #{item[6]}, Revenue: #{item[4]}, Profit: #{profit} "
     total_profit += profit
    end
    totals.each do |item|
      total_sales += item[4].to_f
    end
    puts
    puts "Totals Sales: #{format_currency(total_sales)}"
    puts "Total Profit: #{format_currency(total_profit)}"
end

def format_currency(currency)
  sprintf('%.2f', currency)
end

def change(final_totals)
  puts "What is the amount tendered?"
  tendered = gets.chomp.to_f
  difference = tendered - final_totals

  if difference >= 0.00
    change_due_successful_output(tendered,final_totals)
  else
    change_due_failure_output(tendered,final_totals)
    exit
  end
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
  menuarray = csvdata
  until selection_output == 4
    selection_output = selection
    if selection_output == 5
      csv_Read_Data = read_CSV_receipt
      CSV_report(csv_Read_Data)
      exit
    end
    break if selection_output == 4
    quantity_of_selection_output = quantity_of_selection

    item_subtotal = item_subtotal(quantity_of_selection_output,selection_price(csvdata, selection_index(selection_output)))
    selection_name = selection_name( csvdata, selection_index(selection_output))

    receipt = receipt(menuarray, selection_name(csvdata, selection_index(selection_output)), item_subtotal(quantity_of_selection_output,selection_price(csvdata, selection_index(selection_output))), quantity_of_selection_output)

    grand_totals = grand_total(receipt)
    puts "Subtotal: $#{format_currency(grand_totals)}"
  end
  write_CSV(receipt)
  puts "==Sale Complete=="
  puts "Subtotal: $#{grand_totals}"
  final_receipt_storage = receipt
  final_receipt_storage.each do |item_transactions|
   puts "$#{format_currency(item_transactions[:item_revenue])} - #{item_transactions[:item_quantity]} #{item_transactions[:item_type]}"
 end
 puts "Total: $#{format_currency(grand_totals)}"
 grand_totals
end

puts "Welcome to James' coffee emporium!"
display_menu(csvdata)
final_totals = ordering_session

change(final_totals)

