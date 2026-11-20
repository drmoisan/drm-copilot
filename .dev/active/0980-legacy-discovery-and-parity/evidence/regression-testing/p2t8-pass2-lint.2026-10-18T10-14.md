# p2t8-pass2-lint

Timestamp: 2026-10-18T10-14
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py tests/discovery_runtime/test_parity_rules.py tests/discovery_runtime/test_parity_clients.py tests/discovery_runtime/parity_test_support.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 21 errors.; [[36m*[0m] 2 fixable with the `--fix` option (2 hidden fixes can be enabled with the `--unsafe-fixes` option).

Working directory: .
Started: 2026-10-18T10:14:46.261520+00:00
Duration seconds: 0.824
Phase: P2-T8 source-to-target parity rules; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mMove application import `drm_copilot_discovery.repository_reader.RepositoryIdentity` into a type-checking block[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:22:53
   [1m[94m|[0m
[1m[94m20 |[0m from drm_copilot_discovery.reference_links import string_value
[1m[94m21 |[0m from drm_copilot_discovery.references import index_references
[1m[94m22 |[0m from drm_copilot_discovery.repository_reader import RepositoryIdentity
   [1m[94m|[0m                                                     [1m[91m^^^^^^^^^^^^^^^^^^[0m
[1m[94m23 |[0m from drm_copilot_discovery.revision_rules import is_full_revision, validate_revisions
[1m[94m24 |[0m from drm_copilot_discovery.runtime_claim_rules import has_text
   [1m[94m|[0m
[1m[96mhelp[0m: [1mMove into type-checking block[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:91:89
   [1m[94m|[0m
[1m[94m89 |[0m                 matrix,
[1m[94m90 |[0m                 field,
[1m[94m91 |[0m                 "Parity requires a uniquely resolved source contract at its exact pin/hash.",
   [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m92 |[0m             )
[1m[94m93 |[0m             return None
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:126:89
    [1m[94m|[0m
[1m[94m124 |[0m             matrix,
[1m[94m125 |[0m             pointer + "/target_repository",
[1m[94m126 |[0m             "Parity target identity must match its configured client and immutable pin.",
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m127 |[0m         )
[1m[94m128 |[0m         return None
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (102 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:184:89
    [1m[94m|[0m
[1m[94m182 |[0m                 matrix,
[1m[94m183 |[0m                 field,
[1m[94m184 |[0m                 "Changed or retired parity needs current approvals within this feature/client scope.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^[0m
[1m[94m185 |[0m             )
[1m[94m186 |[0m         return valid
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:198:89
    [1m[94m|[0m
[1m[94m196 |[0m         required: bool,
[1m[94m197 |[0m     ) -> frozenset[str]:
[1m[94m198 |[0m         """Check every supplied classification and both representations of fixed modes."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m199 |[0m         dimensions = row.get("dimensions")
[1m[94m200 |[0m         values = dict(dimensions.items()) if isinstance(dimensions, JsonObject) else {}
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:258:89
    [1m[94m|[0m
[1m[94m256 |[0m                         matrix,
[1m[94m257 |[0m                         location,
[1m[94m258 |[0m                         "Required non-applicability needs rationale and covering approval.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m259 |[0m                     )
[1m[94m260 |[0m             if verification in ("passed", "failed") and not self.proof.evidence(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:277:89
    [1m[94m|[0m
[1m[94m275 |[0m                     matrix,
[1m[94m276 |[0m                     location,
[1m[94m277 |[0m                     "Dimension results need independent target proof for their context.",
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m278 |[0m                 )
[1m[94m279 |[0m             if (
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:289:89
    [1m[94m|[0m
[1m[94m287 |[0m                     matrix,
[1m[94m288 |[0m                     location,
[1m[94m289 |[0m                     "Required target dimensions must pass or have approved non-applicability.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m290 |[0m                 )
[1m[94m291 |[0m         if required and names - present:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:378:89
    [1m[94m|[0m
[1m[94m376 |[0m                     matrix,
[1m[94m377 |[0m                     pointer,
[1m[94m378 |[0m                     "Every linked implementation must have passing target verification.",
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m379 |[0m                 )
[1m[94m380 |[0m             if row.get("blockers") or row.get("validation_status") != "pass":
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (97 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:385:89
    [1m[94m|[0m
[1m[94m383 |[0m                     matrix,
[1m[94m384 |[0m                     pointer,
[1m[94m385 |[0m                     "Completed parity cannot retain blockers or a nonpassing validation result.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^[0m
[1m[94m386 |[0m                 )
[1m[94m387 |[0m             platforms = set(obligation.requirements.platforms) - waived
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py:399:89
    [1m[94m|[0m
[1m[94m397 |[0m                         matrix,
[1m[94m398 |[0m                         pointer,
[1m[94m399 |[0m                         f"Missing passing target test/capture for {client}/{platform}/{mode}.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m400 |[0m                     )
[1m[94m401 |[0m         if (
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mMove application import `drm_copilot_discovery.repository_reader.RepositoryIdentity` into a type-checking block[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py:10:53
   [1m[94m|[0m
[1m[94m 8 |[0m from drm_copilot_discovery.models import JsonObject
[1m[94m 9 |[0m from drm_copilot_discovery.reference_links import string_value
[1m[94m10 |[0m from drm_copilot_discovery.repository_reader import RepositoryIdentity
   [1m[94m|[0m                                                     [1m[91m^^^^^^^^^^^^^^^^^^[0m
[1m[94m11 |[0m from drm_copilot_discovery.revision_rules import is_full_revision
[1m[94m12 |[0m from drm_copilot_discovery.runtime_claim_rules import has_text
   [1m[94m|[0m
[1m[96mhelp[0m: [1mMove into type-checking block[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py:68:89
   [1m[94m|[0m
[1m[94m67 |[0m     def identity(self, record: ArtifactRecord) -> RepositoryIdentity | None:
[1m[94m68 |[0m         """Bind implementation ownership to its configured target client and full pin."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m69 |[0m         value = record.document.get("target_repository")
[1m[94m70 |[0m         client = next(
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py:234:89
    [1m[94m|[0m
[1m[94m232 |[0m                 record,
[1m[94m233 |[0m                 "",
[1m[94m234 |[0m                 "Implementation claims require matching target bytes, client and test proof.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m235 |[0m             )
[1m[94m236 |[0m         return valid
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py:267:89
    [1m[94m|[0m
[1m[94m265 |[0m                 matrix,
[1m[94m266 |[0m                 field,
[1m[94m267 |[0m                 "Implementation links must bind this feature/client and captured bytes.",
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m268 |[0m             )
[1m[94m269 |[0m             return ()
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_parity_clients.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Exercise client/mode obligations and scoped dispositions in memory."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m from dataclasses import replace
[1m[94m 6 |[0m [1m[91m|[0m from itertools import permutations
[1m[94m 7 |[0m [1m[91m|[0m from typing import TYPE_CHECKING
[1m[94m 8 |[0m [1m[91m|[0m
[1m[94m 9 |[0m [1m[91m|[0m import pytest
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery.claim_rules import ClaimContext
[1m[94m11 |[0m [1m[91m|[0m from drm_copilot_discovery.decision_rules import validate_decisions
[1m[94m12 |[0m [1m[91m|[0m from drm_copilot_discovery.dimension_rules import (
[1m[94m13 |[0m [1m[91m|[0m     DimensionValidation,
[1m[94m14 |[0m [1m[91m|[0m     validate_dimensions,
[1m[94m15 |[0m [1m[91m|[0m )
[1m[94m16 |[0m [1m[91m|[0m from drm_copilot_discovery.evidence_rules import validate_evidence
[1m[94m17 |[0m [1m[91m|[0m from drm_copilot_discovery.models import to_plain_value
[1m[94m18 |[0m [1m[91m|[0m from drm_copilot_discovery.parity_rules import validate_parity
[1m[94m19 |[0m [1m[91m|[0m from drm_copilot_discovery.parity_target_rules import TargetProof
[1m[94m20 |[0m [1m[91m|[0m from drm_copilot_discovery.references import index_references
[1m[94m21 |[0m [1m[91m|[0m from drm_copilot_discovery.repository_reader import RepositoryIdentity
[1m[94m22 |[0m [1m[91m|[0m from drm_copilot_discovery.revision_rules import validate_revisions
[1m[94m23 |[0m [1m[91m|[0m
[1m[94m24 |[0m [1m[91m|[0m from tests.discovery_runtime.test_coverage_scope import profile_with
[1m[94m25 |[0m [1m[91m|[0m from tests.discovery_runtime.test_decision_rules import decision, decision_scope
[1m[94m26 |[0m [1m[91m|[0m from tests.discovery_runtime.test_dimension_rules import client
[1m[94m27 |[0m [1m[91m|[0m from tests.discovery_runtime.test_dimension_rules import (
[1m[94m28 |[0m [1m[91m|[0m     obligation_profile as obligation_profile,
[1m[94m29 |[0m [1m[91m|[0m )
[1m[94m30 |[0m [1m[91m|[0m from tests.discovery_runtime.test_evidence_rules import evidence
[1m[94m31 |[0m [1m[91m|[0m from tests.discovery_runtime.parity_test_support import (
[1m[94m32 |[0m [1m[91m|[0m     classification,
[1m[94m33 |[0m [1m[91m|[0m     codes,
[1m[94m34 |[0m [1m[91m|[0m     implementation,
[1m[94m35 |[0m [1m[91m|[0m     parity_row,
[1m[94m36 |[0m [1m[91m|[0m     parity_snapshot,
[1m[94m37 |[0m [1m[91m|[0m     pinned,
[1m[94m38 |[0m [1m[91m|[0m     source_contract,
[1m[94m39 |[0m [1m[91m|[0m     source_row,
[1m[94m40 |[0m [1m[91m|[0m )
[1m[94m41 |[0m [1m[91m|[0m from tests.discovery_runtime.test_references import immutable, reference
[1m[94m42 |[0m [1m[91m|[0m from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
[1m[94m43 |[0m [1m[91m|[0m from tests.discovery_runtime.test_snapshot_io import (
[1m[94m44 |[0m [1m[91m|[0m     snapshot_catalog as snapshot_catalog,
[1m[94m45 |[0m [1m[91m|[0m )
[1m[94m46 |[0m [1m[91m|[0m from tests.schemas.discovery.v2_schema_test_support import as_object
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
[1m[94m47 |[0m
[1m[94m48 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`tests.discovery_runtime.parity_test_support.pinned` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_parity_clients.py:37:5
   [1m[94m|[0m
[1m[94m35 |[0m     parity_row,
[1m[94m36 |[0m     parity_snapshot,
[1m[94m37 |[0m     pinned,
   [1m[94m|[0m     [1m[91m^^^^^^[0m
[1m[94m38 |[0m     source_contract,
[1m[94m39 |[0m     source_row,
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `tests.discovery_runtime.parity_test_support.pinned`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parity_clients.py:445:89
    [1m[94m|[0m
[1m[94m443 |[0m     obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
[1m[94m444 |[0m ) -> None:
[1m[94m445 |[0m     """Pure validation reuses accepted assessments and does not depend on input order."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m446 |[0m     snapshot = parity_snapshot(obligation_profile, snapshot_catalog)
[1m[94m447 |[0m     index = index_references(snapshot)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parity_clients.py:485:89
    [1m[94m|[0m
[1m[94m483 |[0m     obligation_profile: ProfileV2, snapshot_catalog: SchemaCatalog
[1m[94m484 |[0m ) -> None:
[1m[94m485 |[0m     """Direct helper calls cannot manufacture ownership or execution for other records."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m486 |[0m     snapshot = parity_snapshot(obligation_profile, snapshot_catalog)
[1m[94m487 |[0m     index = index_references(snapshot)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_parity_rules.py:72:89
   [1m[94m|[0m
[1m[94m70 |[0m     value: str,
[1m[94m71 |[0m ) -> None:
[1m[94m72 |[0m     """A plausible full status cannot repair a missing or substituted source contract."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m73 |[0m     source = source_contract(obligation_profile)
[1m[94m74 |[0m     target = implementation(obligation_profile, source)
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mUndefined name `PIN`[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parity_rules.py:112:57
    [1m[94m|[0m
[1m[94m110 |[0m @pytest.mark.parametrize(
[1m[94m111 |[0m     "field,value",
[1m[94m112 |[0m     [("target_repository", {"id": "absent", "revision": PIN}), ("client_id", "absent")],
    [1m[94m|[0m                                                         [1m[91m^^^[0m
[1m[94m113 |[0m )
[1m[94m114 |[0m def test_entry_requires_configured_target_identity(
    [1m[94m|[0m

Found 21 errors.
[[36m*[0m] 2 fixable with the `--fix` option (2 hidden fixes can be enabled with the `--unsafe-fixes` option).
```
