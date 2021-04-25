prev_list = [300, 2, 12, 44, 1, 1, 4, 10, 7, 1, 78, 123, 55]
cur_list = [prev_list[i] for i in range(1, len(prev_list)) if prev_list[i] > prev_list[i - 1]]
print(prev_list)
print(cur_list)
