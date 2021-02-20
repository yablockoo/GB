from sys import argv
from itertools import count

script_name, begin = argv

for el in count(int(begin)):
    if el >= 15:
        break
    else:
        print(el)
