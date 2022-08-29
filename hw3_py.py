def read_file(file_name):
    with open(file_name, 'r', encoding='UTF-8') as f:
        word_list = []
        words = []

        for line in f.readlines():
            words.extend(line.split())

        for w in words:
            w = w.lower()
            temp_w = ''
            for d in w:
                if d.isalpha() or d.isdigit():
                    temp_w += d
            if temp_w:
                word_list.append(temp_w)
        return list(set(word_list))


def save_file(file_name, word_list):
    with open(file_name, 'w', encoding='UTF-8') as f:
        word_list = sorted(word_list)
        f.write(f'Quantity of unique words: {len(word_list)}\n')
        for w in word_list:
            f.write(w + '\n')