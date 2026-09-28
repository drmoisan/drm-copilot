# Phase 0 — Copy-Set Baseline ([P0-T8])

Timestamp: 2026-09-07T19-38
Task: [P0-T8]
EXIT_CODE: 0 (all three commands)

## Command 1 — line counts

Command: `wc -l .claude/hooks/validate-bash.ps1 .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1 tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`
EXIT_CODE: 0

Verbatim output:

```
  402 .claude/hooks/validate-bash.ps1
  295 .codex/hooks/validate-bash.ps1
  402 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
  295 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
   82 tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
   45 tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
 1521 total
```

| # | File | Lines (integer) | At or under 500 |
|---|---|---|---|
| 1 | `.claude/hooks/validate-bash.ps1` | **402** | yes |
| 2 | `.codex/hooks/validate-bash.ps1` | **295** | yes |
| 3 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | 402 | yes |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | 295 | yes |
| 5 | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 82 | yes |
| 6 | `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | 45 | yes |

The two canonical hooks are 402 and 295 respectively, matching the values the plan expects.

## Command 2 — Claude pair byte parity

Command: `cmp .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`
EXIT_CODE: 0
Output: (nothing printed)

`cmp` is used without `-s` so that a difference would produce a diagnostic line rather than a silent
non-zero exit. Nothing printed and exit 0 is what a byte-identical pair produces.

## Command 3 — Codex pair byte parity

Command: `cmp .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`
EXIT_CODE: 0
Output: (nothing printed)

Output Summary: All six files at or under the 500-line cap, with the two canonical hooks at 402 and
295 lines. Both canonical/bundle pairs are byte-identical: both `cmp` invocations printed nothing
and exited 0. These are the baseline values that `[P4-T5]` re-verifies after the R-1 edit.
