# [P12-T7] Line-cap inventory

Timestamp: 2026-09-07T16-00

Command:

```
@(Get-Content -LiteralPath $path).Count     # per path, the specified method
```

applied to every path in the [P12-T1] enumeration whose extension is `.ps1` or `.psm1`.

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context, so `@(Get-Content -LiteralPath $path).Count` could not be executed directly. Each count was
computed by an equivalent Python implementation: the file is decoded as `utf-8-sig` with newline
translation disabled, `
` and bare `` are normalized to `
`, one trailing newline is dropped if
present, and the remainder is split on `
`. That reproduces `Get-Content`, which strips a BOM,
treats all three line-ending conventions as line breaks, and emits no trailing empty element for a
file ending in a newline.

Source enumeration: `evidence/qa-gates/scope-and-size.2026-09-07T15-46.md` ([P12-T1]).

## Output Summary

**58 paths** in the [P12-T1] enumeration carry a `.ps1` or `.psm1` extension. Every one of them
has a numeric line count recorded below, and **every count is at or under 500**.

| Measure | Value |
| --- | --- |
| Paths measured | 58 |
| Counts over 500 | **0** |
| Counts at exactly 500 | 2 |
| Maximum count observed | 500 |
| Minimum count observed | 45 |

The two files at exactly 500 are the Codex preimplementation gate and its bundle mirror:

- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` — 500
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` — 500

500 is at the cap and not over it. The plan's standing constraints record that this file entered the
change at 495 lines with five lines of headroom against a 500-line cap; it now sits at the cap
exactly, with no headroom. That is a compliant but tight result and is recorded here explicitly so a
later change to that file knows it must extract before it adds.

The next four largest counts are:

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — 496
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — 496
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — 494
- `.claude/hooks/hook-command-invocation.ps1` — 483

## Full inventory

| # | Path | Lines | At or under 500 |
| --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 473 | yes |
| 2 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 445 | yes |
| 3 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 496 | yes |
| 4 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 331 | yes |
| 5 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 314 | yes |
| 6 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 240 | yes |
| 7 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 115 | yes |
| 8 | `.claude/hooks/enforce-promotion-mcp-only.ps1` | 303 | yes |
| 9 | `.claude/hooks/hook-command-invocation.ps1` | 483 | yes |
| 10 | `.claude/hooks/hook-command-scanner.ps1` | 450 | yes |
| 11 | `.claude/hooks/validate-bash.ps1` | 402 | yes |
| 12 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 174 | yes |
| 13 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 177 | yes |
| 14 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | yes |
| 15 | `.codex/hooks/enforce-promotion-mcp-only.ps1` | 288 | yes |
| 16 | `.codex/hooks/hook-command-invocation.ps1` | 483 | yes |
| 17 | `.codex/hooks/hook-command-scanner.ps1` | 450 | yes |
| 18 | `.codex/hooks/validate-bash.ps1` | 295 | yes |
| 19 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 473 | yes |
| 20 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 445 | yes |
| 21 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 496 | yes |
| 22 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | 331 | yes |
| 23 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 314 | yes |
| 24 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 240 | yes |
| 25 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 115 | yes |
| 26 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | 303 | yes |
| 27 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` | 483 | yes |
| 28 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | 450 | yes |
| 29 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | 402 | yes |
| 30 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | 174 | yes |
| 31 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 177 | yes |
| 32 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | yes |
| 33 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | 288 | yes |
| 34 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` | 483 | yes |
| 35 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | 450 | yes |
| 36 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | 295 | yes |
| 37 | `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 133 | yes |
| 38 | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | 107 | yes |
| 39 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 296 | yes |
| 40 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | 332 | yes |
| 41 | `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 69 | yes |
| 42 | `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` | 88 | yes |
| 43 | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 281 | yes |
| 44 | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | 57 | yes |
| 45 | `tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | 197 | yes |
| 46 | `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` | 330 | yes |
| 47 | `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` | 228 | yes |
| 48 | `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` | 347 | yes |
| 49 | `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 82 | yes |
| 50 | `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 86 | yes |
| 51 | `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` | 110 | yes |
| 52 | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 302 | yes |
| 53 | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 350 | yes |
| 54 | `tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` | 183 | yes |
| 55 | `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1` | 267 | yes |
| 56 | `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` | 321 | yes |
| 57 | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 494 | yes |
| 58 | `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1` | 45 | yes |

## Paths in the enumeration with no `.ps1` or `.psm1` extension

The [P12-T1] enumeration holds 137 paths. 58 carry a `.ps1` or `.psm1` extension and are measured
above. The remaining 79 are Markdown documents, JSON pack manifests, and two `.psd1` data files,
none of which is a production or test PowerShell script and none of which is a subject of this
task's `.ps1`/`.psm1` scope. For completeness, the two `.psd1` copies of
`pester.runsettings.psd1` are 274 lines each, recorded in
`evidence/other/pair-hash-parity.2026-09-07T15-52.md`, also under the cap.
