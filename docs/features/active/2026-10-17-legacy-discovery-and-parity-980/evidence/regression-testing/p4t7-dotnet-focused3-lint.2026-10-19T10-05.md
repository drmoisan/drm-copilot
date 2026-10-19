# P4-T7 .NET parser scoped gate

Timestamp: 2026-10-19T10-05
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_dotnet.py tests/discovery_runtime/analyzer/test_dependency_dotnet.py
EXIT_CODE: 1

Path rendering uses WORKSPACE and SCRATCH tokens; exact streams are preserved by hash.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_dependency_dotnet.py:3:1
   |
 1 |   """Verify pure .NET dependency declarations, redaction and bounded failure contracts."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import json
 6 | | from dataclasses import replace
 7 | | from typing import cast
 8 | |
 9 | | import pytest
10 | |
11 | | from drm_copilot_discovery.analyzer.dependency_dotnet import DotnetDependencyFormat
12 | | from drm_copilot_discovery.analyzer.dependency_dotnet import parse_dotnet_dependencies
13 | | from drm_copilot_discovery.analyzer.dependency_inputs import (
14 | |     DependencyInputError,
15 | |     DependencyLimits,
16 | | )
   | |_^
   |
help: Organize imports

Found 1 error.
[*] 1 fixable with the `--fix` option.

```
