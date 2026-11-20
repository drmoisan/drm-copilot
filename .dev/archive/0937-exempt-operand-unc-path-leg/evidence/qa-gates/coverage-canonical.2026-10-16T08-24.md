# Canonical PowerShell Coverage Artifact, Remediation Cycle 1 (issue #937, RI-1)

Timestamp: 2026-10-16T08-24
Command: mcp__drm-copilot__run_poshqc_test with workspace_root WORKTREE and no scan_folders (final-pass P3-T3 call; no run_poshqc_test call after it)
EXIT_CODE: 0
Output Summary: Every P3-T6 acceptance condition is met using the two sources fixed by the orchestrator decision below. Repo-wide local report (full-suite MCP run): LINE covered 11613, missed 667, line_pct 94.57 (>= 85.00). Local JUnit: TESTCASES=10444, FAILED=0, SKIPPED=10 (10444 > Linux c1 baseline TESTCASES 6335). Both local file times (07-46, 07-48) are at or after RunStart 2026-10-16T07-31. Per-copy (CI run 38870746395, job poshqc / PowerShell QC, headSha ba934fd48): .claude/hooks line_pct=99.40, .codex/hooks line_pct=99.40 (baseline 99.40 each); lines 41, 230, 231 instrumented with ci > 0 in both copies; no changed line uncovered.
OrchestratorDecision: per-copy coverage read from CI artifact 38870746395; local MCP runner reads installed-extension runsettings

Task: P3-T6 (remediation-plan.2026-10-16T03-39.md), executed after P3-T12 as deferred by the orchestrator, applying the same OrchestratorDecision recorded in `remediation-baseline/coverage-local-baseline.2026-10-16T06-11.md`.

RunStart (final-pass `poshqc-test-final-c1.2026-10-16T07-49.md`): 2026-10-16T07-31

## Sources

| Value | Source |
|---|---|
| Per-copy `line_pct`, `instrumented_lines`, `uncovered_lines`, and line hits for 41, 230, 231 (`.claude/hooks`, `.codex/hooks`) | CI run 38870746395 (https://github.com/drmoisan/drm-copilot/actions/runs/38870746395), job `poshqc / PowerShell QC` (concluded `success`), artifact `poshqc-test-results` saved as `SCRATCH/ci-c1final-windows/powershell-coverage.xml`; run headSha ba934fd4864574fdf67d6b578375c38b925c53d6 (equals HEAD; the targets copies are unchanged since P2-T10) |
| Repo-wide local report value, local JUnit totals, file times (RI-1) | Local full-suite `mcp__drm-copilot__run_poshqc_test` run of P3-T3, files `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` |

Reason the per-copy values are not read locally: `mcp__drm-copilot__run_poshqc_test` resolves its Pester runsettings from the installed extension, whose `CodeCoverage.Path` file list does not include `enforce-orchestration-preimplementation-gate-targets.ps1`; the local XML has no sourcefile for any targets copy (local `jacoco_targets.py` and `jacoco_lines.py` both print `NO_MATCH`, below). No coverage configuration was edited, no XML was copied into `artifacts/pester/`, and `pwsh` was not used (Option A).

## Local file times

| Command | Output |
|---|---|
| `date -u -r artifacts/pester/powershell-coverage.xml +%Y-%m-%dT%H-%M` | 2026-10-16T07-46 |
| `date -u -r artifacts/pester/pester-junit.xml +%Y-%m-%dT%H-%M` | 2026-10-16T07-48 |

## Local: poetry run python -I SCRATCH/jacoco_targets.py artifacts/pester/powershell-coverage.xml (exit 3)

```text
NO_MATCH
```

Report LINE counter, read from the same XML (`grep -o '<counter type="LINE"[^>]*>'`, last match): `<counter type="LINE" missed="667" covered="11613" />`.

- REPORT line_covered=11613
- REPORT line_missed=667
- REPORT line_pct=94.57

## Local: poetry run python -I SCRATCH/junit_totals.py artifacts/pester/pester-junit.xml (exit 0)

```text
ROOT_TAG=testsuites
ROOT_TESTS=10444
ROOT_FAILURES=0
ROOT_ERRORS=0
TESTCASES=10444
FAILED=0
SKIPPED=10
```

## Local: poetry run python -I SCRATCH/junit_status.py artifacts/pester/pester-junit.xml (exit 0)

```text
COUNT_MATCHED=10444
COUNT_PASSED=10434
COUNT_FAILED=0
COUNT_SKIPPED=10
```

## Local: poetry run python -I SCRATCH/jacoco_lines.py artifacts/pester/powershell-coverage.xml 41 230 231 (exit 3)

```text
NO_MATCH
```

## CI: poetry run python -I SCRATCH/jacoco_lines.py SCRATCH/ci-c1final-windows/powershell-coverage.xml 41 230 231 (exit 0)

The `package=` values are the CI runner checkout path (windows-latest), recorded verbatim as printed; they contain no local host path.

```text
package=D:/a/drm-copilot/drm-copilot/.claude/hooks nr=41 mi=0 ci=1
package=D:/a/drm-copilot/drm-copilot/.claude/hooks nr=230 mi=0 ci=1
package=D:/a/drm-copilot/drm-copilot/.claude/hooks nr=231 mi=0 ci=2
package=D:/a/drm-copilot/drm-copilot/.codex/hooks nr=41 mi=0 ci=1
package=D:/a/drm-copilot/drm-copilot/.codex/hooks nr=230 mi=0 ci=1
package=D:/a/drm-copilot/drm-copilot/.codex/hooks nr=231 mi=0 ci=2
```

## CI: per-copy jacoco_targets.py values (from `coverage-final-c1.2026-10-16T08-23.md`, same XML)

```text
package=D:/a/drm-copilot/drm-copilot/.claude/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
uncovered_lines=173
package=D:/a/drm-copilot/drm-copilot/.codex/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
uncovered_lines=173
REPORT line_covered=16385 line_missed=1737 line_pct=90.41
```

The full `instrumented_lines` lists are recorded in `coverage-final-c1.2026-10-16T08-23.md`; both contain 41, 230, and 231.

## git merge-base origin/main HEAD

```text
ba53ff5694a42e975d5d1db99b2b6ef505143e66
```

## git diff -U0 ba53ff5694a42e975d5d1db99b2b6ef505143e66 -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1

Hunk headers:

```text
@@ -37,0 +38,6 @@ $script:OrchestrationTargetAbsolutePattern = '^([A-Za-z]:/|/(?!/))'
@@ -223,0 +230,3 @@ function Get-OrchestrationCommandTarget {
```

## git grep -n OrchestrationTargetNonLocalPattern -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1

```text
.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:41:$script:OrchestrationTargetNonLocalPattern = '^(?:\s|[\\/]{2}|[\\/]\?\?[\\/]|\\(?![\\/])|[A-Za-z]:(?![\\/])' +
.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:230:        if ($rawPath -match $script:OrchestrationTargetNonLocalPattern) {
```

## git grep -n path-not-local -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1

```text
.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:231:            return (New-OrchestrationTargetResult -Rule 'path-not-local' -Value $rawPath)
```

## Changed-line status per package (`.claude/hooks` and `.codex/hooks`; identical)

| Line | Status |
|---|---|
| 38 | not instrumented (comment) |
| 39 | not instrumented (comment) |
| 40 | not instrumented (comment) |
| 41 | covered |
| 42 | not instrumented (continuation of line 41 statement) |
| 43 | not instrumented (blank) |
| 230 | covered |
| 231 | covered |
| 232 | not instrumented (closing brace) |

## Acceptance evaluation

| Condition | Result |
|---|---|
| Both file times at or after RunStart 07-31 | met (07-46, 07-48) |
| `REPORT` `line_pct` at least 85.00 | met (local repo-wide 94.57; CI report 90.41) |
| `junit_totals.py` prints `FAILED=0` | met |
| `TESTCASES` greater than the Linux `TESTCASES` of the latest `ci-baseline-run.*.md` (6335) | met (10444) |
| `git grep -n` locates the assignment at 41, the guard at 230, the `return` at 231 | met |
| Lines 41, 230, 231 in `instrumented_lines` for both packages; no changed line in `uncovered_lines` | met (CI XML per OrchestratorDecision) |
| `jacoco_lines.py` prints 41, 230, 231 with `ci` greater than 0 for both packages | met (CI XML per OrchestratorDecision; local XML NO_MATCH) |
| Each package `line_pct` at least its value in the latest `coverage-local-baseline.*.md` (99.40 each) | met (99.40 each) |
