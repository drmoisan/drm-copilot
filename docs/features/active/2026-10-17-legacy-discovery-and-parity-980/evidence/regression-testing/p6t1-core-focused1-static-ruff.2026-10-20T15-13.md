# P6-T1 renderer ruff

Timestamp: 2026-10-20T15-13

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/service.py packages/discovery-runtime/src/drm_copilot_discovery/operations.py packages/discovery-runtime/src/drm_copilot_discovery/service_inspection.py packages/discovery-runtime/src/drm_copilot_discovery/service_reports.py packages/discovery-runtime/src/drm_copilot_discovery/service_mutations.py packages/discovery-runtime/src/drm_copilot_discovery/service_bootstrap.py tests/discovery_runtime/test_service.py tests/discovery_runtime/test_service_publication.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.410 seconds.

```text
E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\service_bootstrap.py:290:89
    |
288 |     artifacts = projected if context.request.dry_run and result.ok else ()
289 |     if result.publication is not None:
290 |         # Bounded planned identities provide exact content provenance for actual effects.
    |                                                                                         ^
291 |         by_path = {row.path: row for row in projected}
292 |         # Actual guarded writer dispositions supersede the preflight status only.
    |

TC001 Move application import `drm_copilot_discovery.findings.Finding` into a type-checking block
  --> packages\discovery-runtime\src\drm_copilot_discovery\service_inspection.py:8:44
   |
 7 | from drm_copilot_discovery.configuration import DEFAULT_PROFILE
 8 | from drm_copilot_discovery.findings import Finding
   |                                            ^^^^^^^
 9 | from drm_copilot_discovery.models import JsonObject, canonical_json
10 | from drm_copilot_discovery.operations import (
   |
help: Move into type-checking block

I001 [*] Import block is un-sorted or un-formatted
   --> packages\discovery-runtime\src\drm_copilot_discovery\service_inspection.py:132:5
    |
130 |       no write, continuation claim or source execution occurs.
131 |       """
132 | /     from dataclasses import replace
133 | |
134 | |     from drm_copilot_discovery.source_read_models import (
135 | |         SourceReadLimits,
136 | |         SourceReadRequest,
137 | |     )
138 | |     from drm_copilot_discovery.source_reads import SourceReader
139 | |     from drm_copilot_discovery.service_serialization import wire_object
    | |_______________________________________________________________________^
140 |
141 |       selection = context.authority.read_selection
    |
help: Organize imports

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_service.py:3:1
   |
 1 |   """Exercise service authority, capture and inspection with isolated memory stores."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import json
 6 | | from datetime import datetime, timezone
 7 | | from hashlib import sha256
 8 | | from typing import TYPE_CHECKING, Literal, cast
 9 | |
10 | | import pytest
11 | | from drm_copilot_discovery.analyzer.input_capture import pin_inventory_sources
12 | | from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
13 | | from drm_copilot_discovery.configuration import (
14 | |     DEFAULT_PROFILE,
15 | |     LOCATOR_PATH,
16 | |     ActivationRecord,
17 | |     locator_bytes,
18 | | )
19 | | from drm_copilot_discovery.init_flow import plan_initialization
20 | | from drm_copilot_discovery.init_io import InitializationIO
21 | | from drm_copilot_discovery.init_projection import InitializationRequest
22 | | from drm_copilot_discovery.models import ParseLimits
23 | | from drm_copilot_discovery.mutation_io import GuardedMutationWriter, capture_workspace
24 | | from drm_copilot_discovery.report_models import bounded_object
25 | | from drm_copilot_discovery.service import execute
26 | | from drm_copilot_discovery.service_contracts import (
27 | |     DiscoveryResult,
28 | |     RuntimeIdentity,
29 | |     ServiceAuthority,
30 | |     ServiceRuntimeError,
31 | | )
32 | | from drm_copilot_discovery.source_read_models import ReadGrant, ReadSelection
33 | |
34 | | from tests.discovery_runtime.initialization_test_support import (
35 | |     MemoryRepository,
36 | |     initialization_catalog as initialization_catalog,
37 | |     initialization_templates as initialization_templates,
38 | | )
39 | | from tests.discovery_runtime.test_activation_store import ConfigurationCase
   | |___________________________________________________________________________^
40 |
41 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_service.py:248:89
    |
246 |     fields: dict[str, object],
247 | ) -> None:
248 |     """Reject field overrides before trusted calls; return None, memory state unchanged."""
    |                                                                                         ^^^
249 |     before = dict(service_io.disk.store.files)
250 |     operation = cast("str", fields.get("operation", "profile"))
    |

E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_service.py:354:89
    |
352 |     service_io: MemoryService,
353 | ) -> None:
354 |     """Validate a wrong-kind captured path; return None with original and graph findings."""
    |                                                                                         ^^^^
355 |     result = invoke(
356 |         service_io, "validate-feature-contract", {"artifact_path": DEFAULT_PROFILE}
    |

E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_service.py:380:89
    |
378 |     service_io: MemoryService,
379 | ) -> None:
380 |     """Refuse an ungranted source path in MemoryService; return None without row leakage."""
    |                                                                                         ^^^^
381 |     result = invoke(
382 |         service_io, "read-source", {"read_operation": "list", "paths": ["application"]}
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\test_service_publication.py:3:1
   |
 1 |   """Verify service planning and publication with real validators and memory I/O."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import json
 6 | | from hashlib import sha256
 7 | | from typing import TYPE_CHECKING
 8 | |
 9 | | import pytest
10 | | from drm_copilot_discovery.configuration import DEFAULT_PROFILE
11 | | from drm_copilot_discovery.draft_contracts import ContractDraft, contract_changes
12 | | from drm_copilot_discovery.models import canonical_json
13 | | from drm_copilot_discovery.mutation_io import capture_workspace
14 | | from drm_copilot_discovery.path_models import WriteGrant
15 | |
16 | | from tests.discovery_runtime.test_draft_scenarios import scenario_fields
17 | | from tests.discovery_runtime.test_service import (
18 | |     MemoryService,
19 | |     initialization_catalog as initialization_catalog,
20 | |     initialization_templates as initialization_templates,
21 | |     invoke,
22 | |     service_io as service_io,
23 | |     service_plan as service_plan,
24 | | )
   | |_^
25 |
26 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_service_publication.py:119:89
    |
117 |     operation: str,
118 | ) -> None:
119 |     """Publish operation's known failed gate as paired files; return None, memory only."""
    |                                                                                         ^^
120 |     result = invoke(
121 |         service_io, operation, write=True, mode="discovery-complete", format="both"
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_service_publication.py:141:89
    |
139 |     service_io: MemoryService, format: str
140 | ) -> None:
141 |     """Render format (str) from one captured report; return None with no memory writes."""
    |                                                                                         ^^
142 |     before = dict(service_io.disk.store.files)
143 |     result = invoke(service_io, "coverage-report", format=format)
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_service_publication.py:154:89
    |
152 |     service_io: MemoryService,
153 | ) -> None:
154 |     """Verify default paired publication and path confinement; return None, memory only."""
    |                                                                                         ^^^
155 |     result = invoke(service_io, "validate-all")
156 |     assert result.ok and len(result.artifacts) == 2
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_service_publication.py:166:89
    |
164 |     service_io: MemoryService,
165 | ) -> None:
166 |     """Retain malformed core blockers without report writes; return None, memory only."""
    |                                                                                         ^
167 |     service_io.disk.store.put("docs/migration/discovery/coverage-ledger.json", b"{}")
168 |     before = dict(service_io.disk.store.files)
    |

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\test_service_publication.py:179:89
    |
177 |     dry_run: bool,
178 | ) -> None:
179 |     """Initialize empty memory io with dry_run; return None without fake directory hashes."""
    |                                                                                         ^^^^^
180 |     io = MemoryService(initialization_catalog)
181 |     io.disk.store.metadata.add("application", kind="directory")
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\test_service_publication.py:206:89
    |
204 |     action: str,
205 | ) -> None:
206 |     """Run explicit action over real memory activation; return None with actual counts."""
    |                                                                                         ^^
207 |     inputs = {"configuration_action": action}
208 |     if action == "activate":
    |

E501 Line too long (101 > 88)
   --> tests\discovery_runtime\test_service_publication.py:220:89
    |
218 |     service_io: MemoryService,
219 | ) -> None:
220 |     """Create an explicitly supplied scenario plan in memory; return None without evidence claims."""
    |                                                                                         ^^^^^^^^^^^^^
221 |     seed_contract(service_io)
222 |     service_io.disk.store.put(
    |

E501 Line too long (92 > 88)
   --> tests\discovery_runtime\test_service_publication.py:283:89
    |
281 |     kind: str,
282 | ) -> None:
283 |     """Generate kind from actual capture; return None without source execution or writes."""
    |                                                                                         ^^^^
284 |     seed_contract(service_io)
285 |     before = dict(service_io.disk.store.files)
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\test_service_publication.py:298:89
    |
296 |     with_report: bool,
297 | ) -> None:
298 |     """Export a contract with optional derived report; return None after dry-run only."""
    |                                                                                         ^
299 |     seed_contract(service_io)
300 |     if with_report:
    |

E501 Line too long (97 > 88)
   --> tests\discovery_runtime\test_service_publication.py:319:89
    |
317 |     operation: str,
318 | ) -> None:
319 |     """Reject malformed manifest for operation; return None, preserving captured memory bytes."""
    |                                                                                         ^^^^^^^^^
320 |     service_io.disk.store.put("proposals/manifest.json", b"{}")
321 |     before = dict(service_io.disk.store.files)
    |

Found 18 errors.
[*] 3 fixable with the `--fix` option (1 hidden fix can be enabled with the `--unsafe-fixes` option).

```
