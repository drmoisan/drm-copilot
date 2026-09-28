# Code Quality Review — F8 Radius Drift Detection (issue #446)

- Timestamp: 2026-08-09T00-01
- Branch: `feature/parallel-drift-detection-446`, commit `bcf2de15`
- Base: `c939b5b8`
- Scope: full branch diff — 6 new Python production modules, 1 new PowerShell hook, 7 new test
  files, 1 test support module, 3 confined shared-file edits, 2 F5-owned test edits, 5 bundled
  mirrors, 19 evidence artifacts

## Overall Assessment

The implementation is careful, well factored, and unusually well documented. Purity is enforced
structurally rather than by convention: all six pure modules import no `datetime`, `os`, `pathlib`,
`subprocess`, or `random`, every timestamp is a parameter, and both I/O boundaries are isolated in
`parallel_drift_detection_cli.py` and `_parallel_drift_cli_io.py`. Every enum member the feature
emits is validated against the F3-owned constant at emission time, which is a stronger binding than
the epic's prior producer/consumer pairs achieved. Coverage is 100% line and 100% branch on all six
new Python modules, independently recomputed.

Two defects are Blocking. Both are semantic rather than mechanical, and both concern the feature's
central control decision rather than its plumbing.

## Blocking Findings

### F8-B1 — The derived resolution has no producer, so the Layer-2 drift gate has no release path

**Severity: Blocking.**

**Locations.**

- `scripts/dev_tools/parallel_drift_detection.py:193-234` — `unresolved_drift_item_keys`
- `scripts/dev_tools/parallel_drift_detection.py:405-439` — `_is_drift_resolved`, the two disjuncts
- `scripts/dev_tools/_parallel_orchestrator_state_drift.py:90-149` — `validate_drift_gate`
- `scripts/dev_tools/parallel_drift_detection_cli.py:283-292` — the stdout payload
- `.claude/skills/parallel-orchestrate/SKILL.md`, `#### Six-Step Procedure` (steps 1-6) and
  `#### Resolution Semantics`

**The mechanism.** Because F3's `action` enum has no `resolved` member and invariant 18 rejects an
event with zero escaped paths, a clean re-evaluation cannot be recorded as an event. The
reconciliation therefore derived resolution from the item's currently recorded `blast_radius`. An
item K's latest event is unresolved unless:

- (a) every `escaped_paths` entry is subsumed by `blast_radius.paths` under `is_path_subsumed`, or
- (b) `blast_radius.source == 'observed'` and `blast_radius.computed_at > at`.

Both disjuncts require an affirmative write to `items[].blast_radius` by the parent.

**The defect.** Nothing produces that write, and nothing instructs anyone to produce it.

1. F8 ships no checkpoint writer, which is correct — F8 populates structures and F6 owns the
   mutation path. But the resolving write is not a `mutations[]` entry and not a recolor, so it is
   not within F6's scope either. It belongs to the parallel-orchestrator, and it is unassigned.
2. The CLI's stdout payload carries `result`, `item_key`, `at`, `computed_at`, `escaped_paths`,
   `newly_conflicting_pairs`, `halted_item_keys`, and `drift_event`. It does **not** carry the
   observed `BlastRadius` block, even though `recompute_conflicts_with_observed` builds exactly that
   block internally via `radius_from_observed_paths` at
   `parallel_drift_detection.py:318-322`. The parent therefore has no tool output it can apply to
   satisfy disjunct (b). Verified: `grep -rn "radius_from_observed_paths"` across `scripts/` and
   `.claude/` shows the only caller is that one in-memory use; no caller emits or persists the
   result.
3. The SKILL.md section states the derivation but never states the action. `#### Six-Step Procedure`
   ends at step 6, "The child's existing R1 through R5 remediation loop processes the finding
   unmodified." `#### Resolution Semantics` asserts "Both disjuncts are concrete, recordable parent
   actions that the existing R1 through R5 remediation cycle already drives, so nothing deadlocks",
   but no sentence anywhere in the file names the actor, the trigger, or the exact write. A grep of
   the whole SKILL.md for `re-record` returns only that one descriptive phrase inside disjunct (b)'s
   own definition.

**Why the original design did not have this gap.** `spec.md` lines 68-72 assigned resolution an
explicit actor and trigger: a `resolved` entry "which the parallel-orchestrator does exactly when the
child remediation cycle that consumed the synthetic finding exits with `blocking_count == 0`". When
the reconciliation correctly replaced the mechanism (F3 defines no `resolved` member), the actor and
the trigger were not carried across. The derivation inherited the predicate and lost the producer.

**The deadlock, stated plainly.** Consider the ordinary remediation outcome — the executor removes
the out-of-radius change, narrowing the diff back inside the declared radius. Sequence:

1. Item K drifts; the parent appends one event with `escaped_paths = [p]` at `T1` and writes the
   finding.
2. R1-R5 runs; R3 removes `p` from the diff. `items[K].blast_radius` is untouched: still
   `source: declared`, `computed_at` from plan time, `paths` not covering `p`.
3. The next pre-review evaluation returns `no_escape` and `drift_event: null` — correctly, since a
   zero-escape event is not a drift event. **No new event is appended.**
4. K's latest event is still the `T1` event. Disjunct (a) fails: `paths` still does not subsume `p`.
   Disjunct (b) fails: `source` is `declared`.
5. `unresolved_drift_item_keys` returns `(K,)` forever. `validate_drift_gate` emits
   `PARALLEL_DRIFT_GATE_VIOLATION:` the moment K's `merge_status` becomes `pr_open`.
6. K can never open a pull request. Because invariant 20's completion gate requires every
   non-withdrawn item to reach `merged` or `worktree_removed`, the whole run cannot complete.

**Answer to the deadlock question.** Yes — the derivation as delivered can deadlock a child. The
deadlock is on the Layer-2 path, not the Layer-1 path.

**Layer 1 does not deadlock, and its finding-file allowance genuinely prevents R1-R5 from being
blocked.** The hook allows an unresolved item once any finding file exists
(`enforce-parallel-drift-gate.ps1:479-481`). Step 2 of the procedure writes that file at detection
time, strictly before any review delegation, so both the initial review and the R4 re-review
proceed. The allowance is real, not nominal, and is the correct resolution of the §9 gate-point
tension the spec records. The one Layer-1 permanent-deny case is a null or absent
`items[].worktree_path`, which blocks both the write and the presence check; that is a fail-closed
deny on missing durable state and is recoverable, since Cache Doctrine makes `worktree_path`
re-derivable from `git worktree list --porcelain`.

So the two layers fail in opposite directions: Layer 1 is correctly live, and Layer 2 is correctly
safe but not live.

**Fail-closedness assessment.** The derivation is genuinely fail-closed in the safety direction:
absent an affirmative write nothing resolves, a missing or unreadable radius is unresolved, a
malformed log is unresolved, and `has_unresolved_drift` returns `True` on refusal. That is the right
default for the epic's dominant failure mode. The defect is not excessive strictness; it is that
strictness was delivered without the matching release.

**Remedy (minimal, no schema change, no enum change).** Two edits, either of which alone closes the
deadlock; both together are preferable:

1. Add a seventh documented step to `#### Six-Step Procedure` naming the actor, the trigger, and the
   exact write. For example: "7. When the child's remediation cycle exits with
   `blocking_count == 0`, the parallel-orchestrator re-records the item's radius from the
   post-remediation diff — `blast_radius` rebuilt by `radius_from_observed_paths` with
   `source: observed` and `computed_at` set to the current instant, which must be strictly later
   than the event's `at` — or, when the resolution widened the declared radius instead, extends
   `blast_radius.paths` to cover every escaped path. Either write clears the derived unresolved
   state; nothing else does."
2. Extend the CLI's stdout payload with an `observed_radius` object (the `BlastRadius` the
   recomputation already builds, serialized), so the parent applies a tool-produced value rather
   than hand-constructing one. Hand construction is exactly what the reconciliation's IC-1b MANDATE
   prohibits, because it drops the module and shared-surface disjuncts.

Add a test that binds the documented resolving write to the derivation: construct a checkpoint,
apply each documented write, and assert `unresolved_drift_item_keys` returns empty. That converts
the release path from prose into an executed contract.

### F8-B2 — Halt selection can select the drifting item, contradicting spec constraint 1 and a user-story acceptance criterion

**Severity: Blocking.**

**Locations.**

- `scripts/dev_tools/parallel_drift_halt.py:167-195` — `select_halted_item`
- `scripts/dev_tools/parallel_drift_detection_cli.py:374-408` — `_halted_item_keys`
- `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py:283-299` —
  `test_evaluate_drift_halts_the_later_started_item_of_a_new_conflict`
- `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py:303-317` —
  `test_evaluate_drift_selects_one_halted_item_per_newly_conflicting_pair`
- `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py:339-374`
- `.claude/skills/parallel-orchestrate/SKILL.md`, `#### Halt the Later-Started Item`

**The defect.** `recompute_conflicts_with_observed` returns canonical pairs of the form
`(drifting, peer)` — the drifting item is a member of every returned pair. `_halted_item_keys` then
applies `select_halted_item` to each pair with no exclusion of the drifting item. When the drifting
item is the later-started member, the drifting item is the item halted.

This is not hypothetical; the feature's own tests assert it. In
`test_evaluate_drift_halts_the_later_started_item_of_a_new_conflict` the drifting item is 446, with
`worktree_created_at = "2026-08-08T09-00"`, against peer 445 at `"2026-08-08T08-00"`:

```
result = _evaluate(state, ["packages/mcp-server/src/index.ts"])
assert result["newly_conflicting_pairs"] == [[445, 446]]
assert result["halted_item_keys"] == [446]          # 446 is the DRIFTING item
```

`test_evaluate_drift_selects_one_halted_item_per_newly_conflicting_pair` repeats it: the drifting
item 446 appears in `halted_item_keys == [446, 447]`.

The frequency is not marginal. `_start_rank` ranks equal timestamps by `item_key`, so for the normal
same-minute cohort fan-out the item with the larger `issue_num` is deemed later-started. Whenever
the drifting item carries the larger `issue_num` of a conflicting pair — roughly half of same-minute
pairs — the drifting item is halted.

**What this contradicts.**

- `spec.md` `## Behavior`: "**Halt the later-started item, not the drifting item.** ... Halting the
  drifting item is not an option and **must not be implemented** or offered as a configuration."
- `spec.md` `## Constraints & Risks` item 1: same wording.
- `user-story.md` `## Acceptance Criteria`: "the **later-started** item of the pair is halted ...;
  the drifting item is **never** the one halted."
- `user-story.md` `## Non-Goals`: "Halting or unwinding the drifting item."
- `user-story.md` Scenario 2's rationale: "#520 — whose broader work already exists — keeps
  running".
- Design §7's rationale: "the drifting item's work is already broader than planned and is more
  expensive to unwind." When the drifting item is halted, the design's stated reason for the rule is
  defeated in exactly the case it is applied.

**Is it an inversion?** Not in the narrow sense. `select_halted_item` receives two `ItemStart`
markers and no drift information, so no code path selects an item *by virtue of drifting*; the
module docstring's claim on that point (`parallel_drift_halt.py:17-22`) is accurate and is a real
structural guarantee. The defect is the absence of a drifting-item exclusion at the call site, one
level up, in `_halted_item_keys`.

**Compounding problem — the deviation is unrecorded and the prose was quietly weakened.** The
SKILL.md states "The drifting item is **never** halted **by virtue of drifting**". That qualifier
converts an unconditional prohibition into a statement about mechanism, and it is not flagged as a
reconciled deviation anywhere. `upstream-contract-reconciliation.2026-08-08T21-19.md` records seven
corrections to the orchestrator's findings and several plan deviations, but contains no entry for
this one — and this is the one substantive behavioural narrowing in the feature. The same qualifier
reappears in the acceptance-criteria check-off evidence at line 186 as the justification for
considering "the halt half fully delivered".

**Root cause.** Design §7 is genuinely ambiguous: its rule ("halt the later-started item") and its
rationale ("rather than the drifting item") coincide only when the drifting item started earlier,
and the design never addresses the other case. The spec resolved the ambiguity explicitly in favour
of never halting the drifting item. The implementation resolved it the other way, silently.

**Remedy — one of the following, not both.**

1. **Honour the spec as written (recommended).** Exclude the drifting item from halt candidacy: for
   each newly conflicting pair `(drifting, peer)`, halt `peer` unconditionally. This preserves the
   drifting item's broader work, which is the design's stated purpose, and makes the two documents
   consistent with the code. `select_halted_item` remains useful and unchanged for any future
   two-way selection, and the drifting-item exclusion belongs in `_halted_item_keys` where the
   drifting key is already known. Add a test asserting the drifting item never appears in
   `halted_item_keys`, including the equal-timestamp larger-`issue_num` case that currently halts it.
2. **Amend the requirements.** If halting the later-started item is intended even when that is the
   drifting item, then `spec.md` constraint 1, the `## Behavior` paragraph, the `user-story.md` AC,
   and the `user-story.md` Non-Goal must be amended, the deviation must be recorded in the
   reconciliation artifact with the design-ambiguity analysis, and the SKILL.md must state the
   consequence explicitly rather than relying on the "by virtue of drifting" qualifier. This path
   changes requirements, so it needs the same adjudication any scope change needs.

The current state — code and tests implementing behaviour that four unamended requirement
statements prohibit — is not acceptable under either reading.

## Non-blocking Findings

### F8-N1 — TypeScript Layer-2 gate parity absent, with no durable record

`extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` validates
`drift_events[]` **shape** (`validateDriftEvents` dispatched at line 203-205, invariant 18) but has
no drift-**gate** dispatch. For a checkpoint carrying an unresolved drift event and a progressed
`merge_status`, the Python validator emits `PARALLEL_DRIFT_GATE_VIOLATION:` and the TypeScript core
emits nothing, so the two runtimes disagree on the error set.

**Ruling: Non-blocking.** Reasons: the approved plan and the spec both assign F8 no TypeScript task
("No TypeScript: the MCP `artifact_type` wiring is F3's", `spec.md` Implementation Strategy);
`.claude/rules/parallel-orchestration.md` names the Python validator authoritative and the
TypeScript port a parity port; no existing TypeScript fixture triggers the invariant, so the
divergence is latent rather than failing; and the rule file itself already documents three
pre-existing divergence classes for this port, establishing that a recorded divergence is the
repository's accepted disposition rather than an automatic block.

**Required record.** F8's own evidence artifact is not sufficient — a feature-folder note is not
discoverable by the next reader of the TypeScript port. The divergence needs a durable
repository-level record following the precedent the rule file itself cites for this port,
`docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`. Create either a
`docs/features/potential/` entry or a tracked issue naming: the missing dispatch, the exact
divergent error set, the file and insertion point (`parallel-orchestrator-state-core.ts`, alongside
the existing key-gated `drift_events` dispatch and outside the F7 seam), and the fact that the
Python validator is authoritative in the interim. Amending `.claude/rules/parallel-orchestration.md`
is not the right instrument here, because policy documents are not to be modified by feature work.

### F8-N2 — Layer-1 narrowing to disjunct (b) only: residual risk

The hook implements only disjunct (b) (`Test-ParallelDriftGateEventResolved`, lines 287-312),
omitting (a) because it needs F1's glob semantics and duplicating that matcher in PowerShell would
create the divergent-matcher failure the feature exists to prevent.

**Ruling: Non-blocking; the residual risk is low and correctly bounded.** The narrowing is
deny-only by construction: omitting a resolution disjunct can only move a verdict from resolved to
unresolved, never the reverse. The cross-runtime seam test asserts the subset direction on **every**
row ("PowerShell must never allow an item key Python reports as unresolved") and exact equality on
all seventeen rows except the one documented `Widened = $true` row, and a separate test pins that
row's expected conservative verdict. The executor's non-vacuity check — mutating the hook and
observing failure — is the right verification for a parity test of this kind. The practical residual
risk is a spurious Layer-1 deny for an item whose radius was widened rather than re-recorded, and
the finding-file allowance absorbs it: any item that reached the widened-radius state necessarily
had a finding written, so the gate allows anyway. The seam test would catch a future PowerShell edit
that drifted in the allow direction.

One improvement: the SKILL.md's `#### Layer-1 Narrowing` subsection explains the limitation but does
not state the operator's recovery action if a spurious deny is ever observed. Add one sentence
naming it (re-record the radius from the later observed diff, which satisfies both runtimes).

### F8-N3 — Finding-presence check matches any `remediation-inputs.*.md`, so a stale finding opens the Layer-1 gate

`Test-ParallelDriftFindingPresent` (`enforce-parallel-drift-gate.ps1:102-111`) returns `$true` for
the first file whose name starts with `remediation-inputs.` and ends with `.md`. It does not compare
the file's timestamp against the drift event's `at`, and it does not check content.

A child feature folder will commonly already contain `remediation-inputs.<timestamp>.md` from an
earlier, unrelated remediation cycle — a CI-failure cycle, for instance. In that case an item whose
drift finding has **not** been written passes the presence check and the gate allows review of
drifted, unsurfaced work, which is precisely the case the Layer-1 gate exists to deny. This is a
fail-open path in a feature whose brief is to prefer fail-closed behaviour.

**Ruling: Non-blocking.** Layer 2 still forbids merge progression, so no drifted item can reach a
pull request through this hole; the impact is one wasted review pass, not an escaped defect.

**Remedy, still presence-gating only and still no glob matcher.** Require the matched file's
embedded `yyyy-MM-ddTHH-mm` timestamp to be ordinally `>=` the latest drift event's `at`. The
substring is extractable with `Substring` and compared with `CompareOrdinal`, so the hook adds no
git call, no glob match, and no content read.

### F8-N4 — Ordinal timestamp comparison with no canonical-format contract

Disjunct (b) compares `blast_radius.computed_at > at` as raw strings in both runtimes
(`parallel_drift_detection.py:434-439`; hook line 311 via `CompareOrdinal`). The two runtimes agree
with each other, which the seam test proves, but neither validates or normalizes the format.

ISO-8601 admits several renderings, and the repository uses at least two: the colon-free
`yyyy-MM-ddTHH-mm` that `TIMESTAMP_FORMAT` emits (`parallel_drift_detection_cli.py:120`), and
conventional colon-bearing forms elsewhere. Ordinally `-` (0x2D) sorts below `:` (0x3A), so a
`computed_at` written as `2026-01-01T10:00:00Z` compares **greater** than an `at` written as
`2026-01-09T10-00`, and drift resolves spuriously — a fail-open inversion. F3 constrains
`computed_at` only to "non-empty string", so nothing prevents the mixture.

**Ruling: Non-blocking**, because both fields are produced by the same surface today and the CLI
default emits one shape. **Remedy:** state the canonical shape once in the SKILL.md's
`#### Resolution Semantics` ("both `at` and `blast_radius.computed_at` are recorded as
`yyyy-MM-ddTHH-mm`; the comparison is ordinal and assumes that shape"), and add a parity row with a
colon-bearing `computed_at` so the assumption is at least visible in the test table.

### F8-N5 — No run-time binding between the documented CLI surface and the argparse implementation

The CLI's argument surface, stdout key set, `result` vocabulary, and exit codes are stated three
times: in `parallel_drift_detection_cli.py`'s module docstring, in the SKILL.md's
`#### CLI Invocation`, and in the argparse configuration plus `evaluate_drift`'s return dictionary.
No test reads the SKILL.md and compares it against `build_parser()` or the payload keys — verified
by grepping every new test file for `SKILL.md`, which returns nothing.

This is the pattern the epic's history warns about: the brief records that the epic has twice
shipped a producer and consumer that diverged silently at 100% per-side coverage. Every other
producer/consumer pair in this feature has a run-time binding; this one does not.

**Ruling: Non-blocking** — the consumer is a human-or-agent reader of documentation, not executing
code, so a divergence misleads rather than breaks. **Remedy:** add one test that extracts the fenced
invocation block and the JSON block from the SKILL.md section and asserts, at run time, that the
option strings match `build_parser()`'s actions and that the JSON keys equal the key set
`evaluate_drift` returns.

### F8-N6 — Exported quiesce predicate widened to two arguments without a recorded deviation

`spec.md`'s API surface and the reconciliation's IC-6a both state the exported contract as
`has_unresolved_drift(events) -> bool`. The delivered signature is
`has_unresolved_drift(events, items)` (`parallel_drift_detection.py:237-264`), necessarily, because
resolution is derived from each item's `blast_radius`.

The widening is correct and the SKILL.md documents the two-argument form. But IC-6a in the
reconciliation artifact still states the one-argument contract, and F6 — executing concurrently and,
per the same artifact, carrying no reference to `has_unresolved_drift` in its own spec — is the
consumer that will wire the call.

**Ruling: Non-blocking.** **Remedy:** record the amended IC-6a signature explicitly alongside the
IC-3a resolution-semantics deviation it follows from, so F6's planner reads the delivered contract
rather than the assumed one.

### F8-N7 — Spec AC #7's check-off rests on the stub escape clause

AC #7 reads "the requeue appends exactly one `mutations[]` entry and increments
`recolor_generation` by one, routed through the single recolor seam (F6's entry point **or the
documented stub**)". No delivered code appends a mutation or increments a generation:
`request_requeue_via_recolor` returns a frozen `RequeueRequest` describing the intended writes.

The escape clause makes the check-off defensible, and the seam decision is right — F2's landed
`parallel_cohort_computation.py` exposes only whole-graph `compute_cohorts` with no pinned-subgraph
recolor, so there is nothing to delegate to, and a second recolor implementation is explicitly
prohibited. `test_halt_module_contains_no_graph_coloring_logic` proves the absence structurally by
parsing the module's own AST and pinning its exact function set, which is a stronger check than a
textual grep.

**Ruling: Non-blocking** — evaluated PARTIAL in the feature audit and recorded there. No code change
required; the gap closes when F6 lands.

### F8-N8 — Cross-runtime seam test spawns an external interpreter resolved from machine PATH

`tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1:210-303` resolves `python` or `py`
via `Get-Command ... -CommandType Application`, sets `PYTHONPATH`, and pipes a here-string harness
into that interpreter. `.claude/rules/general-unit-test.md` prohibits external processes in unit
tests; `.claude/rules/powershell.md` prohibits dependence on mutable machine PATH state and requires
Terminal/Test-Explorer parity. A grep for `Get-Command python`, `& python`, or `python -c` across
`tests/scripts/` matches only this file, so there is no precedent to cite.

**Ruling: Non-blocking, and the trade is the right one.** A genuine run-time cross-runtime binding
is worth more here than rule-literalism, because the alternative — two hardcoded truth tables — is
exactly the failure mode the epic has already shipped twice. The test is also well built: one shared
row table, both runtimes evaluated over it, the fail-closed subset direction asserted on every row.
The missing-interpreter case fails rather than silently skips, which is the safe direction.

**Remedy:** record the deviation explicitly — a comment in the test's `BeforeAll` naming the two
rules being deviated from and why, so a future reader does not "fix" it into two constants.

### F8-N9 — US-4's unchecked-disposition reason omits the "never halted" clause

`evidence/qa-gates/acceptance-criteria-checkoff.2026-08-08T23-24.md` attributes US-4's unchecked
state solely to F6's recolor entry point and asserts "the halt half is fully delivered and tested",
citing "the structural guarantee that the selection function receives no drift information so the
rule cannot be inverted". The criterion also contains "the drifting item is never the one halted",
which is unmet for F8's own reasons (F8-B2) and is not a cross-feature dependency.

**Ruling: Non-blocking as a documentation defect** (the item is unchecked either way, so no AC state
is wrong). The underlying behaviour is F8-B2. **Remedy:** restate US-4's reason to name both unmet
clauses and their distinct owners.

### F8-N10 — Hook and its test are each exactly 500 lines

Both `.claude/hooks/enforce-parallel-drift-gate.ps1` and
`tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` are exactly 500 lines.

**Ruling: compliant, Non-blocking.** The rule is "may not exceed 500 lines"; 500 does not exceed
500.

**On whether the help-block compression harmed readability: it did not.** The `.SYNOPSIS`,
`.DESCRIPTION`, and `.NOTES` block (lines 1-47) is dense but complete and well organised: it states
the activation conditions, the full decision procedure, the presence-gating-only constraint with its
rationale, the resolution-semantics ownership, the exact narrowing and its direction, the pointer to
the seam test, and the Layer-2 counterpart. Every function additionally carries its own
`.SYNOPSIS`/`.DESCRIPTION`. Nothing material was cut to reach the cap.

**However, zero headroom is a real maintenance cost.** Both files sit at the boundary, so any future
edit — including the one-line change F8-N3 recommends — forces a split before it can land. Split
proactively rather than under pressure: the eight shape-and-derivation helpers
(`Test-ParallelDriftGateItemKey` through `Get-ParallelDriftGateUnresolvedState`, lines 145-348) are
cohesive, have no dependency on the decision path, and would move cleanly behind the existing
dot-source guard.

## Informational Observations

- **F8-I8.** `validate_drift_gate` returns `[]` when `items` is absent or not a list
  (`_parallel_orchestrator_state_drift.py:113-122`), so the gate is inert for that checkpoint. F3
  reports the missing key or wrong type, so overall validation still fails and no progression is
  admitted; the comment states the reasoning. Acceptable, and the deliberate choice to emit one
  fail-closed error when the pure module refuses, and one more when a non-object entry left the gate
  inert for that entry, shows the "silently inert gate" risk was considered directly.
- **F8-I9.** `default_timestamp` has minute resolution and disjunct (b) requires a strict `>`, so a
  remediation completing inside the same minute as the event cannot resolve it until the next minute.
  Harmless in practice.
- **F8-I7.** `FILLED_RESERVED_HEADINGS` is designed for one entry per line so the three wave-4
  features do not contend, which is the right instinct. The tuple's closing parenthesis is still a
  shared line, so F6's and F7's appends may produce a trivial fan-in conflict there. Worth flagging
  to the wave-4 integrator; not worth changing.
- **F8-I5.** `spec.md` AC #11 names the H2 `## Radius Drift Detection and Drift Gate`, which does not
  exist. The landed reserved title is `## Radius Drift Detection (F8)`, and F8 correctly filled it in
  place and used the spec's name as its H3. The deviation is properly recorded in the
  reconciliation's IC-5b. Using H3 sub-headings also preserved the sixteen-`##` layout the F5
  contract test pins — a deliberate and correct choice.
- **F8-I6.** Eighteen evidence artifacts are named with local time; one,
  `shared-file-edit-confinement.2026-08-09T03-19.md`, is named with UTC while its mtime is
  `2026-08-08 23:21:08 -0400`. Cosmetic, but it makes the phase ordering read out of sequence.

## What Was Done Well

Recording these because they should survive into the next wave-4 feature.

- **Purity enforced structurally, not by convention.** No pure module imports a clock, filesystem,
  or subprocess API. Both I/O boundaries are named modules with their own docstrings explaining why
  they exist.
- **Every emitted enum member is validated against the F3-owned constant at emission time**
  (`require_enum_member`). A member F3 renames fails at the producer with a literal message, not at
  the validator with a shape error.
- **Structural rather than textual proof of a negative.** `test_halt_module_contains_no_graph_coloring_logic`
  parses the module's AST and pins its exact function set, so prose cannot satisfy or break the
  boundary claim.
- **The cross-runtime seam test executes both runtimes over one shared table.** This is the correct
  answer to the epic's repeated producer/consumer divergence, and the executor verified non-vacuity
  by mutation.
- **The reconciliation artifact caught four real upstream errors** before code was written: the
  absent `resolved` enum member, `new_state: "blocked_drift"` being schema-invalid against the
  item-state enum, F6's real entry-point name, and the `is_path_subsumed` provenance. The
  `new_state` correction alone would otherwise have produced a checkpoint rejected at the next
  validation.
- **The F5-owned test edit inverts an obligation instead of deleting it**, and guards its own
  exemption set with a subset assertion. That is the right shape for a shared-fixture change under
  concurrency.
- **Fail-closed choices are commented with their reasons at each site**, including the non-obvious
  one that the contention relation reports no conflict for an empty radius, so an unevaluable peer
  must be treated as conflicting.

## Summary

| Severity | Count | IDs |
| --- | --- | --- |
| Blocking | **2** | F8-B1, F8-B2 |
| Non-blocking | 10 | F8-N1 … F8-N10 |
| Informational | 9 | F8-I1 … F8-I9 |
