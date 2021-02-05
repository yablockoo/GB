summary = 0
continuation = True


def sum_function(sum_list):
    for i in range(len(sum_list)):
        if sum_list[i] != '*':
            sum_list[i] = float(sum_list[i])
            global summary
            summary += sum_list[i]
        else:
            global continuation
            continuation = False
    print(f"Сумма чисел = {summary}")


while continuation:
    tmp_list = input("Для остановки программы введите '*'. Введите числа через пробел: ").split()
    sum_function(tmp_list)
