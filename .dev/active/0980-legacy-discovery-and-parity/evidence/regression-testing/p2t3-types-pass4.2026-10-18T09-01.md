# p2t3-types-pass4

Timestamp: 2026-10-18T09-01
Original capture timestamp: 2026-10-18T08-29
Source aggregate: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t3-gates.2026-10-18T08-27.md
Source block ordinal: 8
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:     Argument type is "list[tuple[Literal['scope'], Literal['repository'], dict[str, str], set[Unknown]] | tuple[Literal['extension-result-manifest'], Literal['repository'], dict[str, str], set[str]] | tuple[Literal['implementation-record'], Literal['target_repository'], dict[str, str], set[str]] | tuple[Literal['source-snapshot-manifest'], Literal['source_repository'], dict[str, str], set[str]]]" (reportUnknownArgumentType); 3 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T08:29:11.759892+00:00
Duration seconds: 7.783
Phase: P2-T3 evidence integrity and declared repository revisions; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Condition will always evaluate to True since the types "int" and "float" have no overlap (reportUnnecessaryComparison)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "argvalues" in function "__call__"
    Argument type is "list[tuple[Literal['none'], set[Unknown]] | tuple[Literal['hash'], set[str]] | tuple[Literal['pin'], set[str]] | tuple[Literal['role'], set[str]]]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "argvalues" in function "__call__"
    Argument type is "list[tuple[Literal['scope'], Literal['repository'], dict[str, str], set[Unknown]] | tuple[Literal['extension-result-manifest'], Literal['repository'], dict[str, str], set[str]] | tuple[Literal['implementation-record'], Literal['target_repository'], dict[str, str], set[str]] | tuple[Literal['source-snapshot-manifest'], Literal['source_repository'], dict[str, str], set[str]]]" (reportUnknownArgumentType)
3 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
