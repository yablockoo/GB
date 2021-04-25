class Car:
    def __init__(self, var_speed, var_color, var_name, var_is_police):
        self.speed = var_speed
        self.color = var_color
        self.name = var_name
        self.is_police = var_is_police

    def go(self):
        print(f"{self.name} поехала!")

    def stop(self):
        print(f"{self.name} остановилась!")

    def turn(self, direction):
        print(f"{self.name} повернула {direction}!")

    def show_speed(self):
        print(f"Скорость {self.name}: {self.speed}")


class TownCar(Car):
    def show_speed(self):
        print(f"Скорость {self.name}: {self.speed}")
        if self.speed > 60:
            print("Обнаружено превыешние скорости!")


class SportCar(Car):
    def __init__(self, var_speed, var_color, var_name, var_is_police, var_horse_powers):
        super().__init__(var_speed, var_color, var_name, var_is_police)
        self.horse_powers = var_horse_powers

    def show_h_p(self):
        print(f"{self.name} имеет {self.horse_powers}л.с.")


class WorkCar(Car):
    def show_speed(self):
        print(f"Скорость {self.name}: {self.speed}")
        if self.speed > 40:
            print("Обнаружено превыешние скорости!")


class PoliceCar(Car):
    def __init__(self, var_speed, var_color, var_name, var_is_police, var_capacity):
        super().__init__(var_speed, var_color, var_name, var_is_police)
        self.capacity = var_capacity

    def show_capacity(self):
        print(f"{self.name} имеет место для {self.capacity} задержанных.")


t = TownCar(100, "белая", "Седан", False)
s = SportCar(120, "красная", "Купе", False, 550)
w = WorkCar(39, "зеленая", "Мусоровоз", False)
p = PoliceCar(80, "черно-белая", "Автозак", True, 18)

print(f"Скорость:{t.speed}, название:{t.name}, цвет:{t.color}, Полиция? {t.is_police}")
print(f"Скорость:{s.speed}, название:{s.name}, цвет:{s.color}, Полиция? {s.is_police}")
print(f"Скорость:{w.speed}, название:{w.name}, цвет:{w.color}, Полиция? {w.is_police}")
print(f"Скорость:{p.speed}, название:{p.name}, цвет:{p.color}, Полиция? {p.is_police}")

t.go()
s.turn("вправо")
w.stop()
t.show_speed()
w.show_speed()
s.show_h_p()
p.show_capacity()
