# Feature Audit: Docs surface analyzers for Python and configuration (#1022)

**Audit Date:** 2026-11-04
**Feature Folder:** `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/docs-surface-analyzers-python-config-1022-r2`
**Work Mode:** `full-feature`
**Audit Type:** Initial full-branch review

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `06012704f`)
- **Head branch/commit:** `feature/docs-surface-analyzers-python-config-1022-r2` (commit `fc4f2e8d48ac8a436cceade79c1c31871830e7ae`, pushed; no PR yet)
- **Merge base:** `06012704f6e86aa86d41f84b2e191fd40c2a5602` (single merge base from `git merge-base --all`, equal to the integration tip because `fc4f2e8d4` merges that tip)
- **Evidence sources:**
  - Primary: the item diff computed directly with `git diff 06012704f...HEAD` (114 paths) and its `--stat`/`--name-status` variants. `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent in the worktree and the collector is not available to this agent; the direct diff against the single merge base is the authoritative scope source and is recorded as an assumption.
  - Feature evidence: `evidence/**` in the feature folder (baseline, other, qa-gates, regression-testing), including `evidence/qa-gates/self-review.2026-11-04T03-27.md` and `evidence/qa-gates/ac-status.2026-11-04T03-26.md`
  - Additional evidence: reviewer re-runs listed in `policy-audit.2026-11-04T03-37.md` Appendix B
- **Feature folder used:** `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` line 12 reads `- Work Mode: full-feature`.
- **Scope note:** The sibling #1020, #1021 and #1023 changes brought in by the merge commit are outside the item diff; the shared files (`DocsAnalyzerRegistry.psm1`, `Invoke-DocsCommand.ps1`, `core.json`) were checked at their merged state.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` `## Acceptance Criteria` - primary (25 checkbox items, lines 1036-1060, S1 to S25 in order)
- `user-story.md` `## Acceptance Criteria` - secondary (14 checkbox items, lines 88-101, U1 to U14 in order)

The criteria are long; the labels below abbreviate them in source order. The full text is in the source files and was evaluated as written. `spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)` are not acceptance-criteria sections and are not counted. The S3, S4, S6, S9, S13 and U6 texts were revised before execution under orchestrator decision D-1022-exec-1 (lowercase code literals replaced by their uppercase form; criterion count unchanged); the reviewer word-diff confirms the user-story change is limited to that literal and the check-off marks.

### From spec.md

1. S1 Five analyzers emit the expected elements for the nine input families from both corpora.
2. S2 `python-cli`: argparse nesting and positionals, Click naming and suffix removal, Typer names, three console-script tables, attached root, `attached: false`, `cli-command` parent for every option.
3. S3 `python-http`: `include_router` and prefix composition, Flask `url_prefix`, one element per method, `<dynamic>` with `prefix_resolved: false` and `HTTP_PREFIX_DYNAMIC`.
4. S4 `python-public-api` `__all__` forms, naming rule, `_` exclusion, `PUBLIC_API_DYNAMIC_ALL`; `python-architecture` components and edges, no external-dependency component.
5. S5 Every `## Precision Limit` diagnostic row has a test (code, severity, blocking flag, effect, site survival).
6. S6 1,048,577 bytes yields the 1020 over-bound diagnostic; 1,048,576 accepted; `PYTHON_LEXER_UNCLASSIFIED` with no element.
7. S7 Byte-identical snapshot under permuted `ListFile` order, seeded property test.
8. S8 No configuration value exported, seeded marker property test.
9. S9 Non-template env files never passed to `ReadBytes`; `ENV_FILE_NOT_CAPTURED` warning; only the four template names produce keys.
10. S10 Snapshot validates; `inputs[].sha256` and `size` match the fixture bytes.
11. S11 `analysis_method: scanner` on every element; registry rows declare the scanner method.
12. S12 `source_sha256` equals `Get-DocsDeclarationSha256`; digest property test.
13. S13 Independent golden values self-checked against D1; corpus covers every classified form and 1022-owned row except four in-test rows.
14. S14 `inventory` exit codes 0, 1, 2, 3 through `Invoke-DocsCommandCli` with the in-memory context.
15. S15 `-Json` envelope of every exit path validates against `docs-command-envelope.schema.json`.
16. S16 No `WriteText` without `-Write`; one `WriteText` with `create`/`overwrite`; single context-referencing module.
17. S17 Rows only under the 1022 anchors; no other 1020 change except `core.json`; registration checks return no finding.
18. S18 Byte-identical bundle copies; `core.json` lists every new file, `python.json` none; manifest and push-down tests pass.
19. S19 No interpreter invocation or `&` through a variable, member or expression; enforcement suite passes.
20. S20 Seeded property test per pure exported function.
21. S21 Case-distinct Python names stay distinct; ordinal ordering under a different host culture.
22. S22 (CI-dependent) Per-file Pester line coverage >= 85% from the `windows-latest` shard jobs, aggregated by `poshqc / PowerShell QC`, no production file excluded.
23. S23 No temporary file in tests; CR only as escapes or in-code strings; every new production file below 500 lines.
24. S24 Artifact classification table complete; no Python, TypeScript, hook, skill, agent, MCP tool or extension command file in the diff.
25. S25 Phase 0 evidence verifies every `## Dependency on 1020` item before any production file.

### From user-story.md

26. U1 Expected elements for the nine input families.
27. U2 Typer default and explicit names; attached console-script root.
28. U3 `<dynamic>` prefix with a diagnostic; every precision-limit construct produces its named diagnostic.
29. U4 Over-bound or unclassifiable input yields a diagnostic and no elements.
30. U5 Byte-identical rerun proven by a seeded property test.
31. U6 No configuration value; plain `.env` never read or hashed; `ENV_FILE_NOT_CAPTURED`.
32. U7 Snapshot validates and records digest and size of every captured input.
33. U8 Every element records `analysis_method: scanner`.
34. U9 Digest changes only for in-range edits; line-ending invariance.
35. U10 Exit codes 0 to 3 and envelope validation on every exit path.
36. U11 No write without `-Write`; with `-Write` only the snapshot.
37. U12 Registration only under the 1022 anchors; bundle copies; `core.json`.
38. U13 No interpreter invocation; no forbidden file class.
39. U14 (CI-dependent) Per-file Pester line coverage >= 85% on the `windows-latest` shard jobs.

---

## Acceptance Criteria Evaluation

Reviewer command R1 is the Pester run at head `fc4f2e8d4`: `Invoke-Pester` over `tests/scripts/claude-lib/docs` (67 suites), coverage off: 1315 passed, 0 failed, 0 skipped. R2 is the run of the 19 new 1022 suites alone with per-suite counts (policy audit Appendix A). R3 is the gate run over `ClaudeLibModuleConvention.Tests.ps1` (6 of 6) and `enforcement-hooks-no-python-invocation.Tests.ps1` (33 of 33). R4 is the push-down contract pytest (34 of 34). R5 is the reviewer PSScriptAnalyzer and formatter pass over the 39 changed `.ps1`/`.psm1` source files (0 findings, 0 differences). R6 is the reviewer parse of `artifacts/pester/powershell-coverage.xml`. A suite named in a row passed inside R1 unless stated otherwise. Phase evidence named `pN-*` is under `evidence/regression-testing/`.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | S1 | PASS | Analyzer suites `DocsAnalyzerPythonCli`, `DocsAnalyzerPythonHttp`, `DocsAnalyzerPythonApi`, `DocsAnalyzerConfigFiles`, `DocsAnalyzerArchitecture` read both corpora in place | R1; R2 | |
| 2 | S2 | PASS | `DocsPythonCliArgparse`, `DocsPythonCliClick`, `DocsPythonCliTyper`, `DocsAnalyzerPythonCli` suites; `p3-argparse`, `p3-click`, `p3-typer`, `p3-python-cli` | R1 | |
| 3 | S3 | PASS | `DocsPythonHttpSites`, `DocsAnalyzerPythonHttp` suites; `p3-http-sites`, `p3-python-http` | R1 | |
| 4 | S4 | PASS | `DocsAnalyzerPythonApi`, `DocsAnalyzerArchitecture` suites; `p3-python-api`, `p3-architecture` | R1 | |
| 5 | S5 | PASS | Per-row diagnostic tests in the analyzer, lexer and key-scanner suites; `evidence/other/python-corpus-census.2026-11-03T23-49.md`, `evidence/other/config-corpus-census.2026-11-03T23-52.md` | R1 | |
| 6 | S6 | PASS | Size-bound and `PYTHON_LEXER_UNCLASSIFIED` tests in `DocsInventory`, `DocsPythonTokens` suites | R1 | |
| 7 | S7 | PASS | `DocsInventoryProperties.Tests.ps1` seeded permutation property; `isolation-shuffled.2026-11-04T03-10.md` | R1 | |
| 8 | S8 | PASS | Marker-value property in `DocsInventoryProperties.Tests.ps1`; `p4-properties` | R1 | |
| 9 | S9 | PASS | Recording `ReadBytes` wrapper test in `DocsInventory.Tests.ps1`; `p4-inventory-command` | R1 | |
| 10 | S10 | PASS | `DocsInventorySnapshot`, `DocsInventory` suites; `p4-snapshot` | R1 | |
| 11 | S11 | PASS | `DocsAnalyzerRegistry.Tests.ps1` and property suites; reviewer diff shows `AnalysisMethod = 'scanner'` on all five rows | R1; `git diff 06012704f...HEAD -- .claude/lib/docs/DocsAnalyzerRegistry.psm1` | |
| 12 | S12 | PASS | Digest properties against `Get-DocsDeclarationSha256` in `DocsInventoryProperties.Tests.ps1` and analyzer suites | R1 | |
| 13 | S13 | PASS | `evidence/other/golden-vectors.2026-11-03T23-55.md` (D1 self-check); corpus censuses mark the four in-test rows | evidence inspection; R1 | |
| 14 | S14 | PASS | `DocsInventory.Tests.ps1`, `Invoke-DocsCommand.Tests.ps1`; `p4-dispatch-row`, `p4-inventory-command` | R1 | |
| 15 | S15 | PASS | Envelope-validation tests for exits 0 to 3 in `DocsInventory.Tests.ps1` | R1 | |
| 16 | S16 | PASS | Write tests in `DocsInventory.Tests.ps1`; reviewer search finds context member references only in `DocsInventory.psm1` | R1; grep over the eighteen new modules | |
| 17 | S17 | PASS | Reviewer diff: five added lines in `DocsAnalyzerRegistry.psm1`, one in `Invoke-DocsCommand.ps1`, each directly under its 1022 anchor; no other 1020 file in the diff; `Test-DocsAnalyzerRegistration`/`Test-DocsCommandTable` tests pass | R1; `git diff 06012704f...HEAD` | Sibling 1021/1023 rows intact at the merged state. |
| 18 | S18 | PASS | Equal git blob ids for all 20 source/bundle pairs; 18 `core.json` lines, no duplicate path; 0 matches in `python.json`; `Docs.Manifest.Tests.ps1` in R1; R4 | R1; R4; `git rev-parse HEAD:<path>` | |
| 19 | S19 | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33 (R3); reviewer AST scan finds one `&` call, through a `[scriptblock]`-typed parameter declared in the same file | R3; AST scan | |
| 20 | S20 | PASS | `evidence/qa-gates/property-census.2026-11-04T03-24.md` (48 of 48 pure exported functions); reviewer count of `System.Random` uses: 18 of 19 new suites | R1; grep | |
| 21 | S21 | PASS | Case and culture property in `DocsInventoryProperties.Tests.ps1` | R1 | |
| 22 | S22 | UNVERIFIED | Local artifact (R6): every new module at or above 99.22% (`DocsAnalyzerConfigFiles.psm1` 128/129 lowest); no CI run exists for the PR head | R6 | CI-dependent; pending-CI at S9 (`awaiting_ci`, F1). |
| 23 | S23 | PASS | Reviewer token scan of the new suites; no CR byte in new test or fixture files; largest new production file 370 logical lines | grep; `@(Get-Content -LiteralPath <path>).Count` | |
| 24 | S24 | PASS | Plan `## Artifact Classification` rows; reviewer filter of the diff for `.py`, `.ts`, `.tsx`, `.js`, `.cjs`, `.mjs`, `.cs`, `.sh`, `.bats`: no match; no path under `.claude/hooks`, `.claude/skills`, `.claude/agents` or extension source | `git diff --name-only 06012704f...HEAD` | The approved one-Python-analyzer exception was not used. |
| 25 | S25 | PASS | `evidence/other/dependency-1020.2026-11-03T21-45.md` and `dependency-1020.2026-11-03T22-40.md`, committed in `db49ff279`/`8556fd151` before the first production commit `1c4e46dfe` | `git log` order; evidence inspection | |
| 26 | U1 | PASS | As S1 | R1 | |
| 27 | U2 | PASS | As S2 | R1 | |
| 28 | U3 | PASS | As S3, S5 | R1 | |
| 29 | U4 | PASS | As S6 | R1 | |
| 30 | U5 | PASS | As S7 | R1 | |
| 31 | U6 | PASS | As S8, S9 | R1 | |
| 32 | U7 | PASS | As S10 | R1 | |
| 33 | U8 | PASS | As S11 | R1 | |
| 34 | U9 | PASS | As S12 | R1 | |
| 35 | U10 | PASS | As S14, S15 | R1 | |
| 36 | U11 | PASS | As S16 | R1 | |
| 37 | U12 | PASS | As S17, S18 | R1; R4 | |
| 38 | U13 | PASS | As S19, S24 | R3 | |
| 39 | U14 | UNVERIFIED | As S22 | R6 | CI-dependent; pending-CI at S9 (`awaiting_ci`, F1). |

---

## Summary

**Overall Feature Readiness:** READY FOR PR, CI PENDING (no autonomous finding; S22 and U14 wait on CI)

**Criteria summary:**
- **PASS:** 37 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 2 criteria (S22, U14; CI-dependent, pending-CI)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. S22 and U14 wait on the per-file coverage report of `poshqc / PowerShell QC` (`windows-latest` shard jobs) for the PR head (F1, `awaiting_ci`).

**Recommended follow-up verification steps:**

1. Open the PR into `epic/documentation-estate-tooling-integration`; because `ci.yml` triggers only on PRs into `main` or `development`, dispatch it for the PR head if no checks appear.
2. At S9, read the per-file LINE figures for the eighteen new `.claude/lib/docs/` modules from the `poshqc / PowerShell QC` coverage report for the PR head, confirm each is at or above 85%, check off S22 and U14, and re-run the CI gate on the new head.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as PASS are checked off in the source files.
- Criteria evaluated as PARTIAL, FAIL, or UNVERIFIED remain unchecked.

All 37 PASS criteria were already checked (`- [x]`) in the source files by the executor (reviewer count at head `fc4f2e8d4`: 24 checked in the `spec.md` Acceptance Criteria section, 13 in `user-story.md`); the re-evaluation confirms each, so no source-file change was needed. S22 and U14 remain unchecked as CI-dependent; the item's own orchestrator run checks them off at S9.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/spec.md`, `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/user-story.md`
- Total AC items: 39
- Checked off (delivered): 37
- Remaining (unchecked): 2
- Items remaining: spec S22 "Pester line coverage is at least 85% for each new `.claude/lib/docs/` file, read from `artifacts/pester/powershell-coverage.xml` produced by the `poshqc / PowerShell QC shard` jobs on `windows-latest` and aggregated by the required check `poshqc / PowerShell QC`, with no production file excluded from measurement."; user-story U14 "Pester line coverage is at least 85% for each new `.claude/lib/docs/` file, measured by the `poshqc / PowerShell QC shard` jobs on `windows-latest` and enforced by the required check `poshqc / PowerShell QC`."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 25 | 24 | 1 | Checkbox-backed; S22 CI-dependent |
| `user-story.md` | 14 | 13 | 1 | Checkbox-backed; U14 CI-dependent |
