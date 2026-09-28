# Remediation cycle 2 — preflight round 2 delta

- Plan under review: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/remediation-plan.2026-09-08T06-51.md`
- Reviewer: `atomic-executor` (preflight mode), full-pass validation against the tree at HEAD `02150524` with the plan file uncommitted
- Signal: **PREFLIGHT: REVISIONS REQUIRED**
- Convergence: FURTHER ROUNDS LIKELY
- Counts: 7 blocking, 7 non-blocking

## Rulings carried forward (no action)

All four planner alterations from round 1 are SUSTAINED as design decisions, and all three recorded planner disagreements are SUSTAINED:

- The superset registry, `(id, mutation)` row identity, the eight fixed non-arithmetic sites, 37 markers and 39 rows are all re-derived correct. Lines 311 and 321 do each carry two guards on one physical line. No mandatory id is a prefix of another. The `$`-anchored address plus `(id, mutation)` identity does preserve per-guard attribution on the two shared markers.
- The widened observation channel is sound, and its value is confirmed beyond the plan's own example: R5's `diff-header-skip` under `dirt_build_artifact` changes the `DIRTFILE|` verdict while the `DIRTSUM|` aggregate stays `ALL_DISPOSABLE`, so the aggregate-only channel would have forced it to `ARGV`.
- The D-5 eight-file glob agrees with cycle 1's own coverage evidence, which already tabulates eight rows including `cleanup-worktrees.sh` at 97.44%.
- The D-10 direct invocation of `discover_shell_scripts` matches the formatter's file set exactly, because `is_shell_script` accepts an extensionless file whose shebang resolves to `bash` or `sh`.
- D-1 was wrong to name P4-T4 as carrying guard arithmetic. P4-T3 is the Phase 4 task that does.

What is OVERTURNED is narrower: the claim that the four D-2 mechanical obligations are **sufficient**. Obligations 1, 3 and 5 are sound. Obligations 2 and 4 are not, per B1 and B2 below.

## Blocking defects

### B1 BLOCKING — the `mutation` column is unconstrained for 26 of the 39 rows

Only 13 `(id, mutation)` pairs are fixed by the plan: five remediated guards plus the eight in D2 part two. For the other 26 arithmetic rows P2-T8 lets the executor choose the mutation, and no obligation requires the mutation to touch the guard's semantics. A mutation of the form `s%# guard:foo%#  guard:foo%` changes the library source, passes `bash -n`, leaves both channels byte-identical, and is written `EXEMPT`. All seven of P2-T8's acceptance commands pass and P3-T7 exits 0. A comment change is a source change, so obligation 2 does not exclude it.

Remedy:

1. New P2-T5 invariant 7: every registry row whose `mutation` is not one of the 13 literals this plan fixes MUST be exactly `s/((EXPR))/((0))/` or `s/((EXPR))/((1))/`, where `EXPR` is the arithmetic comparison text the plan's regex matches on that row's marked line in the unmutated library. The test derives `EXPR` from the library and asserts string equality against the registry's mutation column, so an inert mutation cannot be chosen. Verified applicable to all 31 arithmetic lines including the compound lines 311 and 321 and the `&&`-suffixed forms at 207, 208, 210, 211, 213, 333, 387, 388, 414.
2. New P2-T6 assertion between the current 2 and 3: the `diff` between unmutated and mutated sources contains exactly one changed line; that line carries `# guard:<id>`; and the two versions of that line still differ after the trailing `# guard:...` comment is stripped from both. This rejects comment-only and marker-only mutations directly.
3. Reword AC-47 (P4-T3) and the P2-T11 design artifact to state both constraints.

### B2 BLOCKING — obligation 4 is satisfied by a scenario under which the ladder never ran

D3 obligation 4 reads "the unmutated run emitted at least one `DIRTFILE|` record or returned a non-zero exit status", and D3 defines "the run" as spanning both `classify_worktree_dirt` and `clear_disposable_dirt`. For a scenario directory that exists but supplies no `status._repo-wt_dirt.out` — `tests/fixtures/cleanup_worktrees/scenarios/dirty_worktree_status_error/` exists and is keyed to `/repo-wt/dirty` — the stub replays empty stdout and exit 0, `classify_worktree_dirt` returns 0 at `cleanup_worktrees_dirt_lib.sh:373` having emitted nothing, and `clear_disposable_dirt` then prints `ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE` and returns 1. Obligation 4 passes on that non-zero exit with the ladder never having executed. The `dirt_*` restriction lives only in P2-T8's prose; there are 52 non-`dirt_*` directories under `scenarios/`.

Remedy: scope obligation 4 to the classifier call, in D3, in P2-T6 assertion 4, and in AC-47 — "the unmutated `classify_worktree_dirt` call emitted at least one `DIRTFILE|` record, or `classify_worktree_dirt` itself returned a non-zero exit status". Add an eighth P2-T8 acceptance command asserting that

```
awk -F'\t' '!/^#/ && $3 !~ /^dirt_/' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv
```

produces no output.

### B3 BLOCKING — P2-T8's acceptance command 6 cannot pass as ordered

P2-T3 writes registry rows naming `dirt_tracked_probe_error_in_history` and `dirt_build_artifact_empty_diff`, but those directories are created by P3-T3 and P3-T4. P2-T8's command 6 asserts every `scenario` value names an existing directory, so it reports both as MISSING and the task cannot be checked off. The same ordering makes P2-T10's characterisation wrong: at P2-T10 two of the four ids fail on a missing scenario directory (assertion 1) and two on separation (assertion 5), but P2-T10 asserts all four fail on separation.

Remedy, adopt option (a) for lower churn: amend P2-T8's command 6 to exempt exactly those two names, and add the unexempted form of command 6 to P3-T7's acceptance. Amend P2-T10 to state which two ids fail on a missing scenario and which two on separation.

### B4 BLOCKING — nothing requires the harness to accumulate offending ids

P2-T6 says offending ids are printed to stderr before each assertion. A bats test asserting per row aborts at the first failing row, so P2-T10's "the diagnostic names all four" is unsatisfiable.

Remedy: state in P2-T4 and P2-T6 that the helper accumulates offending ids across all rows and makes one assertion per obligation at the end over the accumulated list. Add to P2-T6's acceptance that the per-row loop body contains no `return` and no `exit`.

### B5 BLOCKING — D1's reachability table asserts a reachability the tree contradicts

`dirt_build_artifact_added_file` does not reach rung 4's tracked half. Its entry is `A  src/Legacy/Legacy.csproj`; rung 1's gate is true, but the scenario supplies no `rev-list.HEAD.out` so `staged` is empty and the branch falls through. Rung 3 then resolves it: the worktree diff is absent (0 changed lines, rc 0) and the cached diff carries a single `+      <HintPath>...` line (1 changed line, rc 0), so `total=1`, `((total == 0))` at `:213` does not fire, and `dirt_is_build_artifact` returns 0. The entry resolves `DISPOSABLE_BUILD_ARTIFACT` at `:284` and never issues `diff --quiet main`. Its `diff-quiet` fixture is never read. `test_cleanup_worktrees_dirt_classify.bats:354` pins that verdict.

The correct set of tracked entries reaching rung 4's tracked half is six:

| Scenario | Status entry | `diff-quiet..<path>.rc` | Reaches the new read |
|---|---|---|---|
| `dirt_rename_split` | `R  old.md -> new.md` | no fixture, stub default `0` | yes |
| `dirt_build_artifact_mixed` | `M  src/Legacy/Legacy.csproj` | `1` | no |
| `dirt_build_artifact_plus_content` | `M  src/Legacy/Legacy.csproj` | `1` | no |
| `dirt_staged_tree_no_match` | `M  src/a.cs` | `1` | no |
| `dirt_staged_tree_worktree_delta` | `MM src/a.cs` | `1` | no |
| `dirt_tracked_read_errors` | ` M docs/tracked.md` | `128` | no |

The conclusion that only `dirt_rename_split` reaches `drc == 0` is unchanged and correct; the evidence backing it is not. This is the same class as round 1's D-8.

Remedy: replace D1's table with the six rows above and add a sentence recording that `dirt_build_artifact_added_file` was checked and resolves `DISPOSABLE_BUILD_ARTIFACT` at rung 3, so its `diff-quiet` fixture is never read. Amend P1-T10's acceptance to a six-row table with the values above and a separate statement about `dirt_build_artifact_added_file`.

### B6 BLOCKING — D3's second worked example is false; `((srrc != 0))` at 371 stays EXEMPT

The first worked example is verified correct: under `dirt_clear_clean_failed` the unmutated run prints `ACTION|dirt-clear|/repo-wt/dirt|FAILED` and returns 1 while `s/((clrc != 0))/((0))/` prints `...|OK` and returns 0, with argv and aggregate identical. The widening genuinely moves 457 out of EXEMPT. The second does not hold: `srrc` is non-zero only when the `status --porcelain` read fails, and across all 77 scenario directories the only non-`.out` status fixture is `dirty_worktree_status_error/status._repo-wt_dirty.rc`, keyed to `/repo-wt/dirty`. Under every `dirt_*` scenario `srrc` is 0.

Remedy, adopt option (b) for lower churn: restate D3 to name 457 as the single guard the widening moves out of EXEMPT, and record 371 as remaining EXEMPT with the mechanical reason that no checked-in scenario fails the status read at `/repo-wt/dirt`. Do not add a 29th scenario; 457 alone establishes the design argument, and option (a) would re-open the D4 arithmetic in P0-T9, P1-T9, P3-T6, P5-T3 and the AC-8 wording in P4-T1.

### B7 BLOCKING — `\|` in the `mutation` column is GNU sed's alternation operator

Two of the eight fixed mutations escape the pipe for the Markdown table: `hash-object-hard-fail`'s `s% \|\| \[\[ -z $blob \]\]%%` and `rename-payload-split-gate`'s `s%== C \]\]%== C \|\| -n "x" \]\]%`. Taken verbatim into `sed`, the first pattern is a BRE alternation whose empty alternative matches at column 0, so the substitution replaces nothing, the source is unchanged, and P2-T6 assertion 2 fails. P2-T5 invariant 6 propagates the ambiguity into the test body as a literal.

Remedy: state in D2 part two, immediately below the table, that `\|` in the `mutation` column is Markdown table escaping for a literal `|` and that the composed `sed` program must carry an unescaped `|`. Re-quote the two affected mutations in unescaped form in a fenced code block outside the table.

## Non-blocking defects

### NB-1 — P0-T3 demands `StatusBefore:` and `StatusAfter:` be non-empty

`git status --porcelain` legitimately prints nothing on a clean tree. Remedy: require the two status fields to be present and recorded verbatim, with the artifact writing `(empty)` explicitly when the output is empty; keep "non-empty" only for the two digest fields. P5-T1 already uses the weaker wording.

### NB-2 — P4-T4 and P5-T10 demand section-scoped checkbox counts but name no derivation

`spec.md` carries eight checkboxes outside the `## Acceptance Criteria` section (`:24, :25, :26, :27, :84, :595, :597, :599`), so an unscoped `grep -c '^- \['` reports 53 today and 55 after P4-T2 and P4-T3. The 47/45/2 figures are correct for the section. Remedy: name the section-scoped derivation in both tasks, for example `awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' <spec> | grep -c '^- \['`.

### NB-3 — the harness's worktree path is never fixed

P2-T4 and D3 write `classify_worktree_dirt "$WT"` without stating what `$WT` is; the existing suites use `/repo-wt/dirt`. Remedy: state in P2-T4 that the harness uses `WT=/repo-wt/dirt` for every row and that the registry deliberately carries no worktree-path column.

### NB-4 — Phase 3's fixture additions can invalidate a classification made at P2-T8

P3-T1 and P3-T2 add payload files to `dirt_history_read_error` and `dirt_classifier_read_error`. A row classified `SEPARATED` at P2-T8 against one of those scenarios may stop separating afterwards, and P3-T7 would fail with no task permitting a registry edit. Remedy: add to P3-T7 an explicit authorization to re-classify any row whose observed kind changed as a result of Phase 3's fixture additions, and require the change and its reason to be recorded in P3-T8's artifact.

### NB-5 — P5-T12's clean-worktree assertion cannot include the plan file's own final check-off

Remedy: state in P5-T12 that the observation is taken before the task's own check-off, and that the final check-off commit is the orchestrator's to make.

### NB-6 — P0-T3's digest command depends on an unstated working directory

`discover_shell_scripts` collects its roots relative to the current directory and emits relative paths, so the digest returns empty from any cwd other than the repo root. Remedy: state that both P0-T3 and P5-T1 run the digest command with the worktree root as the working directory.

### NB-7 — the plan file carries no planner internal-review record

`atomic-plan-contract` requires a bounded `PLANNER-INTERNAL-REVIEW: PASS` record and a `SELF-REVIEW: RE-DERIVED THIS PASS` enumeration at handoff. The record was emitted in the round-1 handoff message rather than in the plan file, which satisfies the contract. No plan-content change required; the planner must emit it again on this revision.
