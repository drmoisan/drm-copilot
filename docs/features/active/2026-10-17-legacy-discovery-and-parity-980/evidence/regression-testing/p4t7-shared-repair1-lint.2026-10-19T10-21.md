# p4t7-shared-repair1-lint

Timestamp: 2026-10-19T10-21
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_inputs.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_values.py tests/discovery_runtime/analyzer/test_dependency_inputs.py tests/discovery_runtime/analyzer/test_dependency_input_limits.py
EXIT_CODE: 1
Output Summary: scoped lint; duration 1.176 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:3:1
   |
 1 |   """Bound and sanitize dependency declarations before format-specific projection."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import dataclass
 6 | | from typing import Literal, cast
 7 | |
 8 | | from .dependency_values import (
 9 | |     DependencyValue as DependencyValue,
10 | |     Ecosystem as Ecosystem,
11 | |     dependency_value as dependency_value,
12 | |     safe_identifier as safe_identifier,
13 | | )
   | |_^
14 |
15 |   DependencyKind = Literal["declaration", "locked-package", "declared-lock-edge"]
   |
help: Organize imports

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_dependency_input_limits.py:3:1
   |
 1 |   """Verify dependency work and allocation boundaries using only memory values."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from collections.abc import Iterator
 6 | | from dataclasses import replace
 7 | | from typing import Self, SupportsIndex, cast
 8 | |
 9 | | import pytest
10 | | from drm_copilot_discovery.analyzer import dependency_values
11 | | from drm_copilot_discovery.analyzer.dependency_inputs import (
12 | |     DependencyBudget,
13 | |     DependencyInputError,
14 | |     DependencyLimits,
15 | |     DependencyResult,
16 | |     dependency_value,
17 | |     safe_identifier,
18 | | )
19 | | from tests.discovery_runtime.analyzer.test_dependency_inputs import add
   | |_______________________________________________________________________^
   |
help: Organize imports

TC003 Move standard library import `collections.abc.Iterator` into a type-checking block
 --> tests\discovery_runtime\analyzer\test_dependency_input_limits.py:5:29
  |
3 | from __future__ import annotations
4 |
5 | from collections.abc import Iterator
  |                             ^^^^^^^^
6 | from dataclasses import replace
7 | from typing import Self, SupportsIndex, cast
  |
help: Move into type-checking block

F401 [*] `drm_copilot_discovery.analyzer.dependency_inputs.DependencyInputError` imported but unused
  --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:11:5
   |
 9 |     DependencyBudget,
10 |     DependencyCandidate,
11 |     DependencyInputError,
   |     ^^^^^^^^^^^^^^^^^^^^
12 |     DependencyLimits,
13 |     DependencyResult,
   |
help: Remove unused import: `drm_copilot_discovery.analyzer.dependency_inputs.DependencyInputError`

Found 4 errors.
[*] 3 fixable with the `--fix` option (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```
