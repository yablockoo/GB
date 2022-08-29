import random

def monty_hall_paradox(users_door : int, rechoice : bool, doors_num : int):
    doors = list(range(1, doors_num + 1))
    win_door = random.choice(doors)

    while len(doors) > 2:   #Можно просто по очереди убрать все лишние двери
        open_door = random.choice(doors)
        if open_door != win_door and open_door != users_door:
            doors.remove(open_door)

    if rechoice:
        if doors[0] == users_door:
            users_door = doors[1]
        else:
            users_door = doors[0]

    if users_door == win_door:
        return True
    else:
        return False


doors_quantity = 3
attempts = 100000
rechoice_win_count = 0
choice_win_count = 0

for i in range(attempts):
    win_flag = monty_hall_paradox(random.choice(range(1, doors_quantity + 1)), True, doors_quantity)
    if win_flag:
        rechoice_win_count += 1

for i in range(attempts):
    win_flag = monty_hall_paradox(random.choice(range(1, doors_quantity + 1)), False, doors_quantity)
    if win_flag:
        choice_win_count += 1

print(f'Game whith {doors_quantity} doors\n')

print(f'Probability of wins when user change his choice: {rechoice_win_count / attempts}\n'
      f'Win-to-try ratio: {rechoice_win_count}/{attempts}\n')

print(f'Probability of wins when user not change his choice: {choice_win_count / attempts}\n'
      f'Win-to-try ratio: {choice_win_count}/{attempts}')
