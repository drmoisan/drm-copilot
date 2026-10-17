# PowerShell Coverage Delta, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T08-25
Command: derivation from remediation-baseline/coverage-local-baseline.2026-10-16T06-11.md, remediation-baseline/coverage-ci-baseline.2026-10-16T06-12.md, qa-gates/coverage-canonical.2026-10-16T08-24.md, qa-gates/coverage-final-c1.2026-10-16T08-23.md
EXIT_CODE: 0
Output Summary: All six rows numeric. Copy rows: .claude/hooks and .codex/hooks 99.40 -> 99.40 (local canonical and CI), changed-line coverage 3/3 each. Report rows: local canonical 94.57 -> 94.57, CI 90.41 -> 90.41; both >= 85.00. No regression.

Task: P3-T13 (remediation-plan.2026-10-16T03-39.md).

## Sources (latest file per glob)

| Role | Artifact |
|---|---|
| Local baseline | `remediation-baseline/coverage-local-baseline.2026-10-16T06-11.md` |
| CI baseline | `remediation-baseline/coverage-ci-baseline.2026-10-16T06-12.md` |
| Local post-change | `qa-gates/coverage-canonical.2026-10-16T08-24.md` |
| CI post-change | `qa-gates/coverage-final-c1.2026-10-16T08-23.md` |

The local canonical copy rows carry the per-copy values that the recorded OrchestratorDecision fixes as their source (CI artifact of run 38858408695 at baseline and run 38870746395 post-change, job `poshqc / PowerShell QC`), because the local MCP runner reads installed-extension runsettings that do not instrument the targets copies. The local report row is the repo-wide value of the local full-suite run.

## Delta table

| Row | Baseline `line_pct` | Post-change `line_pct` | Delta | Changed-line coverage (covered / instrumented) |
|---|---|---|---|---|
| Local canonical `.claude/hooks` copy | 99.40 | 99.40 | 0.00 | 3 / 3 (lines 41, 230, 231) |
| Local canonical `.codex/hooks` copy | 99.40 | 99.40 | 0.00 | 3 / 3 (lines 41, 230, 231) |
| Local canonical report | 94.57 | 94.57 | 0.00 | n/a |
| CI `.claude/hooks` copy | 99.40 | 99.40 | 0.00 | 3 / 3 (lines 41, 230, 231) |
| CI `.codex/hooks` copy | 99.40 | 99.40 | 0.00 | 3 / 3 (lines 41, 230, 231) |
| CI report | 90.41 | 90.41 | 0.00 | n/a |

Changed lines are those of the `+` ranges of `git diff -U0 <merge-base> -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` (38 to 43 and 230 to 232); of these, 41, 230, and 231 are instrumented and all three are covered. The single uncovered line in each copy (173) is not a changed line.

## Acceptance evaluation

| Condition | Result |
|---|---|
| Every value is numeric | met |
| Every copy row: covered changed lines equal instrumented changed lines | met (3 = 3, four rows) |
| Every copy row: post-change at least baseline | met (99.40 >= 99.40, four rows) |
| Both report rows at least 85.00 | met (94.57, 90.41) |

PowerShell has no branch-coverage gate (Pester does not measure branch coverage).
