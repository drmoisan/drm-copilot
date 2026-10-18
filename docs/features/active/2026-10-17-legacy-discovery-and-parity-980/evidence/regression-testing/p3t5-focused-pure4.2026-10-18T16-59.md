# p3t5-focused-pure4

Timestamp: 2026-10-18T16-59
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_evidence_linking.py tests/discovery_runtime/test_evidence_payloads.py -k not real_plan and not wrapper and not shared_writer and not actual_captured and not missing_pinned and not payload_integrity and not uri_description and not forwards_native and not injected_plan -x -q
EXIT_CODE: 1
Output Summary: =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[duplicate]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; 1 failed, 17 passed, 12 deselected in 10.60s

Working directory: .
Started: 2026-10-18T16:59:10.739097+00:00
Duration seconds: 11.741
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
.................F
================================== FAILURES ===================================
___________ test_target_must_resolve_to_one_local_record[duplicate] ___________

link_baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ved_path=None, children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
invalid = 'duplicate'

    @pytest.mark.parametrize("invalid", ["missing", "duplicate", "imported"])
    def test_target_must_resolve_to_one_local_record(
        link_baseline: CapturedWorkspace, invalid: str
    ) -> None:
        """Absence, ambiguity and imported identity cannot select a writable destination."""
        request = request_for(link_baseline)
        target = next(
            item
            for item in link_baseline.snapshot.artifacts
            if item.expected_kind == "feature-contract"
        )
        if invalid == "missing":
            request = replace(request, artifact_id="missing")
        else:
            extra = replace(
                target,
                path="docs/duplicate.json",
                origin_path="feature.json" if invalid == "imported" else None,
            )
            artifacts = tuple(
                item
                for item in link_baseline.snapshot.artifacts
                if invalid == "duplicate" or item != target
            )
            link_baseline = replace(
                link_baseline,
>               snapshot=replace(link_baseline.snapshot, artifacts=(*artifacts, extra)),
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            )

tests\discovery_runtime\test_evidence_linking.py:230:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = DiscoverySnapshot(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-p...space-example', revision=None), origin_path=None)), repository_files=(), checkout=None, excluded_paths=(), findings=())

    def __post_init__(self) -> None:
        """Freeze collections and require every parsed artifact to have raw bytes."""
        artifacts = tuple(sorted(self.artifacts, key=lambda item: item.path))
        check_path_collisions(item.path for item in artifacts)
        captured = {item.path for item in self.manifest.files}
        if any(item.path not in captured for item in artifacts):
>           raise ValueError("Every parsed artifact requires captured input bytes")
E           ValueError: Every parsed artifact requires captured input bytes

packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:215: ValueError
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_evidence_linking.py::test_target_must_resolve_to_one_local_record[duplicate]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 17 passed, 12 deselected in 10.60s
```
