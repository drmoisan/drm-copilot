# p1t9-ruff-pass2

Timestamp: 2026-10-18T06-35
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/catalog.py packages/discovery-runtime/src/drm_copilot_discovery/schema_validation.py scripts/dev_tools/validate_discovery_schema_artifacts.py tests/discovery_runtime/test_catalog.py tests/discovery_runtime/test_schema_validation.py tests/discovery_runtime/test_schema_formats.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 10 errors.; [[36m*[0m] 2 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T06:35:53.420469+00:00
Duration seconds: 0.782
Phase: P1-T9 offline schema catalog and trusted-kind validation; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (96 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\schema_validation.py:309:89
    [1m[94m|[0m
[1m[94m307 |[0m                         pointer=child_pointer("", field),
[1m[94m308 |[0m                         message=message,
[1m[94m309 |[0m                         next_action="Use the caller-selected kind and exact supported version.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^[0m
[1m[94m310 |[0m                     )
[1m[94m311 |[0m                 )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (97 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\schema_validation.py:327:89
    [1m[94m|[0m
[1m[94m325 |[0m                     artifact_path=artifact_path,
[1m[94m326 |[0m                     message=str(error),
[1m[94m327 |[0m                     next_action="Restore the supported runtime and pinned local schema catalog.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^[0m
[1m[94m328 |[0m                 )
[1m[94m329 |[0m             )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_catalog.py:211:89
    [1m[94m|[0m
[1m[94m210 |[0m def test_registry_denies_unknown_runtime_retrieval() -> None:
[1m[94m211 |[0m     """An unexpected reference reaches an explicit denying backend, never the network."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m212 |[0m     registry = load_catalog().registry()
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_catalog.py:238:89
    [1m[94m|[0m
[1m[94m237 |[0m def test_extension_accepts_local_refs_and_rejects_duplicate_namespace() -> None:
[1m[94m238 |[0m     """A pinned local document resolves definitions without replacing any core schema."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m239 |[0m     extension = _extension(
[1m[94m240 |[0m         {"$defs": {"value": {"type": "string"}}, "$ref": "#/$defs/value"}
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_schema_formats.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Exercise required timestamp and HTTP evidence formats without optional extras."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import json
[1m[94m 6 |[0m [1m[91m|[0m
[1m[94m 7 |[0m [1m[91m|[0m import pytest
[1m[94m 8 |[0m [1m[91m|[0m from jsonschema import FormatChecker
[1m[94m 9 |[0m [1m[91m|[0m
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery.schema_validation import (
[1m[94m11 |[0m [1m[91m|[0m     is_http_evidence_uri,
[1m[94m12 |[0m [1m[91m|[0m     is_rfc3339_timestamp,
[1m[94m13 |[0m [1m[91m|[0m     discovery_format_checker,
[1m[94m14 |[0m [1m[91m|[0m     validate_document,
[1m[94m15 |[0m [1m[91m|[0m )
[1m[94m16 |[0m [1m[91m|[0m from tests.schemas.discovery.v2_schema_test_support import load_fixture
   [1m[94m|[0m [1m[91m|_______________________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`typing.cast` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_schema_validation.py:9:35
   [1m[94m|[0m
[1m[94m 7 |[0m import sys
[1m[94m 8 |[0m from pathlib import Path
[1m[94m 9 |[0m from typing import TYPE_CHECKING, cast
   [1m[94m|[0m                                   [1m[91m^^^^[0m
[1m[94m10 |[0m
[1m[94m11 |[0m import pytest
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `typing.cast`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_schema_validation.py:104:89
    [1m[94m|[0m
[1m[94m102 |[0m     key: str, value: object
[1m[94m103 |[0m ) -> None:
[1m[94m104 |[0m     """Mismatched headers fail before any selected-schema validation can weaken checks."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m105 |[0m     document = load_fixture("feature-contract")
[1m[94m106 |[0m     document[key] = value
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_schema_validation.py:139:89
    [1m[94m|[0m
[1m[94m137 |[0m     kind: str,
[1m[94m138 |[0m ) -> None:
[1m[94m139 |[0m     """Special envelopes omit general headers but remain closed and exactly versioned."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m140 |[0m     document = control_fixture(kind)
[1m[94m141 |[0m     document["$schema"] = V2_URN + kind
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_schema_validation.py:226:89
    [1m[94m|[0m
[1m[94m224 |[0m     monkeypatch: MonkeyPatch,
[1m[94m225 |[0m ) -> None:
[1m[94m226 |[0m     """Library defaults silently missing a checker cannot turn into validation success."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m227 |[0m
[1m[94m228 |[0m     def empty_checker() -> FormatChecker:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_schema_validation.py:255:89
    [1m[94m|[0m
[1m[94m253 |[0m     None
[1m[94m254 |[0m ):
[1m[94m255 |[0m     """Embedded collection records and environments share the authoritative extension rule."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m256 |[0m     catalog = _extension_catalog(
[1m[94m257 |[0m         {"type": "object", "properties": {"mode": {"enum": ["approved"]}}}
    [1m[94m|[0m

Found 10 errors.
[[36m*[0m] 2 fixable with the `--fix` option.
```
