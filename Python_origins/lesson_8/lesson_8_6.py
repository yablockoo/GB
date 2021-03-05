"""
Продолжить работу над вторым заданием. Реализуйте механизм валидации вводимых
пользователем данных. Например, для указания количества принтеров,
отправленных на склад, нельзя использовать строковый тип данных.
"""


class OfficeEquipment:
    store_list = {}

    def __init__(self, model, weight, coast):
        self.model = model
        self.weight = weight
        self.coast = coast

    def show_info(self, name):
        print(f"{name} :{self.__dict__}")

    @staticmethod
    def is_int(var):
        try:
            var = int(var)
        except ValueError:
            print("Вы ввели не число!")
            return False
        else:
            return True


class Printer(OfficeEquipment):
    equip_list = {}

    def __init__(self, model, weight, coast, cartridge_name, lists_capacity):
        super().__init__(model, weight, coast)
        self.cartridge_name = cartridge_name
        self.lists_capacity = lists_capacity

    def to_store(self, quantity):
        if self.is_int(quantity):
            quantity = int(quantity)
            self.equip_list["модель"] = self.model
            self.equip_list["количество"] = quantity
            OfficeEquipment.store_list["Принтеры"] = self.equip_list
        else:
            print("Операция отправки принтеров на склад не выполнена.")

    # Ищет модель на складе, вычитает из склада количество, считает сумму отправленного товара
    def send_to_company(self, quantity_to_send):
        if self.is_int(quantity_to_send):
            quantity_to_send = int(quantity_to_send)
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
        else:
            print("Операция отправки принтеров в компанию не выполнена.")


class Scanner(OfficeEquipment):
    equip_list = {}

    def __init__(self, model, weight, coast, resolution):
        super().__init__(model, weight, coast)
        self.resolution = resolution

    def to_store(self, quantity):
        if self.is_int(quantity):
            quantity = int(quantity)
            self.equip_list["модель"] = self.model
            self.equip_list["количество"] = quantity
            OfficeEquipment.store_list["Сканеры"] = self.equip_list
        else:
            print("Операция отправки сканеров на склад не выполнена.")

    # Ищет модель на складе, вычитает из склада количество, считает сумму отправленного товара
    def send_to_company(self, quantity_to_send):
        if self.is_int(quantity_to_send):
            quantity_to_send = int(quantity_to_send)
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
        if self.is_int(quantity):
            quantity = int(quantity)
            self.equip_list["модель"] = self.model
            self.equip_list["количество"] = quantity
            OfficeEquipment.store_list["Проекторы"] = self.equip_list
        else:
            print("Операция отправки проекторов на склад не выполнена.")

    # Ищет модель на складе, вычитает из склада количество, считает сумму отправленного товара
    def send_to_company(self, quantity_to_send):
        if self.is_int(quantity_to_send):
            quantity_to_send = int(quantity_to_send)
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


printer.to_store(input("Введите количество принтеров для отправки на склад: "))
scanner.to_store(input("Введите количество сканеров для отправки на склад: "))
projector.to_store(input("Введите количество проекторов для отправки на склад: "))
print(f"СКЛАД {OfficeEquipment.store_list}")
printer.send_to_company(input("Введите количество принтеров для отсылки в компанию: "))
scanner.send_to_company(input("Введите количество сканеров для отсылки в компанию: "))
projector.send_to_company(input("Введите количество проекторов для отсылки в компанию: "))
print(f"СКЛАД {OfficeEquipment.store_list}")
