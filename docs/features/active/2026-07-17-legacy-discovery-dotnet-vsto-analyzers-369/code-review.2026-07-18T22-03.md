# Code Review — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-18T22-03
- Reviewer: feature-review agent
- Base: `epic/legacy-discovery-and-parity-integration` @ merge-base `3a4985fa904da7b5925091b393f9551c874ab006`
- Head: `31965bd00a703cc90c173f0f6de7b308b6be9df8`
- Language reviewed: Python (typed review, Pyright strict clean)

## Executive Summary

The change delivers two stack-specific analyzers (`DotnetInventoryAnalyzer`, `VstoOfficeAnalyzer`), a shared pure text-scanning helper module (`source_text.py`), a data-only pattern table (`vsto_patterns.py`), and a shared CLI (`stack_cli.py`) plus two Poetry console scripts. The design cleanly implements the #363 `Analyzer` protocol without reimplementing framework internals, keeps the `parse` I/O stage separate from pure `classify`/`map` detection logic, and threads file text via the `TextParseResult` subtype with fail-fast isinstance narrowing.

Code quality is high and consistent with repository policy: full type annotations (Pyright 0 errors), Black- and Ruff-clean, mandatory class/function docstrings and intent comments on loops and branches, no suppressions, no new dependencies, and every file under the 500-line limit. Detection specifics are confined to `metadata`, ids are deterministic pure functions, and the heuristic claim-scoping is applied uniformly (comment/string stripping for C#, `confidence = "heuristic"` on subscriptions, static symbol-free descriptions). Consumer-neutrality is preserved by capturing the interop application name as data (`INTEROP_USING_RE` group `app`) rather than branching on it.

No blocking or high-severity findings. The observations below are informational or low-severity best-practice notes; none require remediation and none block PR readiness.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | `_build_record` (L435-457) | `dotnet_inventory` wraps the shared `build_evidence_record` in a private `_build_record` helper, whereas `vsto_office.map` calls `build_evidence_record` directly. Minor stylistic inconsistency between the two analyzers. | Optionally align both analyzers on one call style for symmetry. | Consistency aids future maintenance; not a defect. | Source read of both modules. |
| Info | `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | `_detect_subscriptions` (L250-271) | Subscription detections add a `metadata.operator` key that is not among the metadata keys explicitly enumerated in the spec's emission contract (`declaration_form`, `generic`, `customui_schema`, `com_guid`, `interop_target`). | Consider listing `operator` in the spec's emission contract for completeness. | `metadata` is the schema's sanctioned free-form extension point and `operator` is not a `detection_kind`, so this is not a schema or policy violation; documentation completeness only. | Spec Evidence Reference emission contract; source read. |
| Info | `scripts/dev_tools/discovery/analyzer/source_text.py` | `_consume_string` prefix guards (L134-158) | Prefix detection for two-symbol string forms (`@$"`, `$@"`) uses `index + 2 < length`; a literal whose closing quote is the final file character is a documented best-effort edge. | None required; behavior matches the stated regex/stripper limitations. | Spec explicitly scopes raw strings and deeply nested interpolation as best-effort; pathological end-of-file forms are within that documented tolerance. | Spec "Limitations of regex scanning"; source read. |
| Info | `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py`, `vsto_office.py` | `map` hash cache (L410-419 / L421-438) | Per-file content hash is cached across detections in one file, avoiding repeated reads. Good; noted as a validated approach, not a defect. | Keep. | Confirms the I/O-minimization intent stated in the module docstrings. | Source read. |

## Typed-Python Review Notes

- Full type hints on all public and private functions; `from __future__ import annotations` used consistently; `TYPE_CHECKING`-guarded imports for type-only symbols. Pyright reports 0 errors, 0 warnings.
- Frozen `@dataclass(frozen=True, slots=True)` value objects (`Detection`, `TextParseResult`, `DetectionResult`) with covariant-return subtyping over the #363 `ParseResult`/`ClassifyResult`, narrowed with `isinstance` and fail-fast `AnalyzerError`.
- Error handling is specific: only `DomainProfileError` and `AnalyzerError` are caught, and only at the CLI boundary (`stack_cli._run`); no broad handlers. Exit-code mapping (0/1/2) matches the framework contract.
- Determinism: candidate enumeration is POSIX-sorted; ids are pure functions of `(location, line, detection_kind, symbol)` with an 8-hex SHA-256 disambiguator; `captured_at` is injected via `AnalyzerContext` clock. This supports the byte-identical re-run acceptance criterion.

## Test Quality

- Test tree mirrors production at `tests/scripts/dev_tools/discovery/analyzer/`; no colocation.
- 144 targeted tests pass; parametrized positive/negative matrices, stripper state-machine tests, id determinism, narrowing-failure paths, include/exclude routing, unreachable-root error, CLI exit codes, and schema-conformance validation via `jsonschema`.
- Raw fixtures at `tests/fixtures/discovery_dotnet_vsto/*.txt` include false-positive traps (comment/string declaration look-alikes, arithmetic `+=`).
- No temporary files; the in-memory `mem_fs_path` fixture is used for end-to-end runs.

## Recommendation

Go for PR readiness. No remediation required.
