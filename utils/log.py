import os
import re
import logging
import datetime
from colors import Colors

# Default logging strings
date_string = "%m-%d-%YT%H:%M:%S"
default_string = '{levelname}: {name}: {asctime}: {message}'
thread_string = '{levelname}: {name}: {asctime}: {threadName}: {message}'
log_regex = re.compile(r'\033\[\d\d;1m(DEBUG|INFO|WARNING|ERROR|CRITICAL): (.*?): (\d\d-\d\d-\d\d\d\dT\d\d:\d\d:\d\d): (.*)\033\[0m$')
thread_regex = re.compile(r'\033\[\d\d;1m(DEBUG|INFO|WARNING|ERROR|CRITICAL): (.*?): (\d\d-\d\d-\d\d\d\dT\d\d:\d\d:\d\d): (.*?): (.*)\033\[0m$')

def default_parse(line, regex=log_regex, frmt=date_string):
    m = regex.match(line)
    if m is None:
        return m
    return {
        'level': m.groups()[0],
        'name': m.groups()[1],
        'date': datetime.datetime.strptime(m.groups()[2], frmt),
        'message': m.groups()[3],
    }

def thread_parse(line, regex=thread_regex, frmt=date_string):
    m = regex.match(line)
    if m is None:
        return m
    return {
        'level': m.groups()[0],
        'name': m.groups()[1],
        'date': datetime.datetime.strptime(m.groups()[2], frmt),
        'thread': m.groups()[3],
        'message': m.groups()[4],
    }

def parse_log(log, log_parser=default_parse):
    with open(log) as f:
        for line in f:
            line = line.rstrip("\n")
            yield default_parse(line)

class BraceMessage(object):
    """Class to allow for use of str.format in logs.

    This class allows for lazy evaluation of the set.format, i.e. the string is
    not created unless it will actually be logged.
    """

    def __init__(self, fmt, *args, **kwargs):
        """Create the str.format object."""
        self.fmt = fmt
        self.args = args
        self.kwargs = kwargs

    def __str__(self):
        """Insert the args into the string."""
        return self.fmt.format(*self.args, **self.kwargs)

class ColoredFormatter(logging.Formatter):
    COLORS = {
        'WARNING': Colors.YELLOW,
        'INFO': Colors.PURPLE,
        'DEBUG': Colors.BLUE,
        'CRITICAL': Colors.BLACK,
        'ERROR': Colors.RED,
    }

    def format(self, record):
        return f'{self.COLORS[record.levelname]}{super().format(record)}{Colors.NORMAL}'

def get_logger(
        name, *,
        level=None,
        format_string=default_string,
        date_format=date_string,
        thread=False
):
    if level is None:
        level = os.getenv('LOG_LEVEL', "DEBUG")
    numeric_level = getattr(logging, level.upper(), None)
    if not isinstance(numeric_level, int):
        raise ValueError("Invalid log level: {}".format(level))

    if thread:
        format_string = thread_string

    logger = logging.getLogger(name)
    logger.setLevel(numeric_level)

    if not logger.handlers:
        formatter = ColoredFormatter(format_string, datefmt=date_format, style='{')
        ch = logging.StreamHandler()
        ch.setFormatter(formatter)
        logger.addHandler(ch)

    logger.propagate = False

    return logger
