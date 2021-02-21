class Stationery:
    def __init__(self, atr_title):
        self.title = atr_title

    def draw(self):
        print("Запуск отрисовки")


class Pen(Stationery):
    def draw(self):
        print(f"Ручка {self.title} поможет Вам записать все самые нужные лекции!")


class Pencil(Stationery):
    def draw(self):
        print(f"С помощью карандашей {self.title} Вы сможете сделать набросок шедевра!")


class Handle(Stationery):
    def draw(self):
        print(f"Маркеры {self.title} помогут Вам выделить важные места в документе!")


pen = Pen("Cruiser")
pencil = Pencil("Koh-I-Nor")
handle = Handle("Index")

pen.draw()
pencil.draw()
handle.draw()
