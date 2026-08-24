# Line Budgets — Issue #516

Timestamp: 2026-08-24T17-31

Command: `pwsh -NoProfile -Command "@(<the six paths>) | ForEach-Object { $c = (Get-Content $_ | Measure-Object -Line).Lines; '{0} = {1}' -f $_, $c }"`

EXIT_CODE: 0

Output Summary:

| File | `Measure-Object -Line` | Physical lines (`wc -l`) | Under 500 |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 360 | 420 | yes |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 367 | 425 | yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 360 | 420 | yes |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 367 | 425 | yes |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1` | 247 | 316 | yes |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1` | 171 | 209 | yes |

Every count is below the 500-line cap in `.claude/rules/general-code-change.md` under both measures. `Measure-Object -Line` excludes blank lines, so the physical `wc -l` count is reported alongside it as the stricter figure; the budget holds on the stricter figure for all six files.

The Claude hook grew from 340 to 420 physical lines and the Codex hook from 336 to 425, both within the plan's projected budget of approximately 395 and well inside the cap. The Codex copy is the larger of the two because it additionally carries the `Test-ImplementationCommand` `-WorkspaceRoot` parameter and the two normalized hunk-path loops.
