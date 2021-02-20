from time import sleep
from itertools import cycle


class TrafficLight:
    color_set = {"Красный": 7, "Желтый": 2, "Зеленый": 10}
    __color__ = ""

    def running(self, repeats):
        count = 0
        color_iteration = cycle(TrafficLight.color_set.items())
        while count / 3 != repeats:
            light_phase = next(color_iteration)
            __color__ = (light_phase[0])
            print(__color__)
            sleep(light_phase[1])
            count += 1


a = TrafficLight()
a.running(int(input("Количество повторений: ")))
