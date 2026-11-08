# CI Pending (issue 1024)

Timestamp: 2026-11-04T04-33
Task: [P9-T9]
Command: none (record of the CI-dependent criterion AC-27 for the pull-request head; contexts taken from the execution-environment brief `## CI Shape and Required Checks` and ruleset 15241672 as relayed by the orchestrator)
EXIT_CODE: 0
Output Summary: AC-27 is pending-CI. Five contexts are recorded with status pending-CI. The plan's quality-checks7 / Code Quality & Tests (3.10) is not a context of ruleset 15241672 or of ci.yml (matrix 3.11, 3.12, 3.13) and is replaced by the real contexts. AC-27 stays unchecked until the orchestrator observes success on the pull-request head.

## Contexts

| Context | Runner and role | Status |
|---|---|---|
| `poshqc / PowerShell QC` | aggregating required check over `poshqc / PowerShell QC shard 1`, `shard 2` and `shard 3` on `windows-latest` (Pester with coverage, shard completeness, merged coverage) | pending-CI |
| `poshqc / PowerShell QC static` | format and analyze on `windows-latest` | pending-CI |
| `quality-checks7 / Code Quality & Tests (3.11)` | Python quality checks | pending-CI |
| `quality-checks7 / Code Quality & Tests (3.12)` | Python quality checks | pending-CI |
| `quality-checks7 / Code Quality & Tests (3.13)` | Python quality checks with coverage | pending-CI |

The shard jobs `poshqc / PowerShell QC shard 1`, `shard 2` and `shard 3` are covered through the aggregating check, which requires each of them to succeed.

## Correction

The plan text of [P9-T9] names `quality-checks7 / Code Quality & Tests (3.10)`. Ruleset 15241672 lists `quality-checks7 / Code Quality & Tests (3.11)`, `(3.12)` and `(3.13)` only, and `_quality-checks.yml` runs no 3.10 matrix entry, so a 3.10 context is never reported. This record lists the three real contexts in its place.

## Not applicable

`poshqc / PowerShell hook suites (Linux)` runs only `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` and does not run this feature's suites; it is not cited for AC-27.
