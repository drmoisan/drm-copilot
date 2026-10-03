# Feature Audit: Promotion hook raw-containment false-positive deny (#824)

---

**Audit Date:** 2026-10-03
**Feature Folder:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
**Base Branch:** `origin/main`
**Head Branch:** `bug/promotion-hook-raw-containment-false-positive-deny-824`
**Work Mode:** `full-bug`
**Audit Type:** Reaudit after remediation cycle 2 (pass 3)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`; unchanged after a fresh fetch)
- **Head branch/commit:** `bug/promotion-hook-raw-containment-false-positive-deny-824` (commit `425772de97a84663d781d2bffeac4b8e4787787f`)
- **Merge base:** `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-03 20:45 UTC, head-bound to 425772de)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/**`, including the reviewer record `evidence/qa-gates/review-p3-ac42-kcov.2026-10-03T16-55.md`
  - Reviewer re-runs: 31 Pester suites that target changed files (861 pass) with scoped coverage; check-only format and analyzer (0 drift, 0 findings over 40 files); 6 pytest files (148 pass); bats (15 pass), kcov, shellcheck, shfmt, and `bash -n` in WSL Ubuntu; mirror parity hashes; grep checks; JaCoCo and lcov re-parse; merge-base versus head decision probes on the promotion hook (both runtimes) and the worktree-removal gates (Claude epic, Claude parallel, Codex epic)
- **Feature folder used:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
- **Requirements source:** `spec.md` v0.3 (only source), including `## Scope Extension` (AC-30..AC-41) and `### Remediation cycle 2 additions` (AC-42, AC-43)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the sole AC source. The `issue.md` checklist is not authoritative and was not edited.
- **Scope note:** Full branch diff against `origin/main` (364 files). No PR exists, so CI-dependent AC-27 cannot be evaluated.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md` — only source

### Acceptance criteria

1. AC-1: R2 calls `Test-CommandLineRawInvocation` (whole-token, order-independent), not `Test-CommandLineRawContainment`, on both surfaces.
2. AC-2: `Test-CommandLineRawContainment` is used only by `Test-CommandLineMention`.
3. AC-3: An Unbalanced segment is denied by the promotion hook on both runtimes.
4. AC-4: Raw-invocation unit suites exist with the listed positive and negative cases.
5. AC-5: The exact reproduction is allowed on both runtimes.
6. AC-6: The through/issue/New-Object payload is allowed on both runtimes.
7. AC-7..AC-13: The listed `gh issue` forms and `gh api ... -X POST` are denied on both runtimes.
8. AC-14: Detection of real bypasses that raw containment caught is not weakened; listed promotion and worktree-gate forms denied.
9. AC-15: Negative control in `hook-command-invocation.Tests.ps1` on both surfaces.
10. AC-16: Test rename without asserting order; pre-existing wrapper pins pass unedited.
11. AC-17: Audit record of every R2 caller.
12. AC-18..AC-21: Per-hook false-positive regressions.
13. AC-22: Contract comments corrected.
14. AC-23..AC-25: Runtime parity, mirror parity and manifests, `SharedModuleNames` line.
15. AC-26: PowerShell toolchain with per-file coverage at or above 85% and no uncovered changed line.
16. AC-27: Full toolchain on the PR head in CI (CI-dependent).
17. AC-28: No changed file above 500 lines.
18. AC-29: Public signatures unchanged.
19. AC-30..AC-33: Addendum 1 (worktree-removal gates).
20. AC-34..AC-41: Addendum 2 (#823 follow-ups).
21. AC-42: `.codex/codex-web-setup.sh` safe to source, bats-covered, kcov-measured changed functions.
22. AC-43: Worktree gates deny an R2-classified removal that does not yield exactly one literal operand.

---

## Acceptance Criteria Evaluation

| AC | Status | Evidence | Notes |
|---|---|---|---|
| AC-1 | PASS | `Resolve-CommandLineInvocation` line 214 calls `Test-CommandLineRawInvocation`; no `Test-CommandLineRawContainment` inside it on either surface. `Test-CommandLineRawInvocation` loops `Test-CommandLineRawWordPresent` with `(?<![\w-])word(?![\w-])`. R824-P26..P30 (reverse order) pass. | A text grep returns a second line in the AC-22 comment help (code review CR-6); the call site count is one. |
| AC-2 | PASS | Grep over both hooks roots: definition (line 96) and the `Test-CommandLineMention` call (line 493) per surface. | — |
| AC-3 | PASS | P824-D11 passes on both runtimes (reviewer run). | — |
| AC-4 | PASS | Both `hook-command-raw-invocation.Tests.ps1` suites pass (reviewer run). | — |
| AC-5 | PASS | Reviewer probe: the reproduction is allowed at head and denied at base on both runtimes; P824-A1 passes. | — |
| AC-6 | PASS | P824-A2 passes on both runtimes. | — |
| AC-7 | PASS | P824-D1 passes on both runtimes; reviewer control denied at base and head. | — |
| AC-8 | PASS | P824-D2 passes on both runtimes. | — |
| AC-9 | PASS | P824-D3 passes on both runtimes. | — |
| AC-10 | PASS | P824-D4 passes on both runtimes. | — |
| AC-11 | PASS | P824-D5 passes on both runtimes. | — |
| AC-12 | PASS | P824-D6 passes on both runtimes. | — |
| AC-13 | PASS | P824-D7 passes on both runtimes. | — |
| AC-14 | PARTIAL | Every enumerated form is denied: P824-D8..D10 and P824-D16..D19 on both runtimes, and A824-X1, X2, X3, X4, X7, X8, X10 on all three gates; `gh --repo o/r issue list` is allowed. The reviewer probe nevertheless finds base-deny and head-allow cases on the worktree gates. The checkpoint is the AC-14 fixture's, authorizing only `/repo/worktrees/item-b-102`. A command that removes item-b-102 and also removes `/repo/worktrees/item-a-101` is allowed when the second removal follows `>`, `<`, or a subexpression, is fed by `xargs`, or sits in a later segment. Six such commands (W1-W6 in code review CR-1) were confirmed on both Claude gates, and four on the Codex gate. | The general clause ("Detection ... is not weakened") is not met. Unchecked in `spec.md`. |
| AC-15 | PASS | N824-1 passes on both surfaces (reviewer run). | — |
| AC-16 | PASS | Title renamed without asserting order; wrapper pins pass unedited (`evidence/qa-gates/r2-test-integrity.2026-10-03T16-23.md`); reviewer run green. | — |
| AC-17 | PASS | `evidence/other/containment-path-hook-audit.md` lists every named hook, its call sites, effects, and dispositions, and the cycle-2 addendum; it states the abandon gate does not reach R2 and cites Claim N1. | — |
| AC-18 | PASS | A824-PR1 passes. | — |
| AC-19 | PASS | A824-WT1 and A824-WT2 pass in all three gate suites. | — |
| AC-20 | PASS | A824-VB1 passes on both runtimes. | — |
| AC-21 | PASS | A824-PI1 and A824-MG1 pass on both runtimes. | — |
| AC-22 | PASS | `grep -rl "only forces a checkpoint check"` over both hooks roots and `extensions/drm-copilot/resources` returns no file. | — |
| AC-23 | PASS | One SHA-256 (`95236ec7bfee...`) for the four raw-invocation copies and one (`ff576d15a30e...`) for the four invocation copies. | — |
| AC-24 | PASS | Mirrors byte-identical; the four parity pytest files pass (reviewer, 148 cases with the two #824 files). | — |
| AC-25 | PASS | `SharedModuleNames` line lists the module; file is 497 lines; suite passes (reviewer run). | — |
| AC-26 | PASS | Format 0 drift and analyze 0 findings over 40 files (reviewer). Coverage re-measured by the reviewer: raw-invocation modules 100%, invocation helpers 98.4% and 96.8%, gates 95.5%, 93.58%, and 98.57%; every uncovered line is outside the changed hunks. | — |
| AC-27 | UNVERIFIED | No PR exists and the head is not pushed; CI has not run. | CI-dependent; checked off at S9. |
| AC-28 | PASS | Reviewer `wc -l` over every changed non-Markdown file: maximum 497. | — |
| AC-29 | PASS | Signature-pin tests pass without edits (reviewer run). | — |
| AC-30 | PASS | Reviewer probe and A824-WT3: the Addendum 1 reproduction is allowed by both Claude gates and the Codex gate. | — |
| AC-31 | PASS | A824-WT4-1..5 (deny without record) and A824-WT5-1..5 (allow with record) pass in all three gate suites. | The listed forms are gated as required; the multi-removal gap is graded under AC-14 and AC-43. |
| AC-32 | PASS | A824-WT3 asserts containment true alongside an allow decision, so restoring the containment deny path fails it. | — |
| AC-33 | PASS | PowerShell format, analyze, and Pester pass (reviewer and executor). | — |
| AC-34 | PASS | F824-1..F824-3 pass; `feature-review-coverage-thresholds.ps1` 21/21 lines. | Unchanged in cycle 2. |
| AC-35 | PASS | `test_push_down_issue_824_follow_ups.py` passes (reviewer). | Unchanged in cycle 2. |
| AC-36 | PASS | Same suite plus parity tests pass; the setup script names `<solution>.sln` only. | — |
| AC-37 | PASS | Step 8 wording pinned and passing. | Unchanged in cycle 2. |
| AC-38 | PASS | Pinned and passing. | Unchanged in cycle 2. |
| AC-39 | PASS | `test_retired_threshold_scan_reads_coverage_context_only` passes. | Unchanged in cycle 2. |
| AC-40 | PASS | Follow-ups file headings FU-823-1..FU-823-5 present; FU-823-1, -2, -3, -5 resolved by #824 and FU-823-4 open (unchanged since pass 2). | — |
| AC-41 | PASS | Executor loop clean for Python, TypeScript/Jest, and PowerShell (`evidence/qa-gates/r2-qc-loop-complete.2026-10-03T16-40.md`); reviewer re-ran the PowerShell and Python subsets. | — |
| AC-42 | PASS | Last line is the `BASH_SOURCE` guard (C824-1). The bundle copy is byte-identical (`fd4824228f81...`). bats C824-1..C824-15 pass and cover: no solution (C824-2, -3, -7), one solution (C824-4, -5), several in `LC_ALL=C` order (C824-6), restore skipped with its warning (C824-8), and verification failing with its message (C824-12). No temporary file is created; the committed fixture is `tests/fixtures/codex_web_setup/populated-packages`. kcov 43 scoped to the script: all 6 functions that contain changed lines at 100%, and `CHANGED-LINES=47 INSTRUMENTED=20 UNCOVERED-CHANGED=NONE`. `bash -n` passes. 405 lines. | Recorded under `evidence/qa-gates/review-p3-ac42-kcov.2026-10-03T16-55.md`. The CI run of the same steps remains part of AC-27. A non-empty `list_root_solution_files` listing is not asserted (code review CR-3, Minor). |
| AC-43 | PARTIAL | A824-WT6, A824-WT10, A824-WT11-1, and A824-WT11-2 deny on all three gates; A824-WT3 (AC-30) stays allowed; the AC-31 rows are unchanged. However, a classified wrapped removal whose operand the reader cannot read is allowed when the same command also names an authorized literal operand (W1-W4), and a second classified wrapped segment is never read (W5). | The cycle 2 design decision lists "an operand the reader cannot read" among the outcomes that must be denied. Unchecked in `spec.md`. |

---

## Summary

- **Overall acceptance status:** Not accepted. 40 PASS, 2 PARTIAL (AC-14, AC-43), 1 pending CI (AC-27), 0 FAIL.
- **Blocking gaps:**
  - CR-1 (autonomous): the worktree-removal gates authorize a whole command on a single literal operand. A second removal is not checked when its operand cannot be read or when it sits in a later segment. Six commands are denied at the merge base and allowed at head on both Claude gates, and four of them on the Codex gate.
  - CR-2 (awaiting CI): `.github/workflows/_shell-coverage.yml` is modified and no run exists against the head.
- **Non-blocking gaps:** `list_root_solution_files` positive listing and top-level wiring unasserted (CR-3). The same first-segment-only behavior on the structural path is pre-existing. The carried advisories remain open: shell-QC discovery roots, residual No-COM names, the Codex coverage-hook floor, and the unfiled Non-Goals follow-ups.
- **Recommendation:** Remediate R1 (`remediation-inputs.2026-10-03T16-55.md`), push, obtain a green `shell-coverage` run on the head, and request a reaudit.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md`
- Total AC items: 43
- Checked off (delivered): 40
- Remaining (unchecked): 3
- Items remaining: AC-14 (detection of real bypasses not weakened; PARTIAL), AC-27 (CI on the PR head; pending CI), AC-43 (non-literal operand outcomes denied; PARTIAL)

---

## Acceptance Criteria Check-off

- Newly checked off by this review: AC-42 in `spec.md`, from `- [ ]` to `- [x]`. The reviewer ran the bats suite and kcov and recorded the measurement under `evidence/qa-gates/review-p3-ac42-kcov.2026-10-03T16-55.md`. Criterion text unchanged.
- Unchecked by this review: AC-14 and AC-43 in `spec.md`, each from `- [x]` to `- [ ]`, because the reviewer probe contradicts them (code review CR-1). Criterion text unchanged.
- Re-verified as PASS and left checked: AC-1..AC-13, AC-15..AC-26, AC-28..AC-41.
- Left unchecked: AC-27 (CI-dependent; the orchestrator run checks it off at S9).
