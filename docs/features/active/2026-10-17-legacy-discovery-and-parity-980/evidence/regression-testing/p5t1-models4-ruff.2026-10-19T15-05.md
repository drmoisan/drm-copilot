# P5-T1 models4-ruff

Timestamp: 2026-10-19T15-05
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/report_models.py tests/discovery_runtime/test_report_models.py scripts/dev_tools/discovery/coverage_report.py tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_rendering.py
EXIT_CODE: 1

Duration seconds: 1.338

```text
I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_report_models.py:3:1
   |
 1 |   """Verify pure report budgets, deterministic views and v1 compatibility boundaries."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import json
 6 | | import math
 7 | | from dataclasses import FrozenInstanceError
 8 | | from typing import TYPE_CHECKING, cast
 9 | |
10 | | import pytest
11 | |
12 | | from drm_copilot_discovery import report_models
13 | | from drm_copilot_discovery.models import (
14 | |     JsonObject,
15 | |     JsonValue,
16 | |     ParseLimits,
17 | |     canonical_json,
18 | | )
19 | | from drm_copilot_discovery.report_models import (
20 | |     DiscoveryReport,
21 | |     ReportBudget,
22 | |     ReportLimitError,
23 | |     bounded_object,
24 | |     build_coverage_rows,
25 | |     parse_coverage_ledger,
26 | |     ratio,
27 | |     render_coverage_report,
28 | | )
   | |_^
29 |
30 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (91 > 88)
  --> tests\discovery_runtime\test_report_models.py:94:89
   |
92 |     monkeypatch: MonkeyPatch,
93 | ) -> None:
94 |     """Intercept rendering via monkeypatch; oversized Markdown fails first; return None."""
   |                                                                                         ^^^
95 |     document = JsonObject((("key", "😀"),))
96 |     report = DiscoveryReport(
   |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_report_models.py:145:89
    |
144 | def test_budget_checks_records_nodes_depth_and_cycles() -> None:
145 |     """Reject each independent traversal capacity without partial output; return None."""
    |                                                                                         ^
146 |     cycle: list[object] = []
147 |     cycle.append(cycle)
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_report_models.py:210:89
    |
208 | @pytest.mark.parametrize("limits, pretty", [(None, False), (ParseLimits(), 1)])
209 | def test_constructor_rejects_ambiguous_policy(limits: object, pretty: object) -> None:
210 |     """Reject limits/style (objects) with fixed policy error; return None without I/O."""
    |                                                                                         ^
211 |     with pytest.raises(ValueError, match="ParseLimits and a boolean"):
212 |         ReportBudget(cast("ParseLimits", limits), pretty=cast("bool", pretty))
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_report_models.py:219:89
    |
217 |     numerator: int, denominator: int
218 | ) -> None:
219 |     """Project numerator/denominator (int) without inferring completeness; return None."""
    |                                                                                         ^^
220 |     value = ratio(numerator, denominator, unit="source feature identities")
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_report_models.py:309:89
    |
308 | def test_oversized_input_fails_before_detached_copy(monkeypatch: MonkeyPatch) -> None:
309 |     """Intercept copy through monkeypatch; prospective failure comes first; return None."""
    |                                                                                         ^^^
310 |
311 |     def forbidden(value: object) -> None:
    |

Found 6 errors.
[*] 1 fixable with the `--fix` option.

```
