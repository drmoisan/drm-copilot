# Feature Audit — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-18T23-16
- Reviewer: feature-review agent
- Work mode: full-feature (marker `- Work Mode: full-feature` in `issue.md`)

## Scope and Baseline

- Base branch (resolved): `epic/legacy-discovery-and-parity-integration`
- Merge-base SHA: `01fb34a8468090db01db471bb339a0dd6391a9d7`
- Head SHA: `62662879766c9280015800634195a9582cb52041`
- Diff range: `01fb34a8468090db01db471bb339a0dd6391a9d7..62662879766c9280015800634195a9582cb52041`
- Acceptance-criteria sources (full-feature): `spec.md` (`## Acceptance Criteria`) and `user-story.md` (`## Acceptance Criteria`).
- The merge integration and bundle push-down cycles add no new acceptance criteria; they are integration and remediation activity. Feature acceptance is evaluated against the two AC source files.

## Acceptance Criteria Inventory

- `spec.md` `## Acceptance Criteria`: 13 checkbox items (all pre-checked `[x]` by the executor).
- `user-story.md` `## Acceptance Criteria`: 7 checkbox items (all pre-checked `[x]` by the executor).
- Total: 20 acceptance criteria across the two source files.

## Acceptance Criteria Evaluation

### spec.md

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| S1 | `DotnetInventoryAnalyzer` implements the #363 protocol; enumerates namespaces (block/file-scoped, `declaration_form`) and types (normalized `symbol_kind`) | PASS | `dotnet_inventory.py`; `test_dotnet_inventory.py` (410 lines); module line coverage 96.8%. |
| S2 | Event/delegate declarations and `+=`/`-=` subscriptions with literal-rejection filter and `confidence = "heuristic"` | PASS | `dotnet_inventory.py`; `test_dotnet_inventory.py`; fixture `csharp_events.cs.txt` with arithmetic trap. |
| S3 | `VstoOfficeAnalyzer` implements the protocol; Ribbon-XML (2006/2009 customUI, `<customUI`, `IRibbonExtensibility`, `GetCustomUI`, `Microsoft.Office.Tools.Ribbon`) | PASS | `vsto_office.py`; `test_vsto_office.py` (474 lines); fixtures `ribbon_customui.xml.txt`, `vsto_ribbon.cs.txt`. |
| S4 | COM-interop detections (`[ComImport]`/`[ComVisible]`/`[Guid]`/`[InterfaceType]`/`[DispId]`, `Marshal.*`, `GetTypeFromProgID`, interop usings captured as data, project `COMReference`/`EmbedInteropTypes`) | PASS | `vsto_office.py`, `vsto_patterns.py`; fixtures `com_interop.cs.txt`, `project_com_reference.xmlproj.txt`. |
| S5 | Read `legacy_source.root`; `include`/`exclude` via `fnmatch`; fail fast with `AnalyzerError` on unreachable root, distinct from `DomainProfileError` | PASS | `stack_cli.py` boundary handling; `test_stack_cli.py` exit-code tests. |
| S6 | Parsing-strategy decision (regex/plain-text, stdlib only) recorded and justified with limitations and claim-scoping, citing research | PASS | spec.md "Specification Decision: Parsing Strategy" and "Limitations" sections. |
| S7 | Shared pure comment/string stripper preserving line/column; C# over stripped text; XML unstripped | PASS | `source_text.py` (100% line coverage); `test_source_text.py` (325 lines). |
| S8 | `parse` returns frozen `TextParseResult`; `classify` isinstance-narrows and raises `AnalyzerError` on plain `ParseResult`; open coordination item recorded | PASS | `dotnet_inventory.py`/`vsto_office.py`; narrowing-failure test; spec Contracts + `coordination/text-parse-result-reconciliation.md`. |
| S9 | Evidence Reference v1 emission: `kind="file"`, consumer-relative `location`, deterministic `id` matching grammar, scheme-less relative `$schema`, `schema_version`, all specifics under `metadata`; validated via jsonschema in tests | PASS | emitter reuse (#363); schema-validation tests; determinism (pinned clock). |
| S10 | `metadata.detection_kind` drawn only from the twelve-value normative vocabulary | PASS | spec emission contract; classify-stage detection kinds; tests. |
| S11 | Console scripts `dev.discovery.dotnet` / `dev.discovery.vsto` as two `[tool.poetry.scripts]` lines with the argparse surface and exit codes 0/1/2 | PASS | `pyproject.toml` diff (both lines present post-merge); `stack_cli.py`; `test_stack_cli.py`. |
| S12 | No consumer identifiers / per-Office-application hardcoding; feature-scoped domain-neutrality contract test | PASS | independent grep (no `taskmaster`/`tmw`/`outlook`); `test_stack_neutrality.py`, `test_domain_neutrality.py`. |
| S13 | Tests satisfy quality-tier policy (line >= 85%, branch >= 75%), mirrored tree, no temp files, injected clock, raw fixtures, parametrized matrices | PASS | Python coverage 89.29% line / 87.55% branch; new-module per-file coverage all above threshold. |

### user-story.md

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| U1 | `dev.discovery.dotnet` emits namespace/type/event/delegate/subscription instances anchored to file+line | PASS | S1–S2 evidence; end-to-end tests over `mem_fs_path`. |
| U2 | `dev.discovery.vsto` emits Ribbon-XML and COM-interop instances | PASS | S3–S4 evidence. |
| U3 | Honor globs; fail fast exit 1 on malformed profile / unreachable root; usage exit 2; success exit 0 with `--json` | PASS | S5 evidence; `test_stack_cli.py`. |
| U4 | Every artifact validates against the v1 schema; `kind="file"`, stable slug id, scheme-less relative `$schema`, specifics only in `metadata` | PASS | S9 evidence. |
| U5 | Subscriptions marked heuristic; output/docs describe textual pattern evidence, not compiler-verified symbols | PASS | S2, S6 evidence; claim-scoping rule. |
| U6 | Re-run over unchanged tree with pinned clock produces byte-identical artifacts | PASS | determinism tests (pinned clock, byte-identical repeat emission). |
| U7 | Analyzers work unmodified for any consumer repo; no consumer identifiers / per-application special-casing; domain-neutrality contract test permitting generic stack literals | PASS | S12 evidence. |

No criterion evaluates to PARTIAL, FAIL, or UNVERIFIED. The one FAIL in this review (absent PowerShell coverage artifact for the bundle hook mirrors) is a policy-evidence gap outside the feature acceptance criteria; it does not map to any AC and is tracked in the policy audit (PA-1) and remediation inputs.

## Summary

All 20 acceptance criteria across `spec.md` and `user-story.md` are satisfied (PASS) against the base branch `epic/legacy-discovery-and-parity-integration`. The analyzer feature is functionally complete, tested above coverage threshold, domain-neutral, and standard-library-only. The merge integration and bundle push-down introduced no feature regressions and added no new acceptance criteria. Feature-acceptance recommendation: the feature meets its acceptance criteria; PR readiness is gated only by the separate PowerShell coverage-evidence remediation item (PA-1).

## Acceptance Criteria Check-off

All 20 AC items in `spec.md` and `user-story.md` were already checked `[x]` by the executor during delivery. This review confirms each remains correctly checked based on PASS verdicts; no check-off state was changed and no criterion text was modified. No phantom criteria were added.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/spec.md`, `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/user-story.md`
- Total AC items: 20 (13 spec + 7 user-story)
- Checked off (delivered): 20
- Remaining (unchecked): 0
- Items remaining: none
