from abc import ABC, abstractmethod


class Clothes(ABC):
    def __init__(self, arg_size):
        self.size = arg_size

    @abstractmethod
    def consumption(self):
        pass


class Coat(Clothes):
    @property
    def size(self):
        return self.size

    @size.setter
    def size(self, size):
        if size == "s":
            self.product_len = 10
        elif size == "m":
            self.product_len = 15
        elif size == "l":
            self.product_len = 20

    def consumption(self):
        return self.product_len / 6.5 + 0.5


class Costume(Clothes):
    @property
    def size(self):
        return self.size

    @size.setter
    def size(self, size):
        if 150 <= size <= 165:
            self.product_len = 12
        elif 166 <= size <= 175:
            self.product_len = 14
        elif 176 <= size <= 193:
            self.product_len = 16

    def consumption(self):
        return 2 * self.product_len + 0.3


my_coat = Coat(input("Введите размер пальто (s, m ,l):"))
print(f"Расход: {my_coat.consumption():.2f}кв.м.")
my_costume = Costume(int(input("Введите рост костюма (150см - 193см):")))
print(f"Расход: {my_costume.consumption()}кв.м.")
