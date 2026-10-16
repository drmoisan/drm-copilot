# Feature Audit — Issue #928 (SubagentStop validator uncaught error exits 1)

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Head reviewed:** `20c7a8088093a13f1937a4e75f7ed7f581f76a8b`

## Total Blocking Findings: 1

The blocking finding is FA-B1 (AC14 coverage clause pending CI), classified `awaiting_ci`. It is the same item as PA-B1 and CR-B1.

## Scope and Baseline

- Baseline: `origin/main` at merge-base `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99`.
- Work mode: `full-bug` (`issue.md` line 12). The AC source is `spec.md`, section `## Acceptance Criteria` (AC1-AC16).
- Pre-change state was verified from the diff base (`git diff adb9aa5f..HEAD`), not from executor claims alone. Mirror parity, excluded paths, `.NOTES` placement, line counts, and local coverage were re-checked by this review.

## Acceptance Criteria Inventory

Sixteen criteria, all in checkbox format. At review start, AC1-AC13 and AC16 were checked; AC14 and AC15 were unchecked.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 | PASS | Diff shows each of the eight validators wrapping its validation call in `try { ... }` immediately after the S1 tail (required-artifact: after the argument check, as `spec.md:88` specifies); each `catch` calls `Exit-SubagentStopBlock` with the file's S1 prefix and `validator error:` plus the first exception line; `if (-not $result.Ok)` (pr-author: `if (-not $decision['allowed'])`) and `exit 0` follow. `evidence/qa-gates/tail-placement.2026-10-16T02-05.md`. |
| AC2 | PASS | Exactly one occurrence of the sentence per file, positioned between the `.NOTES` keyword and the end of the help block in all eight files (line positions checked by this review). |
| AC3 | PASS | `git diff --quiet adb9aa5f..HEAD` on `validate-feature-review-coverage.ps1` and its mirror exits 0 (this review); the U1 table contains its characterization row, which passed before and after the fix. |
| AC4 | PASS | The only hunk in `subagentstop-envelope.ps1` is the line-12 citation. |
| AC5 | PASS | Nine U1 rows, one per validator in the family; mock throws; `&` route; no temporary file, `TestDrive`, subprocess, or environment variable (search by this review returned no match); assertions for no propagated exception, exit 2, ordinal prefix, error text, and `-Times 1 -Exactly`. |
| AC6 | PASS | U2 compares the table with the AST-discovered set of hooks containing the guarded helper dot-source. |
| AC7 | PASS | `fail-before.2026-10-16T02-03.md`: the eight AC1 rows FAIL with the escaped `RuntimeException`, the feature-review row and U2 PASS. `fail-after.2026-10-16T02-22.md`: suite MATCHED 10 FAILED 0. |
| AC8 | PASS | `cmp` by this review: 12 changed `.claude` files and the `.agents` skill are byte-identical to their bundle counterparts; `pytest-bundle-parity.2026-10-16T03-16.md` records 14 passed. |
| AC9 | PASS | `subagentstop-envelope.ps1:12`, its mirror (byte-identical), and `subagentstop-envelope.Tests.ps1:9` cite the archive path and name the active path as interim. |
| AC10 | PASS | `claude-code-architecture.md:239` states exit 2 with a stderr reason, including on an unhandled error, and that exit 1 does not block. |
| AC11 | PASS | The four statements and their mirrors are corrected; the wave-barrier diff is within the comment-help block only. |
| AC12 | PASS | `git diff --name-only` over `.codex`, the Codex-bundle `.codex`, `.claude/settings.json`, and `core.json` returns nothing; the `epic-orchestrator.md` change is body text at lines 133-135, not frontmatter. |
| AC13 | PASS | `poshqc-test.2026-10-16T03-00.md`: `hook-dependency-guard-completeness` 598/0 failed, `hook-dependency-failure.Claude` 148/0, `claude-settings` 9/0; totals 5332 tests, 0 failures. Taken from recorded evidence; not rerun by this review. |
| AC14 | PARTIAL (pending CI) | Format, analyze, and test clauses are met (`poshqc-format`, `poshqc-analyze`, `poshqc-test` evidence, all MCP ok). The coverage clause is not verifiable locally: six of ten changed files are absent from `artifacts/pester/powershell-coverage.xml` (confirmed by this review). The four present files are 98.96%-100.00%. FA-B1. |
| AC15 | UNVERIFIED (pending CI) | CI-dependent by definition; no PR exists yet. Checked at S9 by the item's orchestrator run (`ac15-ci-pending.2026-10-16T03-20.md`). |
| AC16 | PASS | Maximum changed-file length 442 lines (`validate-planner-output.ps1`); new suite 134 lines (`wc -l` by this review). |

## Summary

14 of 16 criteria PASS. AC14 is PARTIAL and AC15 is UNVERIFIED; both depend on CI on the PR head and are classified `awaiting_ci`. The fix addresses the reported defect: an error thrown inside each validator's validation call now produces exit 2 with a prefixed reason instead of exit 1, as the fail-before and fail-after runs demonstrate.

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

- FA-B1 (Remediability: awaiting_ci): AC14 coverage clause. Resolved by the `poshqc / PowerShell QC` coverage artifact on the PR head showing each of the ten changed `.claude/hooks` files at >= 85% line coverage and not below baseline. Same item as PA-B1 and CR-B1.

### Non-blocking

See `code-review.2026-10-16T03-30.md`:
- CR-N1: `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1:393-408` exercises only a script-terminating `throw`; add statement-terminating variants for the discovery and pr-author validators.
- CR-N2: `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1:369` does not restore `$global:LASTEXITCODE`.
- CR-N3: `docs/engineering/claude-code-architecture.md:237` states that `validate-bash.ps1` blocks with exit 1; the hook uses a JSON deny decision.
- CR-N4: comment-help line wrapping at `.claude/hooks/subagentstop-envelope.ps1:12` (and mirror) and `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1:9`.
- CR-N5: report-and-halt literal duplicated in four validators (optional).
- CR-N6: branch is behind `origin/main` by PR #943; no overlapping paths.

## Assumptions

- The stamp `2026-10-16T03-30` is UTC (`date -u`), consistent with this feature's evidence stamps.
- Coverage was assessed from the existing `artifacts/pester/powershell-coverage.xml`; coverage generation was not rerun.
- Pester results are taken from recorded evidence; this review session has no PoshQC MCP tool.
