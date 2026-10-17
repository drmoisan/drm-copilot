# Local Coverage Baseline, Remediation Cycle 1 (issue #937), with CI per-copy values

Timestamp: 2026-10-16T06-11
Task: P0-T12 (remediation-plan.2026-10-16T03-39.md); supersedes `coverage-local-baseline.2026-10-16T05-52.md`
Command: date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M; date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M; poetry run python -I SCRATCH/jacoco_targets.py artifacts/pester/powershell-coverage.xml; poetry run python -I SCRATCH/junit_totals.py artifacts/pester/pester-junit.xml; poetry run python -I SCRATCH/junit_status.py artifacts/pester/pester-junit.xml; poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/ci-c1baseline-windows/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: Acceptance met using the two sources fixed by the orchestrator decision below. Per-copy (CI run 38858408695, job poshqc / PowerShell QC, headSha 879764889): .claude/hooks line_pct=99.40 (165/166), .codex/hooks line_pct=99.40 (165/166), CI REPORT line_pct=90.41; jacoco_targets.py exit 0. Repo-wide local report (full-suite MCP run, artifacts/pester/powershell-coverage.xml): LINE covered 11613, missed 667, 94.57% (>= 85.00). Local JUnit: TESTCASES=10422, FAILED=0, SKIPPED=10. Both local file times are at or after RunStart 2026-10-16T05-33.
OrchestratorDecision: per-copy coverage read from CI artifact 38858408695; local MCP runner reads installed-extension runsettings

RunStart (from latest poshqc-test-baseline.*.md): 2026-10-16T05-33

## Sources

| Value | Source |
|---|---|
| Per-copy `line_pct`, `instrumented_lines`, `uncovered_lines` (`.claude/hooks`, `.codex/hooks`) | CI run 38858408695 (https://github.com/drmoisan/drm-copilot/actions/runs/38858408695), job `poshqc / PowerShell QC` (concluded `success`), artifact `poshqc-test-results` saved as `SCRATCH/ci-c1baseline-windows/powershell-coverage.xml`; run headSha 879764889bec9244657f348c17a23d34218f0401 (equals the P0-T15 commit) |
| Repo-wide local report value, local JUnit totals, file times (RI-1) | Local full-suite `mcp__drm-copilot__run_poshqc_test` run of P0-T11, files `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` |

Reason the per-copy values are not read locally: `mcp__drm-copilot__run_poshqc_test` resolves its Pester runsettings from the installed extension, whose `CodeCoverage.Path` file list does not include `enforce-orchestration-preimplementation-gate-targets.ps1`; the local XML therefore has no sourcefile for any targets copy (see the local `jacoco_targets.py` result below). No coverage configuration was edited and `pwsh` was not used (Option A).

## Local file times

| File | UTC mtime |
|---|---|
| `artifacts/pester/powershell-coverage.xml` | 2026-10-16T05-49 |
| `artifacts/pester/pester-junit.xml` | 2026-10-16T05-51 |

Both are at or after RunStart 2026-10-16T05-33.

## Local: jacoco_targets.py artifacts/pester/powershell-coverage.xml (exit 3)

```text
NO_MATCH
```

Repo-wide local report counter, read from the same XML (`grep -o '<counter type="LINE"[^>]*>'`, last match): `<counter type="LINE" missed="667" covered="11613" />`, line_pct 94.57.

## Local: junit_totals.py artifacts/pester/pester-junit.xml (exit 0)

```text
ROOT_TAG=testsuites
ROOT_TESTS=10422
ROOT_FAILURES=0
ROOT_ERRORS=0
TESTCASES=10422
FAILED=0
SKIPPED=10
```

## Local: junit_status.py artifacts/pester/pester-junit.xml, no filters (exit 0)

```text
COUNT_MATCHED=10422
COUNT_PASSED=10412
COUNT_FAILED=0
COUNT_SKIPPED=10
```

## CI: jacoco_targets.py SCRATCH/ci-c1baseline-windows/powershell-coverage.xml (exit 0)

The `package=` values are the CI runner checkout path (windows-latest), recorded verbatim as printed.

```text
package=D:/a/drm-copilot/drm-copilot/.claude/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
instrumented_lines=25,26,30,32,33,36,40,43,59,60,61,63,80,81,82,83,85,86,87,88,89,93,102,103,119,120,121,122,125,142,143,144,145,147,148,149,150,151,152,153,154,155,156,157,158,159,161,162,163,164,165,167,168,171,174,175,178,180,181,183,184,187,188,189,190,191,192,193,194,195,196,198,199,221,222,223,225,227,228,229,231,232,233,234,236,239,240,241,242,243,244,245,246,248,249,250,251,252,253,255,257,259,260,262,263,264,265,266,269,274,275,276,277,279,303,304,305,306,307,308,309,310,311,312,317,318,319,320,322,323,325,326,327,328,329,330,332,333,334,336,360,361,363,367,371,377,402,403,405,406,407,409,410,411,412,415,416,417,420,422,423,424,425,426,428,430
uncovered_lines=171
package=D:/a/drm-copilot/drm-copilot/.codex/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
instrumented_lines=25,26,30,32,33,36,40,43,59,60,61,63,80,81,82,83,85,86,87,88,89,93,102,103,119,120,121,122,125,142,143,144,145,147,148,149,150,151,152,153,154,155,156,157,158,159,161,162,163,164,165,167,168,171,174,175,178,180,181,183,184,187,188,189,190,191,192,193,194,195,196,198,199,221,222,223,225,227,228,229,231,232,233,234,236,239,240,241,242,243,244,245,246,248,249,250,251,252,253,255,257,259,260,262,263,264,265,266,269,274,275,276,277,279,303,304,305,306,307,308,309,310,311,312,317,318,319,320,322,323,325,326,327,328,329,330,332,333,334,336,360,361,363,367,371,377,402,403,405,406,407,409,410,411,412,415,416,417,420,422,423,424,425,426,428,430
uncovered_lines=171
REPORT line_covered=16385 line_missed=1737 line_pct=90.41
```

## Acceptance evaluation

| Condition | Result |
|---|---|
| Both local file times at or after RunStart | met (05-49, 05-51 >= 05-33) |
| `jacoco_targets.py` exits 0 with a `.claude/hooks` and a `.codex/hooks` `package=` line, each with numeric `line_pct` | met from CI artifact 38858408695 (99.40, 99.40) |
| A `REPORT` line with numeric `line_pct` | met: CI REPORT 90.41; repo-wide local report 94.57 |
| `junit_totals.py` prints `FAILED=0` | met (local) |
| Stop condition: `FAILED` not 0, or report `line_pct` below 85.00 | not triggered |

## Baseline values carried forward

- Per-copy baseline for P3-T6 and P3-T13 copy rows: `.claude/hooks` 99.40, `.codex/hooks` 99.40 (CI artifact 38858408695).
- Repo-wide local report baseline for P3-T13 local report row: 94.57 (local full-suite run).
