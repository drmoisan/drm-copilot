# Code Review: Hook Session-Root Resolution (Issue #1163)

**Review Date:** 2026-11-13
**Branch:** `bug/hook-session-root-resolution-1163` @ `f4c42955364876622140605f693579a91ee91e82` (no PR exists yet)
**Base:** `main`; merge base `1d62aa292161035aec8058e6c370f133e10a04db`
**Review type:** Re-audit, remediation cycle 1 (light); prior review `code-review.2026-11-13T14-23.md`.
**Scope:** full branch diff, 139 files (20 production PowerShell files and their 20 bundle mirrors, 35 PowerShell test files, 2 pack manifests, 8 Markdown policy and brief copies, 54 feature-folder files)

## Executive Summary

The prior review found one blocking defect (F1): the D3 stale-registration detail of `Resolve-AgentTargetWorktree` named only the first character of a single branch. Cycle 1 fixes it in the module, the Codex twin, and both bundle mirrors, and tightens the two AC-7 rows to require the full branch name. The fix is limited to the named block; no parameter, result field, decision, or other production file changed in the cycle.

The rest of the branch is unchanged since the prior review, whose findings for the resolver composition, adopters, D9 fallback, tests, mirrors, and documentation still hold. No new finding was identified.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (F1) | `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`; `.codex/hooks/agent-target-worktree.ps1`; both bundle mirrors; `AgentTargetWorktree.Rows.Helpers.ps1` | `Resolve-AgentTargetWorktree`, block after "A branch registered only at a prunable root names that root and the repair remedy" | `$branches` is now `@(if (...) { ... } else { ... })`, and the detail names `$stale[0].Branch` and `$stale[0].Root` of the matching dropped record. The two AC-7 rows require `branch 'bug/item'` before the stale root. | None. | The detail now names the branch that the stale record carries, which also covers a second-record match that `$branches[0]` could not. | Commits `9e1ddc695` and `7d100cfc6`; fail-before 4 failures with `branch 'b'`; task check 504 passed; reviewer probes R1 to R7 on both surfaces; `cmp` of sources and mirrors |
| Info (CR1, carried) | `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-orchestrator-output-target.ps1` | consumers of `Resolve-SubagentStopTargetWorktree` | Both inherit the prunable exclusion and the working-directory source through the shared helper; the feature-review coverage hook has no dedicated pinning row. | Optional: one pinning row in the feature-review coverage suite. | Keeps the inherited decision visible to later helper edits. | Prior review; helper unchanged in the cycle |
| Info (CR2, carried) | `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | default `WorktreeListInvoker` | Calls `git` in a script block rather than an `Invoke-GitExe` wrapper, matching the composed `HookTargetWorktree.psm1` seam; the one uncovered line in each new file. | None required. | Consistent with the composed module. | Module text; coverage XML |
| Info (CR3, carried) | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`; removal gates | D9 default `BranchWorktreeResolver` | One worktree listing per rooted record that names no live root. | Optional: list once per gate call if record counts grow. | Bounded process count per hook call. | Prior review |
| Info (CR4) | `docs/features/active/2026-11-09-hook-session-root-resolution-1163/evidence/qa-gates/pester-parallel-final.2026-11-13T14-54.md` | Output Summary | The summary script read 0 skipped, while the JUnit root of the same run reports `disabled="10"`, equal to earlier runs. Test, failure, and coverage figures are correct. | None; evidence is append-only. | Recorded so a later reader does not infer a change in skipped tests. | Reviewer read of `artifacts/pester/pester-junit.xml` root element |
| Warning | `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | whole file | 750 logical lines (700-line advisory tier; the hard limit is 800). | Consider splitting the issue #1163 receipt-root Describe into its own suite in a later change. | File-size advisory tier. | `awk 'END{print NR}'` at head |

No covered file exceeds 800 logical lines, and `config/file-size-baseline.json` is not in the diff. Cycle files: module 207, Codex twin 201, rows helper 167 lines.

## Detailed Review

### F1 fix

```powershell
$branches = @(if (-not [string]::IsNullOrWhiteSpace($CommandBranch)) { $CommandBranch.Trim() } else {
        [regex]::Matches([string] $DelegationPrompt, $branchPattern) | ForEach-Object { ... }
    })
$stale = @($dropped | Where-Object { ... matches a branch in $branches ... })
...
$detailText = "branch '$($stale[0].Branch)' is registered only at the stale root '$($stale[0].Root)'; ..."
```

`@()` around the whole statement keeps one result as a one-element array, so the `$branches` filter compares whole strings. `$stale` now holds the dropped records produced by `ConvertFrom-HookTargetWorktreePorcelain` (properties `Root`, `Branch`, `Prunable`), so the detail reports the record's own branch and root as a pair. `StaleRegistration` is still projected from `$dropped` and is unchanged. Under strict mode, `$stale[0].Branch` is safe because the filter admits only records whose `Branch` is non-null.

Reviewer probes (module and Codex twin, in-memory porcelain):

- R1 one `branch: bug/x-1` label, `FailClosedOnIdentity`, prunable-only: `branch 'bug/x-1' is registered only at the stale root '/old/host/item'; run git worktree repair ...`.
- R2 `-CommandBranch 'bug/x-1'`: same detail.
- R3 two different labels: `TARGET_WORKTREE_AMBIGUOUS` (the D3 block does not run; unchanged behavior).
- R4 `-CommandBranch 'BUG/X-1'`: matches case-insensitively and names the recorded `bug/x-1`.
- R5 padded `'  bug/x-1  '`: trimmed; full name.
- R6 unregistered `bug/none`: keeps the existing "checked out in no registered worktree" detail.
- R7 two prunable records, command branch matching the second: names `bug/y-2` and `/old/b`.

### Test discrimination

The fail-before run (`evidence/regression-testing/fail-before.F1.2026-11-13T14-33.md`) recorded the two tightened rows failing in both shared-row suites with the observed text `branch 'b' ...`, and the task check after the fix recorded 504 passed. The rows therefore detect the defect the prior review described. The test change is pattern-only; the rows keep their names, inputs, and other expectations.

### Mirrors and invariants

`cmp` of the module and the Codex twin with their bundle mirrors: identical. `agent-target-worktree.Tests.ps1` holds the two function texts equal and passed in the cycle gate. The invariant paths are unchanged against the merge base.

## Verification Performed

- `git show 9e1ddc695 7d100cfc6`; `git diff --name-only d28a5645b..HEAD`.
- Direct resolver probes R1 to R7 on both surfaces through a scratchpad launcher.
- Parse of `artifacts/pester/powershell-coverage.xml` (written 14:53 UTC, after the 14:36 UTC fix commit) and the `pester-junit.xml` root element.
- `cmp` of sources and mirrors; `git diff --stat` of invariant paths; logical line counts.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.
- `git fetch origin main` and `git merge-tree --write-tree origin/main HEAD`: merge base unchanged, merge clean.

No reviewer Pester run was made: the owner directive allows only parallel full-suite runs, the cycle gate ran after the last production commit, and later commits add only documents.

## Verdict

**PASS.** F1 is resolved. No blocking finding; CR1 to CR4 and the Warning are non-blocking.
