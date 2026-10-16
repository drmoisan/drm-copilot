# Post-change PowerShell coverage (P3-T11)

Timestamp: 2026-10-16T03-32
Command: poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/ci-final-windows/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: Post-change line coverage from CI run 38844097853 (job `poshqc / PowerShell QC`, conclusion success, headSha fd138e1ca59604664df87e14b44df5e1a15cb7c2): `.claude/hooks` targets copy 99.40% (165/166, uncovered line 171); `.codex/hooks` targets copy 99.40% (165/166, uncovered line 171); report total 90.41% (16385 covered, 1737 missed). Changed executable lines 40, 228, 229 are instrumented and covered in both copies.

## Source

- Run: https://github.com/drmoisan/drm-copilot/actions/runs/38844097853 (databaseId 38844097853 from SCRATCH/ci-final-run.json)
- Artifact: `poshqc-test-results`, downloaded by the orchestrator to SCRATCH/ci-final-windows
- Job `poshqc / PowerShell QC` conclusion: success

## Printed lines (verbatim)

The `package=` values are the CI runner checkout path (windows-latest), not a local host path.

```
package=D:/a/drm-copilot/drm-copilot/.claude/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
instrumented_lines=25,26,30,32,33,36,40,43,59,60,61,63,80,81,82,83,85,86,87,88,89,93,102,103,119,120,121,122,125,142,143,144,145,147,148,149,150,151,152,153,154,155,156,157,158,159,161,162,163,164,165,167,168,171,174,175,178,180,181,183,184,187,188,189,190,191,192,193,194,195,196,198,199,221,222,223,225,227,228,229,231,232,233,234,236,239,240,241,242,243,244,245,246,248,249,250,251,252,253,255,257,259,260,262,263,264,265,266,269,274,275,276,277,279,303,304,305,306,307,308,309,310,311,312,317,318,319,320,322,323,325,326,327,328,329,330,332,333,334,336,360,361,363,367,371,377,402,403,405,406,407,409,410,411,412,415,416,417,420,422,423,424,425,426,428,430
uncovered_lines=171
package=D:/a/drm-copilot/drm-copilot/.codex/hooks file=enforce-orchestration-preimplementation-gate-targets.ps1 line_covered=165 line_missed=1 line_pct=99.40
instrumented_lines=25,26,30,32,33,36,40,43,59,60,61,63,80,81,82,83,85,86,87,88,89,93,102,103,119,120,121,122,125,142,143,144,145,147,148,149,150,151,152,153,154,155,156,157,158,159,161,162,163,164,165,167,168,171,174,175,178,180,181,183,184,187,188,189,190,191,192,193,194,195,196,198,199,221,222,223,225,227,228,229,231,232,233,234,236,239,240,241,242,243,244,245,246,248,249,250,251,252,253,255,257,259,260,262,263,264,265,266,269,274,275,276,277,279,303,304,305,306,307,308,309,310,311,312,317,318,319,320,322,323,325,326,327,328,329,330,332,333,334,336,360,361,363,367,371,377,402,403,405,406,407,409,410,411,412,415,416,417,420,422,423,424,425,426,428,430
uncovered_lines=171
REPORT line_covered=16385 line_missed=1737 line_pct=90.41
```

## Changed-line diff

Command: git diff -U0 origin/main...HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
EXIT_CODE: 0

Hunk headers (verbatim):

```
@@ -37,0 +38,4 @@ $script:OrchestrationTargetAbsolutePattern = '^([A-Za-z]:/|/(?!/))'
@@ -223,0 +228,3 @@ function Get-OrchestrationCommandTarget {
```

Added lines: `+38,4` covers lines 38 to 41 (two comment lines, line 40 the `$script:OrchestrationTargetNonLocalPattern` assignment, one blank line); `+228,3` covers lines 228 to 230 (line 228 the `if`, line 229 the `return`, line 230 the closing brace).

Changed executable line numbers: 40 (assignment), 228 (`if`), 229 (`return`). The `.codex/hooks` copy is byte-identical (targets-mirror-identity, targets-eol-parity), so the same numbers apply to it.

Membership check (mechanical): `jacoco_targets.py ... | grep '^instrumented_lines=' | tr '=,' '\n\n' | grep -nxE '40|228|229'` printed `40`, `228`, `229` once per copy (six lines). None of 40, 228, 229 appears in `uncovered_lines` (`171` only).

## Acceptance

| Condition | Observed | Result |
|---|---|---|
| Script exits 0 | EXIT_CODE 0 | met |
| `.claude/hooks`: `if` (228) and `return` (229) in `instrumented_lines` | both present | met |
| `.codex/hooks`: `if` (228) and `return` (229) in `instrumented_lines` | both present | met |
| No changed executable line (40, 228, 229) in `uncovered_lines` | uncovered is 171 only, in both copies | met |
| `.claude/hooks` `line_pct` >= baseline 99.39 | 99.40 | met |
| `.codex/hooks` `line_pct` >= baseline 99.39 | 99.40 | met |
| REPORT `line_pct` >= 85.00 | 90.41 | met |

Line 171 is the pre-existing uncovered line recorded as 167 in `coverage-baseline.2026-10-16T01-33.md`, shifted by the 4 lines added at 38 to 41.

PowerShell has no branch-coverage gate (Pester does not measure branch coverage).
