# Feature Audit — Issue #928 (SubagentStop validator uncaught error exits 1), re-audit after remediation cycle 3

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Head reviewed:** `a210f5cf92fbbc09679dab9fa3b2756538b076f0` (code head `b43188f8377b5c2bbbfd5484f52b7fc226876353`; PR #954)

## Total Blocking Findings: 2

The two blocking findings, FA-B1 and FA-B2, are the policy audit's PA-B1 and PA-B2. FA-B1 is the local PowerShell coverage artifact at 52.00% repo-wide (partial scope). FA-B2 is the absence of the local Python lcov artifact. Both are classified `autonomous`. They concern local artifact state, not delivered behaviour, and no acceptance criterion depends on them: AC14's clause covers changed PowerShell under `.claude/hooks`, and the PR-head CI artifact shows 98.08%-100.00% per file. The prior `awaiting_ci` item on AC14 is resolved by that CI artifact, which this review recomputed.

## Scope and Baseline

- Baseline: `origin/main` (`a880c46b`), merge base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`. The branch is 34 commits ahead and 55 behind; no file changed on `main` since the merge base overlaps the branch file list.
- Scope: the full branch diff against `origin/main` (140 files), not only remediation cycle 3.
- Work mode: `full-bug` (`issue.md` line 12). The AC source is `spec.md`, section `## Acceptance Criteria` (AC1-AC16, lines 206-221).
- The pre-change state was verified from the diff base (`git diff origin/main...HEAD`), not from executor claims alone. Since the prior review head `2f6b9600`, the following changed: the CI-failure inputs and cycle-3 plan, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, the AC14 and AC15 checkboxes in `spec.md`, and feature-folder evidence (`git diff --name-status e03d60829 HEAD`).

## Acceptance Criteria Inventory

Sixteen criteria, all in checkbox format. At review start all sixteen were checked (`grep -nE '^- \[[ x]\] AC' spec.md`: lines 206-221, all `[x]`). AC14 and AC15 were checked off by the orchestrator at S9 in `a210f5cf9`.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 | PASS | Catch lines discovery `:253`, executor `:322`, orchestrator `:344`, planner `:440`, pr-author `:129`, prd-feature `:118`, required-artifact `:199`, task-researcher `:290` each call `Exit-SubagentStopBlock` with the file's S1 prefix, `validator error:`, and the first exception line. No validator changed in any remediation cycle after cycle 1. |
| AC2 | PASS | One `.NOTES` sentence per validator (diff hunks reviewed by this review). |
| AC3 | PASS | `validate-feature-review-coverage.ps1` and its mirror are not in the branch file list; the U1 table contains its characterization row. |
| AC4 | PASS | The only hunk in `subagentstop-envelope.ps1` is the citation (lines 12-14); the mirror is byte-identical (this review). |
| AC5 | PASS | Nine U1 rows with the required mock, route, constraints, and assertions; banned-token count 0 (`test-file-constraints.2026-10-16T05-22.md`); test file unchanged since. |
| AC6 | PASS | U2 compares the U1 table with the AST-discovered set of hooks that dot-source the helper; the set is the same nine hooks on the branch and on `origin/main` (`git grep` by this review). |
| AC7 | PASS | `fail-before.2026-10-16T02-03.md` (eight AC1 rows FAIL pre-fix); fail-after `poshqc-test.2026-10-16T05-39.md` (13 passed). |
| AC8 | PASS | `cmp` by this review at `a210f5cf9`: 12 changed `.claude` files and the `.agents` skill are byte-identical to their bundle counterparts; bundle-parity pytest passed (this review, within 50 passed). |
| AC9 | PASS | Citation edits unchanged since `citation-width.2026-10-16T05-41.md`; the active-path fallback still resolves on the branch and `origin/main`. |
| AC10 | PASS | `claude-code-architecture.md:237` and `:239` state the deny-decision and exit-2 contracts; no "exits with code 1 and blocks" text remains in the diff. |
| AC11 | PASS | Epic skill (lines 279-281), epic agent (lines 133-135), wave-barrier comment (lines 34-35), and the `.agents` row (line 285) state exit-2 blocking; mirrors identical. The frozen-surface digests for the skill and agent were re-baselined in cycle 3 and match `sha256sum` (this review). |
| AC12 | PASS | No path under `.codex/` or the bundle `.codex/`, no `settings.json`, and no `core.json` is in the branch file list (this review). |
| AC13 | PASS | `poshqc-test.2026-10-16T05-39.md`: `hook-dependency-guard-completeness` 598/0, `hook-dependency-failure.Claude` 148/0, `claude-settings` 9/0. CI `poshqc / PowerShell hook suites (Linux)` success on `b43188f`. |
| AC14 | PASS | Format, analyze, and test clauses: `poshqc-format.2026-10-16T05-27.md`, `poshqc-analyze.2026-10-16T05-28.md`, `poshqc-test.2026-10-16T05-39.md`. Coverage clause: CI run 38867388618 `powershell-coverage.xml` (PR head `b43188f`), recomputed by this review: ten changed files under `.claude/hooks` 98.08%-100.00% (aggregate 909/917, 99.13%), repo 90.45%; matches `s9-ci-coverage.2026-10-16T07-48.md`. |
| AC15 | PASS | `gh api .../commits/b43188f.../check-runs` (this review): `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)`, and `quality-checks7 / Code Quality & Tests` (3.10-3.13, the pytest jobs that run the bundle-parity tests) are all `success`; 20 of 20 checks success. The re-run on the Markdown-only head `a210f5cf9` was pending at review time (CR4-N1, non-blocking). |
| AC16 | PASS | Largest changed non-Markdown file 442 lines (`validate-planner-output.ps1` and mirror); `parallel_orchestrator_surface_expectations.py` 387; new suite 159 (`wc -l` by this review). |

## Summary

All 16 criteria PASS. The two blocking findings concern local coverage artifacts and do not change any AC verdict. The fix addresses the reported defect: an error raised inside each validator's validation call now produces exit 2 with a prefixed reason instead of exit 1. Remediation cycle 3 resolved the CI failure without changing production code, and the S9 check-off of AC14 and AC15 is supported by evidence that this review reproduced.

## Acceptance Criteria Check-off

This review made no change to `spec.md`. All sixteen items were already `[x]`, and this review confirms each one. AC14 and AC15 were checked off at S9 by the item's orchestrator run, as the CI-dependent criteria protocol provides.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/spec.md`
- Total AC items: 16
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: none

## Findings

### Blocking

- FA-B1 (= PA-B1 / CR4-B1; Remediability: autonomous): local `artifacts/pester/powershell-coverage.xml` reports 52.00% repo-wide line coverage (partial-scope run). Regenerate it with full scope at the code head, or have the operator accept the PR-head CI artifact (90.45%) as the source of record.
- FA-B2 (= PA-B2 / CR4-B2; Remediability: autonomous): local `artifacts/python/lcov.info` is absent. Generate it at the code head, or apply the same operator decision.

### Prior findings

- Prior cycle FA-B1 / PA-B1 / CR-B1 (AC14 coverage clause, `awaiting_ci`): resolved (see AC14 row).
- CI-1 (frozen epic-surface digests): resolved (pins equal current `sha256sum`; CI `quality-checks7` success on `b43188f`).
- CR-N5, CR2-N1, CR2-N2, CR2-N5, CR3-N1, CR3-N2: accepted per orchestrator decision; not findings.

### Non-blocking (new, Info)

See `code-review.2026-10-16T07-53.md`:
- CR4-N1: CI on the final head `a210f5cf9` was pending at review time; the orchestrator must gate on the final head before DONE.
- CR4-N2: the branch is 55 commits behind `origin/main` (`mergeStateStatus: BEHIND`, no overlapping files); update before merge and re-gate.

### Out-of-loop observation (accepted)

- `.claude/hooks/validate-planner-output.ps1:186` rejects root-level `CITATION:` paths (no `/`). The line is pre-existing and outside this branch's hunks. It is recorded for separate follow-up, and the loop guard prevents another cycle.

## Assumptions

- The stamp `2026-10-16T07-53` is UTC (`date -u` at write time).
- `a210f5cf9` is treated as code-equivalent to `b43188f` because the only differences are Markdown under the feature folder (`git diff --name-status b43188f83 a210f5cf9`).
- Coverage was assessed from existing CI artifacts; coverage generation was not rerun.
