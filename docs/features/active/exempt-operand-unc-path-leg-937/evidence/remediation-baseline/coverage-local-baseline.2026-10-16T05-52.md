# Local Coverage Baseline, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T05-52
Task: P0-T12 (remediation-plan.2026-10-16T03-39.md)
Command: date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M; date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M; poetry run python -I SCRATCH/jacoco_targets.py artifacts/pester/powershell-coverage.xml; poetry run python -I SCRATCH/junit_totals.py artifacts/pester/pester-junit.xml; poetry run python -I SCRATCH/junit_status.py artifacts/pester/pester-junit.xml
EXIT_CODE: 3
Output Summary: ACCEPTANCE NOT MET. jacoco_targets.py printed NO_MATCH and exited 3: the local full-suite coverage XML contains no sourcefile for enforce-orchestration-preimplementation-gate-targets.ps1 on any surface, so no package= lines and no REPORT line were printed. JUnit: TESTCASES=10422, FAILED=0, SKIPPED=10. Report-level LINE counter read directly from the XML: covered 11613, missed 667 (94.57%), 127 sourcefiles. Both file times are at or after RunStart 2026-10-16T05-33.

RunStart (from latest poshqc-test-baseline.*.md): 2026-10-16T05-33

| File | UTC mtime |
|---|---|
| `artifacts/pester/powershell-coverage.xml` | 2026-10-16T05-49 |
| `artifacts/pester/pester-junit.xml` | 2026-10-16T05-51 |

## jacoco_targets.py (exit 3)

```text
NO_MATCH
```

## junit_totals.py (exit 0)

```text
ROOT_TAG=testsuites
ROOT_TESTS=10422
ROOT_FAILURES=0
ROOT_ERRORS=0
TESTCASES=10422
FAILED=0
SKIPPED=10
```

## junit_status.py, no filters (exit 0)

```text
COUNT_MATCHED=10422
COUNT_PASSED=10412
COUNT_FAILED=0
COUNT_SKIPPED=10
```

## Supplementary observation (read-only; not a plan command)

- Report-level counter from `artifacts/pester/powershell-coverage.xml` (`grep -o '<counter type="LINE"[^>]*>'`, last match): `<counter type="LINE" missed="667" covered="11613" />` = 94.57%. Sourcefile count: 127. Packages present include `WORKTREE/.claude/hooks` and `WORKTREE/.codex/hooks`, but neither lists `enforce-orchestration-preimplementation-gate-targets.ps1`.
- Cause (verified by reading settings files): `mcp__drm-copilot__run_poshqc_test` resolves its Pester runsettings from the installed extension (`danmoisan.drm-copilot-1.1.18`), whose `CodeCoverage.Path` is an explicit file list that does not include the targets file. The in-repo `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` has no Path list and derives the population from `config/poshqc-coverage.json` (the population CI measures, 203 sourcefiles including both targets copies). The cycle 0 66.04% figure (8110 / 12280) was measured on the same 12280-line installed-extension population.

## Deviation

P0-T12 acceptance requires two `package=` lines (`.claude/hooks`, `.codex/hooks`) with numeric `line_pct` and a `REPORT` line from `jacoco_targets.py`. These cannot be produced by the MCP runner under Option A without changing coverage configuration or using the self-hosted module through `pwsh`, both of which the plan and the coordinator exclude. The task is left unchecked. The plan's explicit stop conditions for this task (FAILED not 0, or REPORT line_pct below 85.00) are not triggered: FAILED=0 and the report-level counter reads 94.57%. The same limitation will apply to the per-package conditions of P3-T6 and to the local rows of P3-T13. Reported to the caller.
