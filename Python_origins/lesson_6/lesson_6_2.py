class Road:
    def __init__(self, length_, width_):
        self.__length = length_
        self.__width = width_

    def building(self, mass_, thick_):
        return self.__length * self.__width * mass_ * thick_


length = int(input("Введите длинну дороги: "))
width = int(input("Введите ширину дороги: "))
mass = int(input("Введите массу асфальта на 1 кв.м. на толщину 1 см: "))
thick = int(input("Введите толщину асфальта: "))

road = Road(length, width)
print(f"Требуется {road.building(mass, thick) / 1000}т асфальта.")
