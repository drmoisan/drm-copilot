# CI Post-Change PowerShell Coverage, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T08-23
Command: poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/ci-c1final-windows/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: CI run 38870746395 (https://github.com/drmoisan/drm-copilot/actions/runs/38870746395), job poshqc / PowerShell QC (success), headSha ba934fd48. Targets copy coverage: .claude/hooks line_pct=99.40 (165 covered, 1 missed; uncovered line 173), .codex/hooks line_pct=99.40 (165 covered, 1 missed; uncovered line 173). REPORT line_covered=16385 line_missed=1737 line_pct=90.41. Changed lines 41, 230, 231 are instrumented and covered in both copies; no changed line is uncovered.

Task: P3-T12 (remediation-plan.2026-10-16T03-39.md). The `poshqc-test-results` artifact was downloaded by the orchestrator during the P3-T11 handoff to `SCRATCH/ci-c1final-windows`. Job `poshqc / PowerShell QC` concluded `success` in `SCRATCH/ci-c1final-run.json`.

The `package=` values are the CI runner checkout path (windows-latest), recorded verbatim as printed.

## Output: jacoco_targets.py (exit 0)

```text
package=D:/a/drm-copilot/drm-copilot/.claude/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
instrumented_lines=25,26,30,32,33,36,41,45,61,62,63,65,82,83,84,85,87,88,89,90,91,95,104,105,121,122,123,124,127,144,145,146,147,149,150,151,152,153,154,155,156,157,158,159,160,161,163,164,165,166,167,169,170,173,176,177,180,182,183,185,186,189,190,191,192,193,194,195,196,197,198,200,201,223,224,225,227,229,230,231,233,234,235,236,238,241,242,243,244,245,246,247,248,250,251,252,253,254,255,257,259,261,262,264,265,266,267,268,271,276,277,278,279,281,305,306,307,308,309,310,311,312,313,314,319,320,321,322,324,325,327,328,329,330,331,332,334,335,336,338,362,363,365,369,373,379,404,405,407,408,409,411,412,413,414,417,418,419,422,424,425,426,427,428,430,432
uncovered_lines=173
package=D:/a/drm-copilot/drm-copilot/.codex/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
instrumented_lines=25,26,30,32,33,36,41,45,61,62,63,65,82,83,84,85,87,88,89,90,91,95,104,105,121,122,123,124,127,144,145,146,147,149,150,151,152,153,154,155,156,157,158,159,160,161,163,164,165,166,167,169,170,173,176,177,180,182,183,185,186,189,190,191,192,193,194,195,196,197,198,200,201,223,224,225,227,229,230,231,233,234,235,236,238,241,242,243,244,245,246,247,248,250,251,252,253,254,255,257,259,261,262,264,265,266,267,268,271,276,277,278,279,281,305,306,307,308,309,310,311,312,313,314,319,320,321,322,324,325,327,328,329,330,331,332,334,335,336,338,362,363,365,369,373,379,404,405,407,408,409,411,412,413,414,417,418,419,422,424,425,426,427,428,430,432
uncovered_lines=173
REPORT line_covered=16385 line_missed=1737 line_pct=90.41
```

## Command: git diff -U0 origin/main...HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1

EXIT_CODE: 0

Hunk headers:

```text
@@ -37,0 +38,6 @@ $script:OrchestrationTargetAbsolutePattern = '^([A-Za-z]:/|/(?!/))'
@@ -223,0 +230,3 @@ function Get-OrchestrationCommandTarget {
```

Changed line numbers derived from the `+` ranges: 38, 39, 40, 41, 42, 43 (`+38,6`) and 230, 231, 232 (`+230,3`).

## Changed-line status (both `.claude/hooks` and `.codex/hooks` packages; the instrumented line lists are identical)

| Line | Content | Status |
|---|---|---|
| 38 | comment | not instrumented |
| 39 | comment | not instrumented |
| 40 | comment | not instrumented |
| 41 | `$script:OrchestrationTargetNonLocalPattern = ... +` | covered |
| 42 | `'|file:|~)|\s$'` (continuation of the line 41 statement) | not instrumented |
| 43 | blank | not instrumented |
| 230 | `if ($rawPath -match $script:OrchestrationTargetNonLocalPattern) {` | covered |
| 231 | `return (New-OrchestrationTargetResult -Rule 'path-not-local' -Value $rawPath)` | covered |
| 232 | `}` | not instrumented |

Instrumented changed lines: 3 per copy; covered: 3 per copy. The single uncovered line, 173, is not a changed line (it is baseline line 171 shifted by the two net lines added above it).

## Acceptance evaluation

| Condition | Result |
|---|---|
| Script exits 0 | met |
| Lines 41, 230, 231 in `instrumented_lines` for `.claude/hooks` and `.codex/hooks` | met |
| No changed line in `uncovered_lines` | met (uncovered: 173 only) |
| `.claude/hooks` `line_pct` at least c1 baseline (99.40, `coverage-ci-baseline.2026-10-16T06-12.md`) | met (99.40) |
| `.codex/hooks` `line_pct` at least c1 baseline (99.40) | met (99.40) |
| `REPORT` `line_pct` at least 85.00 | met (90.41; equal to the c1 baseline 90.41) |
