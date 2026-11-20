# Feature Audit: documentation-estate template and onboarding (#1038)

---

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038`
**Base Branch:** `origin/epic/documentation-estate-tooling-integration`
**Head Branch:** `feature/documentation-estate-template-and-onboarding-1038-r2`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-tooling-integration` (commit `d395d5140f3822eeef453f2055d4ac539656d629`)
- **Head branch/commit:** `feature/documentation-estate-template-and-onboarding-1038-r2` (commit `f668e4254135715cce4901e9b6f6d152cacb8d35`)
- **Merge base:** `d395d5140f3822eeef453f2055d4ac539656d629`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-07 22:04:41 UTC, head `f668e4254`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/evidence/**`
  - Additional evidence: `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` (gate run after the last code commit `4ea6d64d2`); reviewer re-run of `Invoke-Formatter` and `Invoke-ScriptAnalyzer`; direct inspection of the deliverables
- **Feature folder used:** `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** explicit marker `- Work Mode: full-feature` at `issue.md` line 11; acceptance criteria come from `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`.
- **Scope note:** full branch diff against the PR base. Owner decisions of 2026-11-07 apply: decision 1 waives the seeded-shuffle and single-process clauses of SAC-24, decision 2 governs the test-baseline comparison. Plan decision D-1 renamed the stale-page finding code to `DOCS_STALE_PAGE`, and `spec.md` carries that erratum. The CI clause of SAC-24 is CI-dependent and is checked off by the orchestrator at S9.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md` — primary source (25 items)
- `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/user-story.md` — secondary source (11 items)

### From spec.md

1. (SAC-1) `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` and `README.md` exist, and no `epic-status.md` exists in that folder.
2. (SAC-2) The template is accepted by `/epic-plan` as a manifest path, verified as conformance to the `epic-orchestrate` manifest schema (OQ-B): `DocumentationEstateEpicTemplate.Tests.ps1` asserts that the frontmatter parses, has `epic: documentation-estate`, `integration_branch: epic/documentation-estate-integration`, a valid ISO-8601 `created_at`, an `intent` block meeting the schema rules, unique integer `issue_num` values and unique `feature_folder` values, and that every `depends_on` entry resolves to another `features[]` entry.
3. (SAC-3) `DocumentationEstateEpicTemplate.Tests.ps1` proves the template manifest has a cycle-free dependency graph under the epic manifest rules: no self-edge, no cycle, every foundation child at wave 0, every page-family child at wave 1, and the exit-gate child alone in the final wave depending on every page-family child; the computed waves equal the template's `## Planned Waves` list.
4. (SAC-4) Positive controls in `DocumentationEstateEpicTemplate.Tests.ps1` apply in-memory mutations of the template text (a two-node cycle, an unresolved `depends_on` entry, a duplicate `issue_num`, a construct outside the parsed YAML subset) and each mutation makes the check fail.
5. (SAC-5) The template `README.md` states how to place `epic.md` at `docs/features/epics/<slug>/epic.md`, that `epic` and `integration_branch` change together, and the `/epic-plan` invocation, and states that no command copies the template.
6. (SAC-6) The pages `README.md`, `architecture.md`, `consumer-onboarding.md`, `command-reference.md` and `workflow.md` exist under `docs/engineering/documentation-estate/`.
7. (SAC-7) `command-reference.md` has a heading and a fenced example for each of the subcommands `init`, `validate-profile`, `check`, `inventory`, `coverage`, `update-ledger`, `validate`, `generate-reference` and `surface-delta`, and `DocumentationEstateOnboarding.Tests.ps1` asserts that every row name returned by `Get-DocsCommandTable` of the merged entry script has such a heading and example.
8. (SAC-8) `command-reference.md` has a heading and a fenced example for each docs MCP tool by its exact contract name, and `DocumentationEstateOnboarding.Tests.ps1` asserts that every tool name defined in the merged `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` has such a heading and example.
9. (SAC-9) `command-reference.md` documents the exit codes 0 to 3 with `DOCS_CLI_ARGUMENTS`, `DOCS_CLI_RUNTIME` and `DOCS_RUNTIME_UNSUPPORTED`, the envelope keys `command`, `exit_code`, `findings`, `ok`, `result` with the schema path `schemas/docs/v1/docs-command-envelope.schema.json`, and states that `init`, `validate-profile` and `surface-delta` have no MCP tool, that `update_docs_ledger` is the only mutating tool, and that `validate_docs_artifacts` never persists a receipt.
10. (SAC-10) Every option spelling in the command-reference examples matches the merged dispatch row of its subcommand or the merged input table of its MCP tool, as recorded in the Phase 0 evidence.
11. (SAC-11) `consumer-onboarding.md` states the destination-repository prerequisite PowerShell 7.4 (Q8 provisional default) and that a lower version exits 3 with `DOCS_RUNTIME_UNSUPPORTED`, and `DocumentationEstateOnboarding.Tests.ps1` asserts the `7.4` statement is present.
12. (SAC-12) `consumer-onboarding.md` states that the optional python pack, with Python 3.10 or later, enables the native Python analyzer (D3), that without it `inventory` falls back to the scanner and records `analysis_method: scanner`, the `-AnalysisMethod` choices, and that a push-down without a pack selection ships the inert helper; the documentation contract suite asserts the python pack statement is present.
13. (SAC-13) `consumer-onboarding.md` states that linting is optional (D4), names the configuration files `init -Write` writes, and states that `check` is the required page gate; the documentation contract suite asserts the optional-lint statement is present.
14. (SAC-14) `workflow.md` names the roles `docs-architect`, `docs-author`, `docs-reconciler`, `docs-coverage-reviewer`, the skills `documentation-workflow`, `docs-init`, `docs-inventory-surface`, `docs-plan-ia`, `docs-author-page`, `docs-reconcile-behavior`, `docs-review-coverage` and `docs-validate`, and the opt-in gate key `completion_gates.integration_pr_gate.enabled`.
15. (SAC-15) A positive control in `DocumentationEstateOnboarding.Tests.ps1` runs the membership check over an in-memory command reference missing one subcommand and the check fails naming that subcommand.
16. (SAC-16) `EndToEndDocumentationEstate.Tests.ps1` runs `inventory`, `update-ledger`, `generate-reference` and `validate -Mode docs-complete` in process through `Invoke-DocsCommandCli` with one stateful in-memory context, and the baseline at revision R1 exits 0.
17. (SAC-17) After the defects are introduced, `validate -Mode docs-complete -Revision R2` exits 1; its error findings are `DOCS_LEDGER_MISSING_DISPOSITION` with the undocumented command's element identifier in `related_ids` and its declaration in the message, and `DOCS_STALE_PAGE` with the stale page path in `related_paths` and the changed command's declaration in the message; the receipt in `result` has `validation_result` `fail`.
18. (SAC-18) After both defects are fixed through `update-ledger` and `generate-reference -Write`, `validate -Mode docs-complete -Revision R2` exits 0 and the receipt has `validation_result` `pass`.
19. (SAC-19) The end-to-end test records `analysis_method`: it asserts that every inventory snapshot element and every ledger entry produced in the scenario carries `analysis_method` with value `scanner` under `-AnalysisMethod scanner`, and that the `InvokeProcess` fake records no call.
20. (SAC-20) `EndToEndDocumentationEstate.Tests.ps1` asserts that `inventory` without `-Revision` followed by `validate -Mode docs-complete` yields `DOCS_SNAPSHOT_UNPINNED` (D5).
21. (SAC-21) No test creates temporary files: a scan of every new test and support file finds no `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`, and no new test starts a process.
22. (SAC-22) A neutrality scan using the 1020 consumer-identifier digest list reports no match in the template pair or the onboarding pages under `docs/engineering/documentation-estate/`.
23. (SAC-23) No file of this child is Python or TypeScript, and no file under `.claude/`, `extensions/drm-copilot/src/` or `extensions/drm-copilot/resources/claude-customizations/` is created or edited.
24. (SAC-24) The new suites `EndToEndDocumentationEstate.Tests.ps1`, `DocumentationEstateEpicTemplate.Tests.ps1` and `DocumentationEstateOnboarding.Tests.ps1` pass in the CI job `poshqc / PowerShell QC`, three seeded shuffled file-order runs and one fresh single-process run over `tests/scripts` pass with evidence under `evidence/regression-testing/`, and changed-line coverage of `.claude/lib/docs/` does not decrease against the baseline recorded under `evidence/baseline/`.
25. (SAC-25) Every new Pester and support file is below 500 logical lines, and the seven-stage toolchain passes in a single pass.

### From user-story.md

1. (USE-1) The template `epic.md` under `extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/` is accepted by `/epic-plan` as a manifest path, verified by a Pester test of conformance to the `epic-orchestrate` manifest schema.
2. (USE-2) A Pester test proves the template manifest has a cycle-free dependency graph under the epic manifest rules, with foundation children in wave 0, page-family children in wave 1 and the exit-gate child alone in the final wave, and in-memory mutations (cycle, unresolved dependency, duplicate `issue_num`) make it fail.
3. (USE-3) The template `README.md` tells the maintainer where to place `epic.md`, which fields to change together and how to run `/epic-plan`, and states that no command copies the template.
4. (USE-4) The onboarding guide under `docs/engineering/documentation-estate/` documents every subcommand and every docs MCP tool by its exact contract name with an example, and a Pester test derives the expected names from the merged dispatch table and the merged MCP tool definitions.
5. (USE-5) The onboarding guide states the destination-repository prerequisite PowerShell 7.4 (Q8 provisional default).
6. (USE-6) The onboarding guide states that the optional python pack enables the native Python analyzer (D3) and that without it `inventory` uses the scanner.
7. (USE-7) The onboarding guide states that linting is optional (D4) and that `check` is the required page gate.
8. (USE-8) The end-to-end test runs inventory, ledger, generation and `docs-complete` validation; it fails naming the undocumented command and the stale page, and passes after both are fixed.
9. (USE-9) The end-to-end test records `analysis_method` for every inventory element and ledger entry and asserts the value `scanner`.
10. (USE-10) No test creates temporary files or starts a process.
11. (USE-11) No consumer identifier appears in the template or the onboarding pages, and this feature adds no Python or TypeScript file.

---

## Acceptance Criteria Evaluation

Test results below are read from `artifacts/pester/pester-junit.xml` (gate run `Invoke-PoshQCParallelTest`, 19341 tests, 0 failures): `DocumentationEstateEpicTemplate.Tests.ps1` 18/18, `DocumentationEstateOnboarding.Tests.ps1` 13/13, `EndToEndDocumentationEstate.Tests.ps1` 10/10.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| SAC-1 | Template pair exists; no `epic-status.md` | PASS | `ls` of the folder lists `epic.md`, `README.md` only; test `ships epic.md and README.md and no epic-status.md` passed | `ls extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/` | |
| SAC-2 | Manifest schema conformance | PASS | Template suite tests 2-7 passed; `Get-EpicManifestSchemaFinding` returns 0 findings | `Invoke-PoshQCParallelTest -Root .` (gate run, inspected) | OQ-B provisional default: conformance stands in for a live `/epic-plan` run |
| SAC-3 | Cycle-free graph, waves equal `## Planned Waves` | PASS | Wave tests 8-12 passed; frontmatter and `## Planned Waves` (Wave 0: 900001-900005, Wave 1: 900006-900010, Wave 2: 900011) inspected | Gate run, inspected | |
| SAC-4 | Positive controls: cycle, unresolved, duplicate, unsupported | PASS | Tests `EPIC_MANIFEST_CYCLE`, `_UNRESOLVED_DEPENDENCY`, `_DUPLICATE_ISSUE_NUM`, `_UNSUPPORTED` passed; a self-edge control is also present | Gate run, inspected | |
| SAC-5 | Template README statements | PASS | `README.md` steps 2, 3 and 6 and the closing sentence; test `states placement, paired fields, ...` passed | Inspection | |
| SAC-6 | Five pages exist | PASS | `git diff --name-status` lists the five `A` paths; test `has the five onboarding pages` passed | `git diff --name-status d395d5140 HEAD` | |
| SAC-7 | Subcommand headings and examples; membership from `Get-DocsCommandTable` | PASS | `command-reference.md` `## Subcommands` has nine `### \`<name>\`` sections with `powershell` blocks; tests `documents every Get-DocsCommandTable row ...` and `documents the nine named subcommands` passed | Gate run, inspected | |
| SAC-8 | MCP tool headings and examples; membership from tool definitions | PASS | Six `### \`<tool>\`` sections with `json` blocks; test `documents every docs MCP tool defined in mcp-docs-tool-definitions.ts ...` passed | Gate run, inspected | |
| SAC-9 | Exit codes, envelope, MCP boundaries | PASS | `command-reference.md` lines 14-28 and 132-136; tests `documents exit codes, envelope keys ...` and `states the MCP tool boundaries` passed | Inspection | |
| SAC-10 | Option spellings match merged rows and input tables | PASS | `evidence/other/option-spelling.2026-11-07T21-18.md` EXIT_CODE 0; reviewer spot check of `surface-delta -Base`, `inventory -AnalysisMethod`, `update-ledger -ActorKind/-ActorId` against `evidence/baseline/upstream-dispatch.2026-11-07T20-27.md` | Inspection of evidence | |
| SAC-11 | PowerShell 7.4 prerequisite and exit 3 | PASS | `consumer-onboarding.md` lines 8-11; test `states the PowerShell 7.4 prerequisite` passed | Inspection | |
| SAC-12 | Python pack with Python 3.10 or later; fallback; `-AnalysisMethod`; inert helper | PARTIAL | Every clause is stated except the version: the page states "Python 3.11 or later" (lines 15-19), which matches the merged floor `FLOOR = (3, 11)` in `.claude/lib/docs/python/run_docs_python_native.py:18`. The criterion text says 3.10, and the spec has no erratum (lines 149 and 324 also say 3.10). Test `states that the optional python pack enables the native Python analyzer` passed. | `grep -n "FLOOR" .claude/lib/docs/python/run_docs_python_native.py` | Blocking. The delivered page is correct; the spec must carry a Python-floor erratum, as was done for D-1. Unchecked by this review pending that erratum. |
| SAC-13 | Lint optional; `init -Write` files; `check` required gate | PASS | `consumer-onboarding.md` lines 31-38; test `states that linting is optional ...` passed | Inspection | |
| SAC-14 | Workflow roles, skills, gate key | PASS | Test `names the workflow roles, skills and the integration gate key` passed (12 names, gate key, deny prefix) | Gate run | |
| SAC-15 | Positive control naming the missing subcommand | PASS | Test `fails naming the subcommand that an in-memory command reference omits` asserts `@('inventory')` | Gate run | |
| SAC-16 | In-process run through `Invoke-DocsCommandCli`; R1 exits 0 | PASS | Test `passes docs-complete at revision R1 ...` passed; suite dot-sources the entry script and uses one context per test | Gate run, inspected | |
| SAC-17 | R2 exits 1 with both findings and `validation_result` `fail` | PASS | Tests at suite lines 176-217 passed: exact error code set, `related_ids` contains B, `related_paths` contains the page, message contains declarations and `digest-changed`, receipt `fail` | Gate run | Code name per D-1 erratum |
| SAC-18 | Fixed R2 exits 0 with `pass` | PASS | Test `passes docs-complete at revision R2 after the ledger and page are fixed` passed | Gate run | |
| SAC-19 | `analysis_method` `scanner` on every element and entry; no process call | PASS | Three tests at suite lines 228-258 passed; each step asserts a non-empty set | Gate run | |
| SAC-20 | `DOCS_SNAPSHOT_UNPINNED` without `-Revision` | PASS | Test `fails closed with DOCS_SNAPSHOT_UNPINNED ...` passed | Gate run | |
| SAC-21 | No temporary files, no process start | PASS | Reviewer scan of the five new files for the listed strings plus `Start-Process`, `Set-Content`, `Out-File`, `New-Item`: no match; `ProcessCallLog` asserted empty | Grep over `tests/scripts/claude-lib/docs/{DocumentationEstate*,EndToEndDocumentationEstate*,EpicManifest*}` | |
| SAC-22 | Neutrality scan, no match | PASS | Test `finds no consumer-identifier digest ...` passed over 7 files with a non-empty digest list; synthetic positive control passed | Gate run | |
| SAC-23 | No Python or TypeScript; no file under the protected roots | PASS | `git diff --name-status` lists no `.py`, `.ts` or protected-root path | `git diff --name-status d395d5140 HEAD` | |
| SAC-24 | CI job, shuffle and single-process runs, changed-line coverage | UNVERIFIED | Coverage clause met: 72 files under `.claude/lib/docs/` with 0.00 delta (`evidence/qa-gates/coverage-delta.2026-11-07T21-55.md`, reviewer re-parse 95.45% repo-wide). Shuffle and single-process clauses waived by owner decision 1 (`evidence/regression-testing/pester-shuffle.2026-11-07T21-55.md`). CI clause pending: no PR exists (`evidence/qa-gates/ci-pending.2026-11-07T22-00.md`). | CI at S9 | Pending-CI; non-blocking under `### CI-Dependent Criteria`; the orchestrator checks it off at S9 |
| SAC-25 | Files below 500 lines; single-pass toolchain | PASS | Reviewer counts 163-302 logical lines; reviewer re-run format 0 differences, analyzer 0 findings; `evidence/qa-gates/toolchain-loop.2026-11-07T22-00.md` | `@(Get-Content -LiteralPath <file>).Count`; `Invoke-Formatter`; `Invoke-ScriptAnalyzer` | |
| USE-1 | Template accepted by `/epic-plan`, Pester conformance | PASS | As SAC-2 | Gate run | |
| USE-2 | Cycle-free graph, waves, mutations | PASS | As SAC-3 and SAC-4 | Gate run | |
| USE-3 | Template README instructions | PASS | As SAC-5 | Inspection | |
| USE-4 | Every subcommand and tool documented; names derived from merged sources | PASS | As SAC-7 and SAC-8 | Gate run | |
| USE-5 | PowerShell 7.4 prerequisite | PASS | As SAC-11 | Inspection | |
| USE-6 | Python pack enables native analyzer; scanner fallback | PASS | `consumer-onboarding.md` lines 15-25 state both; no version is part of this criterion | Inspection | |
| USE-7 | Lint optional; `check` required gate | PASS | As SAC-13 | Inspection | |
| USE-8 | End-to-end fail and pass | PASS | As SAC-16 to SAC-18 | Gate run | |
| USE-9 | `analysis_method` `scanner` recorded | PASS | As SAC-19 | Gate run | |
| USE-10 | No temporary files or process | PASS | As SAC-21 | Grep | |
| USE-11 | No consumer identifier; no Python or TypeScript file | PASS | As SAC-22 and SAC-23 | Gate run; `git diff` | |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 34 criteria (23 in `spec.md`, 11 in `user-story.md`)
- **PARTIAL:** 1 criterion (SAC-12)
- **UNVERIFIED:** 1 criterion (SAC-24, pending-CI; non-blocking)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. SAC-12: the criterion and two design lines of `spec.md` state a Python 3.10 floor, while the delivered page and the merged code use 3.11. The spec needs an erratum, and the SAC-12 text must be aligned before the criterion is checked off.
2. SAC-24: the CI clause awaits `poshqc / PowerShell QC` on the final head (S9, non-blocking for this review).

**Recommended follow-up verification steps:**

1. After the erratum commit, confirm that `spec.md` `## Corrections to the Research` carries the Python-floor entry, that the SAC-12 text, line 149 and line 324 say 3.11, and that [P2-T3] is aligned. Then re-check SAC-12.
2. At S9, confirm that `ci_gate.conclusion` is `success` for the final head and check off SAC-24.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

Source-file changes made by this review:
- `spec.md` SAC-12: the executor had checked it off. This review evaluates it as PARTIAL and reverted its checkbox from `[x]` to `[ ]`, leaving the criterion text unchanged. The remediation cycle re-checks it after the erratum.
- No other change. Every other PASS criterion was already checked by the executor; SAC-24 stays unchecked (pending-CI).

### AC Status Summary

- Source: `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md`, `docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/user-story.md`
- Total AC items: 36
- Checked off (delivered): 34
- Remaining (unchecked): 2
- Items remaining: SAC-12 (`consumer-onboarding.md` states that the optional python pack, with Python 3.10 or later, enables the native Python analyzer ...) pending the spec erratum; SAC-24 (the new suites ... pass in the CI job `poshqc / PowerShell QC` ...) pending CI at S9.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 25 | 23 | 2 | Checkbox-backed; SAC-12 unchecked by this review, SAC-24 pending-CI |
| `user-story.md` | 11 | 11 | 0 | Checkbox-backed |
