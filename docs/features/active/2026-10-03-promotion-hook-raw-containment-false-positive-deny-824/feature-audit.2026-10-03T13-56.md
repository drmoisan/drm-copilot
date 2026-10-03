# Feature Audit: Promotion hook raw-containment false-positive deny (#824)

---

**Audit Date:** 2026-10-03
**Feature Folder:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
**Base Branch:** `origin/main`
**Head Branch:** `bug/promotion-hook-raw-containment-false-positive-deny-824`
**Work Mode:** `full-bug`
**Audit Type:** Reaudit after remediation cycle 1 (pass 2)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`)
- **Head branch/commit:** `bug/promotion-hook-raw-containment-false-positive-deny-824` (commit `c7b78cd2ea8c5a0bd010f0424f54498b7802597c`)
- **Merge base:** `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-03 17:46 UTC, head-bound to c7b78cd2)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/**`
  - Reviewer re-runs: 19 changed Pester suites (486 pass, 224 Issue824-tagged); 6 pytest files (148 pass); Black, Ruff, Pyright; check-only format and analyzer (0 drift, 0 findings); mirror parity (24 files byte-identical); grep checks; JaCoCo and lcov re-parse; merge-base versus head decision probes on both runtimes
  - Owner addenda fetched with `gh api` (comments 5970085575 and 5970141337, author `drmoisan`)
- **Feature folder used:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
- **Requirements source:** `spec.md` (only source), including `## Scope Extension` (AC-30..AC-41)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` is the sole AC source. The `issue.md` checklist is not authoritative and was not edited.
- **Scope note:** Full branch diff against `origin/main` (264 files). No PR exists, so CI-dependent AC-27 cannot be evaluated.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md` — only source

### Acceptance criteria

1. AC-1: R2 calls `Test-CommandLineRawInvocation`, not `Test-CommandLineRawContainment`, on both surfaces.
2. AC-2: `Test-CommandLineRawContainment` is used only by `Test-CommandLineMention`.
3. AC-3: An Unbalanced segment is denied by the promotion hook on both runtimes.
4. AC-4: Raw-invocation unit suites exist with the listed positive and negative cases.
5. AC-5: The exact reproduction is allowed on both runtimes.
6. AC-6: The through/issue/New-Object payload is allowed on both runtimes.
7. AC-7..AC-13: The seven listed `gh issue` forms and `gh api ... -X POST` are denied on both runtimes.
8. AC-14: Detection of real bypasses that raw containment caught is not weakened; three listed forms denied and `gh --repo o/r issue list` allowed.
9. AC-15: Negative control in `hook-command-invocation.Tests.ps1` on both surfaces.
10. AC-16: Test rename with assertions retained; pre-existing wrapper pins pass unedited.
11. AC-17: Audit record of every R2 caller.
12. AC-18..AC-21: Per-hook false-positive regressions (pr-author, worktree gates, validate-bash, preimplementation and merge gates).
13. AC-22: Contract comments corrected; no "only forces a checkpoint check" remains.
14. AC-23..AC-25: `.claude`/`.codex` parity, mirror parity and manifests, `SharedModuleNames` line.
15. AC-26: PowerShell toolchain with per-file coverage at or above 85% and no uncovered changed line.
16. AC-27: Full toolchain on the PR head in CI (CI-dependent).
17. AC-28: No changed file above 500 lines.
18. AC-29: Public signatures unchanged.
19. AC-30..AC-33: Addendum 1 (worktree-removal gates).
20. AC-34..AC-41: Addendum 2 (#823 follow-ups).

---

## Acceptance Criteria Evaluation

| AC | Status | Evidence | Notes |
|---|---|---|---|
| AC-1 | PASS | `git grep Test-CommandLineRawContainment` over both hooks roots returns only the definition (line 94) and the `Test-CommandLineMention` call (line 490); R2 calls `Test-CommandLineRawInvocation`. | — |
| AC-2 | PASS | Same grep: definition plus one informational caller per surface. | — |
| AC-3 | PASS | P824-D11 passes on both runtimes (reviewer run). | — |
| AC-4 | PASS | Both `hook-command-raw-invocation.Tests.ps1` suites pass with the listed rows. | — |
| AC-5 | PASS | Reviewer probe: the reproduction is allowed at head on the Claude promotion hook; Issue824 rows pass on both runtimes. | — |
| AC-6 | PASS | Issue824 rows pass on both runtimes. | — |
| AC-7 | PASS | Deny row passes on both runtimes; reviewer control `gh issue create --title x` denied. | — |
| AC-8 | PASS | Deny row passes on both runtimes. | — |
| AC-9 | PASS | Deny row passes on both runtimes. | — |
| AC-10 | PASS | Deny row passes on both runtimes. | — |
| AC-11 | PASS | Deny row passes on both runtimes. | — |
| AC-12 | PASS | Deny row passes on both runtimes. | — |
| AC-13 | PASS | Deny row passes on both runtimes. | — |
| AC-14 | PARTIAL | The three listed forms are denied and `gh --repo o/r issue list` is allowed (rows pass); B1-B5 from pass 1 are now denied. Reviewer probe at merge base versus head: `bash -c 'gh "$@"' _ issue create`, `bash -c 'gh $*' _ issue create`, `bash -c 'echo issue create (pipe) xargs gh'`, and `bash -c 'gh $1 $2' _ issue create` are denied at base and allowed at head on both runtimes. Seven wrapped worktree removals are denied at base and allowed at head through the gates (code review CR-1, CR-2). | General clause ("not weakened") is not met. Unchecked in `spec.md`. |
| AC-15 | PASS | N824-1 passes on both surfaces; pass-1 reviewer confirmed it fails when R2 is reverted. | — |
| AC-16 | PASS | Renamed test and wrapper pins pass; `evidence/qa-gates/r1-test-integrity.2026-10-03T13-22.md`. | — |
| AC-17 | PASS | `evidence/other/containment-path-hook-audit.md` names every listed hook, its call sites, effects, and dispositions, and states the abandon gate does not reach R2; updated in c7b78cd2 for the gate change. | — |
| AC-18 | PASS | A824-PR1 passes. | — |
| AC-19 | PASS | A824-WT1 and A824-WT2 pass in all three gate suites. | — |
| AC-20 | PASS | A824-VB1 passes on both runtimes. | — |
| AC-21 | PASS | A824-PI1 and A824-MG1 pass on both runtimes. | — |
| AC-22 | PASS | `git grep -c "only forces a checkpoint check"` over both hooks roots and `extensions/drm-copilot/resources` finds no match. | — |
| AC-23 | PASS | One SHA-256 for the four copies of each of `hook-command-invocation.ps1` and `hook-command-raw-invocation.ps1`. | — |
| AC-24 | PASS | All 24 changed canonical files byte-identical to mirrors; the four parity pytest files pass (reviewer). | — |
| AC-25 | PASS | `SharedModuleNames` on line 30 lists the module; the file is 497 lines; the suite passes. | — |
| AC-26 | PASS | Format 0 drift, analyze 0 findings (reviewer); every changed or new hook file at or above 93.64% lines with no uncovered changed line (`r1-coverage-delta.2026-10-03T13-40.md`, reviewer re-parse). | — |
| AC-27 | UNVERIFIED | No PR exists; CI has not run. | CI-dependent; checked off at S9. |
| AC-28 | PASS | Largest changed file 493 lines (`r1-line-counts.2026-10-03T13-41.md`). | — |
| AC-29 | PASS | Signature-pin tests pass without edits. | — |
| AC-30 | PASS | Reviewer probe: the Addendum 1 reproduction is allowed at head by the epic and parallel gates; A824-WT3 passes in all three gate suites. | — |
| AC-31 | PASS | A824-WT4-1..5 (deny without record) and A824-WT5-1..5 (allow with record) pass in all three gate suites. | The listed forms are gated as required; other spellings are covered by CR-1 under AC-14. |
| AC-32 | PASS | Rows cover each case; A824-WT3 asserts `Test-CommandLineRawContainment` true alongside an allow decision, so restoring containment-based R2 makes it fail. | — |
| AC-33 | PASS | Format, analyze, and Pester pass (reviewer and executor). | — |
| AC-34 | PASS | `Get-FeatureReviewCoverageThreshold` resolves each metric independently; F824-1 (lower figures), F824-2 (no figures), F824-3 (line-only) pass; the hook docstring states the precedence and fallback. | — |
| AC-35 | PASS | No listed copy names TaskMaster or No-COM; `test_listed_copy_names_no_consuming_product` fails on reintroduction (self-test included). | Residual names in unlisted `typescript.md` and `csharp.md` recorded as follow-up (code review CR-7). |
| AC-36 | PASS | `git grep TaskMaster.sln` outside docs finds only test fixtures and the test constant; `test_pushed_roots_carry_no_hard_coded_solution_file` scans the pushed roots; parity tests pass. | — |
| AC-37 | PASS | Step 8 now reads "coverage below the governing thresholds defined in step 5"; pinned by `test_review_workflow_step_eight_uses_governing_thresholds`. | — |
| AC-38 | PASS | Reviewer grep: every file that carries the precedence wording also carries the per-metric fallback (the threshold module states it in its own words). | — |
| AC-39 | PASS | `coverage_threshold_context` restricts the scan to coverage paragraphs; `test_retired_threshold_scan_reads_coverage_context_only` discriminates. | — |
| AC-40 | PASS | Follow-ups file: FU-823-1, -2, -3, -5 "Resolved by #824"; FU-823-4 "Open". | — |
| AC-41 | PASS | Python (Black, Ruff, Pyright, pytest 6595), TypeScript/Jest (`r1-jest.2026-10-03T13-41.md`, unchanged baselines), and PowerShell (format, analyze, 6753 tests with coverage) pass in the executor loop; reviewer re-ran the Python and PowerShell subsets. | Bash coverage gap (code review CR-3) is outside the AC-41 language list but is a policy finding. |

---

## Summary

- **Overall acceptance status:** Not accepted. 39 PASS, 1 PARTIAL (AC-14), 1 pending CI (AC-27), 0 FAIL.
- **Blocking gaps:**
  - CR-1: the worktree-removal gates allow seven real removals that the merge base denies, because the new `NoOperand` allow branch trusts an operand reader that stops at `(`, `<`, `>` and ignores `xargs`.
  - CR-2: the R2 matcher does not recognize positional parameters or `xargs`-led command words; four `gh issue create` forms that the merge base denies are allowed on both runtimes.
  - CR-3: the changed bash lines in `.codex/codex-web-setup.sh` have no test or coverage measurement.
- **Non-blocking gaps:** residual No-COM names in `typescript.md` and `csharp.md` (CR-7); the Codex coverage hook keeps a fixed 80% floor (CR-8); the shell-QC discovery roots exclude `.codex/` (policy conflict for the owner); the spec Non-Goals follow-ups are still unfiled.
- **Recommendation:** Remediate R1-R3 (`remediation-inputs.2026-10-03T13-56.md`) and request a reaudit.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md`
- Total AC items: 41
- Checked off (delivered): 39
- Remaining (unchecked): 2
- Items remaining: AC-14 (detection of real bypasses not weakened; PARTIAL), AC-27 (CI on the PR head; pending CI)

---

## Acceptance Criteria Check-off

- Newly checked off by this review: none. AC-1..AC-13, AC-15..AC-26, and AC-28..AC-41 were already checked, and each is re-verified as PASS above.
- Unchecked by this review: AC-14 in `spec.md`, from `- [x]` to `- [ ]`, because the reviewer probe contradicts its general clause (CR-1, CR-2). Criterion text unchanged.
- Left unchecked: AC-27 (CI-dependent; the orchestrator run checks it off at S9).
