"""
Продолжить работу над первым заданием.
Разработать методы, отвечающие за приём оргтехники на склад и передачу
в определенное подразделение компании. Для хранения данных о наименовании
и количестве единиц оргтехники, а также других данных, можно использовать
любую подходящую структуру, например словарь.
"""


class OfficeEquipment:
    store_list = {}

    def __init__(self, model, weight, coast):
        self.model = model
        self.weight = weight
        self.coast = coast

    def show_info(self, name):
        print(f"{name} :{self.__dict__}")


class Printer(OfficeEquipment):
    equip_list = {}

    def __init__(self, model, weight, coast, cartridge_name, lists_capacity):
        super().__init__(model, weight, coast)
        self.cartridge_name = cartridge_name
        self.lists_capacity = lists_capacity

    def to_store(self, quantity):
        self.equip_list["модель"] = self.model
        self.equip_list["количество"] = quantity
        OfficeEquipment.store_list["Принтеры"] = self.equip_list

    # Ищет модель на складе, вычитает из склада количество, считает сумму отправленного товара
    def send_to_company(self, quantity_to_send):
        print(f"Отправка {quantity_to_send} принтеров модели {self.model}.")
        for keys in OfficeEquipment.store_list.keys():
            if keys == "Принтеры":
                for equip_keys in OfficeEquipment.store_list.get(keys):
                    if OfficeEquipment.store_list.get(keys).get(equip_keys) == self.model:
                        if self.equip_list.get("количество") < quantity_to_send:
                            print("На складе не хватает принтеров, отправка отменена.")
                        else:
                            self.equip_list["количество"] = self.equip_list.get("количество") - quantity_to_send
                            total_coast = quantity_to_send * self.coast
                            print(f"Отправлено {quantity_to_send} принтеров {self.model} на сумму {total_coast}")


class Scanner(OfficeEquipment):
    equip_list = {}

    def __init__(self, model, weight, coast, resolution):
        super().__init__(model, weight, coast)
        self.resolution = resolution

    def to_store(self, quantity):
        self.equip_list["модель"] = self.model
        self.equip_list["количество"] = quantity
        OfficeEquipment.store_list["Сканеры"] = self.equip_list

    # Ищет модель на складе, вычитает из склада количество, считает сумму отправленного товара
    def send_to_company(self, quantity_to_send):
        print(f"Отправка {quantity_to_send} сканеров модели {self.model}.")
        for keys in OfficeEquipment.store_list.keys():
            if keys == "Сканеры":
                for equip_keys in OfficeEquipment.store_list.get(keys):
                    if OfficeEquipment.store_list.get(keys).get(equip_keys) == self.model:
                        if self.equip_list.get("количество") < quantity_to_send:
                            print("На складе не хватает сканеров, отправка отменена.")
                        else:
                            self.equip_list["количество"] = self.equip_list.get("количество") - quantity_to_send
                            total_coast = quantity_to_send * self.coast
                            print(f"Отправлено {quantity_to_send} сканеров {self.model} на сумму {total_coast}")


class Projector(OfficeEquipment):
    equip_list = {}

    def __init__(self, model,  weight, coast, contrast, pic_resolution):
        super().__init__(model, weight, coast)
        self.contrast = contrast
        self.pic_resolution = pic_resolution

    def to_store(self, quantity):
        self.equip_list["модель"] = self.model
        self.equip_list["количество"] = quantity
        OfficeEquipment.store_list["Проекторы"] = self.equip_list

    # Ищет модель на складе, вычитает из склада количество, считает сумму отправленного товара
    def send_to_company(self, quantity_to_send):
        print(f"Отправка {quantity_to_send} проекторов модели {self.model}.")
        for keys in OfficeEquipment.store_list.keys():
            if keys == "Проекторы":
                for equip_keys in OfficeEquipment.store_list.get(keys):
                    if OfficeEquipment.store_list.get(keys).get(equip_keys) == self.model:
                        if self.equip_list.get("количество") < quantity_to_send:
                            print("На складе не хватает проекторов, отправка отменена.")
                        else:
                            self.equip_list["количество"] = self.equip_list.get("количество") - quantity_to_send
                            total_coast = quantity_to_send * self.coast
                            print(f"Отправлено {quantity_to_send} проекторов {self.model} на сумму {total_coast}")


printer = Printer("hp", 25, 15000, "f100", 500)
scanner = Scanner("xerox", 5, 3500, "4800*4800")
projector = Projector("fuji",  3, 45000, "20000:1", "2048*1024")


printer.to_store(5)
scanner.to_store(3)
projector.to_store(6)
print(f"СКЛАД {OfficeEquipment.store_list}")
printer.send_to_company(2)
scanner.send_to_company(4)
projector.send_to_company(4)
print(f"СКЛАД {OfficeEquipment.store_list}")
