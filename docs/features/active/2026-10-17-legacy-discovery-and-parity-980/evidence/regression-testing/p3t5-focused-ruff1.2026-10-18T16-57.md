# p3t5-focused-ruff1

Timestamp: 2026-10-18T16-57
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py tests/discovery_runtime/test_evidence_linking.py tests/discovery_runtime/test_evidence_payloads.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 12 errors.; [[36m*[0m] 4 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T16:57:02.954787+00:00
Duration seconds: 0.777
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_evidence_linking.py:239:89
    [1m[94m|[0m
[1m[94m237 |[0m     link_baseline: CapturedWorkspace, path: tuple[str | int, ...]
[1m[94m238 |[0m ) -> None:
[1m[94m239 |[0m     """Nested selection changes only one recognized array, including transition phases."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m240 |[0m     target = next(
[1m[94m241 |[0m         item
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_evidence_linking.py:293:89
    [1m[94m|[0m
[1m[94m291 |[0m     link_baseline: CapturedWorkspace, path: tuple[str | int, ...]
[1m[94m292 |[0m ) -> None:
[1m[94m293 |[0m     """Arbitrary arrays, scalar state and missing fields cannot receive evidence links."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m294 |[0m     request = replace(request_for(link_baseline), link_path=path)
[1m[94m295 |[0m     with pytest.raises(MutationError) as caught:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_evidence_linking.py:427:89
    [1m[94m|[0m
[1m[94m425 |[0m     monkeypatch: pytest.MonkeyPatch,
[1m[94m426 |[0m ) -> None:
[1m[94m427 |[0m     """Thin orchestration returns the actual shared dry-run result without side effects."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m428 |[0m     context = cast("InvocationContext", object())
[1m[94m429 |[0m     seen: list[object] = []
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_evidence_linking.py:469:89
    [1m[94m|[0m
[1m[94m467 |[0m     fail: bool,
[1m[94m468 |[0m ) -> None:
[1m[94m469 |[0m     """Actual memory publication retains unrelated bytes and never conceals partial I/O."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m470 |[0m     monkeypatch.setattr(
[1m[94m471 |[0m         evidence_linking, "plan_evidence_link", lambda *args, **kwargs: evidence_plan
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.evidence_linking.EvidenceLink` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_evidence_payloads.py:12:5
   [1m[94m|[0m
[1m[94m10 |[0m from drm_copilot_discovery import evidence_linking
[1m[94m11 |[0m from drm_copilot_discovery.evidence_linking import (
[1m[94m12 |[0m     EvidenceLink,
   [1m[94m|[0m     [1m[91m^^^^^^^^^^^^[0m
[1m[94m13 |[0m     EvidencePayload,
[1m[94m14 |[0m     evidence_changes,
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.evidence_linking.EvidenceLink`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.models.JsonObject` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_evidence_payloads.py:17:42
   [1m[94m|[0m
[1m[94m15 |[0m     plan_evidence_link,
[1m[94m16 |[0m )
[1m[94m17 |[0m from drm_copilot_discovery.models import JsonObject, to_plain_value
   [1m[94m|[0m                                          [1m[91m^^^^^^^^^^[0m
[1m[94m18 |[0m from drm_copilot_discovery.mutation_plan import MutationError, plan_mutation
[1m[94m19 |[0m from drm_copilot_discovery.path_models import PathPolicyError
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.models.JsonObject`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.mutation_plan.plan_mutation` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_evidence_payloads.py:18:64
   [1m[94m|[0m
[1m[94m16 |[0m )
[1m[94m17 |[0m from drm_copilot_discovery.models import JsonObject, to_plain_value
[1m[94m18 |[0m from drm_copilot_discovery.mutation_plan import MutationError, plan_mutation
   [1m[94m|[0m                                                                [1m[91m^^^^^^^^^^^^^[0m
[1m[94m19 |[0m from drm_copilot_discovery.path_models import PathPolicyError
[1m[94m20 |[0m from drm_copilot_discovery.profile_v2 import ProfileV2
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.mutation_plan.plan_mutation`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`tests.discovery_runtime.test_evidence_linking.add_record` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_evidence_payloads.py:29:5
   [1m[94m|[0m
[1m[94m27 |[0m from tests.discovery_runtime.test_evidence_linking import (
[1m[94m28 |[0m     CONTENT,
[1m[94m29 |[0m     add_record,
   [1m[94m|[0m     [1m[91m^^^^^^^^^^[0m
[1m[94m30 |[0m     request_for,
[1m[94m31 |[0m )
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `tests.discovery_runtime.test_evidence_linking.add_record`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_evidence_payloads.py:123:89
    [1m[94m|[0m
[1m[94m121 |[0m     link_baseline: CapturedWorkspace, kind: str
[1m[94m122 |[0m ) -> None:
[1m[94m123 |[0m     """A full pin and matching retained Git bytes pass the real prospective validator."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m124 |[0m     request = replace(
[1m[94m125 |[0m         request_for(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_evidence_payloads.py:154:89
    [1m[94m|[0m
[1m[94m152 |[0m     link_baseline: CapturedWorkspace,
[1m[94m153 |[0m ) -> None:
[1m[94m154 |[0m     """A source record cannot turn newly supplied local bytes into immutable Git proof."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m155 |[0m     request = request_for(link_baseline, kind="source")
[1m[94m156 |[0m     changes = evidence_changes(link_baseline, request)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_evidence_payloads.py:197:89
    [1m[94m|[0m
[1m[94m195 |[0m     link_baseline: CapturedWorkspace,
[1m[94m196 |[0m ) -> None:
[1m[94m197 |[0m     """Even structurally allowed descriptive URLs fail this operation's local-proof gate."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m198 |[0m     request = replace(
[1m[94m199 |[0m         request_for(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_evidence_payloads.py:231:89
    [1m[94m|[0m
[1m[94m229 |[0m         request = replace(request, expected_sha256="0" * 64)
[1m[94m230 |[0m     elif invalid == "collision":
[1m[94m231 |[0m         # A pre-existing opaque file cannot be replaced through create-only registration.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m232 |[0m         link_baseline = replace(
[1m[94m233 |[0m             link_baseline,
    [1m[94m|[0m

Found 12 errors.
[[36m*[0m] 4 fixable with the `--fix` option.
```
