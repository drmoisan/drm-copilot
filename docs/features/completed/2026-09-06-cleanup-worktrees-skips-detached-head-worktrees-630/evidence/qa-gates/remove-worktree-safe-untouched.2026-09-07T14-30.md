# QA Gate — `remove_worktree_safe` Untouched (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P7-T10]

Command: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- scripts/bash/cleanup_worktrees_actions_lib.sh | awk '/^[-+]/ && /remove_worktree_safe/ {n++} END {print n+0}'`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

None for the invocation form. [P7-T10] names no `wsl -d Ubuntu -- bash -lc '...'` wrapper;
the command runs natively. The plan's stale worktree path `agent-a06652a3fd875c703` does not
appear in this task's command; it ran in the real worktree `agent-adf4f49cbc48904be`.

## Raw Output

```
0
```

The diff is anchored to the base ref `origin/epic/cleanup-merged-worktrees-hardening-integration`,
so it compares the feature branch against the branch point rather than against ambient index
state. A count of **0** means **no added and no removed line** in
`scripts/bash/cleanup_worktrees_actions_lib.sh` references `remove_worktree_safe`. The
function is consumed by the new detached library as an opaque contract and is not modified,
which is the child-C scope boundary the plan states: the dirt classifier, the `DIRTY|` line
vocabulary, and any edit to `remove_worktree_safe` belong to the concurrent sibling child C
(issue 902, gap 2) and are out of scope here.

## The Two Hunks This Feature Adds to the File

The anchored diff of that file, read with default context, contains exactly two hunks. Their
headers, verbatim:

```
@@ -202,6 +202,26 @@ verify_consolidation_merged() {
@@ -343,9 +363,13 @@ run_apply() {
```

### Hunk 1 — the `verify_consolidation_merged` tip-equality pre-check

- Base-side span: lines **202-207**.
- New-side span: lines **202-227**.
- The insertion point is after base line 204; the 20 added lines occupy new lines
  **205-224**. This is [P5-T1], Hunk 4 of the plan's Implementation Shape.

### Hunk 2 — the apply-mode emission loop

- Base-side span: lines **343-351**.
- New-side span: lines **363-375**.
- Four lines are added in two adjacent groups: the three-line detached-candidate skip at new
  lines **366-368**, inserted after base line 345, and the single
  `apply_detached_worktrees "$wlout" || rc=1` call at new line **372**, inserted after base
  line 348. Default diff context merges the two groups into one hunk. This is [P4-T4],
  Hunk 3 of the plan's Implementation Shape.

Added lines, verbatim, from the same diff read with zero context:

```
@@ -204,0 +205,20 @@ verify_consolidation_merged() {
+	# Tip-equality pre-check, ahead of the best-effort fetch so no network call is made
+	# in the blocked case. A consolidation branch created at main and not yet committed
+	# to has a tip identical to main's; merge-base --is-ancestor answers 0 for that
+	# shape, which would wrongly present a zero-commit branch as delete-eligible. An
+	# empty or unresolvable tip on either side is a HARD FAILURE, never an equality
+	# match: two empty strings compare equal, so treating them as equality would block a
+	# genuinely merged branch. A commit-counting guard was rejected for this check: the
+	# count is also zero after the consolidation PR merges with a merge commit, which
+	# would permanently block the documented post-merge cleanup step.
+	local cons_tip main_tip ctrc=0 mtrc=0
+	cons_tip=$(cleanup_wt_git rev-parse "$CLEANUP_WT_CONSOLIDATION_BRANCH") || ctrc=$?
+	main_tip=$(cleanup_wt_git rev-parse main) || mtrc=$?
+	if ((ctrc != 0)) || ((mtrc != 0)) || [[ -z $cons_tip || -z $main_tip ]]; then
+		printf 'ANCESTRY_ERROR\n'
+		return 2
+	fi
+	if [[ $cons_tip == "$main_tip" ]]; then
+		printf 'NOT_ANCESTOR\n'
+		return 1
+	fi
@@ -345,0 +366,3 @@ run_apply() {
+		# A detached registration is handled by apply_detached_worktrees instead: it
+		# emits that registration's single WORKTREE record and owns its removal decision.
+		is_detached_candidate "$wflags" && continue
@@ -348,0 +372 @@ run_apply() {
+	apply_detached_worktrees "$wlout" || rc=1
```

Neither hunk contains an added or removed line referencing `remove_worktree_safe`, which is
the same fact the `awk` count of 0 reports.

## Relationship to Lines 252-279

`remove_worktree_safe` is defined at line **252** and closes at line **279** in the base
file, so lines 252-279 are exactly its body. Neither hunk falls inside that range:

| Hunk | Base-side span | Inside base 252-279? | New-side span | Inside new 252-279? |
|---|---|---|---|---|
| 1 — `verify_consolidation_merged` pre-check | 202-207 | no; the span ends at 207, which is 45 lines above 252 | 202-227 | no; the span ends at 227 |
| 2 — apply-mode emission loop | 343-351 | no; the span begins at 343, which is 64 lines below 279 | 363-375 | no; the span begins at 363 |

The same conclusion holds under post-change numbering. Hunk 1 inserts 20 lines above the
function, so in the current file `remove_worktree_safe` spans lines **272-299**; hunk 1's
new-side span of 202-227 sits entirely above it and hunk 2's new-side span of 363-375 sits
entirely below it. **Neither hunk intersects the function under either numbering.**

Output Summary: The `awk` stage printed **`0`**: no added or removed line in
`scripts/bash/cleanup_worktrees_actions_lib.sh` references `remove_worktree_safe`, so the
function is untouched by this feature. The file receives exactly **two** hunks — the
`verify_consolidation_merged` tip-equality pre-check at base lines 202-207 (new 202-227) and
the apply-mode emission loop at base lines 343-351 (new 363-375). **Neither falls inside
lines 252-279**, the base-file body of `remove_worktree_safe`, nor inside its post-change
span of 272-299. This is the evidence for the AC11 child-C boundary.
