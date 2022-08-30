class User:
    count = 0

    def __init__(self, name, login, pwd):
        self._name = name
        self._login = login
        self._pwd = pwd
        User.count += 1

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, value):
        self._name = value

    @property
    def login(self):
        return self._login

    def set_password(self, value):
        self._pwd = value

    _pwd = property(fset=set_password)

    def show_info(self):
        return f'name: {self._name}, login: {self._login}.'


class SuperUser(User):
    count = 0

    def __init__(self, name, login, pwd, role):
        super().__init__(name, login, pwd)
        self._role = role
        SuperUser.count += 1

    @property
    def role(self):
        return self._role

    @name.setter
    def role(self, value):
        self._role = value

    def show_info(self):
        return super().show_info() + f', role: {self._role}'