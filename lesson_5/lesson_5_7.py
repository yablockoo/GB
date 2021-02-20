import json

sum_profit = 0
count = 0
firm_profit_dict = {}
average_profit = {}

with open("text_7.txt", "r", encoding="utf-8") as f_obj:
    for line in f_obj:
        line_str = line.split()
        profit = int(line_str[2]) - int(line_str[3])
        firm_profit_dict[line_str[0]] = profit
        if profit > 0:
            sum_profit += profit
            count += 1

average_profit["average_profit"] = sum_profit / count
total_list = [firm_profit_dict, average_profit]

with open("text_7.json", "w") as f_json:
    json.dump(total_list, f_json)
