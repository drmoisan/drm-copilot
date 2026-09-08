# Feature Audit — cleanup-worktrees dirt classifier (Issue #632), remediation cycle 2 EXIT REAUDIT

- Timestamp: 2026-09-08T23-30 (UTC)
- Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2` at `454bd523`
- Base: `origin/epic/cleanup-merged-worktrees-hardening-integration` at `4ffe680e`
- Work mode: **`full-bug`**. Acceptance-criteria source: **`spec.md` only**.
- Blocking findings in this artifact: **0 new** (the two blocking findings are recorded in
  `code-review.2026-09-08T23-30.md` and `policy-audit.2026-09-08T23-30.md`; neither maps to an
  existing acceptance criterion).

## Acceptance-Criteria Derivation

Section-scoped derivation, as specified, so the severity radio-button block under `## Context` is
excluded:

```
awk '/^## Acceptance Criteria$/{f=1;next} /^## /{f=0} f' spec.md | grep -c '^- \['
47
```

```
grep -c '^- \[x\]'  -> 47
grep -c '^- \[ \]'  ->  0
```

The `## Acceptance Criteria` section spans `spec.md:678` to `spec.md:892` (next heading
`## Risks & Mitigations` at `:893`). The numbering is self-consistent: item 39 in this section is
labelled `AC-39`, so list position N equals AC-N throughout.

### Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/spec.md
- Total AC items: 47
- Checked off (delivered): 47
- Remaining (unchecked): 0
- Items remaining: none
```

No box was changed by this review. Two are evaluated PARTIAL below and both PARTIALs are on
environmental grounds that the criterion's author could not have controlled; unchecking them would
misattribute a repository-wide defect and a permission denial to this feature. Both are documented
here instead, which is the disposition the check-off protocol prescribes when a criterion's text
cannot be satisfied literally for reasons outside the change.

## Evaluation

Verdicts are stated against the full branch diff `4ffe680e..454bd523`. Criteria delivered before
cycle 2 and untouched by it are marked "carried" and were re-confirmed by the full local suite run
(all thirteen `test_cleanup_worktrees_*.bats` files: **179 ok, 0 not ok, exit 0**) rather than by
restating the cycle-1 verdict.

| AC | Verdict | Evidence |
|---|---|---|
| 1 | PASS (carried) | Library exists at 481 lines, defines the four named functions, runs nothing at source time, and is sourced by the wrapper and every self-sourcing suite. Re-confirmed by the 179-test run. |
| 2–7 | PASS (carried) | The six named scenario directories exist under `tests/fixtures/cleanup_worktrees/scenarios/` and their tests are in the passing set. |
| 8 | PASS | The membership test enumerates the scenario list and asserts `iterated == on_disk` where `on_disk` is `find "${SCEN}" -maxdepth 1 -type d -name 'dirt_*' \| wc -l`. Observed on-disk count: **28**, matching the criterion's corrected "twenty-eight" (cycle 1's O1 is closed). |
| 9–12 | PASS (carried) | Rung-precedence argv assertions in the passing set. |
| 13 | PASS | `dirt_classifier_read_error` now carries `hash-object.notes.md.out` and `rev-parse.main_notes.md.out`, which is what makes the assertion able to fail. See N2 site 2 below. |
| 14 | PASS (carried) | `dirt_build_artifact_mixed`. |
| 15–19 | PASS (carried) | Record-shape and no-regression criteria; the eight expected-output files are unchanged since cycle 1 and the suites pass. |
| 20 | PASS | `remove_worktree_safe` unchanged; `grep -rn 'worktree remove' scripts/bash/` returns exactly two call sites, `cleanup_worktrees_actions_lib.sh:191` and `:292`, both unforced. |
| 21–30 | PASS (carried) | CLI dispatch, clear-sequence ordering, non-mutation, `GIT_INDEX_FILE` sentinel, and staged-probe HEAD-skip criteria, all in the passing set. `clear_disposable_dirt` issues only `reset --hard` (`:469`) and `clean -fd` (`:474`); no `--force`, `-x`, `-X`, or `-ff` appears in the library. |
| 31 | **PARTIAL (non-blocking)** | The three `shell-qc.sh` stages are recorded as passing in a single consecutive pass by the executor, and CI run 34229386300 concluded `success` with `1..411` and 0 `not ok`. The criterion's *format-stage* clause additionally requires a before-and-after tree digest, and that command is denied to every agent in this environment. See the adjudication below. |
| 32 | PASS | Verified independently by this reviewer from the CI artifact rather than from the evidence file: repo-wide bash **93.69% (2166/2312)**, `cleanup_worktrees_dirt_lib.sh` **94.12% (160/170)**, both above 85%. No branch gate asserted, correctly. |
| 33 | PASS | `wc -l`: 481, 496, 380, 230, 452. All at or under 500. |
| 34–36 | PASS | `.claude/skills/cleanup-merged-worktrees/SKILL.md` carries the Report Line Contract, Prohibited Shortcuts, and Triage Procedure text, and gained the N1 narrowing sentence in cycle 2. |
| 37 | **PARTIAL (non-blocking)** | First half **PASS**: `diff` between the canonical file and the bundled mirror produces no output — byte-identical. Second half **FAIL as written**: `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` returns `1 failed, 10 passed`. The failure is `Repo file missing from bundle: .claude\state\current-session-id`, a gitignored local file (`git check-ignore -v` -> `.gitignore:68`), which is issue **#510**, fails identically at Phase 0 baseline, and is green in CI. Not attributable to this branch. |
| 38 | PASS (carried) | `--help` literals pinned in `test_cleanup_worktrees_cli.bats`, in the passing set. |
| 39 | PASS | Rung 1's Y-column gate at `cleanup_worktrees_dirt_lib.sh:270`. Both directions pinned by `dirt_staged_tree_worktree_delta`. Note: this criterion is satisfied, and finding N3 is the *converse* gap it does not cover — see below. |
| 40 | PASS (carried) | `rename-payload-split-gate` at `:418`; `dirt_rename_split` pins both directions. |
| 41 | PASS (carried) | `diff-header-skip` at `:182`; `dirt_build_artifact_plus_content` and `dirt_build_artifact_added_file` pin both directions. |
| 42 | PASS (carried) | Five directions present in `test_cleanup_worktrees_dirt_failclosed.bats`. |
| 43 | PASS (carried) | `status-read-hard-fail` at `:389`; `dirty_worktree_status_error`. |
| 44 | PASS (carried) | No `--ignored` on any status read; asserted with a positive control. |
| 45 | PASS | 94.12%, recomputed by this reviewer from the merged Cobertura artifact of run 34229386300. |
| 46 | **PASS** | Verified by reproduction and by three discrimination probes. See below. |
| 47 | **PASS as written** | Verified by reproduction and by two discrimination probes. The criterion's own text discloses the `EXEMPT is scenario-scoped` limitation that finding N4 concerns, so N4 is not a mismatch between claim and delivery. See below. |

Totals: **45 PASS, 2 PARTIAL (both non-blocking), 0 FAIL, 0 UNVERIFIED.**

## AC-46 — verified by reproduction, not by reading

Fix location: `scripts/bash/cleanup_worktrees_dirt_lib.sh:303-320`.

**Real-git confirmation of both the defect premise and the fix semantics** (read-only probes in this
worktree, not against the stub):

```
git diff --quiet main -- "no/such/path-xyz.md"             ; rc=0
git rev-parse --verify --quiet "main:no/such/path-xyz.md"  ; rc=1, no stdout
git rev-parse --verify --quiet "main:README.md"            ; rc=0, prints a blob id
```

**Discrimination probes.** Each was applied to a scratch copy of the library and the four functional
dirt suites re-run.

| Probe | Mutation | Result |
|---|---|---|
| Minimal neutralization | `s/((erc == 0))/((1))/` | `not ok 32 dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE` |
| True historical revert | `git show 02150524:scripts/bash/cleanup_worktrees_dirt_lib.sh` into the scratch copy | exactly one failure, the same test |
| Positive direction | `s/((erc == 0))/((0))/` | `not ok 33 … a tracked entry whose content is on main is still CONTENT_ON_MAIN` and `not ok 21 dirt_rename_split: a genuine R entry is still split` |

Both directions are pinned by assertions that fail when the fix is absent, and the second-direction
pin also rejects a "fix" that merely disables the rung. **AC-46 satisfied.**

## AC-47 — verified by reproduction, and judged on its merits

Shipped artifact, counted directly rather than restated:

```
registry data rows 39 / distinct ids 37 / 37 SEPARATED, 2 ARGV, 0 EXEMPT
markers in source  37
marker set == registry id set (diff empty)
bats test_cleanup_worktrees_dirt_guard_registry.bats -> 1..3, 3 ok
```

**Discrimination probe 1 — marker removal.** Stripping one marker comment from a scratch copy fails
the gate on five separate accumulators (INVARIANT-1, INVARIANT-3, INVARIANT-7, OBLIGATION-2,
OBLIGATION-5). The gate is load-bearing against future guard removal.

**Discrimination probe 2 — guard neutralization with the marker left in place.** Setting
`((erc == 0))` to `((1))` in the source fails OBLIGATION-2 and OBLIGATION-5, because the registry's
recorded mutation no longer matches and the row's derived `EXPR` no longer exists. The registry
cannot silently drift out of agreement with the library.

Every clause of AC-47 as written is delivered: the marker set matches the arithmetic predicate plus
the eight named literals; `(id, mutation)` row identity is enforced; the mutation admissibility rule
rejects comment-only and whitespace-only edits; the three kinds each assert both a difference and an
identity; the sibling-constant requirement is implemented for arithmetic `EXEMPT` rows; the literal
`EXEMPT is scenario-scoped` appears with the correct disclaimer; and eighteen rows over seventeen ids
are pinned by kind, three of them keyed by pair. **AC-47 satisfied as written.**

Finding N4 concerns the *strength* of what AC-47 specifies, not a gap between the criterion and the
delivery. The full cheapest-passing-registry construction and its empirical demonstration are in
`code-review.2026-09-08T23-30.md`, Part 3.

## AC-31 — the denied tree digest

The criterion requires the format stage to be judged by a before-and-after tree digest over the three
discovery roots, "because `shfmt` in write mode prints nothing and exits 0 whether or not it rewrote
a file". The digest command is denied to every agent in this environment, including the orchestrator,
which re-attempted it and received the identical refusal text; the denial is recorded verbatim in
`evidence/other/phase0-blocked-gates.2026-09-08T22-00.md` and no value is substituted.

The substitution argument — that the byte-identical `git status` observation covers the whole digest
set in this tree — is **sound**, and this reviewer re-derived its three premises rather than
accepting them:

1. `tools/` does not exist, so `discover_shell_scripts` (`scripts/bash/shell_qc_lib.sh:85`) reduces
   to `scripts` and `.claude/lib/bash`.
2. `is_shell_script` (`shell_qc_lib.sh:54-73`) admits a file by `.sh` suffix **or** by a `bash`/`sh`
   shebang. Searching both roots for non-`.sh` files whose leading bytes match
   `^#!.*\b(bash|sh)\b` returns **zero** matches across 238 non-`.sh` files. The digest set and the
   `-name '*.sh'` set are identical in this tree.
3. No untracked `.sh` file appears in either status listing, so every member of the digest set was
   tracked and any rewrite would have surfaced in `StatusAfter`.

The digest's only advantage over the status channel is reach over files the `.sh` predicate misses,
and that set is empty here. The property the criterion exists to establish is therefore established.
**PARTIAL, non-blocking**, with the missing observation named rather than papered over. Leaving
P0-T3 and P5-T1 unchecked is the correct disposition, because two of the task's four required
observation fields are denied.

## AC-37 — the push-down contract test

Reproduced by this reviewer:

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::
       test_bundled_claude_payload_contains_all_repo_runtime_contracts
AssertionError: Repo file missing from bundle: .claude\state\current-session-id
1 failed, 10 passed in 0.18s

git check-ignore -v .claude/state/current-session-id
.gitignore:68:.claude/state/   .claude/state/current-session-id
```

The half of the criterion this feature owns — that the bundled mirror is byte-identical to the
canonical `SKILL.md` — **passes**, confirmed by a `diff` producing no output. The failing assertion
concerns a gitignored local session-state file whose presence has nothing to do with this branch, is
open as issue **#510**, and is green in CI. The executor declined to delete the state file to force a
pass, which is correct: doing so would make the gate green without changing anything the gate
measures. **PARTIAL, non-blocking, not attributable to this branch.**

## The five unchecked plan tasks

53 of 58 plan tasks are checked. The five unchecked ones are adjudicated above and in
`policy-audit.2026-09-08T23-30.md`: P0-T3 and P5-T1 on the denied tree digest, and P0-T10, P4-T7 and
P5-T11 on the pre-existing #510 failure. **None represents incomplete work, and none is blocking.**

## Structural finding: the acceptance set still does not cover the recurring defect class

This is the third consecutive cycle in which a data-loss path passed the entire acceptance set.

- Cycle 1 exit: R1 (rung 1 ignored the porcelain Y column) and R2 (unconditional ` -> ` split).
- Cycle 2 entry: N1 (rung 4 read an empty pathspec as a match).
- Cycle 2 exit: **N3** (rungs 4 and 5 resolve a disposable verdict without ever comparing the index
  blob), reproduced in `code-review.2026-09-08T23-30.md`, Part 4.

Cycle 1's remediation input proposed a general criterion:

> No rung resolves a disposable verdict from a probe whose result does not establish one.

What was delivered as AC-47 is a mechanical proxy for the second half of that sentence — it detects a
guard whose neutralization changes nothing. It does not detect a rung that is *missing* a comparison,
which is the shape of R1, N1, and N3 alike. The guard registry gate passes cleanly on a tree that
contains N3, which this reviewer confirmed by running it: `1..3, 3 ok`.

Recommendation for cycle 3's acceptance set: state the property over the *inputs to a verdict* rather
than over the guards. A workable form is that for every disposable verdict the ladder can emit, the
set of git reads that produced it must account for every location in which the entry's content
exists — the working tree, the index, and `HEAD` — with a checked-in scenario per (status code
class, verdict) pair that reaches a disposable verdict. That form covers R1, R2, N1, and N3, whereas
the guard registry covers none of them directly.

## Verdict

**PARTIAL.** All 47 acceptance criteria are satisfied as written, with two evaluated PARTIAL on
environmental grounds that are documented rather than waived. N1 and all four N2 sites are verified
closed by reproduction and by discriminating mutation probes. The feature nevertheless carries two
new blocking findings, N3 and N4, which map to no existing criterion and therefore open a new
remediation cycle rather than reopening this one.
