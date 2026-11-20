# p1t8-lint-pass1

Timestamp: 2026-10-18T06-18
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/parsing.py packages/discovery-runtime/src/drm_copilot_discovery/findings.py packages/discovery-runtime/src/drm_copilot_discovery/models.py tests/discovery_runtime/test_parsing.py tests/discovery_runtime/test_parsing_limits.py tests/discovery_runtime/test_findings.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 25 errors.; [[36m*[0m] 14 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T06:18:23.627530+00:00
Duration seconds: 0.760
Phase: P1-T8 strict parsing and immutable diagnostics; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\findings.py:133:89
    [1m[94m|[0m
[1m[94m131 |[0m     @property
[1m[94m132 |[0m     def findings(self) -> tuple[Finding, ...]:
[1m[94m133 |[0m         """Return the ordered bounded snapshot; omitted findings always block success."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m134 |[0m         if not self._truncated and self._upstream_marker is None:
[1m[94m135 |[0m             return tuple(self._items)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parsing.py:38:89
   [1m[94m|[0m
[1m[94m37 |[0m class _ObjectPairs(list[tuple[str, object]]):
[1m[94m38 |[0m     """Preserve JSON members until duplicate detection, including escaped-key aliases."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parsing.py:80:89
   [1m[94m|[0m
[1m[94m78 |[0m                 pointer=pointer,
[1m[94m79 |[0m                 message=message,
[1m[94m80 |[0m                 next_action="Correct this document field and validate the document again.",
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m81 |[0m             )
[1m[94m82 |[0m         )
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parsing.py:170:89
    [1m[94m|[0m
[1m[94m168 |[0m                 return None
[1m[94m169 |[0m             try:
[1m[94m170 |[0m                 # The tag whitelist excludes timestamps, binary, objects and custom tags.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m171 |[0m                 value = cast(object, self.scalar_loader.construct_object(value))
[1m[94m172 |[0m             except (ValueError, TypeError, KeyError, yaml.YAMLError):
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parsing.py:171:30
    [1m[94m|[0m
[1m[94m169 |[0m             try:
[1m[94m170 |[0m                 # The tag whitelist excludes timestamps, binary, objects and custom tags.
[1m[94m171 |[0m                 value = cast(object, self.scalar_loader.construct_object(value))
    [1m[94m|[0m                              [1m[91m^^^^^^[0m
[1m[94m172 |[0m             except (ValueError, TypeError, KeyError, yaml.YAMLError):
[1m[94m173 |[0m                 self.error(
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parsing.py:297:27
    [1m[94m|[0m
[1m[94m295 |[0m                 value.value
[1m[94m296 |[0m                 if isinstance(value, SequenceNode)
[1m[94m297 |[0m                 else cast(list[object], value)
    [1m[94m|[0m                           [1m[91m^^^^^^^^^^^^[0m
[1m[94m298 |[0m             )
[1m[94m299 |[0m             # Each alias occurrence consumes budget, even when its node identity repeats.
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parsing.py:299:89
    [1m[94m|[0m
[1m[94m297 |[0m                 else cast(list[object], value)
[1m[94m298 |[0m             )
[1m[94m299 |[0m             # Each alias occurrence consumes budget, even when its node identity repeats.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m300 |[0m             return tuple(
[1m[94m301 |[0m                 self.visit(child, child_pointer(pointer, index), depth + 1)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parsing.py:350:89
    [1m[94m|[0m
[1m[94m348 |[0m             reader.stop("DOCUMENT_ENCODING", "Document must contain valid UTF-8 text.")
[1m[94m349 |[0m         reader.preflight(text, format=format)
[1m[94m350 |[0m         # Typed object boundaries contain untyped decoder outputs before graph traversal.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m351 |[0m         decoded: object = (
[1m[94m352 |[0m             cast(object, json.loads(text, object_pairs_hook=_ObjectPairs))
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\parsing.py:352:18
    [1m[94m|[0m
[1m[94m350 |[0m         # Typed object boundaries contain untyped decoder outputs before graph traversal.
[1m[94m351 |[0m         decoded: object = (
[1m[94m352 |[0m             cast(object, json.loads(text, object_pairs_hook=_ObjectPairs))
    [1m[94m|[0m                  [1m[91m^^^^^^[0m
[1m[94m353 |[0m             if format == "json"
[1m[94m354 |[0m             else yaml.compose(text, Loader=_DiscoveryLoader)
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_findings.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Verify immutable wire diagnostics and deterministic bounded aggregation."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m from dataclasses import FrozenInstanceError
[1m[94m 6 |[0m [1m[91m|[0m from itertools import permutations
[1m[94m 7 |[0m [1m[91m|[0m from typing import cast
[1m[94m 8 |[0m [1m[91m|[0m
[1m[94m 9 |[0m [1m[91m|[0m import pytest
[1m[94m10 |[0m [1m[91m|[0m
[1m[94m11 |[0m [1m[91m|[0m from drm_copilot_discovery.findings import (
[1m[94m12 |[0m [1m[91m|[0m     Finding,
[1m[94m13 |[0m [1m[91m|[0m     FindingCollector,
[1m[94m14 |[0m [1m[91m|[0m     Severity,
[1m[94m15 |[0m [1m[91m|[0m     child_pointer,
[1m[94m16 |[0m [1m[91m|[0m     ordered_findings,
[1m[94m17 |[0m [1m[91m|[0m )
   [1m[94m|[0m [1m[91m|_^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mDo not call `setattr` with a constant attribute value. It is not any safer than normal property access.[0m
  [1m[94m-->[0m tests\discovery_runtime\test_findings.py:63:9
   [1m[94m|[0m
[1m[94m61 |[0m     assert hash(finding)
[1m[94m62 |[0m     with pytest.raises(FrozenInstanceError):
[1m[94m63 |[0m         setattr(finding, "code", "CHANGED")
   [1m[94m|[0m         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mReplace `setattr` with assignment[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
   [1m[94m-->[0m tests\discovery_runtime\test_findings.py:151:27
    [1m[94m|[0m
[1m[94m149 |[0m             message="Invalid",
[1m[94m150 |[0m             next_action="Correct",
[1m[94m151 |[0m             severity=cast(Severity, "fatal"),
    [1m[94m|[0m                           [1m[91m^^^^^^^^[0m
[1m[94m152 |[0m         )
[1m[94m153 |[0m     with pytest.raises(ValueError, match="nonblank"):
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_findings.py:165:89
    [1m[94m|[0m
[1m[94m163 |[0m @pytest.mark.parametrize("order", tuple(permutations((0, 1, 2))))
[1m[94m164 |[0m def test_findings_are_ordered_independently_of_arrival(order: tuple[int, ...]) -> None:
[1m[94m165 |[0m     """Ordering follows path, pointer, code and references rather than traversal order."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m166 |[0m     values = (
[1m[94m167 |[0m         _finding(path="b.json"),
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_findings.py:192:89
    [1m[94m|[0m
[1m[94m191 |[0m def test_collectors_are_independent_and_snapshots_are_immutable() -> None:
[1m[94m192 |[0m     """Adding a duplicate or updating another collector does not mutate prior results."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m193 |[0m     first = FindingCollector(limit=1)
[1m[94m194 |[0m     second = FindingCollector(limit=1)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_parsing.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Verify strict JSON/YAML normalization without filesystem or decoder fallbacks."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import hashlib
[1m[94m 6 |[0m [1m[91m|[0m import json
[1m[94m 7 |[0m [1m[91m|[0m from dataclasses import FrozenInstanceError
[1m[94m 8 |[0m [1m[91m|[0m from itertools import permutations
[1m[94m 9 |[0m [1m[91m|[0m from typing import Literal, cast
[1m[94m10 |[0m [1m[91m|[0m
[1m[94m11 |[0m [1m[91m|[0m import pytest
[1m[94m12 |[0m [1m[91m|[0m
[1m[94m13 |[0m [1m[91m|[0m from drm_copilot_discovery.models import (
[1m[94m14 |[0m [1m[91m|[0m     JsonObject,
[1m[94m15 |[0m [1m[91m|[0m     JsonValue,
[1m[94m16 |[0m [1m[91m|[0m     ParsedDocument,
[1m[94m17 |[0m [1m[91m|[0m     canonical_json,
[1m[94m18 |[0m [1m[91m|[0m     to_plain_value,
[1m[94m19 |[0m [1m[91m|[0m )
[1m[94m20 |[0m [1m[91m|[0m from drm_copilot_discovery.parsing import parse_document
   [1m[94m|[0m [1m[91m|________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mDo not call `setattr` with a constant attribute value. It is not any safer than normal property access.[0m
  [1m[94m-->[0m tests\discovery_runtime\test_parsing.py:59:9
   [1m[94m|[0m
[1m[94m57 |[0m         result.value["missing"]
[1m[94m58 |[0m     with pytest.raises(FrozenInstanceError):
[1m[94m59 |[0m         setattr(result.value, "members", ())
   [1m[94m|[0m         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mReplace `setattr` with assignment[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parsing.py:192:42
    [1m[94m|[0m
[1m[94m190 |[0m     assert result.findings[0].code == "DOCUMENT_ROOT"
[1m[94m191 |[0m     with pytest.raises(ValueError, match="format"):
[1m[94m192 |[0m         parse_document("{}", format=cast(Literal["json"], "toml"))
    [1m[94m|[0m                                          [1m[91m^^^^^^^^^^^^^^^[0m
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parsing.py:209:32
    [1m[94m|[0m
[1m[94m207 |[0m     """Public value constructors cannot retain mutable or nonfinite data."""
[1m[94m208 |[0m     with pytest.raises(ValueError):
[1m[94m209 |[0m         JsonObject((("a", cast(JsonValue, value)),))
    [1m[94m|[0m                                [1m[91m^^^^^^^^^[0m
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parsing.py:217:27
    [1m[94m|[0m
[1m[94m215 |[0m         JsonObject((("a", 1), ("a", 2)))
[1m[94m216 |[0m     with pytest.raises(ValueError, match="strings"):
[1m[94m217 |[0m         JsonObject(((cast(str, 1), 1),))
    [1m[94m|[0m                           [1m[91m^^^[0m
[1m[94m218 |[0m     with pytest.raises(ValueError, match="Failed documents"):
[1m[94m219 |[0m         ParsedDocument(value=None, findings=(), source_sha256=None, format="json")
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parsing.py:229:25
    [1m[94m|[0m
[1m[94m227 |[0m             findings=(),
[1m[94m228 |[0m             source_sha256=None,
[1m[94m229 |[0m             format=cast(Literal["json"], "bad"),
    [1m[94m|[0m                         [1m[91m^^^^^^^^^^^^^^^[0m
[1m[94m230 |[0m         )
[1m[94m231 |[0m     with pytest.raises(ValueError, match="immutable JSON object"):
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parsing.py:233:24
    [1m[94m|[0m
[1m[94m231 |[0m     with pytest.raises(ValueError, match="immutable JSON object"):
[1m[94m232 |[0m         ParsedDocument(
[1m[94m233 |[0m             value=cast(JsonObject, {}), findings=(), source_sha256=None, format="json"
    [1m[94m|[0m                        [1m[91m^^^^^^^^^^[0m
[1m[94m234 |[0m         )
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_parsing_limits.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Exercise finite byte, depth, record, alias-expansion and diagnostic budgets."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import json
[1m[94m 6 |[0m [1m[91m|[0m from typing import Literal
[1m[94m 7 |[0m [1m[91m|[0m
[1m[94m 8 |[0m [1m[91m|[0m import pytest
[1m[94m 9 |[0m [1m[91m|[0m
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery.models import EXPANDED_NODE_MULTIPLIER, ParseLimits
[1m[94m11 |[0m [1m[91m|[0m from drm_copilot_discovery.parsing import parse_document
   [1m[94m|[0m [1m[91m|________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_parsing_limits.py:36:89
   [1m[94m|[0m
[1m[94m35 |[0m def test_default_sixteen_mib_boundary_is_enforced() -> None:
[1m[94m36 |[0m     """Default policy permits exactly 16 MiB and rejects larger input before decoding."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m37 |[0m     size = 16 * 1024 * 1024
[1m[94m38 |[0m     content = b'{"a":"' + b"x" * (size - 8) + b'"}'
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parsing_limits.py:134:89
    [1m[94m|[0m
[1m[94m133 |[0m def test_scalar_alias_expansion_is_bounded_before_result_freezing() -> None:
[1m[94m134 |[0m     """A noncyclic alias tree is charged per occurrence rather than per node identity."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m135 |[0m     sequence = ", ".join("0" for _ in range(30))
[1m[94m136 |[0m     source = f"a: &a [{sequence}]\nb: *a\nc: 0"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_parsing_limits.py:185:89
    [1m[94m|[0m
[1m[94m184 |[0m def test_error_aggregation_is_bounded_actionable_and_repeatable() -> None:
[1m[94m185 |[0m     """Multiple invalid fields produce stable sorted pointers and a truncation marker."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m186 |[0m     source = '{"c":NaN,"a":NaN,"b":NaN,"d":NaN}'
[1m[94m187 |[0m     limits = ParseLimits(findings=3)
    [1m[94m|[0m

Found 25 errors.
[[36m*[0m] 14 fixable with the `--fix` option.
```
