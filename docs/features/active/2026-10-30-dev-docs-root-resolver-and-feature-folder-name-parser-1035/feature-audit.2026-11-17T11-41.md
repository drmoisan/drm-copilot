# Feature Audit: Development-Docs Root Resolver and Feature-Folder Name Parser (#1035)

---

**Audit Date:** 2026-11-17
**Feature Folder:** `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035`
**Base Branch:** `epic/shared-agent-harness-layer-integration` (merge base `7ebf1347dd8fb86613d40e66461fa5ad64a07cfb`)
**Head:** `e3a7b7de2dd82b9968ecb2f698055006515c4853`
**Work Mode:** full-feature (`issue.md` marker `- Work Mode: full-feature`); AC sources `spec.md` and `user-story.md`.
**Review Type:** S6 full feature review (first review)

---

## Scope and Baseline

- Scope: the full two-dot diff `7ebf1347d..e3a7b7de2` (451 files). Phase 1 of #1016 only; Phases 2 and 3 belong to epic child 7 (spec `## Scope Boundary`).
- Baseline: Phase 0 artifacts `evidence/baseline/python-tests.2026-11-16T00-39.md` (pytest 9200 passed; 96.11% line, 91.86% branch), `typescript-tests.2026-11-16T00-44.md` (Jest 5681 passed; 97.19% line, 94.00% branch), `powershell-tests.2026-11-16T01-04.md` (Pester 27341 tests, 0 failed; 96.04% line), plus static baselines of the same date.
- Final: pytest 9328 passed, Jest 5881 passed, Pester 27678 tests with 0 failures; repo-wide coverage up in every language.
- #1016 is referenced and not closed: no Closes, Fixes or Resolves line for #1016 in added text or commit messages. Decision OD-P4 stands and is not a finding.
- Evaluation method: executor evidence was read, cross-checked against the coverage artifacts parsed by the reviewer, against the diff (including every removed line in the 22 modified existing test files), and against the new module sources. The reviewer ran no tests (owner rule; delegation).

---

## Acceptance Criteria Inventory

### From spec.md

| # | Criterion (abridged) |
|---|---|
| S1 | Routing key in the three configuration copies; parity test passes |
| S2 | TypeScript `root.test.ts` covers R-1 to R-8 |
| S3 | Python resolver tests cover R-1 to R-8 |
| S4 | Pester `DevelopmentDocsRoot.Tests.ps1` covers R-1 to R-8 |
| S5 | Area-path function per runtime: every area under both roots; unknown area error |
| S6 | Known-root prefix function per runtime; PowerShell pattern with both separators |
| S7 | No `vscode` import under `src/lib/development-docs/`, asserted by a test |
| S8 | Python additions in `json_config.py` only; no new file, entry point or hook Python call |
| S9 | Full suites pass with the default key; only folder-naming and status-line expectations changed |
| S10 | Recorded residual search with allowlist under `evidence/` |
| S11 | `.dev` writers for `createActiveFolder`, bug entry and promotion (TypeScript) |
| S12 | Feature-folder record validators accept both roots in three runtimes |
| S13 | Preimplementation gate (Claude and Codex) and task-researcher hook recognize `.dev` paths |
| S14 | `new-potential-entry.ps1` `-DevelopmentDocsRoot`; equal copies; service passes the resolved root |
| S15 | Hook fails closed on a resolver error with a reason naming file and key |
| S16 | Each 2026-11-14 refresh consumer routed with a `.dev` case or listed as Stay |
| S17 | CI docs-only `.dev` prefixes and exclusion; classification test |
| S18 | CI change-scope suites pass |
| S19 | `Get-DocsOnlyDiffTextViolation` treats `.dev/` as docs-only |
| S20 | Brief and workflow README list the `.dev` prefixes; brief contract test passes |
| S21 | `GOVERNED_GLOBS` carries `.dev/**/*.json` in Python and TypeScript with discovery tests |
| S22 | `compileGlob` include-dot behavior documented and tested |
| S23 | Five glob consumers each have a `.dev` discovery test |
| S24 | `isExcludedDirectoryName(".dev")` is `true` |
| S25 | `feature-folder-name.test.ts` covers F-1 to F-6 and N-1 to N-5 |
| S26 | Python and Pester parser tests cover F-1 to F-6 and N-1 to N-5 |
| S27 | Existing parsers delegate to the shared parser; issue-first cases pass |
| S28 | Folder-creation tests for issue 1016, issue 42 and no issue (TypeScript and Python) |
| S29 | Epic folder creation keeps `<epics area>/<slug>` |
| S30 | Status-line tests assert `Promoted -> docs/features/active/<NNNN>-<feature>/` |
| S31 | `write-scopes.ts` exports and rule-table tests |
| S32 | Three-direction checker passes |
| S33 | Agent files and settings carry both literal forms; required-artifact patterns accept both roots |
| S34 | Codex generator `--check` no drift; wrapper contract test passes |
| S35 | `PINNED_FROZEN_SURFACE_HASHES` re-baselined with dated comments; surface tests pass |
| S36 | Module text equal in three locations; module convention test passes |
| S37 | Codex `VIRTUAL_RESOURCE_DIRECTORIES` entry in TypeScript and Python; test passes |
| S38 | Pack manifests list the module; completeness and closure tests pass |
| S39 | Bundle parity for every edited `.claude/` and `.codex/` file; listed contract suites pass |
| S40 | No `.dev/`, default unchanged, no rename, no migration command |
| S41 | Per-file `coverageThreshold` entries; changed-code coverage meets 85% line (all) and 75% branch (Python, TypeScript) |
| S42 | Seven-stage toolchain single pass in three languages; no changed production file above 800 lines |
| DoD-1 to DoD-7 | Definition of Done items |
| STC-1 to STC-3 | Seeded test conditions |

### From user-story.md

| # | Criterion (abridged) |
|---|---|
| U1 | Routing key in three copies; parity test |
| U2 | Resolver tests R-1 to R-8 in three runtimes |
| U3 | Python additions in `json_config.py` only |
| U4 | Full suites pass with the default key; only folder-naming and status-line expectations changed |
| U5 | Recorded residual search with allowlist |
| U6 | Feature-folder record validators accept both roots |
| U7 | CI docs-only `.dev` prefixes and classification test |
| U8 | Refresh consumers routed or listed as Stay |
| U9 | `GOVERNED_GLOBS` `.dev` entry with tests in each runtime |
| U10 | Glob consumers `.dev` tests; include-dot documented; `.dev` excluded directory |
| U11 | Module copies, Codex publication entry, pack manifests and parity suites |
| U12 | Seven-stage toolchain; changed-code coverage thresholds; no file above 800 lines |
| U13 | Absent file or key resolves `docs/features` in three runtimes |
| U14 | Malformed file or out-of-set value: explicit error; hook fails closed naming file and key |
| U15 | Folder-creation tests (1016, 42, no issue) |
| U16 | Parser tests F-1 to F-6 and N-1 to N-5 in three runtimes |
| U17 | No `.dev/`, default unchanged, no rename, no migration command |
| U18 | `write-scopes.ts` exports, no `vscode` import |
| U19 | Three-direction checker passes |
| U20 | Both literal forms on every surface; required-artifact patterns accept both roots |
| U21 | Generator `--check` no drift; frozen-surface hashes re-baselined |

---

## Acceptance Criteria Evaluation

| # | Status | Evidence |
|---|---|---|
| S1, U1 | PASS | `config/orchestration-routing.json` diff adds the key; parity test in the Python gate (`task-check.P1-T1`). |
| S2, S3, S4, U2, U13 | PASS | R-1 to R-8 cases in `root.test.ts`, `test_json_config.py`, `DevelopmentDocsRoot.Tests.ps1`; reviewer read the three resolvers and confirmed the rule order. |
| S5, S6 | PASS | Area-map and prefix tests in three runtimes; PowerShell pattern cases with `/` and `\` (`task-check.P1-T5` to `P1-T9`). |
| S7 | PASS | `no-vscode-import.test.ts`; mutant probe failed 1 of 8 as expected (`typescript-tests.2026-11-17T10-25.md`). |
| S8, U3 | PASS | No added `.py` under `scripts/`, no `pyproject.toml` change in the diff; `enforcement-hooks-no-python-invocation.Tests.ps1` in the Pester gate. |
| S9, U4 | PENDING-CI | Local: pytest, Jest and Pester pass with the default key, and the reviewer's read of every removed line in the 22 modified test files finds only folder-naming and status-line expectation changes plus the A-9 items. The integration lane (`Invoke-ParallelAdmission.Integration.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`) runs in CI only. |
| S10, U5 | PASS | `evidence/other/residual-search.2026-11-17T10-10.md`: every hit on the Stay allowlist. |
| S11 | PASS | `.dev` and fallback cases in the folder-creation, bug-entry and promotion suites. |
| S12, U6 | PASS | `development-docs-matchers.test.ts`, Python and Pester feature-folder record cases. |
| S13 | PASS | `enforce-orchestration-preimplementation-gate.DevRoot.Tests.ps1`, Codex `...-dev-root.Tests.ps1`, task-researcher `.dev` cases. |
| S14 | PASS | `new-potential-entry.TemplateRoot.Tests.ps1`, `CopyParity.Tests.ps1`, `repo-automation-service.new-potential-entry-root.test.ts`. |
| S15, U14 | PASS | Pester fail-closed case with a reason naming `config/orchestration-routing.json` and `development_docs_root`; explicit errors in three runtimes. |
| S16, U8 | PASS | `.dev` cases in each Route consumer's suite (EpicCrossDependency, Invoke-ParallelAdmission, ReviewVerdictEligibility, epic merge-gate review, epic fan-in, feature-review-coverage-target, Get-StageTimingReport); Stay rows on the allowlist. |
| S17, U7 | PASS | `config/ci-docs-only-paths.json` diff; `CiDocsOnlyPathsConfig.Tests.ps1` cases. |
| S18 | PASS | CI change-scope suites in the Pester gate (0 failures). |
| S19 | PASS | `hook-docs-only-diff.Tests.ps1` `.dev/` case (Claude and Codex). |
| S20 | PASS | Brief copies and `.github/workflows/README.md` in the diff; brief contract test in the Python gate. |
| S21, U9 | PASS | `test_json_config.py` `mem_fs_path` case; Jest in-memory case. |
| S22, S23, S24, U10 | PASS | `file-system.test.ts` (`**` and `**/*.md` match `.dev/active/x/spec.md`); `.dev` discovery tests in the five consumers; `isExcludedDirectoryName(".dev")` test. |
| S25, S26, U16 | PASS | F-1 to F-6 and N-1 to N-5 in three runtimes. |
| S27 | PASS | Delegating parsers with issue-first cases in `file-prompt-variables`, `test_resolve_execute_plan_prompt.py`, `test_resolve_file_prompt.py`, `test_plan_progress_report.py`. |
| S28, U15 | PASS | `io.test.ts`, `flow.test.ts`, service-call test, `test_new_active_feature_folder.py` (`0063-json-quality`, `0042-...`, no-issue slug). |
| S29 | PASS | Epic folder case in the folder-creation suites. |
| S30 | PASS | `content.test.ts`, `promotion.test.ts`, `test_potential_to_issue_content.py`, `test_potential_to_issue.py` (`0123-sample`). |
| S31, U18 | PASS | `write-scopes.test.ts`; exports match the spec signatures; no `vscode` import. |
| S32, U19 | PASS | `write-scopes.contract.test.ts` (26 tests); removal probe recorded (`task-check.P7-T5`). |
| S33, U20 | PASS | Agent frontmatter, base Codex agents and `.claude/settings.json` diffs; forward coverage passes. |
| S34, S35, U21 | PASS | Generator `--check` no drift (`leak-scan.2026-11-17T11-22.md`); dated digest comment in `parallel_orchestrator_surface_expectations.py`; surface tests in the Python gate. |
| S36, S37, S38, S39, U11 | PASS | Three equal module copies; Codex virtual-path entries in TypeScript and Python; pack manifests; parity suites in the Python and Pester gates. |
| S40, U17 | PASS | No `.dev` directory; key value `docs/features`; `evidence/other/scope-boundary.2026-11-17T10-13.md`. |
| S41 | PASS | `jest.config.cjs` entries `lines: 85`, `branches: 75` for the three new files; changed-code line coverage 100.00% / 100.00% / 97.49%, changed-code branch coverage 100.00% (Python) and 98.00% (TypeScript). The modified-file threshold finding F1 concerns whole-file coverage of modified files, which this criterion does not state. |
| S42 | PENDING-CI | Local seven-stage loops passed in a single pass per language; stage 7 (integration) runs in CI; no changed production file above 800 lines. |
| U12 | PENDING-CI | As S42; changed-code coverage meets the thresholds. |
| DoD-1 | PASS | Already checked. |
| DoD-2 (all documented environments) | PENDING-CI | Needs CI on the pull request head. |
| DoD-3, DoD-4, DoD-5, DoD-7 | PASS | Already checked; confirmed by the evidence above. |
| DoD-6 (telemetry/logging, if applicable) | PASS | No telemetry surface exists for this change; the logging requirement of spec `## Implementation Strategy` (resolver errors carry the configuration path, the key and the offending value) is met in three runtimes and Pester-asserted. Checked off by this review. |
| STC-1, STC-2 | PASS | Already checked (migration items belong to child 7). |
| STC-3 (CLI/API examples) | NOT EVALUATED | Seeded test condition, not under the `## Acceptance Criteria` heading; Phase 1 adds no CLI and no plan task covers it. Left unchecked; no finding. |

---

## Summary

- 40 of 42 spec acceptance criteria and 19 of 21 user-story acceptance criteria evaluate PASS; the remaining four (S9, S42, U4, U12) are CI-dependent and pending CI on the pull request head, with local evidence consistent with PASS.
- No acceptance criterion evaluates FAIL. The blocking findings F1 and F2 are policy-audit coverage findings outside the criteria text.
- Review verdict: REMEDIATION_REQUIRED (see `remediation-inputs.2026-11-17T11-41.md`).

---

## Acceptance Criteria Check-off

- Newly checked off by this review: `spec.md` Definition of Done "Telemetry/logging added or updated (if applicable)".
- Already checked by the executor and confirmed PASS: all other checked items in both files.
- Left unchecked as pending CI (the item's own orchestrator checks them off at S9): spec "With the default key, the full Python, PowerShell and TypeScript test suites pass...", spec "The seven-stage toolchain passes in a single pass...", spec DoD "Behavior matches acceptance criteria in all documented environments", user-story items 63 and 71.
- Left unchecked, not evaluated: spec seeded test condition "CLI/API examples".

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/spec.md`, `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/user-story.md`
- Total AC items: 63 (spec 42, user story 21)
- Checked off (delivered): 59 (spec 40, user story 19)
- Remaining (unchecked): 4
- Items remaining: spec "With the default key, the full Python, PowerShell and TypeScript test suites pass, and the only changed expectations in existing tests are the folder-naming and status-line expectations for supplied issue numbers." (pending CI); spec "The seven-stage toolchain passes in a single pass for Python, PowerShell and TypeScript, and no changed production file exceeds 800 lines." (pending CI); user story "With the default key, the full Python, PowerShell and TypeScript test suites pass..." (pending CI); user story "The seven-stage toolchain passes in a single pass for Python, PowerShell and TypeScript; coverage of changed code meets 85% line coverage...; no changed production file exceeds 800 lines." (pending CI)
- Outside the AC headings: spec DoD "Behavior matches acceptance criteria in all documented environments" (pending CI) and seeded condition "CLI/API examples" (not evaluated) remain unchecked; DoD "Telemetry/logging added or updated (if applicable)" was checked off by this review.
