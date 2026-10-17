# Feature Audit — Issue #928 (SubagentStop validator uncaught error exits 1), re-review after local coverage regeneration

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Head reviewed:** `637876da102759531b42b436dfb248196c77b5e2` (code head `b43188f8377b5c2bbbfd5484f52b7fc226876353`; PR #954)

## Total Blocking Findings: 0

FA-B1 and FA-B2 from the prior review (local coverage artifact state) are resolved. The local PowerShell report is at 94.58% repo-wide line coverage, and the local Python lcov report is present at 93.80% lines and 88.11% branches; this review parsed both. No acceptance criterion depended on those findings. All sixteen criteria remain PASS.

## Scope and Baseline

- Baseline: `origin/main` (`a880c46b`). The merge base equals `origin/main` after merge `5f4f9a332`; the branch is 37 ahead and 0 behind.
- Scope: the full branch diff against `origin/main` (145 files), not only the last remediation step.
- Work mode: `full-bug` (`issue.md` line 12). The AC source is `spec.md`, section `## Acceptance Criteria` (AC1-AC16, lines 206-221).
- This review verified the pre-change state from the diff base (`git diff origin/main...HEAD`) and did not rely on executor claims alone. No item file changed after `b43188f83`: `git diff --stat b43188f83 HEAD` over the item paths is empty.

## Acceptance Criteria Inventory

There are sixteen criteria, all in checkbox format. At review start all sixteen were `[x]`; lines 206-221 of `spec.md` were read by this review.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 | PASS | Catch lines discovery `:253`, executor `:322`, orchestrator `:344`, planner `:440`, pr-author `:129`, prd-feature `:118`, required-artifact `:199`, task-researcher `:290` call `Exit-SubagentStopBlock` with the S1 prefix and the first exception line (grep by this review). |
| AC2 | PASS | One `.NOTES` sentence per validator; the files are unchanged since the prior review. |
| AC3 | PASS | `validate-feature-review-coverage.ps1` and its mirror are not in the branch file list (this review); the characterization row is present. |
| AC4 | PASS | The only hunk in `subagentstop-envelope.ps1` is the citation; the mirror is byte-identical (`cmp` by this review). |
| AC5 | PASS | Nine U1 rows with the required mock, route, constraints, and assertions; the test file is unchanged. |
| AC6 | PASS | The U2 completeness test is unchanged. The merge from `main` changed no `.claude/hooks` file, so the set of hooks that dot-source the helper is unchanged. |
| AC7 | PASS | `evidence/regression-testing/` fail-before records; fail-after in `poshqc-test.2026-10-16T05-39.md` (13 passed). |
| AC8 | PASS | `cmp` by this review at `637876da1`: 12 `.claude` files and the `.agents` skill are byte-identical to their bundle counterparts; the bundle-parity pytest passed (within 50 passed, this review). |
| AC9 | PASS | Citation edits unchanged since `citation-width.2026-10-16T05-41.md`. |
| AC10 | PASS | `claude-code-architecture.md` states exit-2 blocking for SubagentStop; the file is unchanged since the prior review. |
| AC11 | PASS | The stale statements are corrected in the epic skill, epic agent, wave-barrier comment, and `.agents` row; the frozen-surface pins equal the current `sha256sum` (this review). |
| AC12 | PASS | No `.codex`, bundle `.codex`, `settings.json`, or `core.json` path is in the branch file list (this review). |
| AC13 | PASS | `poshqc-test.2026-10-16T05-39.md` (named suites 0 failures); CI `poshqc / PowerShell hook suites (Linux)` success on `6c2c717c3`. |
| AC14 | PASS | Format, analyze, and test evidence (`poshqc-format`, `poshqc-analyze`, `poshqc-test`). Coverage clause: the local report gives four changed hooks at 98.96%-100.00%, and CI run 38871371045 on `6c2c717c3` gives all ten changed `.claude/hooks` files at 98.08%-100.00% (aggregate 909/917). Both were parsed by this review. |
| AC15 | PASS | `gh api .../commits/6c2c717c3.../check-runs` (this review): 20 of 20 success, including `poshqc / PowerShell QC`, `poshqc / PowerShell hook suites (Linux)`, and `quality-checks7` 3.10-3.13. CI on the Markdown-only head `637876da1` is in progress; the orchestrator confirms it at S9 (CR5-N3). |
| AC16 | PASS | Largest changed non-Markdown file is 442 lines (`validate-planner-output.ps1`); `wc -l` by this review. |

## Summary

All 16 criteria PASS. The fix addresses the reported defect: an error raised in each validator's validation call now produces exit 2 with a prefixed reason instead of exit 1. The prior blocking findings, which concerned the local coverage artifacts, are resolved. The branch is current with `main`.

## Acceptance Criteria Check-off

This review made no change to `spec.md`. All sixteen items were already `[x]`, and this review confirms each one.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/spec.md`
- Total AC items: 16
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: none

## Findings

### Blocking

None.

### Prior findings

- FA-B1 / PA-B1 / CR4-B1 (local PowerShell report 52.00%): resolved (94.58%).
- FA-B2 / PA-B2 / CR4-B2 (local Python lcov absent): resolved (93.80% lines, 88.11% branches).
- CR4-N2 (behind `main`): resolved by merge `5f4f9a332`.
- CR-N5, CR2-N1, CR2-N2, CR2-N5, CR3-N1, CR3-N2: accepted per orchestrator decision; not findings.

### Non-blocking

See `code-review.2026-10-16T08-29.md`:
- CR5-N1: six changed hooks are absent from the local PowerShell report; CI per-file figures (98.08%-100.00%) cover them.
- CR5-N2: `evidence/qa-gates/local-coverage-regeneration.2026-10-16T08-25.md:11` states branch 92.07% (5863/6368). The lcov file reports 88.11% (5611/6368).
- CR5-N3: CI on `637876da1` was in progress at review time; the orchestrator confirms it at S9.

### Out-of-loop observation (accepted)

- `.claude/hooks/validate-planner-output.ps1:186` rejects root-level `CITATION:` paths. The line predates this branch.

## Assumptions

- The stamp `2026-10-16T08-29` is UTC (`date -u` at write time).
- `637876da1` is treated as code-equivalent to `6c2c717c3` and `b43188f` for the item paths (`git diff` by this review).
- Coverage was assessed from existing local and CI artifacts; coverage generation was not rerun.
