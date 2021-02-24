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
        return self.__size

    @size.setter
    def size(self, size):
        if size == "s":
            self.__size = 10
        elif size == "m":
            self.__size = 15
        elif size == "l":
            self.__size = 20

    def consumption(self):
        return self.__size / 6.5 + 0.5


class Costume(Clothes):
    @property
    def size(self):
        return self.__size

    @size.setter
    def size(self, size):
        if 150 <= size <= 165:
            self.__size = 12
        elif 166 <= size <= 175:
            self.__size = 14
        elif 176 <= size <= 193:
            self.__size = 16

    def consumption(self):
        return 2 * self.__size + 0.3


my_coat = Coat(input("Введите размер пальто (s, m ,l):"))
print(f"Расход: {my_coat.consumption():.2f}кв.м.")
my_costume = Costume(int(input("Введите рост костюма (150см - 193см):")))
print(f"Расход: {my_costume.consumption()}кв.м.")
