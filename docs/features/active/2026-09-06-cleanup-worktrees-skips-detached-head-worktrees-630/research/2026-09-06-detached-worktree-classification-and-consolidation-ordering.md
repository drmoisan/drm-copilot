# Research: detached-worktree classification and consolidation-branch ordering (Issue #630)

- Timestamp: 2026-09-06T00-00
- Feature: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/`
- Epic: `cleanup-merged-worktrees-hardening`, child A (gaps 1 and 6)
- Branch under study: `bug/cleanup-worktrees-skips-detached-head-worktrees-630`, based on
  `origin/epic/cleanup-merged-worktrees-hardening-integration`
- Scope: gaps 1 and 6 only. The dirt classifier (child C), report-mode orphan/stale-ref/`CHILD_OF`
  records (child B), and the removal manifest (child D) are out of scope and are not designed here.

Every `path:line` citation below was re-derived by reading the file in this pass against the
current worktree tree. Where a citation in the delegation prompt disagreed with the tree, the
tree value is used and the disagreement is called out.

---

## Summary

Two independent defect mechanisms are in scope.

**Mechanism 1 — apply mode is keyed on branch names, so a detached worktree is unreachable.**
`run_apply` builds a branch-to-path map and then iterates branches:

- `scripts/bash/cleanup_worktrees_actions_lib.sh:342-348` builds `wt_of` with the guard
  `[[ -n $wbranch && $wbranch != DETACHED ]] && wt_of[$wbranch]=$wpath` (line 347), so a detached
  registration is never entered into the map.
- `scripts/bash/cleanup_worktrees_actions_lib.sh:358-380` iterates `enumerate_branches` output
  only, and the sole destructive call site is
  `delete_candidate "$name" "${wt_of[$name]:-}" "$state"` at line 376.

A worktree with no branch has no key in `wt_of` and no corresponding entry in
`enumerate_branches`, so it is never passed to `delete_candidate` and never to
`remove_worktree_safe`. Report mode has the mirror-image gap: `run_report`
(`scripts/bash/cleanup_worktrees_lib.sh:445-479`) emits the raw registration line at line 468 and
then classifies branches only (lines 470-477); no classification is ever performed against a
detached HEAD commit. The omission is silent in both modes — no error, no diagnostic.

**Mechanism 2 — the consolidation branch is delete-eligible in the window between its creation and
its first commit.** `create_consolidation_worktree` runs
`cleanup_wt_git worktree add "$path" -b "$CLEANUP_WT_CONSOLIDATION_BRANCH" main`
(`scripts/bash/cleanup_worktrees_actions_lib.sh:94`), so at creation
`tip(documentationandmemories) == tip(main)`. `verify_consolidation_merged`
(`scripts/bash/cleanup_worktrees_actions_lib.sh:198-216`) decides solely on
`merge-base --is-ancestor "$CLEANUP_WT_CONSOLIDATION_BRANCH" main` (line 206), which exits 0 for a
branch whose tip equals `main`. It therefore prints `MERGED_CLEAN` and returns 0, which sets
`consolidation_ok=0` at line 355, which in turn skips the `BLOCKED-CONSOLIDATION-UNMERGED`
short-circuit at lines 360-363. `classify_branch` reaches the same verdict through its own first
rung (`classify_ancestry`, `scripts/bash/cleanup_worktrees_lib.sh:366-371`), so the branch is
`MERGED_CLEAN` and `delete_candidate` (line 376) removes the consolidation worktree and deletes
the branch.

---

## 1. Classification ladder: rung order, emitted states, and SHA reusability

### 1.1 Rung order in `classify_branch`

`classify_branch` is defined at `scripts/bash/cleanup_worktrees_lib.sh:308`. Its executable rung
order, with the exact emission line for each terminal state:

| # | Rung | Guard / call | Terminal emission |
|---|---|---|---|
| 0a | protected-set read | `cpout=$(compute_protected) \|\| cprc=$?` (`:334`) | `BRANCH\|%s\|ANCESTRY_ERROR` (`:336`), `return 2` |
| 0b | worktree-list read | `wlout=$(parse_worktree_list) \|\| wlrc=$?` (`:347`) | `BRANCH\|%s\|ANCESTRY_ERROR` (`:350`), `return 2` |
| 1 | protection | `[[ -n ${prot_branch[$name]:-} ]] \|\| { [[ -n $wt_norm && -n ${prot_path[$wt_norm]:-} ]]; }` (`:361`) | `BRANCH\|%s\|PROTECTED_CURRENT` (`:362`), `return 0` |
| 2 | ancestry | `v=$(classify_ancestry "$name")` (`:366`) | `MERGED_CLEAN` (`:369`) / `ANCESTRY_ERROR` (`:373`, `return 2`) |
| 3 | content-neutral | `v=$(classify_content_neutral "$name")` (`:377`) | `MERGED_CONTENT_NEUTRAL` (`:380`) / `ANCESTRY_ERROR` (`:384`, `return 2`) |
| 4 | cherry patch-id | `ce=$(classify_cherry_equivalent "$name")` (`:389`) | `ANCESTRY_ERROR` (`:393`, `return 2`) / `MERGED_EQUIVALENT` (`:397`) |
| 5 | blob fallback | loop `classify_residual_commit "$name" "$sha"` (`:402-417`) | `ANCESTRY_ERROR` (`:409`, `return 2`) / `MERGED_EQUIVALENT` (`:420`) when `unique_count == 0` |
| 6 | residual disposition | `minus_present` (`:426-427`) or `content_count > 0` (`:429`) | `BRANCH\|%s\|%s` (`:432`) with `state` = `HAS_UNIQUE_RESIDUALS` or `NOT_MERGED` |
| 7 | candidate emission | `select_cherry_pick_candidates "$name"` (`:437`), only when `HAS_UNIQUE_RESIDUALS` | `COMMIT\|...` (`:302`); `return 2` on failure (`:439`) |

Emittable `BRANCH` states, enumerated exhaustively from every `printf 'BRANCH|...` in the file
(lines 336, 350, 362, 369, 373, 380, 384, 393, 397, 409, 420, 432): `ANCESTRY_ERROR`,
`PROTECTED_CURRENT`, `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`,
`HAS_UNIQUE_RESIDUALS`, `NOT_MERGED` — seven tokens. See `## Numeric Derivation Evidence`.

### 1.2 Committish acceptance, per rung

**`classify_ancestry` — accepts any committish.** `scripts/bash/cleanup_worktrees_lib.sh:52-73`:

```bash
	# Args: $1 = branch tip (name or sha).
	local tip="$1" rc=0
	cleanup_wt_git merge-base --is-ancestor "$tip" main >/dev/null 2>&1 || rc=$?
```

The docstring at `:62` already declares "name or sha". `git merge-base --is-ancestor <commit>
<commit>` takes commits, so a bare SHA is valid. Verdicts: `MERGED_CLEAN` (`:66`),
`NOT_ANCESTOR` (`:68`), `ANCESTRY_ERROR` (`:70`).

**`classify_content_neutral` — accepts any committish, despite the docstring.**
`scripts/bash/cleanup_worktrees_lib.sh:75-98`:

```bash
	# Args: $1 = branch name.
	local branch="$1" rc=0
	cleanup_wt_git diff --quiet "main...$branch" >/dev/null 2>&1 || rc=$?
```

The docstring at `:87` says "branch name", but the interpolation produces `main...<sha>`, which is
valid three-dot revision syntax for any commit. Verdicts: `MERGED_CONTENT_NEUTRAL` (`:91`),
`NOT_NEUTRAL` (`:93`), `CONTENT_NEUTRAL_ERROR` (`:95`).

**`classify_cherry_equivalent` — accepts any committish.**
`scripts/bash/cleanup_worktrees_lib.sh:100-169`, capture at `:131`:

```bash
	out=$(cleanup_wt_git cherry main "$branch") || rc=$?
```

`git cherry <upstream> [<head>]` takes a commit for `<head>`. Verdicts: `CHERRY_ERROR` (`:133`),
`DIFF_TREE_ERROR` (`:152`), `MERGED_EQUIVALENT` (`:161`), or `MINUS_PRESENT` (`:163`) followed by
`RESIDUAL <sha>` lines (`:165`).

**`classify_residual_commit` — accepts any committish for `$1`.**
`scripts/bash/cleanup_worktrees_lib.sh:185-252`. `$1` is used only through
`_blob_equal "$branch" main "$relpath"` (`:223`, `:241`), and `_blob_equal`
(`scripts/bash/cleanup_worktrees_lib.sh:171-183`) resolves it as
`cleanup_wt_git rev-parse "$ref_a:$path"` (`:180`). `<sha>:<path>` is valid revision syntax.
`$2` is already a bare SHA in every existing call. Verdicts: `RESIDUAL_ERROR` (`:215`, `:234`),
`CONTENT_ON_MAIN` (`:246`), `UNIQUE|<paths>` (`:249`).

### 1.3 Rungs that misbehave on a bare SHA

**`classify_branch` itself must not be reused.** Three concrete reasons, each with a citation:

1. *Protection lookup is branch-keyed and silently misses.* `scripts/bash/cleanup_worktrees_lib.sh:353-360`:

   ```bash
   	while IFS= read -r record; do
   		[[ -z $record ]] && continue
   		IFS='|' read -r wpath _ wbranch _ <<<"$record"
   		if [[ $wbranch == "$name" ]]; then
   			wt_norm=$(normalize_wt_path "$wpath")
   			break
   		fi
   	done <<<"$wlout"
   ```

   For a detached worktree, `parse_worktree_list` sets the branch field to the literal `DETACHED`
   (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:115-116`), which never equals a SHA. `wt_norm`
   therefore stays empty, the `prot_path` half of the test at `:361` is skipped, and the caller's
   own detached worktree would be classified as an ordinary candidate instead of
   `PROTECTED_CURRENT`. This is the single most safety-relevant misbehaviour and is why the new
   code must look protection up by *path*, not by name.

2. *It emits into the `BRANCH|` namespace.* Every terminal emission is `printf 'BRANCH|%s|...'
   "$name"`, so a SHA would appear as a branch record. The Report Line Contract reserves that
   record for branches (`.claude/skills/cleanup-merged-worktrees/SKILL.md:61-62`).

3. *Rung 7 fabricates SHA-keyed `COMMIT` records.* `select_cherry_pick_candidates`
   (`scripts/bash/cleanup_worktrees_lib.sh:254-306`) emits
   `COMMIT|<branch>|<sha>|UNIQUE|...` at `:302`, and its rev-list at `:281` is
   `"main..$branch"`. With a SHA the second field of the record would be a SHA, and
   `cherry_pick_candidates` (`scripts/bash/cleanup_worktrees_actions_lib.sh:103-163`) reads that
   field into `branch` at `:127` and uses it as the `skip_branch` key at `:129`. A detached HEAD
   has no branch to consolidate from, so rung 7 must not run for a detached candidate.

### 1.4 Reusable call sequence for a bare SHA

The following sequence yields exactly one of the seven states without touching `classify_branch`.
It reuses rungs 1-5 verbatim and replaces rungs 0-1 and 6-7.

```
0. cpout=$(compute_protected) || return ANCESTRY_ERROR/2
   parse the protected-path set; if normalize_wt_path(<worktree path>) is in it -> PROTECTED_CURRENT
1. v=$(classify_ancestry "<sha>")
   MERGED_CLEAN     -> MERGED_CLEAN
   ANCESTRY_ERROR   -> ANCESTRY_ERROR / rc 2
   NOT_ANCESTOR     -> continue
2. v=$(classify_content_neutral "<sha>")
   MERGED_CONTENT_NEUTRAL -> MERGED_CONTENT_NEUTRAL
   CONTENT_NEUTRAL_ERROR  -> ANCESTRY_ERROR / rc 2
   NOT_NEUTRAL            -> continue
3. ce=$(classify_cherry_equivalent "<sha>")
   CHERRY_ERROR | DIFF_TREE_ERROR -> ANCESTRY_ERROR / rc 2
   MERGED_EQUIVALENT              -> MERGED_EQUIVALENT
   otherwise                      -> continue with the RESIDUAL/MINUS_PRESENT token stream
4. for each `RESIDUAL <sha2>` line: verdict=$(classify_residual_commit "<sha>" "<sha2>")
   RESIDUAL_ERROR   -> ANCESTRY_ERROR / rc 2
   UNIQUE|<paths>   -> unique_count++
   CONTENT_ON_MAIN  -> content_count++
   unique_count == 0 -> MERGED_EQUIVALENT
5. minus_present (ce contains MINUS_PRESENT) or content_count > 0 -> HAS_UNIQUE_RESIDUALS
   else                                                           -> NOT_MERGED
   (no COMMIT records are emitted for a detached candidate)
```

This produces `MERGED_CLEAN`, `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, `NOT_MERGED`,
`HAS_UNIQUE_RESIDUALS`, `PROTECTED_CURRENT`, or `ANCESTRY_ERROR` — exactly the vocabulary AC1
requires.

One cost note grounded in the observed run: for a detached HEAD that is an ancestor of `main`
(the common case; 30 of 57 worktrees in the 2026-09-06 run), the sequence terminates at step 1
after a single `merge-base --is-ancestor` call. Only a non-ancestor detached HEAD pays for the
cherry/blob rungs.

---

## 2. Worktree enumeration: `parse_worktree_list` record shape

`parse_worktree_list` is defined at `scripts/bash/cleanup_worktrees_enumerate_lib.sh:85`.

### 2.1 Record shape and variables

The nested `emit_record` helper (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:103-119`) is the
sole emitter:

```bash
	emit_record() {
		((have == 0)) && return 0
		local -a flag_parts=()
		((first == 1)) && flag_parts+=("main")
		((detached == 1)) && flag_parts+=("detached")
		((bare == 1)) && flag_parts+=("bare")
		((locked == 1)) && flag_parts+=("locked")
		((prunable == 1)) && flag_parts+=("prunable")
		local flags=""
		local IFS=,
		flags="${flag_parts[*]}"
		local branch_field="DETACHED"
		[[ -n $branch ]] && branch_field=$branch
		printf '%s|%s|%s|%s\n' "$path" "$head" "$branch_field" "$flags"
		first=0
	}
```

- Output is a **newline-separated stream of 4-field pipe-delimited records**, not an array. Field
  order: `path|head|branch-or-DETACHED|flags`.
- Accumulator variables declared at `scripts/bash/cleanup_worktrees_enumerate_lib.sh:101-102`:
  `path`, `head`, `branch`, `detached`, `bare`, `locked`, `prunable`, `first`, `have`.
- `locked`, `prunable`, `bare`, `detached` are **integer flags** (0/1) collapsed into a
  comma-joined `flags` field in the fixed order `main,detached,bare,locked,prunable`. Their
  porcelain reason text (`locked <reason>`, `prunable <reason>`) is discarded — the parser matches
  on prefix at `:141-142` (`"locked"*`, `"prunable"*`).
- The **main worktree is distinguished only by the `main` flag on the first stanza** (`:106`,
  driven by `first=1` initialised at `:102` and cleared at `:118`). There is no separate field.
- Stanza framing: `"worktree "*` flushes the prior record and resets the accumulators
  (`:131-136`); a blank line is a no-op separator (`:143`); a trailing `emit_record` at `:146`
  flushes the last stanza.
- Hard-failure discipline: the porcelain listing is captured in the parent shell at `:124`
  (`out=$(cleanup_wt_git worktree list --porcelain) || rc=$?`); a non-zero exit returns git's code
  with **no records emitted** (`:125-128`).

### 2.2 Branch stanza versus detached stanza

Verified against `tests/fixtures/cleanup_worktrees/worktree_shapes/worktree-list.out` (4 stanzas,
lines 1-19) and the assertions in `tests/shell/test_cleanup_worktrees_enumeration.bats:29-49`:

| Porcelain input | Emitted record |
|---|---|
| `worktree /repo/main` / `HEAD aaaa0000` / `branch refs/heads/main` | `/repo/main\|aaaa0000\|main\|main` |
| `worktree /repo-wt/onbranch` / `HEAD bbbb1111` / `branch refs/heads/some-branch` | `/repo-wt/onbranch\|bbbb1111\|some-branch\|` |
| `worktree /repo-wt/detachedlocked` / `HEAD cccc2222` / `detached` / `locked reason here` | `/repo-wt/detachedlocked\|cccc2222\|DETACHED\|detached,locked` |
| `worktree /repo-wt/pruned` / `HEAD dddd3333` / `branch refs/heads/gonebranch` / `prunable gitdir file points to a non-existent location` | `/repo-wt/pruned\|dddd3333\|gonebranch\|prunable` |

The four expected records are pinned by `tests/shell/test_cleanup_worktrees_enumeration.bats:33`,
`:34`, `:41`, and `:48`. **This record shape must not change**, or those four assertions break.

### 2.3 Detection rule: use the flag, not the branch field

Two porcelain shapes produce the literal `DETACHED` branch field without being a
detached-HEAD candidate:

- A **bare** repository stanza carries no `HEAD` and no `branch` line, so `head` stays empty,
  `branch_field` becomes `DETACHED`, and `flags` becomes `main,bare` for the first stanza.
- A local branch literally named `DETACHED` would produce `branch_field == DETACHED` with no
  `detached` flag.

Therefore the detached-candidate predicate must be: `flags` contains `detached` **and** does not
contain `main` **and** does not contain `bare` **and** `head` is non-empty. Testing
`branch == DETACHED` is not sufficient. AC1's "excluding the main worktree" is satisfied by the
`main`-flag exclusion.

### 2.4 `normalize_wt_path`

`scripts/bash/cleanup_worktrees_enumerate_lib.sh:150-164`:

```bash
	local p=${1:-}
	[[ -z $p ]] && return 0
	p=${p//\\//}
	p=${p,,}
	p=${p%/}
	printf '%s\n' "$p"
```

Three transformations, in order: every backslash to forward slash; full lowercase (`${p,,}`);
strip exactly one trailing slash. Empty input echoes nothing and returns 0. Applied to the live
detached worktree path this yields
`c:/users/danmoisan/appdata/local/temp/claude/c--users-danmoisan-repos-drm-copilot-wt-2026-08-21t17-18/3a9f9b03-f2e5-4fee-a94a-e4f2849de2d5/scratchpad/base-wt`.

---

## 3. Protection: what `compute_protected` protects and how a detached path matches

`compute_protected` is defined at `scripts/bash/cleanup_worktrees_enumerate_lib.sh:166`.

It emits two record kinds:

- `protected-branch|<name>` — emitted **only** when the current branch is a real branch. Guard at
  `:196`: `if [[ -n $current_branch && $current_branch != HEAD ]]`. `current_branch` comes from
  `git rev-parse --abbrev-ref HEAD` at `:185`, which prints the literal `HEAD` when the caller is
  itself detached, so this line is correctly omitted for a detached caller.
- `protected-path|<normalized-path>` — emitted at `:209` for the **first porcelain stanza
  unconditionally** (the main worktree), and at `:214` for any stanza whose normalized path equals
  the normalized `git rev-parse --show-toplevel` result (`:190`, normalized at `:195`).

Hard failures are fatal, not degrading: `:186-189` and `:191-194` return git's exit code, and the
`parse_worktree_list` capture at `:203-206` propagates its non-zero return.

**How a detached candidate matches.** The protected set is keyed by *normalized path*, so a
detached worktree needs no branch name to be protected. The caller's own detached worktree yields
`PROTECTED_CURRENT` through this chain: `git rev-parse --show-toplevel` returns the detached
worktree's own toplevel; `normalize_wt_path` normalizes it; the porcelain stanza for that same path
normalizes identically; the equality test at `:213` succeeds; `protected-path|<norm>` is emitted;
the new detached classifier looks up `prot_path[$(normalize_wt_path "$wpath")]` and short-circuits
to `PROTECTED_CURRENT`. This is exactly the mechanism `classify_branch` uses at
`scripts/bash/cleanup_worktrees_lib.sh:339-344` and `:361`, minus the branch-name lookup that
cannot work for a SHA.

The main worktree is doubly protected: by the unconditional `protected-path` at `:209` and by the
`main` flag exclusion from §2.3.

---

## 4. Report emission: current format, required change, and existing-assertion impact

### 4.1 The two current emission sites

There are exactly two `WORKTREE|` printf sites in the tool (see `## Numeric Derivation Evidence`):

`scripts/bash/cleanup_worktrees_lib.sh:465-469` (report mode):

```bash
	while IFS= read -r record; do
		[[ -z $record ]] && continue
		IFS='|' read -r wpath _ wbranch wflags <<<"$record"
		printf 'WORKTREE|%s|%s|%s\n' "$wpath" "$wbranch" "$wflags"
	done <<<"$wlout"
```

`scripts/bash/cleanup_worktrees_actions_lib.sh:343-348` (apply mode), identical except for the
added map assignment:

```bash
	while IFS= read -r record; do
		[[ -z $record ]] && continue
		IFS='|' read -r wpath _ wbranch wflags <<<"$record"
		printf 'WORKTREE|%s|%s|%s\n' "$wpath" "$wbranch" "$wflags"
		[[ -n $wbranch && $wbranch != DETACHED ]] && wt_of[$wbranch]=$wpath
	done <<<"$wlout"
```

Note the `head` field of the record is discarded in both loops (the `_` in the `read`). The
detached path needs it, so the new code must re-read the record with the head bound.

### 4.2 Documented contract

`.claude/skills/cleanup-merged-worktrees/SKILL.md:57-71` is the "Report Line Contract" section.
The worktree bullet is line 66, verbatim:

```
- `WORKTREE|<path>|<branch-or-DETACHED>|<flags>` — worktree registrations.
```

The same shape is repeated in two non-normative places: the library header comment at
`scripts/bash/cleanup_worktrees_lib.sh:43` and the `--help` text at
`scripts/bash/cleanup-worktrees.sh:44`.

(The delegation prompt cited SKILL.md:57 for the contract; :57 is the section heading
`## Report Line Contract` and :66 is the worktree bullet. The file is 265 lines, not 264.)

### 4.3 Required change

Branch-backed records keep `WORKTREE|<path>|<branch>|<flags>` byte-for-byte. Detached records must
carry the state.

A strictly 4-field detached record `WORKTREE|<path>|DETACHED|<state>` — the literal AC1 shape —
discards the `locked` and `prunable` flags from report mode, because `detached` is redundant with
field 3 and `main`/`bare` are excluded by §2.3. That loss matters: AC4 requires distinct handling
for `locked` and `prunable` detached worktrees, and a report consumer would have no way to see
which detached worktree is locked before running `--apply`.

**Recommendation: emit a 5-field detached record with the flags appended after the state:**

```
WORKTREE|<path>|DETACHED|<state>|<flags>
```

This is a strict extension of AC1's shape: the first four fields are exactly
`WORKTREE|<path>|DETACHED|<state>`, so any substring or prefix assertion written directly against
AC1's text matches unchanged, and no registration information is lost. The spec should record this
explicitly (see `## Risks and Open Questions`, item R1) rather than leaving the reader to infer it.

The emission must be a **replacement**, not an addition. AC1 says "exactly one" record per detached
worktree, so the loops at `cleanup_worktrees_lib.sh:465-469` and
`cleanup_worktrees_actions_lib.sh:343-348` must skip detached candidates and let the new function
emit the single state-bearing record.

### 4.4 Existing bats assertions — impact analysis

Every existing assertion mentioning `WORKTREE|`, checked individually:

| Assertion | Verdict |
|---|---|
| `tests/shell/test_cleanup_worktrees_classification.bats:44` — `== *"WORKTREE\|/repo-wt/feat\|feature-wt\|"*` | Safe. Branch-backed record, shape unchanged. |
| `tests/shell/test_cleanup_worktrees_classification.bats:37` — `!= *"WORKTREE\|/repo-wt"*"feature-merged"*` | Safe. `merged_no_worktree/worktree-list.out` has only the main stanza. |
| `tests/shell/test_cleanup_worktrees_classification.bats:108` — `!= *"WORKTREE\|"*` | Safe. `worktree_list_error` aborts before emission (`cleanup_worktrees_lib.sh:456-459`). |
| `tests/shell/test_cleanup_worktrees_cli.bats:33` — `== *"WORKTREE\|/repo-wt/feat\|feature-wt\|"*` | Safe. Branch-backed. |
| `tests/shell/test_cleanup_worktrees_cli.bats:61` — `!= *"WORKTREE\|"*` | Safe. Source-guard test; nothing runs. |
| `tests/shell/test_cleanup_worktrees_hard_failures.bats:90` — `!= *"WORKTREE\|"*` | Safe. `enumerate_error` aborts at `cleanup_worktrees_lib.sh:460-463`. |
| `tests/shell/test_cleanup_worktrees_hard_failures.bats:107` — `!= *"WORKTREE\|"*` | Safe. `worktree_list_error` aborts at `cleanup_worktrees_actions_lib.sh:333-336`. |
| `tests/shell/test_cleanup_worktrees_enumeration.bats:33,34,41,48` | Safe **only if** `parse_worktree_list`'s record shape is left untouched. These pin `/repo-wt/detachedlocked\|cccc2222\|DETACHED\|detached,locked` exactly. |

No existing scenario fixture under `tests/fixtures/cleanup_worktrees/scenarios/` contains a
non-main detached stanza (verified by reading every `worktree-list.out` referenced by the report
and apply suites). The only detached stanza in the fixture tree is in
`tests/fixtures/cleanup_worktrees/worktree_shapes/worktree-list.out`, which is consumed only by
`parse_worktree_list`-level tests, never by `run_report`/`run_apply`. **Adding detached
classification therefore changes zero existing scenario outputs.**

One structural change *does* affect two suites: if `run_report` calls a function defined in a new
library file, the bats helpers that source only `ELIB` + `LIB` must also source the new file.
Those helpers are `tests/shell/test_cleanup_worktrees_classification.bats:20-21` (`cb`) and
`:25-26` (`report`), and `tests/shell/test_cleanup_worktrees_enumeration.bats:23,31,...`.
Using a `declare -F` soft guard instead is rejected: it would silently skip detached classification
if the sourcing order ever regressed, which is precisely the failure mode this feature exists to
remove.

---

## 5. Dirty detection: current mechanism, detached reachability, and the child C seam

### 5.1 Current mechanism

Dirtiness is determined in exactly one place, inside `remove_worktree_safe`
(`scripts/bash/cleanup_worktrees_actions_lib.sh:252-279`), and only **after** a failed removal:

```bash
	local path="$1" rc=0 line sout srrc=0
	[[ -z $path ]] && return 0
	cleanup_wt_git worktree remove "$path" >/dev/null || rc=$?
	if ((rc == 0)); then
		printf 'ACTION|worktree-remove|%s|OK\n' "$path"
		return 0
	fi
	sout=$(cleanup_wt_git -C "$path" status --porcelain) || srrc=$?
	if ((srrc == 0)) && [[ -n $sout ]]; then
		while IFS= read -r line; do
			[[ -z $line ]] && continue
			printf 'DIRTY|%s|%s\n' "$path" "$line"
		done <<<"$sout"
	fi
	printf 'ACTION|worktree-remove|%s|BLOCKED-DIRTY\n' "$path"
	return 1
```

- Command: `git -C <path> status --porcelain` (line 270), captured into `sout` with `srrc`.
- Parsing: one `DIRTY|<path>|<status-porcelain-line>` record per non-empty output line (`:272-275`).
- The tool never inspects dirtiness proactively; git's refusal to remove is the trigger.
- Wire format observed in the fixture-driven test
  (`tests/shell/test_cleanup_worktrees_deletion.bats:28-29`, backed by
  `tests/fixtures/cleanup_worktrees/scenarios/dirty_worktree/status._repo-wt_dirty.out`):

  ```
  DIRTY|/repo-wt/dirty|?? untracked-artifact.txt
  ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY
  ```

- A hard failure of the status read still blocks: `srrc != 0` skips the `DIRTY|` lines but the
  `BLOCKED-DIRTY` line and `return 1` still fire. Pinned by
  `tests/shell/test_cleanup_worktrees_hard_failures.bats:166-172`.

### 5.2 Reachability for a path with no branch

Fully reachable. `remove_worktree_safe` takes a **path only** — no branch name, no ref resolution.
`git -C <path> status --porcelain` works identically in a detached worktree. **Child A therefore
needs no new dirty-detection code at all**: it calls `remove_worktree_safe "$path"` and inherits
`DIRTY|` emission, `BLOCKED-DIRTY`, and the non-zero return, satisfying AC4's dirty clause with
zero new logic.

### 5.3 Seam and boundary with child C

Child C (gap 2) adds a report-mode dirt classifier with six verdicts and an opt-in
`--clear-disposable` apply flag. Its natural edit regions are (a) a new `DIRTY|` producer in report
mode and (b) the block at `cleanup_worktrees_actions_lib.sh:268-278`, where the disposable-clearing
path would branch before the `BLOCKED-DIRTY` emission.

**Proposed boundary, to be recorded in both children's specs:**

- Child A **does not modify** `remove_worktree_safe` (`cleanup_worktrees_actions_lib.sh:252-279`).
  It consumes the function as an opaque contract: path in; `OK`/`BLOCKED-DIRTY` and rc 0/1 out.
- Child A owns the `BLOCKED-LOCKED` decision, and places it in the **new file**, before the
  `remove_worktree_safe` call, never inside it.
- Child C owns every `DIRTY|` producer and the dirt-verdict vocabulary. Child A introduces no
  `DIRTY|` line of its own.
- When child C lands, its dirt verdicts apply to a detached worktree automatically, because the
  detached path routes through the same `remove_worktree_safe`. No re-integration work is implied
  by this boundary.

---

## 6. Removal mechanics

### 6.1 `remove_worktree_safe`

Full behaviour is quoted in §5.1. Specifics required by the questions:

- **argv built:** `git worktree remove <path>` and, only on failure, `git -C <path> status
  --porcelain`. Both go through `cleanup_wt_git`
  (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:34-57`).
- **`--force` is never added, under any condition.** A repository-wide grep of `scripts/bash/` for
  `--force`, `worktree prune`, and `BLOCKED-LOCKED` returns **no matches**. The prohibition is also
  stated in `.claude/skills/cleanup-merged-worktrees/SKILL.md:236-238`.
- **Empty path:** `[[ -z $path ]] && return 0` (`:262`) — silent no-op, used by `delete_candidate`
  for a branch with no worktree.
- **Return discipline:** 0 on removal or no-op; 1 on a blocked removal.

### 6.2 `reverify_delete_eligible` contract

`scripts/bash/cleanup_worktrees_actions_lib.sh:218-250`. Same-process re-check immediately before
a destructive action:

```bash
	out=$(classify_branch "$name") || crc=$?
	if ((crc != 0)); then
		printf 'ACTION|delete|%s|BLOCKED-REVERIFY\n' "$name"
		return 1
	fi
	...
	case "$state" in
	MERGED_CLEAN | MERGED_CONTENT_NEUTRAL | MERGED_EQUIVALENT)
		return 0
		;;
	*)
		printf 'ACTION|delete|%s|BLOCKED-REVERIFY\n' "$name"
		return 1
		;;
	esac
```

Two independent fail-closed paths: a non-zero `classify_branch` return (`:231-235`) and a state
outside the three-token allowlist (`:241-249`). It is **branch-only**: it takes a name and calls
`classify_branch`, both of which are unusable for a detached HEAD (§1.3). A detached analogue is
required in the new file.

### 6.3 ACTION vocabulary emitted today

Complete result-token set, derived twice independently (see `## Numeric Derivation Evidence`):
`OK`, `FAILED`, `SKIPPED-BRANCH`, `CONFLICT`, `BLOCKED-DIRTY`, `BLOCKED-REVERIFY`,
`BLOCKED-CONSOLIDATION-UNMERGED` — seven tokens. **`BLOCKED-LOCKED` does not exist and must be
introduced** by this child.

### 6.4 Return-code propagation into `run_apply`'s exit code

`delete_candidate` (`scripts/bash/cleanup_worktrees_actions_lib.sh:297-314`) chains three steps and
stops at the first failure:

```bash
	reverify_delete_eligible "$name" "$state" || return 1
	if [[ -n $wt_path ]]; then
		remove_worktree_safe "$wt_path" || return 1
	fi
	delete_branch "$name"
```

`run_apply` collects it at `:376` (`delete_candidate ... || rc=1`) and at `:367-371` for a
classification hard failure, then returns `rc` at `:381`. The CLI wrapper captures and re-exits it
(`scripts/bash/cleanup-worktrees.sh:70-72`, `:82`, `:88-92`).

Consequence for the detached path: a blocked detached removal (dirty or locked) will set `rc=1`,
exactly as a blocked branch-backed removal does today. This is behaviourally consistent but is a
**visible change to a run's exit code** — a checkout with dirty detached worktrees will start
exiting non-zero from `--apply` where it previously exited 0. Recorded as R3 below.

---

## 7. Consolidation: creation, verification, and the correct guard

### 7.1 `create_consolidation_worktree`

`scripts/bash/cleanup_worktrees_actions_lib.sh:70-101`. Git commands, in order:

1. `consolidation_worktree_path` (`:84`), which derives `<main-worktree-path>-wt/documentationandmemories`
   from the first `parse_worktree_list` record (`:53-67`), or honours
   `CLEANUP_WT_CONSOLIDATION_PATH` (`:48-52`).
2. `cleanup_wt_git rev-parse --verify --quiet "refs/heads/$CLEANUP_WT_CONSOLIDATION_BRANCH"`
   (`:88-89`) — a pre-existing branch aborts with a stderr diagnostic and `return 1` (`:90-93`).
3. `cleanup_wt_git worktree add "$path" -b "$CLEANUP_WT_CONSOLIDATION_BRANCH" main` (`:94`).

Step 3 is the origin of the hazard: `-b <branch> main` creates the branch at `main`'s tip.

`CLEANUP_WT_CONSOLIDATION_BRANCH="documentationandmemories"` is set at `:37`.

### 7.2 `verify_consolidation_merged`

`scripts/bash/cleanup_worktrees_actions_lib.sh:198-216`, in full:

```bash
	local mrc=0
	cleanup_wt_git fetch origin main >/dev/null 2>&1 || true
	cleanup_wt_git merge-base --is-ancestor "$CLEANUP_WT_CONSOLIDATION_BRANCH" main >/dev/null 2>&1 || mrc=$?
	if ((mrc == 0)); then
		printf 'MERGED_CLEAN\n'
		return 0
	elif ((mrc == 1)); then
		printf 'NOT_ANCESTOR\n'
		return 1
	fi
	printf 'ANCESTRY_ERROR\n'
	return 2
```

`MERGED_CLEAN` here means only "every commit reachable from `documentationandmemories` is
reachable from `main`". For a branch with zero commits of its own, that predicate is vacuously
true. The `git fetch origin main` at `:205` is best-effort by design (documented at
`cleanup_worktrees_actions_lib.sh:32-33`: a stale `main` can only block deletion, never fabricate
ancestry).

### 7.3 The exact delete-eligible window

Opens at `cleanup_worktrees_actions_lib.sh:94` (the `git worktree add -b ... main` returns).
Closes when the first commit lands on `documentationandmemories` — i.e. the end of the skill's
consolidation step (`.claude/skills/cleanup-merged-worktrees/SKILL.md:88-94`) or, in the manual
route observed on 2026-09-06, at the hand-authored consolidation commit. Inside the window:

1. `run_apply:352-356` probes `refs/heads/documentationandmemories`, finds it, calls
   `verify_consolidation_merged`, receives `MERGED_CLEAN`, sets `consolidation_ok=0` (`:355`).
2. The short-circuit at `:359-363` is `if [[ $name == "$CLEANUP_WT_CONSOLIDATION_BRANCH" ]] &&
   ((consolidation_ok != 0))`; with `consolidation_ok=0` the guard is false, so the
   `ACTION|delete|documentationandmemories|BLOCKED-CONSOLIDATION-UNMERGED` line at `:361` is **not**
   emitted and the `continue` at `:362` does not run.
3. `classify_branch documentationandmemories` reaches `classify_ancestry` and returns
   `MERGED_CLEAN` (`cleanup_worktrees_lib.sh:366-371`).
4. `:375-377` matches the allowlist and calls `delete_candidate`, which removes the consolidation
   worktree and deletes the branch.

The `ACTION|delete|documentationandmemories|BLOCKED-CONSOLIDATION-UNMERGED` line at
`cleanup_worktrees_actions_lib.sh:361` is therefore produced **only** when `consolidation_ok != 0`,
which today means `verify_consolidation_merged` printed something other than `MERGED_CLEAN`.

### 7.4 The correct guard

Two candidate forms were evaluated against three states.

| State | `rev-list --count main..dm` | `tip(dm) == tip(main)` | Correct verdict |
|---|---|---|---|
| A. Just created, `main` unmoved (the hazard window) | 0 | true | block |
| B. Created, `main` advanced, still zero commits | 0 | false | block (ideally) |
| C. Consolidation PR merged with a merge commit | 0 | false | allow |

- **`git rev-list --count main..documentationandmemories == 0` alone is wrong.** It is 0 in state
  C as well as in A and B, so it would permanently block the legitimate post-merge cleanup the
  skill relies on (`.claude/skills/cleanup-merged-worktrees/SKILL.md:113-117`).
- **Tip equality is correct for the state the AC names.** It blocks A, allows C, and — as a
  read-only comparison of two SHAs — cannot fabricate a verdict.
- **Neither form distinguishes B from C**, because after a merge-commit merge the consolidation
  branch is strictly behind `main` with zero commits ahead, which is exactly state B's shape.
  Ancestry alone cannot separate them; separating them would require persisting the branch's
  creation point.

**Recommendation: tip equality only**, implemented as a pre-check inside
`verify_consolidation_merged` before the fetch:

```bash
	tip_branch=$(cleanup_wt_git rev-parse "$CLEANUP_WT_CONSOLIDATION_BRANCH") || rc=$?
	tip_main=$(cleanup_wt_git rev-parse main) || rc=$?
	# a hard rev-parse failure -> ANCESTRY_ERROR / return 2 (fail closed)
	# tip_branch == tip_main -> NOT_ANCESTOR / return 1
```

Rationale for the plain `rev-parse <ref>` form over `rev-parse <ref>^{commit}`: a branch ref
already resolves to a commit OID, and the plain form maps to the stub keys `rev-parse.main` and
`rev-parse.documentationandmemories`, whereas `main^{commit}` sanitizes to the awkward
`rev-parse.main__commit_`. The `rev-parse.main` key is shared with `check_main_freshness`
(`cleanup_worktrees_enumerate_lib.sh:230`); that is harmless because `check_main_freshness` also
needs `rev-parse.origin_main`, and with that key absent the stub returns empty output and the
`[[ -n $origin_sha ]]` guard at `:232` suppresses the `WARN` line.

Residual state B is documented, not fixed, for two reasons: it is indistinguishable from state C
by ancestry, and the only version of it that risks real content loss — a consolidation worktree
holding staged or untracked consolidated files — is already blocked by the non-forced
`git worktree remove` and the `BLOCKED-DIRTY` path (§5.1). A clean, zero-commit consolidation
worktree that is deleted loses nothing that `create_consolidation_worktree` cannot recreate.

**AC6 is satisfied with zero change to `run_apply`.** With the pre-check returning `NOT_ANCESTOR`,
`vout` at `cleanup_worktrees_actions_lib.sh:354` is not `MERGED_CLEAN`, `consolidation_ok` stays 1
(`:351`), and the guard at `:360` fires, emitting exactly
`ACTION|delete|documentationandmemories|BLOCKED-CONSOLIDATION-UNMERGED` and `continue`-ing past
`classify_branch` and `delete_candidate`. The consolidation worktree is branch-backed, so it is
also not reachable through the new detached path.

**Rejected alternative:** "refuse apply mode while the consolidation worktree exists with no
commits" (the second option in gap 6). Implemented as
`rev-list --count main..dm == 0 && <a worktree registration for dm exists>`, it would additionally
block state B — but the consolidation worktree also still exists in state C, so it would block the
documented post-merge cleanup in the same pass, contradicting
`.claude/skills/cleanup-merged-worktrees/SKILL.md:113-117`. The cost (a broken documented workflow
step every run) exceeds the benefit (covering a state whose harmful variant is already covered by
the dirty guard).

---

## 8. Test seam: the git stub, key derivation, and required fixtures

### 8.1 Wiring

- **`CLEANUP_WT_GIT_BIN`** is read by `cleanup_wt_git`
  (`scripts/bash/cleanup_worktrees_enumerate_lib.sh:34-57`), specifically at `:45`
  (`local override=${CLEANUP_WT_GIT_BIN:-}`) and validated at `:47`
  (`if [[ -n $override && -x $override ]]`). An empty or non-executable value silently falls back
  to `command -v git` (`:50`); no resolvable binary returns 127 (`:52-55`). Pinned by
  `tests/shell/test_cleanup_worktrees_enumeration.bats:51-71`.
- **`CLEANUP_WT_STUB_SCENARIO`** is read by the stub at
  `tests/fixtures/cleanup_worktrees/stub-bin/git:47` (`scenario=${CLEANUP_WT_STUB_SCENARIO:-}`).
- Both are documented in the CLI help at `scripts/bash/cleanup-worktrees.sh:48-52`.

### 8.2 Stub behaviour, end to end

`tests/fixtures/cleanup_worktrees/stub-bin/git` is 208 lines. Reading it in order:

- `:42` `set -uo pipefail` (no `-e`).
- `:45` `printf 'stub-git: %s\n' "$*" >&2` — **the full argv is logged to stderr before any option
  stripping**, so `-C <path>` and every flag appear in the log. Under bats `run`, stderr merges
  into `$output`; the suites that want stdout only redirect stderr away
  (`tests/shell/test_cleanup_worktrees_classification.bats:21`).
- `:49-53` `sanitize()` — `printf '%s' "${s//[^A-Za-z0-9._-]/_}"`; every character outside
  `[A-Za-z0-9._-]` becomes `_`.
- `:55-69` `respond()` — `cat "$scenario/$key.out"` when present, exit `$(cat "$scenario/$key.rc")`
  when present, otherwise empty stdout and exit 0. With no scenario set, empty and 0.
- `:71-93` strips leading `-C <path>` and `-c <name>=<value>` global options, retaining the last
  `-C` value in `dash_c_path`.
- `:96-208` dispatches on the subcommand.

### 8.3 KEY derivation, per subcommand actually used

| Invocation | KEY | Notes |
|---|---|---|
| `for-each-ref --format=... refs/heads/` | `for-each-ref` | `:97-99`. One key per scenario. |
| `worktree list --porcelain` | `worktree-list` | `:102`. One key per scenario. |
| `worktree add ...` | `worktree-add` | `:103`. |
| `worktree remove <path>` | `worktree-remove` | `:104`. **Path-independent** — see §8.4. |
| anything else under `worktree` (e.g. `prune`) | none | `:105` `*) exit 0` — no output file, but the argv is still logged at `:45`. |
| `merge-base --is-ancestor <tip> main` | `merge-base.<sanitize tip>` | `:108-114`. |
| `rev-list ... main..<x>` | `rev-list.<sanitize x>` | `:115-123`, keyed on the text after the last `..`. |
| `diff --quiet main...<x>` | `diff-quiet.<sanitize x>` | `:124-142`. |
| `cherry main <x>` | `cherry.<sanitize x>` | `:143-146`, `${3:-}`. |
| `diff-tree ... <sha>` | `diff-tree.<sanitize sha>` | `:147-152`, last argument. |
| `ls-tree <ref> -- <path>` | `ls-tree.<sanitize ref>_<sanitize path>` | `:153-166`. |
| `rev-parse --abbrev-ref HEAD` | `rev-parse.abbrev-ref-HEAD` | `:168-169`. |
| `rev-parse --show-toplevel` | `rev-parse.show-toplevel` | `:170-171`. |
| `rev-parse --verify --quiet <ref>` | `rev-parse.verify.<sanitize ref>` | `:172-173`. |
| `rev-parse <rev>` | `rev-parse.<sanitize rev>` | `:174-175`. Covers both `main` and `<sha>:<path>`. |
| `-C <path> status --porcelain` | `status.<sanitize path>` | `:178-183`. |
| `branch -D <name>` | `branch-D.<sanitize name>` | `:196-201`. |
| `fetch ...` | `fetch` | `:202-204`. |

Worked sanitization examples for the new fixtures: `/repo-wt/det` -> `_repo-wt_det`;
`fb30a9a5` -> `fb30a9a5` (unchanged); `refs/heads/documentationandmemories` ->
`refs_heads_documentationandmemories`.

### 8.4 Hard constraint: `worktree-remove` is a single per-scenario key

Because `:104` keys on the subcommand alone, **a scenario cannot have one removal succeed and
another fail**. Every new scenario must contain at most one worktree whose removal is attempted
with a distinct expected rc. This forces one scenario per removal outcome and is the single most
important constraint on the test design in §Test Design. The same applies to `worktree-list`,
`for-each-ref`, `worktree-add`, and `fetch`.

### 8.5 Asserting `--force` never appeared and `prune` was never invoked

Both are assertions over the merged `$output` produced by the `stub-git:` argv log:

```bash
[[ "$output" != *"--force"* ]]
[[ "$output" != *"worktree prune"* ]]
```

The first form is already in use at `tests/shell/test_cleanup_worktrees_deletion.bats:31`. The
second does not exist anywhere in `tests/shell/` today and must be added; it is meaningful because
the stub logs at `:45` before the dispatch, so an unhandled `worktree prune` would still appear in
`$output` even though `:105` produces no output.

For these assertions to work, the helper must **not** discard stderr. Compare
`tests/shell/test_cleanup_worktrees_deletion.bats:21-24` (keeps stderr; argv assertions work)
against `tests/shell/test_cleanup_worktrees_classification.bats:20-22` (discards stderr; stdout
report lines only). New apply-mode cases must use the deletion-suite helper shape.

### 8.6 Two existing scenario directories enumerated in full, as worked models

**Model A — `tests/fixtures/cleanup_worktrees/scenarios/merged_with_worktree/` (5 files).**

| File | Content |
|---|---|
| `worktree-list.out` | `worktree /repo/main` / `HEAD aaaa0000` / `branch refs/heads/main` / blank / `worktree /repo-wt/feat` / `HEAD bbbb2222` / `branch refs/heads/feature-wt` / blank |
| `for-each-ref.out` | `feature-wt bbbb2222` / `main aaaa0000` |
| `merge-base.feature-wt.rc` | `0` |
| `rev-parse.abbrev-ref-HEAD.out` | `main` |
| `rev-parse.show-toplevel.out` | `/repo/main` |

Absent keys default to empty output and exit 0, which is what makes this scenario work:
`merge-base.main` is absent, so `merge-base --is-ancestor main main` exits 0 — but `main` is
already `PROTECTED_CURRENT` via `protected-branch|main`, so it is never a candidate.
`worktree-remove.rc` is absent, so the removal in apply mode exits 0 and yields
`ACTION|worktree-remove|/repo-wt/feat|OK` (asserted at
`tests/shell/test_cleanup_worktrees_cli.bats:45`).

**Model B — `tests/fixtures/cleanup_worktrees/scenarios/dirty_worktree/` (7 files).**

| File | Content |
|---|---|
| `worktree-list.out` | `worktree /repo/main` / `HEAD aaaa0000` / `branch refs/heads/main` / blank / `worktree /repo-wt/dirty` / `HEAD dddd9999` / `branch refs/heads/feature-dirty` / blank |
| `for-each-ref.out` | `feature-dirty dddd9999` / `main aaaa0000` |
| `merge-base.feature-dirty.rc` | `0` |
| `rev-parse.abbrev-ref-HEAD.out` | `main` |
| `rev-parse.show-toplevel.out` | `/repo/main` |
| `status._repo-wt_dirty.out` | `?? untracked-artifact.txt` |
| `worktree-remove.rc` | `1` |

This is the exact shape a dirty-detached scenario must mirror, with the branch stanza replaced by
a detached stanza and `for-each-ref.out` reduced to `main aaaa0000` alone.

### 8.7 New scenario directories, by exact relative path

All paths are relative to the repository root. Every scenario that drives `run_report` or
`run_apply` needs `worktree-list.out`, `for-each-ref.out`, `rev-parse.abbrev-ref-HEAD.out`, and
`rev-parse.show-toplevel.out` at minimum, because `compute_protected` and `enumerate_branches` run
unconditionally.

**(a) Merged detached worktree — removed.**
`tests/fixtures/cleanup_worktrees/scenarios/detached_merged/`
- `worktree-list.out` — main stanza + `worktree /repo-wt/det` / `HEAD det00001` / `detached`
- `for-each-ref.out` — `main aaaa0000`
- `merge-base.det00001.rc` — `0`
- `rev-parse.abbrev-ref-HEAD.out` — `main`
- `rev-parse.show-toplevel.out` — `/repo/main`
- (no `worktree-remove.rc`; absence means exit 0 -> `ACTION|worktree-remove|/repo-wt/det|OK`)

**(b) Unmerged detached worktree — no-op.**
`tests/fixtures/cleanup_worktrees/scenarios/detached_unmerged/`
- `worktree-list.out` — main stanza + `worktree /repo-wt/det` / `HEAD det00002` / `detached`
- `for-each-ref.out` — `main aaaa0000`
- `merge-base.det00002.rc` — `1`
- `diff-quiet.det00002.rc` — `1`
- `cherry.det00002.out` — `+ det00002`
- `diff-tree.det00002.out` — `M\tsrc/app.py` (non-empty, so the commit is a real residual)
- `rev-parse.det00002_src_app.py.out` — `blobA`
- `rev-parse.main_src_app.py.out` — `blobB`
- `rev-parse.abbrev-ref-HEAD.out` — `main`
- `rev-parse.show-toplevel.out` — `/repo/main`

**(c) Dirty merged detached worktree — `BLOCKED-DIRTY`, no force.**
`tests/fixtures/cleanup_worktrees/scenarios/detached_merged_dirty/`
- `worktree-list.out` — main stanza + `worktree /repo-wt/det` / `HEAD det00003` / `detached`
- `for-each-ref.out` — `main aaaa0000`
- `merge-base.det00003.rc` — `0`
- `worktree-remove.rc` — `1`
- `status._repo-wt_det.out` — `?? untracked-artifact.txt`
- `rev-parse.abbrev-ref-HEAD.out` — `main`
- `rev-parse.show-toplevel.out` — `/repo/main`

**(d) Locked detached worktree — `BLOCKED-LOCKED`, no `git worktree remove` at all.**
`tests/fixtures/cleanup_worktrees/scenarios/detached_locked/`
- `worktree-list.out` — main stanza + `worktree /repo-wt/det` / `HEAD det00004` / `detached` /
  `locked in use by another session`
- `for-each-ref.out` — `main aaaa0000`
- `merge-base.det00004.rc` — `0`
- `rev-parse.abbrev-ref-HEAD.out` — `main`
- `rev-parse.show-toplevel.out` — `/repo/main`
- (no `worktree-remove.rc`: the assertion is that `worktree remove` never appears in the argv log,
  so the key must be irrelevant)

**(e) Caller's own detached worktree — `PROTECTED_CURRENT`, never removed.**
`tests/fixtures/cleanup_worktrees/scenarios/detached_current/`
- `worktree-list.out` — main stanza + `worktree /repo-wt/current` / `HEAD det00005` / `detached`
- `for-each-ref.out` — `main aaaa0000`
- `rev-parse.abbrev-ref-HEAD.out` — `HEAD` (the detached-caller signal;
  `cleanup_worktrees_enumerate_lib.sh:196` suppresses the `protected-branch` line)
- `rev-parse.show-toplevel.out` — `/repo-wt/current`
- (no `merge-base.det00005.rc`: protection must short-circuit before the ancestry rung, and the
  test asserts `merge-base --is-ancestor det00005` never appears in the argv log)

**(f) Zero-commit consolidation branch — never deleted.**
`tests/fixtures/cleanup_worktrees/deletion/consolidated_zero_commit/`
- `worktree-list.out` — main stanza + `worktree /repo-wt/dm` / `HEAD aaaa0000` /
  `branch refs/heads/documentationandmemories`
- `for-each-ref.out` — `documentationandmemories aaaa0000` / `main aaaa0000`
- `rev-parse.verify.refs_heads_documentationandmemories.out` — `aaaa0000`
- `rev-parse.verify.refs_heads_documentationandmemories.rc` — `0`
- `rev-parse.documentationandmemories.out` — `aaaa0000`
- `rev-parse.main.out` — `aaaa0000`
- `merge-base.documentationandmemories.rc` — `0` (the pre-fix ancestry answer; the new tip-equality
  pre-check must win before it is consulted)
- `rev-parse.abbrev-ref-HEAD.out` — `main`
- `rev-parse.show-toplevel.out` — `/repo/main`

The `deletion/` sub-tree is chosen over `scenarios/` for (f) to match the existing placement of
`consolidated_merged` and `consolidated_unmerged` and the `DEL` variable at
`tests/shell/test_cleanup_worktrees_deletion.bats:17`.

**(g) Hard classification failure on a detached HEAD (AC5).**
`tests/fixtures/cleanup_worktrees/scenarios/detached_ancestry_error/`
- `worktree-list.out` — main stanza + `worktree /repo-wt/det` / `HEAD det00006` / `detached`
- `for-each-ref.out` — `main aaaa0000`
- `merge-base.det00006.rc` — `128`
- `rev-parse.abbrev-ref-HEAD.out` — `main`
- `rev-parse.show-toplevel.out` — `/repo/main`

**(h) Prunable detached worktree — report-only, no removal, no prune.**
`tests/fixtures/cleanup_worktrees/scenarios/detached_prunable/`
- `worktree-list.out` — main stanza + `worktree /repo-wt/det` / `HEAD det00007` / `detached` /
  `prunable gitdir file points to a non-existent location`
- `for-each-ref.out` — `main aaaa0000`
- `merge-base.det00007.rc` — `0`
- `rev-parse.abbrev-ref-HEAD.out` — `main`
- `rev-parse.show-toplevel.out` — `/repo/main`

---

## 9. File-size and collision constraints

### 9.1 Current exact line counts

Counted by reading each file in this pass; the number is the last numbered line reported by the
reader.

| File | Lines | Cap headroom |
|---|---|---|
| `scripts/bash/cleanup_worktrees_lib.sh` | 479 | 21 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 382 | 118 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 236 | 264 |
| `scripts/bash/cleanup-worktrees.sh` | 92 | 408 |
| `scripts/bash/shell-qc.sh` (not touched) | 103 | 397 |
| `scripts/bash/shell_qc_lib.sh` (not touched) | 379 | 121 |

`.claude/skills/cleanup-merged-worktrees/SKILL.md` is 265 lines (Markdown; exempt from the cap per
`.claude/rules/general-code-change.md`).

21 lines of headroom in `cleanup_worktrees_lib.sh` is the binding constraint and confirms the
issue's own conclusion (`issue.md:75`): the detached function group must live in a new file.

### 9.2 Proposed new file

`scripts/bash/cleanup_worktrees_detached_lib.sh` — the detached-worktree function group. Six
functions (signatures and responsibilities in `## Proposed Design`). Estimated 170-220 lines
including the header contract comment, well inside the cap.

**Sourcing point.** `scripts/bash/cleanup-worktrees.sh` currently sources three libraries at
lines 16-24. The new file calls `remove_worktree_safe` (actions lib) and the ladder rungs
(classification lib), so it must be sourced **last**:

```bash
# shellcheck source=scripts/bash/cleanup_worktrees_actions_lib.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/cleanup_worktrees_actions_lib.sh"
# shellcheck source=scripts/bash/cleanup_worktrees_detached_lib.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/cleanup_worktrees_detached_lib.sh"
```

Bash resolves function names at call time, so `run_report` (defined in the classification lib) may
call a function defined in the later-sourced file. The bats helpers must be updated accordingly
(§4.4).

### 9.3 Minimal hunks in existing files

**Hunk 1 — `scripts/bash/cleanup_worktrees_lib.sh:465-469`** (report-mode emission). Current:

```bash
	while IFS= read -r record; do
		[[ -z $record ]] && continue
		IFS='|' read -r wpath _ wbranch wflags <<<"$record"
		printf 'WORKTREE|%s|%s|%s\n' "$wpath" "$wbranch" "$wflags"
	done <<<"$wlout"
```

Add one skip line inside the loop and one call after it. Three added lines total; the existing
lines are untouched.

**Hunk 2 — `scripts/bash/cleanup_worktrees_lib.sh:40-50`** (header comment contract). Add one
line documenting `WORKTREE|<path>|DETACHED|<state>|<flags>` beside the existing line 43. Comment
only.

**Hunk 3 — `scripts/bash/cleanup_worktrees_actions_lib.sh:343-348`** (apply-mode emission).
Current:

```bash
	while IFS= read -r record; do
		[[ -z $record ]] && continue
		IFS='|' read -r wpath _ wbranch wflags <<<"$record"
		printf 'WORKTREE|%s|%s|%s\n' "$wpath" "$wbranch" "$wflags"
		[[ -n $wbranch && $wbranch != DETACHED ]] && wt_of[$wbranch]=$wpath
	done <<<"$wlout"
```

Same shape as hunk 1: one skip line inside the loop, one `apply_detached_worktrees "$wlout" || rc=1`
call after it. Note the loop's `[[ ... ]] && ...` at `:347` is the last command in the loop body;
inserting a `continue` before the `printf` keeps that expression's exit status out of the loop's
final status, so no `set -e` interaction is introduced.

**Hunk 4 — `scripts/bash/cleanup_worktrees_actions_lib.sh:204-206`** (the tip-equality pre-check).
Current:

```bash
	local mrc=0
	cleanup_wt_git fetch origin main >/dev/null 2>&1 || true
	cleanup_wt_git merge-base --is-ancestor "$CLEANUP_WT_CONSOLIDATION_BRANCH" main >/dev/null 2>&1 || mrc=$?
```

Insert the two guarded `rev-parse` captures and the equality test between `:204` and `:205`
(before the fetch, so no network call is made in the blocked case). Roughly 12 added lines,
entirely inside `verify_consolidation_merged`.

**Hunk 5 — `scripts/bash/cleanup-worktrees.sh:22-24`** — the new source block (3 added lines).

**Hunk 6 — `scripts/bash/cleanup-worktrees.sh:42-45`** — the report-lines paragraph in `usage()`,
required by AC7. One modified line.

**Hunk 7 — `.claude/skills/cleanup-merged-worktrees/SKILL.md:66`** plus a short addition to the
apply-mode workflow step at `:113-120` and the `BLOCKED-LOCKED` result. Mirrored per §10.

### 9.4 Collision analysis against concurrent siblings

| Sibling | Shared region | Collision risk | Mitigation |
|---|---|---|---|
| Child B (901, report-mode records) | `run_report` (`cleanup_worktrees_lib.sh:445-479`); the header contract comment; `SKILL.md:57-71` | Real but small | A's insert is a single call appended after the WORKTREE loop; B's are new emission blocks in the same function. Textual conflict resolves by concatenation. Both add bullets to the same SKILL.md list. |
| Child C (902, dirt classifier) | `remove_worktree_safe` (`cleanup_worktrees_actions_lib.sh:252-279`); report-mode `DIRTY\|` emission | None if the §5.3 boundary holds | A never edits `remove_worktree_safe` and emits no `DIRTY\|` line. A owns `BLOCKED-LOCKED` in the new file only. |
| Child F (904, `PRESERVE` consolidation) | `verify_consolidation_merged`, `cherry_pick_candidates` | Low | A's hunk 4 is confined to the first three statements of `verify_consolidation_merged`; F's work is in the cherry-pick and staging path. |
| Child D (903) / G (905) / E (545) / H (906) | none in `scripts/bash/` | None | Different surfaces. |

The epic's own reasoning (`docs/features/epics/cleanup-merged-worktrees-hardening/epic.md:143-147`)
already anticipates this: no dependency edge among A, B, C, F, with separation-by-new-file as the
mechanism. This research confirms that A can be delivered with four small hunks in two shared
files, all of them additive.

---

## 10. Push-down mirror

**The skill has a mirror; the bash scripts do not.**

- Mirror path (verified present):
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  (contract text at line 66, matching the root file).
- A search of the entire bundled root for `cleanup-worktrees`/`cleanup_worktrees` returns exactly
  one file — that SKILL.md. There is no bundled copy of `scripts/bash/cleanup_worktrees_*.sh` or
  `scripts/bash/cleanup-worktrees.sh`, and the six pack manifests under
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/` contain no `scripts/bash`
  reference. `.claude/lib/bash/` holds only the eleven `parallel-*`/`compute-*`/`report-*` files,
  none of them cleanup-worktrees.
- The governing test is
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  (lines 106-131). It enumerates every repo `.claude/**` file except `settings.local.json` and
  `.claude/agent-memory/**` (`:118-122`) and asserts both presence in the bundle (`:125-127`) and
  `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)` (`:128-131`).
- **Precise characterization of "byte-identical":** this test uses `Path.read_text(encoding="utf-8")`
  (`:51-54`), i.e. Python text mode with universal-newline translation, so it is a *content*
  comparison after newline normalization, not a raw byte comparison. The stricter
  `read_bytes()` comparison at `:134-144` applies only to the three
  `PLANNER_REVIEW_RESOURCE_PATHS`, which do not include this skill. In practice the mirror must be
  written with the same content; a CRLF/LF divergence would pass this particular test but should
  still be avoided.

Consequence for the plan: exactly one mirror copy is required, and it is a documentation file. No
bash change needs mirroring.

---

## 11. Toolchain

Verified by reading `scripts/bash/shell-qc.sh` and `scripts/bash/shell_qc_lib.sh`; no WSL
invocation was performed in this pass.

### 11.1 Commands

`.claude/rules/shell.md:17-32` and `scripts/bash/shell-qc.sh:19-27` agree on the three commands:

- `bash scripts/bash/shell-qc.sh format` -> `run_format` (`shell_qc_lib.sh:204-224`), `shfmt -w`
  over the discovered file list (`:222`).
- `bash scripts/bash/shell-qc.sh check` -> `run_check` (`shell_qc_lib.sh:164-202`), `shfmt -d` once
  over the full list (`:188`) then `shellcheck` once per file (`:194-200`), returning the maximum
  exit code.
- `bash scripts/bash/shell-qc.sh test [--coverage]` -> `run_test` (`:226-254`) or
  `run_test_coverage` (`:294-379`).

These are the correct commands. There is no separate type-check stage for bash
(`.claude/rules/shell.md:26-27`).

### 11.2 Coverage headline literal

`scripts/bash/shell_qc_lib.sh:291`:

```bash
	printf 'Bash coverage (lines): %s%%\n' "$percent"
```

with `percent` formatted to one decimal at `:290` (`awk -v r="$rate" 'BEGIN { printf "%.1f", r * 100 }'`).
The exact literal is therefore `Bash coverage (lines): NN.N%`, printed only when the run succeeded
and `cov.xml` parsed (`:374-377`). Pinned as an exact-equality assertion at
`tests/shell/test_shell_qc_commands.bats:144`: `[ "$output" = "Bash coverage (lines): 75.0%" ]`.

### 11.3 Where kcov output lands

`SHELL_QC_KCOV_OUT_DIR`, default `artifacts/pester/kcov`, resolved against `pwd` when relative
(`shell_qc_lib.sh:322-327`); wiped and recreated (`:329-330`). Per-directory runs go to
`<out>/.kcov_runs/<dir>` (`:331`, `:341`) and are always removed (`:373`).
`kcov --merge` writes `<out>/kcov-merged/cov.xml`, which is copied to `<out>/cov.xml`
(`:365-370`). The include pattern is `$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash`
and the exclude pattern is `$repo_root/tests` (`:335-336`), so
`scripts/bash/cleanup_worktrees_detached_lib.sh` **is** in the coverage denominator and its lines
must be exercised.

### 11.4 Most recent recorded bash coverage number

`docs/features/active/2026-08-29-remove-remaining-python-invocations-599/evidence/qa-gates/final-bash-coverage.2026-08-30T20-45.md:19`
records `Bash coverage (lines): 92.3%`. Earlier recorded values on the same feature: 91.4%
(baseline, `evidence/baseline/bash-coverage.2026-08-30T06-22.md:13`) and 91.8%
(`evidence/regression-testing/bash-full-suite.2026-08-30T07-55.md:73`). The 92.3% figure is the
most recent in the repository and is the reference point against which AC8's >= 85% floor should
be read.

### 11.5 Success-case output literals for `format` and `check`

**Both print nothing on a clean run.** This is a verified negative, not an omission:

- `run_check` (`shell_qc_lib.sh:164-202`) has exactly two `printf` statements of its own — the
  no-scripts message at `:174` and the missing-tool block via `:179`/`:183`. On a clean run neither
  fires; `shfmt -d` emits a diff only when a file differs, and `shellcheck` emits findings only.
  Stdout and stderr are empty, exit code 0.
- `run_format` (`shell_qc_lib.sh:204-224`) likewise has only the no-scripts message (`:214`) and
  the missing-tool block (`:218`). `shfmt -w` rewrites in place and prints nothing.

So the honest literal for both is the empty string, and — exactly as the delegation prompt
anticipates — the exit code alone is not an observation of "nothing was rewritten". Two assertable
substitutes, both grounded in what these commands actually do:

1. **For `format`:** run it, then observe `git status --porcelain -- scripts/bash tools .claude/lib/bash tests`.
   Empty output proves shfmt rewrote nothing. This is the only direct observation of the
   idempotence claim.
2. **For `check`:** its `shfmt -d` stage is the formatter's own falsifiable form — it prints a
   unified diff when any discovered file is unformatted. Empty `check` output therefore *is* the
   positive evidence that formatting is clean and lint is clean, and it is falsifiable in a way the
   `format` exit code is not.
3. **For `test`:** bats prints a TAP plan (`1..N`) and one `ok N <name>` line per case. That output
   is assertable content: record `N` and confirm no line begins with `not ok`. This is the pattern
   used in the recorded evidence at
   `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/evidence/regression-testing/bash-full-suite.2026-08-30T07-55.md:73-76`.

One discovery note that affects the plan: `discover_shell_scripts` (`shell_qc_lib.sh:75-102`)
searches only `tools/`, `scripts/`, and `.claude/lib/bash/`, and qualifies files by a `.sh` suffix
or a bash/sh shebang. `tests/shell/*.bats` files are therefore **not** discovered by shfmt or
shellcheck. The new bats suite is exercised by `test`, not by `format`/`check`.

---

## 12. Live reproduction

**Tool limitation, stated plainly.** This research session has no shell tool available (the
available tools are Read, Grep, Glob, WebFetch, Write, Edit), so no `git worktree list --porcelain`
or `git merge-base --is-ancestor` probe could be executed. The porcelain shape below is derived
from the git worktree administrative files, which were read directly, plus the verbatim snippet
already captured in the issue.

**Read-only filesystem evidence gathered (no mutation, no `--apply`, no `git worktree prune`):**

- `C:/Users/DanMoisan/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-08-21T17-18/3a9f9b03-f2e5-4fee-a94a-e4f2849de2d5/scratchpad/base-wt/.git`
  contains exactly:
  `gitdir: C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/base-wt`
  — confirming a live, registered worktree of the `drm-copilot` repository (not an orphan
  directory of the kind gap 7 addresses).
- `C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/base-wt/HEAD` contains
  `fb30a9a58b8422e610a09b07361421e97367807a` — a raw object name with **no `ref:` prefix**. That is
  precisely the condition under which `git worktree list --porcelain` emits a `detached` line
  instead of a `branch refs/heads/...` line.
- `C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/base-wt/gitdir` points back to the
  worktree's `.git` file, so the registration is not prunable.
- The administrative directory contains `gitdir`, `commondir`, `HEAD`, `index`, `ORIG_HEAD`, and
  `logs/HEAD`. **There is no `locked` file**, so this worktree is not locked and would carry the
  flags `detached` only.

**Resulting porcelain stanza and parsed record.** The stanza is exactly the three lines already
recorded verbatim at `issue.md:55-57`:

```
worktree C:/Users/DanMoisan/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-08-21T17-18/3a9f9b03-f2e5-4fee-a94a-e4f2849de2d5/scratchpad/base-wt
HEAD fb30a9a58b8422e610a09b07361421e97367807a
detached
```

`parse_worktree_list` maps that to:

```
C:/Users/.../scratchpad/base-wt|fb30a9a58b8422e610a09b07361421e97367807a|DETACHED|detached
```

and `normalize_wt_path` lowercases it (§2.4). Under the current code this record produces exactly
one report line — `WORKTREE|C:/Users/.../base-wt|DETACHED|detached` — and nothing else, which is the
defect. Under the proposed design it produces
`WORKTREE|C:/Users/.../base-wt|DETACHED|MERGED_CLEAN|detached`, given that `fb30a9a5` is an
ancestor of `main` (asserted in `issue.md:26` and consistent with the commit being reachable; the
`merge-base --is-ancestor` probe itself was not run in this session and remains the one claim here
that rests on the issue author's observation rather than on evidence gathered in this pass).

**Fixture fidelity note.** The live stanza has no `locked`/`prunable` line and no reason text, so
the locked and prunable fixtures in §8.7 must take their shape from
`tests/fixtures/cleanup_worktrees/worktree_shapes/worktree-list.out:9-18`, which already carries
both real forms (`locked reason here` and `prunable gitdir file points to a non-existent location`).

---

## Proposed Design

### New file: `scripts/bash/cleanup_worktrees_detached_lib.sh`

Sourcing contract: depends on `cleanup_worktrees_enumerate_lib.sh` (`cleanup_wt_git`,
`parse_worktree_list`, `normalize_wt_path`, `compute_protected`), `cleanup_worktrees_lib.sh` (the
four ladder rungs), and `cleanup_worktrees_actions_lib.sh` (`remove_worktree_safe`). Defines
functions only; runs nothing at source time. Every git-backed read is captured in the parent shell
with `|| rc=$?` and fails closed, matching the guarded-read invariant documented at
`cleanup_worktrees_actions_lib.sh:19-35`.

| Function | Signature | Responsibility |
|---|---|---|
| `is_detached_candidate` | `is_detached_candidate <flags>` | Return 0 iff `flags` contains `detached` and contains neither `main` nor `bare`. The single predicate used by both emission loops and both drivers. No git calls. |
| `classify_detached_head` | `classify_detached_head <head-sha> <worktree-path>` | Echo exactly one state token from the seven-token vocabulary; return 0 normally, 2 on any hard git failure (which always maps to `ANCESTRY_ERROR`). Implements the §1.4 sequence: protection by normalized path, then rungs 1-5. Emits no report line and no `COMMIT` record. |
| `report_detached_worktrees` | `report_detached_worktrees <parse_worktree_list-output>` | For each detached candidate in the given records, call `classify_detached_head` and emit `WORKTREE\|<path>\|DETACHED\|<state>\|<flags>`. Return the maximum classify return code. |
| `reverify_detached_delete_eligible` | `reverify_detached_delete_eligible <head-sha> <worktree-path>` | Same-process re-classification immediately before removal. Return 0 only for `MERGED_CLEAN`/`MERGED_CONTENT_NEUTRAL`/`MERGED_EQUIVALENT`; otherwise emit `ACTION\|worktree-remove\|<path>\|BLOCKED-REVERIFY` and return 1. A hard failure also returns 1. |
| `remove_detached_worktree` | `remove_detached_worktree <worktree-path> <head-sha> <flags>` | Locked -> emit `ACTION\|worktree-remove\|<path>\|BLOCKED-LOCKED`, invoke no git command, return 1. Prunable -> return 0 with no output and no git command (report-only, per `.claude/skills/cleanup-merged-worktrees/SKILL.md:238`). Otherwise `reverify_detached_delete_eligible` then `remove_worktree_safe "$path"`. |
| `apply_detached_worktrees` | `apply_detached_worktrees <parse_worktree_list-output>` | Apply-mode driver. For each detached candidate: classify; on a hard failure set rc=1 and perform no removal; on a delete-eligible state call `remove_detached_worktree` and set rc=1 if it fails; on any other state do nothing and emit nothing. Return rc. |

Ordering inside `remove_detached_worktree` — locked check, then prunable check, then re-verify,
then remove — is deliberate: the locked and prunable checks are pure string tests on the already-read
flags and must precede any git invocation, so AC4's "no `git worktree remove` invocation" for a
locked worktree is observable in the argv log.

### AC-to-design traceability

| AC (from `issue.md:87-95`) | Satisfied by |
|---|---|
| AC1 detached `WORKTREE\|` record with state | `report_detached_worktrees` + hunk 1; state vocabulary from §1.4 |
| AC2 removal without force, `ACTION\|worktree-remove\|<path>\|OK` | `remove_detached_worktree` -> `remove_worktree_safe` (`actions_lib.sh:263-266`), which never passes `--force` (§6.1) |
| AC3 no removal for non-eligible states, main, or the caller's worktree | `apply_detached_worktrees` allowlist; `is_detached_candidate` main/bare exclusion; `classify_detached_head` path protection (§3) |
| AC4 dirty -> `DIRTY\|` + `BLOCKED-DIRTY`; locked -> `BLOCKED-LOCKED`, no git call; prunable -> report-only | `remove_worktree_safe` unchanged (§5.1); new locked and prunable branches in `remove_detached_worktree` |
| AC5 hard failure -> `ANCESTRY_ERROR`, no removal, non-zero apply rc | `classify_detached_head` returns 2; `apply_detached_worktrees` sets rc=1 and skips removal; rc reaches the CLI exit (§6.4) |
| AC6 zero-commit consolidation branch never deleted | hunk 4 tip-equality pre-check in `verify_consolidation_merged`; existing `run_apply:360-363` emits the required ACTION line unchanged (§7.4) |
| AC7 new bats through the stub seam, no temp files | §Test Design; all fixtures checked in under `tests/fixtures/cleanup_worktrees/` |
| AC8 SKILL.md and `--help` document the new record, `BLOCKED-LOCKED`, and the consolidation guard | hunks 6 and 7, plus the mirror in §10 |
| AC9 clean toolchain loop, coverage >= 85%, no file over 500 lines | §11; §9.1 line counts; the new file is in the kcov denominator (§11.3) |

---

## Test Design

All cases use the checked-in stub through `CLEANUP_WT_GIT_BIN` and `CLEANUP_WT_STUB_SCENARIO`. No
temporary files and no scratch repositories, per `.claude/rules/general-unit-test.md` and
`.claude/rules/shell.md:90-93`.

### New suite: `tests/shell/test_cleanup_worktrees_detached.bats`

Helper shape mirrors `tests/shell/test_cleanup_worktrees_deletion.bats:21-24` (stderr retained, so
argv assertions work) and sources all four libraries in dependency order.

| # | Case | Scenario dir | Key assertions |
|---|---|---|---|
| 1 | report emits one detached record with `MERGED_CLEAN` | `scenarios/detached_merged` | `== *"WORKTREE\|/repo-wt/det\|DETACHED\|MERGED_CLEAN"*`; exactly one line starting `WORKTREE\|/repo-wt/det` |
| 2 | report emits `NOT_MERGED` for an unmerged detached HEAD | `scenarios/detached_unmerged` | `== *"WORKTREE\|/repo-wt/det\|DETACHED\|NOT_MERGED"*` |
| 3 | branch-backed records keep the 4-field shape | `scenarios/merged_with_worktree` | `== *"WORKTREE\|/repo-wt/feat\|feature-wt\|"*` (regression guard, must pass before and after) |
| 4 | apply removes a merged detached worktree without force | `scenarios/detached_merged` | `== *"ACTION\|worktree-remove\|/repo-wt/det\|OK"*`; `== *"worktree remove /repo-wt/det"*`; `!= *"--force"*`; `!= *"worktree prune"*` |
| 5 | apply never touches an unmerged detached worktree | `scenarios/detached_unmerged` | `!= *"worktree remove"*`; `!= *"ACTION\|worktree-remove"*` |
| 6 | dirty detached worktree blocks with `DIRTY\|` lines | `scenarios/detached_merged_dirty` | `== *"DIRTY\|/repo-wt/det\|?? untracked-artifact.txt"*`; `== *"ACTION\|worktree-remove\|/repo-wt/det\|BLOCKED-DIRTY"*`; `!= *"--force"*`; status non-zero |
| 7 | locked detached worktree yields `BLOCKED-LOCKED` and invokes no removal | `scenarios/detached_locked` | `== *"ACTION\|worktree-remove\|/repo-wt/det\|BLOCKED-LOCKED"*`; `!= *"worktree remove"*`; `!= *"worktree prune"*` |
| 8 | prunable detached worktree is report-only | `scenarios/detached_prunable` | report shows the record; apply emits no `ACTION\|worktree-remove` for it; `!= *"worktree prune"*`; `!= *"worktree remove"*` |
| 9 | the caller's own detached worktree is `PROTECTED_CURRENT` | `scenarios/detached_current` | `== *"WORKTREE\|/repo-wt/current\|DETACHED\|PROTECTED_CURRENT"*`; `!= *"merge-base --is-ancestor det00005"*`; apply performs no removal |
| 10 | a hard git failure maps to `ANCESTRY_ERROR` with no removal | `scenarios/detached_ancestry_error` | `== *"WORKTREE\|/repo-wt/det\|DETACHED\|ANCESTRY_ERROR"*`; `!= *"worktree remove"*`; `run_apply` status non-zero |
| 11 | `classify_detached_head` unit: merged | `scenarios/detached_merged` | direct call, `[ "$output" = "MERGED_CLEAN" ]` |
| 12 | `classify_detached_head` unit: hard failure returns 2 | `scenarios/detached_ancestry_error` | `[ "$status" -eq 2 ]`, `[ "$output" = "ANCESTRY_ERROR" ]` |
| 13 | `is_detached_candidate` unit: flag matrix | none (pure) | true for `detached`, `detached,locked`, `detached,prunable`; false for `main`, `main,bare`, `main,detached`, `prunable`, empty |
| 14 | `reverify_detached_delete_eligible` blocks on a flipped verdict | `scenarios/detached_unmerged` | `== *"BLOCKED-REVERIFY"*`, status 1, `!= *"worktree remove"*` |

Case 13 is the property-style case that exercises the §2.3 bare/main exclusions, which are the
guard against removing the main worktree.

### Additions to `tests/shell/test_cleanup_worktrees_deletion.bats`

| # | Case | Fixture dir | Key assertions |
|---|---|---|---|
| 15 | a zero-commit consolidation branch is never deleted | `deletion/consolidated_zero_commit` | `== *"ACTION\|delete\|documentationandmemories\|BLOCKED-CONSOLIDATION-UNMERGED"*`; `!= *"branch -D documentationandmemories"*`; `!= *"worktree remove /repo-wt/dm"*` |
| 16 | `verify_consolidation_merged` unit: tip equality yields `NOT_ANCESTOR` | `deletion/consolidated_zero_commit` | `[ "$output" = "NOT_ANCESTOR" ]`, `[ "$status" -eq 1 ]` |
| 17 | regression: a genuinely merged consolidation branch is still deleted | `deletion/consolidated_merged` | existing assertions at `test_cleanup_worktrees_deletion.bats:80-82` must still pass — this is the guard against the over-blocking failure mode described in §7.4 |

Case 17 already exists (`tests/shell/test_cleanup_worktrees_deletion.bats:74-83`); it must be kept
and treated as the pass-before/pass-after regression guard for hunk 4. `deletion/consolidated_merged`
has no `rev-parse.main.out` or `rev-parse.documentationandmemories.out`, so under the stub both
resolve to empty strings — which would compare *equal* and wrongly trigger the new guard. **The fix
must therefore treat an empty rev-parse result as a hard failure** (`ANCESTRY_ERROR`, return 2),
or the two fixture files must be added to `deletion/consolidated_merged` with distinct values. The
first option is the correct fail-closed choice and is recommended; adding
`rev-parse.main.out` = `aaaa0000` and `rev-parse.documentationandmemories.out` = `dm000001` to
`deletion/consolidated_merged` is required regardless so the scenario models reality. This is the
sharpest fixture trap in the change and must be called out in the plan.

### Helper updates to existing suites

- `tests/shell/test_cleanup_worktrees_classification.bats:20-21` and `:25-26`: add the new library
  to the `source` chain in `cb()` and `report()`.
- `tests/shell/test_cleanup_worktrees_hard_failures.bats:26-27`: add the new library to `runin()`.
- `tests/shell/test_cleanup_worktrees_deletion.bats:22-23`: add the new library to `apply()`.
- `tests/shell/test_cleanup_worktrees_enumeration.bats`: no change required; those tests call
  `parse_worktree_list`/`compute_protected` directly and never reach `run_report`.

### Coverage strategy

Every function in the new file is reached by at least one case above: `is_detached_candidate` (13),
`classify_detached_head` (11, 12, and indirectly 1-10), `report_detached_worktrees` (1, 2, 9, 10),
`reverify_detached_delete_eligible` (14, and the success path in 4),
`remove_detached_worktree` (4, 6, 7, 8), `apply_detached_worktrees` (4-10). The hard-failure return
paths are covered by 10 and 12, which is where the uncovered-line risk concentrates in comparable
bash modules.

---

## Numeric Derivation Evidence

Three numeric claims in this artifact could be inherited by a `spec.md` acceptance criterion. Each
is derived twice, by distinct strategies, with the member sets compared.

### N1. Number of `WORKTREE|` emission sites in the production tool: 2

- **Complete Family:** every statement in `scripts/bash/` that writes a line beginning `WORKTREE|`
  to stdout, in any of the four shell files of the cleanup-worktrees tool, regardless of which
  printf/echo form is used.
- **Exhaustive Search Scope:** the whole repository, then narrowed to `scripts/bash/`; all four
  files (`cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`,
  `cleanup_worktrees_enumerate_lib.sh`, `cleanup-worktrees.sh`).
- **Inclusion Rules:** executable statements that emit the record.
- **Exclusion Rules:** comment lines documenting the contract; help text; test assertions; the
  bundled SKILL.md mirror.
- **Primary Search Strategy or Query Expression:** repository-wide content search for the literal
  `WORKTREE|` with `docs/**` excluded, then classification of each hit as executable or comment.
- **Primary Member Set:** `scripts/bash/cleanup_worktrees_lib.sh:468`,
  `scripts/bash/cleanup_worktrees_actions_lib.sh:346`. (Non-members returned by the same search and
  excluded by rule: `cleanup_worktrees_lib.sh:43` comment; `cleanup-worktrees.sh:44` help text;
  seven `tests/shell/*.bats` assertions; two SKILL.md bullets.)
- **Primary Count:** 2
- **Cross-check Search Strategy or Query Expression:** a different query shape — a regex over
  `scripts/bash/` for `printf '(ACTION|BRANCH|COMMIT|WORKTREE|DIRTY|WARN)`, which enumerates every
  report-record printf of any kind in the tool rather than searching for one token. The `WORKTREE`
  alternation branch of that result is then isolated.
- **Cross-check Member Set:** `scripts/bash/cleanup_worktrees_lib.sh:468`,
  `scripts/bash/cleanup_worktrees_actions_lib.sh:346`.
- **Cross-check Count:** 2
- **Member-set Comparison:** normalized to `<file>:<line>` pairs, the two sets are identical:
  `{cleanup_worktrees_lib.sh:468, cleanup_worktrees_actions_lib.sh:346}`. The cross-check query is
  strictly broader in family (all six record types, all printf forms) and still returns the same
  two `WORKTREE` members, so the family is exhaustively covered. Counts agree.

### N2. Distinct `ACTION|` result tokens emitted today: 7, and `BLOCKED-LOCKED` is not among them

- **Complete Family:** the set of distinct values that can appear in the fourth field of an
  `ACTION|<verb>|<target>|<result>` record emitted by any function in `scripts/bash/`, across every
  verb (`worktree-add`, `worktree-remove`, `branch-delete`, `cherry-pick`, `cherry-pick-skip`,
  `delete`).
- **Exhaustive Search Scope:** all four cleanup-worktrees files in `scripts/bash/`.
- **Inclusion Rules:** result values in executable emission statements.
- **Exclusion Rules:** the same values appearing in docstrings, help text, or tests.
- **Primary Search Strategy or Query Expression:** literal search for `ACTION|` across
  `scripts/bash/`, then reading the fourth field of every executable hit.
- **Primary Member Set:** `OK` (actions_lib 99, 143, 150, 184, 191, 265, 290); `FAILED`
  (96, 180, 186, 193, 292); `SKIPPED-BRANCH` (130); `CONFLICT` (158); `BLOCKED-REVERIFY` (233, 246);
  `BLOCKED-DIRTY` (277); `BLOCKED-CONSOLIDATION-UNMERGED` (361).
- **Primary Count:** 7 distinct tokens over 21 emission sites.
- **Cross-check Search Strategy or Query Expression:** an independent regex over `scripts/bash/`
  for `printf '(ACTION|BRANCH|COMMIT|WORKTREE|DIRTY|WARN)` — a whole-record-family enumeration
  rather than a token search — combined with a separate targeted search for the literal
  `BLOCKED-LOCKED` (and, in the same query, `--force` and `worktree prune`).
- **Cross-check Member Set:** the `ACTION` branch of the record-family regex returns exactly the
  same 21 lines (actions_lib 96, 99, 130, 143, 150, 158, 180, 184, 186, 191, 193, 233, 246, 265,
  277, 290, 292, 361 plus the three non-ACTION records at 149, 157, 274 which are excluded), giving
  the same seven tokens. The targeted `BLOCKED-LOCKED|worktree prune|--force` search over
  `scripts/bash/` returns **no matches**.
- **Cross-check Count:** 7 distinct tokens; 0 occurrences of `BLOCKED-LOCKED`.
- **Member-set Comparison:** the normalized token sets are identical:
  `{OK, FAILED, SKIPPED-BRANCH, CONFLICT, BLOCKED-REVERIFY, BLOCKED-DIRTY,
  BLOCKED-CONSOLIDATION-UNMERGED}`. `BLOCKED-LOCKED` is absent from both, independently confirmed
  by the dedicated zero-match search. The assertion "`BLOCKED-LOCKED` must be introduced" is
  therefore supported. The same zero-match result supports "`--force` is never passed" and
  "`git worktree prune` is never invoked" over the whole `scripts/bash/` tree.

### N3. Existing scenario fixture directories under `tests/fixtures/cleanup_worktrees/scenarios/`: 24

- **Complete Family:** every immediate child directory of
  `tests/fixtures/cleanup_worktrees/scenarios/`, including directories that contain only a single
  fixture file.
- **Exhaustive Search Scope:** the full `tests/fixtures/cleanup_worktrees/` tree.
- **Inclusion Rules:** directories directly under `scenarios/`.
- **Exclusion Rules:** the sibling trees `consolidation/`, `deletion/`, `worktree_shapes/`, and
  `stub-bin/`, which are not scenario directories.
- **Primary Search Strategy or Query Expression:** four alphabetically partitioned directory-glob
  queries — `scenarios/{a,b,c,d,e,f,g,h,i,j,k,l}*/*`, `scenarios/{m,n,o,p,q}*/*`,
  `scenarios/{r,s,t,u,v,w,x,y,z}*/*` — which together cover the whole alphabet with no truncation,
  then reduction of the returned file paths to their parent directory names.
- **Primary Member Set:** `ancestry_error`, `cherry_error`, `consolidation_path_empty`,
  `consolidation_path_error`, `content_neutral`, `current_exclusion`, `deleted_path_absent`,
  `deleted_path_on_main`, `diff_tree_error`, `dirty_worktree`, `dirty_worktree_status_error`,
  `enumerate_error`, `ls_tree_error`, `main_divergence`, `merged_no_worktree`,
  `merged_with_worktree`, `preexisting_consolidation_branch`, `residual_namestatus_error`,
  `residual_on_main`, `residual_unique_doc`, `rev_list_error`, `rev_parse_error_protection`,
  `unmerged`, `worktree_list_error`.
- **Primary Count:** 24
- **Cross-check Search Strategy or Query Expression:** a different partition of the same family —
  two extension-scoped globs, `scenarios/**/*.out` and `scenarios/**/*.rc`, which together cover
  every file type present in the tree (only `.out` and `.rc` files exist, per the stub's
  `respond()` contract at `stub-bin/git:55-69`) — then reduction to parent directory names and
  union of the two results.
- **Cross-check Member Set:** the `.rc` glob returned 46 files spanning `ancestry_error`,
  `cherry_error`, `consolidation_path_error`, `content_neutral`, `deleted_path_absent`,
  `deleted_path_on_main`, `diff_tree_error`, `dirty_worktree`, `dirty_worktree_status_error`,
  `enumerate_error`, `ls_tree_error`, `merged_no_worktree`, `merged_with_worktree`,
  `preexisting_consolidation_branch`, `residual_namestatus_error`, `residual_on_main`,
  `residual_unique_doc`, `rev_list_error`, `rev_parse_error_protection`, `unmerged`,
  `worktree_list_error` (21 dirs); the `.out` glob adds `consolidation_path_empty`,
  `current_exclusion`, and `main_divergence`. Union: 24 directories.
- **Cross-check Count:** 24
- **Member-set Comparison:** the normalized directory-name sets are identical; each is the
  24-element set listed above, with no member present in one and absent from the other.
  `residual_namestatus_error` is the only single-file directory (it holds
  `diff-tree.ns000001.rc` alone, because
  `tests/shell/test_cleanup_worktrees_hard_failures.bats:46` calls `classify_residual_commit`
  directly and needs no worktree listing) and it appears in both sets, confirming the extension
  partition did not drop sparse directories.
- **Disagreement with the delegation prompt, recorded:** the prompt stated 27 scenario
  directories. Two independent exhaustive enumerations in this pass return 24. The assertion used
  in this artifact is 24.

---

## Risks and Open Questions

**R1 — The detached record shape needs a spec decision.** AC1 as written specifies four fields
(`WORKTREE|<path>|DETACHED|<state>`), which discards the `locked` and `prunable` flags from report
mode even though AC4 requires distinct apply-mode handling for both. §4.3 recommends the strict
extension `WORKTREE|<path>|DETACHED|<state>|<flags>`. The spec should either adopt the five-field
form explicitly or accept the flag loss and state where a report consumer is meant to learn that a
detached worktree is locked. This is the one open question that changes the wire contract, so it
should be settled before the plan is written.

**R2 — `BLOCKED-LOCKED` is introduced asymmetrically.** This child adds it only on the detached
path. A *branch-backed* locked worktree keeps today's behaviour: `git worktree remove` fails, the
status read runs, and the result is reported as `BLOCKED-DIRTY` even though the cause is a lock.
That mislabel is pre-existing and out of scope here, but it means the two paths will disagree until
some child unifies them. Recommend recording it as a follow-up rather than widening this child.

**R3 — Apply-mode exit codes will change on real checkouts.** Today a dirty or locked detached
worktree contributes nothing to `run_apply`'s return code, because it is never visited. After the
fix, each blocked detached removal sets `rc=1` (§6.4), consistent with branch-backed behaviour but
newly visible: a checkout resembling the 2026-09-06 run would begin exiting non-zero from
`--apply`. The spec should state whether that is intended (recommended: yes, for consistency) so
the change is not later mistaken for a regression.

**R4 — The `consolidated_merged` fixture trap.** As detailed in Test Design case 17, the existing
`deletion/consolidated_merged` scenario has no `rev-parse.main` or
`rev-parse.documentationandmemories` keys, so under the stub both resolve to the empty string and
would compare equal, wrongly triggering the new tip-equality guard and breaking a currently-green
test. The mitigation is twofold and both halves are required: treat an empty rev-parse result as a
hard failure (`ANCESTRY_ERROR`), and add the two fixture files with distinct values.

**R5 — State B of the consolidation guard is documented, not fixed.** A `documentationandmemories`
branch that is strictly behind `main` with zero commits ahead is indistinguishable by ancestry from
the legitimate post-merge state, so the recommended guard does not cover it (§7.4). The harmful
variant — a consolidation worktree holding uncommitted content — is already blocked by the
non-forced removal path. The spec should record this residual explicitly so a later reader does not
read AC6 as broader than what ships.

**R6 — Report-record ordering across detached worktrees.** The detached records are emitted in
`parse_worktree_list` order, which is `git worktree list --porcelain` order. The tool does not
re-sort worktree records today either (unlike branches, which are `LC_ALL=C` sorted at
`cleanup_worktrees_enumerate_lib.sh:82`), so this introduces no new nondeterminism — but it also
does not add the determinism a `LC_ALL=C` sort would. If the spec wants deterministic detached
ordering, it must say so; that is a small addition to `report_detached_worktrees`.

**R7 — Fan-in conflict with child B in `run_report`.** Both children append to the same function
(§9.4). The conflict is textual and resolves by concatenation, but the epic fan-in should expect
it rather than treat it as a merge defect.

**R8 — One claim rests on the issue author's observation, not on evidence from this pass.** That
`fb30a9a5` is an ancestor of `main` (`issue.md:26`, `:37`) could not be re-verified here because no
shell tool was available (§12). Everything else about the live worktree — its registration, its
detached HEAD, its exact SHA, and the absence of a lock — was verified directly from the git
administrative files. The integration check in AC-validation should run the ancestry probe.

---

## Automation Feasibility

**This work is fully automatable. No step requires a human.**

The change surface is bash source, bats test source, and checked-in text fixtures. Every input and
every gate is a local command with deterministic, machine-readable output:

- **Implementation** is text editing of five files (one new library, two library hunks, one CLI
  wrapper, one skill document) plus one mirror copy. No third-party UI, no interactive tool, no
  credential, no network dependency.
- **Test construction** is the creation of eight scenario directories containing 40-odd small text
  files whose names are mechanically derivable from the stub's KEY scheme (§8.3) and whose contents
  are literal porcelain and SHA text. No git repository is created; no temporary file is used.
- **Verification** is `bash scripts/bash/shell-qc.sh format`, `check`, and `test --coverage`,
  all three of which emit machine-checkable output: empty output plus exit 0 for `format`/`check`
  (§11.5), a TAP stream for `test`, and the exact literal `Bash coverage (lines): NN.N%` for
  `--coverage` (§11.2). The mirror parity gate is a pytest case
  (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:106-131`).
- **The one environmental constraint is not a human step.** `bats` and `kcov` are not on the
  Windows PATH; the toolchain runs under WSL Ubuntu
  (`.claude/rules/shell.md:38-39`, epic constraint 4). That is an invocation detail an agent can
  perform (`wsl -d Ubuntu -- bash -lc '...'`), and CI provides an independent path
  (`.github/workflows/_shell-coverage.yml:51-55`). It requires no human judgment.
- **Decisions that look like human input are specification decisions, not execution steps.** R1
  (record shape) and R3 (exit-code semantics) must be settled in `spec.md` before the plan is
  written, but they are settled by writing a specification — an authoring task, not a manual
  operation on a system.

The only genuinely manual activity anywhere near this change is the live-checkout confirmation in
the issue's validation notes (`issue.md:82-83`), which asks that the real `base-wt` registration be
removed by an actual `--apply` run. That is an optional integration confirmation on the developer's
own machine, is not an acceptance criterion, and is not required for any AC in `issue.md:87-95` to
be verified — every AC is verifiable through the stub-driven bats suite.
