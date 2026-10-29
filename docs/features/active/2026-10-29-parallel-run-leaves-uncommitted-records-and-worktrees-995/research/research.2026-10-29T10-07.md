# Research: parallel run leaves uncommitted records and worktrees (Issue #995)

- Timestamp: 2026-10-29T10-07 (UTC; read from an external time service because the researcher has no shell clock; the value is not estimated)
- Issue: #995, branch `bug/parallel-run-leaves-uncommitted-records-and-worktrees-995`
- Work mode: full-bug
- Method: file reads and searches only. The researcher has no Bash, so no Pester, git, or gh command was run; every behavior claim below is read from source, and anything that needs a live run is marked UNVERIFIED.
- Additional scope received during the task: whether the prohibition on a standalone orchestration merging its own green PR can be removed (sections 7 to 9).

## Summary of Findings

1. The removal denial is a path-form mismatch, not a root-resolution failure. The checkpoint records `items[].worktree_path` as `.claude/worktrees/agent-...`, relative to the main checkout. Every matcher compares that string to the absolute path in the command after only a separator and trailing-slash normalization. The run-resolution module, both removal gates, one diagnostics helper, and the manifest coverage test each carry their own copy of that comparison. Fixing one leaves the denial in place.
2. Records can be committed and landed with no gate change. The pre-implementation gate already exempts `git add` / `git commit` whose every pathspec is inside `docs/features/{parallel,potential,active,epics}/` or `artifacts/orchestration/`, and the pr-author and merge gates already carry docs-only exemptions. The gap is prose (no closing step) plus one agent tool (`Agent(pr-author)` is not in `parallel-orchestrator`'s `tools:`).
3. Planner scratch worktrees cannot be authorized by any checkpoint, and no hook change is recommended. They are reachable only through the sanctioned cleanup tool or by not creating them.
4. A hook fix alone does not remove a worktree that the agent harness has locked. Item #990's registration carries a lock; item #989's does not at research time.
5. The merge prohibition is enforced by one hook branch and described in about ten prose locations. A new sibling file can add a green-CI branch without touching the #670 authorization branch. It belongs in its own issue.

## 1. Worktree-Removal Hook

### Which hooks produce the denial

Two hooks fire on `git worktree remove`, and PreToolUse denials are conjunctive, so both must allow.

| Hook | Reason prefix | Registered |
| --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `EPIC_WORKTREE_REMOVAL_BLOCKED` | project-wide Bash matcher |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `PARALLEL_WORKTREE_REMOVAL_BLOCKED` | `.claude/settings.json` line 122 |

The issue's snippet comes from the epic gate. `Get-EpicWorktreeRemovalTargetDenial` (epic gate lines 340-405) prepends the resolution reason when both run kinds resolve `NoTarget` (lines 399-402). The text `no live worktree's run checkpoint records worktree_path '<abs>'` is built in `Resolve-WorktreeRunMatch` (`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` lines 223-226). The separate literal `TARGET_WORKTREE_NOT_DERIVABLE` at epic gate line 329 is for a command whose target cannot be parsed; it is not the cause here.

### Exact matching code

All paths are compared as strings. None is made absolute.

| Matcher | File and lines | Compares |
| --- | --- | --- |
| Run resolution | `WorktreeRunResolution.psm1` `Test-WorktreeRunCheckpointRecord` lines 376-403, compare at line 400 via `Test-WorktreeRunPathEqual` lines 344-358 | recorded value vs command target: trim, `\` to `/`, trailing `/` removed, ordinal (case-insensitive only if either side starts with a drive letter or `//`) |
| Parallel gate | `enforce-parallel-worktree-removal-gate.ps1` `Find-ParallelWorktreeItemRecord` lines 161-212, compare lines 197 and 206-207 | same normalization, `-eq` |
| Epic gate, features | `enforce-epic-worktree-removal-gate.ps1` `Find-EpicWorktreeFeatureRecord` lines 116-159, compare lines 144 and 153 | same |
| Epic gate, parallel items | `enforce-epic-worktree-removal-gate.ps1` `Test-ParallelCheckpointAllowsWorktreeRemoval` lines 188-250, compare lines 227 and 239 | same |
| Epic gate diagnostics | `enforce-epic-worktree-removal-gate-resolution.ps1` `Find-EpicWorktreeGateParallelItemRecord` lines 130-177, compare lines 162 and 171 | same (deny text only) |
| Manifest coverage | `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` `Test-CleanupManifestCheckpointCoversPath` lines 345-407, compare lines 391 and 401 | same |

The command target is the absolute path from the command text. The recorded value is `.claude/worktrees/agent-...`. They are never equal, so resolution returns `NoTarget`, no checkpoint is read, and the gate falls to the deny.

Evidence from this run's real checkpoint (`artifacts/orchestration/parallel-orchestrator-state.json`, gitignored, present in the planning worktree): `route_id` `parallel` (line 3); item worktree paths `.claude/worktrees/agent-a018d4484e12bf5ae` (line 113) and `.claude/worktrees/agent-aeaa20a879b932016` (line 249); both `merge_status` `merged` (lines 117 and 253). Line 27 of the same file records the deferral and states the recorded path is relative to the main checkout.

### Which checkpoint root is read

Root selection is correct today and needs no change.

- `Resolve-ParallelWorktreeGateRunTarget` (parallel gate line 120) and `Resolve-EpicWorktreeGateRunTarget` (epic resolution file lines 74-93) pass `(Get-Location).Path` as `SessionRoot`.
- `Get-WorktreeRunLiveRoot` (`WorktreeRunResolution.psm1` lines 196-211) calls `Get-WorktreeItemLiveRoot` (`WorktreeItemResolution.psm1` lines 180-215), which ascends to the session worktree and enumerates every registered root through `Get-WorktreeResolutionWorktreeRoot` (`WorktreeResolution.psm1` lines 334-404). That list contains the main checkout first (lines 368-371) and every linked worktree from `<common .git>/worktrees/*/gitdir`.
- The planning worktree is a linked root, so its `artifacts/orchestration/parallel-orchestrator-state.json` is read (path suffix at `WorktreeRunResolution.psm1` line 37). The item worktree under the main checkout is not where the checkpoint lives, and that is fine.

The relative path's base is the main checkout, not the checkpoint's root and not the session root. Three observations support this:
- The agent-memory note `.claude/agent-memory/parallel-orchestrator/worktree-removal-gate-path-mismatch.md` states it.
- The admin directory `agent-a018d4484e12bf5ae/gitdir` in the common git directory points to `<main checkout>/.claude/worktrees/agent-a018d4484e12bf5ae/.git`, and its `commondir` is `../..`.
- The planning worktree is a linked worktree outside the main checkout, so joining the relative string to the planning root names a path that does not exist.

### Smallest change

Make the recorded path absolute before comparing, in one shared pure function, and call it from every matcher above.

1. New pure module `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` (a new file is required, see File Size). It holds:
   - `Test-WorktreeRunPathEqual` (moved unchanged from `WorktreeRunResolution.psm1`).
   - `Test-WorktreeRunRecordedPathMatchesTarget -RecordedPath -TargetPath -BaseRoot <string[]>`. A rooted recorded path (`^([A-Za-z]:(/|$)|/)`, the pattern already at `WorktreeRunResolution.psm1` line 52) compares as today. A relative recorded path is joined to each base root and compared. A relative value is rejected, so it matches nothing, when it is blank, is `.`, has a `.` or `..` segment, or contains `:`. This guard stops a record such as `.` from authorizing the main checkout.
   - `Get-WorktreeRunMainCheckoutRoot -SessionRoot`: the live root whose `.git` entry is a directory (`Get-WorktreeResolutionGitEntryKind` is already exported, `WorktreeResolution.psm1` line 491). This is the only function with a filesystem seam.
2. `Test-WorktreeRunCheckpointRecord` and `Resolve-WorktreeRunTargetByRecord` take the base roots (main checkout and the candidate root) and use the new matcher for the `worktree_path` field.
3. Both gates and the diagnostics helper replace their inline compare with the new matcher. They import the new module directly with the existing guarded `try { Import-Module ... } catch { Add-HookDependencyFailure ... }` pattern; a nested module import does not reach the caller's scope.
4. `Test-CleanupManifestCheckpointCoversPath` uses the same matcher. This is a correctness requirement, not polish: it is a presence test that excludes the manifest branch for any target a checkpoint records. If it misses a relative record, a manifest entry could authorize removal of a still-unmerged item worktree that the checkpoint would have denied.
5. The `merge_status` predicate (`merged` or `worktree_removed`) and the fail-closed ordering are untouched. A relative record with `pr_open` still denies.

Apply the matcher to `features[]` as well as `items[]`: the parallel gate already passes `features` through the same function (line 374), and the epic record has the same shape. See open decision D2.

Codex twin: `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` reads only the epic checkpoint's `features[]` (`Find-CodexWorktreeFeature` lines 50-75) and has no parallel branch and no run-resolution module. `Get-NormalizedCodexWorktreePath` (lines 37-48) already resolves a relative path against the payload `cwd`. No Codex change is needed for the parallel denial. The Claude-runtime `parallel` surface has no `.codex` counterpart (no `*parallel-orchestrat*` file exists under `.codex`, `.agents`, or `.github`).

### Pester tests that pin or must be extended

Existing suites that exercise the changed code (they must stay green and several need new cases):
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` (B3, B5, lines 122-257: separator, trailing slash, case rules). Add relative-record cases.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1`.
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1`, `.Tests.ps1`, `.Issue824.Tests.ps1`, `.EpicAuthorization.Tests.ps1`, `.TriggerScoping.Tests.ps1`.
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1`, `.Tests.ps1`, `.Diagnostics.Tests.ps1`, `.Issue824.Tests.ps1`, `.ManifestBranch.Tests.ps1`, `.TriggerScoping.Tests.ps1`.
- `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`.
- `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-*.Tests.ps1` (unchanged; run as regression).

New tests:
- A pure-module suite for the new file (for example `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1`): relative joins, rooted pass-through, `.` / `..` / `:` / blank rejection, separator and case rules moved with `Test-WorktreeRunPathEqual`.
- One end-to-end decision case per gate, using the existing read seams and `Set-RecordTopology` style mocks (no temp files): a parallel checkpoint in a different live root with `worktree_path` `.claude/worktrees/agent-x`, `merge_status` `merged`, absolute command target under a mocked main root, expected allow in both gates.
- Negative cases for each gate: `pr_open`, `worktree_created`, no `merge_status`, a different agent name, a `..` record, a blank record, and a stale checkpoint copy in two live roots (expected `Ambiguous` deny).
- A manifest-matrix case: a manifest entry for a target recorded relatively with an unsafe status stays denied.

## 2. Closing Step and the Pre-Implementation Gate

### What parallel-orchestrate says today

- `## Worktree Cleanup` (`.claude/skills/parallel-orchestrate/SKILL.md` lines 531-553) says the parent removes each merged worktree "running from the main repository checkout" and records `worktree_removed`. It says nothing about the lock, about records, or about what to do when removal is refused. The coordinator in the failing run was a linked worktree, not the main checkout; `git worktree remove` works from any worktree of the repository, and the hook resolves from the session root.
- `## Completion Requirements` (lines 645-670) and `.claude/agents/parallel-orchestrator.md` lines 282-309 list four completion conditions; none mentions committing or landing records or clearing scratch worktrees.
- `## Documentation Maintenance Boundaries` (line 555 onward) regenerates `parallel-status.md` but never commits it.
- `.claude/agents/parallel-orchestrator.md` `tools:` (lines 5-30) holds `Bash(git *)`, `Bash(gh *)`, `Write(docs/features/parallel/**)`, `Write(artifacts/orchestration/**)`. It has no `Agent(pr-author)`. `/parallel-run` forks into this agent (`.claude/skills/parallel-run/SKILL.md` lines 5-6), so the closing step runs inside it.

### Route the pre-implementation gate accepts

No gate change is needed to commit docs-only records.

- `Test-ImplementationCommand` (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` lines 125-160) classifies `git add` / `git commit` as implementation, then clears it with `Test-ExemptOrchestrationStagingCommand` (line 154) when the exemption holds.
- `Test-ExemptOrchestrationStagingCommand` (`enforce-orchestration-preimplementation-gate-helpers.ps1` lines 411-470) requires that every segment is `git add` or `git commit` with at least one pathspec, every pathspec matches `^[A-Za-z0-9._/-]+$`, is relative, has no `..`, and starts with one of the five trees at lines 27-33: `docs/features/epics/`, `docs/features/parallel/`, `docs/features/active/`, `docs/features/potential/`, `artifacts/orchestration/`.
- Modelled commit options are only `-m`, `--message`, `--trailer` and their `=` forms (lines 368-388). `-F`, `-a`, `--amend`, `-C <relative>`, and any unmodelled option deny. Outside quotes, `$`, backtick, `< > # { } , ( ) @`, and backslashes deny (helpers lines 35-45). A message with such characters must be inside quotes.
- So `git add <literal path> ...` and `git commit -m "<message>" -- <literal path> ...` pass. `git add -A`, `git add .`, and a message passed by `-F` do not.

This is a real route, not a faked checkpoint. It is also why the issue's fifth bullet (gate blocks `git add` and `git commit`) holds only for commands that fall outside the exemption (for example a bare `git add -A`, or a path outside the five trees).

### Landing the commit on `main`

Commit alone does not satisfy "merged". `main` is protected, so a PR is required. Each step has an existing docs-only route:
- Create: `Get-PrAuthorDocsOnlyExemption` (`.claude/hooks/enforce-pr-author-skill.docs-only.ps1`) lets `gh pr create` continue to the receipt checks when no checkpoint file exists at the resolved path (E2, line 14), there is one explicit `--base`, and the diff touches only `docs/`. The coordinator must hold no `artifacts/orchestration/orchestrator-state.json` (the checkpoint-hygiene rule at `parallel-orchestrate` SKILL line 237 already requires that). The PR body still comes from `Agent(pr-author)` with its receipt, so `Agent(pr-author)` must be added to the `parallel-orchestrator` `tools:` list, or the closing step must be driven by a session that has it.
- Merge: `enforce-epic-merge-gate.ps1` lines 387-395 call `Get-DocsOnlyMergeExemption` (`hook-docs-only-diff.ps1`) when the command names an explicit PR number and no checkpoint records it. Conditions M1-M9 require a clean `gh pr merge <N> --merge` command, a base ref that exists locally, the head commit present locally, and every changed path under `docs/`.
- CI: the records PR is docs-only under `config/ci-docs-only-paths.json` (`docs/features/parallel/`, `docs/features/potential/`, `docs/features/active/` with `.md`), so the change-scope decision gives `code=false`.

Unknowns that need a live run: whether the merge queue admits a docs-only PR without delay, and whether `origin/main` is present locally at hook time (M4 does not fetch).

### Records to stage (derive from the checkpoint, not from `git status`)

Stage by explicit path list: the run folder `docs/features/parallel/<slug>/` (`parallel.md`, `parallel-status.md`, the committed kickoff), and promoted lifecycle records under `docs/features/potential/promoted/` created for the run's items. Do not stage `docs/features/active/<item>/` folders: item folders belong to the item branches. In the failing run, `git status` showed untracked `docs/features/active/` folders for items #989, #990, and #995 in the planning worktree; why those exist is UNKNOWN, and a `git add docs/features/active/` would have swept them in.

The manifest and kickoff were already committed on the planning branch, which was never merged. The closing step must therefore land that branch, not re-commit those files. Precondition: `git diff --name-only origin/main...HEAD` lists only `docs/` paths. In this repository the planning branch is the #995 fix branch and carries code; the closing step must stop and report in that case. It must not force anything.

### Proposed wording (new section in `parallel-orchestrate/SKILL.md`, referenced from Completion Requirements in the skill and in `parallel-orchestrator.md`)

> ## Run Closing
>
> The closing step runs once, after every non-withdrawn item is `merged` or `worktree_removed` and before completion is reported. Each substep re-derives state from `git worktree list --porcelain`, `git`, and `gh`, and is safe to repeat.
>
> 1. **Item worktrees.** For each item whose `merge_status` is `merged`, take the absolute path from `git worktree list --porcelain`, never from the relative spelling in `items[].worktree_path`. If that registration is locked with a reason of the form `claude agent <name> (pid <n>)` naming the item's own agent, run `git worktree unlock <path>`. Then run `git worktree remove <path>` with no force flag. On success record `merge_status: worktree_removed` and `worktree_removed_at`. If removal is refused, leave `merged`, add a `completed_steps` entry naming the path and the refusal reason, and continue. A deferred removal does not fail completion.
> 2. **Final status.** Regenerate `docs/features/parallel/<slug>/parallel-status.md` once more.
> 3. **Records.** Stage the run folder and the promoted records created for the run by literal path, in commands whose every path is under `docs/features/` or `artifacts/orchestration/`, so the pre-implementation gate classifies them as bookkeeping. Never use `git add -A` or `git add .`. Confirm `git diff --name-only origin/main...HEAD` lists only `docs/` paths; otherwise stop and report. Push, delegate the pull request to `Agent(pr-author)` with the `branch:` label, merge with `gh pr merge <PR> --merge` naming the pull request number, and confirm the merge by the step 3 procedure of `## Per-Item Merge to Main (Merge-on-Green)`.
> 4. **Scratch worktrees.** Run the scratch-worktree procedure chosen in the decision for D5.
> 5. **Report.** List every deferral. Completion requires the existing four conditions plus a merged records pull request.

The `require_complete` validator does not need to change. Closing evidence lives in `completed_steps` and is tolerated free-form.

## 3. Planner Scratch Worktrees

Observed (read from the common git directory): registrations `wt989`, `wt990`, `wtplan` point into the session scratchpad. `wtplan`'s `HEAD` is `c635f827a2cb06ba3dba5f374e95de8c323a04a7`, the kickoff commit, which is on the unmerged planning branch. `wt989`'s `HEAD` is `82af0bb9ada8330e5343dc4bc1ba676ba3b135ce`. All are detached.

Can a removal hook authorize them? No, and no hook change is recommended.
- The parallel and epic gates authorize a path only if a checkpoint `items[]` or `features[]` record names it with `merged` or `worktree_removed`. Scratch worktrees are in neither array.
- The manifest branch (`CleanupWorktreeManifest.psm1` `Test-CleanupWorktreeManifestAuthorizesRemoval` lines 203-343) accepts only a manifest written by `cleanup-merged-worktrees`: tool and schema match, `generated_at` within 24 hours, disposition `SAFE_TO_DELETE`, evidence text, verdict in `{DEAD_ONE_OFF, ALREADY_SOLVED_ELSEWHERE, STALE_OR_CONTRADICTED}`, branch state in `{NOT_MERGED, HAS_UNIQUE_RESIDUALS}` (lines 45-59). That route serves the dirty-worktree triage, not merged scratch checkouts.
- A new allow rule keyed on "scratch" or "detached" would have no merge-state predicate. The gates exist to stop destruction of unmerged work; a path-class allow would remove that protection for any worktree an agent calls scratch.

What works without a hook change: `cleanup-merged-worktrees` apply mode removes delete-eligible detached worktrees (`MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`) without force (`SKILL.md` lines 235-250). The `git worktree remove` runs inside the script, so the hook sees only the outer `bash ...cleanup-worktrees.sh --apply` command, which is not in its scope. Caveats:
- `--apply` is repository-wide; there is no flag to scope it (SKILL.md lines 156-218). Session memory records that apply can classify an unrelated live worktree as merged.
- `wtplan`'s `HEAD` is not an ancestor of `main` until the records PR merges, so it cannot classify as merged before that. The closing step must run the scratch step after the records merge is confirmed.
- A locked registration is skipped as `BLOCKED-LOCKED`.

Preferred alternative: have the planner stop creating them, or remove them itself in the same session before it ends. Why the planner created three detached scratch worktrees at all is UNKNOWN; the planner's own tools (`parallel-planner.md` lines 14-16) are `Bash(git *)` and `Bash(gh *)`, which can create them, and `parallel-plan/SKILL.md` lines 85-86 and 125 describe only isolated preparation worktrees.

## 4. Mirror Surfaces and Pack Manifest

Reasoning for each surface is from file existence and content checks.

| Surface | Change | Basis |
| --- | --- | --- |
| `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` (new), `WorktreeRunResolution.psm1`, `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | edit and add | section 1 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-epic-worktree-removal-gate-resolution.ps1` | edit | section 1 |
| `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md` | edit | sections 2 and 3 |
| `.claude/rules/parallel-orchestration.md` (line 689 describes the parallel allow branch) | edit if the matcher contract wording changes | |
| `.claude/agent-memory/parallel-orchestrator/worktree-removal-gate-path-mismatch.md` | update or remove after the fix | becomes stale |
| `extensions/drm-copilot/resources/claude-customizations/.claude/...` | byte-identical copy of every file above | bundle copies exist for all of them; `test_push_down_claude_resource_contracts.py` pins equality |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | add the new module (existing precedent: `WorktreeRunResolution.psm1` at line 231; hooks at lines 35 and 54) | `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_pack_manifest_dependency_closure.py` |
| `.codex/hooks`, `extensions/.../codex-and-agents-customizations/.codex/hooks`, `...pack-manifests/core.json` (codex) | none for sections 1 to 3 | Codex gate is epic-only; no parallel surface |
| `.agents`, `.github` | none for sections 1 to 3 | no parallel skill, agent, or removal hook there |
| Six `execution-environment` copies | none expected | the brief does not state the facts changed here; re-check at planning with `test_execution_environment_brief_contracts.py`, which pins text about `enforce-parallel-worktree-removal-gate.ps1` |

Other pinned checks to run after editing: the Codex generator `--check` (the agent file has no Codex variant, but confirm), `claude-architecture-doc.Tests.ps1` (agent tool names, relevant if `Agent(pr-author)` is added), and `hook-dependency-guard-completeness.Tests.ps1` (every dot-source or import in a hook must use the guarded `try/catch Add-HookDependencyFailure` form).

Batch budget: the change touches more than three production PowerShell files, plus bundle copies that also count. It belongs on the `/orchestrate` large route (`.claude/rules/powershell.md`, Change Budget).

## 5. Automation Feasibility

Required by the research gate for autonomous-execution work.

Confirmed from source: no human step is needed on the happy path.
- Matching: a deterministic string comparison; no operator input.
- Unlocking and removal: `git worktree unlock` and `git worktree remove` are plain `git` commands within `parallel-orchestrator`'s `Bash(git *)`. No file under `.claude/hooks/` matches `worktree unlock`, and `validate-bash.ps1` lists no `git worktree` pattern. The cleanup skill's "never force" rule is respected because unlock is not a force flag.
- Commit: the five-tree exemption removes the need for a checkpoint.
- PR and merge: pr-author docs-only and merge docs-only exemptions need no human. `cleanup-merged-worktrees` step 5 ("human-performed" merge, lines 199-209) applies to its dirty-worktree consolidation PR, not to this route.
- Scratch worktrees: automatable through the cleanup tool, or avoidable at the planner.

Not verified (would need a live run, which the researcher cannot do):
- Lock behavior. At research time item #990's registration has `locked` containing `claude agent agent-aeaa20a879b932016 (pid 2576)`, and item #989's registration has no `locked` file, so the harness lock is not uniformly held. Whether `git worktree remove` succeeds after `unlock` while the harness process is alive is UNVERIFIED (Windows file handles may refuse).
- Merge-queue handling of a docs-only PR (section 2).
- Whether `Agent(pr-author)` from the forked `parallel-orchestrator` passes `enforce-model-routing-receipt.ps1` without an issue number. The cleanup skill documents a `branch:` label as the identification when no issue number exists (SKILL.md lines 189-194), which suggests it does.

Deferral rule: a refused removal, or a scratch worktree that does not classify as merged, ends in a recorded deferral and a report, not a halt. That keeps the run autonomous. It also means "no manual step remains" holds only when the refusals do not occur; the deferral list is the explicit exception record.

## 6. Open Decisions for the User (with recommended defaults)

| ID | Decision | Recommended default |
| --- | --- | --- |
| D1 | Base for relative recorded paths | Main checkout root and the checkpoint's own root (two candidates). Main only is stricter; the second candidate costs one extra string compare and covers a coordinator that is the main checkout. |
| D2 | Apply the matcher to epic `features[]` as well as parallel `items[]` | Yes. The same functions serve both; a split would leave two spellings. |
| D3 | Closing step may `git worktree unlock` a harness lock | Yes, only when the item is `merged`, its lock reason matches the item's own agent name, and no force flag is used; otherwise defer and report. |
| D4 | Records landing route | Docs-only PR through the existing exemptions; add `Agent(pr-author)` to `parallel-orchestrator` `tools:`. Rejected: a new gate exemption; a checkpoint written only to satisfy the gate (not acceptable). |
| D5 | Scratch worktrees | Do not add a hook allow. Fix at source if the planner can avoid creating them; otherwise run `cleanup-merged-worktrees` after the records merge and accept the deferral if they are not delete-eligible. |
| D6 | Closing step precondition when the planning branch carries non-docs commits | Stop and report; never force, never split the branch automatically. |
| D7 | Include the Codex twin of the merge-gate change (section 8) | Defer. Claude first; the Codex orchestrate skill (`.agents/skills/orchestrate/SKILL.md`) has no S9 merge text. |
| D8 | Where the standalone self-merge is tracked (section 8) | Separate issue (section 9). |

## 7. Where the Merge Prohibition Lives

Request: remove the prohibition on a standalone orchestration merging its own PR once CI is green.

Enforcement:
- `.claude/hooks/enforce-epic-merge-gate.ps1`: the header (lines 5-38) states branches 1-4 and that "a standalone run never satisfies conditions 1-3". Branch 1 is `Test-ChildCheckpointAllowsEpicMerge` (lines 142-169), which requires `epic_mode` true (line 162) and `step9_status` `passed`. The decision is lines 337-403; the final deny text is line 403.
- `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` (443 lines): branch 4, the #670 record (functions lines 86-443); guidance string line 54.
- `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` `Test-ChildCheckpointPrGateBinding` (lines 153-203): with an explicit PR number, the child checkpoint must record `pr_gate.pr_number` equal to it, or fall back to a `standalone_merge_authorizations` entry.
- `.claude/settings.json` line 114 registers the hook. Neither the cleanup skill nor `.claude/settings.json` `permissions.allow` grants `gh` (cleanup SKILL lines 201-204).

Prose:
- `.claude/skills/orchestrate/SKILL.md`: S9 step 6 (line 314) merges only when `epic_mode` is `true`; PR Creation Gate condition 7 (line 379) ties DONE to the merge only in epic mode; line 381 describes the gate as non-negotiable.
- `.claude/skills/epic-orchestrate/SKILL.md` lines 122 and 150-151: "Standalone (non-epic) orchestration is unchanged: `epic_mode` absent or `false` makes S9 step 6 a no-op". This file is a frozen surface (`PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, per the execution-environment brief), so editing it also needs the pinned hash updated.
- `.claude/skills/parallel-orchestrate/SKILL.md`: lines 373-377 (parallel children run with `epic_mode` false and "never instructed to merge"), and the merge-gate section lines 414-454 including the #670 standalone writer procedure.
- `.claude/rules/orchestrator-state.md` lines 234-306 (Standalone-Merge-Authorization section and its Enforcement bullet) and `.claude/rules/parallel-orchestration.md` line 689.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` lines 199-209: the consolidation PR is "human-performed". This is the cleanup skill's own contract and would stay unless the user wants it changed.
- `.claude/agents/orchestrator.md` has no merge text (searched for `merge`).

Codex: `.codex/hooks/enforce-epic-merge-gate.ps1` `Test-CodexChildMergeReady` (lines 87-103) requires a boolean `epic_mode` and `step9_status` in `{passed, verified}`. It is a separate implementation (it reads no worktree resolution).

Mirrors: bundle copies of the three Claude hooks, `.claude/rules/*`, and the skills exist under `extensions/drm-copilot/resources/claude-customizations/.claude/`; the Codex hook has a copy under `codex-and-agents-customizations/.codex/hooks/`.

Tests that pin current behavior (all under `tests/scripts/`):
- `claude-hooks/enforce-epic-merge-gate.Tests.ps1`: the child contexts at lines 56-77, and `Test-ChildCheckpointAllowsEpicMerge` helper cases at lines 331-350, including `epic_mode` explicitly false returns false (lines 336-339).
- `claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` (lines 111, 185-214, 243, 302) and `.WorktreeResolution.Tests.ps1` (lines 51, 129, 143).
- `claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` (decision matrix lines 94-104, and `$script:Line433Text` at line 85, the pinned final deny text), `.AuthorizationFields.Tests.ps1`, `.MergeQueue.Tests.ps1` (line 46), `.DocsOnly.Tests.ps1` (line 63). Three of these pin the exact final deny string, so changing the line-403 wording means updating all three.
- Codex: `codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1` (lines 130-140), `enforce-epic-merge-gate-authorization.Tests.ps1` (line 59).

## 8. Smallest Change for a Green Per-Feature Checkpoint

Goal: a per-feature checkpoint with `step9_status` `passed`, `ci_gate.conclusion` `success`, `ci_gate.head_sha` equal to the live PR head, and a binding to the explicit PR number satisfies branch 1 without `epic_mode`.

Design:
1. Add `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` as a new dot-sourced sibling, loaded with the guarded pattern. It cannot go into `enforce-epic-merge-gate-authorization.ps1` (443 lines, about 70 lines needed) and the gate is at 460 lines, so the gate gets only the dot-source line and one branch.
2. In it, `Test-ChildCheckpointGreenCiAllowsMerge -Checkpoint -CommandPrNumber -LiveHeadSha` is pure. It returns true only when all of these hold:
   - the command names an explicit PR number (a bare command never qualifies);
   - `epic_mode` is not `true` (an epic child keeps the existing branch unchanged);
   - `step9_status` is `passed`, `ci_gate.conclusion` is `success`;
   - `pr_gate.pr_number` is present and equals the command's number (no fallback to a `standalone_merge_authorizations` entry, which would let a record stand in for a CI result);
   - `ci_gate.head_sha` equals `pr_gate.head_sha` (when present) and equals the live head, as 40 or 64 lowercase hex.
3. A thin seam `Get-EpicMergeGateLivePrHeadSha -PrNumber -WorktreeRoot` runs `gh pr view <N> --json headRefOid` through the existing bounded `Invoke-DocsOnlyGhExe` (`hook-docs-only-diff.ps1` line 281; 7 s bound). The hook has no network call today outside the docs-only branch, so this is the one new I/O. It is invoked only after the cheap checkpoint conditions pass, so most merges make no `gh` call. If the command carries `--match-head-commit`, it must equal the live head, using the same flag reader as the docs-only branch (lines 429-432).
4. In `Invoke-EpicMergeGateDecision`, insert one branch directly after branch 1 (after line 354). A failure returns nothing and falls through to the epic, parallel, #670, and docs-only branches unchanged.

Fail-closed cases, each mapping to a unit test: stale head (checkpoint head differs from live head), `pending` or `failure` conclusion, `step9_status` other than `passed`, `pr_gate.pr_number` absent or different, missing or unparseable checkpoint, a bare command, a `gh` failure or timeout (exit 124), and `--match-head-commit` that differs.

The #670 authorization branch: keep it. It remains the only auditable, deliberate route for a merge that has no green S9 (for example the "standalone fix that unblocks the run" in `parallel-orchestrate` SKILL lines 430-445). Retiring it would delete the 20-plus tests in `.AuthorizationFields.Tests.ps1` and the writer procedure for no gain, and the green branch does not cover non-green cases. Its guidance string and reason codes need no change.

Skill and rule edits that go with the hook:
- `orchestrate/SKILL.md` S9 step 6: add the standalone case. A run that is neither `epic_mode` nor a parallel item (no `Parallel mode: true` marker, see `parallel-orchestrate` SKILL lines 244-249) merges with `gh pr merge --merge <PR>` after step 5, then confirms by the step 3 procedure of `## Per-Item Merge to Main (Merge-on-Green)`. Update PR Creation Gate condition 7.
- Parallel children must stay excluded in prose: the parent merges and confirms each item (SKILL lines 373-411), and the hook cannot see the marker. A child that merged itself would bypass the parent's `ci_green` recording; the `Parallel mode: true` marker is the only discriminator.
- Where the standalone merge result is recorded is undecided. A new top-level key (for example `pr_merge`) would be tolerated by the validators if free-form, but then no validator checks it.
- Update the hook header, the final deny text at line 403 (and the three tests that pin it), `parallel-orchestrate` SKILL lines 414-454, the `orchestrator-state.md` Standalone section, and `parallel-orchestration.md` line 689. If `epic-orchestrate/SKILL.md` lines 122 and 150-151 are edited, update the pinned hash.
- Bundle mirrors and `core.json` (new hook file) as in section 4.

## 9. Same Issue or Separate Issue

Recommendation: separate issue.

- Different mechanism: #995 repairs a path match and adds a closing step. The merge change widens an authorization surface for every standalone orchestration run.
- Different files and tests: the merge gate family (four hook files, about nine Pester suites, the Codex twin decision) shares no code with the removal gates beyond the command parser.
- Independent delivery: #995's records PR uses the existing docs-only merge route, which does not depend on the new branch.
- Overlap risk: both change `parallel-orchestrate/SKILL.md`, `.claude/rules/orchestrator-state.md`, and `.claude/rules/parallel-orchestration.md`. Their declared blast radii will overlap, so the parallel scheduler will serialize them. Sequencing the merge-gate item second avoids a rebase in a 700-line skill.
- Policy: reversing "a standalone run never merges itself" is a user-authorized policy change that deserves its own acceptance criteria and review.

## Candidate Approaches (item 1)

| Approach | Verdict |
| --- | --- |
| A. Shared pure matcher resolving relative paths against the main checkout, used by every site (selected) | Deterministic, Pester-pinned, fixes already-written checkpoints, one definition |
| B. Producer fix only: record absolute paths (`git worktree list --porcelain`) | Rejected as the sole fix. It depends on agent behavior, leaves existing and in-flight checkpoints failing, and the cache doctrine already says git is authoritative, so the hook should not rely on spelling |
| C. Suffix match: accept when the absolute target ends with the recorded relative path | Rejected. A stale checkpoint from another clone would match |
| D. Patch only `Test-WorktreeRunCheckpointRecord` | Rejected. The gates' own `Find-*` functions would still deny, and the manifest coverage test would still miss relative records |

## Matcher Family Enumeration

No numeric acceptance criterion is proposed in this document. The enumeration below supports the prose claim "every site that compares a recorded `worktree_path` to a removal target" and must be re-derived with two independent strategies if the spec states a count.
- Strategy 1 (property read, `\.worktree_path` over `.claude/**/*.ps1,*.psm1`): `CleanupWorktreeManifest.psm1` (lines 195 and 401), `enforce-epic-worktree-removal-gate.ps1` (153 and 239), `enforce-epic-worktree-removal-gate-resolution.ps1` (171), `enforce-parallel-worktree-removal-gate.ps1` (206). Also `enforce-parallel-drift-gate.ps1` line 398, which reads the value for a finding lookup, not a removal match.
- Strategy 2 (normalizer idiom, `-replace '\\', '/').TrimEnd('/')` and `Test-WorktreeRunPathEqual`): adds `WorktreeRunResolution.psm1` (344-358, 400), which reads the field by name through `Get-WorktreeRunPropertyValue` and so is invisible to strategy 1, and the epic and parallel `Find-*` target-side normalizers. Line 195 of the manifest module is the manifest's own `removals[]`, not a checkpoint record, so it is out of family.
- Member-set comparison: the checkpoint-record matchers found by strategy 2 are a superset of strategy 1 by exactly the resolution module; the manifest line 195 and the drift gate line 398 are excluded for stated reasons. The two strategies are consistent. The family is: resolution, parallel gate, epic gate (two sites), diagnostics helper, manifest coverage test.

## Testing Implications

- Pester (v5.x) only; no temporary files; use the existing read-seam mocks and `Set-RecordTopology`-style helpers. Mock `Get-WorktreeResolutionGitEntryKind` or `Get-WorktreeItemLiveRoot` for the main-root function; never mock `git`.
- Branch coverage is not measured for PowerShell; per-file line coverage at least 85% for each changed file, read from `artifacts/pester/powershell-coverage.xml`.
- Hook behavior on a branch is proven by Pester only: isolated subagents run `main`'s hook copies, so a live check needs a non-isolated delegation from a worktree that holds the branch (execution-environment brief, Hook Execution Context).
- A live repro of the original failure can only be rerun after merge, on a fresh two-cohort run.
- Integration scenario from the issue (records merged, no item or scratch worktree left) is a manual or live-run check; it cannot be unit tested.

## Pre-Mortem

- Review checklists: a reviewer could find that one of the six matcher sites still compares raw strings (most likely the diagnostics helper or the manifest coverage test), or that a relative record of `.` or `..` can match a root. Mitigation: the plan lists all six sites (Matcher Family Enumeration), a task per site, a negative test for `.`, `..`, and blank records, and a grep-based check task that no inline `worktree_path` normalizer remains outside the new module.
- Coverage: new branches in the matcher, the main-root function, and the green-CI branch could fall under 85% line coverage because the filesystem and `gh` seams are thin. Mitigation: pure functions take the roots and the head as parameters; seam bodies are covered with test-local scriptblock invokers (as `hook-docs-only-diff.ps1` does); coverage is read per file from `artifacts/pester/powershell-coverage.xml`, never from the MCP result, which carries no output.
- Mirror parity: every edited Claude file needs a byte-identical bundle copy, and the new module and any new hook file need `core.json` entries, or the push-down contract and manifest-completeness tests fail. Mitigation: a plan task per file pair and a final run of the push-down contract tests, the dependency-closure test, and the Codex generator `--check`; the plan names the execution-environment brief as unchanged with the reason.
- File size: `WorktreeRunResolution.psm1` is 497 lines, `WorktreeResolution.psm1` is 500, the removal gates are 456 and 461, the merge gate is 460, and the authorization helper is 443. Adding code inline breaks the 500-line limit. Mitigation: move `Test-WorktreeRunPathEqual` into the new module so the resolution module shrinks, put the green-CI logic in a new sibling file, and add only dot-source and call lines to the gates; the plan records physical line counts with `wc -l` before and after.
- Test isolation: new Pester files could leak mocks or `$script:` state across the many suites that dot-source the same hooks, and the shuffled-order runs could expose it. Mitigation: no temp files, mocks scoped to `BeforeEach`, and the three seeded shuffled runs plus the single-process full run recorded under `evidence/regression-testing/` as the execution-environment brief requires.
- CI-only behavior: Linux hook-suite CI uses a case-sensitive file system and forward-slash paths, and the matcher's case rule differs for drive-letter versus POSIX paths. Mitigation: fixtures use POSIX roots (`/synthetic-worktrees/...`) and `Join-Path`; one case-rule test per style; no drive letters in the Linux-run suites; no test reads gitignored `artifacts/` state.
- Evidence: acceptance depends on behavior that research could not run (lock release after unlock, merge-queue handling of a docs-only PR, `Agent(pr-author)` receipt without an issue number). Mitigation: the plan labels those three as live-verification items with explicit deferral behavior, records command output under `evidence/regression-testing/`, and does not assert a live repro result as an acceptance fact.
