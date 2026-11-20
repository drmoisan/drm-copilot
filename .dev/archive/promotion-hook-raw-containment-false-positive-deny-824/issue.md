# Bug: promotion-hook-raw-containment-false-positive-deny

- Issue: #824
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/824
- Type: bug
- Work Mode: full-bug
- Epic: #852 (enforcement-hook-precision), child C1a command-invocation matching
- Integration branch: epic/enforcement-hook-precision-integration
- Source: GitHub issue #824 body and comments (read with `gh issue view 824 --comments` on 2026-10-08). The original potential record `docs/features/potential/2026-10-03-promotion-hook-raw-containment-false-positive-deny.md` is not present on the integration branch.

## Summary

`.claude/hooks/enforce-promotion-mcp-only.ps1` denies read-only wrapped `pwsh` commands whose raw text merely contains the letters "gh", "issue" and "new" anywhere. The raw-containment fallback in `.claude/hooks/hook-command-invocation.ps1` is documented as loose, on the basis that a false positive only forces a checkpoint check. The promotion hook turns that loose match into an unconditional deny with no checkpoint check and no escape path.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (PowerShell hooks)
- Command/flags used: Bash tool command routed through the PreToolUse hook
- Data source or fixture: main at 93725814

## Steps to Reproduce

1. Send this read-only Bash command, which invokes no `gh`, through the PreToolUse hook:
   `pwsh -NoProfile -Command '$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'`
2. Observe the hook decision.

## Expected Behavior

Allow. Only an actual `gh issue create|new` invocation, or a genuinely unresolvable segment, is denied.

## Actual Behavior

Deny with PROMOTION_MCP_ONLY_BLOCKED (gh issue creation reason).

The hook calls `Test-CommandLineInvocation -CommandWord 'gh' -SubcommandPath @('issue','create'|'new')`. For any wrapper-led segment (for example `pwsh -NoProfile -Command '...'`) or segment containing a live substitution, `Resolve-CommandLineInvocation` falls back to `Test-CommandLineRawContainment`. That fallback uses ordinal, case-insensitive substring containment of each word anywhere in the raw text and ignores word boundaries, order and adjacency. "gh" matches inside through/high/length, "issue" matches inside a string, and "new" matches `New-Object`, `::new()` or newline.

## Impact / Severity

- [x] High

## Addendum 1 (in scope): worktree-removal gates

The same loose-containment defect also produces a hard deny in `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`. The sibling `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` likely shares it.

The gate calls `Test-CommandLineInvocation -CommandText $commandText -CommandWord 'git' -SubcommandPath @('worktree', 'remove')`. For a wrapper-led segment such as `pwsh -NoProfile -Command '...'`, this falls back to `Test-CommandLineRawContainment`. A payload that never runs `git worktree remove` classifies as a worktree removal if it contains any `git` call, a path through a `.claude/worktrees/` directory or the word WORKTREE, and `Remove-Item`. `Get-EpicWorktreeRemovalCommandPath` then finds no operand, so the target path is empty and the gate denies with `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE`.

Reproduction:

    pwsh -NoProfile -Command 'Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'

- Observed: deny, `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE`.
- Expected: allow.

Required change (from the addendum):

1. For wrapper-led and substitution segments, require a token-aware match of an actual `git ... worktree remove` invocation, not substring containment. Keep fail-closed behavior for Unbalanced segments.
2. When the containment fallback matches but no operand can be extracted (empty target path), do not deny unconditionally; treat it as "not a worktree removal" or route it to a checkpoint check, consistent with the helper's documented contract.
3. Apply both changes to `enforce-parallel-worktree-removal-gate.ps1` as well.

Addendum 1 acceptance conditions:

- The reproduction command is allowed by both worktree-removal gates.
- These are still gated exactly as today (denied without an authorizing checkpoint, allowed with one): `git worktree remove <path>`; `git worktree remove --force <path>`; `git -C <dir> worktree remove <path>`; `pwsh -Command 'git worktree remove <path>'`; `bash -c "git worktree remove <path>"`.
- Pester tests cover each case, including a negative control that fails if the substring-containment deny path is restored.
- The PowerShell toolchain passes.

## Excluded: Addendum 2

Issue #824 addendum 2 (the #823 follow-ups FU-823-1, FU-823-2, FU-823-3, FU-823-5 and #823 review notes A and B) is out of scope for this child. A concurrent parallel run delivers it. This feature plans none of its items.

## Bundled Issues

This child (C1a of epic #852) also delivers the following existing issues. No new GitHub issue is created.

### #742 guard-denylist-false-positives

Several PreToolUse guards match substrings of the whole command or path and refuse harmless operations:

1. `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` blocks a plain `git --version` with `PARALLEL_WORKTREE_REMOVAL_BLOCKED` (#713).
2. The worktree isolation guard refuses `git -C` chains, output piped from `sh`, and any argument that is the word `hash` (#707).
3. A Write guard refuses evidence file names that contain "report" (#706 FU-706-5).
4. The Bash permission engine refuses `cd ... && <read-command>` forms (observed; noted for completeness).

Acceptance conditions:

- Guards tokenise the command and match the specific operations they govern (`git worktree remove`, destructive commands, and so on).
- `git --version` is allowed by the parallel worktree-removal gate.
- The worktree isolation guard allows `git -C <own-worktree>` chains, output piped from `sh`, and an argument that is the word `hash`, while still refusing operations outside the worktree.
- The evidence-filename Write guard allows ordinary evidence file names that contain "report".
- Item 4 is a Claude Code permission-engine behavior; the research step determines whether any repository-owned hook is involved, and the plan records the disposition.

### #733 pr-author-allowlist-chaining-and-false-positives

1. The `pr-author` agent's `Bash(git log *)` permission can be stretched to other commands by chaining (`git log ... && sha256sum ... && date ...` was accepted in #712).
2. `enforce-pr-author-skill.ps1` blocked a commit message containing the words `gh`, `pr` and `create` (#714).
3. The same hook rejects a quoted or absolute `--body-file` path with `PR_BODY_PATH_NONCANONICAL` (#715).
4. Comment of 2026-09-29: the pr-author hook denied a read-only grep/sed command that contained no `gh` invocation (`PR_AUTHOR_SKILL_BLOCKED`).

Acceptance conditions:

- An allowlist entry authorises exactly the command it names; chained commands are evaluated segment by segment, so a chained command does not inherit the permission of its first segment.
- Receipts can be produced with a sanctioned tool.
- The hook matches `gh pr create` invocations, not text inside commit messages, read-only grep/sed commands, or legitimate (quoted or absolute) `--body-file` path spellings that resolve to the canonical body path.

## Acceptance Criteria

The authoritative acceptance criteria for this full-bug feature live in `spec.md`.
