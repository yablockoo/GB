"""
Продолжить работу над первым заданием.
Разработать методы, отвечающие за приём оргтехники на склад и передачу
в определенное подразделение компании. Для хранения данных о наименовании
и количестве единиц оргтехники, а также других данных, можно использовать
любую подходящую структуру, например словарь.
"""


class OfficeEquipment:
    store_list = {}

    def __init__(self, model, quantity, weight, coast):
        self.model = model
        self.quantity = quantity
        self.weight = weight
        self.coast = coast

    def show_info(self, name):
        print(f"{name} :{self.__dict__}")


class Printer(OfficeEquipment):
    def __init__(self, model, quantity, weight, coast, cartridge_name, lists_capacity):
        super().__init__(model, quantity, weight, coast)
        self.cartridge_name = cartridge_name
        self.lists_capacity = lists_capacity


class Scanner(OfficeEquipment):
    def __init__(self, model, quantity, weight, coast, resolution):
        super().__init__(model, quantity, weight, coast)
        self.resolution = resolution


class Projector(OfficeEquipment):
    def __init__(self, model, quantity,  weight, coast, contrast, pic_resolution):
        super().__init__(model, quantity, weight, coast)
        self.contrast = contrast
        self.pic_resolution = pic_resolution


printer = Printer("hp", 1, 25, 15000, "f100", 500)
scanner = Scanner("xerox", 2, 5, 3500, "4800*4800")
projector = Projector("fuji", 3,  3, 45000, "20000:1", "2048*1024")

printer.show_info("принтер")
scanner.show_info("сканер")
projector.show_info("проектор")
