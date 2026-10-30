# p2t7-lint-pass1

Timestamp: 2026-10-18T09-41
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/dimension_rules.py packages/discovery-runtime/src/drm_copilot_discovery/acceptance_rules.py tests/discovery_runtime/test_dimension_rules.py tests/discovery_runtime/test_acceptance_rules.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 15 errors.; [[36m*[0m] 1 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T09:41:45.957262+00:00
Duration seconds: 0.854
Phase: P2-T7 dimension and acceptance obligations; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Bind ready acceptance to exact criteria without claiming implementation passes."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import hashlib
[1m[94m 6 |[0m [1m[91m|[0m from dataclasses import dataclass
[1m[94m 7 |[0m [1m[91m|[0m from itertools import product
[1m[94m 8 |[0m [1m[91m|[0m from typing import TYPE_CHECKING
[1m[94m 9 |[0m [1m[91m|[0m
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery.claim_rules import ClaimContext
[1m[94m11 |[0m [1m[91m|[0m from drm_copilot_discovery.coverage_rules import validate_coverage
[1m[94m12 |[0m [1m[91m|[0m from drm_copilot_discovery.coverage_scope_rules import (
[1m[94m13 |[0m [1m[91m|[0m     object_rows,
[1m[94m14 |[0m [1m[91m|[0m     select_coverage_scope,
[1m[94m15 |[0m [1m[91m|[0m     strings,
[1m[94m16 |[0m [1m[91m|[0m )
[1m[94m17 |[0m [1m[91m|[0m from drm_copilot_discovery.decision_rules import validate_decisions
[1m[94m18 |[0m [1m[91m|[0m from drm_copilot_discovery.dimension_rules import (
[1m[94m19 |[0m [1m[91m|[0m     decision_scope,
[1m[94m20 |[0m [1m[91m|[0m     covering_decisions,
[1m[94m21 |[0m [1m[91m|[0m     validate_dimensions,
[1m[94m22 |[0m [1m[91m|[0m )
[1m[94m23 |[0m [1m[91m|[0m from drm_copilot_discovery.evidence_rules import validate_evidence
[1m[94m24 |[0m [1m[91m|[0m from drm_copilot_discovery.findings import Finding
[1m[94m25 |[0m [1m[91m|[0m from drm_copilot_discovery.models import JsonObject, canonical_json
[1m[94m26 |[0m [1m[91m|[0m from drm_copilot_discovery.references import index_references
[1m[94m27 |[0m [1m[91m|[0m from drm_copilot_discovery.runtime_claim_rules import has_text
   [1m[94m|[0m [1m[91m|______________________________________________________________^[0m
[1m[94m28 |[0m
[1m[94m29 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:118:89
    [1m[94m|[0m
[1m[94m116 |[0m         self, source: ArtifactRecord, scenario: ArtifactRecord
[1m[94m117 |[0m     ) -> tuple[tuple[ArtifactRecord, int, JsonObject], ...]:
[1m[94m118 |[0m         """Select criterion origins by the explicit expectation basis and exact scope."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m119 |[0m         if scenario.document.get("expectation_basis") == "verified-source":
[1m[94m120 |[0m             return tuple(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:155:89
    [1m[94m|[0m
[1m[94m154 |[0m     def identity(self, record: ArtifactRecord, source: ArtifactRecord) -> bool:
[1m[94m155 |[0m         """Keep legacy specifications and target-client ownership independently pinned."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m156 |[0m         document = record.document
[1m[94m157 |[0m         client_id = document.get("client_id")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:231:89
    [1m[94m|[0m
[1m[94m229 |[0m                 record,
[1m[94m230 |[0m                 "/source_content_sha256",
[1m[94m231 |[0m                 "Acceptance content digest differs from its referenced immutable inputs.",
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m232 |[0m             )
[1m[94m233 |[0m         if not self.identity(record, source):
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:237:89
    [1m[94m|[0m
[1m[94m235 |[0m                 record,
[1m[94m236 |[0m                 "/client_id",
[1m[94m237 |[0m                 "Specification ownership must match its legacy source or target client pin.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m238 |[0m             )
[1m[94m239 |[0m         if document.get("expectation_basis") == "verified-source" and (
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:248:89
    [1m[94m|[0m
[1m[94m246 |[0m                 record,
[1m[94m247 |[0m                 "/evidence_refs",
[1m[94m248 |[0m                 "Known source expectation requires observation proof at the source pin.",
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m249 |[0m             )
[1m[94m250 |[0m         if origin.kind == "product-decision" and not has_text(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (137 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:335:89
    [1m[94m|[0m
[1m[94m333 |[0m [1m[94m…[0m         feature,
[1m[94m334 |[0m [1m[94m…[0m         "/acceptance_criteria",
[1m[94m335 |[0m [1m[94m…[0m         f"Missing ready criterion/client/platform/mode: {criterion.get('id')}/{obligation.client_id}/{platform}/{mode}.",
    [1m[94m|[0m                                                                           [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m336 |[0m [1m[94m…[0m     )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:339:89
    [1m[94m|[0m
[1m[94m338 |[0m     def empty_scope(self) -> None:
[1m[94m339 |[0m         """Reject vacuous feature completion unless confirmed accounting justifies it."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m340 |[0m         features = tuple(
[1m[94m341 |[0m             item
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (125 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:385:89
    [1m[94m|[0m
[1m[94m383 |[0m                 Finding(
[1m[94m384 |[0m                     code="ACCEPTANCE_SCOPE",
[1m[94m385 |[0m                     message="Zero-feature completion requires confirmed, justified scope and complete inventory accounting.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m386 |[0m                     next_action="Confirm scope and account for captured inventory inputs.",
[1m[94m387 |[0m                 )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py:386:89
    [1m[94m|[0m
[1m[94m384 |[0m                     code="ACCEPTANCE_SCOPE",
[1m[94m385 |[0m                     message="Zero-feature completion requires confirmed, justified scope and complete inventory accounting.",
[1m[94m386 |[0m                     next_action="Confirm scope and account for captured inventory inputs.",
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m387 |[0m                 )
[1m[94m388 |[0m             )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (96 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\dimension_rules.py:193:89
    [1m[94m|[0m
[1m[94m191 |[0m                         feature,
[1m[94m192 |[0m                         pointer,
[1m[94m193 |[0m                         "Required not-applicable behavior needs rationale and scoped approval.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^[0m
[1m[94m194 |[0m                     )
[1m[94m195 |[0m             elif self.complete and applicability != "applicable":
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_acceptance_rules.py:50:89
   [1m[94m|[0m
[1m[94m49 |[0m def criterion(**changes: object) -> dict[str, object]:
[1m[94m50 |[0m     """Keep a criterion's expectation, readiness and selectors independently authored."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m51 |[0m     return {
[1m[94m52 |[0m         "id": "criterion",
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_acceptance_rules.py:201:89
    [1m[94m|[0m
[1m[94m199 |[0m     snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, state: str
[1m[94m200 |[0m ) -> None:
[1m[94m201 |[0m     """Pending specifications preserve uncertainty without becoming ready obligations."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m202 |[0m     snapshot = acceptance_graph(
[1m[94m203 |[0m         snapshot_profile,
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_dimension_rules.py:156:89
    [1m[94m|[0m
[1m[94m154 |[0m     snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
[1m[94m155 |[0m ) -> None:
[1m[94m156 |[0m     """Unknown offline/mobile observations remain optional when nothing requires them."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m157 |[0m     snapshot = claim_snapshot(
[1m[94m158 |[0m         snapshot_profile,
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_dimension_rules.py:332:89
    [1m[94m|[0m
[1m[94m330 |[0m     snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
[1m[94m331 |[0m ) -> None:
[1m[94m332 |[0m     """An invalid dimension name cannot become an unchecked ProfileRequirements value."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m333 |[0m     record = contract(snapshot_profile, required_dimensions=["unsupported"])
[1m[94m334 |[0m     result = validate_dimensions(
    [1m[94m|[0m

Found 15 errors.
[[36m*[0m] 1 fixable with the `--fix` option.
```
