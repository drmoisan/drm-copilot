# Feature Audit: run-actionlint Test Process-State Leak (#1066)

---

**Audit Date:** 2026-11-04
**Feature Folder:** `docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066`
**Base Branch:** `main`
**Head Branch:** `bug/test-path-leak-run-actionlint`
**Work Mode:** `full-bug`
**Audit Type:** First full review

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` at `a7c91431b0cdbedf60a80748e03934fdbc7a676e`)
- **Head branch/commit:** `bug/test-path-leak-run-actionlint` (commit `c97a2ed99d8a6b872320f2ee584a17f1fc6ca1e1`)
- **Merge base:** `a7c91431b0cdbedf60a80748e03934fdbc7a676e`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-04 02:25:08 UTC at the head SHA)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff a7c91431b0cdbedf60a80748e03934fdbc7a676e...HEAD`
  - Feature evidence: `docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/evidence/**`
  - Additional evidence: JaCoCo parses of `artifacts/pester/issue-1066/baseline-scripts-coverage.xml`, `artifacts/pester/issue-1066/final-scripts-coverage.xml`, and `artifacts/pester/parallel/shard-*/powershell-coverage.xml` (this review); a plain `Invoke-Pester` run of the two changed suites in one process (39 passed, 0 failed; PATH unchanged afterwards); PSScriptAnalyzer and Invoke-Formatter over both files (0 findings, 0 changes)
- **Feature folder used:** `docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the only AC source. Checkbox items in other `issue.md` sections are not AC for this mode.
- **Scope note:** full branch diff against the merge base: 2 PowerShell test files and 62 Markdown files; no production file.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/spec.md` - only source (`## Acceptance Criteria`, 11 checkbox items)

### Acceptance criteria

1. The leaking test no longer leaves `$env:PATH` changed; verified by a single-process run.
2. A save/restore of `$env:PATH` covers every Context (Describe level preferred).
3. Every other unrestored process-global mutation identified by research, including `$global:LASTEXITCODE`, is saved and restored, and no other environment variable, location, alias, or global state remains altered.
4. A regression guard fails if the guarded suite changes any process environment variable without restoring it (full comparison, case-insensitive keys), uses no temporary files, and edits no production file.
5. The guard passes on the fixed tree, including in the same process with other dev-tools suites, and leaves the environment unchanged itself.
6. The guard is shown to fail against the pre-fix leak, with fail-before evidence under `evidence/regression-testing/`.
7. The plan records the chosen guard form.
8. Single-process runs in forward, reversed, and at least three seeded shuffled orders show the victims removed and no new failures, by JUnit test-name set difference.
9. The seven-stage toolchain passes in a single pass for the changed PowerShell files, with line coverage not reduced and no production `exclude` entry added.
10. Changed and new test files stay under 700 lines each.
11. CI required checks are green on the PR head (CI-dependent; checked off by the item's orchestrator run at S9).

(Items are abbreviated faithfully from `spec.md`; the source text is unchanged.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | PATH unchanged after the target file | PASS | `evidence/regression-testing/global-state-fail-before.2026-11-04T00-37.md` (fail-before) and `global-state-pass-after.2026-11-04T01-20.md`; this review: PATH byte-identical after a single-process run of both suites | `Invoke-Pester` (scratchpad script comparing `[System.Environment]::GetEnvironmentVariable('PATH')` before and after) | |
| 2 | PATH restore at a scope covering every Context | PASS | Describe-level `BeforeEach`/`AfterEach`, `run-actionlint.Tests.ps1` lines 28-46; Context-level restore removed; `evidence/other/target-rd1.2026-11-04T01-20.md` | Diff review | |
| 3 | LASTEXITCODE and other global state restored | PASS | LASTEXITCODE restored with existence in the Describe `AfterEach`; `AfterAll` removes `Import-ScriptFunction` and `Microsoft.PowerShell.Archive` when added; this review observed both absent after the run; `evidence/regression-testing/global-state-pass-after.2026-11-04T01-20.md`; TestHelpers defines no other global and the file sets no location or alias | `Invoke-Pester`; `grep` for `global:`, `$env:`, `Set-Location`, `Set-Alias` | Closes cycle 1 F1. |
| 4 | Guard: full environment, case-insensitive, no temp files, no production edit | PASS | `OrdinalIgnoreCase` dictionary over `GetEnvironmentVariables()`; nested configuration disables result file and coverage; diff touches no production file | Code reading; `git diff --name-only` | |
| 5 | Guard passes on the fixed tree, in process with other suites, and does not leak | PASS | `evidence/regression-testing/pass-after-guard.2026-11-04T01-20.md`; guard 4/4 in all six order runs and both full-tree runs; control testcase asserts the harness alone leaves the environment unchanged; this review 4/4 | `Invoke-Pester` | |
| 6 | Guard shown to fail against the pre-fix leak | PASS | `fail-before-guard.2026-11-04T00-53.md` (differing key `PATH`), `fail-before-guard-globals.2026-11-04T01-18.md`, `fail-before-lastexitcode.2026-11-04T01-19.md` (each with `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`) | Evidence inspection | Closes cycle 1 F2. |
| 7 | Plan records the guard form | PASS | `evidence/other/guard-decision.2026-11-04T00-56.md` (nested Invoke-Pester, form b); `evidence/other/lastexitcode-guard-decision.2026-11-04T01-19.md` (sentinel/probe form p) | Evidence inspection | No fallback used. |
| 8 | Forward, reversed, three seeded orders; victims removed; no new failures | PASS | `evidence/regression-testing/order-forward.2026-11-04T01-25.md`, `order-reversed.2026-11-04T01-29.md`, `order-seed-1066.2026-11-04T01-33.md`, `order-seed-20261103.2026-11-04T01-36.md`, `order-seed-7.2026-11-04T01-40.md`, `order-leak.2026-11-04T01-44.md`; fail-before `repro-victim-set.2026-11-04T00-49.md` | Evidence inspection (46-file lists: 38 dev-tools suites plus the 8 victim suites, seeds and orders recorded) | The run set is a superset of tests/scripts/dev-tools, because the 8 victims lie outside dev-tools (`evidence/baseline/victim-set.2026-11-03T23-20.md`). |
| 9 | Seven-stage toolchain in one pass; coverage not reduced; no production exclude | PASS | `evidence/qa-gates/qa-loop.2026-11-04T02-19.md`; this review: formatter 0 changes, PSSA 0 findings, 39/39; coverage 91.83% vs 91.51% over the same 265 files; no coverage configuration changed | JaCoCo parse; `git diff --name-only` | |
| 10 | Changed and new test files under 700 lines | PASS | Logical counts in this review: 554 and 210 | `@(Get-Content -LiteralPath <path>).Count` | |
| 11 | CI required checks green on the PR head | PENDING-CI | No PR exists yet (`artifacts/pr_context.summary.txt`) | Orchestrator S9 CI gate | CI-dependent criterion owned by the item's orchestrator run; not a review finding. |

---

## Summary

**Overall Feature Readiness:** PASS (AC11 pending CI by design)

**Criteria summary:**
- **PASS:** 10 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria
- **PENDING-CI:** 1 criterion (AC11)

**Top gaps preventing PASS:**

1. None. AC11 is verified at the S9 CI gate after the PR exists.

**Recommended follow-up verification steps:**

1. At the CI gate, confirm the `windows-latest` PowerShell QC shard jobs pass on the PR head, including the guard's environment comparison on Windows; then check off AC11.
2. Optionally open a separate item for the 8.00% line coverage of `scripts/dev-tools/run-actionlint.ps1` (Info item in the code review).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/spec.md`
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: "CI required checks are green on the PR head." (CI-dependent; checked off by the item's orchestrator run at S9)

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-03-run-actionlint-test-path-env-leak-1066/spec.md` | 11 | 10 | 1 | Checkbox-backed; AC1 to AC10 were already checked; AC11 stays unchecked as pending-CI |

No source-file checkbox change was made in this review: the 10 PASS items were already `- [x]`, and AC11 is owned by the S9 gate.
