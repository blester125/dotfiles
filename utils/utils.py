from collections import deque, Sequence, Mapping
from itertools import count

def len_gen(gen):
    c = count()
    deque(zip(gen, c), 0)
    return next(c)


class Struct:
    def __init__(self, d):
        for k, v in d.items():
            if isinstance(v, Sequence) and not isinstance(v, str):
                setattr(self, k, [Struct(x) if isinstance(x, Mapping) else x for x in v])
            elif isinstance(v, Mapping):
                setattr(self, k, Struct(v))
            else:
                setattr(self, k, v)
    def __repr__(self):
        return repr(self.__dict__)
