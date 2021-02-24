class Matrix:
    def __init__(self, atr_list_of_lists):
        self.list_of_lists = atr_list_of_lists

    def __str__(self):
        tmp_str = ""
        for el in self.list_of_lists:
            for a in el:
                tmp_str += str(a) + ' '
            tmp_str += '\n'
        return tmp_str

    def __add__(self, other):
        sum_matrix = []
        for i in range(len(self.list_of_lists)):
            tmp_list = []
            for j in range(len(self.list_of_lists[i])):
                tmp_list.append(self.list_of_lists[i][j] + other.list_of_lists[i][j])
            sum_matrix.append(tmp_list)
        return Matrix(sum_matrix)


matrix_1 = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
matrix_2 = Matrix([[11, 12, 13], [14, 15, 16], [17, 18, 19]])
print(f"Матрица 1:\n{matrix_1}")
print(f"Матрица 2:\n{matrix_2}")
print(f"Сумма матриц:\n{matrix_1 + matrix_2}")
