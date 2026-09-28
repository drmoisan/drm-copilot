# Cycle-3 closing summary

Timestamp: 2026-09-09T02-30
Task: [P5-T12]
Issue: #632
Branch: `bug/cleanup-worktrees-dirt-classifier-632-r2`
Plan: `remediation-plan.2026-09-08T23-30.md`
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

This is the third and final remediation cycle. Five items were in scope: the two blocking
findings N3 and N4, the systemic missing-comparison gate, and the two non-blocking
corrections P2 and P4. Each is recorded below with the change made, the test that holds it,
and the evidence artifact.

## 1. N3 — the index blob was unaccounted for

**The defect.** For a status entry whose X column and Y column both carry a content-bearing
letter, content exists in the index *and* in the working tree and the two differ. Rung 4's
tracked half compared `main` to the working tree and rung 5 hashed the working-tree file;
neither read the index blob. `MM`, `AM`, `RM` and `CM` entries therefore resolved
`CONTENT_ON_MAIN` or `CONTENT_IN_HISTORY`, the worktree aggregated `ALL_DISPOSABLE`, and
`--clear-disposable` would have destroyed the staged blob. Data loss.

**The change.** `classify_dirt_entry` in `scripts/bash/cleanup_worktrees_dirt_lib.sh`
gained one flag and two arithmetic gates. Nothing was moved and no existing read was
removed or reordered. The flag is set immediately after the untracked test; the two gates
sit at rung 4's and rung 5's positive emissions, so a blocked entry emits nothing at either
site and falls through to rung 6, which is `UNIQUE`. A library header paragraph,
`INDEX AND WORKING TREE ARE TWO LOCATIONS.`, records why.

**The three guard ids, with their registry rows:**

| Guard id | Registry kind | Scenario | Baseline aggregate | Mutation |
|---|---|---|---|---|
| `index-and-worktree-both-hold-content` | `SEPARATED` | `dirt_index_and_worktree_delta` | `HAS_UNIQUE` | `s%\[\[ $x == \[MARCTU\] && $y == \[MARCTU\] \]\]%[[ -n "" ]]%` |
| `rung4-index-blob-unaccounted` | `SEPARATED` | `dirt_index_and_worktree_delta` | `HAS_UNIQUE` | `s/((bothloc == 0))/((1))/` |
| `rung5-index-blob-unaccounted` | `SEPARATED` | `dirt_index_and_worktree_delta` | `HAS_UNIQUE` | `s/((bothloc == 0))/((1))/` |

The first is the ninth named non-arithmetic literal, added to `LIT_IDS` and `LIT_MUTS`. The
two arithmetic rows carry the same mutation text under different ids, which is admissible
because row identity is the pair (`id`, `mutation`).

**The tests that hold it.** Four tests in
`tests/shell/test_cleanup_worktrees_dirt_failclosed.bats`, driven by one checked-in
fixture, `dirt_index_and_worktree_delta`, with four status entries:

1. `dirt_index_and_worktree_delta: an MM entry whose working-tree content is on main is UNIQUE`
2. `dirt_index_and_worktree_delta: an MM entry whose working-tree blob is in history is UNIQUE`
3. `dirt_index_and_worktree_delta: a UU entry whose working-tree content is on main is UNIQUE`
4. `dirt_index_and_worktree_delta: the M-space control entry in the same fixture is still CONTENT_ON_MAIN`

Test 4 is the direction that rejects a "fix" that simply disables rungs 4 and 5. Each of
the three negative assertions is paired with a positive record assertion in the same test,
so none can pass in a build where no classification ran.

**Evidence.**

- `evidence/regression-testing/fail-before-index-blob-unaccounted.2026-09-09T00-30.md` —
  fail-before, exit 1, four failures with two positive controls passing, pre-fix record
  stream carrying `DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|ffff3333`.
- `evidence/regression-testing/pass-after-index-blob-unaccounted.2026-09-09T01-00.md` —
  pass-after, exit 0, post-fix record stream carrying `DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|`
  and no `ALL_DISPOSABLE`.
- `evidence/regression-testing/phase2-sibling-check.2026-09-09T01-00.md` — the six dirt
  suites green together, and `dirt_staged_tree_worktree_delta`'s `MM src/a.cs` sibling
  unchanged, which keeps the registry's `hash-object-hard-fail` literal row separating.
- `evidence/qa-gates/file-size-after-fix.2026-09-09T01-00.md` — the library at 495 of 500.

## 2. N4 — the `EXEMPT` kind let a separable guard be parked

**The defect.** A registry row could be satisfied by naming a scenario under which the
ladder never reaches the guard, so 20 of 37 marker ids were parkable and the pin floor
covered only 17.

**The change.** The kind was **removed** rather than strengthened. Any mechanical form of
"the ladder reached this line" would need a third observation channel, which is a new
mechanism and out of scope. Removing the kind achieves the same end with a deletion: a row
must be `SEPARATED` or `ARGV`, and both require an observed difference, which is only
possible if the guard executed. "Never reached" stops being a way to pass. Six edits to
`tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats`: the `EXEMPT` arm of
Obligation 5 deleted; Invariant 2's kind list narrowed to `'SEPARATED ARGV'`; Obligation 6,
the `sibling_mutation` helper and the `EXEMPT_SIBLING_DIFFERED` accumulator deleted;
Invariant 8 added as an inadmissible-kind accumulator; the third test's Groups A and B
replaced by a floor over **every** marker id, with Group C's three pair-keyed pins kept.

**The pin floor holds.** 42 registry rows over 40 distinct ids: 40 `SEPARATED`, 2 `ARGV`,
no third kind. 39 ids carry a `SEPARATED` row. The fortieth,
`history-scan-bounded-range`, is the single member of `ARGV_ONLY_IDS` and carries an `ARGV`
row, because the stub keys `log --find-object` on the object id alone and no scenario can
make that guard separate on the record channel. There is no unpinned remainder.

**The test that holds it.** `every marker id is pinned by kind and the two dual-row lines
are pinned by pair`, which reads the id set from the library's own markers rather than from
a list written into the test.

**Evidence.**

- `evidence/regression-testing/n4-parked-row-rejected.2026-09-09T01-30.md` — the
  demonstration that the parked-row artefact is now rejected. The variant registry the
  cycle-2 reaudit built, which passed all three tests before this phase, now fails all
  three, printing `INVARIANT-8 inadmissible kind:`,
  `OBLIGATION-5 channel comparison failed:` and `PINS NOT SATISFIED:`. The registry was
  restored by the inverse row rewrite and is byte-identical to the committed version.
- `evidence/qa-gates/registry-kind-distribution.2026-09-09T01-30.md` — the end-state kind
  distribution and marker-id count.

## 3. The missing-comparison gate

**The subject.** R1, N1 and N3 are the same defect: a rung infers disposability from a
probe that does not answer the question. The guard registry detects a *dead guard* and
passed cleanly on a tree containing N3, so it does not cover this class.

**The change.** A second, independent gate,
`tests/shell/test_cleanup_worktrees_dirt_content_locations.bats`, stating the property over
the **inputs to a verdict**. It reads the classifier's own output and, for every
`DIRTFILE|` record whose verdict is neither `UNIQUE` nor `DISPOSABLE_SESSION_ARTIFACT`,
derives the required content locations from that record's own `xy` field and requires a
matching probe in the argv log for that record's own path. Nothing in it is a list of
expected verdicts, so it cannot be satisfied by editing a table. Checked by hand against
the three historical defects, it fails on all three; the guard registry catches none of
them directly.

**The tests that hold it.** Two:

1. `every disposable verdict is backed by a git read of every location holding that entry's content`
2. `every classifier-relevant status-code class is covered by a checked-in dirt scenario`

The second is a coverage floor over eight status codes — `??`, `M `, `A `, `R `, ` M`,
`AD`, `MM`, `UU` — and it can fail: `UU` is present only because this cycle's new scenario
supplies it.

**Evidence.** The same fail-before and pass-after artifacts as N3, in which test 1 fails
before the fix and passes after while test 2 passes throughout, which is what shows the
accounting failure was not a fixture-availability artefact.

## 4. P2 — a stale citation in a cycle-2 evidence artifact

**The change.** `evidence/other/phase0-blocked-gates.2026-09-08T22-00.md:78` cited
`.gitignore:67`. The observed rule is at `.gitignore:68`, which reads `.claude/state/`;
`.gitignore:67` reads `.claude/agent-memory`. One-token edit; the artifact's reasoning is
unaffected because the path is gitignored either way.

**What holds it.** `grep -cF '.gitignore:68'` reports 1 and `grep -cF '.gitignore:67'`
reports 0 over that artifact.

**Evidence.** The corrected artifact itself,
`evidence/other/phase0-blocked-gates.2026-09-08T22-00.md`.

## 5. P4 — the registry's predicate compels markers only onto arithmetic guards

**The change.** The one non-arithmetic guard this cycle adds,
`index-and-worktree-both-hold-content`, is registered by name in the suite's hard-coded
`LIT_IDS` and `LIT_MUTS` lists, taking each from eight elements to nine, at the same index
in both. That is the whole of P4's remediation and its bound is stated rather than implied:
it registers the one guard, and does not make future `[[ ... ]]` verdict guards register
themselves. A general `[[ ... ]]` predicate would match every conditional in the file
rather than only the verdict guards, so no such predicate was proposed.

**What holds it.** Invariant 6 pairs the two arrays by index, and Obligation 2 fails when
the substitution does not change the line, so the ninth literal must match the source line
character for character. The registry suite passes at exit 0.

**Evidence.** `evidence/qa-gates/registry-kind-distribution.2026-09-09T01-30.md` and the
full local test stage, `evidence/qa-gates/shell-qc-test.2026-09-09T02-30.md`.

## Toolchain position

| Stage | Command | Exit |
|---|---|---:|
| format | `bash scripts/bash/shell-qc.sh format` | 0 |
| lint | `bash scripts/bash/shell-qc.sh check` | 0 |
| test | `env SHELL_QC_BATS_BIN=<resolved> bash scripts/bash/shell-qc.sh test` | 0 |
| contract | `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | 1, expected |

417 bats tests, 0 failures, up from the 411 baseline by exactly the six this cycle adds.
The contract stage's single failure is issue #510, identical at this cycle's baseline and
green in CI.

## Acceptance criteria

Section-scoped total 49, checked 49, unchecked 0. AC-8's count phrase corrected, AC-47
edited in place, AC-48 and AC-49 added and checked off against their evidence.

## Outstanding — caller-owned

Coverage remains CI-measured. `kcov` has no local route in this worktree and
`bash scripts/bash/shell-qc.sh test --coverage` exits 127 here, so no locally derived
coverage figure is asserted anywhere in this cycle. P5-T8, P5-T9 and P5-T10, the
`workflow_dispatch` and the two coverage reads, are the caller's, as is the push in P5-T7.
P5-T11's declaration is complete for its four local stages and blocked on the coverage run
id. Those five plan tasks are left unchecked.
