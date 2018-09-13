from functools import wraps
from contextlib import ExitStack
from typing import Callable
import traceback
from functools import wraps


class Transaction:
    def __init__(self):
        self.stack = ExitStack()

    def on_cleanup(self, callback: Callable[..., None], *args, **kwds):
        if isinstance(callback, Transaction):
            return self.stack.enter_context(callback.stack, *args, **kwds)
        else:
            return self.stack.callback(callback, *args, **kwds)

    def on_error(self, callback: Callable[..., None], *args, **kwds):
        def exit(stack, exc_type, exc_value, traceback=None) -> bool:
            if exc_type:
                callback(*args, **kwds)
            return False
        return self.stack.push(exit)

    def __enter__(self, *args, **kwds):
        self.stack.__enter__(*args, **kwds)
        return self

    def __exit__(self, *args, **kwds):
        return self.stack.__exit__(*args, **kwds)

    #def pop_all(self):
    #    return Transaction(stack=self.stack.pop_all())

    def commit(self) -> None:
        self.stack.pop_all().close()


def transaction(f: Callable):
    @wraps(f)
    def wrapper(*args, **kwds):
        tx = Transaction()
        with tx:
            return f(*args, tx=tx, **kwds)
    return wrapper

# TODO: on_error, on_cleanup: accept context managers; mount: return exit callback


def catch(f):
    @wraps(f)
    def wrapper(*args, **kwds):
        try:
            return f(*args, **kwds)
        except:
            traceback.print_exc()
            return None
    return wrapper
