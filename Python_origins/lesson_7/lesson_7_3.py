class Cell:
    def __init__(self, arg_part):
        self.cells = arg_part

    def __add__(self, other):
        return Cell(self.cells + other.cells)

    def __sub__(self, other):
        if self.cells - other.cells > 0:
            return Cell(self.cells - other.cells).cells
        else:
            return "Ошибка, результат вычитания отрицательный."

    def __mul__(self, other):
        return Cell(self.cells * other.cells)

    def __truediv__(self, other):
        if self.cells >= other.cells:
            return Cell(self.cells // other.cells)
        else:
            return Cell(other.cells // self.cells)

    def make_order(self, cells_in_order):
        order = ""
        for c in range(1, self.cells + 1):
            if c % cells_in_order == 0:
                order += "*\n"
            else:
                order += "*"
        return order


cell_1 = Cell(10)
cell_2 = Cell(5)
print(f"+: {(cell_1 + cell_2).cells}")
print(f"-: {(cell_1 - cell_2)}")
print(f"*: {(cell_1 * cell_2).cells}")
print(f"/: {(cell_1 / cell_2).cells}")
print(f"Ряд:\n{cell_1.make_order(3)}")
