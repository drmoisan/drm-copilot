# P5-T1 graph2-ruff

Timestamp: 2026-10-20T03-36
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/coverage_report.py packages/discovery-runtime/src/drm_copilot_discovery/coverage_population.py
EXIT_CODE: 1

Duration seconds: 1.592

```text
E501 Line too long (89 > 88)
 --> packages\discovery-runtime\src\drm_copilot_discovery\coverage_population.py:1:89
  |
1 | """Collect source-owned coverage identities through existing scope and proof services."""
  |                                                                                         ^
2 |
3 | from __future__ import annotations
  |

E501 Line too long (90 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\coverage_population.py:41:89
   |
40 | class CoveragePopulation:
41 |     """Collect one report's source selection and proof queries without granting authority.
   |                                                                                         ^^
42 |
43 |     The validation composer supplies accepted typed assessments. Call collect once,
   |

E501 Line too long (90 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\coverage_population.py:79:89
   |
77 |         self.errors: dict[str, list[str]] = {}
78 |         self.claim_errors: set[str] = set()
79 |         # Physical paths preserve invalid ownership/reference diagnostics without aliases.
   |                                                                                         ^^
80 |         for finding in findings:
81 |             if finding.severity == "error" and finding.artifact_path is not None:
   |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\coverage_population.py:109:89
    |
107 |         self, record: ArtifactRecord, pointer: str
108 |     ) -> tuple[ArtifactRecord, ...]:
109 |         """Resolve record/pointer (ArtifactRecord/str) with accepted links; return tuple.
    |                                                                                         ^
110 |
111 |         Reserves local link visits; raises ReportLimitError on excess. Only local
    |

E501 Line too long (92 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\coverage_population.py:260:89
    |
258 |                 continue
259 |             count += 1
260 |             # Exact repository/pin ownership prevents target scenarios proving source facts.
    |                                                                                         ^^^^
261 |             for feature in self.targets(scenario, "/feature_refs"):
262 |                 if (
    |

I001 [*] Import block is un-sorted or un-formatted
  --> packages\discovery-runtime\src\drm_copilot_discovery\coverage_report.py:26:5
   |
25 |   if TYPE_CHECKING:
26 | /     from drm_copilot_discovery.claim_rules import ClaimValidation
27 | |     from drm_copilot_discovery.dimension_rules import DimensionValidation
28 | |     from drm_copilot_discovery.evidence_rules import EvidenceValidation
29 | |     from drm_copilot_discovery.findings import Finding
30 | |     from drm_copilot_discovery.references import ReferenceIndex
31 | |     from drm_copilot_discovery.coverage_population import Identity
32 | |     from drm_copilot_discovery.validation import ValidationMode
   | |_______________________________________________________________^
   |
help: Organize imports

Found 6 errors.
[*] 1 fixable with the `--fix` option.

```
