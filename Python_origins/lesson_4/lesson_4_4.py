prev_list = [2, 2, 2, 7, 23, 1, 44, 44, 3, 2, 10, 7, 4, 11]
cur_list = [el for el in prev_list if prev_list.count(el) == 1]
print(prev_list)
print(cur_list)
