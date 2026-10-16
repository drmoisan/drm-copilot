# Coverage Delta, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T12-29
Task: P4-T13 (remediation-plan.2026-10-16T08-40.md)
Command: derived from recorded artifacts (no command run): remediation-baseline/coverage-local-baseline-c2.2026-10-16T10-04.md, remediation-baseline/coverage-ci-baseline-c2.2026-10-16T10-33.md, qa-gates/coverage-canonical-c2.2026-10-16T11-57.md, qa-gates/coverage-final-c2.2026-10-16T12-28.md
EXIT_CODE: 0
Output Summary: Local report 94.58 -> 94.58; CI .claude/hooks copy 99.40 -> 99.40 (changed lines 3 of 3 covered); CI .codex/hooks copy 99.40 -> 99.40 (changed lines 3 of 3 covered); CI report 90.44 -> 90.44. All values numeric, no regression, both report rows at least 85.00. PowerShell has no branch-coverage gate (Pester does not measure branch coverage).
OrchestratorDecision: per-copy coverage read from CI artifact 38898218767; local MCP runner reads installed-extension runsettings

## Delta table

| Row | Baseline line_pct | Baseline source | Post-change line_pct | Post-change source | Changed-line coverage |
|---|---|---|---|---|---|
| Local repo-wide report | 94.58 (11629 covered, 667 missed) | coverage-local-baseline-c2.2026-10-16T10-04.md | 94.58 (11629 covered, 667 missed) | coverage-canonical-c2.2026-10-16T11-57.md | n/a |
| CI `.claude/hooks` targets copy | 99.40 (165 covered, 1 missed) | coverage-ci-baseline-c2.2026-10-16T10-33.md (run 38885695856) | 99.40 (165 covered, 1 missed) | coverage-final-c2.2026-10-16T12-28.md (run 38898218767) | 3 / 3 (lines 41, 230, 231) |
| CI `.codex/hooks` targets copy | 99.40 (165 covered, 1 missed) | coverage-ci-baseline-c2.2026-10-16T10-33.md (run 38885695856) | 99.40 (165 covered, 1 missed) | coverage-final-c2.2026-10-16T12-28.md (run 38898218767) | 3 / 3 (lines 41, 230, 231) |
| CI report | 90.44 (16432 covered, 1737 missed) | coverage-ci-baseline-c2.2026-10-16T10-33.md (run 38885695856) | 90.44 (16432 covered, 1737 missed) | coverage-final-c2.2026-10-16T12-28.md (run 38898218767) | n/a |

The local report has no row for the targets copies: the local MCP runner's installed-extension runsettings omit the targets file (`jacoco_targets.py` prints `NO_MATCH`, exit 3), so per-copy values come only from CI, as recorded by the OrchestratorDecision.

## Acceptance

- Every value is numeric: met.
- Each copy row: covered changed executable lines equal changed executable lines (3 of 3), and post-change 99.40 is at least baseline 99.40: met.
- Both report rows at least 85.00 (local 94.58, CI 90.44): met.
- Branch coverage: not applicable to PowerShell.
