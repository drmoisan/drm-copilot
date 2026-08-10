# Code Review — F8 Radius Drift Detection (issue #446), Remediation Cycle 1 Exit Reaudit

- Timestamp: 2026-08-09T07-23
- Branch: `feature/parallel-drift-detection-446`, head `2266e1ab`
- Base: `c939b5b8`. Cycle-1 delta: `bcf2de15..HEAD`
- Blocking count: **0**

## Method Statement

Every closure verdict below rests on re-execution or direct structural inspection, not on the
executor's evidence artifacts. Where an executor claim was checked and found accurate, that is stated.
Where a claim was checked and found inaccurate, the inaccuracy is recorded as a finding even when the
underlying remediation is sound.

Two scratch harnesses were used and are reproduced inline so the results are auditable.

## F8-B1 Closure — the derived resolution now has a producer

**Verdict: CLOSED.**

### What was required and what landed

| Required action (cycle entry) | Landed | Verified how |
| --- | --- | --- |
| Add step 7 naming actor, trigger, and the exact write | `#### Six-Step Procedure` renamed `#### Seven-Step Procedure`; step 7 names actor `parallel-orchestrator`, trigger "the consuming remediation cycle exiting with `blocking_count == 0`", both writes, and the sentence "**No other write clears the derived unresolved state**" with the reason for each excluded write | Read the SKILL.md diff |
| Emit `observed_radius` from the library-built value | `evaluate_drift` returns a ninth key, populated from `request_resolution_write(...).blast_radius` | Executed `evaluate_drift`; payload key set is exactly the nine documented keys |
| Add a test applying each resolving write and asserting the derivation clears | `tests/scripts/dev_tools/test_parallel_drift_resolution.py`, three tests | Read and re-executed |
| Update `#### Resolution Semantics` to cite the producer rather than assert the property | The paragraph now reads "Each disjunct has a named producer, so the gate has a release path and nothing deadlocks. The producer is step 7 …" | Read the diff |

The prohibitions were honored: no `resolved` member added to `drift_events[].action`, no checkpoint
field added, the Layer-2 invariant not relaxed. `observed_radius` is a **stdout payload** key, not a
schema field.

### The loop-closing seam test genuinely closes the loop

`test_applying_the_emitted_observed_radius_resolves_the_recorded_drift` was checked against all four
properties demanded at cycle entry:

1. **Asserts unresolved before the write** — line 79:
   `assert ITEM_KEY in unresolved_drift_item_keys(events, items)`. Present.
2. **Writes the emitted value verbatim** — lines 101-102: `resolved_items[0]["blast_radius"] =
   emitted`, where `emitted = payload["observed_radius"]`. No radius is hand-built, no field is
   adjusted between emission and application.
3. **Asserts resolved after the write** — line 105:
   `assert unresolved_drift_item_keys(events, resolved_items) == ()`. The same derivation function is
   called on both sides of the write, in the same test.
4. **Isolates disjunct (b) as the mechanism** — the later invocation's observed diff is
   `["packages/mcp-server/src/index.ts"]`, not the recorded event's escaped path, and line 99 asserts
   `ESCAPED_PATH not in emitted["paths"]`. Disjunct (a) is therefore provably inapplicable, leaving
   `source == 'observed'` with a strictly later `computed_at` as the only possible cause of the
   transition.

This is a genuine loop closure, not two independent per-side assertions. A producer emitting a value
the derivation does not accept fails here.

### Non-vacuity — independently confirmed

The executor claims that `computed_at` equal to and earlier than the event's `at` both leave the item
unresolved. I re-ran the same construction at three `computed_at` values:

```
computed_at              before        after
2026-08-08T10-00 (equal)   (446,)   ->  (446,)   still unresolved
2026-08-08T09-30 (earlier) (446,)   ->  (446,)   still unresolved
2026-08-08T11-00 (later)   (446,)   ->  ()       resolved
```

**Confirmed.** Only the strictly later value closes the loop, so the assertion is sensitive to the
producer's `computed_at` and to disjunct (b)'s strictness. The claim is accurate as stated. Note the
equal case is also the CLI's default (`--computed-at` defaults to the resolved `--at`), which is what
finding F8-N11 below is about.

### Deadlock analysis — can a child still deadlock on the Layer-2 path?

The residual the executor recorded is real and I reproduced it: with `changed_paths=["docs/a.md"]`
against a declared radius of `["docs/**"]`, `evaluate_drift` returns
`result: no_escape, observed_radius: None`. So an invocation made **after** remediation has narrowed
the diff emits no radius and cannot itself close the loop.

**Narrowed-diff case — NOT a deadlock.** The parent captures `observed_radius` from the invocation
made while the diff still escapes, and applies it with a `computed_at` strictly later than the
event's `at`. Verified:

```
escaping invocation (changed_paths = ["scripts/dev_tools/escape.py", "docs/a.md"],
                     at = 2026-08-08T10-00, computed_at = 2026-08-08T11-00)
apply emitted observed_radius -> unresolved_drift_item_keys == ()
```

The sequencing is guaranteed to be available, not merely likely: a recorded `drift_events[]` entry
exists **only because** an escaping invocation happened, and `escaped_paths` must be non-empty per F3
invariant 18. There is therefore always at least one invocation from which a resolving radius can be
minted, and `--computed-at` exists on the parser to give it a strictly later stamp. What the operator
must not do is wait until after remediation and then re-invoke expecting a value.

**Widened-radius case — NOT a deadlock, and unconditionally so.** Extending `blast_radius.paths` to
cover the escaped path resolves the item through disjunct (a), which involves **no timestamp
comparison, no CLI invocation, and no emitted value at all**. Verified:

```
blast_radius.paths = ["docs/**", "scripts/dev_tools/escape.py"], source left at "declared"
-> unresolved_drift_item_keys == ()
```

`test_widening_the_declared_radius_resolves_the_recorded_drift` asserts `source == "declared"`
explicitly, so the transition is attributable to path subsumption alone.

**Ruling on the residual: acceptable narrowing, not a real deadlock.** Two independent reasons:

1. Disjunct (a) is a complete release path that is always available and has no dependency on the
   emitted value, on any timestamp, or on invocation ordering. Even an operator who never discovers
   `--computed-at` can always release the gate.
2. Disjunct (b) is reachable from the escaping invocation that necessarily precedes any recorded
   event, so the narrowing is to *when* the radius is captured, not to *whether* one can be.

The residual is correctly recorded in the CLI module docstring, where a future reader of the payload
contract will encounter it. It is **not** recorded in the SKILL.md, which is the document the
`parallel-orchestrator` actually reads — see F8-N11.

### Evidence used

Re-executed `evaluate_drift` and `unresolved_drift_item_keys` across the equal, earlier, later,
no-escape, narrowed-diff, and widened-radius cases; read `parallel_drift_resolution.py`,
`test_parallel_drift_resolution.py`, the `evaluate_drift` diff, the `_is_drift_resolved` diff, and the
SKILL.md step-7 and `#### Resolution Semantics` diffs; confirmed the payload key set is exactly nine
keys.

## F8-B2 Closure — halt selection can no longer select the drifting item

**Verdict: CLOSED.**

### The exclusion is at the call site and is structurally sound

`halted_item_keys(items, pairs, drifting_item_key)` in
`scripts/dev_tools/parallel_drift_detection_cli.py` drops the drifting key from each pair's candidate
list **before** the comparator runs:

```python
for first, second in pairs:
    candidates = [key for key in (first, second) if key != drifting_item_key]
    if len(candidates) == 1:
        halted.add(candidates[0])
    else:
        halted.add(select_halted_item(markers[candidates[0]], markers[candidates[1]]))
```

Because a canonical pair holds two distinct keys with `a < b` (F3 invariant 15), the candidate list is
provably one or two entries and can never be empty, so no zero-candidate branch is needed. The
drifting key cannot appear in `candidates` and therefore cannot appear in the returned tuple. The
guarantee is by construction, not by test coverage.

### Both tie-breaks verified

`test_the_drifting_item_is_never_halted_even_when_it_started_later` covers both cases the finding
named:

- **Later by timestamp**: drifting item 446 at `2026-08-08T09-00`, peer 445 at `2026-08-08T08-00`.
  Result `[445]`, and `assert DRIFTING not in halted_item_keys`.
- **Later by the equal-timestamp item-key tie-break**: both at `2026-08-08T08-00`, so the bare rule
  selects the larger `issue_num`, 446. Result `[445]`, and the same negative assertion.

Both cases assert the positive expectation (`== [445]`) and the negative (`DRIFTING not in ...`), so
the test cannot pass by returning an empty tuple.

### `select_halted_item` is unchanged apart from its docstring

`git diff --numstat bcf2de15 -- scripts/dev_tools/parallel_drift_halt.py` returns **`6  0`** — six
added lines, zero removed. Reading the diff confirms all six are docstring prose explaining that the
exclusion is applied by the caller. **The executor's +6/-0 docstring-only claim is accurate.** The
comparator keeps its `(a, b)` signature and receives no drift information, which is the structural
guarantee that no item is ever selected by virtue of drifting.

### No test anywhere still asserts the drifting item is halted

`grep -rn "halted_item_keys" tests/` returns every assertion site. Enumerated:

| Site | Assertion | Drifting item halted? |
| --- | --- | --- |
| `test_parallel_drift_detection_cli.py:212` | `== []` | no |
| `test_parallel_drift_detection_cli.py:228` | `== []` | no |
| `test_parallel_drift_detection_cli.py:306` | `== [445]` — this is `test_main_prints_the_detection_result_as_json`, the fourth test the executor corrected beyond the plan's named three | no |
| `test_parallel_drift_detection_cli_halt.py:57, 79, 104, 117, 139` | `[445]`, `[445, 447]`, `[445]`, `[445]`, `(448,)` plus four explicit `DRIFTING not in ...` assertions | no |
| `test_parallel_drift_detection_conflicts.py:378` | `halted == (445,)` where the drifting key passed is 446 | no |

The executor's disclosure that it corrected a fourth test beyond the plan's named three is accurate
and is the correct handling; leaving `test_main_prints_the_detection_result_as_json` asserting the old
behavior would have contradicted the fix.

### The comparator-level assertion in the determinism test — the executor's reasoning holds

`test_the_detection_and_halt_path_is_deterministic_across_repeated_calls` calls `select_halted_item`
directly with two constructed `ItemStart` markers carrying equal timestamps, so the comparator returns
the larger key, 446 — the drifting item — and feeds it to `request_requeue_via_recolor`. The
executor recorded this as correct and unchanged because `select_halted_item` receives no drift
information.

**Confirmed, for the reason given.** The test's only assertion is `results[0] == results[1]`. It
asserts **determinism**, never that 446 is the halted item. `select_halted_item` in isolation is
correct: given two markers with no drift context, the larger key is the later starter. Nothing in this
test states or implies that the drifting item should be halted, so it required no correction.

One caveat, recorded as F8-N12 rather than as an F8-B2 gap: the test is named "the detection **and
halt** path" but now routes around the production halt path, because `halted_item_keys` is the call
site and this test bypasses it.

### Evidence used

`git diff --numstat` and the full diff of `parallel_drift_halt.py`; the full current text of
`halted_item_keys` and `_start_markers`; the complete grep of halt assertions across `tests/`; a
direct read of `recompute_conflicts_with_observed` confirming every returned pair is
`canonical_pair(drifting, peer)`; execution of `halted_item_keys` on a drifter-free pair.

## Adjudications — items (a) through (e)

### (a) Three test helpers and one production helper renamed from private to public

**Severity: Informational for the test-support renames; Non-blocking for the production rename
(recorded as F8-N14 for its verified side effect).**

The three renames `_in_flight`/`_checkpoint`/`_evaluate` to `in_flight`/`checkpoint`/`evaluate` are in
`tests/scripts/dev_tools/parallel_drift_test_support.py` — a **test** module. Nothing about a
production public surface is involved. A shared test-support module exists precisely to be imported
across test-module boundaries, so an underscore prefix on its exports was wrong from the outset and
pyright's `reportPrivateUsage` and `reportUnusedFunction` correctly identified it. The new names also
match that module's three pre-existing exports `radius`, `item`, and `event`, so the rename increases
internal consistency. `.claude/rules/python-suppressions.md` offers no pre-authorized pattern for
`reportPrivateUsage`, and inventing one would have been the worse outcome. **The rename is the correct
fix, not a workaround.** The substance of the plan's acceptance is preserved exactly: each fixture is
defined once and imported by both consumers, and no fixture is duplicated.

`_halted_item_keys` to `halted_item_keys` in `scripts/dev_tools/parallel_drift_detection_cli.py` is a
genuine production rename and does widen the importable surface by one name. Three considerations make
it acceptable:

1. It is **deliberately absent from `__all__`**, verified: `__all__` lists exactly
   `RESULT_HALT_REQUIRED`, `RESULT_NO_ESCAPE`, `RESULT_NO_NEW_CONFLICT`, `build_parser`,
   `default_timestamp`, `evaluate_drift`, `main`. The function is reachable but not advertised.
2. `_start_markers` remains private, so the change is minimal rather than a blanket de-privatization.
3. Direct access is **necessary**, not convenient. The two-candidate branch of `halted_item_keys` is
   unreachable through `evaluate_drift`, because `recompute_conflicts_with_observed` returns only
   pairs containing the drifting item. Without direct access that branch could not be covered at all,
   and the module's 100% branch figure would be unattainable.

It does not widen the public surface improperly. It does, however, expose a function whose input
validation weakened in the same change — see F8-N14.

### (b) The `ConvertFrom-Json` full-ISO coercion divergence

**Severity: Non-blocking. Deferring the fix was correct; the characterization of its impact was not,
and that is recorded as F8-N13.**

Both halves of the divergence were reproduced.

PowerShell, with `at` set to `2026-01-02T00:00:00Z`:

```
at CLR type: System.DateTime
PowerShell Malformed=True UnresolvedItemKeys=[]
```

Python, same document:

```
Python malformed=False unresolved= [501]
```

**Deferring was correct.** The divergence was discovered during execution; the plan's `## Scope
Contract` states that a finding discovered during execution opens a new cycle rather than extending
the current plan. It arises from a PowerShell runtime type-coercion behavior, not from a logic error
in either implementation, so a fix needs its own design (normalize before shape-testing, or accept a
`[datetime]` and re-render it) and its own review. Choosing the minute-precision colon-bearing form
`2026-01-02T00:00` for the four new rows was the right call: that form stays a string in both
runtimes, so the rows pin the string comparison the finding is actually about, and the table's own
comment explains exactly why. That is good practice.

**The characterization is wrong in a way that matters.** Both
`evidence/remediation-baseline/f8-n4-verification.2026-08-09T00-01.md` and
`evidence/qa-gates/remediation-cycle-summary.2026-08-09T00-01.md` state that "the seam test's
fail-closed subset invariant still holds." The harness's subset check is
`foreach ($key in $pythonKeys) { if ($powerShellKeys -notcontains [long]$key) { divergence } }`,
evaluated on `UnresolvedItemKeys` alone. With PowerShell reporting `Malformed=True` and an **empty**
`UnresolvedItemKeys` while Python reports `[501]`, that check **would fire** — as would the
malformed-flag equality check. A full-ISO row cannot be added to the shared table without either
fixing the divergence or widening the harness to treat `Malformed=True` as a superset of every key.

What actually holds is the invariant at the **hook decision level**: `Malformed=True` skips the first
allow branch, `LatestAt` is empty so `$eventAt` stays `''`, and the gate denies. Both surfaces deny,
and PowerShell is strictly more conservative. That is the correct and defensible conclusion; the
evidence attributes it to the wrong mechanism. The next cycle's planner needs the accurate version,
because it determines whether the fix must also touch the harness.

### (c) The MCP PoshQC coverage-denominator divergence

**Severity: Non-blocking for F8. The provenance labelling is adequate. Escalation is warranted and is
recorded as F8-N15.**

Verified independently rather than accepted:

- `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` line 22 imports PoshQC from
  `Join-Path -Path $PSScriptRoot -ChildPath "..\powershell\PoshQC\PoshQC.psd1"` — the **installed
  extension's** bundled resources.
- Line 32 calls `Invoke-PoshQCTest` **without** `-SettingsPath`, so `$SettingsPath` falls back to
  `$script:PesterSettings`, which `PoshQC.psm1:3` defines as
  `Join-Path $ModuleRoot 'settings/pester.runsettings.psd1'` — resolved relative to the **imported**
  module, i.e. the installed bundle, not the worktree.
- The installed bundle's runsettings at
  `C:\Users\DanMoisan\.vscode\extensions\undefined_publisher.drm-copilot-0.0.1\resources\powershell\PoshQC\settings\pester.runsettings.psd1`
  contains **0** occurrences of `enforce-parallel-drift-gate`.

The mechanism and its consequence are exactly as reported. This audit's repo-root run measured
**48** sourcefiles including both drift hooks; the MCP path measures 41.

**Pre-existing and outside the feature diff:** neither the MCP template nor the PoshQC module appears
in `git diff c939b5b8..HEAD`. F8 did not cause it; F8's new files are simply the newest ones it omits.

**Provenance labelling is adequate.** `evidence/qa-gates/coverage-delta.2026-08-09T00-01.md` lines
9-17 state the measurement path per surface, name both invocations, state which one the numbers come
from and why, state both denominators (41 versus 48), and record that test outcomes were identical
between the two. `evidence/remediation-baseline/powershell-test-baseline.2026-08-09T00-01.md` carries
a dedicated `## Coverage-Denominator Divergence` section naming the six omitted files and the
resolution mechanism. A reader cannot mistake which path produced the figures. The one weakness is
cosmetic and recorded as F8-I14: the two artifacts state 47 and 48 without noting that the helpers
module was created between the captures.

**Escalation is warranted.** The defect silently understates the coverage denominator for every
PowerShell file added since the last extension build, which means it would understate the coverage
obligations of F6 (#442) and F7 (#440) as they execute right now — and their reviewers will not read
F8's evidence folder. Recorded as F8-N15 with the recommendation that it get a
`docs/features/potential/` entry or a tracked issue, following the F8-N1 precedent.

### (d) The hook and its Pester suite were split at exactly 500 lines

**Severity: Informational. The split is behavior-preserving and the coverage claim is verified.**

| Check | Result |
| --- | --- |
| Behavior preserved | **PASS.** The split-parity artifact records that the seven moved helpers were verified byte-identical by diffing the pre-split hook's lines 145-348 against the new module's lines 46-249 with an empty diff, and the retained decision-path functions likewise in two ranges. Corroborated behaviorally: the full Pester suite passes at 2089 with the failed count unchanged at 1 |
| No test deleted | **PASS.** `It` blocks: 47 before, 31 + 16 = 47 after. Expanded Pester cases: 59 before, 59 after. Python CLI `def test_` names: 20 before, 20 after, set-identical by `diff` |
| Dot-source guard still works | **PASS.** `if ($MyInvocation.InvocationName -eq '.') { return }` sits after the function definitions, and the helpers dot-source at line 67 is **outside** the guard so a test dot-sourcing the parent also loads the helpers. Both paths are exercised: the suite dot-sources the hook in `BeforeAll` and then calls `Test-ParallelDriftFindingPresent`, which internally calls the helpers-module function `Test-ParallelDriftGateCanonicalTimestamp` — this only resolves if the dot-source chain worked. The non-dot-sourced path is covered by two entrypoint tests that spawn `pwsh -File $UnderTest` and assert exit 0 with an allow decision, and exit 1 on malformed JSON |
| Both files in the coverage denominator | **PASS.** The runsettings diff appends both paths with comments naming issue #446 and stating the reason ("so the new production hook is not excluded from coverage" / "so the Coverage Exclusion Policy's no-production-file-excluded rule still holds after the split"). Confirmed at run time: the JaCoCo report contains **48** `sourcefile` nodes and both hooks are among them |
| Union coverage clears the pre-split benchmark | **PASS, independently recomputed from `artifacts/pester/powershell-coverage.xml`:** `enforce-parallel-drift-gate.ps1` LINE 94/99 = 94.95%; `enforce-parallel-drift-gate-helpers.ps1` LINE 66/66 = 100.00%; **union 160/165 = 96.97%** against the pre-split 139/144 = 96.53%. The claimed figure is exact and it genuinely clears the benchmark |

Comparing against the union rather than either file alone is the correct arithmetic: the benchmark was
captured when the measured surface was one 144-line file, and the split moved 59 measurable lines to
the sibling. Both files also clear the 85% floor independently. The hook's five uncovered lines are
the same dot-source-guarded entrypoint block as at cycle entry, and the count of uncovered lines did
not change while 19 measured lines were added — which is why the union percentage rose rather than
merely held.

The split also improved the design: `enforce-parallel-drift-gate-helpers.ps1` is a cohesive pure
shape-and-derivation module with no entrypoint logic, and the parent retains only the two read seams,
prompt and item resolution, and the decision path. That separation is what let the helpers reach 100%
line and instruction coverage.

### (e) The F8-N1 record

**Severity: Informational. Requirements met.**

| Check | Result |
| --- | --- |
| Exists | **PASS.** `docs/features/potential/2026-08-09-parallel-drift-gate-typescript-parity-divergence.md`, 120 lines |
| Follows the template | **PASS.** Its headings are `# <name> (Potential)`, `## Problem / Why`, `## Proposed Behavior`, `## Acceptance Criteria (early draft)`, `## Constraints & Risks`, `## Test Conditions to Consider`, `## Next Step` — identical to `docs/features/potential/template.md` and to the precedent `2026-08-07-python-repr-quote-selection-divergence.md` |
| Adequately records the divergence | **PASS.** It names the exact insertion point (beside the key-gated `drift_events` dispatch at `parallel-orchestrator-state-core.ts:203`, **outside** the F7 seam at lines 307-314, with the reason), the divergent error set (Python emits one `PARALLEL_DRIFT_GATE_VIOLATION:` per offending item, TypeScript emits nothing under any input), the consequence for MCP consumers, and that Python is authoritative in the interim. It also raises the non-obvious risk a future implementer would otherwise miss: disjunct (a) needs a path-subsumption matcher, and porting one risks the divergent-matcher failure mode this whole feature exists to prevent, so an existing shared implementation should be reused or the scope grows |
| No `.claude/rules/**` edited | **PASS.** No match in the diff file list |
| No TypeScript file edited | **PASS.** No `.ts` or `.tsx` path in the diff file list |

The entry correctly states that amending `.claude/rules/parallel-orchestration.md` to record the
closed divergence belongs at spec review, not at implementation time.

## New Findings

### F8-N11 — step 7 does not say how to obtain a strictly later `computed_at`

- **Severity: Non-blocking**
- Files: `.claude/skills/parallel-orchestrate/SKILL.md` step 7 of `#### Seven-Step Procedure`;
  `scripts/dev_tools/parallel_drift_detection_cli.py:217-224` (`--computed-at`)
- Problem: step 7 tells the parent to apply "the library-built value the detecting invocation already
  emitted as the `observed_radius` payload key, carrying `source: observed` and a `computed_at` that
  must be strictly later than the event's `at`". It states the requirement but not the mechanism. The
  CLI's `--computed-at` **defaults to the resolved `--at`**, so the radius emitted by the invocation
  that records the event carries `computed_at == at`, which I verified does **not** resolve. And a
  re-invocation after remediation emits `observed_radius: null`. An operator following step 7 with
  default flags therefore applies a non-resolving radius and observes the gate still denying, with no
  guidance on why.
- Why it is not Blocking: the necessary condition is stated in step 7, `--computed-at` is documented
  in the parser help, the resolution seam test demonstrates the pattern, and — decisively — disjunct
  (a) is a complete, always-available release path that involves no timestamp at all. The gate cannot
  deadlock.
- Recommended action: add one sentence to step 7 naming `--computed-at` explicitly and stating that
  the radius must be captured from an invocation made while the diff still escapes, because a
  post-remediation invocation emits `null`. The CLI module docstring already carries this residual;
  the SKILL.md is the document the actor reads and does not.

### F8-N12 — the later-started comparator is unreachable from the CLI production path

- **Severity: Non-blocking**
- Files: `scripts/dev_tools/parallel_drift_detection_cli.py:461-468`;
  `scripts/dev_tools/parallel_drift_halt.py` `select_halted_item`;
  `.claude/skills/parallel-orchestrate/SKILL.md` `#### Halt the Later-Started Item`; `spec.md` AC #6
- Problem: `recompute_conflicts_with_observed` builds every returned pair as
  `canonical_pair(drifting, item_key)` — verified by reading the loop — so every pair contains the
  drifting item. After the F8-B2 exclusion, `candidates` always has exactly one entry on the
  production path and the `else` branch never executes. `select_halted_item` and its 30-test suite
  therefore govern **no production decision** in the CLI path; the branch is reachable only by the
  direct-call test `test_halted_item_keys_applies_the_comparator_to_a_pair_without_the_drifter`.
  Meanwhile the SKILL.md still presents "Selection among two candidates is `argmax` over
  `(start_unknown, worktree_created_at, item_key)`" with its three tie-breaks as the operative halt
  rule, and `spec.md` AC #6 is phrased around `select_halted_item` halting the later-started item.
- This is a direct consequence of the remediation I prescribed at cycle entry (option 1: "for each
  newly conflicting pair, halt the peer"), so it is not a deviation from the required action. It is a
  design and documentation consequence worth recording rather than a defect.
- Recommended action: no code change. Either state in the SKILL.md that the comparator is retained
  for the general case and that in the current single-drifter recomputation model the peer is always
  the halted item, or record the observation for the wave-4 integrator. Also consider renaming
  `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls`, which no longer traverses
  the production halt path.

### F8-N13 — two artifacts mischaracterize the seam test's fail-closed invariant

- **Severity: Non-blocking**
- Files: `evidence/remediation-baseline/f8-n4-verification.2026-08-09T00-01.md` lines 191-205;
  `evidence/qa-gates/remediation-cycle-summary.2026-08-09T00-01.md` lines 117-127
- Problem: both state that for the `ConvertFrom-Json` coercion divergence "the seam test's fail-closed
  subset invariant still holds." Verified false at the harness's assertion level: PowerShell yields
  `Malformed=True, UnresolvedItemKeys=[]` while Python yields `malformed=False, unresolved=[501]`, so
  both the malformed-equality check and the "PowerShell dropped Python-unresolved key 501" subset
  check would fire. The invariant that holds is at the hook **decision** level.
- Impact: the next cycle's planner may scope the fix as a one-sided normalization when it also has to
  decide whether the harness should treat `Malformed=True` as a superset of every key. Getting this
  wrong means adding a full-ISO row and discovering the harness fails.
- Recommended action: correct the wording in a dated amendment to the f8-n4 artifact, distinguishing
  the decision-level invariant (holds) from the harness-level assertion (would fire).

### F8-N14 — now-public `halted_item_keys` no longer validates an unresolvable pair endpoint

- **Severity: Non-blocking**
- File: `scripts/dev_tools/parallel_drift_detection_cli.py:449-469`
- Problem: the single-candidate branch adds `candidates[0]` directly without a `markers` lookup, so a
  pair naming an item absent from `items[]` is returned as a halt target instead of raising. Verified:
  `halted_item_keys(items, [(446, 999)], 446)` returns `(999,)` with no exception, where 999 has no
  item record. The pre-cycle code reached `markers[second]` unconditionally and would have raised.
  The docstring's `Raises:` section claims `ParallelDriftInputError` for "a start marker is malformed,
  or if a pair names one item twice" — neither covers this case, so the behavior is undocumented on
  both sides of the change.
- Mitigating: within the documented contract this is unreachable, because pairs come from
  `recompute_conflicts_with_observed` over the same `items`, and `_start_markers` still validates every
  item record eagerly. But the function became importable in the same change (item a), so the exposure
  is new.
- Recommended action: either guard the single-candidate branch with a `markers` membership check that
  raises `ParallelDriftInputError`, or state in the docstring that pair endpoints are assumed
  resolvable because the only caller derives them from the same `items` collection.

### F8-N15 — the MCP coverage-denominator divergence has no durable repo-level record

- **Severity: Non-blocking**
- Problem: the divergence verified in adjudication (c) is recorded only inside F8's evidence folder.
  F6 (#442) and F7 (#440) are adding PowerShell production files to the same integration branch right
  now, and their reviewers will not read F8's evidence. Any of them running only
  `mcp__drm-copilot__run_poshqc_test` will report coverage over a 41-file denominator that silently
  omits their new files, and their coverage gate will pass without measuring the code it exists to
  measure.
- Recommended action: create a `docs/features/potential/` entry or a tracked issue naming the
  resolution mechanism (`run-poshqc-test.ps1` line 22 importing from the installed bundle, line 32
  omitting `-SettingsPath`), the consequence, and the repo-root workaround. Follows the F8-N1
  precedent. Not F8's to fix.

## Code Quality Assessment

### Strengths

- **The producer/consumer seam is bound at run time, not asserted per side.** The resolution seam test
  drives the whole release path in one pass with an explicit control (`ESCAPED_PATH not in
  emitted["paths"]`) that isolates the mechanism. The cross-runtime table pipes one shared row set
  into a live Python process. Both are the right construction for an epic that has shipped silent
  producer/consumer divergence before, where per-side coverage cannot detect the defect.
- **The canonical-timestamp contract is bound in both directions.** Forward: the shared table's four
  rows hold both runtimes to the same verdict. Reverse:
  `re.match(CANONICAL_TIMESTAMP_RE, default_timestamp())` makes a change to `TIMESTAMP_FORMAT` a test
  failure rather than a silent universal resolution failure. The second binding is the less obvious
  one and it is the one that prevents a real deadlock.
- **The canonical rows are asserted directly, not only as cross-runtime agreement.** A regression that
  made both runtimes fail open together would still fail. Agreement-only assertions would not catch
  it.
- **The F8-B2 fix is a structural guarantee, not a tested behavior.** The drifting key cannot enter
  `candidates`, and the comment explains why no zero-candidate branch is needed rather than writing an
  unreachable one to satisfy a coverage tool.
- **Fail-closed is consistent and deliberate throughout.** A non-conforming timestamp on either side
  is unresolved; an unreadable log yields an empty `LatestAt` and denies; a missing radius is
  unresolved; a non-canonical `EventAt` denies before touching the filesystem. Every narrowing is in
  the deny direction and each is documented as such.
- **Residuals are recorded rather than omitted.** The CLI module docstring states its own
  `no_escape`/`null` residual with the sentence "recorded so a reaudit does not read it as a new
  finding". The `#### Layer-1 Narrowing` section states the omission of disjunct (a) plainly and now
  names the recovery. The coercion divergence was recorded rather than quietly worked around. The
  executor also disclosed correcting a fourth test beyond the plan's named three, and disclosed the
  three findings for which no task was planned. This is the standard of disclosure that makes a
  reaudit tractable.
- **Purity is maintained under pressure.** `parallel_drift_resolution.py` states in its module
  docstring that every function is pure and that individual docstrings therefore omit a `Side Effects`
  section — an accurate, non-repetitive way to satisfy the commenting policy. `default_timestamp()`
  remains the single clock read.

### Weaknesses

- The SKILL.md, the document the acting persona reads, is the one place the `computed_at` mechanism is
  not stated (F8-N11).
- Two evidence artifacts overstate what the seam test's invariant covers (F8-N13).
- Three stale or inaccurate comments: the helper count "seven" versus "eight" in five places
  (F8-I10), a claimed dot-source guard that does not exist (F8-I11), and a docstring naming the
  pre-rename `_halted_item_keys` (F8-I12). Each is small; collectively they are the kind of drift the
  commenting policy exists to prevent.
- The 499-line Python module recreates the zero-headroom condition that F8-N10 was raised about
  (F8-I13).
- F8-N5's unbound documented surface grew this cycle (a ninth payload key and a new parser option),
  which raises rather than lowers the value of the run-time binding test that was deferred.

## Regression Verdict

**No regression. Every claimed figure independently reproduced.**

| Claim | Verified result | Match |
| --- | --- | --- |
| Python 3201 passed / 0 failed | `3201 passed in 11.44s`, EXIT 0 | exact |
| Seven Python production modules at 100% line and branch | All seven at 100.00% / 100.00% from `coverage json` | exact |
| Repo-wide 92.04% line / 84.14% branch | 12795/13902 = 92.04%; 4296/5106 = 84.14% | exact |
| PowerShell 2099 tests: 2089 passed / 1 failed / 9 skipped | `Tests Passed: 2089, Failed: 1, Skipped: 9` — 2099 total | exact |
| The single failure is the pre-existing `enforce-pr-author-skill` case | Reproduced by targeted run: same test, same assertion, line 142, `Expected 'allow' But was 'deny'`. File absent from the diff | exact |
| Union hook coverage 160/165 = 96.97% versus 96.53% | Recomputed from the JaCoCo report: 94/99 + 66/66 = 160/165 = 96.97% | exact |
| Every file under 500 lines | Maximum 499 (`parallel_drift_detection.py`) | confirmed |

Additionally verified and not claimed: black `--check` EXIT 0 over 391 files, ruff "All checks
passed!", pyright 0 errors / 0 warnings / 0 informations, the F5 surface-contract suite 36 passed, zero
suppressions added anywhere in the diff, and `validate_evidence_locations.py` EXIT 0.
