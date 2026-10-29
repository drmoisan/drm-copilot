# Research: standalone orchestration merge-on-green (Issue #997)

- Branch: `bug/standalone-orchestration-merge-on-green-997`
- Inputs read: `issue.md`, `spec.md` (template only, no content yet), the promoted record, `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/research/research.2026-10-29T10-07.md` sections 7 to 9, and the files cited below.
- Filename stamp note: the `task-researcher` tool set has no clock. The stamp `2026-10-29T11-46` is the stamp of the sibling `plan.2026-10-29T11-46.md` written by the feature-folder tooling; the orchestrator may rename this file to the true write time.
- All line numbers below were read from the current tree (physical lines, via `Read` and `Grep` counts), not copied from the #995 research.

## Summary of Findings

1. Insertion point correction. The #995 research placed the new branch "directly after branch 1 (after line 354)". That is wrong for the parallel-exclusion requirement: the epic and parallel run targets are resolved only at lines 358-367. Insert the green-CI branch after the parallel allow-branch (after line 377), before the `Branch 4` comment at line 379. Branches 1 to 3 keep their order and behavior; the green branch is evaluated only when they decline.
2. The change is one dot-source line, one call, and one early-return in `enforce-epic-merge-gate.ps1` (about +14 lines, 460 to about 474), plus a new sibling `enforce-epic-merge-gate-green-ci.ps1` (estimated 110 to 140 lines).
3. Parallel children cannot be distinguished by the `Parallel mode: true` marker (it lives in the Agent delegation prompt, never in a Bash `PreToolUse` payload). A hook-checkable discriminator exists in two layers: the parallel-orchestrator checkpoint's `items[].pr_number` and `items[].worktree_path` (resolved through `Resolve-WorktreeRunTargetByRecord`), and a new child-recorded `parallel_mode` key. Both are best-effort; prose remains the final control. Details in section 2.
4. Only three Pester files pin the final deny string (`Authorization`, `MergeQueue`, `DocsOnly`). No existing test has a green standalone fixture, so no behavior test changes. Recommended default: keep the line-403 deny text unchanged except for appending, which still updates those three pins; see decision D3.
5. Mirrors: three Claude files change plus one new file under the bundle and `core.json`; four prose surfaces plus their bundle copies. The `epic-orchestrate` frozen hash does not need to be touched. One additional pin was found that the #995 research missed: `MERGE_ON_GREEN_FRAGMENTS` in `parallel_orchestrator_surface_expectations.py` line 236 pins the sentence "`.claude/skills/orchestrate/SKILL.md` is **not modified by this feature**" in the parallel-orchestrate skill.

## 1. Re-verification of the #995 Citations (sections 7 to 9)

| #995 claim | Current evidence | Status |
| --- | --- | --- |
| Gate header lines 5-38 state branches 1-4 and "a standalone run never satisfies conditions 1-3" | Header is lines 5-58 (docs-only and #690 text added). The sentence is lines 31-34. Branches are lines 10-27. | Moved, claim still true |
| `Test-ChildCheckpointAllowsEpicMerge` lines 142-169, `epic_mode` check line 162 | `enforce-epic-merge-gate.ps1` lines 142-169; line 162 `-not [bool]$Checkpoint.epic_mode`; `step9_status` line 165-168 | Verified |
| Decision lines 337-403, deny text line 403 | `Invoke-EpicMergeGateDecision` is lines 292-404; body logic 337-403; deny text line 403 | Verified |
| Authorization helper 443 lines, guidance string line 54 | `enforce-epic-merge-gate-authorization.ps1` is 443 lines; `$script:StandaloneAuthorizationGuidance` at line 54 | Verified |
| `Test-ChildCheckpointPrGateBinding` lines 153-203 in the resolution file | `enforce-epic-merge-gate-resolution.ps1` lines 153-205; resolution file is 278 lines | Verified (end line 205) |
| `Invoke-DocsOnlyGhExe` at `hook-docs-only-diff.ps1` line 281, 7 s bound | Line 281; default invoker `Invoke-DocsOnlyBoundedNative ... -TimeoutMilliseconds 7000` at line 304; timeout sets `LASTEXITCODE` 124 (line 221) | Verified |
| `--match-head-commit` reader at lines 429-432 | `Get-DocsOnlyPullRequestTarget` lines 428-434 use `Test-CommandLineFlag` and `Get-CommandLineFlagValue` | Verified (lines 428-434) |
| `.claude/settings.json` line 114 registers the hook | Not re-read in the repo copy; the bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` line 114 holds `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1` | Verified in the bundle copy; no settings change is needed because the hook is already registered |
| orchestrate SKILL S9 step 6 line 314; PR Creation Gate condition 7 line 379; line 381 "non-negotiable" | S9 step 6 is line 314; condition 7 line 379; "non-negotiable" line 381 | Verified |
| epic-orchestrate lines 122 and 150-151 | Line 122 ("Non-epic (standalone) orchestration is unchanged.") and lines 150-151 ("Standalone (non-epic) orchestration is unchanged: `epic_mode` absent or `false` makes S9 step 6 a no-op.") | Verified |
| parallel-orchestrate lines 373-377 and 414-454 | The merge procedure is now lines 363-417; "never instructed to merge" at lines 381-382; merge-gate authorization lines 419-459 | Stale (moved by about +5) |
| parallel-orchestrate marker lines 244-249 | Kickoff marker lines 244-250 | Moved slightly |
| `orchestrator-state.md` lines 234-306 | Standalone section is lines 234-256; the `## Enforcement` standalone bullet is line 315 (file is 318 lines) | Stale: corrected |
| `parallel-orchestration.md` line 689 | Line 689 (file is 690 lines) | Verified |
| cleanup skill lines 199-209 "human-performed" | `cleanup-merged-worktrees/SKILL.md` lines 200-201 | Verified (own contract, unchanged) |
| Codex `Test-CodexChildMergeReady` lines 87-103 | `.codex/hooks/enforce-epic-merge-gate.ps1` line 87 function, lines 97-101 conditions | Verified |
| `.agents/skills/orchestrate/SKILL.md` has no S9 merge text | Grep for `gh pr merge`, `epic_mode`, `merge-on-green` returned no match | Verified |
| `.claude/agents/orchestrator.md` has no merge text | `merge` occurs at lines 101 and 138 only (unrelated); frontmatter line 16 has `Bash(gh *)` | Verified; the agent already may run `gh`, so no agent edit is needed |

## 2. Design (items 1 and 2)

### 2.1 Exact insertion point

In `.claude/hooks/enforce-epic-merge-gate.ps1`:

- Add one guarded dot-source line after line 88 (the `hook-docs-only-diff.ps1` line), in the same pattern as lines 82-88:
  `try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-green-ci.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-green-ci.ps1' -ErrorRecord $_ }`
  with a one-line comment above it (issue #997). The new sibling calls `Invoke-DocsOnlyGhExe`, `Get-DocsOnlyMergeShapeViolation`, `Test-CommandLineFlag`, and `Get-CommandLineFlagValue` at call time only, so load order among siblings does not matter, but placing it after line 88 keeps the dependency visible.
- In `Invoke-EpicMergeGateDecision`, after the parallel allow-branch closes at line 377 and before the `# Branch 4` comment at line 379, add inside no new `if` (the green function itself returns `Allowed = $false` for a bare command):

  ```text
  # Branch 3b (issue #997): a standalone run with a green S9 gate merges its own PR.
  $greenCi = Get-EpicMergeGateGreenCiDecision -CommandText $commandText -CommandPrNumber $commandPrNumber -ChildCheckpoint $childCheckpoint -ItemTarget $itemTarget -EpicTarget $epicTarget -ParallelTarget $parallelTarget -SessionRoot $sessionRoot
  if ($greenCi.Allowed) { return Get-EpicMergeGateAllowDecision }
  ```

  The `$greenCi.Suffix` string (empty unless the live-head stage ran and failed) is appended to the branch-4 deny reason at line 400 alongside `$docsOnlySuffix`, which costs one more line. Net gate growth is about 14 lines including the header text (460 to about 474, below the 500-line guidance and below the cap asserted by `session-root-reads-850.Constraints.Tests.ps1`).
- Branch 1 (`Test-ChildCheckpointAllowsEpicMerge`) is not edited. It must keep returning `$false` for `epic_mode` false because `enforce-epic-merge-gate.Tests.ps1` lines 336-339 pin that.
- Header text (lines 5-38) changes: the branch list gains the new branch and the sentence at lines 31-34 is rewritten ("a standalone run satisfies condition 1-3 never; it merges only through the green-CI branch or a record under condition 4").

Why after line 377 and not after line 354: the parallel exclusion needs `$epicTarget` and `$parallelTarget`, which are not assigned until lines 358-367. Placing the branch earlier would force a second resolution call or a duplicate scan. It also keeps the ordering contract that branches 1 to 3 are unchanged and that the new route and the #670 route are both evaluated only after them. The cost is that the child checkpoint is read once (already done at line 350) and reused.

### 2.2 The sibling file `enforce-epic-merge-gate-green-ci.ps1`

Functions (PowerShell 7, advanced functions, `Invoke-<Tool>Exe`-style seams per `.claude/rules/powershell.md`):

1. `Test-ChildCheckpointGreenCiRecorded -Checkpoint -CommandPrNumber` (pure, no I/O). Returns `$true` only when all hold:
   - `CommandPrNumber` is non-null and greater than zero (a bare command never qualifies);
   - `epic_mode` is absent, `$null`, or a JSON boolean `false` (any other value, including a string, fails closed; `epic_mode` true is branch 1);
   - no parallel marker: `parallel_mode` absent or JSON `false`, and `parallel_slug` absent or blank (see 2.3);
   - `step9_status` is exactly `passed` (ordinal, as the validator `validate_orchestrator_state.py` line 135 compares exactly);
   - `ci_gate` is an object and `ci_gate.conclusion` is exactly `success`;
   - `pr_gate.pr_number` is present and parses as an integer equal to `CommandPrNumber`. No fallback to a `standalone_merge_authorizations` entry (unlike `Test-ChildCheckpointPrGateBinding`, resolution file lines 193-203): a record must not stand in for a CI result;
   - `ci_gate.head_sha` matches `^[0-9a-f]{40}([0-9a-f]{24})?$`, the same shape check as `hook-docs-only-diff.ps1` line 425;
   - when `pr_gate.head_sha` is present and non-null, it is ordinal-equal to `ci_gate.head_sha` (this mirrors the completion rule at `validate_orchestrator_state.py` lines 140-150, which applies only when `pr_gate.head_sha` is present).
2. `Get-EpicMergeGateLivePrHeadSha -PrNumber -WorktreeRoot` (the mockable seam). Runs `Invoke-DocsOnlyGhExe -WorkingRoot $WorktreeRoot -GhArgs @('pr','view',[string]$PrNumber,'--json','headRefOid')`; returns the head string when `ExitCode` is 0, the JSON parses to an object, and `headRefOid` matches the same hex shape; otherwise `$null`. Every failure path (non-zero exit, `-1` for a missing root, `124` for the 7 s timeout, unparseable JSON, malformed oid) returns `$null`. Tests mock this function by name (`Mock Get-EpicMergeGateLivePrHeadSha`) with a scriptblock returning a fixed string or `$null`; the wrapper's own body is covered by mocking `Invoke-DocsOnlyGhExe` (the established pattern: three existing suites already mock it at `BeforeAll`, for example `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` line 28). No test starts `gh` (never mock `gh` itself, per `powershell.md`).
3. `Test-EpicMergeGateGreenCiHeadAgreement -Checkpoint -LiveHeadSha -PinnedHeadSha` (pure). True only when `LiveHeadSha` is non-null and ordinal-equal to `ci_gate.head_sha`, and `PinnedHeadSha` is either `$null` (flag absent) or ordinal-equal to `LiveHeadSha`.
4. `Get-EpicMergeGateGreenCiDecision -CommandText -CommandPrNumber -ChildCheckpoint -ItemTarget -EpicTarget -ParallelTarget -SessionRoot` (orchestrator of the stages; returns `[ordered]@{ Allowed; Suffix }`). Stage order, cheapest first, so most merges make no `gh` call:
   - Stage A (pure, silent decline): `Test-ChildCheckpointGreenCiRecorded` fails, or `ItemTarget.Status` is not `SessionRoot` or `OtherWorktree`, or the checkpoint is `$null`. Returns `Allowed = $false`, `Suffix = ''`. A silent decline keeps every existing deny string byte-identical for non-green cases.
   - Stage B (pure, parallel exclusion, silent decline): `EpicTarget.Status` and `ParallelTarget.Status` must both be `NoTarget` (an `Ambiguous` or resolved target declines), and the child's own worktree must not be recorded as a parallel item (2.3 layer 1b).
   - Stage C (pure shape): `Get-DocsOnlyMergeShapeViolation -CommandText -PrNumber` must return `$null`. This reuses the M1 shape rules already proven for the docs-only branch: one structural `gh pr merge` segment, no chain or wrapper or substitution, no inline environment prefix, no `-R` or `--repo`, no `/pull/` URL selector, and no `--auto`. This closes the ambient `GH_REPO` and chained-command gaps the docs-only header documents (lines 44-51). A `gh api` merge or enqueue command is not a structural `gh pr merge`, so it cannot be authorized by this branch. Silent decline on failure.
   - Stage D (I/O): `Get-EpicMergeGateLivePrHeadSha`. On `$null`, decline with `Suffix = ' (green-CI merge not applied: GREEN_CI_LIVE_HEAD_UNRESOLVED)'`.
   - Stage E (pure): read the optional `--match-head-commit` with `Test-CommandLineFlag` and `Get-CommandLineFlagValue` (`gh`, `@('pr','merge')`), then `Test-EpicMergeGateGreenCiHeadAgreement`. On a stale checkpoint head decline with `GREEN_CI_HEAD_STALE`; on a pin that differs from the live head decline with `GREEN_CI_MATCH_HEAD_MISMATCH`. On agreement return `Allowed = $true`.

   Suffix codes appear only after stage D has run (the checkpoint is a plausible green candidate), so only a genuinely green-looking checkpoint changes any deny text.

### 2.3 Fail-closed cases

Each row is one unit test. "Decline" means the branch returns not-allowed and evaluation falls through to the epic, parallel, #670, and docs-only logic unchanged.

| # | Condition | Result |
| --- | --- | --- |
| 1 | Bare command (no PR number) | Decline; final line-403 text |
| 2 | Child checkpoint missing, unreadable, or ambiguous item target (`pr_gate.pr_number` matches no or several worktrees) | Decline |
| 3 | `epic_mode` true | Decline (branch 1 owns it) |
| 4 | `epic_mode` present but not a JSON boolean | Decline |
| 5 | `step9_status` absent, `pending`, `failed_remediation_required`, `blocked_ci_loop_limit`, or a case variant of `passed` | Decline |
| 6 | `ci_gate` absent, not an object, or `conclusion` `pending`, `failure`, absent, or a case variant of `success` | Decline |
| 7 | `pr_gate.pr_number` absent, null, non-integer, or different from the command number | Decline; a matching `standalone_merge_authorizations` entry does not count |
| 8 | `ci_gate.head_sha` absent, blank, uppercase, or not 40 or 64 hex | Decline |
| 9 | `pr_gate.head_sha` present and different from `ci_gate.head_sha` | Decline |
| 10 | Epic or parallel target resolved or ambiguous for the number | Decline |
| 11 | Child worktree recorded as a parallel item (`worktree_path`) | Decline |
| 12 | Child checkpoint carries `parallel_mode` true or a non-blank `parallel_slug` | Decline |
| 13 | Command not a single structural `gh pr merge` (chain, wrapper, `-R`, `--repo`, URL selector, inline env, `--auto`, `gh api` mutation) | Decline |
| 14 | `gh pr view` fails, returns exit 1, times out (exit 124), a missing root (exit -1), or returns unparseable JSON or a malformed oid | Decline with `GREEN_CI_LIVE_HEAD_UNRESOLVED` |
| 15 | Live head differs from `ci_gate.head_sha` (push after S9) | Decline with `GREEN_CI_HEAD_STALE` |
| 16 | `--match-head-commit` present and different from the live head | Decline with `GREEN_CI_MATCH_HEAD_MISMATCH` |
| 17 | Dot-source of the sibling fails | `Add-HookDependencyFailure` produces the existing fail-closed deny (the `hook-dependency-failure.SpecialCases.Tests.ps1` C3 pattern, line 162, is the model) |
| Positive | All checks pass and live head equals `ci_gate.head_sha` (and equals `--match-head-commit` when present) | Allow |

A residual limit shared with the docs-only branch: a push after the lookup changes the head unless `--match-head-commit` is passed. The skill prose (section 5) should instruct the orchestrator to pass `--match-head-commit <ci_gate.head_sha>`; the hook does not require it.

### 2.4 Parallel children (item 2)

Facts:
- The marker `Parallel mode: true` is in the `Agent(orchestrator)` delegation prompt (`parallel-orchestrate/SKILL.md` lines 244-250). The hooks that read it (`enforce-parallel-cohort-barrier.ps1` line 255, `enforce-parallel-drift-gate.ps1` line 338, `enforce-orchestration-preimplementation-gate-modes.ps1` line 60) are `Agent`-matcher hooks that see prompts. A Bash `PreToolUse` payload for `gh pr merge` carries only `tool_input.command` and `session_id`; no prompt. The marker is therefore invisible to the merge gate. Verified by reading the three marker sites and the gate's payload use (`Get-ClaudeHookToolInputString -Name 'command'`, `Get-ClaudeHookEnvelopeValue -Name 'session_id'`).
- A child's per-feature checkpoint carries no parallel indicator today (`orchestrate/SKILL.md` has no `parallel_mode` clause; `parallel-orchestrate/SKILL.md` lines 365-368 state this explicitly). The validators reject no unknown top-level key (no `additionalProperties`, unknown-key, or extra-key match in `scripts/dev_tools/*orchestrator_state*.py`), so a new key is tolerated, as `epic_context` and `epic_merge` are (`epic_merge` is referenced by no validator or hook).

Hook-checkable discriminators, in decreasing strength:

- Layer 1a, run target by PR number (no new I/O): `$parallelTarget` and `$epicTarget` from `Resolve-EpicMergeGateRunTarget` are already computed at lines 363-364. The green branch requires both to be `NoTarget`. Limit: the parent records `items[].pr_number` when the child reports the PR open (`parallel-orchestrate/SKILL.md` line 679, `worktree_created` to `pr_open`), so a child that merges before the parent records it is not caught by 1a.
- Layer 1b, run target by worktree path: call `Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField worktree_path -Value <item worktree root> -SessionRoot (Get-Location).Path` (`WorktreeRunResolution.psm1` lines 391-438, exported at line 486; the `worktree_path` field is supported at lines 361-389 including the issue #995 relative-path matcher). Wrap it in a one-line seam (for example `Resolve-EpicMergeGateParallelItemByWorktree`) in the sibling so tests mock it. The skill records `worktree_path` at spawn (`SKILL.md` lines 227-228), before the child runs. Limits: line 1115-1116 says the field is optional and may be null, and line 541 says it can be relative; the #995 matcher handles relative values but a null record matches nothing.
- Layer 2, child-recorded key: the kickoff gains one sentence telling the child to record top-level `parallel_mode: true` and `parallel_slug` in its first checkpoint write, as the epic kickoff does for `epic_mode` (`epic-orchestrate/SKILL.md` lines 145-147). The green branch declines when the key is present. Limit: it depends on agent behavior and is therefore the fail-open direction when omitted.
- Layer 3, prose: S9 step 6 and the parallel skill state that a parallel item never merges itself and that the parent merges and confirms each item.

Honest assessment: layers 1a and 1b are mechanical and independent of agent behavior, but neither covers the window in which the parent has recorded neither the PR number nor a non-null `worktree_path`. Layer 2 narrows that window only when the child complies. No Bash-time mechanism can close it completely, because the hook has no access to the delegation prompt. The control is therefore policy-level, the same disclosure the repository makes for the #670 record (`orchestrator-state.md` line 240-242 and the gate header lines 66-70). Recommendation: implement layers 1a, 1b, and 2 with layer 3, and record the residual window in the hook header and the rules text. Layer 1b is the one that most reduces risk per line changed, because the worktree is recorded at spawn.

An alternative considered and rejected for the first delivery: require the green branch to be allowed only from a session whose `git rev-parse --abbrev-ref HEAD` is not a parallel item branch. The branch name carries no parallel marker, so it would need the parallel checkpoint anyway.

## 3. File Sizes (item 3)

Tier policy on `main` (`.claude/rules/general-code-change.md` lines 51-52 and the execution-environment brief): 500 lines is guidance (look for a logical split), 700 is an advisory Warning, above 800 is a hard block (exactly 800 passes). Production, test, and reusable script files are counted; Markdown is exempt. `config/file-size-baseline.json` has no entry for any `enforce-epic-merge-gate*` file. In addition, `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` (lines 39-73, test at line 86) separately asserts a 500-line cap on the gate, the resolution file, and several merge-gate suites. That test is stricter than the tiered policy, so the 500-line figure is a working cap for these files.

Physical line counts (`Grep` count of `^`, which counts every physical line):

| File | Lines now | Expected after | Touched |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 460 | about 474 | yes |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 443 | 443 | no (the #670 branch is kept as is) |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | 278 | 278 | no |
| `.claude/hooks/enforce-epic-merge-gate-command.ps1` | 190 | 190 | no |
| `.claude/hooks/hook-docs-only-diff.ps1` | 497 | 497 | no (reused, not edited; at 497 lines it has about 3 lines of headroom) |
| `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` | new | 110 to 140 estimated | yes |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 471 | 471 | do not add tests here |
| `...Authorization.Tests.ps1` | 183 | 183 | one-line pin edit |
| `...MergeQueue.Tests.ps1` | 204 | 204 | one-line pin edit |
| `...DocsOnly.Tests.ps1` | 216 | 216 | one-line pin edit |
| New suite(s) | new | each below 500 | yes |
| `.claude/skills/orchestrate/SKILL.md` | 464 | about 475 | Markdown exempt |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 1296 | about 1310 | Markdown exempt |
| `.claude/rules/orchestrator-state.md` | 318 | about 325 | Markdown exempt |
| `.claude/rules/parallel-orchestration.md` | 690 | about 692 | Markdown exempt |

Do not add logic to `hook-docs-only-diff.ps1` (497 lines): the new seam lives in the new sibling. Because the sibling owns all new logic and the gate takes only the dot-source and the call, no existing file crosses 500.

## 4. Tests That Pin Current Behavior (item 4)

### 4.1 Deny-text pins (must change if the text changes)

Two independent strategies, both enumerating test files that assert the exact Claude final deny string:

- Strategy A (phrase): `Grep` for `requires either a per-feature checkpoint` over `tests/scripts/claude-hooks`.
- Strategy B (symbol): `Grep` for the variables that hold that text, `DenyText|Line433Text|BareDeny`, over `enforce-epic-merge-gate*.Tests.ps1`.

Both return the same three files; see the Numeric Derivation Evidence section. They are:
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` line 85 (`$script:Line433Text`), asserted at line 154 with `-BeExactly`.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` line 46 (`$script:DenyText`), used at line 188.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` line 63 (`$script:BareDeny`), used at line 183.

The Codex copies pin a different string (`requires a safe epic child checkpoint or a successful final epic CI gate...`) in `codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` line 55, `...-docs-only.Tests.ps1` line 59, and `...-authorization.Tests.ps1` line 79; they are unaffected while the Codex twin is deferred.

Recommended default (D3): update the line-403 text to add the new route and change the three pins in the same commit, so the deny message that the user sees describes every allowed route. The alternative, leaving the text unchanged, avoids touching three tests but gives a message that omits the new route. Because only the final (bare command) deny uses this text, the new suffix codes do not alter it.

### 4.2 Behavior pins

Two strategies again:
- Strategy 1 (decision entry point): files referencing `Invoke-EpicMergeGateDecision`, `Test-ChildCheckpointAllowsEpicMerge`, or `enforce-epic-merge-gate.ps1`: the nine Claude merge-gate suites (`Tests`, `Authorization`, `AuthorizationFields`, `Coverage`, `DocsOnly`, `ItemResolution`, `MergeQueue`, `TriggerScoping`, `WorktreeResolution`), plus `hook-dependency-failure.Claude.Tests.ps1` line 78, `hook-dependency-failure.SpecialCases.Tests.ps1` line 162, `session-root-reads-850.Constraints.Tests.ps1` lines 43-44, `hook-command-parser.AcceptanceCases.Tests.ps1`, and `hook-command-consumers.Issue824.Tests.ps1`.
- Strategy 2 (fixtures): `Grep` for `ci_gate|head_sha|step9_status|epic_mode` in the nine suites. Every `step9_status` fixture is either `epic_mode: true` (branch 1), carries no `ci_gate`, or is a helper-level test. The one decision-level fixture without `epic_mode` is `AuthorizationFields.Tests.ps1` line 180 (`plain = @{ step9_status = 'passed' }`), consumed at line 188 by `Test-StandaloneCheckpointAllowsMerge` directly, not through the decision. No existing fixture records `ci_gate` on a per-feature checkpoint.

Result: no existing behavior assertion contradicts the new branch. The two decision-level suites that mock `Resolve-EpicMergeGateRunTarget` to a resolved `SessionRoot` status (`Authorization.Tests.ps1` lines 86-87) cause Stage B to decline, so they keep their expectations. The shape that already works: `Mock Invoke-DocsOnlyGhExe { ExitCode 1 }` in `BeforeAll`, which makes the live-head seam return `$null` (fail closed) in every existing suite.

Unchanged but must stay green (each pins a contract the change relies on): `enforce-epic-merge-gate.Tests.ps1` lines 336-339 (`epic_mode` false returns false) and 341-350; `ItemResolution.Tests.ps1` lines 185-214, 243, 302; `WorktreeResolution.Tests.ps1` lines 129-146; `AuthorizationFields.Tests.ps1` (20+ cases of the #670 branch).

### 4.3 Documentation pins (Python)

- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` line 236: the parallel-orchestrate merge section must still contain "`.claude/skills/orchestrate/SKILL.md` is **not modified by this feature**". That sentence is historically about the parallel feature and is true of it; do not edit or delete it. Add a new sentence after it recording the #997 amendment, as the #744 amendment paragraph (lines 370-374) does. The same file's `MERGE_ON_GREEN_FRAGMENTS` also pins "Execute `gh pr merge --merge <PR>`" (line 235), which stays.
- `tests/scripts/dev_tools/merge_queue_documentation_expectations.py` lines 61-77: `claude-orchestrate-s9` and `claude-orchestrate-pr-gate` pin `epic_merge.merge_commit_sha is recorded only after the merge is confirmed by polling and ancestry check` (S9 step 6 and condition 7), `awaiting_merge_queue` with `Remediability: awaiting_ci`, and "`gh pr merge` is never re-issued in a loop after `not_queued`". Keep those fragments verbatim and add the standalone case as new sentences.
- `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` (S9 fragments, lines 51-61) and `test_ci_gate_epic_child_contracts.py` (S9 epic fragments, lines 57-166, 197-199: the S9 step 3 parser command keeps its path and `-HeadSha` on one line): not touched provided step 3 is not edited.
- `test_completion_gate_documentation_contracts.py` lines 215-226 pin PR Creation Gate condition 2 wording: do not edit condition 2.
- Mirror equality of each edited surface is pinned by `test_push_down_claude_resource_contracts.py`.

## 5. Prose and Rules to Update (item 5)

| File | Lines | Change |
| --- | --- | --- |
| `.claude/skills/orchestrate/SKILL.md` S9 step 6 | 314 | Add the standalone case. Preferred shape: keep the existing epic sentence untouched, and add a new numbered step 7 (or a following paragraph) so the pinned epic fragments are not disturbed. The new text: when `epic_mode` is absent or `false`, no `Parallel mode: true` marker was supplied in the kickoff, the route requires S9 (not `preparation`), and the PR base branch is `main`, execute `gh pr merge --merge <PR> --match-head-commit <ci_gate.head_sha>` after step 5, then confirm with the step 3 procedure of `## Per-Item Merge to Main (Merge-on-Green)` (`gh api graphql` query, `Invoke-MergeConfirmationParser.ps1`, fetch, and `git merge-base --is-ancestor`). Record `pr_merge: { merge_commit_sha, target_branch, merged_at }` (an unvalidated key, like `epic_merge`; see D4). `not_queued` and `closed` outcomes follow the same handling as step 6. A parallel item never merges itself. |
| `orchestrate/SKILL.md` PR Creation Gate condition 7 | 379 | Keep the sentence naming `epic_merge.merge_commit_sha ... (S9 step 6)` verbatim (pinned) and add an alternative: `epic_mode` is `false` and the run is a standalone run, in which case DONE requires `pr_merge.merge_commit_sha` once the merge is confirmed. Line 381 ("conditions 5-7 are additive") needs one clause. |
| `.claude/skills/orchestrate/SKILL.md` Checkpoint Schema | 332-335 | Add a `pr_merge` bullet beside `epic_merge`. |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 365-368, 378-382, 419-459 | Keep line 366 untouched (pinned). Add a sentence that #997 amends the child contract for standalone runs only, that a parallel child still never merges its own PR (the parent performs steps 2 to 4), and that the child records `parallel_mode: true` (kickoff, near line 259-266). Update the merge-gate authorization paragraph (lines 419-433): five allow conditions, the new one evaluated after the parallel condition and before the #670 record, and the standalone condition paragraph (line 435) stops saying it is "the only route" for a standalone merge; it remains the only route for a merge with no green S9. |
| `.claude/rules/orchestrator-state.md` | 234-242 (section intro), 315 (Enforcement bullet) | Add a short subsection "Green-CI standalone merge (issue #997)" stating the conditions, that `parallel_mode` and `parallel_slug` are tolerated unvalidated keys, and that the policy-level disclosure applies. Update the bullet at line 315 to name the new sibling. Line 240-242 disclosure text is kept. |
| `.claude/rules/parallel-orchestration.md` | 689 | Extend the merge-gate Enforcement bullet: after the parallel allow-branch, a standalone green-CI branch applies only when no parallel or epic checkpoint records the PR or the item worktree. |
| `.claude/skills/epic-orchestrate/SKILL.md` | 122, 150-151 | Both lines say standalone orchestration is "unchanged" and that S9 step 6 is a no-op for `epic_mode` absent or false. After #997 that is stale for step 6 (the epic skill describes the epic flow; the standalone merge is a different step). Do not edit: this is a frozen surface (`PINNED_FROZEN_SURFACE_HASHES`, `parallel_orchestrator_surface_expectations.py` lines 177-186, the skill digest `84b0555d...`). The wording remains true as scoped to the epic skill's own contract ("Standalone orchestration is unchanged" in epic terms), because the epic flow itself is unchanged. If the user wants the sentence corrected, that needs a pinned-hash update and a new `RE-BASELINED` comment; recommend not touching it (D6). |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | 200-201 | No change. That text is the cleanup skill's own contract ("human-performed" consolidation PR). |
| `.claude/agents/orchestrator.md` | frontmatter line 16 | No change. `Bash(gh *)` is already granted. |
| Gate header, final deny text | `enforce-epic-merge-gate.ps1` lines 5-38, 403 | As in 2.1 and 4.1. |

The `.claude/rules` files and skills carry no consuming-product name (`test_push_down_issue_824_follow_ups.py`); keep that true.

## 6. Mirrors, Manifests, Codex, Automation Feasibility (item 6)

### 6.1 Mirrors and manifests

Under `extensions/drm-copilot/resources/claude-customizations/`:
- Edited files need byte-identical copies: `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md` (all five exist in the bundle, verified by `Glob`).
- The new `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` needs a bundle copy and one entry in `pack-manifests/core.json` next to lines 34-37 (the four existing merge-gate files are listed there; `hook-docs-only-diff.ps1` is at line 77). The new file dot-sources nothing by `$PSScriptRoot` itself, but the gate dot-sources it, so `test_push_down_pack_manifest_dependency_closure.py` requires it in the manifest.
- `.claude/settings.json` is unchanged (the gate is already registered; the sibling is not a registered hook). `config/file-size-baseline.json` and `config/blast-radius.json` need no entry (no `enforce-epic-merge-gate` match in `config/`).
- Contract tests to run after edits (from the brief): `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `claude-hooks` Pester suites, `hook-dependency-guard-completeness.Tests.ps1`, `parallel_orchestrator_surface_expectations.py` consumers, and the merge-queue documentation contract.
- The execution-environment brief states no merge-gate fact, so it is not edited, and its six copies stay byte-identical. The plan's `Mirror parity` bullet should say so with this reason.
- The Codex generator `--check` and `core.json` of the Codex bundle are unaffected while the Codex twin is deferred.

### 6.2 Codex twin decision: defer

Recommendation: defer, as the #995 research also did (decision D7), for these reasons:
- The Codex hook is a separate implementation (`.codex/hooks/enforce-epic-merge-gate.ps1`, `Test-CodexChildMergeReady` lines 87-103, no worktree resolution, no docs-only seam parity with the Claude gate), so the same change is a second design, not a mirror.
- The Codex orchestrate skill (`.agents/skills/orchestrate/SKILL.md`) has no merge-on-green text at all (no match for `gh pr merge`, `epic_mode`, or `merge-on-green`), so the Codex runtime has no instruction that would exercise a new Codex branch.
- Codex tests pin a different deny string and are independent (`codex-hooks/enforce-epic-merge-gate-*.Tests.ps1`).
- Isolated subagent runs use `main`'s hook copies, so a Codex change adds no proof until merged.
Open follow-up: record a separate issue for the Codex twin if the user wants Codex standalone runs to merge themselves.

### 6.3 Automation Feasibility

- Hook logic, sibling file, and all Pester suites: fully automatable by `atomic-executor`. The pure functions need no `gh`. The seam is mocked by name. No temporary files are needed.
- Pester runs cannot go through the PoshQC MCP result (it carries no output). Pass and fail counts come from `artifacts/pester/pester-junit.xml` and per-file coverage from `artifacts/pester/powershell-coverage.xml`, after a `sh`-launched PowerShell 7 run of `Invoke-PoshQCTest` (execution-environment brief). Line coverage of at least 85 percent applies to the new sibling and the edited gate.
- Branch-hook behavior cannot be proven by an isolated subagent (hooks run `main`'s copies): the Pester suites are the proof. A live repro (a standalone orchestration merging its own green PR, and a parallel child still not) needs a non-isolated run from this branch's worktree after merge and cannot be an acceptance fact beforehand. The issue's "Integration scenario to retest" must be labeled a live-verification item with a stated deferral.
- Documentation and mirror edits: automatable; contract tests listed above prove parity.
- The pinned edits (three deny-text tests, one doc fragment decision) are automatable but must name each test in the plan (preflight defect class: tests asserting changed behavior outside the task's file set).
- Batch budget: the change touches more than three production PowerShell files (gate, sibling, bundle copies and any helper) and so needs the orchestrated large path (`powershell.md` Change Budget). Bundle copies count against the cap.
- Merge-confirmation flow in S9 is prose for the orchestrator; it is not testable beyond the documentation fragment tests.

## 7. Open Decisions with Recommended Defaults

| ID | Decision | Recommended default |
| --- | --- | --- |
| D1 | Insertion point: after branch 1 (line 354) as in #995, or after the parallel branch (line 377) | After line 377, because the parallel and epic targets are needed for the exclusion |
| D2 | Parallel exclusion strength | Layers 1a, 1b, 2, and 3 (section 2.4); state the residual window in the hook header and rules; do not claim it is mechanically closed |
| D3 | Deny text at line 403 | Update it to describe the new route and change the three pinned tests together |
| D4 | Where the standalone merge result is recorded | New top-level `pr_merge` object, unvalidated like `epic_merge`; a validator change is out of scope (follow-up if wanted) |
| D5 | Does the hook require the pull request base to be `main` | No. The merge gate treats every base alike today. Require `main` in the skill prose; add a hook check (`baseRefName` from the same `gh pr view`) only if the user wants it |
| D6 | Edit `epic-orchestrate/SKILL.md` lines 122 and 150-151 | No. Frozen hash; the statements are scoped to the epic flow. Revisit only with a deliberate re-baseline |
| D7 | Codex twin | Defer; file a follow-up if wanted |
| D8 | Require `--match-head-commit` in the command | Not required by the hook (residual push-after-lookup window stated); the skill instructs the orchestrator to pass it |
| D9 | Retire the #670 branch | No. Keep it for merges with no green S9 (parallel-orchestrate skill lines 435-450) |
| D10 | Same issue or separate | This is already the separate issue #997 (the #995 section 9 recommendation was followed). #995 and #997 both edit `parallel-orchestrate/SKILL.md`, `orchestrator-state.md`, and `parallel-orchestration.md`; the #995 PR merged first (git log shows #998), so rebase on `main` before editing |
| D11 | Which routes may self-merge | Routes with S9 required (`route_requires_ci_gate`, `_orchestrator_state_route_gates.py` line 141); the `preparation` route (`requires_ci_gate: false`) never merges. State this in the S9 prose |

## Candidate Approaches (summary)

| Approach | Verdict |
| --- | --- |
| A. New sibling with pure checkpoint check plus a mockable live-head seam, one call in the gate after branch 3 (selected) | Smallest gate change, no file over the cap, every case unit-testable, `epic_mode` branch untouched |
| B. Widen `Test-ChildCheckpointAllowsEpicMerge` to accept a green standalone checkpoint | Rejected. It is a pure, `gh`-free function pinned by `enforce-epic-merge-gate.Tests.ps1` lines 336-339, and it has no access to the live head or the run targets |
| C. Add the logic to `enforce-epic-merge-gate-authorization.ps1` | Rejected. 443 lines plus about 70 would exceed 500 and mixes the CI route with the #670 record logic |
| D. Auto-write a `standalone_merge_authorizations` record when S9 passes | Rejected. It makes the record meaningless (a same-session forgery path, `orchestrator-state.md` lines 240-242) and writes no live-head check |

## Testing Implications

- Pester 5 only; no temporary files; mocks scoped to `BeforeAll`/`BeforeEach` (state of mocks must not leak: the merge-gate suites mock `Invoke-DocsOnlyGhExe`, the three checkpoint read seams, and the two item and run resolvers).
- New suites (each below 500 lines; do not extend `enforce-epic-merge-gate.Tests.ps1`, which is 471 lines and capped by the 850 constraints test): `enforce-epic-merge-gate.GreenCi.Tests.ps1` (pure function matrix, one `It` per row in 2.3) and `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` (end-to-end decision through `Invoke-EpicMergeGateDecision` with `Set-MergeReadSeam`-style helpers, the allow case, and the paired parallel-child decline cases with `Resolve-EpicMergeGateRunTarget` returning `NoTarget` versus `SessionRoot`). Cover the wrapper body by mocking `Invoke-DocsOnlyGhExe` for exit 0, exit 1, exit 124, exit -1, unparseable JSON, and a malformed oid.
- Register the baseline mock family used by the other gate suites (`Register-EpicStateBaselineMock` and `Invoke-EpicStateInterceptionProbe`, as in `session-root-reads-850.Constraints.Tests.ps1` lines 20-35 and `enforce-gate-suites.EpicStateIsolation.Tests.ps1`) so a new suite cannot read a live checkpoint.
- Add the new suite file names to the `NewSuites` list in `session-root-reads-850.Constraints.Tests.ps1` only if the plan wants them under that cap check (that file is itself 500-line capped; recommend not editing it).
- Fixtures use `/synthetic-worktrees/<name>` roots and `Join-Path`; no drive letters (Linux hook-suite job, case-sensitive).
- Live head values are 40-hex literals defined in the test; no real SHAs are needed.

## Numeric Derivation Evidence

No numeric acceptance criterion is proposed. The following supports the prose claim "three Claude Pester files pin the exact final deny string", which a spec may quote only if the evidence below is accepted.

- Complete Family: Claude Pester test files under `tests/scripts/claude-hooks/` whose source contains the exact Claude merge-gate final deny string of `enforce-epic-merge-gate.ps1` line 403 (the Codex string is a different family).
- Exhaustive Search Scope: every file matching `tests/scripts/claude-hooks/enforce-epic-merge-gate*.Tests.ps1` (nine files: `Tests`, `Authorization`, `AuthorizationFields`, `Coverage`, `DocsOnly`, `ItemResolution`, `MergeQueue`, `TriggerScoping`, `WorktreeResolution`); the same phrase search was also run over all of `tests/scripts` with the broader alternation `per-feature checkpoint|epic_mode == true|never satisf|standalone run`, which surfaced no additional deny-string pin (the 14 hits were fixture or contract tests unrelated to the string; for example `Invoke-CiGateParser.Tests.ps1` matches `never satisf` in unrelated text).
- Inclusion Rules: the file holds the full text `EPIC_MERGE_GATE_BLOCKED: a pull-request merge or merge-queue enqueue ... No checkpoint satisfied this gate.` in a variable it later compares.
- Exclusion Rules: Codex tests (different text); suites that only match a deny by token or `-Match`; Python documentation tests.
- Primary Search Strategy or Query Expression: `Grep` pattern `requires either a per-feature checkpoint` over `tests/scripts/claude-hooks`.
- Primary Member Set: `enforce-epic-merge-gate.DocsOnly.Tests.ps1` (line 63), `enforce-epic-merge-gate.Authorization.Tests.ps1` (line 85), `enforce-epic-merge-gate.MergeQueue.Tests.ps1` (line 46).
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: `Grep` pattern `(DenyText|Line433Text|BareDeny)` (the variable names that hold and use the string) over `enforce-epic-merge-gate*.Tests.ps1`, output as matches with `-o`.
- Cross-check Member Set: `MergeQueue` (lines 46 and 188), `DocsOnly` (lines 63 and 183), `Authorization` (lines 85 and 154).
- Cross-check Count: 3.
- Member-set Comparison: after normalizing to file names, the two sets are identical (`Authorization`, `DocsOnly`, `MergeQueue`); each file appears with a definition line and a use line in strategy B, and the definition line coincides with the phrase line in strategy A. No disagreement.

## Pre-Mortem

- Review checklists: a reviewer could find that the green branch can fire for a parallel child (the marker is invisible to the hook), that `epic_mode` handling accepts a truthy string, or that a deny pin was left stale. Mitigation: the plan carries the fail-closed matrix of section 2.3 as one test per row, including the paired parallel decline rows (run target by PR number, by worktree path, by `parallel_mode`), `epic_mode` as a string, and the exact-case rows for `passed` and `success`; the hook header and rules state the residual window honestly; a grep check task confirms the three pinned strings and the `Line433Text` use were updated together.
- Coverage: the sibling is new and the live-head wrapper is I/O-thin, so the wrapper body and the decision stages could fall below the 85 percent line threshold per file. Mitigation: every stage is a function with a parameter-driven test; the wrapper body is exercised through a mocked `Invoke-DocsOnlyGhExe` with six outcomes; coverage is read from `artifacts/pester/powershell-coverage.xml` per file (not from the MCP result, which carries no output); no branch gate exists for PowerShell.
- Mirror parity: five edited Claude files need byte-identical bundle copies and the new hook needs a bundle copy plus a `core.json` entry, or `test_push_down_claude_resource_contracts.py`, the manifest-completeness test, and the dependency-closure test fail. Mitigation: one plan task per file pair, a final run of the three contract tests and the Pester hook suites; the plan states that the execution-environment brief is unchanged because it states no merge-gate fact, and that the Codex bundle is unchanged because the Codex twin is deferred (decision D7).
- File size: the gate is 460 lines, `hook-docs-only-diff.ps1` is 497, and the 850 constraints test caps the gate and `enforce-epic-merge-gate.Tests.ps1` (471) at 500 lines. Adding logic inline or tests to the 471-line suite would break the cap. Mitigation: all new logic goes in the new sibling, the gate takes only about 14 lines, new tests go in new suites, `hook-docs-only-diff.ps1` is reused unedited, and the plan records `wc -l` counts before and after.
- Test isolation: the merge-gate suites mock `Invoke-DocsOnlyGhExe` and the checkpoint seams at `BeforeAll`, and a new suite that omits a seam mock could read a live checkpoint or start `gh`, and leaked mocks could change shuffled-order results. Mitigation: new suites register the baseline mock family and the interception probe, mock the live-head seam by name, create no files, and the plan records the three seeded shuffled Pester runs plus a single-process full run under `evidence/regression-testing/`.
- CI-only behavior: the Linux hook-suite job is case-sensitive and uses forward slashes, and the `shell-coverage` and docs checks do not run these suites. Mitigation: fixtures use `/synthetic-worktrees/...` roots and `Join-Path`; no test reads gitignored `artifacts/` state; the new sibling is covered by the Linux hook-suite job (`tests/scripts/claude-hooks`) without extra configuration; the new sibling name uses exact case.
- Evidence: the acceptance scenario "a standalone orchestration merges its own green PR; a parallel child still does not" cannot be run from an isolated subagent (hooks are `main`'s copies) and the PoshQC MCP result carries no output. Mitigation: the plan labels the scenario a post-merge live-verification item with an explicit deferral, takes counts only from the JUnit and coverage files, and does not state a live result as an acceptance fact.
