# Feature Audit — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-18T22-03
- Reviewer: feature-review agent
- Work mode: full-feature

## Scope and Baseline

- Base branch (resolved): `epic/legacy-discovery-and-parity-integration`
- Merge-base SHA: `3a4985fa904da7b5925091b393f9551c874ab006`
- Head SHA: `31965bd00a703cc90c173f0f6de7b308b6be9df8`
- AC sources (full-feature): `spec.md` (`## Acceptance Criteria`, 14 items) and `user-story.md` (`## Acceptance Criteria`, 8 items)
- Evaluation basis: source inspection of the five new modules, `pyproject.toml`, the test tree, and `tests/fixtures/discovery_dotnet_vsto/`; independent toolchain runs (Black, Ruff, Pyright, targeted Pytest); coverage parsed from `artifacts/python/lcov.info`.

## Acceptance Criteria Inventory

Spec AC (S1–S14):

- S1 `DotnetInventoryAnalyzer` (`name = "dotnet-inventory"`), namespace (block/file-scoped + `declaration_form`) and type enumeration (normalized `symbol_kind`).
- S2 event/delegate declarations and `+=`/`-=` subscriptions with literal-rejection filter and `confidence = "heuristic"`.
- S3 `VstoOfficeAnalyzer` (`name = "vsto-office"`) Ribbon-XML detection (2006/2009 URIs, `<customUI`, `IRibbonExtensibility`, `GetCustomUI`, `Microsoft.Office.Tools.Ribbon`).
- S4 COM-interop detection (attributes incl. `Guid`→`com_guid`, `Marshal.*`→`symbol`, `GetTypeFromProgID`, interop usings→`interop_target`, project COM references).
- S5 read at `legacy_source.root`, `include`/`exclude` via `fnmatch` over POSIX paths, fail fast with `AnalyzerError` on unreachable root, distinct from `DomainProfileError`.
- S6 parsing-strategy decision recorded/justified in spec (limitations, claim-scoping, research citation).
- S7 shared pure stripper preserving line/column; C# over stripped text; Ribbon/project XML unstripped.
- S8 `parse` returns frozen `TextParseResult`; `classify` isinstance-narrows and raises on plain `ParseResult`; no #363 change; reconciliation recorded as open coordination item.
- S9 Evidence Reference v1 conformance (kind `"file"`, POSIX `location`, id pattern + deterministic, scheme-less relative `$schema`, `schema_version`, specifics only in `metadata`; jsonschema-validated in tests).
- S10 `metadata.detection_kind` drawn only from the twelve-value vocabulary.
- S11 two console scripts targeting `stack_cli:main_dotnet`/`:main_vsto`, argparse surface, exit codes 0/1/2.
- S12 production modules free of consumer identifiers / per-app hardcoding, verified by feature-scoped neutrality test.
- S13 tests satisfy quality-tier policy (coverage, mirrored tree, no temp files, injected clock, raw fixtures with traps, parametrized matrices).
- S14 no file exceeds 500 lines, no new runtime dependency, no coverage exclusion for new modules.

User-story AC (U1–U8):

- U1 `dev.discovery.dotnet` emits namespaces/types/events/delegates/subscriptions anchored to path+line.
- U2 `dev.discovery.vsto` emits Ribbon-XML and COM-interop instances.
- U3 honor `include`/`exclude`; exit 1 malformed/unreachable, exit 2 usage, exit 0 + `--json`.
- U4 emitted artifacts validate against the v1 schema; specifics only in `metadata`.
- U5 event-subscriptions marked heuristic; output/docs describe detections as textual evidence.
- U6 re-run over unchanged tree with pinned clock yields byte-identical artifacts.
- U7 analyzers work unmodified for any consumer repo; no consumer ids / per-app special-casing; neutrality test.
- U8 delivered tests satisfy quality-tier policy with raw fixtures and false-positive traps.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| S1 | PASS | `dotnet_inventory.py` `_ANALYZER_NAME="dotnet-inventory"`; `_NAMESPACE_FILE_SCOPED_RE`/`_NAMESPACE_BLOCK_RE` with `declaration_form`; `_TYPE_RE` + `_SYMBOL_KIND_BY_KEYWORD` (`record class`→`record`, `record struct`→`record_struct`). |
| S2 | PASS | `_EVENT_RE`, `_DELEGATE_RE`, `_SUBSCRIPTION_RE`; `_is_probable_handler` literal-rejection; `extra=(("operator",..),("confidence","heuristic"))`. |
| S3 | PASS | `vsto_office.py` `_ANALYZER_NAME="vsto-office"`; `vsto_patterns.CUSTOMUI_URIS`, `CUSTOMUI_ELEMENT_RE`, `IRIBBON_RE`, `GETCUSTOMUI_RE`, `DESIGNER_RIBBON_LITERAL`. |
| S4 | PASS | `COM_ATTRIBUTE_RES`, `GUID_CAPTURE_RE`→`com_guid`, `MARSHAL_RE`→`symbol`, `PROGID_RE`, `INTEROP_USING_RE`→`interop_target`, `COMREFERENCE_RE`/`EMBEDINTEROP_RE`/`INTEROP_ASSEMBLY_RE`. |
| S5 | PASS | `parse` raises `AnalyzerError` when root not `exists`/`is_dir`; `filter_paths` fnmatch; `stack_cli` catches `DomainProfileError` separately (exit 1). |
| S6 | PASS | `spec.md` "Specification Decision: Parsing Strategy" with limitations, claim-scoping rule, research artifact citation. |
| S7 | PASS | `strip_comments_and_strings` blanks non-code preserving newlines/length; `classify_text` strips first; `classify_xml`/`classify_project` scan unstripped. |
| S8 | PASS | Frozen `TextParseResult(ParseResult)`; `classify` isinstance-narrows and raises `AnalyzerError` on plain `ParseResult`; coordination doc `coordination/text-parse-result-reconciliation.md` present. |
| S9 | PASS | `build_evidence_record` sets `kind="file"`, `location=detection.path`, `build_evidence_id` deterministic pattern; `$schema` computed by reused #363 emitter; jsonschema validation asserted in passing tests. |
| S10 | PASS | detection_kind values used across both analyzers total exactly twelve: namespace, type, event_declaration, delegate, event_subscription, ribbon_xml, ribbon_extensibility, com_attribute, marshal_call, progid_activation, interop_using, com_reference. |
| S11 | PASS | `pyproject.toml` two lines → `stack_cli:main_dotnet`/`:main_vsto`; `_build_parser` positional `profile` default `DEFAULT_PROFILE_FILENAME`, `--output-dir`, `--json`; exit 0/1/2. |
| S12 | PASS | `test_stack_neutrality.py` present and passing; interop app name captured as data, never branched. |
| S13 | PASS | Coverage (lcov) repo-wide 89.22% line / 87.50% branch; new modules >= 94% line; mirrored tree; no temp files; injected clock; raw trap fixtures; parametrized matrices. |
| S14 | PASS | Max file 476 lines; only two console-script lines in `pyproject.toml`; no coverage exclusion added. |
| U1 | PASS | `main_dotnet`→`DotnetInventoryAnalyzer`; detections anchored via `Detection.path`/`line`; end-to-end tests pass. |
| U2 | PASS | `main_vsto`→`VstoOfficeAnalyzer`; ribbon + COM detections; end-to-end tests pass. |
| U3 | PASS | `filter_paths` globs; `_run` returns 1 on `DomainProfileError`/`AnalyzerError`; argparse `SystemExit(2)`; `--json` summary; exit 0 on success. |
| U4 | PASS | Same emitter path as S9; schema validation in tests. |
| U5 | PASS | `confidence="heuristic"` on subscriptions; static symbol-free descriptions use "Heuristic textual detection …"; module docstrings state heuristic-not-compiler scope. |
| U6 | PASS | Pure ids, POSIX-sorted enumeration, injected clock; determinism asserted by passing tests. |
| U7 | PASS | Neutrality test passing; `INTEROP_USING_RE` captures `app` as data. |
| U8 | PASS | 144 targeted tests pass; fixtures include comment/string and arithmetic `+=` traps. |

All 22 acceptance criteria evaluate PASS. No PARTIAL, FAIL, or UNVERIFIED items.

## Summary

The feature satisfies every documented acceptance criterion across `spec.md` and `user-story.md`. Toolchain gates (Black, Ruff, Pyright, Pytest) are green on independent re-run, coverage exceeds thresholds with no regression, evidence locations are canonical, no workflow/benchmark/action paths are touched, and consumer-neutrality is enforced by a passing feature-scoped contract test. Recommendation: PASS / go for PR readiness. No remediation required.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/spec.md`, `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/user-story.md`
- Total AC items: 22 (14 spec + 8 user-story)
- Checked off (delivered): 22
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

All 22 criteria evaluated PASS were checked off (`- [ ]` → `- [x]`) in the `## Acceptance Criteria` sections of `spec.md` and `user-story.md` as part of this review. No criterion text was modified.
