"""
Реализовать класс «Дата», функция-конструктор которого должна принимать дату
в виде строки формата «день-месяц-год». В рамках класса реализовать два метода.
Первый, с декоратором @class_method, должен извлекать число, месяц, год и преобразовывать
их тип к типу «Число». Второй, с декоратором @staticmethod, должен проводить валидацию числа,
 месяца и года (например, месяц — от 1 до 12). Проверить работу полученной структуры на реальных данных.
"""


class Date:
    date = ""

    def __init__(self, arg_date):
        Date.date = arg_date

    @classmethod
    def date_converter(cls):
        tmp_date = cls.date.split("-")
        day = int(tmp_date[0])
        month = int(tmp_date[1])
        year = int(tmp_date[2])
        return f"{cls.date} --> {cls.is_date_valid(day, month, year)}"

    @staticmethod
    def is_date_valid(arg_day, arg_month, arg_year):
        day = arg_day
        month = arg_month
        year = arg_year

        if (1 <= day <= 31) and (1 <= month <= 12) and (0 <= year):
            return "Date is valid!"
        else:
            return "ERROR: date format is not valid!"


d = Date("10-12-2020")
print(d.date_converter())  # сначала выводил валидна ли дата, потом переделал чтоб конвертер использовал статик
