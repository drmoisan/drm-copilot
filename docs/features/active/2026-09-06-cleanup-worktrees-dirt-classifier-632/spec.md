# 2026-09-06-cleanup-worktrees-dirt-classifier (Spec)

- **Issue:** #632
- **Parent (optional):** epic `cleanup-merged-worktrees-hardening` (child C)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06T23-55
- **Status:** Draft
- **Version:** 0.2

## Context
`/cleanup-merged-worktrees` reports dirty worktrees as `BLOCKED-DIRTY` without classifying the
dirt, so an operator cannot tell disposable build or session output from work that exists only in
that worktree. On the 2026-09-06 run this left 14 worktrees on already-merged branches requiring
manual, file-by-file triage.

Environment:
- OS/version: Windows 11 Pro 10.0.26200, bash toolchain under WSL Ubuntu
- Python version: not applicable; the cleanup toolchain is native bash
- Command/flags used: `/cleanup-merged-worktrees` report mode and apply mode
  (`bash scripts/bash/cleanup-worktrees.sh`)
- Data source or fixture: the TaskMaster checkout as observed on 2026-09-06

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A cleanup run that reports 14 unclassified blocked worktrees pushes the entire triage burden onto
the operator, and the manual triage is exactly the work the skill exists to automate.


## Repro & Evidence
Steps to Reproduce:
1. Run `/cleanup-merged-worktrees` in report mode against a checkout that carries worktrees on
   already-merged branches whose working trees are dirty.
2. Observe that report mode emits `WORKTREE|` records with no statement about the nature of the
   dirt in each worktree.
3. Run apply mode against the same checkout.
4. Observe that each dirty worktree produces `DIRTY|<path>|<status-porcelain-line>` records
   followed by `ACTION|worktree-remove|<path>|BLOCKED-DIRTY`, with no verdict distinguishing
   disposable output from unique work.

Expected:
Report mode labels every dirty worktree with a deterministic verdict so the operator can decide
without inspecting each file by hand, and an explicit opt-in flag clears provably disposable dirt
and completes the normal non-forced removal.

The six verdicts required by the run observations are:

- `DISPOSABLE_BUILD_ARTIFACT`
- `DISPOSABLE_SESSION_ARTIFACT`
- `CONTENT_ON_MAIN`
- `CONTENT_IN_HISTORY`
- `STAGED_TREE_IS_COMMIT <sha>`
- `UNIQUE`

Actual:
The only classification an operator receives is the raw `git status --porcelain` line carried on
each `DIRTY|` record, and that record is emitted only in apply mode. Report mode says nothing at
all about dirt. Every dirty worktree is treated identically regardless of whether its dirt is a
`nuget restore` HintPath rewrite or a file that exists nowhere else.

Verbatim from the 2026-09-06 run observations:

> ### 2. Dirty worktrees are blocked with no classification of the dirt
>
> 14 worktrees on merged branches were reported `BLOCKED-DIRTY`. In every case the dirt was one of:
> `*.csproj` / `packages.config` / `app.config` analyzer-HintPath rewrites left by `nuget restore`;
> `artifacts/pr_context.summary.txt` / `artifacts/pr_context.appendix.txt`;
> `artifacts/orchestration/orchestrator-state.json`; or untracked files whose exact content already
> exists in `main`'s history (`git log main --find-object=<blob>` hits) or matches `main`'s current
> blob at the same path.
>
> Required: add a deterministic dirt classifier to report mode that labels each `DIRTY|` line
> `DISPOSABLE_BUILD_ARTIFACT`, `DISPOSABLE_SESSION_ARTIFACT`, `CONTENT_ON_MAIN`,
> `CONTENT_IN_HISTORY`, `STAGED_TREE_IS_COMMIT <sha>` (compare `git write-tree` against the
> branch's commit trees; one worktree carried 86 staged changes that were exactly an earlier
> commit), or `UNIQUE`. Add an opt-in apply flag (for example `--clear-disposable`) that, for a
> worktree whose dirt is entirely non-`UNIQUE`, runs `git reset --hard` + `git clean -fd` and then
> the normal non-forced removal. Keep the default behavior unchanged. `UNIQUE` dirt still blocks.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:

```
DIRTY|/repo-wt/dirty|?? untracked-artifact.txt
ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY
```


## Scope & Non-Goals

- In scope:
  - A new production library `scripts/bash/cleanup_worktrees_dirt_lib.sh` defining
    `classify_worktree_dirt <worktree-path>`, `classify_dirt_entry`, a bounded staged-tree probe,
    and `clear_disposable_dirt <worktree-path>`.
  - Two new report record types, `DIRTFILE|` and `DIRTSUM|`, emitted by report mode for every
    non-main, non-bare worktree that has at least one `git status --porcelain` entry.
  - The six verdicts listed in Repro & Evidence, assigned per status entry by a deterministic,
    fail-closed precedence ladder.
  - An opt-in, apply-mode-only `--clear-disposable` modifier that clears a worktree whose dirt is
    entirely non-`UNIQUE` and then retries the existing non-forced removal.
  - Anchored edits to `scripts/bash/cleanup_worktrees_lib.sh` (report-line contract comment and the
    `run_report` worktree loop), `scripts/bash/cleanup_worktrees_actions_lib.sh` (`delete_candidate`
    clearing hook only), and `scripts/bash/cleanup-worktrees.sh` (source block, `usage`, flag
    pre-pass).
  - Extensions to the recording stub `tests/fixtures/cleanup_worktrees/stub-bin/git`, new checked-in
    scenario fixtures under `tests/fixtures/cleanup_worktrees/scenarios/`, and new and updated bats
    suites under `tests/shell/`.
  - `.claude/skills/cleanup-merged-worktrees/SKILL.md` reconciliation, mirrored byte-identically
    into the bundled copy under `extensions/drm-copilot/resources/claude-customizations/`.

- Out of scope / non-goals:
  - Detached-worktree classification and the consolidation-branch ordering hazard — epic child A,
    issue #630.
  - Orphan, stale-ref, `CHILD_OF`, and `registration-lost` report records — epic child B.
  - The removal manifest — epic child D.
  - `PRESERVE` consolidation — epic child F.
  - Any change to the branch classification ladder, the apply-mode state allowlist, or the states
    `NOT_MERGED` / `HAS_UNIQUE_RESIDUALS` / `PROTECTED_CURRENT` are acted on under.
  - Any change to `remove_worktree_safe` itself, including its `DIRTY|` emission and its
    fail-closed status-read behavior.
  - Narrowing the SKILL's `allowed-tools` entry. The existing
    `"Bash(bash scripts/bash/cleanup-worktrees.sh *)"` wildcard already covers the new flag; no
    `allowed-tools` edit is required and narrowing it belongs to a separate change.
  - Clearing ignored files. `git clean` is never invoked with `-x`, `-X`, or `-ff`, and the status
    read is never given `--ignored`.

- Explicitly excluded systems, integrations, or datasets:
  - No consumer-repository copy is patched. Delivery is in `drm-copilot` only. The TaskMaster
    checkout that produced the 2026-09-06 observations receives the change through the normal
    bundle push-down, not through an edit made in this change.
  - No new external service, no network access, and no new dependency. The classifier uses only
    git plumbing already reachable through the `cleanup_wt_git` seam.
  - `scripts/bash/**` is not in the push-down mirror scope. The mirror scope is `.claude/**` only
    (`SCOPED_ROOTS = (Path(".claude"),)` at
    `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:20`), so none of the four
    production shell files, the stub, the fixtures, or the bats suites are mirrored.


## Root Cause Analysis
- The only `DIRTY|` emission site is `scripts/bash/cleanup_worktrees_actions_lib.sh:274`, inside
  `remove_worktree_safe`, immediately before the `ACTION|worktree-remove|%s|BLOCKED-DIRTY` emission
  at `:277`. That is apply mode. The requirement places the classifier in report mode, so the
  emission site and the requirement disagree and the resolution must be decided and recorded.
- `STAGED_TREE_IS_COMMIT <sha>` requires `git write-tree`, which writes to the object database and
  to the index. Report mode must remain non-mutating, so the index used for that comparison must be
  redirected away from the inspected worktree's own index.
- `scripts/bash/cleanup_worktrees_lib.sh` is at 479 lines and
  `scripts/bash/cleanup_worktrees_actions_lib.sh` at 382 against the 500-line cap in
  `.claude/rules/general-code-change.md`, so the classifier belongs in a new sibling library.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` **Prohibited Shortcuts** states that a dirty
  worktree is never force-removed. A `--clear-disposable` flag clears and then removes without
  force, which is consistent with that prohibition but is not obviously so from the current text.


## Proposed Fix

### Design summary (what changes where):

The design source is
`docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/research/2026-09-06-dirt-classifier-design-research.md`.
Every recommendation in that record is accepted. Three decisions resolve disagreements between the
requirement text and the current code and are recorded here in full, because a reviewer comparing
the implementation against the requirement's literal wording would otherwise read the
implementation as a deviation.

**Decision 1 — emission site: a shared classifier in a new library, with new record types.**

Research §2, option (b). A new file `scripts/bash/cleanup_worktrees_dirt_lib.sh` defines
`classify_worktree_dirt <worktree-path>`. It is called from `run_report`
(`scripts/bash/cleanup_worktrees_lib.sh`, the worktree loop) and from the `--clear-disposable` path
in `delete_candidate` (`scripts/bash/cleanup_worktrees_actions_lib.sh`). Report mode emits two new
record types:

```
DIRTFILE|<worktree-path>|<verdict>|<detail>|<status-code>|<file-path>
DIRTSUM|<worktree-path>|<ALL_DISPOSABLE|HAS_UNIQUE>|<detail>
```

The existing `DIRTY|` record is left byte-identical. It does not gain a verdict field.

This is a deliberate departure from the requirement's literal wording, which says the classifier
"labels each `DIRTY|` line". The departure and its reason are recorded here rather than left
implicit:

- `DIRTY|<worktree-path>|<status-porcelain-line>` is a published three-field contract, documented
  in `scripts/bash/cleanup-worktrees.sh:45`, `scripts/bash/cleanup_worktrees_lib.sh:45`, and
  `.claude/skills/cleanup-merged-worktrees/SKILL.md:69`, and asserted at
  `tests/shell/test_cleanup_worktrees_deletion.bats:28`. Appending a fourth field would survive
  that substring assertion while silently changing the contract for every downstream consumer.
- `DIRTFILE|` and `DIRTSUM|` are additive and collide with nothing under prefix matching: `DIRTY|*`
  does not match `DIRTFILE|...`, and `DIRTFILE|*` does not match `DIRTY|...`.
- The file path is the **last** field of `DIRTFILE|`, so a path containing a pipe character cannot
  corrupt any earlier field. `<detail>` carries a commit SHA for `STAGED_TREE_IS_COMMIT` and
  `CONTENT_IN_HISTORY` and is empty otherwise, which preserves the requirement's
  `STAGED_TREE_IS_COMMIT <sha>` information without a variable-arity field.
- A single shared function means the verdicts the operator reads in the report are, structurally,
  the same verdicts the clearing gate acts on. Duplicating the logic for a report-only emission
  would create two definitions of "disposable", one of which authorizes an irreversible action.

**Decision 2 — how "keep the default behavior unchanged" is interpreted.**

Research §2, "Reconciling the byte-identical constraint". The constraint binds:

1. **Mutating behavior** — which side-effecting git commands are issued, and which worktrees and
   branches are removed or deleted.
2. **The shape and ordering of every existing record type** — `BRANCH|`, `COMMIT|`, `WORKTREE|`,
   `WARN|`, `DIRTY|`, and `ACTION|` keep their field counts, field values, and relative order.

It does **not** forbid additive report records carrying new prefixes.

The justification is internal to the requirement paragraph. Its first sentence mandates new
report-mode output and attaches no flag to that output. If "keep the default behavior unchanged"
also covered report-mode stdout, the same paragraph would mandate and forbid the same change. The
sentence sits between the description of the destructive flag and "`UNIQUE` dirt still blocks",
both of which are statements about destructive behavior, so the mutating reading is the only
self-consistent one.

This interpretation is load-bearing and must be auditable. Two guardrails constrain it and both are
pinned by tests (see Acceptance Criteria): no existing record type changes; and apply-mode stdout
is byte-identical without the flag while report mode issues no new mutating command.

**Decision 3 — `STAGED_TREE_IS_COMMIT` is detected without `git write-tree`.**

Research §3. The verdict is detected with
`git --no-optional-locks -C <wt> diff-index --cached --quiet <commit> --` against bounded candidate
commits obtained from `git -C <wt> rev-list --max-count=<N+1> HEAD` with the first entry (HEAD
itself) dropped. `git write-tree` is not used, and no test or production path sets
`GIT_INDEX_FILE`. The reasons:

- A naive `GIT_INDEX_FILE` redirect to a scratch path makes `write-tree` serialize an **empty**
  index, yielding the empty tree `4b825dc642cb6eb9a060e54bf8d69288fbee4904`. That is a wrong answer,
  not a slow one: it is a deterministic false negative for every worktree.
- `git read-tree` cannot repair that. Seeding a scratch index from a commit's tree and comparing the
  resulting `write-tree` output against that same commit is true by construction and measures
  nothing. No plumbing command copies a *staged* index into another index.
- The only correct write-tree route is a filesystem copy of the real per-worktree index into a
  scratch path, which requires locating the per-worktree git directory and managing a temporary
  file — and `write-tree` still writes tree objects into the inspected repository's object database,
  because `GIT_INDEX_FILE` redirects only the index. Writing unreferenced loose tree objects is a
  real mutation and contradicts `run_report`'s stated contract at
  `scripts/bash/cleanup_worktrees_lib.sh:446` and the CLI's at `scripts/bash/cleanup-worktrees.sh:32-34`.
- `git diff-index --cached` is documented as answering the identical question — the difference
  between a commit and the index contents "the ones I'd write using `git write-tree`" — and writes
  nothing: it neither refreshes nor rewrites the index and creates no objects. `--quiet` implies
  `--exit-code`, so exit 0 means the index matches that commit's tree and exit 1 means it does not.

Report mode must remain non-mutating, and `diff-index --cached --quiet` is the mechanism by which
it does.

### Boundaries and invariants to preserve:

- `remove_worktree_safe` (`scripts/bash/cleanup_worktrees_actions_lib.sh:252-279`) is not modified.
  Its single `git worktree remove` invocation at `:263` carries no force flag and remains the only
  removal path used by deletion. Its fail-closed status-read behavior, pinned by
  `tests/shell/test_cleanup_worktrees_hard_failures.bats:166-172`, is unchanged.
- `reverify_delete_eligible` (`:218-250`) is reused as-is. No variant is introduced.
- Fail-closed is the family convention and here it means "blocks clearing": any non-zero exit from
  any classifier git read maps that entry to `UNIQUE`, which makes the worktree aggregate
  `HAS_UNIQUE`, which refuses the clear.
- Every git call goes through the `cleanup_wt_git` seam
  (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:34-57`) so the stub seam stays complete.
- Every read the new library issues carries `--no-optional-locks`, most importantly the
  `status --porcelain` read, so report mode cannot rewrite the inspected worktree's index stat
  cache as a side effect. The existing apply-mode status read at
  `scripts/bash/cleanup_worktrees_actions_lib.sh:270` is deliberately left unmodified so apply-mode
  argv stays byte-identical.
- The libraries define functions only and run nothing at source time.
- The 500-line cap in `.claude/rules/general-code-change.md` and `.claude/rules/shell.md:89` applies
  to every production and test shell file touched.

### Dependencies or blocked work:

- No blocking dependency. The change is self-contained within the cleanup-worktrees family.
- Fan-in with epic child A (#630), which also targets `run_report` in
  `scripts/bash/cleanup_worktrees_lib.sh` and the CLI. See Risks & Mitigations.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| File | Nature of change |
|---|---|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | New. Constants, `classify_dirt_entry`, `classify_worktree_dirt`, the staged-tree probe, `clear_disposable_dirt`, helpers. |
| `scripts/bash/cleanup_worktrees_lib.sh` | Two anchored hunks: two lines added to the report-line contract comment block after `:45`; a guarded `classify_worktree_dirt "$wpath"` call plus one comment inside the `run_report` worktree loop at `:465-469`. |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | Two anchored hunks: header-comment lines noting the clearing hook; replacement of `:310-312` inside `delete_candidate` with the guarded clear-and-retry block. `remove_worktree_safe` untouched. |
| `scripts/bash/cleanup-worktrees.sh` | Three anchored hunks: a fourth source block appended after `:24`; `usage` additions; a flag pre-pass inserted before `local command=${1:-}`. |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | A `GIT_INDEX_FILE` environment log line after `:45`; `--no-optional-locks` added to the global-option strip; keying for non-`--quiet` `diff` and range-free `rev-list`; new subcommand arms covering at minimum `hash-object`, `log`, `diff-index`, `reset`, and `clean`. `write-tree` is deliberately not added. |
| `tests/fixtures/cleanup_worktrees/scenarios/dirt_*/` | New checked-in scenario directories, one per verdict plus the mixed, clearing, ordering, and read-error cases. |
| `tests/shell/test_cleanup_worktrees_*.bats` | Each existing suite gains the new library in its `source` chain. A new suite carries the classifier and clearing tests. |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | Report Line Contract, Prohibited Shortcuts, and Dirty Worktree Triage Procedure edits. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | Byte-identical mirror of the SKILL.md edits. |

#### Functions/classes/CLI commands impacted:

- New: `classify_worktree_dirt`, `classify_dirt_entry`, the bounded staged-tree probe,
  `clear_disposable_dirt`.
- Modified: `run_report` (one guarded call), `delete_candidate` (the clear-and-retry block),
  `usage`, `main` (flag pre-pass).
- Unmodified by design: `remove_worktree_safe`, `reverify_delete_eligible`, `delete_branch`,
  `classify_branch`, `run_apply`, `parse_worktree_list`, `enumerate_branches`,
  `check_main_freshness`, `compute_protected`.
- CLI: `--clear-disposable` is added as an apply-mode-only modifier. Supplying it without `--apply`
  is a usage error with exit code 2, not a silently ignored no-op, because an operator who typed it
  expects clearing to happen.

#### Data flow and validation changes:

Report mode: for each non-main, non-bare worktree registration, `classify_worktree_dirt` performs a
guarded `--no-optional-locks ... status --porcelain` read. Each line yields a status code
`xy=${line:0:2}` and a path `rel=${line:3}`; for a rename or copy entry the payload is `OLD -> NEW`
and the text after ` -> ` is used. If `rel` begins with a double quote the entry is C-quoted and is
classified `UNIQUE` immediately with no unquoting attempt — deterministic, one branch, and failing
in the safe direction. The read is not given `-z`, which would complicate the line-oriented loop for
no classification benefit and would diverge the payload from `DIRTY|`.

Precedence, first match wins, evaluated per file (research §4.6):

1. `STAGED_TREE_IS_COMMIT` — staged entries only (X column not in `' ?!'`), when the once-per-worktree
   probe matched.
2. `DISPOSABLE_SESSION_ARTIFACT` — exact repo-relative match against a hard-coded path array
   (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`,
   `artifacts/orchestration/orchestrator-state.json`). Pure string comparison; no git call. Exact
   match only, never a prefix: `artifacts/**` at large must not be auto-cleared.
3. `DISPOSABLE_BUILD_ARTIFACT` — tracked, modified entries only, whose path matches `*.csproj`,
   `packages.config`, or `app.config` **and** whose every changed content line in both the worktree
   and cached diffs is an analyzer `HintPath` rewrite.
4. `CONTENT_ON_MAIN` — tracked modified: `diff --quiet main -- <rel>` exits 0. Untracked: the
   `hash-object` blob equals `rev-parse main:<rel>`.
5. `CONTENT_IN_HISTORY` — the blob appears in `main`'s bounded history via
   `log "main~<depth>..main" --find-object=<blob> --format=%H --max-count=1`; the returned SHA
   becomes the detail field.
6. `UNIQUE` — fallback, and the mapping for any classifier read that hard-fails.

Aggregation is per worktree and derived from the per-file set: `DIRTSUM` is `ALL_DISPOSABLE` if and
only if the entry count is at least one and the `UNIQUE` count is zero; otherwise `HAS_UNIQUE`. Zero
entries emits neither record. `--clear-disposable` reads exactly one thing:
`DIRTSUM|<path>|ALL_DISPOSABLE`.

`DISPOSABLE_BUILD_ARTIFACT` is deliberately not path-pattern-only. The requirement names the class
precisely as "analyzer-HintPath rewrites left by `nuget restore`", so the content confinement is the
definition rather than extra scope. A path-only rule would clear a genuine hand edit to a `.csproj`,
which is not hypothetical: in a legacy non-SDK C# project every added source file is an explicit
`<Compile Include=...>` edit to the project file, and a path-only rule would label that edit
disposable and destroy it.

The session-artifact list is a hard-coded array constant with no environment override, following the
`CLEANUP_WT_CONSOLIDATION_BRANCH` precedent at `scripts/bash/cleanup_worktrees_actions_lib.sh:37`.
It is the authorization list for an irreversible action; a runtime override would let any path be
declared disposable and would defeat the `UNIQUE` gate that is this feature's entire safety
argument. The family's existing environment seams are a binary-path seam, a test-scenario seam, and
a derived-path override — none is a policy override, and adding one would be a new category.

Clearing sequence in `clear_disposable_dirt`, with guarded captures at every step: classify; require
the `DIRTSUM` verdict to be exactly `ALL_DISPOSABLE`; `reset --hard`; `clean -fd`; emit
`ACTION|dirt-clear|<path>|OK`. `git clean` is never given `-x`, `-X`, or `-ff`.

Placement in `delete_candidate`: pre-reverify (existing, unchanged) → removal attempt → guarded on
the flag → classify → clear → post-clear `reverify_delete_eligible` → non-forced removal retry →
`delete_branch` (existing, unchanged). The post-clear re-verification is required even though
`reset --hard` and `clean -fd` do not move the branch tip, because `main` can advance between the
two reads in a concurrent session and `reverify_delete_eligible` re-reads `main`.

#### Error handling and logging updates:

- A hard-failing status read yields no `DIRT*` lines for that worktree, a non-zero return, and a
  refusal from `--clear-disposable`.
- A hard-failing per-entry classification read yields `UNIQUE` for that entry, hence `HAS_UNIQUE`,
  hence refusal. This is the one rule whose violation converts a transient git failure into data
  loss, so it carries a dedicated test.
- Any `UNIQUE` entry yields `ACTION|dirt-clear|<path>|REFUSED-UNIQUE` with no reset, no clean, and
  no removal retry; `delete_candidate` returns 1.
- A non-zero `reset --hard` or `clean -fd` yields `ACTION|dirt-clear|<path>|FAILED` with no removal
  retry.
- A post-clear re-verification flip yields the existing `ACTION|delete|<name>|BLOCKED-REVERIFY` and
  no removal retry and no branch delete.
- `--clear-disposable` without `--apply` prints usage to stderr and exits 2.
- The staged-tree probe returns a distinct hard-failure code for any exit other than 0 or 1, which
  maps to `UNIQUE`.

#### Rollback/feature-flag considerations (if applicable):

The destructive behavior is entirely behind `--clear-disposable`, which is opt-in, apply-mode-only,
has no configuration default, and defaults to `CLEANUP_WT_CLEAR_DISPOSABLE=0` in the new library so
the libraries stay directly testable from bats without the wrapper. Rolling back the destructive
behavior means not passing the flag. Rolling back the change as a whole is a revert of a single
commit set; no state is persisted and no migration is involved.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

New report records:

```
DIRTFILE|<worktree-path>|<verdict>|<detail>|<status-code>|<file-path>
DIRTSUM|<worktree-path>|<ALL_DISPOSABLE|HAS_UNIQUE>|<detail>
```

`<verdict>` is one of `DISPOSABLE_BUILD_ARTIFACT`, `DISPOSABLE_SESSION_ARTIFACT`, `CONTENT_ON_MAIN`,
`CONTENT_IN_HISTORY`, `STAGED_TREE_IS_COMMIT`, `UNIQUE`. `<detail>` carries the commit SHA for
`STAGED_TREE_IS_COMMIT` and `CONTENT_IN_HISTORY` and is empty otherwise. `<status-code>` is the
two-character `git status --porcelain` code. `<file-path>` is last.

New action record value: `ACTION|dirt-clear|<worktree-path>|OK|REFUSED-UNIQUE|FAILED`.

Ordering. Report: `WARN` → per worktree (`WORKTREE|`, then its `DIRTFILE|` records in
`git status --porcelain` order, then its single `DIRTSUM|`) → per branch. Apply clearing:
pre-reverify → remove attempt → classify → clear → post-reverify → remove retry → branch delete.

Report-mode exit code is unchanged: still the maximum `classify_branch` return.

#### Required configuration keys and defaults:

| Name | Kind | Default | Notes |
|---|---|---|---|
| `--clear-disposable` | CLI flag | absent | Apply-mode-only, opt-in, destructive modifier. |
| `CLEANUP_WT_CLEAR_DISPOSABLE` | internal variable | `0` | Set by the CLI pre-pass; defaults to `0` in the library so bats can drive the functions directly. Not a documented user seam. |
| `CLEANUP_WT_STAGED_TREE_DEPTH` | named constant | `200` | Bounds the staged-tree candidate walk. |
| `CLEANUP_WT_HISTORY_SCAN_DEPTH` | named constant | `1000` | Bounds the `--find-object` revision range; falls back to plain `main` when `main~<depth>` does not resolve, detected by a guarded `rev-parse --verify --quiet` probe rather than by parsing an error message. |
| `CLEANUP_WT_SESSION_ARTIFACT_PATHS` | hard-coded array | the three `artifacts/` paths | No environment override by design. |

#### Backward-compatibility expectations:

- No existing record type changes its field count, field values, or relative order.
- Apply-mode stdout without `--clear-disposable` is byte-identical to the pre-change output.
- Report-mode stdout is byte-identical for any worktree with no dirt, which is every existing
  report-mode fixture: only `dirty_worktree` and `dirty_worktree_status_error` carry a
  `status.<path>` fixture and neither is exercised by a report-mode test.
- The `DIRTY|` record stays apply-mode-only and keeps its three-field shape.
- Existing exit codes are unchanged.

#### Performance constraints (latency/throughput/memory):

- The `--find-object` history walk terminates early on a hit but walks the whole scanned range on a
  miss, and a miss is the common case for genuinely unique content. It is therefore bounded by
  revision range rather than output count, and it runs only for entries that already failed
  `CONTENT_ON_MAIN` and for which `hash-object` produced a blob.
- The staged-tree probe runs once per worktree, only when at least one status entry has a staged
  change, and only over at most `CLEANUP_WT_STAGED_TREE_DEPTH` candidate commits.
- The build-artifact content check costs two `git diff` invocations per candidate file, bounded by
  the number of dirty project-file entries in one worktree.
- Every bound is one-sided toward safety: a missed match degrades to `UNIQUE`, which blocks
  clearing. That asymmetry is documented in the function header so a future reader does not "fix"
  it by removing the bound.

**Decision 4 — report-mode exit code on a hard status read.**

The propagation is intended and is retained. `classify_worktree_dirt` returns the version-control
tool's exit code on a hard `status --porcelain` failure
(`scripts/bash/cleanup_worktrees_dirt_lib.sh:342-344`), `run_report` propagates it
(`scripts/bash/cleanup_worktrees_lib.sh:485-487`), and the wrapper propagates it in turn. A
checkout containing such a worktree therefore exits non-zero from report mode where it previously
exited 0 and produced a complete report.

The operator consequence is what makes the propagation correct. Report mode is the read-only
diagnostic pass that feeds the Dirty Worktree Triage Procedure. A worktree whose status read failed
produces no `DIRTFILE|` record and no `DIRTSUM|` record at all, so a report that also exited 0 would
be indistinguishable from a report about a clean worktree, and an operator would make a deletion
decision on silently incomplete data.

The rejected alternative was to suppress the propagation and emit a `WARN|` record instead. That
would require adding a record type to the published Report Line Contract, which every downstream
consumer would then have to handle, and it would leave the exit code unable to signal the
incompleteness at all to a wrapping script that reads only the exit status.

The precedent is in the same document. `.claude/skills/cleanup-merged-worktrees/SKILL.md:197-200`
already documents an analogous apply-mode exit-status change introduced by issue 631. This decision
mirrors that treatment for report mode: a `SKILL.md` note with its byte-identical bundle mirror, a
new acceptance criterion (AC-43), and a test pinning exit 128 for the `dirty_worktree_status_error`
scenario. No code change is made.

**Decision 5 — DISPOSABLE_SESSION_ARTIFACT is retained and inert in drm-copilot.**

The verdict is retained. It is not dead code and is not removed. It is unreachable in drm-copilot
only, because `.gitignore:6` is `/artifacts` and the status read deliberately omits `--ignored`
(`scripts/bash/cleanup_worktrees_dirt_lib.sh:29-33`, `:341`).

The provenance of the 2026-09-06 observation that named the three paths is the TaskMaster checkout,
not drm-copilot: the environment line records it, and in that checkout the three paths were reported
by `git status --porcelain` and are therefore not ignored there. The tool is repository-agnostic and
targets consumer checkouts, and delivery to them is by the extension push-down of
`claude-customizations` recorded in `## Rollout & Follow-up`, so the rung is live exactly where the
tool is used.

The reachability mechanism is the inspected checkout's own ignore state, with no change to the
status read. Adding `--ignored` is prohibited: it would pull every ignored build output into the
classified set and, for any entry matching a disposable rung, into the cleared set. That prohibition
is already stated in the library header and is reinforced by a test asserting that no status read
the library issues carries `--ignored`, with a positive control.

Retaining the rung is coverage-neutral. `dirt_is_session_artifact` at
`scripts/bash/cleanup_worktrees_dirt_lib.sh:126-129` and its emission site at `:244-245` are already
exercised by the `dirt_session_artifact` scenario and are absent from the uncovered set. Lines 74-77
are reported uncovered only because they are the interior of the multi-line
`CLEANUP_WT_SESSION_ARTIFACT_PATHS=(` array assignment, whose statement kcov attributes to its
closing line 78, which is not in the uncovered set. That is the kcov multi-line-statement
attribution property — the same one that reports lines 95, 148, 151 and 305 uncovered while the
statements they open do execute — and not a reachability property.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - The operator runs the tool through WSL Ubuntu against a Windows checkout. Toolchain
    verification is split across two hosts rather than run through a single wrapper form. `shfmt`,
    `shellcheck`, and `bats` run natively in the agent worktree, reached through
    `bash scripts/bash/shell-qc.sh` with the bats binary supplied through the documented
    `SHELL_QC_BATS_BIN` seam. `kcov` has no local route there, so coverage is measured by
    dispatching `.github/workflows/_shell-coverage.yml` against the pushed branch, and that
    dispatch measures the pushed tree rather than the working tree.
  - `/artifacts` is gitignored in drm-copilot (`.gitignore:6`). `git status --porcelain` without
    `--ignored` therefore never lists the three session-artifact paths in a drm-copilot worktree, so
    `DISPOSABLE_SESSION_ARTIFACT` cannot fire in this repository at runtime. The verdict is still
    required because the tool is repository-agnostic and targets consumer checkouts, such as the
    TaskMaster checkout that produced the 2026-09-06 observations, where those paths are tracked or
    not ignored. **This must not be "fixed" by adding `--ignored` to the status read**: that would
    enlarge the dirt set with every ignored build output and, combined with clearing, would
    authorize destruction of files that were never classified. The verdict is exercised through the
    checked-in stub fixtures, which is where its coverage comes from.
  - The recording stub is stateless: it replays the same canned response for every invocation of the
    same key. A "first removal fails, retry succeeds" sequence therefore cannot be modeled. The
    clear-and-retry sequence is pinned by argv ordering instead, and the post-clear re-verification
    is pinned by argv ordering plus a direct unit test of `reverify_delete_eligible` against the
    existing `unmerged` fixture. A stateful stub is not introduced.
  - `git hash-object` does not write to the object database (writing requires `-w`) and by default
    applies the attribute-selected input filters including end-of-line conversion. `--no-filters`
    must not be used, or a CRLF working-tree file on Windows can never match `main`'s LF blob.
  - `.claude/hooks/validate-bash.ps1:53` blocks any Bash command whose text contains
    `git reset --hard` (substring match at `:73`). Invoking the script is not blocked because the
    reset lives inside it, but an implementer cannot manually reproduce the clearing step with a raw
    Bash command. Use the stub-driven bats path.

- Constraints (budget, performance, compatibility):
  - Delivery is in `drm-copilot` only; no consumer-repository copy is patched. `.claude/**` edits
    mirror byte-identically into
    `extensions/drm-copilot/resources/claude-customizations/.claude/**`. `scripts/bash/**` is not in
    the mirror scope.
  - No production, test, or reusable shell file may exceed 500 lines. The research measured
    `scripts/bash/cleanup_worktrees_lib.sh` at 479 lines and projects 483 after this change,
    leaving 17 lines of headroom. **Re-measure that file at integration time; do not assume 479.**
  - Tests must not create temporary files. All scenarios are checked-in fixtures under
    `tests/fixtures/cleanup_worktrees/scenarios/`, driven through the `CLEANUP_WT_GIT_BIN` and
    `CLEANUP_WT_STUB_SCENARIO` seam.
  - Report mode must remain non-mutating. No production or test path may set `GIT_INDEX_FILE` or
    invoke `git write-tree`.
  - kcov measures line coverage only. The uniform line threshold of >= 85% applies; there is no
    branch-coverage gate for bash (`.claude/rules/shell.md:68-70`, `.claude/rules/quality-tiers.md`).

- External dependencies (services, libraries, releases):
  - None. No new package, no network access, no new git version requirement beyond the plumbing
    already used by the family (`diff-index --cached --quiet`, `hash-object`,
    `log --find-object`, `rev-list --max-count`, `--no-optional-locks`).
  - Verification depends on the existing toolchain: `shfmt`, `shellcheck`, `bats`, and `kcov` via
    `scripts/bash/shell-qc.sh`, plus the Python contract test
    `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` for the SKILL mirror.

## Data / API / Config Impact

- User-facing or API changes:
  - Two new report record types, `DIRTFILE|` and `DIRTSUM|`, appear in report-mode stdout for dirty
    worktrees, and in apply mode only under `--clear-disposable`.
  - One new action verb value, `ACTION|dirt-clear|<path>|OK|REFUSED-UNIQUE|FAILED`.
  - One new CLI flag, `--clear-disposable`, documented in `usage` and in SKILL.md.
  - The report-line contract block is updated in all three places it is published:
    `scripts/bash/cleanup_worktrees_lib.sh` (authoritative comment),
    `scripts/bash/cleanup-worktrees.sh` (`usage` here-doc), and
    `.claude/skills/cleanup-merged-worktrees/SKILL.md` (Report Line Contract).

- Data or migration considerations:
  - None. The tool holds no persisted state, writes no data file, and performs no migration.
  - The only data-affecting behavior is the opt-in clearing, which is bounded to files that appeared
    in `git status --porcelain` and were each classified non-`UNIQUE`. Ignored files never appear in
    that set and are never cleared.

- Logging/telemetry updates (if any):
  - No telemetry. The tool's only output channel is its stdout record stream, which is covered above.
  - Stub argv logging goes to stderr and gains one line reporting `GIT_INDEX_FILE` when it is set,
    so environment redirection is observable in tests. That is test infrastructure, not production
    logging.

- Compatibility notes (CLI flags, config schemas, versioning):
  - `--clear-disposable` is order-independent relative to the mode argument and is stripped by a
    pre-pass before mode dispatch, so every existing `case` arm is textually unchanged.
  - No config schema exists for this tool and none is introduced. The session-artifact list is
    intentionally not configurable.
  - The SKILL's `allowed-tools` wildcard already pre-approves the new flag; no `allowed-tools` edit
    is made.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: one bats scenario fixture per verdict, driven through the
  `CLEANUP_WT_GIT_BIN` stub seam paired with `CLEANUP_WT_STUB_SCENARIO`.
- [x] Integration scenario to retest: existing `dirty_worktree` and `dirty_worktree_status_error`
  scenarios must produce byte-identical output when the new flag is absent.
- [x] Manual verification notes: confirm the inspected worktree's index file is unchanged after a
  report-mode run that exercises the `STAGED_TREE_IS_COMMIT` path.

- Regression tests to add or update:
  - Report-mode byte-identity for `merged_with_worktree`, `merged_no_worktree`, `unmerged`,
    `content_neutral`, `residual_on_main`, `residual_unique_doc`, `current_exclusion`, and
    `main_divergence`, each against a checked-in expected output, with no `DIRTFILE|` or `DIRTSUM|`
    line present.
  - Apply-mode byte-identity for `dirty_worktree` and `dirty_worktree_status_error` without the
    flag, with the `DIRTY|` and `ACTION|worktree-remove|...|BLOCKED-DIRTY` lines unchanged and no
    `DIRT*` line present.
  - The existing hard-failure suite passes unmodified apart from the added `source` of the new
    library.

- Unit tests (bats) for the fixed behavior and boundaries:
  - New checked-in scenarios under `tests/fixtures/cleanup_worktrees/scenarios/`:
    `dirt_build_artifact`, `dirt_session_artifact`, `dirt_content_on_main`,
    `dirt_content_in_history`, `dirt_staged_tree_is_commit`, `dirt_unique`,
    `dirt_mixed_unique_blocks`, `dirt_clear_all_disposable`, `dirt_classifier_read_error`, and
    `dirt_clear_reverify_order`. Each carries the standard scenario baseline
    (`worktree-list.out`, `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`,
    `rev-parse.show-toplevel.out`, `merge-base.<branch>.rc`, `worktree-remove.rc`,
    `status.<sanitized-worktree-path>.out`) plus the verdict-specific stub responses.
  - Precedence proofs are expressed as the absence of the lower-rung git call in the argv log, not
    only as the presence of the expected verdict.
  - `reverify_delete_eligible` is exercised directly against the existing `unmerged` fixture to pin
    the post-clear re-verification refusal.

- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Empty status output: neither `DIRTFILE|` nor `DIRTSUM|` is emitted.
  - C-quoted path: classified `UNIQUE` with no unquoting attempt.
  - Rename or copy entry: the path after ` -> ` is classified.
  - Root-commit repository: the candidate list after dropping the first `rev-list` entry is empty,
    so no staged-tree probe runs.
  - History shorter than `CLEANUP_WT_HISTORY_SCAN_DEPTH`: `main~<depth>` does not resolve and the
    range falls back to plain `main`.
  - Worktree with only untracked dirt: no staged-tree probe at all.
  - Ignored files: never in the dirt set, never classified, never cleared.
  - `--clear-disposable` without `--apply`, and `report --clear-disposable`: exit 2 with usage on
    stderr.

- Error handling and logging verification:
  - `dirt_classifier_read_error` pins the fail-closed mapping from a non-zero classifier read to
    `UNIQUE` and thence to a refused clear.
  - The status-read hard-failure path pins the absence of `DIRT*` lines and the non-zero return.
  - `dirt_mixed_unique_blocks` pins `REFUSED-UNIQUE` together with the absence of `reset --hard` and
    `clean` from the argv log.

- Coverage impact and targets for changed lines/modules:
  - kcov line coverage >= 85%, measured over the shell-QC discovery roots with `tests/` excluded
    (`scripts/bash/shell_qc_lib.sh:333-336`), so the new production library is fully in the
    denominator and the stub and fixtures do not dilute it.
  - No branch-coverage gate applies to bash.
  - The `CONTENT_IN_HISTORY` depth-fallback branch and the C-quoted-path branch need dedicated
    scenario entries or they will be the uncovered lines.

- Toolchain commands to run (format → lint → test → coverage):

```
bash scripts/bash/shell-qc.sh format
bash scripts/bash/shell-qc.sh check
env SHELL_QC_BATS_BIN=<absolute path to the bats executable> bash scripts/bash/shell-qc.sh test
gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2
```

  The first three commands run in the agent worktree. `kcov` has no local route there, so the
  coverage stage is not a local command: the fourth line dispatches the CI workflow, which measures
  the pushed tree rather than the working tree, and its merged Cobertura report is the coverage
  measurement of record.

  The SKILL.md edits additionally require
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` to pass, which fails unless
  the bundle mirror is updated in the same change.

- Manual validation steps (if required):
  - Not required. The report-mode non-mutation property is verified by the stub-argv assertions
    rather than by inspecting a real worktree's index file, because the stub seam replaces git
    entirely and the argv and environment logs are the complete observable.

## Acceptance Criteria

- [x] `scripts/bash/cleanup_worktrees_dirt_lib.sh` exists, defines `classify_worktree_dirt`,
  `classify_dirt_entry`, the bounded staged-tree probe, and `clear_disposable_dirt`, runs nothing at
  source time, and is sourced by `scripts/bash/cleanup-worktrees.sh` and by every self-sourcing
  `tests/shell/test_cleanup_worktrees_*.bats` suite, meaning every suite that itself sources
  `scripts/bash/cleanup_worktrees_lib.sh`. Three suites fall outside that set and are excluded:
  `tests/shell/test_cleanup_worktrees_scan_helper.bats`, which sources no cleanup-worktrees
  library at all; `tests/shell/test_cleanup_worktrees_scan_seam.bats`, which sources only
  `scripts/bash/cleanup_worktrees_report_records_lib.sh`; and
  `tests/shell/test_cleanup_worktrees_cli.bats`, which references
  `scripts/bash/cleanup_worktrees_dirt_lib.sh` but not `scripts/bash/cleanup_worktrees_lib.sh`,
  so it too shows zero in the `cleanup_worktrees_lib.sh` column tabulated by the sourcing-set
  evidence artifact.
- [x] A checked-in fixture `tests/fixtures/cleanup_worktrees/scenarios/dirt_build_artifact/` and a
  passing bats test assert a `DIRTFILE|` record whose verdict field is `DISPOSABLE_BUILD_ARTIFACT`
  for a tracked, modified `*.csproj` entry whose diff contains only `HintPath` lines.
- [x] A checked-in fixture `tests/fixtures/cleanup_worktrees/scenarios/dirt_session_artifact/` and a
  passing bats test assert a `DIRTFILE|` record whose verdict field is
  `DISPOSABLE_SESSION_ARTIFACT` for `artifacts/pr_context.summary.txt`.
- [x] A checked-in fixture `tests/fixtures/cleanup_worktrees/scenarios/dirt_content_on_main/` and a
  passing bats test assert a `DIRTFILE|` record whose verdict field is `CONTENT_ON_MAIN` for an
  untracked path whose `hash-object` blob equals `rev-parse main:<path>`.
- [x] A checked-in fixture `tests/fixtures/cleanup_worktrees/scenarios/dirt_content_in_history/` and
  a passing bats test assert a `DIRTFILE|` record whose verdict field is `CONTENT_IN_HISTORY` and
  whose detail field carries the SHA returned by `log --find-object`.
- [x] A checked-in fixture `tests/fixtures/cleanup_worktrees/scenarios/dirt_staged_tree_is_commit/`
  and a passing bats test assert a `DIRTFILE|` record whose verdict field is
  `STAGED_TREE_IS_COMMIT` and whose detail field carries the matching commit SHA, and assert that
  the `DIRTSUM|` detail field carries the same SHA.
- [x] A checked-in fixture `tests/fixtures/cleanup_worktrees/scenarios/dirt_unique/` and a passing
  bats test assert a `DIRTFILE|` record whose verdict field is `UNIQUE` and a `DIRTSUM|` record
  whose aggregate field is `HAS_UNIQUE`.
- [x] The verdict field of every emitted `DIRTFILE|` record is one of exactly the six tokens
  `DISPOSABLE_BUILD_ARTIFACT`, `DISPOSABLE_SESSION_ARTIFACT`, `CONTENT_ON_MAIN`,
  `CONTENT_IN_HISTORY`, `STAGED_TREE_IS_COMMIT`, `UNIQUE`, and no other verdict token is produced
  by any of the twenty-eight `dirt_*` scenarios.
- [x] In `dirt_staged_tree_is_commit`, the staged entries are labelled `STAGED_TREE_IS_COMMIT` and
  the stub argv log contains no `hash-object`, no `diff --quiet main`, and no `log --find-object`
  invocation for those paths, proving rung 1 precedes rungs 2 through 5.
- [x] In `dirt_session_artifact`, the argv log contains no git invocation naming
  `artifacts/pr_context.summary.txt`, proving rung 2 is a pure string comparison evaluated before
  rungs 3 through 5.
- [x] In `dirt_build_artifact`, the entry is labelled `DISPOSABLE_BUILD_ARTIFACT` and the argv log
  contains no `log --find-object` invocation for that path, proving rung 3 precedes rungs 4 and 5.
- [x] In `dirt_content_on_main`, the entry is labelled `CONTENT_ON_MAIN` and the argv log contains
  no `log --find-object` invocation, proving rung 4 precedes rung 5.
- [x] A checked-in fixture `tests/fixtures/cleanup_worktrees/scenarios/dirt_classifier_read_error/`
  and a passing bats test assert that a classifier git read exiting non-zero produces `UNIQUE` for
  that entry, `HAS_UNIQUE` for the worktree, and a refused clear.
- [x] A tracked, modified `*.csproj` entry whose diff contains at least one changed line that is not
  a `HintPath` rewrite is classified `UNIQUE` rather than `DISPOSABLE_BUILD_ARTIFACT`, pinned by a
  dedicated bats test.
- [x] For each non-detached candidate registration with dirt that the report classifies, report mode
  emits exactly one `DIRTFILE|` record per `git status --porcelain` entry, in porcelain order,
  immediately after that worktree's `WORKTREE|` record, followed by exactly one `DIRTSUM|` record;
  `dirt_mixed_unique_blocks` pins the two-entry case. Detached, `main`, and `bare` registrations are
  never classified and therefore receive no dirt records: the `is_detached_candidate` guard in
  `run_report` skips a detached registration before the classification call, and the adjacent
  `main`/`bare` guard excludes those two registration kinds as well.
- [x] The `DIRTSUM|` aggregate field is `ALL_DISPOSABLE` if and only if the entry count is at least
  one and the `UNIQUE` count is zero, and is `HAS_UNIQUE` otherwise; a worktree with zero status
  entries emits neither a `DIRTFILE|` nor a `DIRTSUM|` record.
- [x] The `DIRTFILE|` detail field carries a commit SHA for `STAGED_TREE_IS_COMMIT` and
  `CONTENT_IN_HISTORY` and is empty for the other four verdicts, and the file path is the last
  field of the record, pinned by a bats test using a fixture path containing a pipe character.
- [x] No existing record type changes: for `merged_with_worktree`, `merged_no_worktree`, `unmerged`,
  `content_neutral`, `residual_on_main`, `residual_unique_doc`, `current_exclusion`, and
  `main_divergence`, report-mode stdout is byte-identical to a checked-in expected-output file and
  contains no `DIRTFILE|` or `DIRTSUM|` line.
- [x] Apply-mode stdout without `--clear-disposable` is byte-identical to the pre-change output for
  `dirty_worktree` and `dirty_worktree_status_error`, specifically retaining the three-field
  `DIRTY|` record and the `ACTION|worktree-remove|<path>|BLOCKED-DIRTY` record, and containing no
  `DIRTFILE|` or `DIRTSUM|` line.
- [x] `scripts/bash/cleanup_worktrees_actions_lib.sh` `remove_worktree_safe` is unchanged, and
  `tests/shell/test_cleanup_worktrees_hard_failures.bats` and
  `tests/shell/test_cleanup_worktrees_deletion.bats` pass with no assertion edits, only the added
  `source` of the new library.
- [x] `bash scripts/bash/cleanup-worktrees.sh --clear-disposable` and
  `bash scripts/bash/cleanup-worktrees.sh report --clear-disposable` each exit 2 and print usage to
  stderr, pinned by tests in `tests/shell/test_cleanup_worktrees_cli.bats`.
- [x] `--apply --clear-disposable` and `--clear-disposable --apply` both dispatch to apply mode,
  pinned by an argument-order-independence test in `tests/shell/test_cleanup_worktrees_cli.bats`.
- [x] A checked-in fixture
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_mixed_unique_blocks/` and a passing bats test
  assert that `--clear-disposable` on a worktree carrying at least one `UNIQUE` verdict emits
  `ACTION|dirt-clear|<path>|REFUSED-UNIQUE` and that the argv log contains no `reset --hard`, no
  `clean`, and no second `worktree remove`.
- [x] A checked-in fixture
  `tests/fixtures/cleanup_worktrees/scenarios/dirt_clear_all_disposable/` and a passing bats test
  assert the argv order `reset --hard` → `clean -fd` → `worktree remove`, that
  `ACTION|dirt-clear|<path>|OK` is emitted, and that the argv log contains none of `--force`, `-x`,
  `-X`, or `-ff`.
- [x] A checked-in fixture `tests/fixtures/cleanup_worktrees/scenarios/dirt_clear_reverify_order/`
  and a passing bats test assert that a second `cherry main feature-dirt` invocation appears in the
  argv log after `reset --hard` and before the removal retry, and a direct bats test of
  `reverify_delete_eligible` against the existing `unmerged` fixture asserts it refuses a
  non-eligible branch.
- [x] `git worktree remove` is invoked from exactly the two existing call sites in
  `scripts/bash/cleanup_worktrees_actions_lib.sh` with no force flag; the clear-and-retry path
  routes through `remove_worktree_safe` and introduces no third call site.
- [x] Report mode is non-mutating: over `dirt_staged_tree_is_commit`, a bats test asserts the stub
  argv and environment log contains no `write-tree`, no `stub-git-env: GIT_INDEX_FILE=`, no
  `/index`, no `reset`, no `clean`, no `worktree remove`, no `branch -D`, and no `hash-object -w`.
- [x] `tests/fixtures/cleanup_worktrees/stub-bin/git` logs `GIT_INDEX_FILE` to stderr when that
  variable is set, so the non-mutation assertion above can fail when the property is violated.
- [x] Over `dirt_staged_tree_is_commit`, the argv log contains `diff-index --cached --quiet`, and
  every `status --porcelain` invocation issued by the new library carries `--no-optional-locks`.
- [x] The staged-tree probe never probes the first entry returned by `rev-list`, pinned in
  `dirt_staged_tree_is_commit` by asserting no `diff-index` invocation names the HEAD SHA supplied
  in that fixture.
- [x] `bash scripts/bash/shell-qc.sh format`, `bash scripts/bash/shell-qc.sh check`, and
  `bash scripts/bash/shell-qc.sh test` each complete with no error in a single consecutive pass,
  run in the agent worktree with the bats binary supplied through the documented
  `SHELL_QC_BATS_BIN` seam. The format stage is judged by a before-and-after tree digest over the
  three discovery roots rather than by its exit code alone, because `shfmt` in write mode prints
  nothing and exits 0 whether or not it rewrote a file.
- [x] A dispatch of `.github/workflows/_shell-coverage.yml` against the pushed branch reports kcov
  line coverage of at least 85% repository-wide, and `scripts/bash/cleanup_worktrees_dirt_lib.sh`
  itself reports line coverage of at least 85% in the merged Cobertura report of that run. `kcov`
  has no local route in the agent worktree, so the CI dispatch is the measurement path and no
  local coverage invocation substitutes for it. No branch-coverage gate applies to bash, and none
  is asserted.
- [x] Every shell file changed or added by this work is at or under 500 lines, measured at
  integration time rather than assumed from the research projection.
- [x] `.claude/skills/cleanup-merged-worktrees/SKILL.md` Report Line Contract documents `DIRTFILE|`
  and `DIRTSUM|` with their field lists and states that `DIRTY|` remains apply-mode-only with an
  unchanged three-field shape.
- [x] `.claude/skills/cleanup-merged-worktrees/SKILL.md` Prohibited Shortcuts states that
  `--clear-disposable` is not an exception to the never-force-remove rule and is not force-removal,
  because it clears the working tree first and then retries the same unforced
  `git worktree remove`, and adds a bullet prohibiting any widening of the disposable-dirt
  definition.
- [x] `.claude/skills/cleanup-merged-worktrees/SKILL.md` Dirty Worktree Triage Procedure states that
  report mode now precedes the procedure with `DIRTFILE|` and `DIRTSUM|` records, scopes step 6 to
  the `HintPath`-confined build-artifact case, and amends step 9 to distinguish the automated
  clearing of classified-disposable dirt from the never-automated editorial discard of `UNIQUE`
  content.
- [x] `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  is byte-identical to the canonical file, and
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
- [x] The report-line contract comment block in `scripts/bash/cleanup_worktrees_lib.sh` and the
  `usage` here-doc in `scripts/bash/cleanup-worktrees.sh` both document `DIRTFILE|`, `DIRTSUM|`, and
  `--clear-disposable`, and `bash scripts/bash/cleanup-worktrees.sh --help` output contains all
  three strings, pinned by a test in `tests/shell/test_cleanup_worktrees_cli.bats`.
- [x] AC-39 — Rung 1 resolves `STAGED_TREE_IS_COMMIT` only when the porcelain **Y** column is a
  space. An `MM` entry falls through to the lower rungs, which compare working-tree content, and is
  never labelled `STAGED_TREE_IS_COMMIT` on the strength of an index-only probe. This is pinned in
  both directions by a single checked-in fixture carrying one `MM` entry and one `M ` entry, so the
  same once-per-worktree probe result serves both directions.
- [x] AC-40 — The ` -> ` payload split is applied only when the porcelain **X** column is `R` or
  `C`. A non-rename entry whose path contains the literal ` -> ` is classified and reported under
  its full path rather than under a truncated suffix, and a genuine `R` entry is still split so its
  destination path is the one classified. Both directions are pinned.
- [x] AC-41 — The diff header skip is anchored to the header forms the version-control tool emits,
  so an added line whose content begins `+++ ` is counted as a changed content line and tested for
  `HintPath`, while a `/dev/null` header is still skipped. Both directions are pinned.
- [x] AC-42 — `STAGED_TREE_IS_COMMIT` is pinned in five material directions, the two hard-failure
  sites counted separately: probe match; probe no-match; probe hard read failure at the `rev-list`
  site; probe hard read failure at the `diff-index` site; and a staged entry with a non-space Y
  column.
- [x] AC-43 — Report mode returns the version-control tool's non-zero exit code when a candidate
  worktree's `status --porcelain` read fails, emits no `DIRTFILE|` and no `DIRTSUM|` record for that
  worktree, and the behaviour is documented in
  `.claude/skills/cleanup-merged-worktrees/SKILL.md` and pinned by a test over the checked-in
  `dirty_worktree_status_error` scenario.
- [x] AC-44 — `DISPOSABLE_SESSION_ARTIFACT` is retained as repository-agnostic behaviour and is
  inert in drm-copilot because `.gitignore:6` ignores `/artifacts`. The status read never carries
  `--ignored`, pinned by a test asserting its absence from the stub argv log with a positive
  control.
- [x] AC-45 — `scripts/bash/cleanup_worktrees_dirt_lib.sh` reports kcov line coverage of at least
  85% in the merged Cobertura report of the CI coverage run against the pushed branch.
- [x] AC-46 — Rung 4's tracked half resolves `CONTENT_ON_MAIN` only when the path is present in
  `main`; a `diff --quiet` exit 0 over a pathspec matching nothing in either tree advances the
  ladder rather than resolving a verdict, so an `AD` entry whose content exists only as a staged
  blob is `UNIQUE` and its worktree is `HAS_UNIQUE`; both directions are pinned by a single
  checked-in fixture carrying one `AD` entry and one tracked entry whose content is present in
  `main`.
- [x] AC-47 — Every line in `scripts/bash/cleanup_worktrees_dirt_lib.sh` that carries an arithmetic
  comparison of a variable against a numeric literal carries a `# guard:` marker; the marked lines
  plus the eight named non-arithmetic verdict guards — the diff-header skip, rung 1's Y-column
  gate, the empty-blob fail-closed test, rung 4's untracked main-blob equality test, rung 5's
  history-hit test, the ` -> ` payload split gate, the `UNIQUE` tally, and the clear's
  `ALL_DISPOSABLE` precondition, which are the sites that produced findings R1, R2, and R5 — are
  together registered in `tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv` under
  (`id`, `mutation`) row identity. Every registered row's neutralization is a semantic one, being
  either one of the eight non-arithmetic mutations the remediation plan fixes by literal or the
  arithmetic guard's own comparison rewritten to a constant, so a mutation that edits only a
  comment or only whitespace is rejected by the suite rather than recorded as an exempt guard.
  `tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats` neutralizes each registered row in
  an in-memory copy of the library and requires, for every row, that the named scenario directory
  exists under a name beginning `dirt_`, that the substitution changed exactly one line and that
  the changed line still differs once the marker comment is stripped and whitespace runs are
  collapsed, that the mutated source parses, and that the unmutated `classify_worktree_dirt` call
  emitted at least one `DIRTFILE|` record. The three row kinds partition the outcome space of two
  comparisons for an admissible (`mutation`, `scenario`) pair — one that survives the
  sibling-constant requirement below — and each asserts both the difference and the identity it
  names, so a `SEPARATED` row's record stream and exit status must differ, an `ARGV` row's record
  stream must be identical while its argv log differs, and an `EXEMPT` row's record stream and
  argv log must both be identical — under the sibling constant as well, for a row whose mutation
  is an arithmetic constant — which makes `EXEMPT` an observed outcome rather than a verdict
  written into the registry. `EXEMPT is scenario-scoped`, meaning that an `EXEMPT` row establishes
  only that its guard is unobservable under its own named scenario in both admissible directions
  and does **not** establish that no checked-in scenario separates that guard, while the eighteen
  pinned registry rows carry the stronger property that a named checked-in scenario does separate
  them. Eighteen registry rows over seventeen distinct ids are pinned by kind, the fourteen listed
  as `SEPARATED` in the remediation plan's remediated-guard and thirteen-pinned-guards tables
  being registered `SEPARATED`, and four rows — R1's Y-column gate, R2's payload-split gate, R5's
  diff-header skip, and the empty-blob fail-closed test — being registered `SEPARATED` or `ARGV`.
  The three pins that fall on the two library lines carrying an arithmetic guard and a named
  non-arithmetic guard together are keyed to the pair (`id`, `mutation`) rather than to `id`,
  because a single marker on such a line backs two registry rows and an id-keyed pin on it is
  discharged by either one. An arithmetic guard-shaped line with no marker, a marker with no
  registry row, or a registry row naming an unmarked id fails the suite.

## Risks & Mitigations

- Technical or operational risks:
  - **Data loss through an over-broad disposable definition.** The clearing path runs
    `git reset --hard` and `git clean -fd`, which are irreversible for uncommitted content. The
    dominant risk is a file being labelled disposable when it is not.
  - **Fan-in on `scripts/bash/cleanup_worktrees_lib.sh`.** Epic child A (#630) also targets
    `run_report` in that file. The research measured the file at 479 lines and projects 483 after
    this change, which leaves 17 lines of headroom against the 500-line cap. If child A lands first
    and consumes that headroom, this change cannot land as designed.
  - **Fan-in on `scripts/bash/cleanup-worktrees.sh`.** Child A also changes the CLI and report
    surface, so `usage` and `main` are shared edit targets.
  - **Performance on a large repository.** The `--find-object` miss case walks the scanned range,
    and the miss is the common case for genuinely unique content.
  - **`DISPOSABLE_SESSION_ARTIFACT` cannot fire in drm-copilot** because `/artifacts` is gitignored
    (`.gitignore:6`), so a future maintainer may conclude the predicate is dead code and either
    delete it or add `--ignored` to the status read.
  - **The stateless stub cannot model a changing exit code**, so the clear-then-retry success path
    is not directly observable.
  - **Reviewer reads the implementation as deviating from the requirement**, because `DIRTY|` is not
    labelled and `git write-tree` is not used.

- Mitigations and rollbacks:
  - The disposable definition is deliberately narrow and every rung fails closed to `UNIQUE`. The
    session-artifact list is a hard-coded array with no override, matched on the exact
    repo-relative path and never on a prefix. The build-artifact rule requires both the path pattern
    and the `HintPath` content confinement. `git clean` is never given `-x`, `-X`, or `-ff`, so
    ignored files — which never appear in `git status --porcelain` and are therefore never
    classified — are never cleared. The flag is opt-in with no configuration default and refuses the
    whole worktree on a single `UNIQUE` verdict. A dedicated acceptance criterion pins the
    fail-closed mapping.
  - Fan-in on `cleanup_worktrees_lib.sh` is mitigated by keeping this change's footprint there to
    four lines across two anchored hunks. **Contingency:** if the headroom is gone at integration
    time, first extract `run_report` into a new `scripts/bash/cleanup_worktrees_report_lib.sh` as a
    separate, behavior-preserving move commit, then apply this change's hunks to the new file.
    Re-measure the file at integration time; do not assume 479 lines.
  - Fan-in on `cleanup-worktrees.sh` is mitigated by appending the new source block at the end of
    the contiguous source block (a both-sides-keep append if child A does the same) and by inserting
    the flag pre-pass before `local command=${1:-}` so every existing `case` arm stays textually
    untouched.
  - Performance is bounded by `CLEANUP_WT_HISTORY_SCAN_DEPTH` and `CLEANUP_WT_STAGED_TREE_DEPTH`,
    and the expensive rung runs only for entries that already failed the cheaper rungs. Both bounds
    are one-sided toward `UNIQUE`, and that asymmetry is documented in the function header so it is
    not "fixed" by removing the bound.
  - The gitignored-`/artifacts` fact is recorded in the Assumptions section and in the function
    header, together with the explicit prohibition on adding `--ignored`. The verdict's coverage
    comes from the checked-in stub fixtures rather than from a live drm-copilot worktree.
  - The stub limitation is accepted rather than worked around: the clear-and-retry sequence is
    pinned by argv ordering, and the post-clear re-verification is pinned by argv ordering plus a
    direct unit test of `reverify_delete_eligible`. Introducing a stateful stub would change the
    fixture contract for all six suites to satisfy one assertion.
  - The two departures from the requirement's literal wording are recorded in Proposed Fix with
    their reasons and are constrained by explicit guardrail acceptance criteria, so a reviewer can
    audit the decision rather than infer it.

### Re-verification ordering is asserted through `cherry`, not `merge-base --is-ancestor`

- **Why the probe changed.** The post-clear re-verification is asserted through the `cherry`
  invocation rather than `merge-base --is-ancestor`. The ancestry call at
  `scripts/bash/cleanup_worktrees_lib.sh:64` is written
  `cleanup_wt_git merge-base --is-ancestor "$tip" main >/dev/null 2>&1`, and the `2>&1` discards the
  stub's `stub-git:` log line, which the stub writes to stderr
  (`tests/fixtures/cleanup_worktrees/stub-bin/git:45`). The probe is therefore unobservable in the
  argv log through no fault of the classifier. The same redirection appears at
  `scripts/bash/cleanup_worktrees_actions_lib.sh:206`. `cleanup_wt_git` is a plain wrapper that
  executes the resolved binary, so the caller's redirection applies to the stub process; there is no
  test-side workaround, because the redirection sits in production code this change does not modify
  and a stub file sink is barred by the no-temporary-files rule in
  `.claude/rules/general-unit-test.md`. By contrast, `classify_cherry_equivalent` issues
  `out=$(cleanup_wt_git cherry main "$branch")` at `scripts/bash/cleanup_worktrees_lib.sh:131`,
  capturing stdout only, so the `stub-git: cherry main <branch>` line reaches the argv log.
- **What the fixture does.** `dirt_clear_reverify_order` drives the branch down the cherry rung. It
  extends `dirt_clear_all_disposable` with `merge-base.feature-dirt.rc` = `1`,
  `diff-quiet.feature-dirt.rc` = `1`, and a `cherry.feature-dirt.out` whose lines are all
  `- <sha>`. An all-`- <sha>` cherry output leaves the residual array empty, so
  `classify_cherry_equivalent` prints `MERGED_EQUIVALENT`
  (`scripts/bash/cleanup_worktrees_lib.sh:159-161`), and `MERGED_EQUIVALENT` is on the
  delete-eligible allowlist in `reverify_delete_eligible`
  (`scripts/bash/cleanup_worktrees_actions_lib.sh:242`). Both re-verifications therefore still
  succeed, and each logs one `cherry main feature-dirt` line.
- **This is an observability substitution, not a weakening.** The assertion still pins that the
  re-verification happens after the clear and before the removal retry. What changed is which git
  invocation carries the evidence.
- **Residual limitation.** On the `MERGED_CLEAN` path the re-verification produces no observable
  output at all: `classify_branch` stops at the ancestry rung, whose git call is stderr-suppressed,
  and its stdout is consumed by the command substitution at
  `scripts/bash/cleanup_worktrees_actions_lib.sh:231`. The cherry-rung fixture is what makes the
  ordering observable.

## Rollout & Follow-up

- Release/rollout steps:
  1. Land the change in `drm-copilot` on `bug/cleanup-worktrees-dirt-classifier-632`, including the
     SKILL.md edit and its byte-identical bundle mirror in the same commit set so the push-down
     contract test stays green.
  2. Run the four `shell-qc.sh` commands recorded in Test Strategy plus
     `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, repeating the loop from
     the start if any stage fails or auto-formats a file.
  3. Consumer checkouts pick the change up through the normal extension push-down of
     `claude-customizations`; no consumer repository is patched by this change.
  4. Exercise report mode first on a real checkout and read the `DIRTFILE|` and `DIRTSUM|` records
     before using `--clear-disposable`. The flag is not part of the default cleanup run.

- Post-fix monitoring or clean-up tasks:
  - On the first real run against a consumer checkout, compare the `DIRTSUM|` aggregates against the
    manual triage that the 2026-09-06 run required, and record any worktree the classifier labels
    `HAS_UNIQUE` that manual triage would have called disposable. Under-classification is the safe
    direction and does not block; over-classification is a defect and must be filed immediately.
  - Re-measure `scripts/bash/cleanup_worktrees_lib.sh` against the 500-line cap after the sibling
    epic children land, and execute the `cleanup_worktrees_report_lib.sh` extraction contingency if
    the file is at or near the cap.
  - Confirm the coverage of the `CONTENT_IN_HISTORY` depth-fallback branch and the C-quoted-path
    branch in the kcov report rather than assuming the scenario set reaches them.

- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/632
  - Epic: `cleanup-merged-worktrees-hardening`; sibling children #630 (A) and the B, D, and F
    children, all out of scope here.
  - Design research (authoritative source for this spec):
    `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/research/2026-09-06-dirt-classifier-design-research.md`
  - Skill: `.claude/skills/cleanup-merged-worktrees/SKILL.md`
  - Rules: `.claude/rules/shell.md`, `.claude/rules/general-code-change.md`,
    `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`
