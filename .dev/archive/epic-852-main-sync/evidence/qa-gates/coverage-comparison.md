# Coverage Comparison (baseline vs post-change)

Timestamp: 2026-10-11T00-42
Task: [P3-T7]
Command: comparison of R-COV output recorded in [P0-T9] (`evidence/baseline/p0-pester-coverage.md`) and [P3-T5] (`evidence/qa-gates/final-pester-coverage.md`)
EXIT_CODE: 0

| File | Baseline ([P0-T9]) | Post-change ([P3-T5]) | Threshold |
| --- | --- | --- | --- |
| `.claude/hooks/validate-feature-review-coverage.ps1` | 97.22 (covered=210, missed=6) | 98.62 (covered=215, missed=3) | >= 85.00 met |
| `.codex/hooks/validate-feature-review-coverage.ps1` | 99.29 (covered=140, missed=1) | 99.29 (covered=140, missed=1) | >= 85.00 met (unchanged file) |
| `.claude/hooks/feature-review-coverage-thresholds.ps1` | BASELINE: none (file new to the branch via the merge) | 100.00 (covered=21, missed=0) | >= 85.00 met |

Changed-line coverage (guarded line, `.claude/hooks/validate-feature-review-coverage.ps1:47`): ci=3, mi=0 (covered).

Overall coverage:

- Console command coverage: baseline 87.07%, post-change 89.16%.
- XML report LINE counter: baseline 87.97% (covered=15570, missed=2129), post-change 90.43% (covered=16116, missed=1705).

MIRROR-COVERAGE: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1` is outside the `config/poshqc-coverage.json` roots (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`) and is SHA256-equal to the measured `.claude/hooks` copy (BF8D4346AFDB17F2D51A98B3CB2D0904D9DF88D393969DE129DFDBFE59D94072, from [P3-T8]).

Output Summary: Claude hook 97.22 -> 98.62; Codex hook 99.29 -> 99.29; thresholds file 100.00 (new via merge); guarded line covered (ci=3, mi=0); overall 87.07% -> 89.16% (command) and 87.97% -> 90.43% (line). All post-change percents for changed PowerShell files are at least 85.00.
