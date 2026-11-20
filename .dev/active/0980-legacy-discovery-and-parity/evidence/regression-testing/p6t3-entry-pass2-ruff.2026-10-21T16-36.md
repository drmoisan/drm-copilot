# P6-T3 installed entry ruff

Timestamp: 2026-10-21T16-36

Command: `WORKSPACE\.venv\Scripts\python.exe -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/cli.py tests/discovery_runtime/test_legacy_adapters.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 0.208 seconds.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_legacy_adapters.py:3:1
   |
 1 |   """Keep legacy entry forwarding on the bounded installed CLI composition."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import io
 6 | | import json
 7 | | import sys
 8 | | from typing import TYPE_CHECKING
 9 | |
10 | | import pytest
11 | |
12 | | from drm_copilot_discovery import cli
13 | | from drm_copilot_discovery.cli import CliPorts
14 | | from drm_copilot_discovery.models import ParseLimits
15 | |
16 | | from tests.discovery_runtime.test_cli_errors import CountedArguments
   | |____________________________________________________________________^
17 |
18 |   if TYPE_CHECKING:
   |
help: Organize imports

Found 1 error.
[*] 1 fixable with the `--fix` option.

```
