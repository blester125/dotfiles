import os
import sys
import stat
from enum import Enum


Mode = Enum("Mode", "PIPED REDIRECTED TERMINAL")


def stdin_mode() -> Mode:
    return file_mode(sys.stdin.fileno())


def file_mode(fd: int) -> Mode:
    mode = os.fstat(fd).st_mode
    if stat.S_ISFIFO(mode):
        return Mode.PIPED
    elif stat.S_ISREG(mode):
        return Mode.REDIRECTED
    return Mode.TERMINAL
