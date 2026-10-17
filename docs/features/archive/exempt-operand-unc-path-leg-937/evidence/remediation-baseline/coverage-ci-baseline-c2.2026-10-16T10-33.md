# CI Baseline PowerShell Coverage, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T10-33
Task: P0-T16 (remediation-plan.2026-10-16T08-40.md), stage `c2baseline`
Command: poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/ci-c2baseline-windows/powershell-coverage.xml; poetry run python -I SCRATCH/jacoco_lines.py SCRATCH/ci-c2baseline-windows/powershell-coverage.xml 40 41 42 230 231
EXIT_CODE: 0
Output Summary: Source is the poshqc-test-results artifact of job poshqc / PowerShell QC (conclusion success) in run 38885695856 (headSha 1d09122061149af971b5acdff3d2ddb9f53b8fdc). Targets copy line coverage: .claude/hooks 99.40% (165 covered, 1 missed, uncovered line 173); .codex/hooks 99.40% (165 covered, 1 missed, uncovered line 173). CI report line coverage 90.44% (16432 covered, 1737 missed). Lines 41, 230, 231 covered in both packages (ci 1, 1, 2); lines 40 and 42 not instrumented. Both scripts exit 0.
OrchestratorDecision: per-copy coverage read from CI artifact 38885695856; local MCP runner reads installed-extension runsettings

Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38885695856
Job poshqc / PowerShell QC conclusion (SCRATCH/ci-c2baseline-run.json): success

Package paths below are CI runner paths, recorded verbatim.

## Command: poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/ci-c2baseline-windows/powershell-coverage.xml

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

## Command: poetry run python -I SCRATCH/jacoco_lines.py SCRATCH/ci-c2baseline-windows/powershell-coverage.xml 40 41 42 230 231

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

## Acceptance

- Both scripts exit 0: met.
- A package value ending in `/.claude/hooks` and one ending in `/.codex/hooks`, each with numeric `line_pct` (99.40 each; cycle 1 recorded 99.40): met.
- `REPORT` line with numeric `line_pct` (90.44): met.
- Lines 41, 230, 231 with `ci` greater than 0 for both packages: met.
