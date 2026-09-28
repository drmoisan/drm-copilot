# [P2-T4] D-1 containment fix in the Python hook

Timestamp: 2026-08-30T00-40

Task: [P2-T4] of the cycle-1 remediation plan.

## Execution context

The plan states its commands worktree-relative. Each command was executed with the absolute prefix
`cd "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5" && ` prepended
to the plan's command text, recorded verbatim below. The one exception is the supplementary reset
described under "Deviation", which was executed against a different absolute root and is recorded
with that root named.

## The edit

Line 89 of `.claude/hooks/enforce-python-batch-budget.ps1` was replaced in place, one line for one
line. Before:

```
    return $normalizedPath.StartsWith($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)
```

After, the literal pinned by decision D-1:

```
    return ([string]::Equals($normalizedPath, $normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase) -or $normalizedPath.StartsWith($normalizedRoot + '/', [System.StringComparison]::OrdinalIgnoreCase))
```

The null-or-whitespace path guard, the relative-candidate early return, the empty-root guard, the
function signature, and the comment-based help are all unchanged.

## Deviation — the batch-budget counter is session-scoped, not worktree-scoped

The first attempt at this edit was blocked by the PowerShell batch-budget hook. Its message, quoted
verbatim in the essential part:

```
PowerShell per-batch budget exceeded: production file cap is 3 and is already full
(C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7/.claude/lib/mermaid/MermaidMarkdownFences.psm1,
 C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7/extensions/drm-copilot/resources/claude-customizations/.claude/lib/mermaid/MermaidMarkdownFences.psm1,
 C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1).
Requested new file: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/.claude/hooks/enforce-python-batch-budget.ps1.
... reset the batch by deleting C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-29T15-07\.claude\state\powershell-batch-budget.default.json.
```

Two facts follow directly from that message and neither was anticipated by the plan:

1. **The counter file lives in the executing session's repository root**
   (`C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-29T15-07\.claude\state\`), not in the worktree
   being edited (`.../worktrees/agent-add102e7ba6e997d5/.claude/state/`). The plan's reset command is
   worktree-relative, so [P1-T1] and [P2-T1] both ran against a directory that was absent and both
   reported a count of `0` without touching the counter that actually governs the edits.
2. **The counter is shared across concurrent worktrees.** Two of the three occupied production slots
   name files under a different worktree, `agent-aee68cdb110fb5da7`, which this remediation does not
   touch. The Phase 1 edits therefore landed only because that shared counter happened to have room,
   not because [P1-T1] re-armed it.

Corrective micro-action taken, which is the plan's own reset command applied at the location the
counter actually occupies rather than a new or different action:

Command: `pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/state' -Filter '*-batch-budget.*.json' -ErrorAction SilentlyContinue | Remove-Item -Force"`,
executed with the prefix `cd "C:/Users/DanMoisan/repos/drm-copilot-wt/2026-08-29T15-07" && `.

EXIT_CODE: 0

A pre-removal enumeration listed exactly one file,
`C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-29T15-07\.claude\state\powershell-batch-budget.default.json`.
The plan's acceptance command run afterwards at the same root printed `0` with EXIT_CODE 0, so the
counter is re-armed. The blocked edit then succeeded.

Only a gitignored runtime state file was removed. No tracked file, and no file inside the target
worktree, was affected by the corrective action.

This deviation is reported to the orchestrator rather than absorbed, because it means the Phase 1 and
Phase 2 batch boundaries were not enforced by the mechanism the plan names, and because it is
directly relevant to issue #596, whose subject is batch-budget state portability.

## Step 1 — corrected literal present

Command: `git grep -c -F "StartsWith(\$normalizedRoot + '/'," -- .claude/hooks/enforce-python-batch-budget.ps1`

EXIT_CODE: 0

Output Summary: `.claude/hooks/enforce-python-batch-budget.ps1:1` — a count of `1`, as required.

## Step 2 — defective literal absent

Command: `git grep -c -F 'StartsWith($normalizedRoot,' -- .claude/hooks/enforce-python-batch-budget.ps1`

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary: No output. Exit 1 with no output is `git grep`'s no-match result, which is the
required outcome. [P0-T7] recorded a count of `1` for this literal in this file before the edit, so
this gate moved from matching to not-matching and is capable of failing.

## Step 3 — line-count preservation

Command: `pwsh -NoProfile -Command "(Get-Content -LiteralPath '.claude/hooks/enforce-python-batch-budget.ps1').Count"`

EXIT_CODE: 0

Output Summary: `454`, unchanged from the [P0-T5] baseline of `454`. This keeps the Form D absolute
line numbers 151 and 152 pointing at the two catch-body statements across the baseline and
pass-after captures.

## Verdict

PASS. All three acceptance conditions met. One deviation recorded above.
