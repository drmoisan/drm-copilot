# Remediation Inputs — F8 Radius Drift Detection (issue #446)

- Timestamp: 2026-08-09T00-01
- Branch: `feature/parallel-drift-detection-446`, commit `bcf2de15`
- Baseline: `c939b5b8`
- Source artifacts:
  - `docs/features/active/2026-08-07-parallel-drift-detection-446/policy-audit.2026-08-09T00-01.md`
  - `docs/features/active/2026-08-07-parallel-drift-detection-446/code-review.2026-08-09T00-01.md`
  - `docs/features/active/2026-08-07-parallel-drift-detection-446/feature-audit.2026-08-09T00-01.md`
- Blocking count: **2**

## Remediation-Required Findings

### F8-B1

- Severity: Blocking
- Title: The derived resolution has no producer, so the Layer-2 drift gate has no release path
- Files:
  - `.claude/skills/parallel-orchestrate/SKILL.md` — `## Radius Drift Detection (F8)`,
    subsections `#### Six-Step Procedure` and `#### Resolution Semantics`
  - `scripts/dev_tools/parallel_drift_detection_cli.py:283-292` — the stdout payload
  - `scripts/dev_tools/parallel_drift_detection.py:405-439` — `_is_drift_resolved`, for reference
- Problem: resolution is derived from `items[].blast_radius`, but no code writes either resolving
  form, the CLI does not emit the observed radius it already builds internally, and no document
  instructs any actor to perform the write. An item that remediates by narrowing its diff — the
  ordinary outcome — leaves `blast_radius` untouched, so `unresolved_drift_item_keys` returns that
  item permanently and `validate_drift_gate` blocks every progression to `pr_open`, `ci_green`,
  `merged`, and `worktree_removed`. Invariant 20's completion gate then prevents the run from
  completing. `spec.md:68-72` originally assigned resolution an explicit actor and trigger; the
  reconciliation replaced the mechanism and did not carry the actor or the trigger across.
- Required action:
  1. Add a seventh step to `#### Six-Step Procedure` naming the actor (`parallel-orchestrator`), the
     trigger (the child's remediation cycle exiting with `blocking_count == 0`), and the exact write:
     rebuild `items[].blast_radius` via `radius_from_observed_paths` with `source: observed` and a
     `computed_at` strictly later than the event's `at`, or extend `blast_radius.paths` to cover every
     escaped path. State that no other write clears the derived unresolved state.
  2. Add an `observed_radius` object to the CLI stdout payload, serialized from the `BlastRadius` the
     recomputation already builds, so the parent applies a library-produced value rather than
     hand-constructing one — hand construction is prohibited by the IC-1b MANDATE because it drops
     the module and shared-surface disjuncts.
  3. Add a test that applies each documented resolving write to a constructed checkpoint and asserts
     `unresolved_drift_item_keys` returns empty, converting the release path from prose into an
     executed contract.
  4. Update the `#### Resolution Semantics` claim "Both disjuncts are concrete, recordable parent
     actions that the existing R1 through R5 remediation cycle already drives, so nothing deadlocks"
     so it cites the new step rather than asserting the property without a producer.
- Do not: add a `resolved` member to `drift_events[].action`, add any checkpoint field, or relax the
  Layer-2 invariant. The gate's strictness is correct; only its release is missing.

### F8-B2

- Severity: Blocking
- Title: Halt selection can select the drifting item, contradicting `spec.md` Constraints #1 and
  `user-story.md` AC US-4
- Files:
  - `scripts/dev_tools/parallel_drift_detection_cli.py:374-408` — `_halted_item_keys`, the call site
    that applies later-started selection to pairs that always contain the drifting item
  - `scripts/dev_tools/parallel_drift_halt.py:167-195` — `select_halted_item` (correct in isolation;
    receives no drift information)
  - `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py:283-299` and `:303-317` — assert the
    drifting item is halted
  - `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py:339-374`
  - `.claude/skills/parallel-orchestrate/SKILL.md` — `#### Halt the Later-Started Item`, the phrase
    "never halted **by virtue of drifting**"
- Problem: `recompute_conflicts_with_observed` returns pairs of the form `(drifting, peer)`, and
  `_halted_item_keys` applies later-started selection without excluding the drifting item, so the
  drifting item is halted whenever it started later. Because `_start_rank` breaks equal timestamps by
  `item_key`, this occurs for roughly half of same-minute cohort pairs. Four unamended requirement
  statements prohibit it: `spec.md` `## Behavior` and Constraints #1 ("Halting the drifting item is
  not an option and must not be implemented"), `user-story.md` AC US-4 ("the drifting item is never
  the one halted"), and `user-story.md` Non-Goals. Design §7's rationale — the drifting item's work
  is broader and more expensive to unwind — is defeated in exactly the case the code halts it. The
  SKILL.md's "by virtue of drifting" qualifier narrows the prohibition without recording a deviation.
- Required action — choose one:
  1. **Honour the requirements as written (recommended).** Exclude the drifting item from halt
     candidacy in `_halted_item_keys`: for each newly conflicting pair, halt the peer. Update the
     three affected tests. Add a test asserting the drifting item never appears in
     `halted_item_keys`, including the equal-timestamp larger-`issue_num` case that currently halts
     it. Remove the "by virtue of drifting" qualifier from the SKILL.md, which then states the
     unconditional rule truthfully.
  2. **Amend the requirements.** If halting the later-started item is intended even when that is the
     drifting item, amend `spec.md` `## Behavior`, `spec.md` Constraints #1, `user-story.md` AC US-4,
     and `user-story.md` Non-Goals; record the deviation in
     `evidence/other/upstream-contract-reconciliation.*.md` with the design-§7 ambiguity analysis;
     and state the consequence explicitly in the SKILL.md. This path changes requirements and needs
     the same adjudication any scope change needs.
- Also required either way: correct US-4's disposition in
  `evidence/qa-gates/acceptance-criteria-checkoff.*.md` so it names both unmet clauses and their
  distinct owners (F8-N9).

## Non-Blocking Findings Recommended for the Same Cycle

These do not gate merge. The first three are cheap and reduce real risk.

| ID | Title | File / location | Recommended action |
| --- | --- | --- | --- |
| F8-N3 | Any `remediation-inputs.*.md` satisfies the Layer-1 finding-presence check, so a stale finding from an earlier cycle opens the gate | `.claude/hooks/enforce-parallel-drift-gate.ps1:102-111` | Require the matched file's embedded `yyyy-MM-ddTHH-mm` substring to be ordinally `>=` the latest drift event's `at`. Still presence gating only: `Substring` plus `CompareOrdinal`, no git call, no glob match |
| F8-N4 | Ordinal timestamp comparison with no canonical-format contract can resolve drift spuriously | `scripts/dev_tools/parallel_drift_detection.py:434-439`; hook line 311 | State the canonical `yyyy-MM-ddTHH-mm` shape for both `at` and `blast_radius.computed_at` in `#### Resolution Semantics`, and add a parity row with a colon-bearing `computed_at` |
| F8-N1 | TypeScript Layer-2 drift-gate dispatch absent; no durable repo-level record | `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` | Create a `docs/features/potential/` entry or a tracked issue, following the precedent `.claude/rules/parallel-orchestration.md` itself cites (`docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`). Record the missing dispatch, the divergent error set, the insertion point beside the existing key-gated `drift_events` dispatch and outside the F7 seam, and that the Python validator is authoritative meanwhile. Do not modify the rule file |
| F8-N5 | No run-time binding between the documented CLI surface and the argparse implementation | `.claude/skills/parallel-orchestrate/SKILL.md` `#### CLI Invocation`; `scripts/dev_tools/parallel_drift_detection_cli.py:142-204,283-292` | Add a test that extracts the fenced invocation block and JSON block from the SKILL.md and asserts, at run time, that option strings match `build_parser()`'s actions and JSON keys equal `evaluate_drift`'s key set |
| F8-N6 | Exported `has_unresolved_drift` takes two arguments, widening the reconciled IC-6a contract | `evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md` IC-6a | Record the amended two-argument signature alongside the IC-3a derivation it follows from, so F6's planner reads the delivered contract |
| F8-N2 | Layer-1 narrowing lacks a stated recovery action | `.claude/skills/parallel-orchestrate/SKILL.md` `#### Layer-1 Narrowing` | Add one sentence naming the recovery for a spurious deny: re-record the radius from the later observed diff, which satisfies both runtimes |
| F8-N8 | Cross-runtime seam test spawns `python` resolved from machine PATH, against two rules, without a recorded exception | `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1:210-230` | Add a comment in `BeforeAll` naming `.claude/rules/general-unit-test.md` (no external processes) and `.claude/rules/powershell.md` (no PATH dependence) and why the run-time binding is worth the deviation, so a future reader does not replace it with two hardcoded tables |
| F8-N10 | Hook and its test are each exactly 500 lines, leaving zero headroom | `.claude/hooks/enforce-parallel-drift-gate.ps1`; its Pester test | Split proactively: the eight shape-and-derivation helpers at lines 145-348 are cohesive and independent of the decision path. Required in practice before F8-N3's one-line change can land |
| F8-N7 | No code appends the `mutations[]` entry or increments `recolor_generation` | `scripts/dev_tools/parallel_drift_halt.py:198-264` | No change required; closes when F6 lands. Recorded so the SP-7 check-off is not read as a delivered checkpoint write |
| F8-N9 | US-4 disposition omits the "never halted" clause | `evidence/qa-gates/acceptance-criteria-checkoff.2026-08-08T23-24.md` | Folded into F8-B2's required action |

## Explicitly Out of Scope for This Remediation

| ID | Item | Reason |
| --- | --- | --- |
| F8-I3 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` :: `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` fails, so the PowerShell stage exits 1 | Verified pre-existing: identical failure, assertion, and line 142 in the Phase 0 baseline artifact. The file is absent from the branch diff. **It must not be edited to force a green gate.** Its own fix — replacing the real gitignored `orchestrator-state.json` read with a mocked seam — belongs to a separate task against `enforce-pr-author-skill.ps1` |
| F8-I1 | `quality-tiers.yml` absent at the repository root | Verified absent at the base commit `c939b5b8`; a repository-level gap, not caused by and not fixable within F8 |
| F8-I2 | PowerShell branch coverage unavailable | Pester v5 and the PoshQC conversion step emit no `BRANCH` counter; verified by counter-type enumeration at both baseline and final. A toolchain limitation, not a threshold waiver |
| F8-I4 | Property-test density | Satisfied for the tier the rule file's examples imply for dev tooling (T4, density "none"); the exhaustive combinatorial selection test exceeds the obligation. `hypothesis` is correctly not added |
| F8-I5 | Section-title deviation from the spec's `## Radius Drift Detection and Drift Gate` | The landed reserved title is `## Radius Drift Detection (F8)`; filling it in place was mandatory and the deviation is recorded in IC-5b |
| F8-I6, F8-I7, F8-I8, F8-I9 | Timestamp-naming inconsistency, `FILLED_RESERVED_HEADINGS` fan-in line, gate inert on a non-list `items`, minute-granularity strict comparison | Cosmetic or already correctly handled; recorded for the wave-4 integrator |

## Verification Required After Remediation

1. Re-run the full Python toolchain; expect four `EXIT_CODE: 0` stages and no coverage regression on
   any changed line.
2. Re-run `mcp__drm-copilot__run_poshqc_format`, `_analyze`, `_test`; expect the same single
   pre-existing failure and no additional one.
3. Re-run the F5 surface-contract suite so the SKILL.md edits are re-validated against
   `RESERVED_HEADINGS`, `FILLED_RESERVED_HEADINGS`, the sixteen-`##` layout, and the reserved-section
   ordering.
4. Re-verify the four bundled mirrors are byte-identical by SHA-256 after any `.claude` or PoshQC
   edit.
5. Re-verify the validator diff against `c939b5b8` is still exactly two added lines with the dispatch
   above and outside the F7 seam, and that `.claude/settings.json` still shows one appended entry.
6. Re-run `python scripts/dev_tools/validate_evidence_locations.py --root .`; expect exit 0.
