"""
Начните работу над проектом «Склад оргтехники». Создайте класс, описывающий склад.
А также класс «Оргтехника», который будет базовым для классов-наследников.
Эти классы — конкретные типы оргтехники (принтер, сканер, ксерокс).
В базовом классе определить параметры, общие для приведенных типов.
В классах-наследниках реализовать параметры, уникальные для каждого типа оргтехники.
"""


class OfficeEquipment:
    def __init__(self, inv_num, weight, coast):
        self.inv_num = inv_num
        self.weight = weight
        self.coast = coast

    def show_info(self, name):
        print(f"{name} :{self.__dict__}")


class Printer(OfficeEquipment):
    def __init__(self, inv_num, weight, coast, cartridge_name, lists_capacity):
        super().__init__(inv_num, weight, coast)
        self.cartridge_name = cartridge_name
        self.lists_capacity = lists_capacity


class Scanner(OfficeEquipment):
    def __init__(self, inv_num, weight, coast, resolution):
        super().__init__(inv_num, weight, coast)
        self.resolution = resolution


class Projector(OfficeEquipment):
    def __init__(self, inv_num, weight, coast, contrast, pic_resolution):
        super().__init__(inv_num, weight, coast)
        self.contrast = contrast
        self.pic_resolution = pic_resolution


printer = Printer(1, 25, 15000, "f100", 500)
scanner = Scanner(1, 25, 15000, "4800*4800")
projector = Projector(1, 25, 15000, "20000:1", "2048*1024")

printer.show_info("принтер")
scanner.show_info("сканер")
projector.show_info("проектор")
