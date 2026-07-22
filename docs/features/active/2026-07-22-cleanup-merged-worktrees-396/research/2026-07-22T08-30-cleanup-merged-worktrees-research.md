# Research: cleanup-merged-worktrees skill (Issue #396)

- Date: 2026-07-22
- Author: task-researcher agent
- Feature: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/`
- Inputs read: `issue.md`, `spec.md`, `.claude/skills/pr-author/SKILL.md`, `.claude/agents/pr-author.md`, `.claude/skills/orchestrate/SKILL.md` (PR Authoring section), `.claude/rules/shell.md`, `scripts/bash/shell-qc.sh`, `scripts/bash/shell_qc_lib.sh`, `tests/shell/test_shell_qc_discovery.bats`, `tests/fixtures/shell_qc/**`, `.claude/skills/make-skill-template/SKILL.md`, `.claude/skills/identify-session-id/SKILL.md`, `.claude/skills/python-qa-gate/SKILL.md`, `.claude/skills/pr-context-artifacts/SKILL.md`, git metadata under `C:/Users/DanMoisan/repos/drm-copilot/.git/`.

## Current Repository State (verified from git metadata)

This working directory is itself a linked worktree. `.git` in the working directory contains `gitdir: C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/2026-07-21T21-57`. The main checkout is `C:/Users/DanMoisan/repos/drm-copilot`; linked worktrees live under `C:/Users/DanMoisan/repos/drm-copilot-wt/<timestamp>`.

Registered linked worktrees (from `.git/worktrees/*/HEAD`):

| Worktree admin dir | Branch | Notes |
|---|---|---|
| `2026-07-21T17-18` | `drm-copilot-wt-2026-07-21T17-18` | candidate for classification |
| `2026-07-21T21-57` | `drm-copilot-wt-2026-07-21T21-57` | the CURRENT worktree — must be excluded |

Local branches (loose refs plus `packed-refs`): `main`, `development`, `feature/bootstrap-pc`, `drm-copilot-wt-2026-07-02-19-03`, `drm-copilot-wt-2026-07-21T17-18`, `drm-copilot-wt-2026-07-21T17-20`, `drm-copilot-wt-2026-07-21T21-57`. Branch `drm-copilot-wt-2026-07-21T17-20` has no worktree and its PR (#394) is already merged into `main` (merge commit `b2351cbc` at branch head) — a live instance of the "merged branch, no worktree" case.

PRs in this repository merge via merge commits (`b2351cbc Merge pull request #394 ...`), not squash merges. This matters: with true merges, a fully merged branch tip IS an ancestor of `main`, so `git merge-base --is-ancestor` is the correct primary classifier. If squash-merge were ever adopted, ancestry would never hold and the content-equivalence fallback (section 2) would become the primary path.

## Recommended Approach (summary)

A two-file bash implementation following the established shell-qc pattern: a thin CLI wrapper `scripts/bash/cleanup-worktrees.sh` (subcommand dispatch, `--help`, dry-run default / explicit apply) sourcing a function library `scripts/bash/cleanup_worktrees_lib.sh` (all logic, unit-testable by sourcing from bats). Classification ladder per branch: (1) `merge-base --is-ancestor` → fully merged; (2) `git cherry` patch-id equivalence for residual commits; (3) cumulative content diff (`git diff main...<branch>`) as the tree-content fallback; (4) anything still unique is emitted as a cherry-pick candidate for LLM/editorial triage. Consolidation happens in a dedicated new worktree on branch `documentationandmemories` created off `main`; the skill (not the script) drives the pr-author handoff; deletion uses `git worktree remove` (no `--force` by default) plus `git branch -D` gated by an immediately-preceding re-verification of ancestry/equivalence.

Rejected alternatives (brief):
- `git branch --merged main` parsing: porcelain output, decoration markers (`*`, `+`), locale/format risk; `for-each-ref` + `merge-base --is-ancestor` is the plumbing equivalent with explicit exit-code semantics.
- `git log --all --grep '<message>'` to find re-applied commits: text heuristic on commit messages; explicitly disallowed by the spec ("ancestry checks, not text heuristics"). Usable only as human-facing diagnostic output, never as a classification input.
- Manual per-commit `git show | git patch-id --stable` loop against all of `main`'s history: O(branch x main) and reimplements what `git cherry` already does with the same patch-id machinery.
- Doing the consolidation checkout in the current worktree: mutates the active checkout the spec says must never be disturbed; a dedicated `git worktree add` isolates it.

---

## 1. Merged-branch/worktree detection mechanics

### Enumerating worktrees

`git worktree list --porcelain` emits one stanza per worktree, stanzas separated by a blank line, first stanza always the main worktree. Attribute lines per stanza:

- `worktree <absolute-path>` — always present, first line.
- `HEAD <sha>` — always present.
- `branch refs/heads/<name>` — present when the worktree is on a branch.
- `detached` — present instead of `branch` for detached HEAD.
- `bare`, `locked [<reason>]`, `prunable <reason>` — optional.

Parse stanza-wise in bash (`while IFS= read -r line`), keyed on the `worktree ` prefix starting a new record. For paths that could contain newlines git offers `-z` (NUL-terminated, git >= 2.36); repository worktree paths here are timestamp-shaped so line-wise parsing is sufficient, but `-z` is the strictly deterministic option if the planner wants it. A `detached` worktree has no branch and must be skipped for branch classification (only reported).

### Enumerating local branches

Use plumbing, not `git branch`:

```
git for-each-ref --format='%(refname:short) %(objectname)' refs/heads/
```

This is stable, script-safe output (no `*` current-branch marker, no `+ ` worktree marker, no column padding) and reads loose refs and `packed-refs` uniformly — relevant here because `development`, `feature/bootstrap-pc`, and `drm-copilot-wt-2026-07-02-19-03` exist only in `packed-refs`. Sort with `LC_ALL=C` for deterministic ordering (matches the discovery convention in `shell_qc_lib.sh`).

### Classification: `git merge-base --is-ancestor`

```
git merge-base --is-ancestor "$branch_tip" main
```

Exit-code semantics (must be captured with `|| rc=$?` under `set -euo pipefail`, per `.claude/rules/shell.md`):

- `0` — the branch tip is an ancestor of `main`: every commit on the branch is reachable from `main`; the branch is fully merged with zero residual commits.
- `1` — not an ancestor: the branch has at least one commit not reachable from `main` (proceed to residual-commit analysis, section 2).
- `> 1` (typically `128`) — error (unknown revision, corrupt ref). Must be distinguished from `1` and reported as a failure, not treated as "not merged".

Freshness precondition: the check is against the LOCAL `main`. The script should either require/perform `git fetch origin main` first or verify `git rev-parse main` equals `git rev-parse origin/main` and warn on divergence; classifying against a stale `main` can only produce false "not merged" results (safe direction — nothing gets deleted that should not), never false "merged", but the report would be misleading.

### Excluding the current worktree/branch

Two independent exclusions, both required:

1. **Current branch**: `git rev-parse --abbrev-ref HEAD` (returns `HEAD` when detached — treat that as "no branch to protect by name" but still protect the worktree by path). Any branch equal to this value is excluded from deletion candidates.
2. **Current worktree path**: `git rev-parse --show-toplevel` gives the absolute toplevel of the worktree the script runs in; compare (after path normalization — on Windows/WSL, case and slash normalization matter) against each `worktree <path>` from the porcelain output and exclude the match. Also always exclude the FIRST porcelain stanza (the main worktree, `C:/Users/DanMoisan/repos/drm-copilot`) — `git worktree remove` refuses to remove it anyway, but the tool should never list it as a candidate.

Additional belt: any branch whose ref appears as the `branch` of some OTHER live worktree cannot be deleted with `git branch -d/-D` (git refuses with "used by worktree"); the tool must remove that worktree first, which the workflow already orders correctly (worktree removal before branch deletion).

### What to avoid

- Parsing `git branch --merged`, `git branch -vv`, or `git log --oneline` text.
- Any commit-message matching (`--grep`) as classification input.
- Date/name pattern heuristics on branch names (e.g., assuming all `drm-copilot-wt-*` branches are disposable).

---

## 2. Stranded/residual-commit detection

Applies to branches where `--is-ancestor` returned `1`. Goal: decide, per residual commit, whether its content already exists on `main` (droppable) or is unique (cherry-pick candidate).

### Enumerating residual commits

```
git rev-list --reverse main.."$branch"          # oldest-first commit SHAs ahead of main
git rev-list --count main.."$branch"            # residual count
```

`rev-list` is the plumbing equivalent of `git log main..<branch>` and needs no `--format` sanitization. `--reverse` gives application order for later cherry-picking. Note `main..<branch>` (two dots, asymmetric) is correct; `...` (symmetric difference) would also include commits on `main` not on the branch, which is noise here.

### Tier 1 — patch-id equivalence: `git cherry`

```
git cherry main "$branch"
```

Emits one line per commit in `main..<branch>`: `- <sha>` when a commit with an EQUIVALENT patch (same `git patch-id --stable` result) exists on `main`, `+ <sha>` when no equivalent exists. This is exactly the "same content under a different SHA, e.g. re-applied via a different merge/cherry-pick/rebase" detector the spec asks for, using git's own patch-id machinery rather than a hand-rolled loop. A branch that fails `--is-ancestor` but whose `git cherry` output is all `-` lines is content-equivalent-merged and safe to delete.

Manual equivalent (useful for per-commit diagnostics, same semantics): `git show <sha> | git patch-id --stable` and compare the first field against patch-ids computed over candidate `main` commits.

Patch-id limitations (why Tier 2 exists):
- **Squash merges / conflict-resolved merges**: if a residual commit's change landed on `main` combined with other changes or with conflict-resolution edits, the line-level patch differs and `git cherry` reports `+` even though the net content is on `main`.
- **Context drift**: a rebase that changed surrounding lines alters the patch text; `patch-id --stable` normalizes hunk order and whitespace-adjacent noise but not changed context lines.
- **Renames**: a change applied on `main` after a rename produces a different patch (different path header) — `+` despite equivalent content.
- **Empty commits**: a commit with an empty diff (e.g., created with `--allow-empty`, or a merge commit in the range) produces no patch-id; treat empty-diff residual commits as droppable (verify with `git diff-tree --no-commit-id -r <sha>` producing no output). Merge commits in the residual range should be enumerated with `git rev-list --no-merges` for the cherry-pick candidate list and handled separately in reporting.

### Tier 2 — cumulative content diff against main

For commits still marked `+`, check whether the branch's NET content beyond the merge base is already present on `main`:

```
git diff --quiet main..."$branch"        # exit 0: no content difference vs merge base... 
```

More precisely, per residual commit, enumerate its touched paths and compare final blob content:

```
git diff-tree --no-commit-id --name-status -r -M "$sha"     # paths + A/M/D/Rnnn status, rename-aware
git rev-parse "$branch:$path"                                # blob OID at branch
git rev-parse "main:$path"                                   # blob OID at main (fails if path absent)
```

Blob-OID equality (`branch:path` == `main:path`) proves the file's current content on the branch already exists byte-identically at the same path on `main` — this catches the squash/conflict-resolution cases patch-id misses. Equivalent aggregate form: `git diff --quiet main "$branch" -- "$path"` (exit 0 = identical, 1 = differs, >1 = error). Edge cases:

- **Path deleted on branch (`D` status)**: content check inverts — droppable iff the path is also absent on `main` (`git rev-parse main:path` exits non-zero).
- **Renames (`Rnnn` status)**: `-M` in `diff-tree` reports old and new path; compare the NEW path's blob against `main`'s blob at that new path.
- **Path evolved further on main**: branch blob != main blob even though the residual commit's delta was incorporated and then superseded. This is not deterministically resolvable at file granularity; classify as "unique" (conservative — flags for cherry-pick review rather than deleting). The cherry-pick of such a commit will conflict or come up empty, and the conflict-handling policy in section 3 covers it.
- **A residual commit fully reverted by a later residual commit on the same branch**: per-commit checks see two "unique" commits, but the branch-level `git diff --quiet main..."$branch"` (three-dot: diff of branch tip against merge base as seen from main) is empty. Run the branch-level check FIRST: if `git diff --quiet main..."$branch"` exits 0 the whole residual set is content-neutral and droppable without per-commit analysis. Note for this check `main...branch` in `git diff` means "diff merge-base(main,branch) → branch", which is the intended "what does this branch add" question; it is NOT the `rev-list` symmetric-difference meaning.

### Tier 3 — explicitly rejected: message grep

`git log --all --grep="$subject"` finds re-applied commits by message text. It is non-deterministic classification (messages get edited, squash commits concatenate subjects) and is barred by the spec's "not text heuristics" clause. Permitted only as advisory output in the human-readable report (e.g., "a main commit with a similar subject exists: <sha>"), never as an input to the safe/unsafe decision.

### Resulting deterministic decision ladder (per branch)

1. `merge-base --is-ancestor` exit 0 → **MERGED_CLEAN** (delete-eligible).
2. Else `git diff --quiet main...branch` exit 0 → **MERGED_CONTENT_NEUTRAL** (residual commits net to nothing; delete-eligible).
3. Else `git cherry main branch` all `-` (empty diffs counted as `-`) → **MERGED_EQUIVALENT** (delete-eligible).
4. Else, per `+` commit: blob-level check (above) — all touched paths equivalent on `main` → droppable; any path unique → commit enters the **CHERRY_PICK_CANDIDATE** list with its paths, author, and date. The script emits the candidate list; the editorial judgment "is this documentation/agent-memory content" is the LLM/skill layer's job (spec behavior 8), optionally assisted by a deterministic path allowlist (e.g., `docs/**`, `.claude/agent-memory/**`, `**/*.md`) that the script can annotate but not decide with.
5. A branch with at least one unique NON-candidate (code) commit → **NOT_MERGED** (excluded from all destructive action; reported).

---

## 3. Cherry-pick consolidation onto `documentationandmemories`

### Branch and workspace creation

Do NOT `git checkout -b` in the current worktree — that mutates the active checkout the spec protects. Create the consolidation branch in its own worktree, matching this repo's layout:

```
git worktree add "C:/Users/DanMoisan/repos/drm-copilot-wt/documentationandmemories" -b documentationandmemories main
```

(`git worktree add <path> -b <branch> <start-point>` creates the branch off `main` and checks it out at `<path>` in one step; equivalent to `git checkout -b documentationandmemories main` but isolated.) Precondition checks: branch `documentationandmemories` must not already exist (`git rev-parse --verify --quiet refs/heads/documentationandmemories` exits non-zero) — if it exists from a prior aborted run, the script must stop and report rather than reuse silently. `git branch <name> <start>` alone is insufficient because cherry-pick requires a checked-out working tree.

### Cherry-pick mechanics

All subsequent commands run with `-C <consolidation-worktree-path>` (or `git -C`), never in the caller's worktree.

```
git -C "$wt" cherry-pick -x "$sha"
```

- **Authorship**: cherry-pick preserves author name/email/date by default; only the committer identity/date changes. No extra flags needed for the spec's "preserving commit authorship".
- **Provenance**: `-x` appends `(cherry picked from commit <sha>)` to the message — recommended so the consolidation PR is auditable back to the stranded branches.
- **Order**: within one source branch, apply oldest-first (`git rev-list --reverse main..<branch>` order) so intra-branch dependencies (e.g., a MEMORY.md index line added then amended) apply cleanly. Across branches, process branches in `LC_ALL=C` sorted name order (deterministic) — the repo's timestamp-shaped branch names make this chronological as a side effect. Multiple commits can be passed in one invocation (`git cherry-pick -x sha1 sha2 ...`) but per-commit invocation gives cleaner per-commit error attribution; prefer per-commit.
- **Multiple source branches into one branch**: nothing special — sequential cherry-picks onto the same HEAD. The realistic conflict hot spot is index-style files touched by several stranded branches (e.g., `.claude/agent-memory/*/MEMORY.md`, `docs/**` indexes) where two branches append adjacent lines.

### Failure modes and required handling

- **Conflict**: `git cherry-pick` exits `1`, writes `CHERRY_PICK_HEAD`, leaves conflict markers. The deterministic script must NOT auto-resolve: run `git -C "$wt" cherry-pick --abort`, record the commit as `CONFLICT`, and continue or stop per a `--keep-going` policy decision for the planner. Conflicted commits are surfaced to the LLM/skill layer (editorial judgment), consistent with spec behavior 8. Detect the state via exit code plus `git -C "$wt" rev-parse --verify --quiet CHERRY_PICK_HEAD`.
- **Empty result** ("The previous cherry-pick is now empty"): means the content already landed on `main` — corroborates a Tier-2 miss. Resolve with `git -C "$wt" cherry-pick --skip` and reclassify the commit as droppable. (`--empty=drop` automates this but requires git >= 2.45; `--skip` on failure is version-portable. `--keep-redundant-commits`/`--allow-empty` would pollute the PR with empty commits — do not use.) The Tier-1/2 pre-filter should make this rare.
- **Nothing to consolidate**: skip branch creation entirely; the workflow proceeds straight to deletion (spec behavior 7's "or when there was nothing to consolidate").
- **Cleanup on abort**: if the run aborts, the consolidation worktree and branch must be removed (`git worktree remove`, `git branch -D documentationandmemories`) or explicitly left with a reported resume path — the planner must pick one; silent leftovers recreate the problem this tool exists to fix.

---

## 4. pr-author handoff contract

Verified from `.claude/skills/pr-author/SKILL.md`, `.claude/agents/pr-author.md`, and `.claude/skills/orchestrate/SKILL.md` ("PR Authoring (pr-author Handoff)").

**Division of labor.** The new cleanup skill/script never calls `gh pr create` or `gh pr edit --body*`. Those commands are reserved to `Agent(pr-author)` and blocked for everyone else by the `enforce-pr-author-skill.ps1` PreToolUse hook. The cleanup skill's job ends at: consolidation branch pushed, PR-context bundle fresh, delegation issued.

**Mandatory sequence (from orchestrate SKILL.md, steps 1–4):**

1. Refresh the PR-context bundle so it reflects the `documentationandmemories` branch: `mcp__drm-copilot__collect_pr_context` (backing implementation `scripts/dev_tools/pr_context/collector.py`), producing `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`. Base branch is `main` (explicit; `pr-base-branch-merge-base` resolution applies only when ambiguous, per `pr-context-artifacts` SKILL).
2. Validate the orchestrator-state checkpoint: `artifacts/orchestration/orchestrator-state.json` with `--require-pr-creation-ready`; record the result under `pr_author_preflight` (`{status, checked_at, checkpoint_path, validator_command, output_summary}`). Delegation is prohibited when this fails.
3. Delegate to `Agent(pr-author)`. That agent (model: sonnet; tools: Read, `Bash(git log *)`, `Bash(git rev-parse *)`, `Bash(gh pr create *)`, `Bash(gh pr edit *)`, `Write(/artifacts/**)`) authors the body per the pr-author skill and performs the file writes and `gh pr create`.
4. Record `pr_author_receipt` in the checkpoint citing the verified body-file and receipt paths.

**Body file + receipt shape the pr-author agent produces (the contract the delegation relies on):**

- Body: `artifacts/pr_body_<N>.md`, where `<N>` is the target issue or PR number. For this feature the consolidation PR's `<N>` should be `396` unless a dedicated issue is opened for the consolidation PR — the planner must fix this choice; the receipt's `number` field must match whatever `<N>` is used.
- Receipt: sibling `artifacts/pr_body_<N>.receipt.json`, exactly:

```json
{
  "skill": "pr-author",
  "pr_body_path": "artifacts/pr_body_<N>.md",
  "number": <N>,
  "sha256": "<lowercase-hex SHA-256 of the body bytes>",
  "context_summary_path": "artifacts/pr_context.summary.txt",
  "created_at": "<ISO-8601 UTC, strictly newer than pr_context.summary.txt last-write>"
}
```

- PR creation must use `--body-file artifacts/pr_body_<N>.md`; inline `--body` is hook-blocked. The hook verifies five ordered checks: canonical body-file path, receipt present, `number` match, `sha256` match against body bytes, `created_at` strictly newer than the context-summary last-write.
- The pr-author agent must report the PR URL or `PR #<n>` in its final output (SubagentStop hook `validate-pr-author-output.ps1` blocks otherwise).
- Auto-close: `- Closes #NNN` only from verified autoclose context. The consolidation PR should reference #396 only if #396 appears in the provided context; the cleanup skill should ensure the feature/issue reference is present in the PR-context inputs rather than instructing pr-author to invent it.

**Gating deletion on PR merge (spec behavior 7).** The cleanup skill must observe merge state before the deletion phase — deterministic check: `gh pr view <n> --json state,mergedAt` or, git-native, re-run the section-1 ancestry check on `documentationandmemories` itself (`git merge-base --is-ancestor documentationandmemories main` after `git fetch`). The git-native re-check is preferable: it is the same primitive, and it simultaneously re-validates that every previously flagged commit is now reachable from `main`. After the consolidation PR merges, `documentationandmemories` and its worktree become instances of MERGED_CLEAN and are cleaned up by the same deletion mechanics.

---

## 5. Worktree/branch deletion mechanics

### `git worktree remove <path>`

- Removes the worktree directory and its administrative files under `.git/worktrees/<id>`.
- **Refusal behavior (precise):** only clean worktrees can be removed — a worktree containing modifications to tracked files OR any untracked files makes `git worktree remove` fail with a non-zero exit and the message `fatal: '<path>' contains modified or untracked files, use --force to delete it`. A worktree with submodules also requires `--force`.
- `--force` overrides the dirty check (one `--force`); a **locked** worktree requires `--force` given twice (`--force --force`) or a prior `git worktree unlock`.
- The **main worktree cannot be removed** (`fatal: '<path>' is a main working tree`).
- Default policy for this tool: NO `--force`. A dirty worktree means potentially unpreserved content — exactly the failure class (stranded agent-memory files, uncommitted review artifacts) documented in this repo's own cleanup history (the `agent-ae68d14e27bb8727e` worktree removed 2026-07-21 held an uncommitted review-artifact cycle that had to be copied out first). The tool should report dirty worktrees with their `git -C <path> status --porcelain` output and leave them; a `--force` passthrough flag may exist but must never be the default.
- If a worktree directory was already deleted manually, the registration is stale: `git worktree prune` removes stale entries (`--dry-run` available). The tool should treat `prunable` stanzas from the porcelain output as report-only prune candidates.

### Branch deletion: `-d` vs `-D`

- `git branch -d <name>` succeeds only when the branch is fully merged into **HEAD** (the branch currently checked out where the command runs) or, if unmerged into HEAD, into its own configured upstream. Otherwise: `error: the branch '<name>' is not fully merged` (exit non-zero).
- `git branch -D <name>` deletes unconditionally.
- Both refuse to delete a branch checked out in ANY worktree (`error: cannot delete branch '<name>' used by worktree at '<path>'`) — hence the fixed order: worktree removal first, then branch deletion.
- **Which to use here:** the `-d` safety check is HEAD-relative, not main-relative. This tool runs from an arbitrary worktree (currently `drm-copilot-wt-2026-07-21T21-57`, not `main`), so `-d` would spuriously fail for branches merged into `main` but not into the current branch — and conversely `-d` is NOT a check against `main` at all, so it adds no safety aligned with this tool's contract. Since the script has just proven merge status itself (ancestry or content equivalence), the correct pattern is: re-run `git merge-base --is-ancestor <tip> main` (or the recorded equivalence verdict) immediately before deletion in the same process, then delete with `-D`. Using `-D` with an explicit self-owned precondition is more deterministic than relying on `-d`'s HEAD-relative semantics. The spec's issue text mentions `git branch -d`; the plan should document this refinement (it satisfies the intent — merged-only deletion — with a check against the correct base).
- Branches with no associated worktree (e.g., `drm-copilot-wt-2026-07-21T17-20`): deletion is the branch-delete step alone; no worktree step.

### Ordering per candidate

1. Re-verify classification (ancestry/equivalence) at deletion time.
2. `git worktree remove <path>` (skip/report if dirty; skip if no worktree).
3. `git branch -D <name>` (after re-verification).
4. Optionally `git worktree prune` for stale registrations, report-only by default.

---

## 6. Existing repo conventions

### Bash script conventions (from `.claude/rules/shell.md` and `scripts/bash/`)

- Layout pattern (verified in `shell-qc.sh` + `shell_qc_lib.sh`): thin executable wrapper with `set -euo pipefail`, `SCRIPT_DIR` self-resolution, `usage()` heredoc, `main()` with `case` dispatch returning `2` for usage errors, source-guard `if [[ ${BASH_SOURCE[0]} == "${0}" ]]` so bats can source without executing; all logic in a sourceable `*_lib.sh` with per-function comment blocks. The new tool should be `scripts/bash/cleanup-worktrees.sh` + `scripts/bash/cleanup_worktrees_lib.sh` (names for the planner to confirm).
- `set -euo pipefail`; every command that legitimately returns non-zero (`merge-base --is-ancestor`, `diff --quiet`, `cherry-pick`, `worktree remove` on dirty trees) captured with `|| rc=$?`.
- shfmt default formatting (tabs); shellcheck-clean, suppressions only inline with justification; quote all expansions; resolve tools with `command -v`; 500-line cap per file (the classification ladder + consolidation + deletion likely forces the lib/wrapper split anyway, possibly two libs).
- Toolchain: `bash scripts/bash/shell-qc.sh format` / `check` / `test [--coverage]`. On Windows run under WSL; CI runs on `ubuntu-latest` (`.github/workflows/_shell-coverage.yml`). CI tool versions are canonical. Known operational constraint from recent shell-QC work (#393/#394): no local delegate can run the bash toolchain in this Windows environment; CI dispatch is the verification path. The plan should budget for CI-based verification of the bats suite.
- Environment-override seam convention: `SHELL_QC_<TOOL>_BIN` per external tool, empty/nonexistent value treated as missing. The new script should expose the same pattern for its externals — at minimum a `CLEANUP_WT_GIT_BIN`-style git override — because this seam is HOW the existing tests stub external binaries.

### Bash test framework (established — reuse, do not introduce)

- Framework: **bats**, already in use — six files in `tests/shell/*.bats` (e.g., `test_shell_qc_discovery.bats`, `test_shell_qc_commands.bats`, `test_coverage_demo.bats`). Runner discovery covers `tests/shell` and `tests/bash`; the convention in use is `tests/shell/`.
- Test file path convention: `.claude/rules/shell.md` states tests live in `tests/shell/*.bats` and mirror `scripts/bash/`; general policy (`general-unit-test.md`) states tests mirror production structure (`scripts/powershell/Foo.ps1` → `tests/scripts/powershell/Foo.Tests.ps1`). The shell-specific rule and the actual tree (`tests/shell/test_<snake_name>.bats`) are the operative convention: the new tests belong at `tests/shell/test_cleanup_worktrees_<topic>.bats`.
- Test style (verified in `test_shell_qc_discovery.bats`): header comment describing scope; `setup()` computing `REPO_ROOT`, `LIB`, `FIXTURE_ROOT`; each `@test` uses `run bash -c "source '${LIB}' && <function> <args>"` and asserts `$status`/`$output`. **No temporary files** — checked-in fixtures under `tests/fixtures/shell_qc/` and checked-in stub binaries under `tests/fixtures/shell_qc/stub-bin/` (stub `shfmt`, `shellcheck`, `bats`, `kcov` exist) wired through the `SHELL_QC_<TOOL>_BIN` seam.
- **Tension the planner must resolve explicitly:** the spec's seeded test conditions mention an integration run "against a scratch git repo fixture ... a disposable git repo built in a test-only helper", but `.claude/rules/shell.md` and `general-unit-test.md` prohibit temporary files in tests. The established, policy-compliant resolution is the stub-binary pattern: a checked-in `git` stub under `tests/fixtures/cleanup_worktrees/stub-bin/git` that replays canned `worktree list --porcelain` / `for-each-ref` / exit-code scenarios via the env-var seam. A real-git end-to-end scenario, if kept, must be scoped as an integration test with an explicitly sanctioned mechanism (e.g., `BATS_TEST_TMPDIR`-based, CI-only) and the plan must call out the policy exception rather than let it surface in review as a Blocking finding. Coverage: kcov line coverage only, >= 85% line threshold applies (no bash branch gate).

### SKILL.md conventions (verified across `pr-author`, `identify-session-id`, `python-qa-gate`, `make-skill-template`)

- Location: `.claude/skills/<lowercase-hyphenated-name>/SKILL.md`; frontmatter `name:` must match the folder exactly.
- Frontmatter fields in use: `name`, `description` (single-quoted, states WHAT + WHEN, keyword-rich), and — only when the skill itself runs tools — `allowed-tools` as a YAML list, with scoped Bash patterns quoted (pr-author: `- Read`, `- "Bash(git log *)"`; identify-session-id: `- Read`, `- Bash`). Procedural skills that only instruct (python-qa-gate, pr-context-artifacts) omit `allowed-tools`.
- Body structure in house style: `# Title`, short overview paragraph, `## When to Use This Skill` (bulleted triggers), then workflow sections (numbered steps), explicit prohibited-shortcut / policy sections where destructive or gated behavior exists, and cross-references to other skills/rules by path. Body under 500 lines.
- For the new skill: frontmatter should scope Bash to the wrapper (e.g., `- "Bash(bash scripts/bash/cleanup-worktrees.sh *)"` plus the narrow git/gh read-only commands the skill layer needs), and the body must document the full workflow: detect → report → consolidate → pr-author handoff (referencing `.claude/skills/pr-author/SKILL.md` and the orchestrate handoff sequence, NOT re-specifying `gh pr create`) → post-merge deletion. This satisfies the AC "Skill documents the cherry-pick-to-documentationandmemories-then-PR-then-delete workflow end to end."

---

## 7. Automation Feasibility

This feature is fully automatable with local tooling. Every step is a local `git` operation (`worktree list/add/remove`, `for-each-ref`, `merge-base`, `rev-list`, `cherry`, `diff`, `cherry-pick`, `branch -D`, `fetch`) or a `gh` CLI operation performed by the existing `pr-author` agent (`gh pr create --body-file`) and, for merge-state observation, `gh pr view`/a git-native ancestry re-check. There is no third-party UI interaction, no portal, no manual click, and no credential/approval flow outside the already-provisioned `gh` authentication. **No human-interaction exception (per `.claude/skills/human-exception-runbook/SKILL.md`) is needed.** The single wait state — the consolidation PR must merge before the deletion phase — is a CI/branch-protection wait observable and completable entirely via CLI (`gh pr merge` subject to required checks), not a manual step. Editorial classification of stranded content ("is this really documentation/memory") is by design an in-session LLM judgment (spec behavior 8), which is agent work, not human interaction.

---

## Requirements Mapping (acceptance criteria → design elements)

| Acceptance criterion (issue.md) | Design element |
|---|---|
| Deterministically lists merged worktrees/branches with no residuals, safe to auto-delete | Section 1 ladder step 1 (`--is-ancestor` exit 0) + section 5 deletion order |
| Distinguishes residual content-already-on-main from unique documentation content | Section 2 tiers 1–2 (`git cherry` patch-id, blob/diff content checks); unique commits → CHERRY_PICK_CANDIDATE list |
| Never selects the current worktree/branch | Section 1 dual exclusion (`rev-parse --abbrev-ref HEAD` + `--show-toplevel` vs porcelain paths + main-worktree exclusion) |
| Skill documents cherry-pick → PR → delete workflow end to end | Section 6 SKILL.md structure; sections 3–5 supply the content |
| Unit tests cover the six enumerated scenarios | Section 6 bats + git-stub seam; scenarios map to canned porcelain/for-each-ref/exit-code fixtures |

Proposed state model for a branch: `NOT_MERGED | MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT | HAS_UNIQUE_RESIDUALS | PROTECTED_CURRENT`; per-residual-commit: `EQUIVALENT | CONTENT_ON_MAIN | EMPTY | UNIQUE(paths)`. Output contract: dry-run (default) prints a deterministic machine-parseable report (one line per branch/commit, `LC_ALL=C` ordering); `--apply` executes deletion for delete-eligible states only; consolidation and PR handoff are skill-layer steps invoking script subcommands.

## Testing Implications (strategy only)

- Unit (bats, `tests/shell/`): porcelain parsing (branch/detached/locked/prunable stanzas), for-each-ref parsing incl. packed-refs shapes, exit-code ladder for `--is-ancestor` (0/1/128 via git stub), `git cherry` output parsing (`-`/`+`/empty), blob-equality decisions (A/M/D/rename), current-worktree/branch exclusion, dirty-worktree refusal path, `-D` re-verification gate, dry-run vs apply gating. All through a checked-in `git` stub in `tests/fixtures/cleanup_worktrees/stub-bin/` driven by the env-override seam — no temp files, matching `shell_qc` fixture precedent.
- The six AC scenarios (merged/no-worktree, merged/with-worktree, unmerged, residual-equivalent, residual-unique-doc, current-branch exclusion) each get a named fixture scenario for the stub.
- Coverage: kcov line coverage >= 85% on the new lib; wrapper kept thin per the coverage-exclusion policy (no production file excluded).
- Verification path: shell toolchain runs in CI (`ubuntu-latest`); plan for CI-dispatch verification given the local-WSL constraint noted in section 6.
