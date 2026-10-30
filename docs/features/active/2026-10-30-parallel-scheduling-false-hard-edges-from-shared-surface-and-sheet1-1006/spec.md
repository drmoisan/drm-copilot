# parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1 (Spec)

- **Issue:** #1006
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T07-40
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md`)
- **Research:** `research/research.2026-10-30T11-05.md` in this feature folder (authoritative for the file list, symbols, and recommended design)
- **Execution environment:** `.claude/skills/execution-environment/SKILL.md` (tool routes, command-text restrictions, batch budget, contract tests, evidence rules, coverage and file-size gates, and test-isolation checks are referenced there and not restated here)

## Context
Parallel scheduling serializes items on two false hard edges, and destinations cannot relax them durably. A shipped shared surface (`quality-tiers.yml`) and a default Excel worksheet name recorded as a contract (`Sheet1`) each produce a hard edge between items that have no real dependency. A destination fix is overwritten by the next push-down.

Environment:
- OS/version: not recorded
- Python version: not recorded
- Command/flags used: `/parallel-plan` and `/parallel-run`, run `backlog-2026-10`, harness 1.1.23
- Data source or fixture: destination repo Real-Good-Foods/iar-migration

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Items run serially that could run in parallel, and a destination cannot fix it without forking.


## Repro & Evidence
Steps to Reproduce:
1. In a destination repo, plan two items that each append one entry to `quality-tiers.yml` (each adds a module).
2. Give two unrelated specs an Interface/Contract section that names an Excel worksheet `Sheet1`.
3. Recompute the blast radius and conflict edges.

Expected:
Neither source produces a hard edge. Two radii that share only append-only registry paths, generic worksheet names, and ordinary path or module overlap yield no hard edge. At `tolerance_percent` 0 the output stays identical to strict scheduling.

Actual:
Items #41 and #42 (and #42 and #44) received a hard edge from two sources:

1. Shared surface `quality-tiers.yml`. Every item that adds a module appends one entry to it. Listing it in `shared_surfaces` makes any two such items a hard `shared_surface_overlap` edge at every tolerance (integration-cost scheduling rule 2, issue #722).
2. Contract `Sheet1`. `extract_contract_identifiers` / `Get-ContractIdentifier` recorded the worksheet name as a contract, producing a hard `contract_dependency`.

The destination fixed both locally (iar-migration PR #45). Push-down 1.1.23 (PR #46) overwrote the fix. The destination `config/blast-radius.json` is derived from the published copy on every push, and `config/blast-radius.local.json` cannot remove a shipped shared surface (issue #508 overlay semantics).

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: none; evidence is the destination run and PRs above.

Fail-before evidence for this repository is produced by the new end-to-end regression tests (Test Strategy) and recorded under `evidence/regression-testing/` in this feature folder.


## Scope & Non-Goals
- In scope:
  - Change 1, generic contract tokens: a closed code constant of default spreadsheet sheet-tab stems (`Sheet`, `Chart`), matched as stem plus ASCII digits, case-insensitive, with an ASCII guard, defined in the token-shape leaf modules of Python and PowerShell and applied at every contract-filtering site in both runtimes.
  - Change 2, append-only `quality-tiers.yml`: in both committed truth tables (self-hosted `config/blast-radius.json` and published `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`), remove `quality-tiers.yml` from `shared_surfaces`, append it to `conflict_tolerance.append_only_paths`, and keep it in `mandate_reads`.
  - Change 3, destination demotion: a new overlay directive key `shared_surfaces_demote` in the TypeScript and Python push-down overlay composers.
  - Rule text in `.claude/rules/parallel-orchestration.md` and its bundle copy, and the tests and fixtures listed under Files/modules to change.
- Out of scope / non-goals:
  - No change to the `conflict_edges[].reason` enum.
  - No change to the parallel checkpoint schema.
  - No change to drift detection beyond its reuse of the scheduling edge rule.
  - No change to `HARD_REASON_KINDS`, `decide_pair`, `conflicts`, or the truth-table reader (`config_conflict_tolerance`, `config_root_surfaces`, `Get-ConfigRootSurface`).
  - No TypeScript or bash contract extractor is added; neither runtime extracts contracts today (research section 1.2).
  - No edit to the stale "three token shapes" sentence in `.claude/skills/parallel-plan/SKILL.md`; recorded as a follow-up note.
- Explicitly excluded systems, integrations, or datasets:
  - The fix does not edit `quality-tiers.yml`.
  - The fix does not edit any `.github/instructions/` file, and no `.agents/`, `.github/`, or `.codex/` mirror is required, because neither the rule nor the blast-radius modules have mirrors outside the bundle.
  - No live destination push-down is performed; push-down through MCP serves the installed payload (execution-environment brief, MCP section), so destination behavior is proven by in-memory push-down tests.
  - The execution-environment brief states no fact this change alters, so no brief update is required.

## Root Cause Analysis
The overlay is union-only for `shared_surfaces`, so a destination cannot demote a shipped entry. Contract extraction has no filter for generic spreadsheet worksheet names.

Detail (research section 1.1):
- `conflicts` intersects the recorded `shared_surfaces` and `contracts` lists of both radii; `HARD_REASON_KINDS` classifies `shared_surface_overlap` and `contract_dependency` as hard, and `decide_pair` makes every hard conflict an edge at every tolerance.
- `quality-tiers.yml` reaches a radius through the planner append obligation in `.claude/skills/parallel-plan/SKILL.md` or through an observed diff radius (`radius_from_observed_paths`). `resolve_shared_surfaces` then lists it as a shared surface because the truth tables list it in `shared_surfaces`.
- Contract harvesting accepts any inline-code token in an `API`/`Interface`/`Contract`/`Surface` section that has no `/` and has an ASCII letter. No rule rejects default sheet-tab names.
- `composeBlastRadiusOverlay` and `compose_blast_radius_overlay` take an ordered union for `STRING_LIST_KEYS`; nothing removes a base entry.


## Proposed Fix

### Design summary (what changes where):
- Change 1: add the generic-contract constant, its compiled pattern, and a total predicate to `scripts/dev_tools/_blast_radius_token_shapes.py` and `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`; re-export the PowerShell predicate from `BlastRadiusExtraction.psm1`; add the predicate as a further conjunct at each contract-filtering site.
- Change 2: edit both committed truth tables so `quality-tiers.yml` is an append-only path and a mandate read, not a shared surface; rewrite read-by-mandate constraint 2 in the rule.
- Change 3: add the `shared_surfaces_demote` directive to both overlay composers, applied after all other keys are composed and consumed from the output; update the issue #508 overlay paragraph in the rule.

### Boundaries and invariants to preserve:
- Strict identity: at `tolerance_percent` 0 the scheduling edge set equals the detected-conflict set (`decide_pair` short-circuits on zero). Every existing strict-identity pin listed in research section 6 re-runs unchanged.
- The detection relation, `HARD_REASON_KINDS`, the `conflict_edges[].reason` enum, and the checkpoint schema are unchanged.
- `conflict_tolerance` is a Class 1 (byte-equal) key; both committed copies carry identical `conflict_tolerance` values after the change.
- With no overlay, or with an overlay that omits `shared_surfaces_demote`, composed output is byte-identical to current output (issue #508 AC01 and AC18 identity properties).
- The forbidden-glob guard on `modules` (`FORBIDDEN_GLOBS`) is unchanged and still runs.
- Each `.claude/` file edited has a byte-identical bundle copy under `extensions/drm-copilot/resources/claude-customizations/`.

### Dependencies or blocked work:
- Large-route execution is required: the distinct non-test PowerShell and Python production files each exceed the direct-mode batch budget (execution-environment brief, Batch Budget). The orchestrator selects the `large` route in the item worktree checkpoint.
- Branch base confirmation, CI dispatch, and CI polling are orchestrator-owned.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
The fix writes exactly the following files (research Complete File List). It edits `.claude/rules/parallel-orchestration.md` and its bundle copy, and `config/blast-radius.json` and its published copy. It does not edit `quality-tiers.yml` or any `.github/instructions/` file.

Production, configuration, and documentation:
1. `scripts/dev_tools/_blast_radius_token_shapes.py`
2. `scripts/dev_tools/_blast_radius_extraction.py`
3. `scripts/dev_tools/_blast_radius_write_intent.py`
4. `scripts/dev_tools/compute_blast_radius.py`
5. `scripts/dev_tools/push_down_claude_blast_radius_overlay.py`
6. `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`
7. `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`
8. `.claude/lib/blast-radius/BlastRadiusNormalization.psm1`
9. `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1`
10. `.claude/lib/blast-radius/BlastRadius.psm1`
11. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`
12. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1`
13. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusNormalization.psm1`
14. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1`
15. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1`
16. `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts`
17. `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts` (new)
18. `extensions/drm-copilot/jest.config.cjs`
19. `config/blast-radius.json`
20. `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`
21. `.claude/rules/parallel-orchestration.md`
22. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`

Tests and fixtures:
23. `tests/scripts/dev_tools/blast_radius_parity_test_support.py`
24. `tests/scripts/dev_tools/test_blast_radius_config_parity.py`
25. `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py`
26. `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py`
27. `tests/scripts/dev_tools/test_blast_radius_generic_contracts.py` (new)
28. `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay_demote.py` (new)
29. `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
30. `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`
31. `tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1` (new)
32. `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`
33. `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-parity.test.ts`
34. `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-demote.test.ts` (new)
35. `tests/fixtures/blast_radius_overlay/shared-surfaces-demote.json` (new)
36. `tests/fixtures/blast_radius_overlay/shared-surfaces-demote-already-append-only.json` (new)
37. `tests/fixtures/blast_radius_overlay/shared-surfaces-demote-unknown-entry.json` (new)
38. `tests/scripts/dev_tools/test_blast_radius_mandate_reads.py`
39. `tests/scripts/dev_tools/test_blast_radius_extraction.py` (comment only)
40. `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` (comment only)

Items 38 to 40 follow from change 2. `test_derive_without_the_mandate_reads_key_includes_the_citations` derives against the committed `config/blast-radius.json` and asserts that `quality-tiers.yml` enters `paths` and `shared_surfaces` once `mandate_reads` is removed; after change 2 the committed table no longer makes `quality-tiers.yml` a root surface, so the test supplies the surface in its arranged config. Items 39 and 40 carry comments stating that their inline root-surface set equals the committed `shared_surfaces` subset, which change 2 makes false; only those comments change.

Feature documentation and evidence under this feature folder are written by later phases.

#### Functions/classes/CLI commands impacted:
- Python, change 1: new `GENERIC_CONTRACT_STEMS`, a compiled generic-contract pattern, and `is_generic_contract_token` in `_blast_radius_token_shapes.py`; filter added in `extract_contract_identifiers` (`_blast_radius_extraction.py`), `extract_write_intent_contracts` (`_blast_radius_write_intent.py`), and `normalize_declared_radius` (`compute_blast_radius.py`).
- PowerShell, change 1: new `$script:GenericContractStem`, `$script:GenericContractPattern`, and `Test-GenericContractToken` in `BlastRadiusTokenShape.psm1` (exported); `Test-GenericContractToken` added to `Export-ModuleMember` in `BlastRadiusExtraction.psm1`; filter added in `Get-ContractIdentifier` (`BlastRadiusNormalization.psm1`), `Get-WriteIntentSpecContract` (`BlastRadiusWriteIntent.psm1`), and `Get-NormalizedDeclaredRadius` (`BlastRadius.psm1`).
- TypeScript, change 3: new `SHARED_SURFACES_DEMOTE_KEY` and pure `applySharedSurfaceDemotion` in `claude-blast-radius-overlay-demote.ts`; `composeBlastRadiusOverlay` skips the directive key in its overlay-only loop and calls the demotion after composition.
- Python, change 3: new `SHARED_SURFACES_DEMOTE_KEY` and `_apply_shared_surface_demotion` in `push_down_claude_blast_radius_overlay.py`; `compose_blast_radius_overlay` applies it after composition; `__all__` and the module docstring rules list updated.

#### Data flow and validation changes:
- Contract filtering: a token is recorded as a contract only when it passes the existing separator, letter, and (write-intent) wildcard tests and is not a generic contract token. The order of the conjuncts does not change results.
- Declared-radius normalization re-filters recorded contracts with the same predicate, so a previously recorded `Sheet1` is dropped on recompute.
- Overlay composition: all other keys compose as today; then `shared_surfaces_demote` is validated, each entry is removed from the composed `shared_surfaces` (remaining order preserved), and the entries are unioned into `conflict_tolerance.append_only_paths` with the existing union semantics (`unionStrings` / `_union_strings`). The directive key is not emitted.

#### Error handling and logging updates:
The demotion fails closed with `BlastRadiusOverlayError` (both runtimes, identical detail text) before any write, so the destination `config/blast-radius.json` keeps its prior bytes (existing `_rejected_write` contract):
- non-list value, or a list with a non-string member: `key "shared_surfaces_demote" must be a list of strings`;
- composed document lacks a `conflict_tolerance` object with an `append_only_paths` list: `key "shared_surfaces_demote" requires conflict_tolerance.append_only_paths in the composed document` (no partial `conflict_tolerance` is created);
- an entry that is neither in the composed `shared_surfaces` nor in the composed `conflict_tolerance.append_only_paths`: `key "shared_surfaces_demote" names "<entry>", which is neither a shared surface nor an append-only path`.

The generic-contract predicate is total and never raises. No logging changes.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the change. A destination that does not set `shared_surfaces_demote` sees only change 1 and change 2, which arrive through the published truth table and the bundled modules after an extension rebuild and reinstall.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `is_generic_contract_token(token: str) -> bool`: returns true only when `token` is ASCII and fully matches `(?:Sheet|Chart)[0-9]+` under `re.IGNORECASE | re.ASCII`. `GENERIC_CONTRACT_STEMS` uses the `tuple("...".split())` shape used by `READ_VERBS`.
- `Test-GenericContractToken -Token <string>`: returns `$true` only when the token passes an ordinal ASCII check (`-cmatch '\A[\x00-\x7F]*\z'`) and matches a `\A...\z`-anchored pattern built from `$script:GenericContractStem` with `IgnoreCase, CultureInvariant`.
- Overlay input: `config/blast-radius.local.json` may carry `"shared_surfaces_demote": [<string>, ...]`. Output: the composed `config/blast-radius.json` without that key.

#### Required configuration keys and defaults:
- Both committed truth tables: `shared_surfaces` no longer contains `quality-tiers.yml`; `conflict_tolerance.append_only_paths` keeps its existing entries in their existing order and gains `quality-tiers.yml` as its last entry; `mandate_reads` still contains `quality-tiers.yml`.
- `shared_surfaces_demote` is an overlay directive key, never a truth-table key. It has no default; absence means no demotion.

#### Backward-compatibility expectations:
- Overlays without the directive compose byte-identically to today.
- Separator-free token acceptance for `quality-tiers.yml` through `config_root_surfaces` / `Get-ConfigRootSurface` ends (research section 1.6). No derived radius changes, because `mandate_reads` already drops a bare citation; a planner-appended or observed `quality-tiers.yml` stays in `paths` and contends on `path_overlap` at the `append_only` weight.
- A demoted entry still matched by a `shared_surface_globs` pattern remains shared through the glob (the bundled glob list is empty); the rule text records this residual.

#### Performance constraints (latency/throughput/memory):
No new constraint. The predicate is a single anchored regular-expression match per candidate token; demotion is linear in the size of the composed lists.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): no inline-code `SheetN`/`ChartN` token exists in the repository outside this feature's own documents (research section 2.1, case-insensitive search), so change 1 removes no existing recorded contract. Both committed truth tables are hand-maintained; no generator writes them.
- Constraints (budget, performance, compatibility): large-route execution (batch budget); file-size tiers per `.claude/rules/general-code-change.md`, with new logic placed in leaf modules and the new TypeScript module, and new cases placed in new test files; tests create no temporary files.
- External dependencies (services, libraries, releases): none. Destinations receive the change only after an extension release, rebuild, and reinstall.

## Data / API / Config Impact
- User-facing or API changes: new destination overlay directive `shared_surfaces_demote`; generic sheet-tab names are no longer recorded as contracts.
- Data or migration considerations: none. Existing recorded radii are re-filtered on normalization.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): the truth-table key set is unchanged; `conflict_tolerance` values change identically in both copies; the `conflict_edges[].reason` enum and checkpoint schema are unchanged.

## Test Strategy
Seeded from issue (proposed fix and acceptance), refined by research sections 5 through 7.

- Regression tests to add or update:
  - New `tests/scripts/dev_tools/test_blast_radius_generic_contracts.py`: predicate cases, each Python contract-filtering site, `normalize_declared_radius` dropping a recorded `Sheet1`, a pin of `GENERIC_CONTRACT_STEMS`, and the end-to-end issue scenario under both committed tables (no hard edge; at tolerance 0 the edge set equals the detected-conflict set). This scenario fails before the change with a hard `contract_dependency` or `shared_surface_overlap`; that run is the fail-before evidence.
  - New `tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1`: the Pester mirror, a parity `It` that reads `GENERIC_CONTRACT_STEMS` from the Python source and pins `$script:GenericContractStem` equal, and the issue scenario through `Get-BlastRadiusConflictEdge` with `-Relation ${function:Test-BlastRadiusConflict}`.
  - New `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay_demote.py` and `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-demote.test.ts`: demotion semantics and the in-memory push-down scenario from the issue.
  - New corpus fixtures under `tests/fixtures/blast_radius_overlay/` (demote, already-append-only no-op, unknown entry with `expected_error`), asserted by both overlay parity tests.
  - Updated: `PORTABLE_SHARED_SURFACES` and new `OVERLAY_DIRECTIVE_KEYS` in `blast_radius_parity_test_support.py`; `test_committed_conflict_tolerance_values` and `test_committed_conflict_tolerance_reads_cleanly`; Pester `'lists quality-tiers.yml as both a shared surface and a mandate read'` (rewritten); `SOURCE_BLAST_RADIUS` and its docblock in `config-carriage.test-helpers.ts`; `test_every_top_level_key_is_classified_and_shared_by_both_copies`; Pester `'requires every top-level key in both copies to be classified and shared'`; `test_ac16_corpus_composition_matches_expected` and "composes %s to its expected text" (support for `expected_error`); a new constant-parity test for `SHARED_SURFACES_DEMOTE_KEY` in `test_push_down_claude_overlay_parity.py`; `test_derive_without_the_mandate_reads_key_includes_the_citations` in `test_blast_radius_mandate_reads.py` (its arranged config supplies `quality-tiers.yml` in `shared_surfaces`); and the root-surface comments in `test_blast_radius_extraction.py` and `BlastRadiusExtraction.Path.Tests.ps1`.
  - Unchanged and re-run: the strict-identity pins (research section 6), the Class 1 parity tests, the separator-free shared-surface tests, the issue #452 regression corpus tests, the issue #508 AC18 property tests (no demote overlay is added to `PROPERTY_OVERLAYS`), and the existing contract-extraction suites.
- Unit tests (pytest) for the fixed behavior and boundaries: as listed above; Pester and Jest mirrors for the PowerShell and TypeScript code.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): `Sheet`, `Sheet1a`, `MySheet1`, `Sheet1.Range`, empty string, full-width digits, a Kelvin-sign (U+212A) variant, `Book1`, `Table1` are not generic; `Sheet1`, `sheet12`, `CHART3` are generic. Demotion: non-list value, non-string member, missing `conflict_tolerance.append_only_paths`, unknown entry, entry already append-only, order preservation, consumed key.
- Error handling and logging verification: each fail-closed detail text is asserted in both runtimes, and the prior destination bytes are preserved on rejection.
- Coverage impact and targets for changed lines/modules: per `.claude/rules/general-unit-test.md` and the execution-environment brief (Coverage and File-Size Gates).
- Toolchain commands to run (format → lint → type-check → test): the seven-stage loop per `.claude/rules/general-code-change.md` for Python, PowerShell, and TypeScript; then the contract tests under "Contract Tests That Pin Mirrored Files" in the execution-environment brief; then the test-isolation checks in the brief.
- Manual validation steps (if required): none. Destination behavior is proven by in-memory push-down tests.


## Acceptance Criteria

Issue acceptance (restated from `issue.md`; the checked state there is an issue-template artifact):

- [ ] AC-01 No hard edge for benign overlap: a recompute of two radii that share only append-only registry paths, generic worksheet names, and ordinary path/module overlap yields no hard edge. At `tolerance_percent` 0 the output stays identical to strict scheduling (the strict-identity proof still holds).
- [ ] AC-02 Cross-runtime parity and key partition: the generic-contract constant and the demotion semantics are equal across Python, PowerShell, and TypeScript (where ported), and the key-partition exhaustiveness test covers the new overlay key.
- [ ] AC-03 Mirror and published-table contracts: contract tests that pin mirrored and bundled files pass, and the published truth table carries the same `append_only_paths` change as the self-hosted table.
- [ ] AC-04 Destination push-down: a push-down into a destination whose overlay has `shared_surfaces_demote: ["quality-tiers.yml"]` and `conflict_tolerance.tolerance_percent: 5000` produces a composed `config/blast-radius.json` in which `quality-tiers.yml` is in `conflict_tolerance.append_only_paths`, is not in `shared_surfaces`, and `tolerance_percent` is 5000; proven by in-memory push-down tests in both `test_push_down_claude_blast_radius_overlay_demote.py` and `claude-blast-radius-overlay-demote.test.ts`.

Change 1, generic contract tokens:

- [ ] AC-05 Predicate definition: `is_generic_contract_token` and `Test-GenericContractToken` return true for `Sheet1`, `sheet12`, and `CHART3`, and false for `Sheet`, `Sheet1a`, `MySheet1`, `Sheet1.Range`, the empty string, a full-width-digit variant, a Kelvin-sign (U+212A) variant, `Book1`, and `Table1`; neither predicate raises on any string input.
- [ ] AC-06 Python filtering sites: `extract_contract_identifiers`, `extract_write_intent_contracts`, and `normalize_declared_radius` each drop `Sheet1` and keep a genuine contract identifier in the same input, asserted in `test_blast_radius_generic_contracts.py`.
- [ ] AC-07 PowerShell filtering sites: `Get-ContractIdentifier`, `Get-WriteIntentSpecContract`, and `Get-NormalizedDeclaredRadius` each drop `Sheet1` and keep a genuine contract identifier in the same input, asserted in `BlastRadiusGenericContract.Tests.ps1`; `Test-GenericContractToken` is exported from `BlastRadiusTokenShape.psm1` and re-exported from `BlastRadiusExtraction.psm1`.
- [ ] AC-08 Constant parity: a Pester parity test reads `GENERIC_CONTRACT_STEMS` from `_blast_radius_token_shapes.py` and asserts it equals `$script:GenericContractStem`; a pytest pins `GENERIC_CONTRACT_STEMS` to the stems `Sheet` and `Chart`. No TypeScript or bash contract extractor exists, and the rule text states that TypeScript has no contract extractor.
- [ ] AC-09 Fail-before evidence: the end-to-end issue-scenario tests in `test_blast_radius_generic_contracts.py` and `BlastRadiusGenericContract.Tests.ps1` were run against the pre-change code and failed with a hard `contract_dependency` or `shared_surface_overlap` edge, and the run is recorded under `evidence/regression-testing/` in this feature folder.

Change 2, append-only `quality-tiers.yml`:

- [ ] AC-10 Truth tables: in both `config/blast-radius.json` and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`, `quality-tiers.yml` is absent from `shared_surfaces`, is the last entry of `conflict_tolerance.append_only_paths` with the prior entries unchanged and in their prior order, and is present in `mandate_reads`; `conflict_tolerance` is byte-equal across both copies (`test_class_one_keys_are_equal_across_both_committed_copies` and Pester `'declares equal values for the runtime-describing keys in both copies'` pass).
- [ ] AC-11 Truth-table tests updated: `PORTABLE_SHARED_SURFACES`, `test_committed_conflict_tolerance_values`, `test_committed_conflict_tolerance_reads_cleanly`, the rewritten Pester truth-table test asserting the new membership in both copies, and the `SOURCE_BLAST_RADIUS` pin in `claude-config-carriage.test.ts` all pass against the edited tables.
- [ ] AC-12 Constraint 2 text: in `.claude/rules/parallel-orchestration.md` under `### Read-by-mandate classification`, constraint 2 no longer states that `quality-tiers.yml` stays a shared surface; it states that `quality-tiers.yml` is an append-only registry and a mandate read, contends on `path_overlap` at the `append_only` weight, is never a hard edge (issue #1006), and that separator-free token acceptance for it through the root-surface rule no longer applies.

Change 3, destination demotion:

- [ ] AC-13 Demotion move semantics: in both composers, each `shared_surfaces_demote` entry present in the composed `shared_surfaces` is removed from it with the order of the remaining entries preserved and is unioned into `conflict_tolerance.append_only_paths`; the directive key is absent from the composed output; demotion runs after all other keys are composed.
- [ ] AC-14 Idempotent no-op: an entry already present in the composed `conflict_tolerance.append_only_paths` and absent from `shared_surfaces` is accepted without error and leaves both lists unchanged; composing an already-composed result again yields identical output.
- [ ] AC-15 Fail closed: both composers raise `BlastRadiusOverlayError` with the identical detail text stated under Error handling and logging updates for a non-list value, a non-string member, a missing `conflict_tolerance.append_only_paths`, and an unknown entry; on rejection the destination `config/blast-radius.json` keeps its prior bytes.
- [ ] AC-16 Guard and identity preserved: the `modules` forbidden-glob guard (`FORBIDDEN_GLOBS`) still rejects forbidden globs when the overlay also carries `shared_surfaces_demote`; an overlay without the directive, or no overlay, composes byte-identically to the pre-change composer (existing issue #508 AC01 and AC18 tests pass unchanged).
- [ ] AC-17 Demotion parity corpus: the corpus fixtures `shared-surfaces-demote.json`, `shared-surfaces-demote-already-append-only.json`, and `shared-surfaces-demote-unknown-entry.json` (the last carrying `expected_error`) are asserted to the same expected text or error by both `test_ac16_corpus_composition_matches_expected` and the TypeScript "composes %s to its expected text" test; a constant-parity test pins `SHARED_SURFACES_DEMOTE_KEY` equal across the TypeScript and Python sources.
- [ ] AC-18 Key-partition coverage: `OVERLAY_DIRECTIVE_KEYS` in `blast_radius_parity_test_support.py` declares `shared_surfaces_demote`; `test_every_top_level_key_is_classified_and_shared_by_both_copies` and Pester `'requires every top-level key in both copies to be classified and shared'` assert that the directive key is disjoint from every declared truth-table key class and absent from both committed truth tables.
- [ ] AC-19 Overlay rule text: the issue #508 overlay paragraph in `.claude/rules/parallel-orchestration.md` no longer states that the overlay cannot remove a shipped surface; it documents `shared_surfaces_demote`, its fail-closed conditions, that the key is consumed, the already-append-only no-op, the unchanged forbidden-glob guard, and the `shared_surface_globs` residual.

Cross-cutting:

- [ ] AC-20 Token-shape rule text: the token-shape rejection paragraph under `### Read-by-mandate classification` lists the generic sheet-tab shape (`Sheet` or `Chart` followed by ASCII digits, compared case-insensitively) alongside the existing rejected shapes, its stated count of shapes matches the shapes listed, and a subsection "Generic contract-token rejection (issue #1006)" states that the stems are a code constant pinned equal across Python and PowerShell by a Pester parity test.
- [ ] AC-21 Bundle copies byte-identical: each edited `.claude/lib/blast-radius/*.psm1` file and `.claude/rules/parallel-orchestration.md` is byte-identical to its copy under `extensions/drm-copilot/resources/claude-customizations/`, and `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, and `test_push_down_pack_manifest_dependency_closure.py` pass.
- [ ] AC-22 Strict identity re-run: `test_property_tolerance_zero_equals_conflict`, `test_strict_identity_over_existing_conflict_fixtures`, `test_before_strict_scheduling_equals_detection`, `test_tolerance_zero_output_equals_conflict_only_output`, the Pester Context `'Strict identity'` in `BlastRadiusScheduling.Tests.ps1`, and `BlastRadius.HistoricalRuns.Tests.ps1` pass unchanged; `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` carries an unconditional skip marker, is reported as skipped by that marker, and its file is unchanged against the merge base.
- [ ] AC-23 Scope boundaries held: the change does not edit `HARD_REASON_KINDS`, `decide_pair`, `conflicts`, the `conflict_edges[].reason` enum, the parallel checkpoint schema, drift detection, `quality-tiers.yml`, or any `.github/instructions/` file; the diff touches only files named under Files/modules to change and feature-folder documentation and evidence.
- [ ] AC-24 Coverage: every changed or new production file meets the line and branch coverage thresholds of `.claude/rules/general-unit-test.md` (line only for PowerShell), measured per file as described in the execution-environment brief; `claude-blast-radius-overlay-demote.ts` has its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`; no production file is excluded from measurement; coverage on changed lines does not regress.
- [ ] AC-25 Toolchain and isolation: the seven-stage toolchain loop passes in a single pass for Python, PowerShell, and TypeScript, and the test-isolation checks in the execution-environment brief pass and are recorded under `evidence/regression-testing/` in this feature folder.

## Risks & Mitigations
- Technical or operational risks:
  - A reviewer may treat demotion as weakening fail-closed scheduling.
  - The stem set may be challenged as arbitrary.
  - Removing `quality-tiers.yml` from `shared_surfaces` ends separator-free token acceptance for it.
  - Mirror drift between `.claude/` files and bundle copies; files near the 500-line guidance tier.
  - Test-order dependence in new Pester parity tests that read module script scope.
- Mitigations and rollbacks:
  - Demotion is opt-in, fails closed on unknown entries, never touches `modules`, and leaves `HARD_REASON_KINDS` unchanged; residuals are documented in the rule text.
  - The stem set is closed to default sheet-tab names; workbook and object names (`Book`, `Table`, `PivotTable`) are excluded with rationale in the research record; zero existing corpus exposure.
  - `mandate_reads` already drops bare citations; the planner append obligation and `detect_escaped_paths` remain backstops.
  - Bundle copies are made in the same task as their sources and verified by the contract tests (AC-21); new logic goes into leaf modules and new test files.
  - Isolation checks per the execution-environment brief (AC-25). Rollback is a revert.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; destinations receive changes 1 and 2 and the demotion directive at the next extension release after rebuild and reinstall. Destinations using the interim workaround (`tolerance_percent: 5000` and `quality-tiers.yml` in `append_only_paths` in `config/blast-radius.local.json`) remain valid; the `append_only_paths` entry becomes redundant.
- Post-fix monitoring or clean-up tasks: follow-up note for the stale "three token shapes" sentence in `.claude/skills/parallel-plan/SKILL.md` and its bundle copy.
- Links: issue #1006; issue #508 (overlay); issue #722 (integration-cost scheduling); issue #489 (contention doctrine); issue #903 (ASCII guard precedent); research `research/research.2026-10-30T11-05.md`.
