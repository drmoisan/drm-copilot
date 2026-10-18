# p2t5-lint-pass1

Timestamp: 2026-10-18T09-04
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/decision_rules.py tests/discovery_runtime/test_decision_rules.py tests/discovery_runtime/test_decision_supersession.py
EXIT_CODE: 1
Output Summary:    [1m[94m|[0m; ; Found 18 errors.; [[36m*[0m] 1 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T09:03:59.629359+00:00
Duration seconds: 0.782
Phase: P2-T5 scoped decisions and supersession; focused task verification.

## Captured output

```text
[1m[91minvalid-syntax: [0m[1mCannot use `type` alias statement on Python 3.10 (syntax was added in Python 3.12)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:22:1
   [1m[94m|[0m
[1m[94m20 |[0m     from drm_copilot_discovery.snapshot import DiscoverySnapshot
[1m[94m21 |[0m
[1m[94m22 |[0m type RecordKey = tuple[str, str]
   [1m[94m|[0m [1m[91m^^^^[0m
[1m[94m23 |[0m type FeatureKey = tuple[str, str]
   [1m[94m|[0m

[1m[91minvalid-syntax: [0m[1mCannot use `type` alias statement on Python 3.10 (syntax was added in Python 3.12)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:23:1
   [1m[94m|[0m
[1m[94m22 |[0m type RecordKey = tuple[str, str]
[1m[94m23 |[0m type FeatureKey = tuple[str, str]
   [1m[94m|[0m [1m[91m^^^^[0m
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:137:89
    [1m[94m|[0m
[1m[94m136 |[0m     def scope(self, record: ArtifactRecord) -> DecisionScope | None:
[1m[94m137 |[0m         """Reject scopes that cannot select unique resolved feature/client identities."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m138 |[0m         value = record.document.get("scope")
[1m[94m139 |[0m         names = ("feature_ids", "client_ids", "platforms", "modes", "dimensions")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:173:89
    [1m[94m|[0m
[1m[94m172 |[0m     def approval(self, record: ArtifactRecord) -> bool:
[1m[94m173 |[0m         """Require a configured owner, timestamp and locally verifiable required proof."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m174 |[0m         approval = record.document.get("approval")
[1m[94m175 |[0m         owner = (
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:212:89
    [1m[94m|[0m
[1m[94m210 |[0m                 record,
[1m[94m211 |[0m                 "/approval/evidence_refs",
[1m[94m212 |[0m                 "Approval lacks intact local proof for every owner-required evidence type.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m213 |[0m             )
[1m[94m214 |[0m             return False
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:218:89
    [1m[94m|[0m
[1m[94m217 |[0m     def declarations(self) -> None:
[1m[94m218 |[0m         """Record valid scopes and distinguish proposals from evidenced target policy."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m219 |[0m         # Historical superseded records retain their original approval provenance.
[1m[94m220 |[0m         for key, record in self.records.items():
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:235:89
    [1m[94m|[0m
[1m[94m233 |[0m                         record,
[1m[94m234 |[0m                         "/resulting_acceptance_criteria",
[1m[94m235 |[0m                         "Unapproved proposals cannot establish ready target requirements.",
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m236 |[0m                     )
[1m[94m237 |[0m                 continue
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:249:89
    [1m[94m|[0m
[1m[94m247 |[0m                         record,
[1m[94m248 |[0m                         "",
[1m[94m249 |[0m                         "Approved policy requires decision, rationale and target behavior.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m250 |[0m                     )
[1m[94m251 |[0m                 if approved and complete and scope is not None:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:285:89
    [1m[94m|[0m
[1m[94m283 |[0m                         record,
[1m[94m284 |[0m                         "/supersedes",
[1m[94m285 |[0m                         "Supersession requires the same key and complete predecessor scope.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m286 |[0m                     )
[1m[94m287 |[0m                 elif key in self.valid and destination in self.valid:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:327:89
    [1m[94m|[0m
[1m[94m325 |[0m                     self.records[left],
[1m[94m326 |[0m                     "/scope",
[1m[94m327 |[0m                     "Overlapping approvals share a decision key without valid supersession.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m328 |[0m                 )
[1m[94m329 |[0m                 self.claims.add(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:333:89
    [1m[94m|[0m
[1m[94m331 |[0m                     self.records[right],
[1m[94m332 |[0m                     "/scope",
[1m[94m333 |[0m                     "Overlapping approvals share a decision key without valid supersession.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m334 |[0m                 )
[1m[94m335 |[0m         # A superseded label cannot retire policy without a valid approved successor.
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:369:89
    [1m[94m|[0m
[1m[94m367 |[0m                         record,
[1m[94m368 |[0m                         "/target_relevance",
[1m[94m369 |[0m                         "Retirement requires an approved decision covering the whole feature.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m370 |[0m                     )
[1m[94m371 |[0m                 if record.document.get(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (97 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:419:89
    [1m[94m|[0m
[1m[94m417 |[0m                     record,
[1m[94m418 |[0m                     "/resolution_evidence_refs",
[1m[94m419 |[0m                     "Observed resolution requires local observation proof, not target approval.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^[0m
[1m[94m420 |[0m                 )
[1m[94m421 |[0m             return
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (100 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\decision_rules.py:446:89
    [1m[94m|[0m
[1m[94m444 |[0m                 record,
[1m[94m445 |[0m                 "/decision_ref",
[1m[94m446 |[0m                 "Resolution requires matching owner, target behavior and active covering approval.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^[0m
[1m[94m447 |[0m             )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_decision_rules.py:163:89
    [1m[94m|[0m
[1m[94m161 |[0m     decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog
[1m[94m162 |[0m ) -> None:
[1m[94m163 |[0m     """Captured owner proof permits target policy while source state remains inferred."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m164 |[0m     snapshot = decision_snapshot(
[1m[94m165 |[0m         decision_profile, snapshot_catalog, decision(decision_profile)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_decision_rules.py:188:89
    [1m[94m|[0m
[1m[94m186 |[0m     readiness: str,
[1m[94m187 |[0m ) -> None:
[1m[94m188 |[0m     """Pending proposals are valid drafts; authored ready criteria cannot approve them."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m189 |[0m     record = decision(
[1m[94m190 |[0m         decision_profile,
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_decision_supersession.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Exercise scoped conflicts and supersession without editing historical facts."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m from typing import TYPE_CHECKING
[1m[94m 6 |[0m [1m[91m|[0m
[1m[94m 7 |[0m [1m[91m|[0m import pytest
[1m[94m 8 |[0m [1m[91m|[0m from drm_copilot_discovery.decision_rules import validate_decisions
[1m[94m 9 |[0m [1m[91m|[0m
[1m[94m10 |[0m [1m[91m|[0m from tests.discovery_runtime.test_decision_rules import (
[1m[94m11 |[0m [1m[91m|[0m     decision,
[1m[94m12 |[0m [1m[91m|[0m     decision_profile as decision_profile,
[1m[94m13 |[0m [1m[91m|[0m     decision_scope,
[1m[94m14 |[0m [1m[91m|[0m     decision_snapshot,
[1m[94m15 |[0m [1m[91m|[0m     resolved_question,
[1m[94m16 |[0m [1m[91m|[0m )
[1m[94m17 |[0m [1m[91m|[0m from tests.discovery_runtime.test_evidence_rules import evidence
[1m[94m18 |[0m [1m[91m|[0m from tests.discovery_runtime.test_observation_claims import (
[1m[94m19 |[0m [1m[91m|[0m     claim_snapshot,
[1m[94m20 |[0m [1m[91m|[0m     contract,
[1m[94m21 |[0m [1m[91m|[0m     question,
[1m[94m22 |[0m [1m[91m|[0m )
[1m[94m23 |[0m [1m[91m|[0m from tests.discovery_runtime.test_references import artifact, reference
[1m[94m24 |[0m [1m[91m|[0m from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
[1m[94m25 |[0m [1m[91m|[0m from tests.discovery_runtime.test_snapshot_io import (
[1m[94m26 |[0m [1m[91m|[0m     snapshot_catalog as snapshot_catalog,
[1m[94m27 |[0m [1m[91m|[0m )
   [1m[94m|[0m [1m[91m|_^[0m
[1m[94m28 |[0m
[1m[94m29 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_decision_supersession.py:73:89
   [1m[94m|[0m
[1m[94m71 |[0m     decision_profile: ProfileV2, snapshot_catalog: SchemaCatalog
[1m[94m72 |[0m ) -> None:
[1m[94m73 |[0m     """Structured keys determine conflicts; arbitrary contradictory prose is not parsed."""
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m74 |[0m     records = (
[1m[94m75 |[0m         decision(decision_profile, "first"),
   [1m[94m|[0m

Found 18 errors.
[[36m*[0m] 1 fixable with the `--fix` option.
```
