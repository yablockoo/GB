from sys import argv
from itertools import cycle

script_name, end = argv
my_list = ['Л', 'е', 'ш', 'а', '!']

count = 0
for el in cycle(my_list):
    if count >= int(end):
        break
    else:
        print(el)
        count += 1
