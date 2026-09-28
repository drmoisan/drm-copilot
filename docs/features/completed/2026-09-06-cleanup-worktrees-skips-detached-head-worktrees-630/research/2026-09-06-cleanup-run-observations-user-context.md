# User-supplied context: cleanup-merged-worktrees run observations (2026-09-06)

- Source: user message received during the `/orchestrate` session for issue #630 on 2026-09-06.
- Status: verbatim capture; not yet decomposed into issue, research, spec, or plan artifacts.
- Purpose: preserve the observed gaps and acceptance criteria exactly as supplied so downstream
  planning artifacts derive from this record rather than from a paraphrase.

---

# Fix the cleanup-merged-worktrees surface so it can finish a cleanup without manual routing

## Context

On 2026-09-06 the `/cleanup-merged-worktrees` skill was run in the TaskMaster checkout against
57 registered worktrees and 69 local branches. The deterministic script did its part correctly
(45 branches classified merged, 32 deleted, 7 worktrees removed), but finishing the job required
hand-written scripts, a manual consolidation commit, and hook workarounds. Every gap below was
observed in that run; file paths are the push-down locations in the consumer repository.

Deliver the fixes in `drm-copilot` so the next push-down carries them. Do not patch the consumer
copies.

## Gaps to fix

### 1. `--apply` never considers detached worktrees

`scripts/bash/cleanup_worktrees_actions_lib.sh` iterates `enumerate_branches` and removes a
worktree only when it is checked out on a delete-eligible branch (`wt_of[$name]`). 30 of the 57
worktrees had a detached HEAD (preparation worktrees, epic-child baselines, agent worktrees whose
branch was deleted earlier) and were invisible to apply mode.

Required: classify each detached worktree on its own. A detached worktree whose HEAD is an
ancestor of `main` (or whose HEAD tree content is already on `main` by the existing
content-neutral / equivalence ladder) and whose working tree is clean is delete-eligible. Emit a
`WORKTREE|<path>|DETACHED|<state>` record with the same state vocabulary as branches, and remove it
in apply mode under the same allowlist.

### 2. Dirty worktrees are blocked with no classification of the dirt

14 worktrees on merged branches were reported `BLOCKED-DIRTY`. In every case the dirt was one of:
`*.csproj` / `packages.config` / `app.config` analyzer-HintPath rewrites left by `nuget restore`;
`artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt`;
`artifacts/orchestration/orchestrator-state.json`; or untracked files whose exact content already
exists in `main`'s history (`git log main --find-object=<blob>` hits) or matches `main`'s current
blob at the same path.

Required: add a deterministic dirt classifier to report mode that labels each `DIRTY|` line
`DISPOSABLE_BUILD_ARTIFACT`, `DISPOSABLE_SESSION_ARTIFACT`, `CONTENT_ON_MAIN`,
`CONTENT_IN_HISTORY`, `STAGED_TREE_IS_COMMIT <sha>` (compare `git write-tree` against the branch's
commit trees; one worktree carried 86 staged changes that were exactly an earlier commit), or
`UNIQUE`. Add an opt-in apply flag (for example `--clear-disposable`) that, for a worktree whose
dirt is entirely non-`UNIQUE`, runs `git reset --hard` + `git clean -fd` and then the normal
non-forced removal. Keep the default behavior unchanged. `UNIQUE` dirt still blocks.

### 3. The worktree-removal hook contradicts the skill's manual-action step

`.claude/hooks/enforce-epic-worktree-removal-gate.ps1` denies every `git worktree remove` in a
Bash command unless an epic or parallel checkpoint records the path with `merge_status` in
`{merged, worktree_removed}`. The skill's Dirty Worktree Triage Procedure (step 9) instructs the
agent to perform "a distinct, individually confirmed manual action" for `SAFE_TO_DELETE` verdicts,
which is exactly the command the hook blocks. The only way to comply was to write the removals to
a script file and invoke `bash <file>`, which the hook does not inspect. That is a hook bypass
in all but name.

Required: give the skill a sanctioned removal path. Either (a) extend the hook to accept a
cleanup manifest the skill writes (for example
`artifacts/orchestration/cleanup-worktrees-manifest.json` listing each path with its verdict and
the evidence that produced it) and allow removal of listed paths, or (b) route all skill removals
through the script (`cleanup-worktrees.sh --apply --manifest <path>`) and have the hook recognize
that invocation. Update the skill text to match whichever is chosen. The hook must keep denying
bare `git worktree remove` for epic/parallel item worktrees that no manifest covers.

### 4. The merge gate blocks the consolidation PR the skill itself produces

`.claude/hooks/enforce-epic-merge-gate.ps1` denies `gh pr merge --merge` unless a per-feature,
epic, or parallel checkpoint records CI green for that PR number. The consolidation PR
(`documentationandmemories -> main`) has none of those checkpoints, so the skill's step 5
("after the consolidation PR merges") can only be satisfied by a human. Either document that the
merge is human-only in the skill, or add a fourth checkpoint shape for the consolidation PR
(`cleanup-worktrees-state.json` with `consolidation_pr: {pr_number, head_sha, ci_gate.conclusion}`)
and let the skill write it after `gh pr checks --required` passes.

### 5. Untracked lesson files are the bulk of the preserved content, and the script cannot see them

Report mode emits `COMMIT|...|UNIQUE|...` records only for committed residuals. In this run there
were none; instead ~140 never-committed `.claude/agent-memory/**` lesson files and feature-folder
drafts sat untracked or modified across 20 worktrees. The consolidation step (`--consolidate`,
cherry-pick with `-x`) therefore had nothing to do, and the actual consolidation was done by hand:
copy the files into a manually created `documentationandmemories` worktree, append each file's
`MEMORY.md` index line taken from the source worktree, normalize the index files to CRLF (the
consumer checkout is CRLF and appended LF lines produce mixed endings), sanitize account/host
tokens, commit, push.

Required: teach the consolidation step to stage untracked/modified files that the editorial pass
marks `PRESERVE` (via the manifest from gap 3), carrying the `MEMORY.md` index line for each new
lesson file, normalizing line endings to the target file's existing convention, and refusing to
commit any file that matches the `_shared_no_absolute_host_paths` token patterns until sanitized.
Emit a `PRESERVE|<worktree>|<path>|<verdict>` record per file.

### 6. Ordering hazard: the consolidation branch is delete-eligible before its first commit

`create_consolidation_worktree` creates `documentationandmemories` at `main`. Until a commit lands
on it, `classify_branch` reports it `MERGED_CLEAN` and `verify_consolidation_merged` returns
`MERGED_CLEAN` (it is an ancestor of `main`), so an apply pass in that window deletes the branch
and worktree. Make `verify_consolidation_merged` return `NOT_ANCESTOR`-equivalent when the branch
tip equals `main` (zero commits ahead), or refuse apply mode while the consolidation worktree
exists with no commits.

### 7. Orphaned directories and stale refs are not reported

Four directories under `.claude/worktrees/` and `<repo>-wt/` had no `.git` file and no
registration (one was a 6 GB checkout from July), and 17 `refs/remotes/child/*` refs remained
from an epic run although no remote named `child` exists. Report mode should emit
`ORPHAN_DIR|<path>|<size>` and `STALE_REF|<refname>` lines so the skill can put them in front of
the user; deletion stays manual and confirmed per item.

### 8. Hook text-matching false positives

The gate hooks match on the Bash command string, so a `printf` whose literal text mentioned the
gated gh subcommand was denied (`EPIC_MERGE_GATE_BLOCKED`) while writing a memory note. Match the
command word position (first token of a pipeline segment, after `gh`), not any substring.

### 9. Smaller items

- The skill hard-codes `<N> = 396` for the pr-author body file and receipt. Derive it (for example
  from the consolidation branch name or the issue the skill tracks) or document why 396.
- `collect_pr_context` lists 2 of 92 changed files under "Changed files overview" because it does
  not enumerate `.claude/**`; the PR body has to point reviewers at the appendix. Include
  `.claude/agent-memory/**` in the overview.
- Report mode took about 6 minutes, dominated by per-commit patch-id classification of 20 epic
  child branches with up to 64 commits each. Short-circuit a branch whose tip is already an
  ancestor of another `NOT_MERGED` branch (the epic integration branch) and report it as
  `CHILD_OF|<branch>` instead of re-classifying every commit.
- `git worktree list` registrations for two session worktrees disappeared mid-run while their
  directories stayed on disk (cause not established; a concurrent session was active). Add a
  `WARN|registration-lost|<path>` line when a `.git` file on disk points at a missing
  `.git/worktrees/<name>` entry.

## Acceptance criteria

- [ ] Report mode classifies detached worktrees and emits `DIRTY|` lines with a dirt verdict; apply
      mode with the new opt-in flag clears and removes worktrees whose dirt is entirely non-`UNIQUE`.
- [ ] The skill can remove a `SAFE_TO_DELETE` worktree without invoking a command the removal hook
      denies, and the hook still denies unmanifested removals of epic/parallel item worktrees.
- [ ] The consolidation step carries untracked `PRESERVE` files with index lines, line-ending
      normalization, and host-token refusal; the skill text documents whether the consolidation PR
      merge is human-only or checkpoint-gated.
- [ ] An apply pass cannot delete a zero-commit `documentationandmemories` branch.
- [ ] Orphan directories and stale `child/*` refs appear in report output.
- [ ] Hook command matching no longer triggers on quoted text.
- [ ] bats coverage for every new lib function per `.claude/rules/shell.md` (no temp files; use the
      `CLEANUP_WT_GIT_BIN` seam), Pester coverage for the hook changes, and the skill, script, and
      hooks pushed down together.
