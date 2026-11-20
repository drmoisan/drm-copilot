# Remediation cycle 2 — preflight round 3 delta

- Plan under review: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/remediation-plan.2026-09-08T06-51.md`
- Reviewer: `atomic-executor` (preflight mode), full-pass validation against the tree
- Signal: **PREFLIGHT: REVISIONS REQUIRED**
- Convergence: FURTHER ROUNDS LIKELY
- Counts: 3 blocking, 8 non-blocking

## Rulings carried forward

Sustained without change: the whitespace-collapse addition to P2-T6 assertion 2 (verified that the comment-strip test alone does not reject a whitespace-only code edit, and that the collapse rejects none of the ten admissible mutation shapes); the removal of the non-zero-exit disjunct (`classify_worktree_dirt` returns non-zero only via the status-read failure at `:371-373`, and no `dirt_*` scenario carries a `status.*.rc` fixture, so the disjunct named a value nothing admissible could satisfy); the `PENDING-PHASE-3` token (the four ids are correct and `rung4-tracked-path-in-main` is correctly excluded); the 452 contrast (`dirt_clear_reset_failed/reset-hard.rc` contains `1`, so neutralizing `:452` reaches `clean -fd` and changes both the argv log and the record); the two corrected fixture status strings and the `:374` correction; and the independent set-membership re-derivation (18 tracked entries, 6 reaching rung 4's tracked half, 12 resolving earlier as 6 at rung 3, 1 at `:287`, 2 at `:262`, 3 at `:266`). All eight fixed `sed` literals were executed against their actual source lines and work; the escaped form of the `:311` literal was confirmed a no-op, which is the finding B7 raised.

Two rulings go the other way.

- The **reason** given for narrowing the escape hatch from thirteen to eight is inaccurate. Because all five remediated mutations are already form-2 instances, the thirteen-literal and eight-literal hatches admit the same string for a row's own marked line, so a thirteen-row hatch would not have left five rows unconstrained. The narrowing is still correct and slightly tighter, for a different reason. See NB-A.
- The **371 half** of the round-2 B6 remedy is overturned. See BD2.

## Blocking defects

### BD1 BLOCKING — `EXEMPT` is still a written verdict, and D3's own design witness is among the rows it frees

Cheapest passing artifact under the current text of D2, D3, P2-T5, P2-T6, P2-T8 and P2-T9: for each of the 31 rows not pinned by P2-T7, set `scenario` to `dirt_unique`, set `mutation` to the form-2 string in whichever of `((0))` or `((1))` is inert under that scenario, set `kind` to `EXEMPT`, and set `reason` to `RECORDS-AND-ARGV-IDENTICAL: no observable difference`. Obligation 1 passes (`dirt_unique` exists and carries the `dirt_` prefix); obligation 2 passes (form 2 changes the comparison text, one line, marker present, differs after strip and collapse); obligation 3 passes; obligation 4 passes (`dirt_unique` emits one `DIRTFILE|`); obligation 5 for `EXEMPT` asserts only the `reason` prefix. P2-T8 commands 1 through 8 pass, P2-T5 invariants 1 through 7 pass, and P3-T7 exits 0. No acceptance command requires the mutated library to be executed for any of those rows.

The consequence is not hypothetical. `((clrc != 0))` at `:457` — the single guard D3 says the widened observation channel exists to expose, sitting on the failure check for the irreversible `clean -fd` — is not in P2-T7's pinned set, so a registry recording it `EXEMPT` against `dirt_unique` passes the whole gate and the widening is never exercised. `clear-requires-all-disposable` (`:447`), `unique-verdict-tally` (`:410`) and `history-hit-nonempty` (`:341`) are in the same position and each is trivially separable under a checked-in scenario.

Remedy, both parts required. Part (b) alone is genuinely lower churn but does not close the class, since it leaves the remaining 26 arithmetic rows writable without running the harness.

(a) Amend D3's kind table and P2-T6 assertion 5 so an `EXEMPT` row additionally requires the mutated record channel to equal the unmutated record channel AND the mutated argv log to equal the unmutated argv log. Delete the D3 paragraph beginning "The gate deliberately does not assert the absence of a difference". P3-T7 already carries an explicit re-classification authorization, which answers the "fails on an improvement" objection: the failure is precise and its fix is a two-column registry edit the plan already permits. Mirror the change in P2-T11 and in AC-47's per-kind clause.

(b) Extend P2-T7 to additionally require at least one row with `kind` exactly `SEPARATED` for `clear-requires-all-disposable`, `unique-verdict-tally`, `history-hit-nonempty`, and for three new mandatory ids assigned to cycle-start lines `371`, `452` and `457`. Add those three ids to the mandatory-marker-id section so P2-T7 can name them as literals, and confirm in that section that no new id is a prefix of another.

### BD2 BLOCKING — D3's `EXEMPT` determination for `((srrc != 0))` at `:371` is false in the direction invariant 7 permits

D3 states that under every `dirt_*` scenario `srrc` is 0 and both channels are identical, so row 371 is registered `EXEMPT`. That holds only for `s/((srrc != 0))/((0))/`. `srrc` is declared `srrc=0` at `:369`, so `s/((srrc != 0))/((1))/` makes `:371-373` read `if ((1)); then return "$srrc"; fi`: the mutated `classify_worktree_dirt` returns 0 having emitted no record at all, while the unmutated run under any `dirt_*` scenario emits at least one `DIRTFILE|` and one `DIRTSUM|`. Both the record channel and the argv log differ. D2 part six states that choosing `((0))` or `((1))` is the executor's decision per row, so the plan grants the choice and simultaneously asserts an outcome only one choice produces.

Remedy: replace D3's 371 paragraph with a statement that the guard is inert under `((0))` and separating under `((1))`. Fix row 371's `mutation` in D2 as the literal `s/((srrc != 0))/((1))/` with `kind` `SEPARATED`, and add its id to the mandatory-marker-id section. This overturns the part of round-2 B6 the plan adopted and removes an `EXEMPT` row rather than adding one, so it does not disturb the D4 arithmetic, the scenario counts, or AC-8.

### BD3 BLOCKING — AC-47 states a thirteen-literal escape hatch; the suite implements eight

P4-T3's AC-47 text reads "being either one of the thirteen mutations the remediation plan fixes by literal or the arithmetic guard's own comparison rewritten to a constant". D2 part six, recorded departure 4, P2-T5 invariant 7 and P2-T11 all state eight. Round-2 B1 remedy item 3 required both AC-47 and the P2-T11 artifact to be reworded; only P2-T11 was. AC-47 is a permanent spec artifact and must describe the gate the suite enforces.

Remedy: in P4-T3, replace "one of the thirteen mutations the remediation plan fixes by literal" with "one of the eight non-arithmetic mutations the remediation plan fixes by literal".

## Non-blocking defects

**NB-A** — D2 part six and departure 4 justify the eight-row hatch with "a thirteen-row hatch would leave five rows unconstrained". It would not. Restate the reason as "so that a literal fixed for one row cannot be borrowed by another row, where P2-T6 assertion 2 would then have to catch it".

**NB-B** — P2-T5 invariant 7 does not say how the test behaves for a row whose marked line carries no arithmetic comparison (the six non-arithmetic-only lines 172, 260, 341, 403, 410, 447), where the `EXPR` extraction yields nothing. Add "for a marked line carrying no arithmetic comparison, only the eight-literal disjunct applies and the derived disjunct is not evaluated".

**NB-C** — P3-T8's acceptance does not exclude the `PENDING-PHASE-3` token. Add that `grep -c 'PENDING-PHASE-3' docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/evidence/qa-gates/guard-separation-probe.2026-09-08T09-00.md` reports `0`.

**NB-D** — P2-T10's acceptance requires the diagnostic to name the four ids and not to name `rung4-tracked-path-in-main`, but does not bound it to exactly four, so an unrelated fifth failing row would go unreported. Add "and the accumulated diagnostic names no id other than those four".

**NB-E** — P5-T12's enumerated commit contents omit this plan file, which lives in the folder its clean-status acceptance covers and carries check-offs for P5-T7 through P5-T11 made after P5-T6's commit. Add "and this plan file with its check-offs through P5-T11".

**NB-F** — P2-T4 says the mutated library is evaluated "in place of sourcing the real library" without stating that `cleanup_worktrees_enumerate_lib.sh` and `cleanup_worktrees_lib.sh` are still sourced, which the `cleanup_wt_git` seam requires and which the existing helpers at `tests/shell/test_cleanup_worktrees_dirt_classify.bats:41-44` do. State it.

**NB-G** — D2 part six argues form 2 is safe on the nine `&&`-suffixed lines because the checked-in suites already execute every one of those lines in its false direction. The property that actually carries it is that none of the three libraries sets `errexit` and the harness's `bash -c` child does not either, so an exit status of 1 from `((0))` cannot abort the run. Restate on that basis, which is decidable from the tree.

**NB-H** — D1 and P1-T10 say `dirt_build_artifact_added_file` resolves `DISPOSABLE_BUILD_ARTIFACT` at `:284`. The verdict is printed at `:283` and returned at `:284`. Cite `:283-284`.

## Verified clean (no action)

Invariant 7 is well-formed on all 31 arithmetic lines, including the two compound lines and the nine `&&`-suffixed lines, and no line is silently exempted by the invariant's shape: for each of the 31, at least one direction separates under a checked-in scenario. The exemption risk comes from the free direction choice, reported as BD1 and BD2.

No acceptance condition compares against HEAD, a literal SHA, or a clean worktree in a way that a commit would invalidate. P5-T6 pairs its anchored `git diff --name-only` with a post-`git add -A` porcelain span; P5-T7 records the head SHA as an observation. The Phase 1 and Phase 3 windows in which the classify membership suite is red are covered by the task-ordering note, and no acceptance condition inside those windows requires that suite green. The only ordering gap found is NB-E.

The AC arithmetic is correct: section at `spec.md:678`, 45 boxes all checked, AC-45 last at `:848`, eight boxes outside the section, unscoped 53 today and 55 after Phase 4. The section-scoped `awk` derivation terminates at `## Risks & Mitigations` and is not terminated by `###` subheadings. Both P4-T1 assertions are satisfiable and can fail; P4-T3's registry-name assertion currently returns 0 so it can fail; P5-T10's `grep -c '^- \[ \] AC-4'` reports 0 only after both check-offs.

No wrap-tolerant-assertion violation was found in the conditions added this round. The three unwrapped-stream searches are the correct treatment for rewrapped prose blocks, and P4-T5's target phrase currently occurs zero times so that assertion can fail. The TAP-shaped assertions in P0-T5 and P5-T3 are satisfiable against a recorded successful run showing `1..390` with 390 `ok` lines.
