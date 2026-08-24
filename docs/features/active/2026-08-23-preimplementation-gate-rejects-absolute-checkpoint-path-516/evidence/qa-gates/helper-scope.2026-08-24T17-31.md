# Helper Landed in Exactly the Intended Files — Issue #516

Timestamp: 2026-08-24T17-31

Command: `git grep --untracked -l 'ConvertTo-WorkspaceRelativePath' -- '*.ps1'`

EXIT_CODE: 0

Output Summary:

Six `.ps1` files match, and no others:

| # | Path | Role |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | hook copy 1 (production) |
| 2 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | hook copy 2 (production) |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | hook copy 3 (bundled mirror of copy 1) |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | hook copy 4 (bundled mirror of copy 2) |
| 5 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1` | new Claude facet test file |
| 6 | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate.path-normalization.Tests.ps1` | new Codex facet test file |

The matched set is exactly the four hook copies named in the plan's Batch split section plus the two new facet test files. No other production `.ps1` file carries the helper, confirming the fix was not centralized and did not leak into any other hook.

`--untracked` is required because plain `git grep` searches tracked files only; the two facet test files created by P1-T1 and P3-T2 are untracked at verification time.
