# P8-T4 Coverage delta (issue #927)

Timestamp: 2026-10-16T13-31
Command: Coverage delta from p0-ci-coverage-baseline and p8-ci-coverage
EXIT_CODE: 0
Output Summary: All five files of [P0-T12] are at or above their baseline line coverage and at or above 85% post-change (docs-only 93.44 -> 100.0; pr-author 92.98 -> 92.98; Claude merge gate 99.25 -> 99.29; resolution sibling 95.24 -> 95.65; Codex merge gate 87.9 -> 88.41). Helper copies 97.6% each. Changed-line coverage: docs-only 8/8, pr-author N/A (0 executable changed lines), Claude merge gate 8/8, resolution 4/4, Codex merge gate 8/9 (88.89%; the uncovered line is the permitted entry-point statement 403).

Inputs:
- Baseline: `FEATURE/evidence/baseline/p0-ci-coverage-baseline.2026-10-16T00-48.md` (CI run 38730332356, merge-base head adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99). Baseline is available (not UNAVAILABLE).
- Post-change: `FEATURE/evidence/qa-gates/p8-ci-coverage.2026-10-16T13-30.md` (CI run 38905372728, PR head f82da3681f059f437573bf3b773f9a72a77b592b).

## Five files of [P0-T12]

| File | Baseline covered/missed/line_pct | Post covered/missed/line_pct | Post >= baseline or >= 85% |
|---|---|---|---|
| .claude/hooks/enforce-pr-author-skill.docs-only.ps1 | 57 / 4 / 93.44 | 54 / 0 / 100.0 | yes (both) |
| .claude/hooks/enforce-pr-author-skill.ps1 | 53 / 4 / 92.98 | 53 / 4 / 92.98 | yes (both) |
| .claude/hooks/enforce-epic-merge-gate.ps1 | 132 / 1 / 99.25 | 139 / 1 / 99.29 | yes (both) |
| .claude/hooks/enforce-epic-merge-gate-resolution.ps1 | 40 / 2 / 95.24 | 44 / 2 / 95.65 | yes (both) |
| .codex/hooks/enforce-epic-merge-gate.ps1 | 138 / 19 / 87.9 | 145 / 19 / 88.41 | yes (both) |

## Helper copies (new files; post-change only)

| File | Post covered/missed/line_pct |
|---|---|
| .claude/hooks/hook-docs-only-diff.ps1 | 122 / 3 / 97.6 |
| .codex/hooks/hook-docs-only-diff.ps1 | 122 / 3 / 97.6 |

## Changed-line coverage (five edited canonical hook files)

CHANGED_LINE_COVERAGE: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 8/8 (100.00%)
CHANGED_LINE_COVERAGE: .claude/hooks/enforce-pr-author-skill.ps1 N/A (0 executable changed lines)
CHANGED_LINE_COVERAGE: .claude/hooks/enforce-epic-merge-gate.ps1 8/8 (100.00%)
CHANGED_LINE_COVERAGE: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 4/4 (100.00%)
CHANGED_LINE_COVERAGE: .codex/hooks/enforce-epic-merge-gate.ps1 8/9 (88.89%; uncovered line 403 recorded as UNCOVERED_CHANGED_LINE in p8-ci-coverage)

Each file's changed-line coverage is at least 85% or N/A with 0 executable changed lines.

COVERAGE_DELTA: SATISFIED
