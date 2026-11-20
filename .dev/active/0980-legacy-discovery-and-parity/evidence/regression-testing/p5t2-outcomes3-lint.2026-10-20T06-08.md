# P5-T2 outcomes3-lint

Timestamp: 2026-10-20T06-08

Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py packages/discovery-runtime/src/drm_copilot_discovery/parity_entry_rules.py packages/discovery-runtime/src/drm_copilot_discovery/parity_models.py tests/discovery_runtime/test_parity_models.py

EXIT_CODE: 1

Output Summary: Exact scoped stage completed in 1.185s; raw bytes are retained in the JSON receipt.

```text
S101 Use of `assert` detected
   --> packages\discovery-runtime\src\drm_copilot_discovery\parity_entry_rules.py:296:9
    |
294 |         matrix, pointer = result.matrix, result.pointer
295 |         source, target, client = result.source, result.target, result.client_id
296 |         assert source is not None and target is not None and client is not None
    |         ^^^^^^
297 |         state = result.authored_state
298 |         approved = (
    |

E501 Line too long (92 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\parity_entry_rules.py:432:89
    |
430 |                         obligation.feature,
431 |                         "",
432 |                         f"Required feature lacks parity for client {obligation.client_id}.",
    |                                                                                         ^^^^
433 |                     )
434 |         outcomes: list[ParityEntryOutcome] = []
    |

I001 [*] Import block is un-sorted or un-formatted
  --> packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:3:1
   |
 1 |   """Check pinned parity and retain outcomes independently of authored summaries."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import replace
 6 | | from typing import TYPE_CHECKING
 7 | |
 8 | | from drm_copilot_discovery.claim_rules import ClaimContext
 9 | | from drm_copilot_discovery.coverage_scope_rules import object_rows
10 | | from drm_copilot_discovery.decision_rules import validate_decisions
11 | | from drm_copilot_discovery.dimension_rules import (
12 | |     covering_decisions,
13 | |     decision_scope,
14 | |     validate_dimensions,
15 | | )
16 | | from drm_copilot_discovery.evidence_rules import validate_evidence
17 | | from drm_copilot_discovery.models import JsonObject
18 | | from drm_copilot_discovery.parity_entry_rules import ParityEntryRules
19 | | from drm_copilot_discovery.parity_models import (
20 | |     ParityDimensionOutcome,
21 | |     ParityValidation as ParityValidation,
22 | | )
23 | | from drm_copilot_discovery.parity_target_rules import TargetProof
24 | | from drm_copilot_discovery.reference_links import string_value
25 | | from drm_copilot_discovery.references import index_references
26 | | from drm_copilot_discovery.report_models import ReportBudget
27 | | from drm_copilot_discovery.revision_rules import validate_revisions
28 | | from drm_copilot_discovery.runtime_claim_rules import has_text
   | |______________________________________________________________^
29 |
30 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:229:89
    |
227 |                 "Required target classifications are absent.",
228 |             )
229 |         # Missing required axes stay unresolved; undeclared optional axes are not required.
    |                                                                                         ^^^
230 |         for name in sorted((names | {"online", "offline", "mobile"}) - present):
231 |             outcomes.append(
    |

Found 4 errors.
[*] 1 fixable with the `--fix` option.
```
