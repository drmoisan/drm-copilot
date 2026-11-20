# CI Post-Change PowerShell Coverage, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T12-28
Task: P4-T12 (remediation-plan.2026-10-16T08-40.md), stage `c2final`
Command: poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/ci-c2final-windows/powershell-coverage.xml; poetry run python -I SCRATCH/jacoco_lines.py SCRATCH/ci-c2final-windows/powershell-coverage.xml 40 41 42 230 231; git diff -U0 origin/main...HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | grep "^@@"
EXIT_CODE: 0
Output Summary: Source is the poshqc-test-results artifact of job poshqc / PowerShell QC (conclusion success) in run 38898218767 (headSha 72554509671c82e39885469359a77659aecb67a7). Targets copy line coverage: .claude/hooks 99.40% (165 covered, 1 missed, uncovered line 173); .codex/hooks 99.40% (165 covered, 1 missed, uncovered line 173); each equals its c2 CI baseline (99.40). CI report line coverage 90.44% (16432 covered, 1737 missed), at least 85.00 and equal to the c2 CI baseline (90.44). Changed executable lines 41, 230, 231 covered in both packages (ci 1, 1, 2), 3 of 3; lines 40 and 42 not instrumented. Both scripts exit 0.
OrchestratorDecision: per-copy coverage read from CI artifact 38898218767; local MCP runner reads installed-extension runsettings

Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38898218767
Job poshqc / PowerShell QC conclusion (SCRATCH/ci-c2final-run.json): success

Package paths below are CI runner paths, recorded verbatim.

## Command: poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/ci-c2final-windows/powershell-coverage.xml

EXIT_CODE: 0

```text
package=D:/a/drm-copilot/drm-copilot/.claude/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
instrumented_lines=25,26,30,32,33,36,41,45,61,62,63,65,82,83,84,85,87,88,89,90,91,95,104,105,121,122,123,124,127,144,145,146,147,149,150,151,152,153,154,155,156,157,158,159,160,161,163,164,165,166,167,169,170,173,176,177,180,182,183,185,186,189,190,191,192,193,194,195,196,197,198,200,201,223,224,225,227,229,230,231,233,234,235,236,238,241,242,243,244,245,246,247,248,250,251,252,253,254,255,257,259,261,262,264,265,266,267,268,271,276,277,278,279,281,305,306,307,308,309,310,311,312,313,314,319,320,321,322,324,325,327,328,329,330,331,332,334,335,336,338,362,363,365,369,373,379,404,405,407,408,409,411,412,413,414,417,418,419,422,424,425,426,427,428,430,432
uncovered_lines=173
package=D:/a/drm-copilot/drm-copilot/.codex/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
instrumented_lines=25,26,30,32,33,36,41,45,61,62,63,65,82,83,84,85,87,88,89,90,91,95,104,105,121,122,123,124,127,144,145,146,147,149,150,151,152,153,154,155,156,157,158,159,160,161,163,164,165,166,167,169,170,173,176,177,180,182,183,185,186,189,190,191,192,193,194,195,196,197,198,200,201,223,224,225,227,229,230,231,233,234,235,236,238,241,242,243,244,245,246,247,248,250,251,252,253,254,255,257,259,261,262,264,265,266,267,268,271,276,277,278,279,281,305,306,307,308,309,310,311,312,313,314,319,320,321,322,324,325,327,328,329,330,331,332,334,335,336,338,362,363,365,369,373,379,404,405,407,408,409,411,412,413,414,417,418,419,422,424,425,426,427,428,430,432
uncovered_lines=173
REPORT line_covered=16432 line_missed=1737 line_pct=90.44
jacoco_targets EXIT=0
```

## Command: poetry run python -I SCRATCH/jacoco_lines.py SCRATCH/ci-c2final-windows/powershell-coverage.xml 40 41 42 230 231

EXIT_CODE: 0

```text
package=D:/a/drm-copilot/drm-copilot/.claude/hooks nr=40 NOT_INSTRUMENTED
package=D:/a/drm-copilot/drm-copilot/.claude/hooks nr=41 mi=0 ci=1
package=D:/a/drm-copilot/drm-copilot/.claude/hooks nr=42 NOT_INSTRUMENTED
package=D:/a/drm-copilot/drm-copilot/.claude/hooks nr=230 mi=0 ci=1
package=D:/a/drm-copilot/drm-copilot/.claude/hooks nr=231 mi=0 ci=2
package=D:/a/drm-copilot/drm-copilot/.codex/hooks nr=40 NOT_INSTRUMENTED
package=D:/a/drm-copilot/drm-copilot/.codex/hooks nr=41 mi=0 ci=1
package=D:/a/drm-copilot/drm-copilot/.codex/hooks nr=42 NOT_INSTRUMENTED
package=D:/a/drm-copilot/drm-copilot/.codex/hooks nr=230 mi=0 ci=1
package=D:/a/drm-copilot/drm-copilot/.codex/hooks nr=231 mi=0 ci=2
jacoco_lines EXIT=0
```

## Command: git diff -U0 origin/main...HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | grep "^@@"

EXIT_CODE: 0

```text
@@ -37,0 +38,6 @@ $script:OrchestrationTargetAbsolutePattern = '^([A-Za-z]:/|/(?!/))'
@@ -223,0 +230,3 @@ function Get-OrchestrationCommandTarget {
```

## Changed executable lines

Changed `+` ranges against the merge base: 38 to 43 (`+38,6`) and 230 to 232 (`+230,3`). Lines of those ranges that appear in `instrumented_lines`:

| Package | Changed executable lines | ci (jacoco_lines.py) | In uncovered_lines | Covered / changed |
|---|---|---|---|---|
| D:/a/drm-copilot/drm-copilot/.claude/hooks | 41, 230, 231 | 1, 1, 2 | none (only 173 uncovered) | 3 / 3 |
| D:/a/drm-copilot/drm-copilot/.codex/hooks | 41, 230, 231 | 1, 1, 2 | none (only 173 uncovered) | 3 / 3 |

Lines 40 and 42 (changed in this cycle: the comment and the continuation of the line 41 statement) print `NOT_INSTRUMENTED`.

## Acceptance

- Both scripts exit 0: met.
- Hunk headers begin `@@ -37,0 +38,6 @@` and `@@ -223,0 +230,3 @@`: met.
- Changed executable lines are 41, 230, 231 for both packages, each with `ci` greater than 0, and no line in 38 to 43 or 230 to 232 is in `uncovered_lines`: met.
- Each package `line_pct` (99.40) at least its c2 CI baseline (99.40, coverage-ci-baseline-c2.2026-10-16T10-33.md): met.
- `REPORT` `line_pct` (90.44) at least 85.00: met (c2 CI baseline 90.44; not below baseline).
