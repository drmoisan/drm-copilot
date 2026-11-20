# Feature Audit — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-19T00-43
- Reviewer: feature-review agent
- Work mode: full-feature (marker `- Work Mode: full-feature` in `issue.md`)

## Scope and Baseline

- Base branch (resolved): `epic/legacy-discovery-and-parity-integration`
- Merge-base SHA: `01fb34a8468090db01db471bb339a0dd6391a9d7`
- Head SHA: `937cfeb7fa9ea362454fa2d4834bed6f4416ca21`
- Diff range: `01fb34a8468090db01db471bb339a0dd6391a9d7..937cfeb7fa9ea362454fa2d4834bed6f4416ca21`
- Acceptance-criteria sources (full-feature): `spec.md` (`## Acceptance Criteria`) and `user-story.md` (`## Acceptance Criteria`).
- The merge integration and the four remediation cycles (pyproject conflict resolution, bundle push-down, PowerShell coverage evidence, pack-manifest registration) add no new acceptance criteria; they are integration and remediation activity. Feature acceptance is evaluated against the two AC source files.

## Acceptance Criteria Inventory

- `spec.md` `## Acceptance Criteria`: 14 checkbox items (all pre-checked `[x]` by the executor / prior review cycles).
- `user-story.md` `## Acceptance Criteria`: 8 checkbox items (all pre-checked `[x]`).
- Total: 22 acceptance criteria across the two source files.
- Note: the `spec.md` `## Definition of Done` (8 items) and `## Seeded Test Conditions` (3 items) sections are tracking checklists, not the authoritative acceptance-criteria set; they are excluded from the AC inventory per the acceptance-criteria-tracking skill.

## Acceptance Criteria Evaluation

### spec.md

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| S1 | `DotnetInventoryAnalyzer` implements the #363 protocol; enumerates namespaces (block/file-scoped, `metadata.declaration_form`) and types (normalized `metadata.symbol_kind`), one file+line detection per match | PASS | `dotnet_inventory.py` (`_detect_namespace`, `_detect_type`); `test_dotnet_inventory.py`; module line 96.83% / branch 90.91% (lcov parsed first-hand). |
| S2 | Event/delegate declarations and `+=`/`-=` subscriptions with documented literal-rejection filter and `metadata.confidence = "heuristic"` | PASS | `dotnet_inventory.py` (`_detect_event_or_delegate`, `_is_probable_handler`, `_detect_subscriptions`); fixture `csharp_events.cs.txt` with arithmetic trap. |
| S3 | `VstoOfficeAnalyzer` implements the protocol; Ribbon-XML (2006/2009 customUI URIs, `<customUI` root, `IRibbonExtensibility`, `GetCustomUI`, `Microsoft.Office.Tools.Ribbon`) | PASS | `vsto_office.py` (`_detect_ribbon_xml`, `_detect_ribbon_cs`), `vsto_patterns.py`; fixtures `ribbon_customui.xml.txt`, `vsto_ribbon.cs.txt`. |
| S4 | COM-interop detections (`[ComImport]`/`[ComVisible]`/`[Guid]`→`metadata.com_guid`/`[InterfaceType]`/`[DispId]`, `Marshal.*`→`metadata.symbol`, `Type.GetTypeFromProgID`, interop usings→`metadata.interop_target` as data, project `COMReference`/`EmbedInteropTypes`/interop refs) | PASS | `vsto_office.py` (`_detect_com_attributes`, `_detect_com_usage`, `_detect_project`), `vsto_patterns.py`; fixtures `com_interop.cs.txt`, `project_com_reference.xmlproj.txt`. |
| S5 | Read `profile.legacy_source.root`; `include`/`exclude` via `fnmatch` over consumer-relative POSIX paths; fail fast with `AnalyzerError` on unreachable root, distinct from `DomainProfileError` | PASS | `parse` root check in both analyzers; `filter_paths` reuse; `stack_cli.py` boundary mapping; `test_stack_cli.py`. |
| S6 | Parsing-strategy decision (regex/plain-text, stdlib only, no AST/Roslyn/tree-sitter) recorded and justified with limitations, claim-scoping, citing research | PASS | `spec.md` Specification Decision + Limitations; research artifact under `research/`. |
| S7 | Shared pure comment/string stripper in `source_text.py` blanking non-code spans while preserving line/column; C# patterns over stripped text; Ribbon/project XML unstripped | PASS | `source_text.py` `strip_comments_and_strings` (100% line coverage, parsed first-hand); XML/project routing unstripped; `test_source_text.py`. |
| S8 | `parse` acquires text behind `AnalyzerFileSystem` and returns frozen `TextParseResult`; `classify` isinstance-narrows and raises `AnalyzerError` on plain `ParseResult`; no #363 change; ParseResult reconciliation recorded as open item | PASS | `source_text.py` `TextParseResult`; narrowing in both analyzers; `coordination/text-parse-result-reconciliation.md`. |
| S9 | Every artifact is Evidence Reference v1: `kind="file"`, consumer-relative POSIX `location` (no line appended), `id` matching `^[a-z0-9][a-z0-9._-]*$` and deterministic, scheme-less relative `$schema`, `schema_version` matching `^1\.\d+\.\d+$`, specifics only in `metadata`; validates via `jsonschema` in tests | PASS | reused #363 `serialize_record`; `build_evidence_id`/`build_evidence_record`; schema-validation tests. |
| S10 | `metadata.detection_kind` drawn only from the twelve-value normative vocabulary | PASS | detection kinds in `dotnet_inventory.py` `_DESCRIPTIONS` and `vsto_patterns.DESCRIPTIONS`; tests. |
| S11 | Console scripts `dev.discovery.dotnet` / `dev.discovery.vsto` as two `[tool.poetry.scripts]` lines, argparse surface, exit codes 0/1/2 | PASS | `pyproject.toml` diff (both lines present); `stack_cli.py` `main_dotnet`/`main_vsto`; `test_stack_cli.py`. |
| S12 | Production modules contain no consumer identifiers (`taskmaster`, `tmw`) and no per-Office-application hardcoding; feature-scoped domain-neutrality contract test | PASS | `test_stack_neutrality.py`, `test_domain_neutrality.py`; independent grep at head `937cfeb7` returned zero matches; interop app name captured as data via `INTEROP_USING_RE` group `app`. |
| S13 | Tests satisfy quality-tier policy: pytest, line coverage >= 85%, branch >= 75% | PASS | repo-wide 89.29% line / 80.09% branch (lcov parsed first-hand); all new modules >= 94% line; 2065 tests passed. |
| S14 | No production or test file exceeds 500 lines (raw fixtures exempt); no new runtime dependency | PASS | largest file `source_text.py` 476 (verified at head); stdlib-only implementation; no dependency added to `pyproject.toml`. |

### user-story.md

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| U1 | `dev.discovery.dotnet` emits namespace/type/event/delegate/subscription instances anchored to consumer-relative file+line | PASS | S1–S2 evidence; end-to-end tests over an in-memory fixture tree. |
| U2 | `dev.discovery.vsto` emits Ribbon-XML and COM-interop instances | PASS | S3–S4 evidence. |
| U3 | Honor globs; fail fast exit 1 on malformed profile / unreachable root; usage exit 2; success exit 0 with `--json` | PASS | S5 evidence; `stack_cli.py` exit-code mapping; `test_stack_cli.py`. |
| U4 | Every artifact validates against `schemas/discovery/v1/evidence-reference.schema.json`; `kind="file"`, stable slug id, scheme-less relative `$schema`, specifics only in `metadata` | PASS | S9 evidence. |
| U5 | Event-subscription detections explicitly heuristic; output/docs describe textual pattern evidence, not compiler-verified symbols | PASS | S2, S6 evidence; heuristic-scope docstrings. |
| U6 | Re-run over an unchanged tree with a pinned clock produces byte-identical artifacts | PASS | injected clock (`stack_cli` default, overridable); determinism tests; pure hash-based ids. |
| U7 | Analyzers work unmodified for any consumer .NET/VSTO repo; no consumer identifiers / per-application special-casing; domain-neutrality contract test permitting generic stack literals | PASS | S12 evidence; `test_stack_neutrality.py` permit assertion. |
| U8 | Delivered tests satisfy quality-tier policy (line >= 85%, branch >= 75%, mirrored tree, no temp files, injected clock) and include raw C#/VSTO snippet fixtures with false-positive traps | PASS | S13/S14 evidence; fixtures under `tests/fixtures/discovery_dotnet_vsto/`; mirrored test tree under `tests/scripts/dev_tools/discovery/analyzer/`. |

No criterion evaluates to PARTIAL, FAIL, or UNVERIFIED. The two prior gating items (cycle 3: absent PowerShell coverage artifact; cycle 4: unregistered bundle hooks failing `claude-pack-manifest-completeness`) were policy/CI-evidence gaps outside the feature acceptance criteria; both are resolved and neither affects any AC verdict.

## Summary

All 22 acceptance criteria across `spec.md` (14) and `user-story.md` (8) are satisfied (PASS) against the base branch `epic/legacy-discovery-and-parity-integration`. The analyzer feature is functionally complete, tested above the coverage threshold, domain-neutral, and standard-library-only. The merge integration and the four remediation cycles introduced no feature regressions and added no new acceptance criteria. The cycle-4 change is a two-line `core.json` pack-manifest registration that resolves the `claude-pack-manifest-completeness` CI failure; the full extension jest suite (1886 tests) and full Python toolchain (2065 tests, no regression) are green. Feature-acceptance recommendation: the feature meets its acceptance criteria and is ready for PR from a review standpoint.

## Acceptance Criteria Check-off

All 22 AC items in `spec.md` and `user-story.md` were already checked `[x]` at head `937cfeb7` (verified: 14 checked / 0 unchecked in `spec.md`; 8 checked / 0 unchecked in `user-story.md`). This review confirms each remains correctly checked based on PASS verdicts; no check-off state was changed and no criterion text was modified. No phantom criteria were added.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/spec.md`, `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/user-story.md`
- Total AC items: 22 (14 spec + 8 user-story)
- Checked off (delivered): 22
- Remaining (unchecked): 0
- Items remaining: none
