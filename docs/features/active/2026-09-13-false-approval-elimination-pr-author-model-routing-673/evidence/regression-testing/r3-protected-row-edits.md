# Protected-Row Edit Record (issue #673)

Timestamp: 2026-09-19T18-31

Command: a Python edit script that appends one argument to each named call site, asserting for every line that it already contains `Test-EpicBaseBranchOverride -CommandText` and does not already contain `-CheckpointPath`, and printing the before and after text of each.

EXIT_CODE: 0

Output Summary: Nine before-and-after pairs recorded for AC-19 edit form (a). Each after-line differs from its before-line only by the appended `-CheckpointPath` argument; no `It` name, no other argument, and no assertion changed. Two of the nine sit inside AC-19's protected span and are marked as such. Later tasks append further sections to this file.

---

## `[P5-T6]` — AC-19 edit form (a): supplying `-CheckpointPath` where the parameter became mandatory

`[P5-T4]` makes `Test-EpicBaseBranchOverride`'s `-CheckpointPath` mandatory with no default. Without this edit every call site below would fail parameter binding rather than exercise its subject. The value supplied is a path that does not exist, composed from `$PSScriptRoot`, so the read seam returns `$null` and the check remains the no-op these rows already assert. That is the same absent-checkpoint condition the rows exercised before the change, when the relative default named a file absent from the test's process directory.

### Inside AC-19's protected span `:22-42`

These two are the calls the plan's RS-8 names as sitting inside the protected span.

**`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:34`** — inside the protected span

```
BEFORE  $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md'
AFTER   $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
```

**`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:40`** — inside the protected span

```
BEFORE  $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md'
AFTER   $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
```

### Outside AC-19's protected span

**`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:48`**

```
BEFORE  $result = Test-EpicBaseBranchOverride -CommandText 'gh pr edit 5 --body-file artifacts/pr_body_5.md'
AFTER   $result = Test-EpicBaseBranchOverride -CommandText 'gh pr edit 5 --body-file artifacts/pr_body_5.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
```

**`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:58`**

```
BEFORE  $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base epic/foo-integration --body-file artifacts/pr_body_1.md'
AFTER   $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base epic/foo-integration --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
```

**`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:68`**

```
BEFORE  $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md'
AFTER   $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
```

**`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:78`**

```
BEFORE  $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md'
AFTER   $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
```

**`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:84`**

```
BEFORE  $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md'
AFTER   $result = Test-EpicBaseBranchOverride -CommandText 'gh pr create --title "x" --base main --body-file artifacts/pr_body_1.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
```

**`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1:38`**

```
BEFORE  $result = Test-EpicBaseBranchOverride -CommandText 'gh --repo drmoisan/drm-copilot pr create --base epic/x --body-file artifacts/pr_body_545.md'
AFTER   $result = Test-EpicBaseBranchOverride -CommandText 'gh --repo drmoisan/drm-copilot pr create --base epic/x --body-file artifacts/pr_body_545.md' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
```

**`tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1:52`**

```
BEFORE  $result = Test-EpicBaseBranchOverride -CommandText 'echo "gh pr create --base main"' 
AFTER   $result = Test-EpicBaseBranchOverride -CommandText 'echo "gh pr create --base main"' -CheckpointPath (Join-Path $PSScriptRoot 'no-such-checkpoint.json')
```

Nine pairs. In every one, the after-line is the before-line plus the identical appended argument and nothing else.

---

## `[P6-T3]` — pin replacement in `OrchestratorState.Tests.ps1`, outside AC-19's rows

Timestamp: 2026-09-19T18-36. This edit is **outside** AC-19's seven protected rows: AC-19 names three files and `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` is not among them. It is recorded here because it replaces a pin of the same script variable the pr-author gate no longer reads, and because RS-8 requires every form-(b)-shaped substitution to quote both sides.

The edited row is `It 'blocks a not-ready checkpoint with ORCHESTRATOR_STATE_PREFLIGHT_FAILED through the default path'`. Every assertion line in it is unchanged.

BEFORE:

```
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            $script:OrchestratorStateCheckpointPath = 'artifacts/orchestration/orchestrator-state.nonexistent-fixture.json'
```

AFTER:

```
            Mock -CommandName Get-PrContextArtifactExistence -MockWith { $true }
            # Issue #673 removed the script-variable pin this row used to set: the gate now
            # takes its checkpoint path from target resolution, so a pin would be overwritten
            # before the preflight reads it. The seam supplies a resolved worktree that does
            # not exist, which reproduces the same missing-file condition the pin created.
            $script:MissingWorktreeRoot = Join-Path $PSScriptRoot 'no-such-worktree-fixture'
            Mock -CommandName Resolve-PrAuthorWorktreeTarget -MockWith {
                [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = $script:MissingWorktreeRoot; ReasonCode = $null; Detail = 'absent fixture worktree' }
            }
```

Equivalence: the pin named a checkpoint file that does not exist, so the default invoker ran the real portable validation against a missing file and failed closed. The replacement resolves to a worktree directory that does not exist, so the composed checkpoint path beneath it does not exist either, and the same validation fails closed for the same reason. The row still reaches `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` through the unmocked preflight rather than through a mocked verdict, which is what makes it an end-to-end row rather than a stub.

Why a substitution was unavoidable: after this change set, `Get-PrAuthorBypassReason` assigns `$script:OrchestratorStateCheckpointPath` from the resolution result before the preflight reads it. A pin set by a test is therefore overwritten, and no design both removes the process-directory binding and leaves that pin effective. This is the same reasoning AC-19 records for its own form (b).

---

## `[P7-T3]` — AC-19 edit form (c): a Describe-level `BeforeEach` in `enforce-model-routing-receipt.Tests.ps1`

Timestamp: 2026-09-19T18-40. This is the form #687 used on `main` for the two pr-author suites, reproduced here for the model-routing seam. Three of AC-19's seven protected rows live in this file, so the edit is confined to an insertion: `git diff b7c1161655b4b53b0358dc7890a26200207c4b91 -- tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` reports nine added lines and zero removed lines, so no `It` name, no assertion, and no existing line changed.

Inserted block, placed immediately after the `BeforeAll` that ends at `:17`:

```
    # Issue #673 routes the checkpoint through a resolution seam. Defaulting it to the
    # session root keeps these rows exercising presence gating, and independent of
    # whichever worktrees exist on the machine running them.
    BeforeEach {
        Mock -CommandName Resolve-ModelRoutingWorktreeTarget -MockWith {
            [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = (Get-Location).Path; ReasonCode = $null; Detail = 'session root' }
        }
    }
```

Why it is necessary: after this change set, the gate resolves a target between the scope filter and the checkpoint read, and denies when it cannot identify one. The rows in this file supply prompts written to exercise presence gating, not identity, so without the default they would all deny on an unresolved target and stop measuring their own subject. Defaulting the seam to the session root restores exactly the pre-change reading for these rows, which is what makes them regression guards rather than rewritten tests. The three filesystem-seam rows call `Get-ModelRoutingCheckpoint -CheckpointPath` directly and already supplied the argument, so the parameter becoming mandatory changed nothing for them.
