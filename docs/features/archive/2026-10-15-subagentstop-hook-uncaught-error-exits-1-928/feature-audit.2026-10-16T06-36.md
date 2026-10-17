# Feature Audit — Issue #928 (SubagentStop validator uncaught error exits 1), re-audit after remediation cycle 2

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Head reviewed:** `2f6b960051a92c85a3fcc7ea8c85dd89fea79014`

## Total Blocking Findings: 1

The blocking finding is FA-B1 (AC14 coverage clause pending CI), classified `awaiting_ci`. It is the same item as PA-B1 and CR-B1 and is unchanged from the two prior reviews.

## Scope and Baseline

- Baseline: `origin/main` at merge base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`; the branch is 0 commits behind and 30 ahead.
- Scope: the full branch diff against `origin/main` (115 files), not only remediation cycle 2.
- Work mode: `full-bug` (`issue.md` line 12). The AC source is `spec.md`, section `## Acceptance Criteria` (AC1-AC16).
- Pre-change state was verified from the diff base (`git diff origin/main...HEAD`), not from executor claims alone. Mirror parity, excluded paths, catch lines, dot-source set, line counts, and local coverage were re-checked by this review at `2f6b9600`. Since the prior review head `b222a6ba`, only Markdown files under the feature folder changed (`git diff --name-status b222a6baf HEAD`).

## Acceptance Criteria Inventory

Sixteen criteria, all in checkbox format. At review start, AC1-AC13 and AC16 were checked; AC14 and AC15 were unchecked (`spec.md:206-221`).

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 | PASS | Catch lines discovery `:253`, executor `:322`, orchestrator `:344`, planner `:440`, pr-author `:129`, prd-feature `:118`, required-artifact `:199`, task-researcher `:290` each call `Exit-SubagentStopBlock` with the file's S1 prefix, `validator error:`, and the first exception line (`grep -n` by this review). No validator changed in either remediation cycle. |
| AC2 | PASS | One `.NOTES` sentence per validator (verified in the prior review; no validator changed since). |
| AC3 | PASS | `git diff --quiet origin/main...HEAD` on `validate-feature-review-coverage.ps1` and its mirror exits 0 (this review); the U1 table contains its characterization row. |
| AC4 | PASS | The only hunk in `subagentstop-envelope.ps1` is the citation (lines 12-14); whitespace-normalized text is unchanged (`limited-diff.2026-10-16T05-41.md`); file unchanged since. |
| AC5 | PASS | Nine U1 rows with the required mock, route, constraints, and assertions; banned-token count 0 (`test-file-constraints.2026-10-16T05-22.md`); test file unchanged since. |
| AC6 | PASS | U2 compares the U1 table with the AST-discovered set of hooks that dot-source the helper; that set is still the nine U1 hooks at `2f6b9600` (`grep -l` by this review). |
| AC7 | PASS | `fail-before.2026-10-16T02-03.md`: eight AC1 rows FAIL, the feature-review row and U2 PASS. Fail-after: `poshqc-test.2026-10-16T05-39.md`, suite MATCHED 13 FAILED 0. |
| AC8 | PASS | `cmp` by this review at `2f6b9600`: 12 changed `.claude` files and the `.agents` skill are byte-identical to their bundle counterparts; `pytest-bundle-parity.2026-10-16T05-40.md` records 14 passed. |
| AC9 | PASS | Citation counts per file unchanged (`citation-width.2026-10-16T05-41.md`); the helper and the test have not changed since. |
| AC10 | PASS | `claude-code-architecture.md` unchanged since the prior review, which found "exits with code 1 and blocks" 0 matches and the unhandled-error clause 1 match. |
| AC11 | PASS | The epic skill, epic agent, wave-barrier comment, and `.agents` skill are unchanged since the prior review; mirrors identical (this review). |
| AC12 | PASS | `git diff --quiet origin/main...HEAD` over `.codex`, the bundle `.codex`, and both `settings.json` files exits 0 (this review); `excluded-paths-diff.2026-10-16T05-42.md` also covers `core.json`. |
| AC13 | PASS | `poshqc-test.2026-10-16T05-39.md`: `hook-dependency-guard-completeness` 598/0, `hook-dependency-failure.Claude` 148/0, `claude-settings` 9/0; 5334 tests, 0 failures. No PowerShell file changed after that run. |
| AC14 | PARTIAL (pending CI) | Format, analyze, and test clauses are met (`poshqc-format.2026-10-16T05-27.md`, `poshqc-analyze.2026-10-16T05-28.md`, `poshqc-test.2026-10-16T05-39.md`). The coverage clause is not verifiable locally: six of ten changed files are absent from `artifacts/pester/powershell-coverage.xml` (recomputed by this review); the four present files are 98.96%-100.00%. FA-B1. |
| AC15 | UNVERIFIED (pending CI) | CI-dependent by definition; no PR exists for the branch (`gh pr list --head bug/subagentstop-hook-uncaught-error-exits-1-928 --state all` returned `[]`). Checked off at S9 by the item's orchestrator run. |
| AC16 | PASS | Largest changed non-Markdown file 442 lines (`validate-planner-output.ps1` and mirror); new suite 159 lines (`wc -l` by this review). |

## Summary

14 of 16 criteria PASS. AC14 is PARTIAL and AC15 is UNVERIFIED; both depend on CI on the PR head and are classified `awaiting_ci`. Remediation cycle 2 did not regress any criterion and did not change any AC checkbox. The fix addresses the reported defect: an error raised inside each validator's validation call now produces exit 2 with a prefixed reason instead of exit 1.

## Acceptance Criteria Check-off

No change was made to `spec.md` by this review. AC1-AC13 and AC16 were already `[x]` and this review confirms each. AC14 and AC15 remain `[ ]`; they are CI-dependent criteria owned by the item's orchestrator run at S9.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/spec.md`
- Total AC items: 16
- Checked off (delivered): 14
- Remaining (unchecked): 2
- Items remaining: AC14 (PoshQC format, analyze, test pass and line coverage >= 85% for changed PowerShell under `.claude/hooks`; coverage clause pending CI), AC15 (CI on the PR head reports success for the PowerShell QC, Linux hook suites, and bundle-parity pytest jobs; pending CI)

## Findings

### Blocking

- FA-B1 (Remediability: awaiting_ci): AC14 coverage clause. Resolved by the `poshqc / PowerShell QC` coverage artifact on the PR head showing each of the ten changed `.claude/hooks` files at >= 85% line coverage and not below baseline, and the repo-wide figure at >= 85%. Same item as PA-B1 and CR-B1.

### Prior findings

- CR2-N3: resolved (`spec.md:6` `Last Updated: 2026-10-16T06-23`, `spec.md:8` `Version: 0.3`).
- CR2-N4: resolved (`issue.md:5` names the existing feature folder).
- CR-N5, CR2-N1, CR2-N2, CR2-N5: accepted per orchestrator decision; not findings.

### Non-blocking (new, Info)

See `code-review.2026-10-16T06-36.md`:
- CR3-N1: `remediation-plan.2026-10-16T06-40.md`; filename stamp later than its commit time and the evidence it governed.
- CR3-N2: `issue.md:11`; `Last Updated: 2026-10-15` not updated after the cycle-2 edit of line 5.

## Assumptions

- The stamp `2026-10-16T06-36` is UTC (`date -u` at write time); see CR3-N1 for its ordering relative to the cycle-2 plan.
- Coverage was assessed from the existing `artifacts/pester/powershell-coverage.xml`; coverage generation was not rerun.
- Pester results are taken from recorded cycle-1 evidence; no PowerShell file changed after that run.
