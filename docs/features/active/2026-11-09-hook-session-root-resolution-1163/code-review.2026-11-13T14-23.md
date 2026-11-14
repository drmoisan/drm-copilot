# Code Review: Hook Session-Root Resolution (Issue #1163)

**Review Date:** 2026-11-13
**Branch:** `bug/hook-session-root-resolution-1163` @ `d28a5645ba0c4194484f0f947847628424e14f71` (no PR exists yet)
**Base:** `main`; merge base `1d62aa292161035aec8058e6c370f133e10a04db`
**Scope:** full branch diff, 127 files (20 production PowerShell files and their 20 bundle mirrors, 35 PowerShell test files, 2 pack manifests, 8 Markdown policy and brief copies, 42 feature-folder files)

## Executive Summary

The change implements the spec's design: `Resolve-AgentTargetWorktree` composes `Resolve-HookTargetWorktree` through a filtered listing, so prunable registrations never match, adds the agent working directory as a source before the session root, and applies the two policies. The adopters receive small call-site edits, the D9 fallback is confined to the no-live-match branch of `Test-WorktreeRunRecordedPathMatchesTarget`, and every new parameter defaults to today's behavior. Fail-before evidence covers each changed decision, and parity rows cover the unchanged ones.

Reviewer probes called the resolver directly with in-memory porcelain (11 calls). Ten results match the spec: a prunable plus live registration resolves the live root where `Resolve-HookTargetWorktree` returns `TARGET_WORKTREE_AMBIGUOUS`; an identity outranks the working directory; a working directory inside a prunable root falls back to the session root; a listing failure keeps the session root with the failure in the detail; Windows-style roots compare case-insensitively. One call shows a defect (F1): the stale-registration detail names `branch 'b'` for the branch `bug/x-1`.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Medium (blocking, F1) | `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`; `.codex/hooks/agent-target-worktree.ps1`; both bundle mirrors | `Resolve-AgentTargetWorktree`, the block after the comment "A branch registered only at a prunable root names that root and the repair remedy" (`$branches = if (...) { @($CommandBranch.Trim()) } else { @(...) }` and `$branches[0]`) | The `if`/`else` expression unrolls a one-element array into a scalar string, so `$branches[0]` returns the first character. With one branch (`-CommandBranch`, or a prompt with one `branch:` label) over a prunable-only registration, the detail reads `branch 'b' is registered only at the stale root '<root>'; run git worktree repair ...`. With two labels the array survives and the name is correct. The stale-root match itself is unaffected. | Assign `$branches = @(if (...) { ... } else { ... })` and name the branch whose record matched (the `Branch` of the dropped record) rather than `$branches[0]`. Apply the same function text to the Codex twin and both bundle mirrors. In `AgentTargetWorktree.Rows.Helpers.ps1`, extend the `DetailPattern` of the two AC-7 rows ('prunable a command branch registered only at a prunable root ...' and 'prunable a prompt branch registered only at a prunable root ...') to require `branch 'bug/item'`, and confirm both rows fail before the fix. | The detail is the operator-facing remedy text that D3 and the spec's error-handling section require; SubagentStop blocks and the brief surface it. A wrong branch name misdirects the operator, and the current rows (`DetailPattern` matches only the root and `git worktree repair`) cannot detect it. | Reviewer probe P2: `-DelegationPrompt 'branch: bug/x-1'`, `FailClosedOnIdentity`, prunable-only porcelain gave `branch 'b' ...`; probe P10 with `-CommandBranch 'bug/x-1'` gave the same; probe P11 with two labels gave `branch 'bug/x-1' ...` |
| Info (CR1) | `.claude/hooks/subagentstop-target-worktree.ps1` consumers `.claude/hooks/validate-feature-review-coverage.ps1` and `.claude/hooks/validate-orchestrator-output-target.ps1` | `Resolve-SubagentStopTargetWorktree` | Both hooks consume the shared helper and so inherit the prunable exclusion and the `AgentWorkingDirectory` source. D5 names the orchestrator hook; the feature-review coverage hook is not named in the spec and has no dedicated row for the working-directory source. The full gate passes, and the inherited behavior is the intended direction (a stop resolves the agent's own worktree). | Optional: add one row to the feature-review coverage suite showing a no-identity stop whose envelope `cwd` lies in an item worktree, so the inherited decision is pinned. | Keeps the inherited decision visible to later edits of the helper. | `grep` of helper consumers at head |
| Info (CR2) | `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | default `WorktreeListInvoker` | The default invoker calls `git` inside a script block instead of an `Invoke-GitExe` wrapper. This matches the seam in `HookTargetWorktree.psm1` that D1 composes, and no test reaches it (the one uncovered line in each new file). | None required. | Consistent with the composed module; recorded for the wrapper-seam rule in the language rule file. | Module text; coverage XML |
| Info (CR3) | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`; removal gates | D9 default `BranchWorktreeResolver` | Each rooted record that names no live root starts one `git worktree list` through the default resolver. Checkpoints hold few records, so the cost is small. | Optional: list once per gate call and pass the result if record counts grow. | Bounded process count per hook call. | Diff of `Resolve-WorktreeRunTargetByRecord` and `Test-WorktreeRunRecordedPathMatchesTarget` |
| Warning | `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | whole file | 750 logical lines (700-line advisory tier; the hard limit is 800). | Consider splitting the issue #1163 receipt-root Describe into its own suite in a later change. | File-size advisory tier. | `awk 'END{print NR}'` at head |

No covered file exceeds 800 logical lines, and `config/file-size-baseline.json` is not in the diff. The other covered files at or above 500 lines are `.claude/hooks/enforce-completion-consistency.ps1` (505) and `.codex/hooks/enforce-completion-consistency.ps1` (500), both below the advisory tier.

## Detailed Review

### F1, branch name in the D3 detail

```powershell
$branches = if (-not [string]::IsNullOrWhiteSpace($CommandBranch)) { @($CommandBranch.Trim()) } else {
    @([regex]::Matches([string] $DelegationPrompt, $branchPattern) | ForEach-Object { ... })
}
...
$detailText = "branch '$($branches[0])' is registered only at the stale root '$($stale[0])'; run git worktree repair ..."
```

PowerShell writes the array returned by each branch of the `if` statement to the pipeline, and the assignment collects a single item as a scalar. `$branches` is then a `[string]`, and `[string][0]` is a `[char]`. The `$stale` filter still works because piping a scalar string yields one item, so `StaleRegistration` and the stale root in the detail are correct; only the branch name is wrong. The finding is autonomous and contained: the fix is a one-line change in the named function plus its twin and mirrors, and a tightened pattern in two existing data rows. It changes no decision, parameter, result field, or AC.

### Resolver composition

`ConvertTo-AgentTargetLiveWorktreeListText` re-renders only the `worktree` and `branch` or `detached` lines; the `locked` and `bare` lines are dropped, which `Resolve-HookTargetWorktree` does not read for matching. The wrapped invoker is a closure that captures the filter as a script block, so the module needs no command lookup inside `Resolve-HookTargetWorktree`'s scope. `$PSBoundParameters` forwarding passes only the sources the caller supplied, so the parity rows hold.

### Adopters

- SubagentStop: `Resolve-SubagentStopArtifactLocation -Target` rejects before any path conversion when the target carries a reason code, and the six hooks pass `-Target`; the `FailIfCalled` rows prove no probe runs.
- Completion consistency (both surfaces): the folder check is rebased only when an absolute checkpoint path resolves to a worktree other than the session root; a listing failure is absorbed by the resolver (probe P7 returns the session root), so the process-relative probe stays.
- File size (both surfaces): the resolver runs only for an absolute path that is outside the root or under `.claude/worktrees/`, inside a `try` that keeps today's path on failure.
- Docs-complete gate: `Get-DocsCompleteGateReceiptRoot` uses `FailClosedOnIdentity` and falls back to the repository root on any reason code, blank root, or exception; the profile read is unchanged.
- D9: the fallback runs only for a rooted record that equals no live root, with a non-blank branch and a resolver; it matches only when the resolver returns no reason code and a root equal to the target. Removal stays fail-closed for zero or several resolved worktrees.

### Tests

The fail-before run recorded 54 expected failures, all issue #1163 rows, none failing on binding or mock registration. Converted SubagentStop rows record the D4 reason. The orchestrator-output suites changed only the mocked collaborator name in two resolver-throw rows, with the reason recorded; the no-identity `ORCHESTRATOR_CHECKPOINT_FALLBACK:` rows are unedited (AC-12). Tests use POSIX-style roots and in-memory seams throughout.

### Mirrors, manifests, and documentation

Every changed `.claude/` and `.codex/` source is byte-identical to its bundle mirror (reviewer `cmp`). Both manifests list the new files. The six brief copies share one blob id, and the orchestrator-state rule note and its mirror are identical.

### Security and correctness

No hook writes, restores, or normalizes a tracked file. No changed code persists a path. The default listing call uses `git -C <session root>` with no user-supplied arguments.

## Verification Performed

- `git -C <item worktree> diff 1d62aa292..HEAD` over every production file and the changed existing test rows.
- Direct resolver probes (11 calls) through a scratchpad launcher, with in-memory porcelain and readers.
- Parse of `artifacts/pester/powershell-coverage.xml`: root and per-file LINE counters for the 20 production files.
- `cmp` of every changed source with its bundle mirror; `git ls-files -s` of the brief copies.
- `git diff --stat` of the invariant paths against the merge base: empty.
- Logical line counts of every covered file in the diff.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.
- `git fetch origin main` and `git merge-tree --write-tree origin/main HEAD`: merge base unchanged, merge clean.

No reviewer Pester run was made: the owner directive allows only parallel full-suite runs, the final gate ran after the last production commit, and the head adds only documents. Test discrimination was judged from the fail-before evidence, row inspection, and the direct probes.

## Verdict

**REMEDIATION REQUIRED.** One blocking contained finding (F1), suited to a light cycle. CR1 to CR3 and the Warning are non-blocking.
