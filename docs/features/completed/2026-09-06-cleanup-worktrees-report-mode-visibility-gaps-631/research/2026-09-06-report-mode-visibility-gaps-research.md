# Research: Report-Mode Visibility Gaps (Issue #631, Epic Child B)

Scope: gaps 7, 9c, 9d only, from
`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md`
(lines 109-137), under epic `cleanup-merged-worktrees-hardening`
(`docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`, child B, issue placeholder 901,
complexity band C2: "Three additive report-mode record types on an existing emission path. The
`CHILD_OF` short-circuit changes classification cost, not classification outcome.").

Three new additive report-mode record types:

- `ORPHAN_DIR|<path>|<size>` (gap 7)
- `STALE_REF|<refname>` (gap 7)
- `CHILD_OF|<branch>` (gap 9c, cost-only short-circuit)
- `WARN|registration-lost|<path>` (gap 9d, detection line only; root cause is out of scope)

Deletion of orphan directories and stale refs stays manual/confirmed. No implementation performed;
this is research only.

## 1. Current-State Analysis

### 1.1 File inventory (line counts verified 2026-09-06)

| File | Lines | Role |
| --- | --- | --- |
| `scripts/bash/cleanup_worktrees_lib.sh` | 479 | classification ladder + `run_report` |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 237 | git-binary seam, enumeration, `WARN\|main-divergence` |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 383 | apply-mode driver, consolidation, deletion |
| `scripts/bash/cleanup-worktrees.sh` | 93 | CLI wrapper, sourcing order, `usage()` text |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | 264 | editorial workflow, Report Line Contract (line 57) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | mirror | byte-identical mirror target |

The prompt's line-count citations for `cleanup_worktrees_lib.sh` (479/500) and
`cleanup_worktrees_enumerate_lib.sh` (236, actual 237 — off by one, negligible) are verified.
`cleanup_worktrees_actions_lib.sh` is 383 lines (prompt said 382, off by one), `cleanup-worktrees.sh`
is 93 lines (prompt said 92, off by one). SKILL.md is exactly 264 lines with the Report Line
Contract heading at line 57 — verified exact match. The epic.md file corroborates the 479/500 figure
verbatim ("`scripts/bash/cleanup_worktrees_lib.sh` is at 479 lines").

### 1.2 `cleanup_worktrees_lib.sh` — exact emission points (verified by direct read)

- `classify_ancestry` (lines 52-73): rung 1, `merge-base --is-ancestor <tip> main`, returns a
  verdict token only (no `BRANCH|` emission itself).
- `classify_content_neutral` (75-98): rung 2, `diff --quiet main...<branch>`.
- `classify_cherry_equivalent` (100-169): rung 3, `git cherry main <branch>` plus per-`+`-commit
  `diff-tree` empty-check.
- `_blob_equal` (171-183): blob-OID helper for rung 4.
- `classify_residual_commit` (185-252): rung 4, rename-aware blob comparison per residual commit.
- `select_cherry_pick_candidates` (254-306): emits `COMMIT|<branch>|<sha>|UNIQUE|<paths>|<author>|<date>`
  at line 302 (`printf 'COMMIT|%s|%s|UNIQUE|%s|%s|%s\n' ...`).
- `classify_branch` (308-443): orchestrates rungs 1-6 and is the **sole** emitter of `BRANCH|` lines:
  line 336 (`ANCESTRY_ERROR` on protected-set failure), 350 (`ANCESTRY_ERROR` on worktree-list
  failure), 362 (`PROTECTED_CURRENT`), 369 (`MERGED_CLEAN`), 373 (`ANCESTRY_ERROR`), 380
  (`MERGED_CONTENT_NEUTRAL`), 384 (`ANCESTRY_ERROR`), 393 (`ANCESTRY_ERROR` on cherry/diff-tree hard
  failure), 397 (`MERGED_EQUIVALENT`), 409 (`ANCESTRY_ERROR` on residual hard failure), 420
  (`MERGED_EQUIVALENT` when all residuals are content-on-main), 432
  (`printf 'BRANCH|%s|%s\n' "$name" "$state"` where `state` is `NOT_MERGED` or
  `HAS_UNIQUE_RESIDUALS`).
- `run_report` (445-479): driver. Emission order is `WARN` (via `check_main_freshness`, line 464),
  then `WORKTREE|` lines (466-469), then per-branch `classify_branch` output in `enumerate_branches`'
  `LC_ALL=C` order (470-477). Aborts before any output on a `parse_worktree_list` or
  `enumerate_branches` hard failure (456-463).

### 1.3 Baseline: how a branch that is an ancestor of another `NOT_MERGED` branch is classified TODAY

There is **no existing short-circuit**. Verified by reading the full ladder: `classify_ancestry`
(line 64) only checks ancestry against the literal ref `main`; nothing in `classify_branch` checks a
branch's tip against any other branch's tip. Consequently, for a branch `X` whose tip is an ancestor
of another branch `Y`'s tip (both unmerged into `main`), `classify_branch("X")` runs the **full**
ladder exactly as it would for any unrelated branch:

1. Rung 1 (`classify_ancestry`) resolves `NOT_ANCESTOR` (X is not an ancestor of `main`).
2. Rung 2 (`classify_content_neutral`) resolves `NOT_NEUTRAL` (X's net diff against `main` is
   non-empty, assuming X carries real content not on `main`).
3. Rung 3 (`classify_cherry_equivalent`) runs `git cherry main X`, which is O(commits-in-X) —
   the expensive step named in gap 9c ("per-commit patch-id classification... up to 64 commits
   each").
4. Rungs 4-5 (`classify_residual_commit` per `+` commit) run rename-aware blob comparisons,
   O(commits-in-X × touched-paths).
5. Absent any `-` (minus) cherry line or `CONTENT_ON_MAIN` residual, `classify_branch` line 428 sets
   `state="NOT_MERGED"` and emits `BRANCH|X|NOT_MERGED` at line 432.

**This is the baseline the `CHILD_OF` short-circuit must reproduce exactly for the `BRANCH|` line
outcome**: `BRANCH|X|NOT_MERGED`. `CHILD_OF` is defined as an *additive* record (per the epic's
explicit design constraint: "gap 7's orphan and stale-ref output is report-only" and "the `CHILD_OF`
short-circuit changes classification cost, not classification outcome"), so the correct
outcome-preserving design keeps emitting `BRANCH|X|NOT_MERGED` and adds a new
`CHILD_OF|X|<Y>` line alongside it, while skipping rungs 3-5's expensive per-commit work whenever the
short-circuit's safety precondition (Section 2.3) holds.

### 1.4 `cleanup_worktrees_enumerate_lib.sh` — enumeration/protection surface (verified)

- `cleanup_wt_git` (34-57): resolves `CLEANUP_WT_GIT_BIN` override, falls back to `command -v git`.
  This is the established override-seam pattern (mirrors `SHELL_QC_<TOOL>_BIN` in
  `scripts/bash/shell_qc_lib.sh:132`), the template any new binary/tool seam should follow.
- `enumerate_branches` (59-83): `git for-each-ref --format='%(refname:short) %(objectname)' refs/heads/`,
  `LC_ALL=C` sorted.
- `parse_worktree_list` (85-148): parses `git worktree list --porcelain` stanza-wise into
  `path|head|branch-or-DETACHED|flags` records. Flags vocabulary: `main, detached, bare, locked,
  prunable` (lines 106-111). This function has **no concept of a directory that is not registered as
  a worktree at all** — it only ever sees what git itself reports; it cannot by itself detect an
  orphan directory or a lost registration, both of which are filesystem-side facts absent from git's
  own porcelain output.
- `normalize_wt_path` (150-164): backslash-to-forward-slash, lowercase, trailing-slash strip.
- `compute_protected` (166-219): dual exclusion (current branch, current worktree path); guarded
  `parse_worktree_list` capture.
- `check_main_freshness` (221-236): the existing precedent for the new `WARN|registration-lost|<path>`
  line shape. Exact current line (line 233): `printf 'WARN|main-divergence|%s|%s\n' "$local_sha"
  "$origin_sha"`. It is advisory-only, always returns 0, and skips silently on either `rev-parse`
  failure (230-231) rather than treating a missing ref as an error. `run_report` calls it once,
  unconditionally, before any other record (line 464) — the same integration slot a new
  `check_registration_loss`-style function should use for `WARN|registration-lost|<path>`.

### 1.5 `cleanup_worktrees_actions_lib.sh` — how apply mode reads classification (verified)

`run_apply` (316-382) does **not** parse `run_report`'s serialized text output; it calls
`classify_branch "$name"` directly per branch (line 365: `cb_out=$(classify_branch "$name") ||
crc=$?`), then extracts the state with:

```
state=$(printf '%s\n' "$cb_out" | awk -F'|' '/^BRANCH\|/{print $3; exit}')
```

(line 373). This awk pattern matches only lines beginning `BRANCH|` and takes the **first** such
line's third field, then exits. Two consequences, both verified directly from the code:

1. Any additional non-`BRANCH|`-prefixed line that `classify_branch` might emit (such as a new
   `CHILD_OF|<name>|<Y>` annotation) is invisible to this awk extraction and does not affect the
   allowlist decision at line 375 (`MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT`).
2. If the `CHILD_OF` short-circuit is implemented **inside** `classify_branch` itself (as opposed to
   only inside `run_report`'s driver loop), `run_apply` automatically inherits both the speed-up and
   the outcome-preservation guarantee for free, because it calls the same function. `classify_branch`
   must still print `BRANCH|<name>|NOT_MERGED` as the first (or only) `BRANCH|`-prefixed line for the
   short-circuited case; anywhere else in `cb_out` is safe for an additive `CHILD_OF` line.

This is the concrete basis for the "treated identically" requirement: run_apply's behavior is
governed entirely by the first `BRANCH|` line's third field, so as long as the short-circuit still
emits `BRANCH|<name>|NOT_MERGED` as that line, apply mode's allowlist gate is provably unaffected,
regardless of whether `run_apply`'s own stdout stream also surfaces the `CHILD_OF` line (it will,
since `run_apply` does `printf '%s\n' "$cb_out"` at line 366, echoing everything `classify_branch`
produced). Whether that CHILD_OF leakage into apply-mode's output stream is desirable or should be
suppressed is an open question — see Section 6.

`run_apply`'s per-branch loop (357-380) is structurally identical to `run_report`'s (470-477): both
iterate `ebout` (from `enumerate_branches`), both call `classify_branch` once per name, and both
currently classify each branch independently with no shared state across branches in the loop. A
cross-branch short-circuit (needing to know "was some other branch Y already resolved to
NOT_MERGED?") requires either (a) a pre-pass shared between the two callers, or (b) memoization
threaded through both loops. See Section 3.

### 1.6 `cleanup-worktrees.sh` — sourcing order and file-size constraint (verified)

Sourcing order (lines 16-24): `cleanup_worktrees_enumerate_lib.sh` first, then
`cleanup_worktrees_lib.sh`, then `cleanup_worktrees_actions_lib.sh`. All three functions/behaviors
depend on functions from the enumerate lib being defined first. `cleanup_worktrees_lib.sh` is at
479/500 lines — only 21 lines of headroom, comment overhead included. Adding three new record types'
logic there is not viable; a **new sibling file** is required, matching the epic's explicit
constraint ("new behavior is added in new or clearly separated files rather than by growing these").
The wrapper would need one new `source` line for the new file, added after the enumerate lib (since
the new functions will need `cleanup_wt_git`) and, for `CHILD_OF`, likely after
`cleanup_worktrees_lib.sh` too if the new file calls `classify_branch`/`classify_ancestry` internally,
or before it if `cleanup_worktrees_lib.sh` is modified to call into the new file's functions (the
latter requires the new file to be sourced first, mirroring the existing
enumerate-before-classification convention documented in `cleanup_worktrees_lib.sh`'s header comment,
lines 5-11).

`usage()` in `cleanup-worktrees.sh` (lines 42-45) also documents the report-line contract inline (a
second copy of the same list that appears in SKILL.md's Report Line Contract). This must be extended
with the three new record shapes for consistency, though no bats test currently pins its exact text
(`test_cleanup_worktrees_cli.bats` only substring-checks `"Usage: cleanup-worktrees.sh"`, not the
report-line list), so this update carries no test-breakage risk, only a documentation-consistency
obligation.

### 1.7 SKILL.md — Report Line Contract (verified, line 57-71)

Current record types listed: `BRANCH|`, `COMMIT|`, `WORKTREE|`, `WARN|main-divergence|`, `DIRTY|`,
`ACTION|`. The new types (`ORPHAN_DIR|`, `STALE_REF|`, `CHILD_OF|`, `WARN|registration-lost|`) are
absent and must be added following the same one-bullet-per-type format. Separately, SKILL.md's
existing "Dirty Worktree Triage Procedure" step 7 (lines 190-197) already tells a human/agent how to
*manually* recognize an orphaned non-worktree directory found *incidentally* during per-worktree
triage ("flag them for plain filesystem removal... requires explicit user confirmation"). The new
`ORPHAN_DIR|` report line is a **different, earlier** detection point: a proactive, whole-tree scan
performed automatically by `run_report` up front, rather than something discovered only while
triaging a specific dirty worktree. Step 7's guidance ("filesystem removal ... is a destructive action
outside this skill's pre-approved tool surface; it requires explicit user confirmation each time")
remains the correct downstream disposition and should be cross-referenced from the new Report Line
Contract entry, not duplicated.

`test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:106-131`) asserts byte-identical
content between every non-agent-memory `.claude/**` file at repo root and its counterpart at
`extensions/drm-copilot/resources/claude-customizations/.claude/**` (verified: `assert
read_text(BUNDLED_ROOT, relative_path) == read_text(REPO_ROOT, relative_path)` at line 128-131). The
mirror file was confirmed to exist and currently starts with byte-identical frontmatter (spot-checked
first 10 lines). Both `SKILL.md` copies must be edited together, byte-for-byte, or this test fails.

### 1.8 bats/fixture/stub-seam mechanics (verified)

- The recording stub `tests/fixtures/cleanup_worktrees/stub-bin/git` (208 lines) derives a `KEY` from
  the (global-option-stripped) argv per a fixed per-subcommand scheme (documented in its own header,
  lines 10-41), then replays `<scenario>/<KEY>.out` to stdout and exits with `<scenario>/<KEY>.rc`
  (default 0) via the `respond()` helper (lines 55-69). It logs every invocation as `stub-git: <argv>`
  to **stderr** (line 45) so bats can assert on argv without polluting stdout capture.
- **Critical gap for `STALE_REF`**: the `for-each-ref` case (lines 97-99) is `respond "for-each-ref"`
  — the KEY does **not** incorporate the refspec pattern argument at all. `enumerate_branches`
  (`cleanup_worktrees_enumerate_lib.sh:74-75`) already calls `for-each-ref ... refs/heads/` and
  every one of the ~27 existing scenario directories that includes a `for-each-ref.out` fixture
  relies on that single, pattern-agnostic key. A new `STALE_REF` detector that also calls `git
  for-each-ref ... refs/remotes/child/` (or a broader `refs/remotes/` scan filtered client-side)
  would collide on the exact same `for-each-ref.out` fixture file used for branch enumeration in
  every existing scenario, silently replaying the wrong canned data for one of the two calls. This
  is a **concrete backward-compatibility hazard**, not a hypothetical one — verified directly from
  the stub's `case` statement. See Section 4.2 for the recommended fix (a specific-then-fallback key
  scheme).
- `git remote` is not handled at all by the stub (falls through to the `*) exit 0 ;;` default at line
  205-206, emitting nothing with rc 0). A `STALE_REF` implementation that needs to know "is there a
  remote named `child`?" (per the gap-7 wording, "no remote named `child` exists") needs a new `case`
  arm added to the stub for the `remote` subcommand — additive only, does not disturb any existing
  scenario (none currently invoke `git remote`).
- Representative scenario `current_exclusion` (`tests/fixtures/cleanup_worktrees/scenarios/current_exclusion/`)
  and shared shape file `tests/fixtures/cleanup_worktrees/worktree_shapes/worktree-list.out` were read
  in full; both are plain, hand-authored porcelain-format text files with no generation tooling — new
  fixtures for the four new record types would be authored the same way, by hand, matching the exact
  KEY the stub would derive for the new call(s).
- `test_cleanup_worktrees_classification.bats` (129 lines) and `test_cleanup_worktrees_enumeration.bats`
  (113 lines) were both read in full; both follow the identical pattern of `run env
  CLEANUP_WT_GIT_BIN=<stub> CLEANUP_WT_STUB_SCENARIO=<scenario-dir> bash -c "source <libs> && <call>
  2>/dev/null"`, asserting on `$status` and exact or substring `$output` matches. New tests for the
  four record types would follow the same idiom.
- No test in either file creates a temporary file or a real git repository; every input is a
  checked-in fixture file. This confirms the "no temp files" test policy is followed today and must
  be preserved for the new coverage.

### 1.9 Toolchain commands (verified)

`scripts/bash/shell-qc.sh` (104 lines) and `scripts/bash/shell_qc_lib.sh` exist and expose exactly
four subcommands: `check` (shfmt -d + shellcheck), `format` (shfmt -w), `test` (bats over
`tests/shell` and `tests/bash`), `test --coverage` (bats under kcov, Cobertura `cov.xml`, prints
`Bash coverage (lines): NN.N%`). Verbatim invocation form (per `.claude/rules/shell.md` and the
epic's Shared Design Constraint 4):

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<worktree path, forward slashes, no drive colon> && bash scripts/bash/shell-qc.sh <format|check|test|test --coverage>'
```

`shfmt`/`shellcheck` are also available directly on the Windows PATH per the same rule file.

## 2. Candidate Approaches

### 2.1 `CHILD_OF` short-circuit mechanism

**Approach A (rejected): per-pair ancestry check inside `classify_branch`, no cross-call memoization.**
Have `classify_branch` itself, before running rung 3, loop over every *other* branch name (passed in
as an extra argument or read from a global) and run `merge-base --is-ancestor <this-tip>
<other-tip>` against each. Rejected because it requires `classify_branch`'s signature/contract to
change (currently `classify_branch(name)` takes no branch-set context) and it re-derives the "is Y
already NOT_MERGED" fact redundantly on every call, with no way to guarantee Y has already been
resolved when X is processed (branch names are iterated in `LC_ALL=C` order via `enumerate_branches`,
which has no relationship to ancestor/descendant order).

**Approach B (recommended): shared two-phase driver in the new sibling library, called by both
`run_report` and `run_apply`.** Replace the duplicated per-branch loops at
`cleanup_worktrees_lib.sh:470-477` and `cleanup_worktrees_actions_lib.sh:357-380` with a single call
to a new function (e.g. `classify_all_branches`) defined in the new sibling file. That function:

1. Runs rungs 1-2 (`classify_ancestry`, `classify_content_neutral`) for every branch up front — both
   are O(1) git calls, not the expensive part.
2. For every branch not resolved by rungs 1-2, computes pairwise ancestry among just that reduced set
   via `merge-base --is-ancestor <tip-x> <tip-y>` (reusing the existing 0/1/>1 exit-code convention
   from `classify_ancestry`, generalized to an arbitrary second ref instead of the literal `main`).
   This builds a partial order (a branch may be an ancestor of one or more others in the set).
3. For each branch that is a *maximal* element of that partial order restricted to its connected
   component (i.e., not itself an ancestor of any other still-unresolved branch), runs the full rungs
   3-5 ladder normally.
4. For every branch `X` that *is* an ancestor of some other unresolved branch `Y`, defers X: once Y's
   full classification resolves, if Y's state is exactly `NOT_MERGED`, emit `BRANCH|X|NOT_MERGED` and
   `CHILD_OF|X|Y` for X without running rungs 3-5 for X at all. If Y's state resolves to anything else
   (`MERGED_EQUIVALENT`, `HAS_UNIQUE_RESIDUALS`, `MERGED_CONTENT_NEUTRAL`, `MERGED_CLEAN`,
   `ANCESTRY_ERROR`), the short-circuit does **not** apply and X must run the full ladder normally
   (see Section 2.3 for why this restriction to `NOT_MERGED` specifically is required for
   correctness).

Recommended because it is the only design that (a) reuses `classify_branch`'s existing per-branch
ladder unchanged for every branch that cannot be short-circuited, (b) is naturally shared between
`run_report` and `run_apply` (both already have the "loop over `enumerate_branches`' output, call the
classifier" shape and both would call the same new shared function), and (c) keeps the safety
argument (Section 2.3) local and auditable rather than distributed across ad hoc per-call checks.

**Rejected alternative:** always short-circuit as soon as *any* ancestor relationship is found,
regardless of the ancestor's resolved state. Rejected outright — this is the precise trap the
outcome-preservation invariant forbids (see Section 2.3: the subset argument only holds for the
`NOT_MERGED` outcome, not for `HAS_UNIQUE_RESIDUALS` or `MERGED_EQUIVALENT`).

### 2.2 `ORPHAN_DIR` / `STALE_REF` / `WARN|registration-lost` mechanism

**Approach A (rejected): compute directory sizes and `.git` pointer checks directly against the real
filesystem inside the library function, with no override seam.** Rejected because the general unit
test policy (`.claude/rules/general-unit-test.md`, "External Dependencies" and "Creation and use of
temporary files in tests is strictly prohibited") and the shell-specific test policy
(`.claude/rules/shell.md`: "Tests must not create temporary files; use checked-in fixtures... wired
through the `SHELL_QC_<TOOL>_BIN` seam") both forbid tests that touch a real, ad hoc filesystem
layout. A function that calls `du`/`find`/`stat` directly with no override point cannot be driven
deterministically from a checked-in fixture, and directory-size scanning of the actual repository
tree during a bats run is exactly the kind of non-deterministic, environment-dependent behavior the
policy exists to prevent.

**Approach B (recommended): extend the existing binary-override seam pattern
(`CLEANUP_WT_GIT_BIN` / `SHELL_QC_<TOOL>_BIN`) to the filesystem-scan and size-computation tools.**
Introduce new resolver functions in the new sibling library, following `cleanup_wt_git`'s exact
shape (`cleanup_worktrees_enumerate_lib.sh:34-57`): e.g. `cleanup_wt_du` honoring
`CLEANUP_WT_DU_BIN`, and a directory-candidate enumerator (e.g. `cleanup_wt_find`) honoring
`CLEANUP_WT_FIND_BIN`, each falling back to `command -v du` / `command -v find` when the override is
unset or not executable. Bats scenarios then ship a tiny checked-in shell-script stub for `du`/`find`
(mirroring `tests/fixtures/cleanup_worktrees/stub-bin/git`) that emits canned, deterministic lines —
synthetic paths and byte counts that never touch the real disk — keyed by scenario directory the same
way the git stub is. This is the only approach consistent with the repository's established
test-seam convention and the no-temp-file policy, and it requires no new pattern to be invented: it
is a mechanical extension of a pattern already proven for `git`.

Rejected micro-alternative within Approach B: reusing `cleanup_wt_git` itself for `du`/`find` calls
(i.e. routing non-git tools through the git-binary resolver). Rejected because `cleanup_wt_git`
explicitly resolves and execs a *git* binary (`"$git_bin" "$@"` at line 56); repurposing it for an
unrelated tool would be a misleading, dual-purpose function and would break the stub's argv-logging
convention (`stub-git: ...`), which is git-specific by name and by the KEY scheme documented in the
stub's header.

For `WARN|registration-lost`, the detection needs three filesystem-adjacent facts per candidate
directory: (1) enumerate directories under the known roots (`.claude/worktrees/`, `<repo>-wt/`); (2)
read the `.git` file inside each candidate (a `gitdir: <path>` pointer, per git's own worktree
convention); (3) check whether that pointed-to `.git/worktrees/<name>` path still exists. All three
are naturally exposed through the same `cleanup_wt_find`-style seam (a single stub invocation can
emit a synthetic `path|gitdir-target|target-exists(0/1)` tuple per candidate, avoiding three separate
tool seams). This mirrors `parse_worktree_list`'s own stanza-record design
(`path|head|branch-or-DETACHED|flags`) and keeps the new function's contract equally simple: one
record in, one `WARN|registration-lost|<path>` (or nothing) out.

## 3. Behavior Semantics

### 3.1 `CHILD_OF` — success/failure conditions

- **Applies only when** a branch `X`'s tip is a `merge-base --is-ancestor` match against another
  branch `Y`'s tip, **and** `Y`'s full-ladder classification resolves to exactly `NOT_MERGED` (not
  `HAS_UNIQUE_RESIDUALS`, `MERGED_EQUIVALENT`, `MERGED_CONTENT_NEUTRAL`, `MERGED_CLEAN`, or
  `ANCESTRY_ERROR`). See Section 2.3 for the correctness argument restricting this to `NOT_MERGED`.
- **On match:** emit `BRANCH|X|NOT_MERGED` (unchanged shape/value) plus a new, additive
  `CHILD_OF|X|Y` line. Rungs 3-5 are skipped for `X`.
- **On no match** (X is not an ancestor of any other unresolved branch, or its sole ancestor-target
  resolves to something other than `NOT_MERGED`): `X` runs the full ladder exactly as today, with no
  `CHILD_OF` line and no behavior change.
- **A hard git failure during the new pairwise `merge-base --is-ancestor` probe** (exit code > 1) must
  not silently fall through to "not an ancestor" (which would be safe-but-wrong only in the sense of
  losing the speed-up, not in the sense of a wrong verdict) nor be swallowed; per the file's own
  documented convention ("A hard failure of any enumeration/protection/cherry/diff-tree/ls-tree/rev-list
  read maps to the BRANCH|<name>|ANCESTRY_ERROR report state", `cleanup_worktrees_lib.sh:36-38`), a
  hard failure of this new probe should likewise map `X` to `ANCESTRY_ERROR`, consistent with every
  other git-backed read in this tool.
- **Ordering:** `CHILD_OF` lines are additive to the existing emission order (WARN, WORKTREE, then
  per-branch BRANCH/COMMIT); the exact interleaving of `CHILD_OF` lines relative to other branches'
  `BRANCH|`/`COMMIT|` lines is an open question for the atomic planner — see Section 6.

### 3.2 `ORPHAN_DIR` — success/failure conditions

- **Applies to** any directory found under the known worktree-tracking roots (`.claude/worktrees/`,
  `<repo>-wt/`) that has no `.git` file inside it and no corresponding entry in
  `parse_worktree_list`'s output. This mirrors SKILL.md's existing manual definition (line 192-194):
  "no `.git` file inside and no entry in `git worktree list`."
  Not a "registration-lost" directory (which *does* have a `.git` file but a broken pointer — see 3.4);
  the two are disjoint by definition and must not collide on the same report line.
- **Size** is a best-effort, informational field only (`<size>` in the record); no acceptance
  criterion here should assert a specific numeric size value, since size is inherently
  environment-dependent in production (though deterministic in tests via the stub seam).
- **Failure mode:** if the size-computation tool cannot resolve a size for a given directory (e.g. a
  permissions error), the record should still be emitted with an explicit placeholder (e.g. `unknown`)
  rather than being silently dropped — dropping would recreate exactly the visibility gap gap 7
  reports. This mirrors `check_main_freshness`'s "skip only when the underlying read cannot resolve at
  all" versus "always emit what can be determined" pattern, adapted to a per-item add rather than a
  single global check.

### 3.3 `STALE_REF` — success/failure conditions

- **Applies to** any `refs/remotes/<name>/*` ref where `<name>` is not present in the current `git
  remote` list. The gap-7 example is `refs/remotes/child/*` with no `child` remote configured.
- Must be **general** (not hardcoded to the literal name `child`), since gap 7 is describing one
  observed instance, not a permanent constant — verified against the epic's own framing of gap 7 as a
  general "stale refs are not reported" gap rather than a `child`-specific one.
- **Ordering:** `LC_ALL=C` sorted, consistent with the tool's existing sort convention for
  `enumerate_branches`.

### 3.4 `WARN|registration-lost` — success/failure conditions

- **Applies to** a directory with a `.git` file present (i.e., it is not an `ORPHAN_DIR` — it was, or
  still purports to be, a real worktree) whose `.git` file's `gitdir:` pointer target
  (`.git/worktrees/<name>` inside the main repo's `.git`) does not exist.
- **Advisory only**, following the `WARN|main-divergence` precedent exactly (line 233): never blocks
  classification, always safe to emit alongside everything else, and a failure to read the `.git` file
  itself (e.g. permissions) should be treated the same way `check_main_freshness` treats an
  unresolvable `rev-parse` — skip silently rather than error the whole report.
- **Root cause is explicitly out of scope** per both the epic's non-goals ("Establishing the cause of
  the mid-run worktree deregistration observed in gap 9d... adds a... detection line, not a
  root-cause fix.") and the task prompt. This research does not investigate why registrations were
  lost.

## 4. Requirements Mapping

### 4.1 New sibling library file

Recommend a new file `scripts/bash/cleanup_worktrees_report_records_lib.sh` (name chosen to match the
existing `cleanup_worktrees_<topic>_lib.sh` naming convention: `enumerate_lib`, `actions_lib`).
Proposed function groups:

- `cleanup_wt_du` / `cleanup_wt_find` (or a single combined filesystem-scan resolver) — override-seam
  resolvers mirroring `cleanup_wt_git` (Section 2.2, Approach B).
- `scan_orphan_dirs` — emits `ORPHAN_DIR|<path>|<size>` lines given the known roots and the current
  `parse_worktree_list` output (to exclude registered paths).
- `scan_stale_refs` — emits `STALE_REF|<refname>` lines given `git for-each-ref refs/remotes/` output
  and `git remote` output.
- `scan_registration_loss` — emits `WARN|registration-lost|<path>` lines given the same directory scan
  used by `scan_orphan_dirs`, filtered to directories that *do* have a `.git` file with a broken
  pointer.
- `classify_all_branches` (or equivalent name) — the shared two-phase `CHILD_OF`-aware driver
  described in Section 2.1, Approach B, intended to replace the duplicated loop bodies at
  `cleanup_worktrees_lib.sh:470-477` and `cleanup_worktrees_actions_lib.sh:357-380`.

This keeps `cleanup_worktrees_lib.sh` at 479 lines unchanged except for the `run_report` call-site
edit (replacing its inline loop with a call to the new shared function — a net-small diff, likely
still comfortably under 500 lines) and keeps the genuinely new logic isolated in a new,
independently-testable file.

### 4.2 Stub and fixture extensions required

- **`tests/fixtures/cleanup_worktrees/stub-bin/git`**: two additive changes only, both backward
  compatible with all ~27 existing scenario directories:
  1. Extend the `for-each-ref` case (lines 97-99) to derive a pattern-specific key first (e.g.
     `for-each-ref.$(sanitize "<last-arg>")`), falling back to the bare `for-each-ref` key when no
     scenario file matches the specific key. This preserves every existing `for-each-ref.out` fixture
     unchanged (they continue to satisfy the `refs/heads/` call via the fallback) while allowing new
     scenarios to supply a distinct `for-each-ref.refs_remotes_.out` (or similarly keyed) fixture for
     the stale-ref scan. This is the one change in this whole gap set that touches a file shared by
     every existing scenario, and must be implemented as a strict superset of current behavior — the
     atomic planner should require a full existing-suite bats run as a regression gate for this
     specific edit.
  2. Add a new `remote)` case (not currently present; falls through to the `*) exit 0 ;;` default
     today) that responds with a new `remote` key. Purely additive; no existing scenario invokes `git
     remote`, so no fixture needs to change.
  3. If `WARN|registration-lost`/`ORPHAN_DIR` are implemented via new `cleanup_wt_du`/`cleanup_wt_find`
     seams rather than through the git stub, a new, separate stub binary (e.g.
     `tests/fixtures/cleanup_worktrees/stub-bin/find` and/or `.../du`) is needed, following the same
     `KEY`-derivation-and-replay shape as the git stub but scoped to whatever synthetic
     path/size/pointer tuples the new scan functions need. This is a new file, not an edit to the git
     stub, so it carries zero regression risk to existing scenarios.
- **New scenario directories** (additive, one or more per new record type) under
  `tests/fixtures/cleanup_worktrees/scenarios/`, following the existing naming convention (verb/state
  descriptive, e.g. `orphan_dir_present`, `stale_ref_no_remote`, `child_of_not_merged`,
  `registration_lost`), each supplying only the `.out`/`.rc` files the new functions actually read
  (per the stub's KEY scheme), consistent with how e.g. `content_neutral/` supplies only
  `diff-quiet.feature-neutral.rc`, `for-each-ref.out`, `merge-base.feature-neutral.rc`, and the two
  `rev-parse.*` files it needs — no more.
- **New/extended bats files**: either new files (`test_cleanup_worktrees_report_records.bats`) or new
  `@test` blocks appended to `test_cleanup_worktrees_classification.bats` (for `CHILD_OF`) and
  `test_cleanup_worktrees_enumeration.bats` (for `ORPHAN_DIR`/`STALE_REF`/`WARN|registration-lost`,
  alongside the existing `check_main_freshness` tests). A new dedicated bats file is recommended for
  the three filesystem-facing record types, since they exercise a genuinely new function group (the
  new sibling library) rather than extending the existing enumeration functions.

### 4.3 Full file-change list

- `scripts/bash/cleanup_worktrees_report_records_lib.sh` — new file; all new scan/short-circuit logic.
- `scripts/bash/cleanup_worktrees_lib.sh` — edit `run_report` (445-479) to call the new shared
  `classify_all_branches`-style driver instead of its inline per-branch loop (470-477), and to invoke
  the new `scan_orphan_dirs`/`scan_stale_refs`/`scan_registration_loss` functions at the appropriate
  point in the emission order (Section 6, open question).
- `scripts/bash/cleanup_worktrees_actions_lib.sh` — edit `run_apply`'s per-branch loop (357-380) to
  call the same shared driver, so apply mode inherits the `CHILD_OF` cost optimization with an
  unchanged outcome (Section 1.5).
- `scripts/bash/cleanup-worktrees.sh` — extend `usage()`'s inline report-line-contract summary
  (lines 42-45) with the four new record shapes; extend the `Environment overrides` section if a new
  `CLEANUP_WT_DU_BIN`/`CLEANUP_WT_FIND_BIN`-style override is introduced; add the new sibling file's
  `source` line (16-24) in the correct order.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` — extend the Report Line Contract section
  (57-71) with the four new record types; cross-reference the existing Dirty Worktree Triage step 7
  orphan-directory guidance (190-197) from the new `ORPHAN_DIR` bullet rather than duplicating it;
  consider whether the End-to-End Workflow's step 1 (75-79) should mention the new proactive scan.
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  — byte-identical mirror of the SKILL.md edit above, required by
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- `tests/fixtures/cleanup_worktrees/stub-bin/git` — additive `for-each-ref` key-specificity fallback
  and new `remote` case (Section 4.2).
- New stub binary/binaries for the filesystem-scan seam (e.g.
  `tests/fixtures/cleanup_worktrees/stub-bin/find`, `.../du`), if that design direction is adopted.
- New scenario fixture directories under `tests/fixtures/cleanup_worktrees/scenarios/` (Section 4.2).
- `tests/shell/test_cleanup_worktrees_classification.bats` and/or a new
  `tests/shell/test_cleanup_worktrees_report_records.bats` — new `@test` coverage for all four record
  types (Section 4.2).

## 5. Testing Implications

- All new coverage must follow the established no-temp-file, checked-in-fixture, stub-seam pattern
  (Section 1.8); this is a hard constraint from `.claude/rules/general-unit-test.md` and
  `.claude/rules/shell.md`, not a stylistic preference.
- `CHILD_OF` needs at minimum: (a) a positive case where `X` is a verified ancestor of a `Y` that
  resolves `NOT_MERGED`, asserting both `BRANCH|X|NOT_MERGED` and `CHILD_OF|X|Y` are present and that
  none of `X`'s expensive-rung stub keys (`cherry.X`, `diff-tree.*`, `rev-list.X`) were invoked (an
  argv-log assertion against the `stub-git:` stderr lines, the same technique
  `test_cleanup_worktrees_consolidation.bats`-style tests likely already use for argv assertions); (b)
  a negative case where `X` is an ancestor of a `Y` that resolves `HAS_UNIQUE_RESIDUALS` or
  `MERGED_EQUIVALENT`, asserting the short-circuit does **not** apply and `X` is fully, correctly
  classified via the normal ladder with no `CHILD_OF` line; (c) an apply-mode test asserting the
  allowlist decision for a `CHILD_OF`-short-circuited `NOT_MERGED` branch is unchanged (no deletion
  ACTION emitted), directly exercising the Section 1.5 invariant.
- `ORPHAN_DIR`/`STALE_REF`/`WARN|registration-lost` each need a positive case (record emitted with the
  expected shape) and a negative case (no record when the directory is registered / the remote
  exists / the pointer resolves), following the existing pattern of paired scenarios (e.g.
  `dirty_worktree` vs `dirty_worktree_status_error`).
- The `for-each-ref` stub key-fallback change (Section 4.2) is the single highest-regression-risk
  fixture edit in this gap set, since it is shared by every existing scenario. The atomic plan should
  require a full `bash scripts/bash/shell-qc.sh test` pass (all existing suites, not just the new
  ones) immediately after that specific edit, before any new scenario fixtures are authored on top of
  it.
- Coverage: per `.claude/rules/quality-tiers.md`, line coverage >= 85% applies uniformly; bash has no
  branch-coverage gate (kcov limitation, not a lowered bar). The new sibling library's functions must
  each have direct bats coverage, per the epic's own NFR ("Every new bash library function carries
  bats coverage... with no temporary files").
- No numeric acceptance-criterion counts (e.g., "must detect N orphan directories") are proposed by
  this research; the user-supplied observation numbers (four directories, 17 refs, two worktrees) are
  historical facts about one past run, not properties the new detection logic should assert a fixed
  count for. Per the Numeric Derivation Evidence requirement, no such numeric AC should be written
  into spec.md without a full primary/cross-check derivation, and none is warranted here since the
  fix is generic, parameterized detection logic.

## 6. Open Questions and Risks for the Atomic Planner

1. **Exact emission ordering for the three new scan-based record types.** `run_report`'s current
   order is WARN (main-divergence) -> WORKTREE -> per-branch BRANCH/COMMIT (Section 1.2). Where do
   `ORPHAN_DIR`, `STALE_REF`, and `WARN|registration-lost` slot in? Grouping all WARN-class lines
   together (main-divergence and registration-lost) immediately after `check_main_freshness` seems
   natural; `ORPHAN_DIR`/`STALE_REF` could go either before or after the per-branch section. This
   research recommends colocating them with the other pre-branch-loop output (immediately after
   `WARN|main-divergence`, before `WORKTREE|` lines) since none of the three depend on per-branch
   classification results, but the planner should confirm this against SKILL.md's step-1 workflow
   text expectations.
2. **Whether `CHILD_OF` lines should appear in apply-mode's stdout stream.** Section 1.5 established
   that if `CHILD_OF` is emitted inside `classify_branch` (needed so the outcome-preservation
   guarantee is automatic in both modes), `run_apply`'s `printf '%s\n' "$cb_out"` at line 366 will
   surface it during `--apply` too. This is harmless to the allowlist logic but may be visual noise in
   apply-mode output. The planner should decide whether to filter `CHILD_OF` lines out of `run_apply`'s
   echoed output (a one-line `grep -v` before the printf) while keeping the underlying short-circuit
   intact, or leave it as informational apply-mode output.
3. **The `for-each-ref` stub key-specificity fallback (Section 4.2) is a shared-fixture-format
   change**, even though designed to be backward compatible. The planner should scope this as its own
   atomic, independently-verifiable step (edit the stub, run the full existing bats suite, confirm
   zero regressions) before any new scenario authoring depends on it.
4. **`git remote` output shape for the "no remote named `child`" check.** `git remote` (plain, no
   `-v`) prints one remote name per line; the exact args the new `scan_stale_refs` function issues
   (`git remote` vs `git remote --verbose` vs `for-each-ref refs/remotes/` alone with name extraction
   via `refname:short` prefix stripping) should be pinned by the planner, since it determines both the
   new stub `remote` case's exact key and the fixture content shape.
5. **Directory-root discovery for `ORPHAN_DIR`/`WARN|registration-lost`.** Gap 7's wording names two
   concrete roots (`.claude/worktrees/` and `<repo>-wt/`), but `<repo>-wt/` is itself derived
   (`consolidation_worktree_path`, `cleanup_worktrees_actions_lib.sh:39-68`, derives
   `<main-worktree-path>-wt/...`) rather than a fixed literal. The planner must decide whether the
   orphan/registration-loss scan roots are configurable (an env-var override, consistent with
   `CLEANUP_WT_CONSOLIDATION_PATH`) or hardcoded relative to the resolved main worktree path, and
   whether `.claude/worktrees/` is scoped to the current repo's `.claude/` or is a machine-wide
   convention (this session's own cwd, `.../drm-copilot/.claude/worktrees/agent-a2832325c12c3a9e1`,
   suggests it is per-repo, under the current repo's `.claude/` directory, and CLI-tool-managed rather
   than git-managed — i.e., outside git's own worktree bookkeeping entirely, which is consistent with
   gap 7's "no `.git` file and no registration" description).
6. **Whether `scan_registration_loss` and `scan_orphan_dirs` should share one filesystem-scan pass**
   or run as two independent scans. Section 2.2 recommends one shared low-level enumerator (emitting
   a `path|gitdir-target|target-exists` tuple) consumed by two thin classifier functions, to avoid
   duplicating the directory-walk seam; the planner should confirm this shape or specify an
   alternative before implementation.
