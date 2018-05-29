from checking import CheckedClass, PositiveInteger

dx: PositiveInteger

class Example(CheckedClass):
    name: NonemptyString
    x: Integer
    y: Integer

    def __init__(self, name, x, y):
        self.name = name
        self.x = x
        self.y = y

    def left(self, dx):
        self.x -= dx

    def right(self, dx):
        self.x += dx


if __name__ == "__main__":
    e = Example('Brian', 12, 12)
    print(e)
    e.y = 'f'
