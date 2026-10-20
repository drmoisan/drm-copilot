# P5-T2 graph ruff

Timestamp: 2026-10-20T06-23

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py packages/discovery-runtime/src/drm_copilot_discovery/report_models.py tests/discovery_runtime/test_parity_report.py tests/discovery_runtime/test_parity_metrics.py tests/discovery_runtime/test_report_models.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.199 seconds.

```text
E501 Line too long (95 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:146:89
    |
144 |             if isinstance(authored, tuple):
145 |                 budget.work(len(authored))
146 |                 # Preserve each authored blocker and exact row rather than deduplicating prose.
    |                                                                                         ^^^^^^^
147 |                 for text in authored:
148 |                     value = {**location, "blocker": text}
    |

E501 Line too long (93 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:187:89
    |
185 |             required.add("mobile")
186 |         values: dict[str, list[ParityDimensionOutcome]] = {}
187 |         # Multiple direct/nested representations remain a single axis with combined validity.
    |                                                                                         ^^^^^
188 |         for dimension in entry.dimensions if entry else ():
189 |             values.setdefault(dimension.name, []).append(dimension)
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:253:89
    |
252 |     def project(self, unavailable: JsonObject) -> JsonObject:
253 |         """Return a bounded summary, using unavailable (JsonObject) when scope is absent.
    |                                                                                         ^
254 |
255 |         Unavailable source scope produces null metrics, not inferred completion.
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:277:89
    |
275 |         totals = Counter[str]()
276 |         self.population.budget.work(len(obligations))
277 |         # Missing rows remain obligations; duplicate rows never select a preferred proof.
    |                                                                                         ^
278 |         for (identity, client), obligation in obligations.items():
279 |             matches = self.by_obligation.get((identity, client), [])
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py:331:89
    |
329 |             len(self.decisions.approved) + len(self.population.index.records)
330 |         )
331 |         # Physical approval identity prevents same-ID records from borrowing eligibility.
    |                                                                                         ^
332 |         for item in self.decisions.approved:
333 |             approved.add((item.record.artifact.path, item.record.pointer))
    |

I001 [*] Import block is un-sorted or un-formatted
  --> packages\discovery-runtime\src\drm_copilot_discovery\parity_report.py:3:1
   |
 1 |   """Project parity from captured assessments while retaining bounded v1 helpers."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import re
 6 | | from typing import TYPE_CHECKING, cast
 7 | |
 8 | | from drm_copilot_discovery.parity_metrics import ParityProjection
 9 | | from drm_copilot_discovery.coverage_report import coverage_preflight
10 | | from drm_copilot_discovery.models import JsonObject, ParseLimits, to_plain_value
11 | | from drm_copilot_discovery.parsing import parse_document
12 | | from drm_copilot_discovery.rendering import render_pretty_json, sort_rows
13 | | from drm_copilot_discovery.report_models import (
14 | |     DiscoveryReport,
15 | |     ReportBudget,
16 | |     bounded_object,
17 | | )
   | |_^
18 |
19 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\report_models.py:274:89
    |
272 |         whitespace or ASCII escaping would exceed the independent output budget.
273 |         """
274 |         # Only the closed artifact kind selects a heading; authored text cannot inject it.
    |                                                                                         ^^
275 |         heading = (
276 |             "parity"
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_parity_metrics.py:137:89
    |
135 |         dimensions=dimensions,
136 |     )
137 |     # Preserve all actual family diagnostics when authoritative source scope is selected.
    |                                                                                         ^
138 |     findings = tuple(
139 |         item
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_parity_metrics.py:255:89
    |
253 |     value: str,
254 | ) -> None:
255 |     """Reject altered field/value (str) without hiding authored full state; return None."""
    |                                                                                         ^^^
256 |     snapshot = report_graph(report_profile, snapshot_catalog)
257 |     matrix = next(
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_parity_metrics.py:381:89
    |
379 |     """Remove authority kind (str); return None without promoting an empty graph."""
380 |     snapshot = report_graph(report_profile, snapshot_catalog)
381 |     # Removing a record tests absence without changing independent retained source bytes.
    |                                                                                         ^
382 |     snapshot = replace(
383 |         snapshot,
    |

TC002 Move third-party import `drm_copilot_discovery.snapshot.DiscoverySnapshot` into a type-checking block
   --> tests\discovery_runtime\test_parity_report.py:168:48
    |
166 | def test_graph_entrypoints_reject_non_snapshot_inputs(value: object) -> None:
167 |     """Reject value (object) before any graph work; return None without I/O."""
168 |     from drm_copilot_discovery.snapshot import DiscoverySnapshot
    |                                                ^^^^^^^^^^^^^^^^^
169 |
170 |     with pytest.raises(ValueError, match="captured v2 DiscoverySnapshot"):
    |
help: Move into type-checking block

Found 11 errors.
[*] 1 fixable with the `--fix` option (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```
