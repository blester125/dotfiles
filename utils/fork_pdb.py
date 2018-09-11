import os
import sys
import pdb


class ForkPdb(pdb.Pdb):
    """A version of pdb that allows you to attach a debugger to forked process.

    Useful for debugging in a process created by the multiprocessing library.

    Note:
        * `import fork_pdb` must be done outside of the function that will be run
        by `multiprocessing.Process`.
        * Only works with python 3
    """
    _original_stdin_fd = sys.stdin.fileno()
    _original_stdin = None

    def __init__(self):
        super(ForkPdb, self).__init__(nosigint=True)

    def _cmdloop(self):
        current_stdin = sys.stdin
        try:
            if not self._original_stdin:
                self._original_stdin = os.fdopen(self._original_stdin_fd)
            sys.stdin = self._original_stdin
            self.cmdloop()
        finally:
            sys.stdin = current_stdin


def set_trace():
    ForkPdb().set_trace(sys._getframe().f_back)
