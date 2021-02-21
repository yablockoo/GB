"""
3. Реализовать базовый класс Worker (работник), в котором определить атрибуты:
name, surname, position (должность), income (доход).
Последний атрибут должен быть защищенным и ссылаться на словарь,
содержащий элементы: оклад и премия, например, {"wage": wage, "bonus": bonus}.
Создать класс Position (должность) на базе класса Worker.
В классе Position реализовать методы получения полного имени сотрудника
(get_full_name) и дохода с учетом премии (get_total_income).
Проверить работу примера на реальных данных
(создать экземпляры класса Position, передать данные, проверить значения атрибутов, вызвать методы экземпляров).
"""


class Worker:
    def __init__(self, var_name, var_surname, var_position, var_income: dict):
        self.name = var_name
        self.surname = var_surname
        self.position = var_position
        self.__income = var_income


class Position(Worker):
    def get_full_name(self):
        return f"{self.name} {self.surname}"

    def get_total_income(self):
        return f"{self.__income.get('wage') + self.__income.get('bonus')}"
