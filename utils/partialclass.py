import functools

def partialclass(cls, *args, **kwargs):
    class PartialClass(cls):
        __init__ = functools.partialmethod(cls.__init__, *args, **kwargs)
    PartialClass.__name__ = cls.__name__
    return PartialClass
