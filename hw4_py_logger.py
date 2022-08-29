import os
import datetime
import fnmatch


class Logger():

    @staticmethod
    def current_date():
        return datetime.datetime.now().strftime('%d.%m.%y')

    @staticmethod
    def create_empty_file(filename):
        try:
            with open(filename, 'w'):
                pass
        except:
            print("Error: Can't open/create file!")

    def _init_file(self):
        self.date = self.current_date()
        self.filename = os.path.join(self.path, 'log_' + self.date + '.txt')
        self.create_empty_file(self.filename)


    def __init__(self, path=os.getcwd()):
        self.path = path
        self.date = ''
        self.last_log = ''
        self.filename = ''
        self._init_file()

    def write_log(self, event):
        if self.date != self.current_date():
            self._init_file()

        try:
            with open(self.filename, 'a', encoding='UTF-8') as f:
                time = datetime.datetime.now().strftime('[%H:%M:%S]')
                self.last_log = f'{time} {event}'
                f.write(self.last_log + '\n')
        except:
            print("Error: Can't write new log!")

    def clear_log(self):
        self.last_log = ''
        self.create_empty_file(self.filename)
        print('Logs clear.')

    def get_logs(self):
        try:
            with open(self.filename, 'r', encoding='UTF-8') as f:
                today_logs = []
                for line in f.readlines():
                    today_logs.append(line[:-1])
                if today_logs:
                    return today_logs
                else:
                   return '...Logs is empty...'
        except:
            print("Error: Can't open file!")

    def get_last_event(self):
        if self.last_log:
            return self.last_log
        else:
            return '...Logs is empty...'

    def get_all_logs(self):
        log_files = []
        pattern = 'log_*.txt'
        for root, dirs, files in os.walk(self.path):
            for name in files:
                if fnmatch.fnmatch(name, pattern):
                    log_files.append(os.path.join(root, name))
        return log_files