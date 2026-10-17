# CI Baseline PowerShell Coverage, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T06-12
Command: poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/ci-c1baseline-windows/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: CI run 38858408695 (https://github.com/drmoisan/drm-copilot/actions/runs/38858408695), job poshqc / PowerShell QC (success), headSha 879764889. Targets copy coverage: .claude/hooks line_pct=99.40 (165 covered, 1 missed; uncovered line 171), .codex/hooks line_pct=99.40 (165 covered, 1 missed; uncovered line 171). REPORT line_covered=16385 line_missed=1737 line_pct=90.41.

Task: P0-T17 (remediation-plan.2026-10-16T03-39.md). The `poshqc-test-results` artifact was downloaded by the orchestrator during the P0-T16 handoff to `SCRATCH/ci-c1baseline-windows`. Job `poshqc / PowerShell QC` concluded `success` in `SCRATCH/ci-c1baseline-run.json`.

The `package=` values are the CI runner checkout path (windows-latest), recorded verbatim as printed.

## Output

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
| Script exits 0 | met |
| Numeric `line_pct` for `.claude/hooks` copy | 99.40 |
| Numeric `line_pct` for `.codex/hooks` copy | 99.40 |
| Numeric `REPORT` `line_pct` | 90.41 |
