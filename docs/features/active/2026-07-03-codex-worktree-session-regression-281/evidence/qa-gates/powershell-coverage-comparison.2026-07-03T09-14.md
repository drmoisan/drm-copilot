Timestamp: 2026-07-03T09-14
Command: Compare PowerShell baseline coverage evidence against final PowerShell coverage evidence.
EXIT_CODE: 0
Output Summary: PowerShell coverage comparison passed. Baseline repository-wide line coverage: 92.92%. Final repository-wide line coverage: 92.92%. Baseline focused changed-script coverage was 0.00% because the tracked post-Codex script was not present in baseline coverage XML. Final supplemental focused changed-script command coverage is 79.34% (121 analyzed, 96 executed, 25 missed), above the Pester focused command-coverage target of 75%. Threshold verdict: PASS.

Baseline Evidence:
- docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/baseline/powershell-test-coverage.2026-07-03T09-14.md

Final Evidence:
- docs/features/active/2026-07-03-codex-worktree-session-regression-281/evidence/qa-gates/powershell-test-coverage-final.2026-07-03T09-14.md

Coverage Comparison:
```text
Repository PowerShell line coverage: baseline 92.92%, final 92.92%, delta 0.00 percentage points
Focused changed-script coverage: baseline 0.00% (not present in baseline XML), final 79.34% command coverage
Focused changed-script command coverage target: 75%
Threshold verdict: PASS
```
