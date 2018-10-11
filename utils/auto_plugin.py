import inspect
from functools import wraps

def optional_params(func):
    @wraps(func)
    def wrapped(*args, **kwargs):
        if len(args) == 1 and len(kwargs) == 0 and callable(args[0]):
            return func(args[0])
        return lambda x: func(x, *args , **kwargs)
    return wrapped

@optional_params
def plugin(cls, name='create_model'):
    """Automatically create a plugin hook for the decorated model.

    addons/model.py
        @plugin
        class A: pass

    >>> from model import create_model
    >>> a = create_model()
    >>> type(a)
    <model.A object as ...>
    """
    g = inspect.stack()[2][0].f_globals
    def create(*args, **kwargs):
        return cls(*args, **kwargs)
    g[name] = create
    return cls
