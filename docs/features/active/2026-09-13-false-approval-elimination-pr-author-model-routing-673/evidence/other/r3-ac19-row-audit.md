# AC-19 Protected-Row Audit Against Issue #687

Timestamp: 2026-09-19T17-24

Command: `git log --format=%H -S Resolve-PrAuthorWorktreeTarget b7c1161655b4b53b0358dc7890a26200207c4b91 -- tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`; then for each of `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` and `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`, `git diff <#687 commit>^:<file> <#687 commit>:<file>`; then `git log --format=%H b7c1161655b4b53b0358dc7890a26200207c4b91 -1 -- tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1`

EXIT_CODE: 0

## Commit identification

The `-S` log printed exactly one SHA, so the last SHA printed is the #687 commit: `f62c85abd62d05c828751fcc6353310db49f02f5`.

The last commit touching `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` at or before `F5_BASE_SHA` is `6a8d59f34441068c994e885abfee5fe7f0fc5bc5`. That SHA differs from `f62c85abd62d05c828751fcc6353310db49f02f5`, so #687 did not modify that file and all three of its protected rows stand at their spec line numbers.

## Row-by-row audit (seven rows)

### Row 1 — `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`

- Spec location: `:26-37`
- Current location: `:35-46`, shifted by the nine lines #687 inserted above it
- Current `It` names in the span: `blocks gh pr create --body-file when the checkpoint is missing`
- Verdict: **unchanged by #687** — the `It` name, body, and assertions are byte-identical across the commit; only the line numbers moved.

### Row 2 — `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`

- Spec location: `:39-51`
- Current location: `:48-60`, shifted by the same nine lines
- Current `It` names in the span: `blocks gh pr create --body-file with the summarized output when --require-pr-creation-ready fails`
- Verdict: **unchanged by #687** — byte-identical across the commit; only the line numbers moved.

### Row 3 — `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` (the end-to-end row)

- Spec location: `:64-102`
- Current location: `:73-115` including the four-line #687 comment block; the `It` itself is `:77-115`
- Current `It` names in the span: `blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE)`
- Verdict: **changed by #687.** Two lines differ.

Before (`f62c85abd62d05c828751fcc6353310db49f02f5^`):

```
        It 'blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, ORCHESTRATOR_STATE_PREFLIGHT_FAILED)' {
```

```
                $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'ORCHESTRATOR_STATE_PREFLIGHT_FAILED'
```

After (`f62c85abd62d05c828751fcc6353310db49f02f5`):

```
        # Issue #687: this case drives a real pwsh process, so the resolution seam cannot be
        # mocked. The command names no feature folder, file path, or branch, so it resolves
        # NoTarget and the gate now refuses to answer from the session root's checkpoint. The
        # ORCHESTRATOR_STATE_PREFLIGHT_FAILED path is covered by the mocked cases above.
        It 'blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE)' {
```

```
                $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'TARGET_WORKTREE_NOT_DERIVABLE'
```

The pre-#687 name ends `(exit 0, deny, ORCHESTRATOR_STATE_PREFLIGHT_FAILED)` and the current name ends `(exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE)`. This row resolves `NoTarget` in a real child process and therefore never reads the script-variable pin at `:97`, which is why RS-8 records no edit to this file for this plan.

### Row 4 — `enforce-model-routing-receipt.Tests.ps1`

- Spec location: `:62-68`
- Current location: `:62-68`, unshifted
- Current `It` names in the span: `allows when a routing receipt exists for the subagent`
- Verdict: **unchanged by #687** — the file's last commit at `F5_BASE_SHA` is `6a8d59f34441068c994e885abfee5fe7f0fc5bc5`, which is not the #687 commit.

### Row 5 — `enforce-model-routing-receipt.Tests.ps1`

- Spec location: `:71-92`
- Current location: `:71-92`, unshifted
- Current `It` names in the span: `denies with MODEL_ROUTING_RECEIPT_BLOCKED when no receipt exists for the subagent` (`:71`) and `denies when the checkpoint is missing (no receipts at all)` (`:83`)
- Verdict: **unchanged by #687**, same evidence as row 4.

### Row 6 — `enforce-model-routing-receipt.Tests.ps1`

- Spec location: `:20-58`
- Current location: `:20-58`, unshifted
- Current `It` names in the span: `denies an empty payload as an envelope anomaly (fail closed)` (`:20`); `denies the legacy flat root shape as a missing-tool_input anomaly` (`:26`); `allows a well-formed tool_input carrying no subagent_type (scope filter)` (`:33`); `denies unparseable JSON as an envelope anomaly (fail closed)` (`:38`); `allows a non-delegating subagent_type` (`:44`); `allows an orchestrator subagent_type (caller, not receipt-gated)` (`:52`)
- Verdict: **unchanged by #687**, same evidence as row 4.

### Row 7 — `enforce-pr-author-skill.epic-base-branch.Tests.ps1`

- Spec location: `:22-42`
- Current location: `:31-51`, shifted by the nine lines #687 inserted above it. Read in current coordinates, the span `:22-42` covers the two `Test-EpicBaseBranchOverride` calls at `:34` and `:40`, which is the reading RS-8 and `[P5-T6]` use.
- Current `It` names in the span: `allows when the checkpoint is absent (Get-PrAuthorCheckpointContent returns $null)` (`:32`); `allows when the checkpoint has epic_mode: false` (`:38`); `allows a non-create command regardless of epic_mode (gh pr edit is out of scope)` (`:44`)
- Verdict: **unchanged by #687** apart from position — no `It` name and no assertion in the span differs across the commit; the only #687 edit to this file is the Describe-level `BeforeEach` insertion quoted below.

## Both #687 `BeforeEach` blocks, verbatim

`tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`, inserted at `:18-27`:

```
    # Issue #687 routes the checkpoint through a resolution seam. Defaulting it to the
    # session root keeps these tests exercising receipt behaviour, and keeps them
    # independent of whichever worktrees exist on the machine running them.
    BeforeEach {
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
            [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = (Get-Location).Path; ReasonCode = $null; Detail = 'session root' }
        }
    }
```

`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`, inserted at `:19-28`:

```
    # Issue #687 routes the checkpoint through a resolution seam. Defaulting it to the
    # session root keeps these tests exercising their own subject, and independent of
    # whichever worktrees exist on the machine running them.
    BeforeEach {
        Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
            [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = (Get-Location).Path; ReasonCode = $null; Detail = 'session root' }
        }
    }
```

These two blocks are the form RS-8 names as form (c) and that `[P7-T3]` reproduces in `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` for the model-routing seam.

## It names for `[P11-T4]` to read

`[P11-T4]` requires every AC-19 `It` name to appear exactly once with status Passed. The eleven names are:

1. `blocks gh pr create --body-file when the checkpoint is missing`
2. `blocks gh pr create --body-file with the summarized output when --require-pr-creation-ready fails`
3. `blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE)`
4. `allows when a routing receipt exists for the subagent`
5. `denies with MODEL_ROUTING_RECEIPT_BLOCKED when no receipt exists for the subagent`
6. `denies when the checkpoint is missing (no receipts at all)`
7. `denies an empty payload as an envelope anomaly (fail closed)`
8. `denies the legacy flat root shape as a missing-tool_input anomaly`
9. `allows a well-formed tool_input carrying no subagent_type (scope filter)`
10. `denies unparseable JSON as an envelope anomaly (fail closed)`
11. `allows a non-delegating subagent_type`
12. `allows an orchestrator subagent_type (caller, not receipt-gated)`
13. `allows when the checkpoint is absent (Get-PrAuthorCheckpointContent returns $null)`
14. `allows when the checkpoint has epic_mode: false`
15. `allows a non-create command regardless of epic_mode (gh pr edit is out of scope)`

Output Summary: Seven protected rows audited. Five are unchanged by #687 apart from line-number shifts; one, the end-to-end row of `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`, was renamed and had one assertion literal changed by #687, recorded verbatim before and after; and the `enforce-pr-author-skill.epic-base-branch.Tests.ps1` row moved by nine lines with no change to any `It` name or assertion. Both #687 `BeforeEach` blocks are quoted verbatim. The end-to-end row's pre-#687 name ends `(exit 0, deny, ORCHESTRATOR_STATE_PREFLIGHT_FAILED)` and its current name ends `(exit 0, deny, TARGET_WORKTREE_NOT_DERIVABLE)`, as the acceptance condition requires. Fifteen distinct `It` names across the seven rows are listed for `[P11-T4]`.
