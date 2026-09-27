# blast-radius-over-reports-and-zero-overlap-tolerance (Spec)

- **Issue:** #722
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T12-45
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria live in this file only; no user story)
- **Parallel run:** blast-radius-tolerance-2026-09-27 (preparation mode)
- **Research input:** the research note dated 2026-09-27T12-25 in this feature folder's research directory

## Radius Hygiene Note (read before editing this spec)

The blast radius of this item is derived from this spec and its plan by the current extractor, which
over-reports. In this document, inline code is used ONLY for concrete repository paths that this item
will write. Read-only files are named in plain words. Function names, configuration keys, enum
members, and test names are written in plain text so that they are not harvested as contracts.
Problematic token shapes are shown only inside fenced code blocks. Keep this discipline when the spec
is revised.

## Context

- **Summary.** Parallel-run scheduling is close to serial for two independent reasons.
  1. **Over-reporting.** Blast-radius derivation treats every path mention in plan and spec text as
     a write. Glob mentions, placeholder or example paths, feature-relative fragments, command-span
     tokens, and read-only policy citations all enter the radius.
  2. **Zero tolerance.** Conflict-edge policy turns any detected overlap into a hard scheduling edge,
     regardless of how cheap the overlap would be to integrate.
- **Operator direction (2026-09-27, verbatim):** "raise the risk tolerance. some overlap is ok
  provided that the benefit of parallelism outweighs the cost of integrating the branches."
- **Observed environments.** The self-hosted repository (Python authority plus PowerShell runtime) and
  every destination workspace that receives the pushed-down Claude runtime (PowerShell runtime plus
  the bundled truth table).
- **Impact and severity.** High. Every parallel run is affected. Backlog burn-down throughput is
  limited because items that could run concurrently are serialized into extra cohorts.
- **First observed.** Runs epic-655-followups (2026-09-25), backlog-2026-09-26, and
  followups-2026-09-27. All current versions of the blast-radius library are affected.

## Repro & Evidence

- **Steps to reproduce.** Run the parallel-plan skill over the followups-2026-09-27 item set and
  inspect the resulting conflict edges and cohort assignment. Repeat for the other two runs using
  the manifests on their plan-home refs.
- **Expected.** A conflict edge exists only when the expected integration cost of running two items
  concurrently exceeds the parallelism benefit. Mentions that are not writes contribute nothing.
- **Actual.** The issue records that most item pairs in followups-2026-09-27 conflict, that a glob
  in one epic-655-followups item serialized a peer that only read the overlapping paths, and that
  most backlog-2026-09-26 edges came from paths the plans cited but did not write.
- **Evidence limits.** The research note read the historical manifests through a summarizing fetch.
  For backlog-2026-09-26 and for one epic-655-followups item it elided radius entries. The research
  edge and cohort counts are therefore projections, not verified values. This spec does not use any
  research count as an acceptance threshold. The plan's P0 re-derives every before value with git and
  with both the Python and PowerShell runtimes before any value is pinned into a fixture.
- **Frequency.** Deterministic. The same plan text always produces the same over-reported radius and
  the same edge set.

## Scope & Non-Goals

### In scope (design points 1-7, all mandatory)

1. **Write-intent-only radius extraction.** Ignore glob mentions, placeholder or example paths, and
   read-only or mandate-read policy files. The same filtering governs shared-surface and contract
   derivation: a read citation of a shared surface does not become a hard edge unless the item writes
   it. Add the Copilot instructions file under the .github directory to the mandate-read list.
2. **Per-pair integration-cost weights.** Zero for mergeable paths; low for append-only or registry
   files; high for same-file edits (the proxy for same-symbol or same-region edits); a HARD edge only
   for declared shared surfaces and contract dependencies. Cost is weighed against the parallelism
   benefit with the integer edge rule defined below.
3. **Configurable conflict tolerance.** A new conflict_tolerance key in both copies of the blast-radius
   truth table. The committed value leans toward parallelism. Tolerance 0 reproduces current
   zero-tolerance scheduling exactly (the fail-closed opt-out). An absent key means strict.
4. **Soft overlaps run concurrently.** Tolerated pairs are scheduled into the same or adjacent cohorts
   without a barrier. The later of two tolerated items to merge syncs with main (the orchestrator
   merges origin/main under the existing per-item merge-conflict handling) and re-passes CI.
5. **Rule-file amendment as a configured policy change.** `.claude/rules/parallel-orchestration.md`
   and its bundled mirror record the change as operator-directed configuration, not as ad hoc
   narrowing. Planners still never hand-narrow a radius.
6. **Parity across runtimes and copies.** Python authority, PowerShell modules, TypeScript push-down
   derivation (including its carried-key list), the TypeScript validator port (tolerance of the new
   extra fields, verified by test), the bundled payload mirrors, and the key-partition exhaustiveness
   tests. The bash port is not affected (see Decisions).
7. **Historical-run acceptance evidence.** Before and after edge counts, cohort counts, and maximum
   cohort width for epic-655-followups, backlog-2026-09-26, and followups-2026-09-27, derived by P0
   and pinned into committed fixtures.

Also in scope, as planner constraints:

- The #452 non-regression gate (detection relation unchanged; bidirectional scheduling tests).
- Drift-detection handling of tolerated pairs, through a new helper module.
- Carrying weights, costs, and soft-pair data in tolerated extra fields, with the conflict-edge
  reason enum unchanged.

### Out of scope / non-goals

- Changing the pure detection relation (the conflicts function in Python and Test-BlastRadiusConflict
  in PowerShell) in any way that alters a verdict or reason list.
- Adding a member to the conflict-edge reason enum or to any other F3-owned enum.
- A global (whole-coloring) benefit function. The edge rule stays pairwise so recoloring stays
  deterministic.
- Any change to the bash cohort-coloring entry point or other bash library scripts.
- Rebasing or force-pushing item branches. Soft-overlap integration uses the existing sync-with-main
  path.
- **Recorded follow-up, not implemented here:** noisy spec contract tokens (for example the
  identifiers shown below) that become hard contract-dependency edges. Filing a potential entry for
  this is a follow-up action for the review phase.

```text
allow    deny    new_string,    package.json    index.ts
```

### Explicitly excluded systems

- The epic orchestration surface and its checkpoints.
- The standard orchestrator-state checkpoint.
- The Codex runtime surfaces.

## Root Cause Analysis

Confirmed by the research note, which cites file and line for each stage of the pipeline.

### Over-reporting (extraction)

- Every inline-code span in every plan line and every spec line is harvested and split on whitespace,
  so a multi-word command span yields path tokens.
- Wildcard tokens are admitted when they start with a known top-level segment or end in a recognized
  extension. A token whose literal prefix is empty (a leading double-star glob) overlaps every entry
  of every other radius, including the peer's own feature-folder glob.
- A mandate-read glob entry excludes a citation only on exact string equality, so a narrower glob under
  a mandate-read subtree survives.
- The Copilot instructions file under .github is not a mandate read, so its citation in "read the
  policy" tasks is recorded as a path.
- Placeholder markers are rejected, but placeholder-looking concrete paths and feature-relative
  fragments are not. Examples of the shapes involved:

```text
**/models.ts    .claude/**    tests/*    .github/workflows/*.yml    src/**/*.ts
src/x.ps1    src/x.ts    research/research.<stamp>.md    evidence/other/follow-ups.md
git add src/x.ts
```

- Shared surfaces are resolved from the harvested concrete paths, so a read citation of a shared
  surface becomes a shared-surface overlap, which is a hard reason. Contracts are harvested from spec
  sections whose headings name an API, interface, contract, or surface, including tokens from
  multi-word command spans.

### Zero tolerance (scheduling)

- Conflict edges are built by the planner, by hand, applying the detection relation to every unordered
  pair and recording an edge for every detected conflict. There is no library function for edge
  construction, and no notion of cost or benefit.
- Cohort coloring is a pure function of the edge list and never re-evaluates the relation, so every
  detected overlap becomes a serialization.

### Affected components

- Python: the extraction, normalization, derivation, and validation modules of the blast-radius
  library under scripts/dev_tools; the drift-detection module.
- PowerShell: the blast-radius facade and its sibling modules under the Claude library directory, and
  their bundled mirrors.
- TypeScript: the push-down truth-table derivation core (carried-key list and emitted key order); the
  parallel-state validator port (reads only a, b, and reason on each edge; no production change).
- Configuration: both copies of the blast-radius truth table.
- Documentation: the parallel-orchestration rule, the parallel-plan and parallel-add skills, the
  parallel-planner agent, and their bundled mirrors.

## Proposed Fix

### Design summary (what changes where)

The fix has two layers, delivered as two sequential phase groups of one plan.

- **Part A: integration-cost scheduling layer.** A new pure scheduling function in Python and in
  PowerShell takes the declared radii, per-item complexity bands, and the truth table. It calls the
  unchanged detection relation on each unordered pair and decides whether each conflicting pair
  becomes an edge. Edge construction moves from hand-written planner steps into library code. The
  conflict_tolerance key configures the rule. Drift detection evaluates pairs through the same rule.
- **Part B: write-intent extraction.** A new pure extraction layer in Python and in PowerShell,
  active only when the write_intent_extraction key is true, applies rules W1-W6 below so that only
  write-intent tokens become paths, shared surfaces, or contracts. The path_roots key enables root
  anchoring. The mandate-read list gains the Copilot instructions file under .github.

### Edge rule (Part A)

For each unordered pair (a, b) of items:

1. Run the unchanged detection relation. If it reports no conflict, there is no edge and no tolerated
   overlap.
2. **Hard.** If the reason list contains shared_surface_overlap or contract_dependency, the pair is an
   edge at every tolerance.
3. **Cost** (integer, computed only for a detected conflict). Re-enumerate the overlapping path pairs
   with the same mergeable-path exclusion and the same entry-overlap primitive the relation uses, then
   sum:
   - same_file weight when both entries are concrete and equal;
   - append_only weight when the concrete overlapping path matches an entry of append_only_paths
     (checked before same_file, so an append-only file is low cost even when both items name it);
   - possible_overlap weight for a glob or directory-prefix overlap;
   - module weight multiplied by the number of shared modules.
   Mergeable paths contribute 0 because they are excluded before enumeration.
4. **Benefit** (integer). The minimum of band_durations for the two items' complexity bands. A missing
   band uses default_band. This is the pairwise form of "cohorts saved times estimated item duration":
   running the pair concurrently saves at most one cohort step of the shorter item.
5. **Rule.** edge if and only if conflict AND (hard OR cost * 100 > benefit * tolerance_percent).
6. **Recorded reason.** The first member of the detection relation's reason list in its canonical
   kind order. The reason enum is unchanged.

Every weight and every band duration is validated as an integer >= 1 (booleans rejected). Therefore
any detected conflict has cost >= 1 or is hard, and with tolerance_percent 0 the inequality
cost * 100 > 0 always holds: the edge set equals the detected-conflict set exactly. For every
tolerance, edge implies conflict, so the new edge set is always a subset of today's. These two
properties are the strict-identity guarantee and the #452 safety guarantee.

Adopted as specified by the operator, with one refinement: append_only is evaluated before same_file
(see Decisions).

### Write-intent rules (Part B)

Active only when write_intent_extraction is true. Each rule is a pure, statically decidable function
of the text and the truth table.

- **W1 glob mention.** Drop any harvested token containing a wildcard character. The feature-folder
  glob is added after filtering and is never dropped.
- **W2 command span.** Drop every token of an inline span whose whitespace split yields more than one
  word.
- **W3 read task.** Drop tokens whose owning task attribution window (a task line plus the following
  non-task lines up to the next ATX heading, as defined by the plan-acceptance-gates rule) starts with
  a task title whose first word, after an optional bold label, is in a fixed read-verb set (Read,
  Verify, Confirm, Inspect, Review, Baseline) AND whose title contains no member of a fixed write-verb
  set (for example Fix, Write, Update, Edit, Add, Create, Delete, Remove, Rename, Author, Append,
  Replace). Both sets are code constants pinned equal across Python and PowerShell by a parity test.
- **W4 root anchoring.** Drop a concrete token whose first segment (after stripping a leading "./")
  is not in path_roots and is not a configured root surface. An empty or absent path_roots disables
  W4.
- **W5 spec paths.** In write-intent mode the spec contributes contracts only, not paths. Contract
  harvesting from the spec applies W1 and W2 (a wildcard token or a multi-word span contributes no
  contract).
- **W6 placeholder stem.** Drop a concrete token whose final-component stem is in a fixed placeholder
  stem set (single ASCII letters, and foo, bar, baz, example, sample, placeholder). The set is a code
  constant pinned across Python and PowerShell by a parity test.
- **Mandate amendment.** Add the Copilot instructions file under .github to mandate_reads in both
  config copies.

Shared surfaces continue to be resolved from the surviving concrete paths, so a shared surface that
survives only as a read citation is removed by W2, W3, W5, or the mandate list and produces no hard
edge. A shared surface the item writes in a write task survives and remains hard.

W1, W4, W6, and the mandate amendment are token-level and also apply inside normalization of a
recorded radius, which is what makes the recorded-radius historical fixtures usable. W2, W3, and W5
need line context and apply only to derivation and to the plan-side extraction of validation.
Derivation and validation select the same extractor from the same flag, so a derived radius still
passes V1 and V2 against its own plan.

Known false-negative classes (all to be restated in the rule file): a genuine write stated only as a
glob; a genuine write stated only in a command span; a write named only in spec prose; a read-verb
task that also writes without a write verb in its title; a new top-level directory not yet in
path_roots; a genuine file whose stem is in the placeholder set. Mitigations: the planner obligation
to append a genuine write explicitly, execution-time escaped-path detection, and the fail-closed
absent key.

### Boundaries and invariants to preserve

- **#452 detection invariant.** The detection relation in every runtime returns the same verdict and
  the same reasons for every #452 case and for every existing conflict fixture. No detection module is
  edited for behavior.
- **Strict identity.** With conflict_tolerance absent, or with tolerance_percent 0, the scheduling
  function returns exactly the detected-conflict pair set, and cohort coloring of that set is
  identical to today's.
- **Extraction identity.** With write_intent_extraction absent or false, derivation, normalization,
  and validation are byte-identical to today's.
- **Enum ownership.** The conflict-edge reason enum keeps its four members. Weights, costs, the hard
  flag, and soft-pair data travel in tolerated-not-validated fields.
- **Monotonicity.** For a fixed input, raising tolerance_percent never adds an edge.
- **Symmetry.** The decision for (a, b) equals the decision for (b, a).
- **File-size limit.** No production or test file exceeds 500 lines. The drift-detection module is at
  the limit and must not grow; the Python validation module and the PowerShell config module have
  little room, so new logic goes into new helper modules.
- **Batch budgets.** At most 3 production files and 3 test files per batch, per language.
- **No hand-narrowing.** Planners never edit a radius to suppress an edge. Configured tolerance and
  configured write-intent extraction are the only sanctioned mechanisms.

### Dependencies or blocked work

- **#452.** Its detection fixture corpus is already on main. This item must still be merge-order
  independent: it carries its own #452-case scheduling fixtures (with the radii embedded, not
  referenced), and a P0 detection step runs the #452 shared corpus unmodified as a gate when present,
  and records any sibling-added fixture.
- No other blocking dependency.

### Implementation strategy (what changes, not sequencing)

#### Split decision

The research recommends two sequential plans. This parallel run carries exactly one plan per item, so
the decision is: **one plan with two sequential phase groups, Part A then Part B.** Part B's
acceptance evidence uses Part A's scheduling harness, so Part A lands first within the plan. Each part
amends only its own sections of the rule file. None of design points 1-7 is dropped. The 500-line
limit and the per-batch budgets apply to every batch in both parts.

#### Files/modules to change

Part A (scheduling layer, strict identity, drift handling, historical BEFORE pins):

- Python production:
  - `scripts/dev_tools/_blast_radius_scheduling.py` (new): pure scheduling function, per-pair
    decision, cost and benefit helpers, strict conflict_tolerance reader.
  - `scripts/dev_tools/compute_blast_radius.py`: re-export the scheduling entry points.
  - `scripts/dev_tools/_parallel_drift_scheduling.py` (new): scheduling-aware peer evaluation and
    known-edge collection, relocated from the drift module.
  - `scripts/dev_tools/parallel_drift_detection.py`: delegate the per-peer decision to the new helper;
    net line count must not increase.
- PowerShell production (each with its bundled mirror):
  - `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` (new): Get-BlastRadiusConflictEdge and its
    helpers.
  - `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusScheduling.psm1` (new mirror)
  - `.claude/lib/blast-radius/BlastRadius.psm1`: import and export the scheduling module.
  - `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1`
- PowerShell registration:
  - `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  - `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
  - `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- Configuration (conflict_tolerance key):
  - `config/blast-radius.json`
  - `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`
- TypeScript:
  - `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`: carried-key list and
    emitted document literal.
  - `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts`
  - `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts`
  - `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`
  - `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts` (new)
  - `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts` (new)
- Python tests:
  - `tests/scripts/dev_tools/test_blast_radius_scheduling.py` (new)
  - `tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py` (new)
  - `tests/scripts/dev_tools/test_blast_radius_historical_runs.py` (new)
  - `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` (new)
  - `tests/scripts/dev_tools/blast_radius_parity_test_support.py`
  - `tests/scripts/dev_tools/test_parallel_drift_scheduling.py` (new)
  - `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py` (new)
- PowerShell tests:
  - `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1` (new)
  - `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` (new)
  - `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
- Fixtures (new):
  - `tests/fixtures/blast_radius/scheduling/scheduling-452-shared-surface-hard.json`
  - `tests/fixtures/blast_radius/scheduling/scheduling-452-directory-prefix-weighted.json`
  - `tests/fixtures/blast_radius/scheduling/scheduling-452-negative-controls.json`
  - `tests/fixtures/blast_radius/scheduling/scheduling-soft-pair-tolerated.json`
  - `tests/fixtures/blast_radius/scheduling/scheduling-absent-key-strict.json`
  - `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json`
  - `tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json`
  - `tests/fixtures/blast_radius/historical-runs/epic-655-followups.json`
- Documentation (scheduling sections):
  - `.claude/rules/parallel-orchestration.md`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`
  - `.claude/skills/parallel-plan/SKILL.md`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
  - `.claude/skills/parallel-add/SKILL.md`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
  - `.claude/agents/parallel-planner.md`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`

Part B (write-intent extraction, new keys, mandate amendment, AFTER pins, re-derivation evidence):

- Python production:
  - `scripts/dev_tools/_blast_radius_write_intent.py` (new): W1-W6, read-verb, write-verb, and
    placeholder-stem constants, strict readers for write_intent_extraction and path_roots.
  - `scripts/dev_tools/compute_blast_radius.py`: flag branch in derivation and normalization.
  - `scripts/dev_tools/_blast_radius_validation.py`: extractor selection for V1 and V2 (if the file
    would exceed 500 lines, move the selection into the new write-intent module).
- PowerShell production (each with its bundled mirror):
  - `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1` (new)
  - `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1` (new mirror)
  - `.claude/lib/blast-radius/BlastRadius.psm1`: flag branch in derivation and normalization, import.
  - `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1`
  - `.claude/lib/blast-radius/BlastRadiusValidation.psm1`: extractor selection.
  - `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusValidation.psm1`
- PowerShell registration: the two Pester runsettings copies and the Claude pack manifest listed in
  Part A, extended with the write-intent module.
- Configuration (write_intent_extraction, path_roots, mandate_reads amendment): the two config copies
  listed in Part A.
- TypeScript: the derivation core and the three push-down test files listed in Part A, extended with
  the two Part B keys.
- Python tests:
  - `tests/scripts/dev_tools/test_blast_radius_write_intent.py` (new)
  - `tests/scripts/dev_tools/test_blast_radius_historical_runs.py` (AFTER pins)
  - `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` (Part B keys)
  - `tests/scripts/dev_tools/blast_radius_parity_test_support.py` (Part B key classes)
  - `tests/scripts/dev_tools/test_blast_radius_mandate_reads.py` (committed-config helper also
    removes the two write-intent keys; see Backward-compatibility expectations)
  - `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` (committed-config helper also
    removes the two write-intent keys; see Backward-compatibility expectations)
- PowerShell tests:
  - `tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1` (new)
  - `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` (AFTER pins)
  - `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` (Part B key classes)
- Fixtures (new):
  - `tests/fixtures/blast_radius/write-intent/write-intent-glob-mention.json`
  - `tests/fixtures/blast_radius/write-intent/write-intent-command-span.json`
  - `tests/fixtures/blast_radius/write-intent/write-intent-read-task.json`
  - `tests/fixtures/blast_radius/write-intent/write-intent-root-anchoring.json`
  - `tests/fixtures/blast_radius/write-intent/write-intent-spec-contracts-only.json`
  - `tests/fixtures/blast_radius/write-intent/write-intent-placeholder-stem.json`
  - `tests/fixtures/blast_radius/write-intent/write-intent-shared-surface-read-citation.json`
  - `tests/fixtures/blast_radius/write-intent/write-intent-flag-absent-matches-current.json`
  - the three historical-run fixtures listed in Part A (AFTER sections)
- Documentation (write-intent sections): the rule file and its mirror listed in Part A.

Files that are read or verified but not written: the detection modules in every runtime, the existing
fixture corpus (including every #452-tagged fixture), the bash library, the TypeScript validator
production modules, the pack-manifest completeness test, the push-down resource-contract test, and the
existing config-parity test module (which is at 500 lines). If P0 finds that any of these must change,
the plan records the finding and the reason before editing it.

#### Functions/classes/CLI commands impacted

- New Python: a scheduling entry point that returns the edge list and the tolerated-overlap list for
  a set of items; a per-pair decision function returning the verdict, the hard flag, the cost, the
  benefit, and the recorded reason; a strict conflict_tolerance reader. New write-intent extraction
  functions for plan and spec text, and strict readers for the two Part B keys.
- New PowerShell: Get-BlastRadiusConflictEdge (edge list plus tolerated overlaps), a per-pair
  decision helper, and write-intent extraction functions, exported through the facade.
- Changed Python: derive_blast_radius, normalize_declared_radius, validate_blast_radius (flag branch
  only); recompute_conflicts_with_observed (per-peer decision delegated to the new helper; signature
  unchanged).
- Changed PowerShell: Get-BlastRadius, Get-NormalizedDeclaredRadius, Test-BlastRadius (flag branch
  only).
- Changed TypeScript: the carried-key list and the emitted document literal in the derivation core.
- Unchanged: the Python conflicts function, Test-BlastRadiusConflict, compute_cohorts, and the bash
  cohort entry point.
- Skill and agent consumers: the parallel-plan and parallel-add skills and the parallel-planner agent
  call the scheduling function instead of looping over pairs by hand, and record tolerated overlaps.

#### Data flow and validation changes

- Planner: derive radii (write-intent aware) → normalize → scheduling function → edges plus tolerated
  overlaps → cohort coloring (unchanged) → checkpoint and manifest.
- Each recorded edge keeps a, b, and reason, and may carry the tolerated extra fields hard, cost, and
  benefit. Tolerated pairs are recorded in a tolerated_overlaps list on the planner and orchestrator
  checkpoints, each entry carrying a, b, reasons, cost, and benefit. No validator reads these fields;
  tests in Python and TypeScript confirm both validators accept them with zero errors.
- Drift: when an item's observed radius replaces its declared radius, each in-flight peer pair is
  evaluated through the scheduling rule, using the items' complexity bands from the checkpoint
  (default_band when absent). A pair is newly conflicting only when the rule yields an edge and the
  pair is not already a recorded edge. A tolerated pair whose observed overlap stays within tolerance
  does not halt either item. A tolerated pair whose observed overlap exceeds tolerance, or becomes
  hard, is reported. At tolerance 0 the output equals today's output.

#### Error handling and logging updates

- Config readers fail fast with specific errors: a non-object conflict_tolerance, a negative or
  non-integer or boolean tolerance_percent, a weight or band duration that is not an integer >= 1, an
  unknown or missing weight name, a default_band outside C1-C4, a non-list append_only_paths or
  path_roots, a non-boolean write_intent_extraction. Error text names the key.
- A missing item band is not an error; default_band applies.
- The drift helper keeps the existing fail-closed behavior: an unevaluable peer radius counts as an
  edge.

#### Rollback/feature-flag considerations

- Remove conflict_tolerance or set tolerance_percent to 0 to restore zero-tolerance scheduling exactly.
- Remove write_intent_extraction or set it to false to restore current extraction exactly.
- Both flags are independent, and both copies of the truth table carry them.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Scheduling input: an ordered collection of items, each with an integer key, a declared radius, and
  an optional complexity band; the parsed truth table.
- Scheduling output: edges sorted by (a, b) with a < b, each with a reason from the unchanged enum and
  the extra fields hard, cost, benefit; and tolerated overlaps sorted by (a, b), each with a, b, the
  full reason list, cost, and benefit.
- Both runtimes produce identical output for every scheduling and historical fixture.

#### Required configuration keys and defaults

| Key | Shape | Partition class | Absent-key behavior | Committed value (both copies unless noted) |
| --- | --- | --- | --- | --- |
| conflict_tolerance | object: tolerance_percent (int >= 0), weights {same_file, possible_overlap, append_only, module} (int >= 1 each), band_durations {C1, C2, C3, C4} (int >= 1 each), default_band (C1-C4), append_only_paths (list) | byte-equal | strict (tolerance_percent 0 semantics) | tolerance_percent 100; weights same_file 8, possible_overlap 2, append_only 1, module 2; band_durations C1 1, C2 2, C3 4, C4 8; default_band C1; append_only_paths selected at P0 from registry and changelog files present in the repository (an empty list is permitted and must be justified in the plan) |
| write_intent_extraction | boolean | byte-equal | false: current extraction | true |
| path_roots | list of first path segments | self-hosted and bundled differ (Class 2) | W4 disabled | self-hosted: the repository's tracked top-level directories, derived at P0 from the tracked file list; bundled: empty list |
| mandate_reads (amended) | existing list | byte-equal | existing behavior | adds the Copilot instructions file under .github |

The committed values lean toward parallelism (design point 3); the absent-key defaults are strict
(fail closed). Existing fixtures embed their own config and remain byte-identical.

#### Backward-compatibility expectations

- Every existing test and fixture passes unmodified, with two exceptions:
  1. Tests that assert the exact key set or key order of the truth tables are updated to include the
     new keys.
  2. Tests whose committed-config helpers pin current-extraction semantics are updated so that those
     helpers also remove the two new write-intent keys, write_intent_extraction and path_roots, from
     the committed config. They then continue to exercise strict (current) extraction. P0 found three
     such tests in two modules: test_derive_without_the_mandate_reads_key_includes_the_citations in
     the mandate-reads test module, and test_derive_blast_radius_keeps_a_cited_csproj_in_paths and
     test_validate_blast_radius_findings_are_identical_with_and_without_the_key in the
     mergeable-paths test module. This is a scoped test update, not a behavior regression.
- The plan's P0 inventories every test that consumes the committed config. Any existing-test failure
  outside that inventory and outside exception 1 stops execution; it is not resolved by editing the
  test.
- Every recorded checkpoint remains valid.
- A destination that has not received the new bundled truth table keeps current behavior.

#### Performance constraints

- The scheduling function is quadratic in item count and linear in radius size per pair, the same
  order as today's hand loop. No measurable change for runs within the concurrency bound of 32.

## Assumptions, Constraints, Dependencies

- **Assumptions.** The plan-home refs for the three historical runs are fetchable at P0. The kickoff
  files for backlog-2026-09-26 and followups-2026-09-27 exist only in the main checkout and are
  gitignored; no kickoff exists for epic-655-followups. Complexity bands for fixtures come from the
  kickoff tables where available; otherwise default_band applies and the fixture records that.
- **Constraints.** 500-line file limit; 3 production plus 3 test files per batch per language; every
  PowerShell module edit has a bundled mirror; T2 property-test density for the new pure functions.
- **External dependencies.** None new. (Amended by decision 11: hypothesis is not installed in this
  repository; the property tests use exhaustive enumeration instead.)

## Data / API / Config Impact

- **User-facing changes.** Parallel runs produce fewer edges and fewer cohorts. Planner reports list
  tolerated overlaps.
- **Data or migration.** None. Existing checkpoints are valid. New fields are optional.
- **Telemetry.** None.
- **Compatibility notes.** Four truth-table keys change (three new, one amended) in both copies; the
  push-down carries them verbatim. The conflict-edge reason enum is unchanged.

## Test Strategy

- **Regression tests.**
  - #452 bidirectional scheduling cases in Python and PowerShell (shared-surface case hard at every
    tolerance; directory-prefix case detected, weighted, and an edge at tolerance 0; matched negative
    controls edge-free at every tolerance).
  - Strict identity: at tolerance 0 and with the key absent, the scheduling edge set equals the
    detected-conflict set for every existing conflict fixture and every historical-run fixture.
  - Historical-run BEFORE pins (current extraction, strict scheduling) and AFTER pins (write-intent
    token-level rules plus committed tolerance), in both runtimes, reading committed fixtures only.
- **Unit tests.** One or more per write-intent rule W1-W6; cost terms (same_file, append_only,
  possible_overlap, module, mergeable zero); benefit (band lookup, default_band); hard classification;
  reason selection; every config-reader rejection; the flag-absent identity path; the drift helper.
- **Property tests (exhaustive enumeration; decision 11).** edge implies conflict; tolerance 0 equals conflict; monotonicity in
  tolerance_percent; symmetry; W-rules never add a token.
- **Parity.** Python and PowerShell produce identical results for every scheduling, write-intent, and
  historical fixture; the read-verb, write-verb, and placeholder-stem sets are pinned equal.
- **Key partition.** Every new top-level key is classified and present in both config copies, in the
  Python and PowerShell partition tests; the TypeScript carriage test confirms each new key reaches the
  destination document.
- **Coverage.** >= 85% line on every changed or new file in every language; >= 75% branch for Python
  and TypeScript; no regression on changed lines.
- **Toolchain.** Python: black, ruff, pyright, pytest with coverage. PowerShell: Invoke-Formatter,
  PSScriptAnalyzer, Pester with coverage (via the PoshQC path). TypeScript: prettier, eslint, tsc,
  jest. bash: not touched, so bats and shellcheck are not run.
- **Evidence, not tests.** The one-time re-derivation of the three historical runs over origin refs,
  including the line-context rules W2, W3, and W5 that need plan text, is an evidence artifact only.
  Automated tests never read origin refs, gitignored artifacts, or the main checkout.

## Acceptance Criteria

Criteria that depend on CI are checked off by the execution child, which pushes the check-off before
reporting done.

### P0 gates and historical evidence (design point 7)

- [ ] P0 detection gate: the #452 shared fixture corpus (every fixture in the blast-radius fixture
  corpus tagged #452, plus any sibling-added fixture found at P0) runs unmodified through the Python
  and PowerShell detection drivers and passes; the list of fixtures found and the pass result are
  recorded in an evidence artifact under this feature folder's evidence tree.
- [x] P0 historical re-derivation: for each of epic-655-followups, backlog-2026-09-26, and
  followups-2026-09-27, the recorded radii are read verbatim with git show from the run's plan-home
  ref, and the BEFORE edge member set, edge count, cohort partition, cohort count, and maximum cohort
  width are computed independently by the Python and PowerShell runtimes; the two member sets are
  compared explicitly; the artifact records the commit, the commands, both member sets, and the
  comparison. Values are pinned into fixtures only after the two runtimes agree.
- [ ] The three historical-run fixtures exist under the blast-radius fixture corpus's historical-runs
  directory, each containing the recorded radii, per-item complexity band (or a default_band marker),
  the pre-change config, pinned radius sizes, and BEFORE and AFTER edges, cohorts, cohort count, and
  maximum cohort width.
- [ ] A final evidence artifact under this feature folder's evidence tree reports, for each of the
  three runs, BEFORE and AFTER edge count, cohort count, and maximum cohort width, including the
  AFTER values for the line-context rules W2, W3, and W5 derived from plan text at a pinned commit.
- [ ] The historical-run tests in Python (test_blast_radius_historical_runs) and PowerShell
  (BlastRadius.HistoricalRuns.Tests) assert the pinned BEFORE and AFTER values, read only the committed
  fixtures, and contain no reference to origin refs, the artifacts directory, or the main checkout.

### Strict identity and #452 non-regression

- [ ] The detection relation is unchanged: every existing conflict fixture and every #452-tagged
  fixture yields the same verdict and the same reason list in Python and PowerShell as on main, and no
  detection module appears in the diff with a behavioral change.
- [ ] Strict identity (tolerance 0): a Python test and a Pester test assert that the scheduling edge
  pair set equals the detected-conflict pair set for every existing conflict fixture and for the BEFORE
  section of every historical-run fixture, and that cohort coloring of that set equals the pinned
  BEFORE partition.
- [ ] Absent-key identity: the scheduling-absent-key-strict fixture passes in both runtimes, showing
  that a truth table without conflict_tolerance yields the same edges as tolerance 0.
- [ ] #452 shared-surface case: the scheduling-452-shared-surface-hard fixture is a hard edge at
  tolerance 0, at the committed tolerance, and at a very large tolerance, in both runtimes.
- [ ] #452 directory-prefix case: the scheduling-452-directory-prefix-weighted fixture is detected,
  carries the possible_overlap cost, and is an edge at tolerance 0, in both runtimes.
- [ ] #452 negative controls: the scheduling-452-negative-controls fixture yields no edge and no
  tolerated overlap at every tested tolerance, in both runtimes.
- [ ] Each #452 scheduling fixture embeds its radii rather than referencing a #452 fixture file, so the
  item's tests pass regardless of merge order.

### Scheduling layer (design points 2, 3, 4)

- [ ] The Python scheduling module and the PowerShell Get-BlastRadiusConflictEdge implement the edge
  rule exactly as specified (hard classes, integer cost terms with mergeable zero and append-only
  precedence, pairwise benefit with default_band, the integer inequality, first-kind reason selection),
  each term covered by a named unit test in both runtimes.
- [ ] The scheduling-soft-pair-tolerated fixture shows a detected, non-hard pair recorded as a
  tolerated overlap (not an edge) at the committed tolerance and as an edge at tolerance 0, in both
  runtimes.
- [x] Property tests (exhaustive enumeration over a fixed finite domain; see decision 11) cover: edge
  implies conflict; tolerance 0 equals conflict; monotonicity in tolerance_percent; symmetry.
- [ ] The conflict_tolerance reader rejects every invalid shape listed under Error handling with an
  error naming the key, in both runtimes, each rejection covered by a test.
- [x] Both config copies carry conflict_tolerance with the committed values in this spec, byte-equal
  between the copies.
- [ ] The parallel-plan and parallel-add skills and the parallel-planner agent (and their bundled
  mirrors) call the scheduling function instead of a hand pair loop, record tolerated overlaps, and
  state that the later-merging item of a tolerated pair syncs with main and re-passes CI.
- [ ] Edges keep only the four existing reason members; the tolerated extra fields (hard, cost,
  benefit) and the tolerated_overlaps list are accepted with zero errors by the Python validators
  (test_validate_parallel_state_tolerated_edge_fields) and the TypeScript validator port
  (parallel-state-tolerated-edge-fields.test).

### Drift detection

- [x] Drift recomputation evaluates each in-flight peer pair through the scheduling rule via the new
  drift helper module; test_parallel_drift_scheduling shows a tolerated pair whose observed overlap
  stays within tolerance is not reported, a tolerated pair that becomes hard or exceeds tolerance is
  reported, and output at tolerance 0 equals the pre-change output.
- [ ] The drift-detection module does not grow in line count, and every existing drift test passes
  unmodified.

### Write-intent extraction (design point 1)

- [ ] Rules W1-W6 are implemented in the Python write-intent module and the PowerShell write-intent
  module, active only when write_intent_extraction is true, each covered by its write-intent fixture
  and a named unit test in both runtimes.
- [ ] The write-intent-shared-surface-read-citation fixture shows a shared surface cited only in a read
  task or command span produces no shared surface and no hard edge, while the same surface named in a
  write task is retained and is hard.
- [ ] The write-intent-spec-contracts-only fixture shows the spec contributes no paths and that
  wildcard tokens and multi-word spans contribute no contracts in write-intent mode.
- [ ] The write-intent-flag-absent-matches-current fixture shows derivation, normalization, and
  validation are identical to current behavior when write_intent_extraction is absent or false, in
  both runtimes.
- [ ] A derived radius passes V1 and V2 against its own plan in write-intent mode, in both runtimes.
- [ ] The read-verb, write-verb, and placeholder-stem sets are pinned equal across Python and
  PowerShell by a parity test.
- [ ] Both config copies add the Copilot instructions file under .github to mandate_reads, set
  write_intent_extraction to true, and carry path_roots (self-hosted: the P0-derived top-level
  directory list; bundled: an empty list).

### Parity and configuration partition (design point 6)

- [ ] The key-partition tests classify every new top-level key: conflict_tolerance and
  write_intent_extraction as byte-equal in the Python support module and the PowerShell partition
  test; path_roots in the Class 2 registry with a consuming test asserting the bundled value is empty;
  the existing exhaustiveness test passes with every key present in both copies.
- [ ] The TypeScript derivation core carries conflict_tolerance, write_intent_extraction, and
  path_roots verbatim; blast-radius-derive-tolerance-keys.test confirms each reaches the destination
  document; the key-order assertions and the source-document helper are updated and pass.
- [ ] Every new or changed PowerShell module has a content-identical bundled mirror, is registered in
  both Pester runsettings copies, and is listed in the Claude pack manifest; the push-down
  resource-contract and pack-manifest completeness tests pass.
- [ ] No file in the bash library directory is changed.

### Rule-file amendment (design point 5)

- [ ] `.claude/rules/parallel-orchestration.md` and its bundled mirror are amended, content-identical,
  to record: the write-intent rules and their false-negative list; the mandate-read amendment; an
  integration-cost scheduling subsection with the edge rule, the strict-identity proof, and the hard
  classes; the statement that this is an operator-directed configured policy change and that planners
  still never hand-narrow a radius; soft-overlap handling (the later merge syncs with main and
  re-passes CI); the enum-ownership note that no reason member is added and which fields are
  tolerated-not-validated; and the updated byte-equal key list and path_roots class.

### Toolchain and CI

- [ ] Python toolchain passes in a single pass (black, ruff, pyright, pytest) with >= 85% line and
  >= 75% branch coverage on every new or changed Python file and no regression on changed lines.
- [ ] PowerShell toolchain passes in a single pass (formatter, PSScriptAnalyzer, Pester) with >= 85%
  line coverage on every new or changed module.
- [ ] TypeScript toolchain passes in a single pass (prettier, eslint, tsc, jest) with >= 85% line and
  >= 75% branch coverage on the changed derivation core.
- [ ] No new or changed file exceeds 500 lines, and each plan batch stays within 3 production and
  3 test files per language.
- [ ] CI is green on the pull request, including the windows-latest Pester job (checked off by the
  execution child, which pushes the check-off before reporting done).

## Risks & Mitigations

- **Under-reporting from write-intent rules (the #452 class).** Mitigations: the fail-closed absent
  flag; the planner obligation to append a genuine write; execution-time escaped-path detection; the
  write-verb override in W3; the false-negative list in the rule file.
- **Silent destination fallback.** A key missing from the carried-key list would silently make
  destinations strict. Mitigation: the TypeScript carriage test for every new key.
- **Drift false halts.** Mitigated by routing drift through the scheduling rule.
- **Tolerated pairs still produce merge conflicts.** Accepted by design; the later item syncs with main
  and re-passes CI under the existing per-item handling. Operators can set tolerance 0.
- **Hard floors from genuine shared-surface writes.** Tolerance does not relax them by design. Part B
  removes read citations; genuine writes remain hard.
- **Cohort count alone understates the effect.** Evidence reports edges and maximum cohort width as
  well.
- **Research counts are unverified.** Mitigated by the P0 re-derivation in two runtimes before any
  value is pinned.

## Rollout & Follow-up

- **Rollout.** Merge Part A and Part B in one pull request. The committed config enables both. The
  push-down publishes the new bundled truth table on the next extension release.
- **Follow-up (recorded, not implemented).** Noisy spec contract tokens producing hard contract edges.
- **Follow-up (monitoring).** Compare edge counts and cohort counts of the next two parallel runs with
  this evidence.

## Decisions Beyond the Research and Prompt

1. **Key naming.** The operator's conflict_tolerance name is used for the single scheduling object
   (the research proposed conflict_scheduling). tolerance_percent, weights, band_durations,
   default_band, and append_only_paths are its members.
2. **Append-only precedence.** append_only is evaluated before same_file, so a registry file named by
   both items is low cost rather than high cost.
3. **Module weight.** The committed module weight is 2 (the research left it unspecified).
4. **W3 write-verb override.** A read-verb title that also contains a write verb is not a read task,
   which closes the "Verify and fix" false-negative class.
5. **W6 placeholder-stem rule.** Added because W4 alone does not remove placeholder paths under a real
   top-level directory in this repository.
6. **Contract filtering.** Write-intent mode applies W1 and W2 to spec contract harvesting; noisy
   single-token contracts remain a recorded follow-up.
7. **Drift strategy.** Drift evaluates pairs through the scheduling rule (rather than treating recorded
   tolerated overlaps as permanently known), so a tolerated pair whose observed overlap grows is still
   caught.
8. **Bash.** Not touched; the bash cohort entry point colors an edge list and never sees radii.
9. **Pester runsettings as a mandate read.** Not adopted. The research suggested it; the operator
   named only the Copilot instructions file, and write-intent extraction removes read citations of
   shared surfaces generally.
10. **Current-extraction tests against the committed config.** Executor preflight found that committing
    write_intent_extraction true and the self-hosted path_roots breaks three existing tests that check
    current-extraction semantics against the committed config: in the mandate-reads test module, W3
    drops the read-citation tokens once only mandate_reads is removed; in the mergeable-paths test
    module, W4 drops a csproj path whose top-level directory is not tracked. Decision (orchestrator,
    autonomous mode): those tests keep checking current-extraction semantics, and their committed-config
    helpers also remove write_intent_extraction and path_roots. Write-intent behavior is covered by the
    new write-intent tests and fixtures. The committed config values are unchanged by this decision.
11. **Property-test mechanism (AC-15 amendment, recorded 2026-09-27 during execution).** The spec
    stated that hypothesis was already approved. It is not: it is absent from pyproject.toml and the
    lockfile, and existing suites state that it stays absent. Adding it would be an unplanned
    dependency change, and a seeded-random substitute triggers ruff S311, whose only remedy is an
    unplanned per-file ignore. Decision (orchestrator, autonomous mode): the four properties are
    verified by exhaustive enumeration over a fixed finite domain (13,689 decisions per truth table)
    that produces conflicts, edges, tolerated overlaps, and hard pairs, so no property holds
    vacuously. Exhaustive enumeration checks every input in that domain, whereas sampling checks only
    a subset. AC-15's wording is amended accordingly; the properties it names are unchanged. Evidence:
    evidence/other/property-test-framework-deviation.2026-09-27T15-17.md.
