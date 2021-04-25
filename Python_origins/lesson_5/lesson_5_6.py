lessons = {}

with open("text_6.txt", "r", encoding="utf-8") as f_obj:
    for line in f_obj:
        line_str = line.split(" ")
        line_str[0] = line_str[0].replace(":", "")    # replace ":" in lesson's name
        sum_lesson = 0
        for i in range(1, 4):
            lesson = ""
            if line_str[i] == "-" or line_str[i] == "-\n":
                continue
            for char in line_str[i]:
                if char != "(":
                    lesson += char
                else:
                    break
            lesson = int(lesson)
            sum_lesson += lesson
        lessons[line_str[0]] = sum_lesson

print(lessons)
