# Feature Audit — Issue #928 (SubagentStop validator uncaught error exits 1), re-audit after remediation cycle 1

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Head reviewed:** `b222a6baf6dbe42f86a352938a3e8518ca1fedc0`

## Total Blocking Findings: 1

The blocking finding is FA-B1 (AC14 coverage clause pending CI), classified `awaiting_ci`. It is the same item as PA-B1 and CR-B1 and is unchanged from the prior review.

## Scope and Baseline

- Baseline: `origin/main` at merge base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`; the branch is 0 commits behind.
- Scope: the full branch diff against `origin/main` (103 files), not only remediation cycle 1.
- Work mode: `full-bug` (`issue.md` line 12). The AC source is `spec.md`, section `## Acceptance Criteria` (AC1-AC16).
- Pre-change state was verified from the diff base (`git diff origin/main...HEAD`), not from executor claims alone. Mirror parity, excluded paths, `.NOTES` sentences, documentation tokens, line counts, and local coverage were re-checked by this review at `b222a6ba`.

## Acceptance Criteria Inventory

Sixteen criteria, all in checkbox format. At review start, AC1-AC13 and AC16 were checked; AC14 and AC15 were unchecked.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 | PASS | Each of the eight validators wraps its validation call in `try { ... }` after the S1 tail (required-artifact: after the argument check); catch lines discovery `:253`, executor `:322`, orchestrator `:344`, planner `:440`, pr-author `:129`, prd-feature `:118`, required-artifact `:199`, task-researcher `:290` each call `Exit-SubagentStopBlock` with the file's S1 prefix, `validator error:`, and the first exception line; the result check and `exit 0` follow. No validator changed in cycle 1. |
| AC2 | PASS | `grep -c` of the `.NOTES` sentence returns 1 in each of the eight validators (this review). |
| AC3 | PASS | `git diff --quiet origin/main...HEAD` on `validate-feature-review-coverage.ps1` and its mirror exits 0 (this review); the U1 table contains its characterization row. |
| AC4 | PASS | The only hunk in `subagentstop-envelope.ps1` is the citation starting at line 12 (now lines 12-14 after the cycle-1 rewrap); whitespace-normalized text is unchanged (`limited-diff.2026-10-16T05-41.md`). |
| AC5 | PASS | Nine U1 rows, one per validator in the family, with the required mock, route, constraints, and assertions; banned-token count 0 (`test-file-constraints.2026-10-16T05-22.md`). The two U1-ST rows added in cycle 1 are additional and keep the same constraints. |
| AC6 | PASS | U2 compares the U1 table with the AST-discovered set of hooks containing the guarded helper dot-source; that set is still the nine U1 hooks at `b222a6ba` (`grep -l` by this review). |
| AC7 | PASS | `fail-before.2026-10-16T02-03.md`: the eight AC1 rows FAIL, the feature-review row and U2 PASS. Fail-after: `poshqc-test.2026-10-16T05-39.md`, suite MATCHED 13 FAILED 0. |
| AC8 | PASS | `cmp` by this review at `b222a6ba`: 12 changed `.claude` files and the `.agents` skill are byte-identical to their bundle counterparts; `pytest-bundle-parity.2026-10-16T05-40.md` records 14 passed. |
| AC9 | PASS | The helper (and mirror) and the test cite the archive path and name the active path as interim (counts 1, 0, 1 per file, `citation-width.2026-10-16T05-41.md`). |
| AC10 | PASS | `claude-code-architecture.md`: "exits with code 1 and blocks" 0 matches; "or when the validator raises an unhandled error" 1 match (this review). |
| AC11 | PASS | The potential-record path occurs 0 times in `epic-orchestrate/SKILL.md`, `epic-orchestrator.md`, and `enforce-epic-wave-barrier.ps1`; "SubagentStop, exit 1" occurs 0 times in the `.agents` skill (this review); mirrors identical; the wave-barrier hunk is comment-help only. |
| AC12 | PASS | `git diff --quiet origin/main...HEAD` over `.codex`, the Codex-bundle `.codex`, and both `settings.json` files exits 0 (this review); `excluded-paths-diff.2026-10-16T05-42.md` also covers `core.json`; the `epic-orchestrator.md` change is body text. |
| AC13 | PASS | `poshqc-test.2026-10-16T05-39.md`: `hook-dependency-guard-completeness` 598/0, `hook-dependency-failure.Claude` 148/0, `claude-settings` 9/0; totals 5334 tests, 0 failures. Taken from recorded evidence; the later merge touches no path in this scope. |
| AC14 | PARTIAL (pending CI) | Format, analyze, and test clauses are met (`poshqc-format.2026-10-16T05-27.md`, `poshqc-analyze.2026-10-16T05-28.md`, `poshqc-test.2026-10-16T05-39.md`). The coverage clause is not verifiable locally: six of ten changed files are absent from `artifacts/pester/powershell-coverage.xml` (recomputed by this review). The four present files are 98.96%-100.00%. FA-B1. |
| AC15 | UNVERIFIED (pending CI) | CI-dependent by definition; no PR exists for the branch (`gh pr list --head` returned an empty list). Checked off at S9 by the item's orchestrator run. |
| AC16 | PASS | Largest changed file 442 lines (`validate-planner-output.ps1` and mirror); new suite 159 lines (`wc -l` by this review). |

## Summary

14 of 16 criteria PASS. AC14 is PARTIAL and AC15 is UNVERIFIED; both depend on CI on the PR head and are classified `awaiting_ci`. Remediation cycle 1 did not regress any criterion. The fix addresses the reported defect: an error raised inside each validator's validation call, whether script-terminating or (for the two default-preference validators) statement-terminating, now produces exit 2 with a prefixed reason instead of exit 1.

## Acceptance Criteria Check-off

No change was made to `spec.md`. AC1-AC13 and AC16 were already `[x]` and this review confirms each. AC14 and AC15 remain `[ ]`; they are CI-dependent criteria owned by the item's orchestrator run at S9.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/spec.md`
- Total AC items: 16
- Checked off (delivered): 14
- Remaining (unchecked): 2
- Items remaining: AC14 (PoshQC format, analyze, test pass and line coverage >= 85% for changed PowerShell under `.claude/hooks`; coverage clause pending CI), AC15 (CI on the PR head reports success for the PowerShell QC, Linux hook suites, and bundle-parity pytest jobs; pending CI)

## Findings

### Blocking

- FA-B1 (Remediability: awaiting_ci): AC14 coverage clause. Resolved by the `poshqc / PowerShell QC` coverage artifact on the PR head showing each of the ten changed `.claude/hooks` files at >= 85% line coverage and not below baseline, and the repo-wide figure at >= 85%. Same item as PA-B1 and CR-B1.

### Prior non-blocking findings

- CR-N1, CR-N2, CR-N3, CR-N4: resolved (verified in `code-review.2026-10-16T05-53.md`, section Prior Findings Verification).
- CR-N5: accepted as a design choice; not a finding.
- CR-N6: resolved (branch up to date with `origin/main`).

### Non-blocking (new, all Info)

See `code-review.2026-10-16T05-53.md`:
- CR2-N1: `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1:117-134`; U1-ST rows were not run against the pre-fix validators.
- CR2-N2: `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1:9-11`; uneven rewrap (68 then 112 characters).
- CR2-N3: `spec.md:6-7`; `Last Updated` and `Version` not updated after cycle-1 edits.
- CR2-N4: `issue.md:5`; status path names a folder that does not exist.
- CR2-N5: `.claude/hooks/validate-bash.ps1:441-443`; PreToolUse analogue of #928, outside this item's scope.

## Assumptions

- The stamp `2026-10-16T05-53` is UTC (`date -u`), consistent with this feature's evidence stamps.
- Coverage was assessed from the existing `artifacts/pester/powershell-coverage.xml`; coverage generation was not rerun.
- Pester results are taken from recorded cycle-1 evidence; this review session has no PoshQC MCP tool.
