summary = 0
continuation = True


def sum_function(sum_list):
    loc_sum = 0
    for i in range(len(sum_list)):
        if sum_list[i] != '*':
            sum_list[i] = float(sum_list[i])
            loc_sum += sum_list[i]
        else:
            global continuation
            continuation = False
    return loc_sum


while continuation:
    tmp_list = input("Для остановки программы введите '*'. Введите числа через пробел: ").split()
    summary += sum_function(tmp_list)
    print(f"Сумма чисел = {summary}")


"""
def summary_func():
    summary = 0
    continuation = True

    while continuation:
        tmp_list = input("Для остановки программы введите '*'. Введите числа через пробел: ").split()
        for i in tmp_list:
            if i != '*':
                summary += int(i)
            else:
                continuation = False
                break
        print(f"Сумма чисел = {summary}")


summary_func()
"""