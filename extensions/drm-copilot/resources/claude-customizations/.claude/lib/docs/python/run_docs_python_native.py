"""Entry script of the Python-native documentation analyzers (issue 1031).

The PowerShell adapter starts this script with the interpreter arguments -I -B -X utf8
and writes one JSON request to standard input. The version check runs before the package
is imported, so an interpreter below the 3.11 floor writes one version-below-floor error
object and exits 4. The script uses no syntax newer than Python 3.6 so that such an
interpreter reaches the check.
"""

import os
import sys
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import MutableSequence, Sequence
    from typing import BinaryIO

FLOOR = (3, 11)
FLOOR_ERROR = (
    b'{"error":{"code":"version-below-floor",'
    b'"message":"Python 3.11 or later is required"},"protocol_version":1}'
)


def ensure_package_path(path_list: "MutableSequence[str]", directory: str) -> None:
    """Insert the script directory at the front of a module search path when absent."""
    if directory not in path_list:
        path_list.insert(0, directory)


def entry(
    stdin: "BinaryIO",
    stdout: "BinaryIO",
    version_info: "Sequence[object]" = sys.version_info,
) -> int:
    """Check the interpreter floor, then delegate to the protocol main function."""
    if tuple(version_info[:2]) < FLOOR:
        stdout.write(FLOOR_ERROR)
        return 4
    ensure_package_path(sys.path, os.path.dirname(os.path.abspath(__file__)))
    from docs_python_native.protocol import main

    return main(stdin, stdout, version_info=version_info)


if __name__ == "__main__":
    sys.exit(entry(sys.stdin.buffer, sys.stdout.buffer))
