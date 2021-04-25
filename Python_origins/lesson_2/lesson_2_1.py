my_list = [None, True, 146, "42", False, 146.0001, bytes(b"22")]
b_array = bytearray(b"228, 42, 146")
my_list.append(b_array)

for i in range(len(my_list)):
    print(f"{my_list[i]} is {type(my_list[i])}")
