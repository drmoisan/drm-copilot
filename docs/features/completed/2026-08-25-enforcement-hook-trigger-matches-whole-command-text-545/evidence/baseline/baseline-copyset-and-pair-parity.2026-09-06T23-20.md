# Baseline: copy set and pair parity for the widened hook scope

Timestamp: 2026-09-06T23-20
Command: `wc -l` over the in-scope hooks; `cmp -s` over each Claude canonical/bundle pair and each Codex canonical/bundle pair; `test -f` for copy presence
EXIT_CODE: 0

Output Summary: All nine in-scope Claude hooks are present and byte-identical to their Claude
bundle copies. All seven Codex-side files checked are present and byte-identical to their Codex
bundle copies. Every pair is green at baseline, so any pair failure observed later in this work is
caused by this change and not inherited. Line counts confirm the epic brief's figures exactly.

Branch: `bug/enforcement-hook-trigger-matches-whole-command-text-545-r2`
Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `be722eba`

## Line counts (verified, current tree)

| Hook | Lines | Headroom under 500 |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 489 | 11 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 | 151 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 480 | 20 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 451 | 49 |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 418 | 82 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 280 | 220 |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 274 | 226 |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 256 | 244 |
| `.claude/hooks/validate-bash.ps1` | 230 | 270 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 228 | 272 |
| `.claude/lib/hook-payload/HookPayload.psm1` | 496 | 4 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 494 | 6 |

The preimplementation gate has **11 lines of headroom**, not the larger figure implied elsewhere.
`HookPayload.psm1` at 496 and `legacy-codex-hook-contracts.Tests.ps1` at 494 are the two tightest
files in scope; neither can absorb meaningful new content.

## Copy set (verified by presence test)

Four-copy files — Claude canonical, Claude bundle, Codex canonical, Codex bundle:

- `enforce-orchestration-preimplementation-gate.ps1`
- `enforce-orchestration-preimplementation-gate-helpers.ps1`
- `enforce-promotion-mcp-only.ps1`
- `enforce-epic-merge-gate.ps1`
- `enforce-epic-worktree-removal-gate.ps1`
- `validate-bash.ps1`

Two-copy files — Claude canonical and Claude bundle only, no `.codex` copy:

- `enforce-parallel-worktree-removal-gate.ps1`
- `enforce-parallel-abandon-gate.ps1`
- `enforce-pr-author-skill-helpers.ps1`

This asymmetry is a load-bearing fact for the fix. Because four of the in-scope hooks have Codex
copies, the shared parser must be reachable from `.codex/hooks/`.

## Pair parity at baseline

| Pair | Files checked | Result |
| --- | --- | --- |
| Claude canonical vs Claude bundle | 9 in-scope hooks | all byte-identical |
| Codex canonical vs Codex bundle | 7 files incl. `codex-pretooluse-file-mapping.ps1` | all byte-identical |

## Shared-module contract, verified

`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30 currently reads:

```powershell
$script:SharedModuleNames = @('codex-pretooluse-file-mapping.ps1', 'enforce-orchestration-preimplementation-gate-helpers.ps1')
```

Two members today. `$script:StaticCheckNames` at line 31 is `$script:AllHookNames` plus
`$script:SharedModuleNames`, and it drives the hashing and static checks at lines 94, 112, and 128;
line 136 iterates `$script:SharedModuleNames` for the manifest assertion.

This confirms spec decision D7's cited precedent and confirms that the shared-helper mechanism the
repository already uses is a **dot-sourced `.ps1`**, not a `.psm1`.

## Consequence for the module-form decision

`.claude/lib/**/*.psm1` modules are mirrored only into
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/`. There is no Codex-side
mirror of `.claude/lib/`. A `.psm1` under `.claude/lib/` therefore cannot be consumed by the Codex
copies of the four in-scope hooks that have them.

The dot-sourced shared-helper form settled in spec decision D7 is the form that satisfies both
sides. The epic brief's assumption that the parser needs a new `.psm1` under `.claude/lib/` does not
hold once the Codex copies are taken into account; the correct reading of the 500-line pressure is
that `HookPayload.psm1` is irrelevant to this change rather than that it is a blocked destination.

## Drift since the 2026-08-25 preparation

Three commits touched in-scope hooks after the original spec and plan were authored:

| Commit | Subject | In-scope files touched |
| --- | --- | --- |
| `d7ce455f` | replace preimplementation-gate delegation classifier (#554) | preimplementation gate, both canonical copies, +132 / +137 lines |
| `c4261e51` | add a parallel allow-branch to the epic worktree-removal gate (#573) | `enforce-epic-worktree-removal-gate.ps1`, +181 lines |
| `18140faa` | deny cd-chained file-read Bash commands | `validate-bash.ps1`, both Claude copies, +43 lines |

All three land inside files this work modifies, and two of them add large blocks to files whose
line numbers the 2026-08-25 spec and plan cite directly. Line-number citations in those documents
must be treated as unverified until re-derived.
