# Baseline PowerShell coverage (P0-T13)

Timestamp: 2026-10-16T01-33
Command: poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/ci-baseline-windows/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: Baseline line coverage from CI run 38833589314 (job `poshqc / PowerShell QC`, conclusion success, headSha 2fe0469956f4a3ce916e31350d5090bd1097b9d6): `.claude/hooks` targets copy 99.39% (162/163, uncovered line 167); `.codex/hooks` targets copy 99.39% (162/163, uncovered line 167); report total 90.42% (16381 covered, 1735 missed).

## Source

- Run: https://github.com/drmoisan/drm-copilot/actions/runs/38833589314 (databaseId 38833589314 from SCRATCH/ci-baseline-run.json)
- Artifact: `poshqc-test-results`, downloaded by the orchestrator to SCRATCH/ci-baseline-windows
- Job `poshqc / PowerShell QC` conclusion: success

## Printed lines (verbatim)

The `package=` values are the CI runner checkout path (windows-latest), not a local host path.

```
package=D:/a/drm-copilot/drm-copilot/.claude/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=162 line_missed=1 line_pct=99.39
instrumented_lines=25,26,30,32,33,36,39,55,56,57,59,76,77,78,79,81,82,83,84,85,89,98,99,115,116,117,118,121,138,139,140,141,143,144,145,146,147,148,149,150,151,152,153,154,155,157,158,159,160,161,163,164,167,170,171,174,176,177,179,180,183,184,185,186,187,188,189,190,191,192,194,195,217,218,219,221,223,224,225,226,227,229,232,233,234,235,236,237,238,239,241,242,243,244,245,246,248,250,252,253,255,256,257,258,259,262,267,268,269,270,272,296,297,298,299,300,301,302,303,304,305,310,311,312,313,315,316,318,319,320,321,322,323,325,326,327,329,353,354,356,360,364,370,395,396,398,399,400,402,403,404,405,408,409,410,413,415,416,417,418,419,421,423
uncovered_lines=167
package=D:/a/drm-copilot/drm-copilot/.codex/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=162 line_missed=1 line_pct=99.39
instrumented_lines=25,26,30,32,33,36,39,55,56,57,59,76,77,78,79,81,82,83,84,85,89,98,99,115,116,117,118,121,138,139,140,141,143,144,145,146,147,148,149,150,151,152,153,154,155,157,158,159,160,161,163,164,167,170,171,174,176,177,179,180,183,184,185,186,187,188,189,190,191,192,194,195,217,218,219,221,223,224,225,226,227,229,232,233,234,235,236,237,238,239,241,242,243,244,245,246,248,250,252,253,255,256,257,258,259,262,267,268,269,270,272,296,297,298,299,300,301,302,303,304,305,310,311,312,313,315,316,318,319,320,321,322,323,325,326,327,329,353,354,356,360,364,370,395,396,398,399,400,402,403,404,405,408,409,410,413,415,416,417,418,419,421,423
uncovered_lines=167
REPORT line_covered=16381 line_missed=1735 line_pct=90.42
```

## Baseline values

| Scope | line_pct |
|---|---|
| `.claude/hooks` targets copy | 99.39 |
| `.codex/hooks` targets copy | 99.39 |
| Report | 90.42 |

PowerShell has no branch-coverage gate (Pester does not measure branch coverage).
