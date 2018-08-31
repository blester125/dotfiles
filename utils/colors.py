from enum import Enum
from functools import partial

__all__ = [
    'print_red',
    'print_yellow',
    'print_white',
    'print_purple',
    'print_blue',
    'print_green',
    'print_black',
    'print_cyan'
]

BASE = '\033[{};1m'

class Colors(Enum):
    NORMAL = '\033[0m'
    YELLOW = BASE.format(33)
    RED = BASE.format(31)
    WHITE = BASE.format(37)
    PURPLE = BASE.format(35)
    BLUE = BASE.format(34)
    GREEN = BASE.format(32)
    BLACK = BASE.format(30)
    CYAN = BASE.format(36)

    def __str__(self):
        return self.value

def colored_out(message, *args, color=Colors.NORMAL, out=print, **kwargs):
    out(f'{color}{message}{Colors.NORMAL}', *args, **kwargs)

print_red = partial(colored_out, color=Colors.RED)
print_yellow = partial(colored_out, color=Colors.YELLOW)
print_white = partial(colored_out, color=Colors.WHITE)
print_purple = partial(colored_out, color=Colors.PURPLE)
print_blue = partial(colored_out, color=Colors.BLUE)
print_green = partial(colored_out, color=Colors.GREEN)
print_black = partial(colored_out, color=Colors.BLACK)
print_cyan = partial(colored_out, color=Colors.CYAN)

if __name__ == "__main__":
    print_red("RED", end=' ')
    print_yellow("YELLOW", end=' ')
    print_white("WHITE", end=' ')
    print_purple("PURPLE", end=' ')
    print_blue("BLUE", end=' ')
    print_green("GREEN", end=' ')
    print_black("BLACK", end=' ')
    print_cyan("CYAN", end=' ')
    print("NORMAL")
