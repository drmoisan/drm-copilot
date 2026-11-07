"""Shared configuration of the issue 1031 native-helper tests.

sys.dont_write_bytecode is set when this file is imported, before any test module
imports docs_python_native from .claude/lib/docs/python, so the tests write no
__pycache__ directory under .claude/ (spec S15).
"""

import sys

sys.dont_write_bytecode = True
