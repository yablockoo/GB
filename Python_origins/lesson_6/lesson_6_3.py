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
        return f"{self._Worker__income.get('wage') + self._Worker__income.get('bonus')}"


p = Position("Иван", "Иванов", "старший помощник", {'wage': 10000, 'bonus': 5000})
print(p.name, p.surname, p.position, p._Worker__income)   # на доступ жалуется, расскажите на уроке норма ли это
print(p.get_full_name())
print(f"{p.get_total_income()}р")
