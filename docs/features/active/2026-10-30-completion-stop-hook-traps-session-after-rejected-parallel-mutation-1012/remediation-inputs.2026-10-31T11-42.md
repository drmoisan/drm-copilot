# Remediation Inputs (Issue #1012), initial review

Review-Verdict: AWAITING_CI

**Entry timestamp:** 2026-10-31T11-42
**Feature folder:** `docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012`
**Base branch:** `main` (merge base `52d818c3fc93288e1133f7d36fe76857f3c879a4`)
**Head:** `bug/completion-stop-hook-rejected-mutation-1012` @ `53bdea616163ef327d95d600489c4283ea08d11d`
**Work mode:** `full-bug`; AC source is `spec.md` only (20 AC: 19 PASS, AC-20 awaiting CI)
**Blocking finding count:** 3 (awaiting_ci: 3; other classes: 0)

## Audit Artifacts

- `docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012/policy-audit.2026-10-31T11-42.md` (Section 8, PA-1 and PA-2)
- `docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012/code-review.2026-10-31T11-42.md` (Findings Table: three Minor rows, two Info rows; no Blocker or Major)
- `docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012/feature-audit.2026-10-31T11-42.md` (19 PASS; AC-20 awaiting CI)

## Findings

### R1 - CI run on the PR head (feature-audit AC-20)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: AC-20 is a CI-dependent criterion; no pull request exists for the branch (artifacts/pr_context.summary.txt reports no PR yet), so the CI run on the PR head, including the Linux poshqc / PowerShell hook suites job, cannot have run. No code change is needed to produce it.

**Observed state.** AC-20 is unchecked in `spec.md`; no CI record exists for head `53bdea616`.

**Expected state.** The `CI` run on the final PR head concludes `success`, including the Linux `poshqc / PowerShell hook suites` job that runs the two new Pester suites.

**Clearing procedure.** At the S9 CI gate, record the run id, head SHA, and conclusion under `evidence/qa-gates/`, check off AC-20 in `spec.md` from the item's own worktree, push, and re-run the gate against the new head.

### R2 - PowerShell repo-wide line coverage figure (policy-audit PA-1)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: The on-disk artifacts/pester/powershell-coverage.xml was rewritten by a 3-minute targeted coverage-enabled run (session 11:23:16 to 11:26:38 UTC), so its report-level counters describe that run, not the full P5-T3 run. The per-file figures of both changed files (43 of 43, 122 of 123) are confirmed. The CI poshqc job merges shard coverage over the full suite and prints a Merged PowerShell line coverage line on the PR head, which supplies the repo-wide figure without a code change.

**Observed state.** Report-level LINE counter: covered 1708, missed 20663. The executor's evidence records 92.76% of 34165 commands for the full run but no repo-wide line figure.

**Expected state.** A recorded repo-wide PowerShell line figure at or above 85% for the PR head.

**Clearing procedure.** At the S9 CI gate, copy the `Merged PowerShell line coverage: <covered> of <total> lines (<percent>%)` line from the `poshqc` job into `evidence/qa-gates/` (for example `ps-coverage-pr-ci.<timestamp>.md`). A local full single-process `Invoke-PoshQCTest -ScanFolders tests/scripts` run whose artifact is not overwritten may be recorded as supplementary evidence.

### R3 - Python coverage artifact absent (policy-audit PA-2)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: The only changed Python file is a test module, so no production Python line changed; artifacts/python/lcov.info does not exist locally. The CI step Enforce Python coverage thresholds in _quality-checks.yml runs pytest with coverage over the whole repository on the PR head.

**Observed state.** No local Python coverage artifact.

**Expected state.** The CI step `Enforce Python coverage thresholds` concludes `success` on the PR head.

**Clearing procedure.** At the S9 CI gate, record the job id, step conclusion, and pytest `TOTAL` line under `evidence/qa-gates/`.

## Do Not Do

- Do not change production or test code to address R1, R2, or R3; none requires a code change.
- Do not check off AC-20 before CI on the final PR head concludes `success`.
- Do not lower, reinterpret, or add exclusions to coverage thresholds.
- Do not write coverage evidence outside `evidence/qa-gates/` in this feature folder.
- Do not rewrite or force-push commit `569be86e0` to change its message.

## Related findings that do not block the merge

- CR-1 Minor: commit `569be86e0` carries the reused preparation-run message; its content (Phase 0 evidence and plan check-offs) is correct. Note it in the PR description; a squash merge replaces the message on `main`.
- CR-2 Minor: coverage-enabled targeted runs overwrite the canonical artifact; record repo-wide figures at the time of the full run in future items.
- CR-3 Minor: the block for a valid signal defeated by contradicting live checkpoint text carries only the generic hint; an optional improvement is a line naming the contradicting state and the `artifacts/orchestration/handoff/` remedy. Spec-conformant as delivered.
- CR-4 Info and CR-5 Info: see the code review.
- File-size Warnings: none (largest covered file 412 logical lines).

## Orchestrator Cycle Scope

No autonomous remediation cycle is required. Proceed to PR authoring and clear R1, R2, and R3 at the S9 CI gate.
