# p4t7-lead-focused2-lint

Timestamp: 2026-10-19T09-53
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_inputs.py tests/discovery_runtime/analyzer/test_dependency_inputs.py
EXIT_CODE: 1
Output Summary: scoped lint; duration 1.155 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
E501 Line too long (91 > 88)
 --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:1:89
  |
1 | """Exercise the shared dependency parser contract entirely with immutable memory values."""
  |                                                                                         ^^^
2 |
3 | from dataclasses import FrozenInstanceError, replace
  |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:3:1
   |
 1 |   """Exercise the shared dependency parser contract entirely with immutable memory values."""
 2 |
 3 | / from dataclasses import FrozenInstanceError, replace
 4 | | from typing import Protocol, cast
 5 | |
 6 | | import pytest
 7 | |
 8 | | from drm_copilot_discovery.analyzer.dependency_inputs import (
 9 | |     DependencyAnchor,
10 | |     DependencyBudget,
11 | |     DependencyCandidate,
12 | |     DependencyInputError,
13 | |     DependencyLimits,
14 | |     DependencyResult,
15 | |     DependencyValue,
16 | |     Ecosystem,
17 | |     dependency_value,
18 | |     safe_identifier,
19 | | )
   | |_^
   |
help: Organize imports

E501 Line too long (90 > 88)
  --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:44:89
   |
43 | def add(budget: DependencyBudget, **changes: object) -> None:
44 |     """Append a valid declaration or injected malformed values; mutate only its budget."""
   |                                                                                         ^^
45 |     values: dict[str, object] = {
46 |         "kind": "declaration",
   |

Found 3 errors.
[*] 1 fixable with the `--fix` option.
```
