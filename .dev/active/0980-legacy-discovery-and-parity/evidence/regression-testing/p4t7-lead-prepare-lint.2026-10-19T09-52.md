# p4t7-lead-prepare-lint

Timestamp: 2026-10-19T09-52
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_inputs.py tests/discovery_runtime/analyzer/test_dependency_inputs.py
EXIT_CODE: 1
Output Summary: scoped lint; duration 1.175 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
I001 [*] Import block is un-sorted or un-formatted
 --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:3:1
  |
1 |   """Bound and sanitize dependency declarations before format-specific projection."""
2 |
3 | / from __future__ import annotations
4 | |
5 | | from dataclasses import dataclass
6 | | import re
7 | | from typing import Literal, cast
  | |________________________________^
8 |
9 |   Ecosystem = Literal["node", "python", "dotnet"]
  |
help: Organize imports

E501 Line too long (90 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:78:89
   |
77 |     def __init__(self, code: str) -> None:
78 |         """Accept a declared code; raise ValueError for unknown codes; retain no input."""
   |                                                                                         ^^
79 |         if code not in _CODES:
80 |             raise ValueError("Unknown dependency diagnostic code")
   |

E501 Line too long (101 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:240:89
    |
238 | @dataclass(frozen=True)
239 | class DependencyCandidate:
240 |     """Sanitized syntax facts only; binding, execution and effective precedence remain unresolved."""
    |                                                                                         ^^^^^^^^^^^^^
241 |
242 |     kind: DependencyKind
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:256:89
    |
255 |     def __post_init__(self) -> None:
256 |         """Validate already sanitized construction; reject mutable or unsafe metadata."""
    |                                                                                         ^
257 |         if self.kind not in {"declaration", "locked-package", "declared-lock-edge"}:
258 |             raise ValueError("Unknown dependency candidate kind")
    |

E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:289:89
    |
287 | @dataclass(frozen=True)
288 | class DependencyResult:
289 |     """Immutable bounded parser output without Analysis rows, identities or provenance."""
    |                                                                                         ^^
290 |
291 |     candidates: tuple[DependencyCandidate, ...] = ()
    |

E501 Line too long (97 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:316:89
    |
315 | class DependencyBudget:
316 |     """Reserve parse work and sanitized output before allocations; exhaustion poisons results."""
    |                                                                                         ^^^^^^^^^
317 |
318 |     def __init__(self, limits: DependencyLimits) -> None:
    |

E501 Line too long (94 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:319:89
    |
318 |     def __init__(self, limits: DependencyLimits) -> None:
319 |         """Bind immutable limits and empty local counters; raise ValueError for bad limits."""
    |                                                                                         ^^^^^^
320 |         if not isinstance(limits, DependencyLimits):
321 |             raise ValueError("Dependency budget requires validated limits")
    |

E501 Line too long (92 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:331:89
    |
329 |         self, *, nodes: int = 0, candidates: int = 0, text_bytes: int = 0
330 |     ) -> None:
331 |         """Reserve independent nonnegative work; raise fixed limit error before mutation."""
    |                                                                                         ^^^^
332 |         if any(
333 |             type(value) is not int or value < 0
    |

E501 Line too long (92 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:350:89
    |
349 |     def decode(self, content: bytes) -> str:
350 |         """Decode one retained UTF-8 document after byte/physical-line preflight; no I/O."""
    |                                                                                         ^^^^
351 |         if not isinstance(cast("object", content), bytes):
352 |             raise ValueError("Dependency input must be retained bytes")
    |

E501 Line too long (94 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:373:89
    |
372 |     def note(self, code: str) -> None:
373 |         """Deduplicate a fixed parser diagnostic; reject unrecognized codes before storage."""
    |                                                                                         ^^^^^^
374 |         if code not in _CODES:
375 |             raise ValueError("Unknown dependency diagnostic code")
    |

E501 Line too long (96 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_inputs.py:476:89
    |
475 |     def result(self) -> DependencyResult:
476 |         """Return an immutable snapshot; previously exhausted/undecodable work cannot escape."""
    |                                                                                         ^^^^^^^^
477 |         if self._failed:
478 |             raise DependencyInputError("dependency-limit")
    |

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

E501 Line too long (94 > 88)
  --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:26:89
   |
25 |     def __call__(self, **values: object) -> None:
26 |         """Forward test-controlled values; the real collector must validate or reject them."""
   |                                                                                         ^^^^^^
27 |         ...
   |

E501 Line too long (90 > 88)
  --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:44:89
   |
43 | def add(budget: DependencyBudget, **changes: object) -> None:
44 |     """Append a valid declaration or injected malformed values; mutate only its budget."""
   |                                                                                         ^^
45 |     values: dict[str, object] = {
46 |         "kind": "declaration",
   |

E501 Line too long (89 > 88)
  --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:72:89
   |
70 |     field: str, value: object
71 | ) -> None:
72 |     """Pass an invalid capacity; expect construction failure without input processing."""
   |                                                                                         ^
73 |     with pytest.raises(ValueError, match="positive integers"):
74 |         replace(DependencyLimits(), **{field: value})
   |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:245:89
    |
244 | def test_carriers_are_immutable_and_preserve_distinct_dependency_kinds() -> None:
245 |     """Build independent declaration/locked/edge facts with unresolved target identity."""
    |                                                                                         ^^
246 |     item = candidate()
247 |     locked = replace(
    |

B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:258:9
    |
256 |     assert result.candidates[2].owner == "parent"
257 |     with pytest.raises(FrozenInstanceError):
258 |         setattr(item, "name", "changed")
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
259 |     with pytest.raises(FrozenInstanceError):
260 |         setattr(result, "candidates", ())
    |
help: Replace `setattr` with assignment

B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:260:9
    |
258 |         setattr(item, "name", "changed")
259 |     with pytest.raises(FrozenInstanceError):
260 |         setattr(result, "candidates", ())
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    |
help: Replace `setattr` with assignment

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:334:89
    |
333 | def test_shared_collector_redacts_values_and_keeps_requested_separate() -> None:
334 |     """Sanitize every output field while retaining factual version roles and conditions."""
    |                                                                                         ^^^
335 |     budget = DependencyBudget(DependencyLimits())
336 |     add(
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:359:89
    |
358 | def test_diagnostic_deduplication_and_snapshot_isolation() -> None:
359 |     """Repeated fixed diagnostics cost once; snapshots do not share mutable collections."""
    |                                                                                         ^^^
360 |     budget = DependencyBudget(DependencyLimits())
361 |     add(budget)
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:379:89
    |
378 | def test_encoded_candidate_and_raw_text_reservations_are_aggregate() -> None:
379 |     """Charge selected UTF-8 work plus quoted retained strings before candidate storage."""
    |                                                                                         ^^^
380 |     probe = DependencyBudget(DependencyLimits())
381 |     add(probe, name="café")
    |

E501 Line too long (94 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:406:89
    |
404 |     text: str, capacity: int, code: str
405 | ) -> None:
406 |     """Reject oversized characters, encoded bytes and escaped surrogates with fixed errors."""
    |                                                                                         ^^^^^^
407 |     budget = DependencyBudget(DependencyLimits(max_text_bytes=capacity))
408 |     with pytest.raises(DependencyInputError) as caught:
    |

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:427:89
    |
426 | def test_public_contract_invalid_types_and_fixed_error_messages() -> None:
427 |     """Reject public boundary misuse without exposing raw parser messages or input values."""
    |                                                                                         ^^^^^
428 |     with pytest.raises(ValueError, match="validated limits"):
429 |         DependencyBudget(cast("DependencyLimits", None))
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_inputs.py:443:89
    |
442 | def test_empty_and_repeated_results_are_deterministic() -> None:
443 |     """Repeated collection preserves stable order and does not mutate earlier results."""
    |                                                                                         ^
444 |     first, second = DependencyBudget(DependencyLimits()), DependencyBudget(
445 |         DependencyLimits()
    |

Found 25 errors.
[*] 4 fixable with the `--fix` option.
```
