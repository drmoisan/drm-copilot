# Research: parallel scheduling false hard edges from a shared surface and `Sheet1` (Issue #1006)

- Issue: #1006
- Branch: bug/parallel-scheduling-false-hard-edges-1006
- Requirements source: `issue.md` and `spec.md` in this feature folder, and the lifecycle record `docs/features/potential/promoted/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1.md`
- Environment brief: `.claude/skills/execution-environment/SKILL.md` (referenced, not restated)
- Timestamp source: UTC read from a network time service at write time (the researcher has no shell clock); `2026-10-30T11-05`.

All findings below were verified by reading the files named. Facts that need `git` or `gh` are marked for the orchestrator.

## 1. Current State

### 1.1 How the two false hard edges arise

- Hard classes are fixed in `HARD_REASON_KINDS` (`scripts/dev_tools/_blast_radius_scheduling.py`) as `shared_surface_overlap` and `contract_dependency`. `decide_pair` sets `edge = hard or tolerance_percent == 0 or cost * 100 > benefit * tolerance_percent`. PowerShell mirror: `Get-BlastRadiusPairDecision` / `Get-BlastRadiusConflictEdge` in `.claude/lib/blast-radius/BlastRadiusScheduling.psm1`.
- `conflicts` (`scripts/dev_tools/_blast_radius_conflicts.py`) intersects the recorded `shared_surfaces` and `contracts` lists of both radii. It does not re-derive them.
- **`quality-tiers.yml`.** It is in `shared_surfaces` and `mandate_reads` in both committed truth tables. Derivation and `normalize_declared_radius` drop it through `exclude_mandate_reads`, so it reaches a radius only through the planner obligation in `.claude/skills/parallel-plan/SKILL.md` ("append that exact path to the item's declared radius explicitly after normalization") or through an observed (diff) radius (`radius_from_observed_paths`). In both cases `resolve_shared_surfaces` lists it as a shared surface, and two such items get a hard `shared_surface_overlap` at every tolerance.
- **`Sheet1`.** Contract harvesting accepts any inline-code token inside an `API`/`Interface`/`Contract`/`Surface` section that has no `/` and has an ASCII letter. No rule rejects default spreadsheet sheet names, so two specs that name `Sheet1` share a contract and get a hard `contract_dependency`.

### 1.2 Contract-filtering sites (complete family)

Python authority:

| Site | File | Current filter |
|---|---|---|
| `extract_contract_identifiers` | `scripts/dev_tools/_blast_radius_extraction.py` | `"/" not in token and CONTRACT_LETTER_RE.search(token)` |
| `extract_write_intent_contracts` | `scripts/dev_tools/_blast_radius_write_intent.py` | adds `not _has_wildcard(token)`; tokens from `_single_word_tokens` |
| `normalize_declared_radius` | `scripts/dev_tools/compute_blast_radius.py` | re-filters `radius.contracts` by `CONTRACT_LETTER_RE` only |

PowerShell port (each file also has a byte-identical bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`):

| Site | File | Current filter |
|---|---|---|
| `Get-ContractIdentifier` | `.claude/lib/blast-radius/BlastRadiusNormalization.psm1` | `$token.IndexOf('/') -lt 0 -and $script:ContractLetterPattern.IsMatch($token)` |
| `Get-WriteIntentSpecContract` | `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1` | adds the `*`/`?` checks |
| `Get-NormalizedDeclaredRadius` | `.claude/lib/blast-radius/BlastRadius.psm1` | `$script:ContractLetterPattern.IsMatch([string]$identifier)` |

TypeScript: no contract extraction exists. A search of `extensions/drm-copilot/src` for contract-heading or contract-extraction symbols returned nothing; the TypeScript blast-radius code is the push-down derive and overlay only. The bash runtime under `.claude/lib/bash/` validates the `contracts` field shape in checkpoints and manifests but does not extract contracts. TypeScript and bash parity for the generic-contract constant is therefore not applicable.

Search scope for this family: `CONTRACT_LETTER_RE` and `ContractLetterPattern` across the repository (excluding `docs/`) return exactly the six sites above plus their bundle copies.

### 1.3 Truth tables and how they are produced

- `config/blast-radius.json` (self-hosted) and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` (published) are both hand-maintained committed files. No generator writes either one in this repository: a search of `scripts/` for writers of `config/blast-radius.json` finds only readers and the push-down code.
- "Regenerated" in the issue refers to the **destination**. On every push, the destination's `config/blast-radius.json` is derived from the published copy:
  - TypeScript: `BlastRadiusDeriveFileSystem` (`claude-blast-radius-derive.ts`) with `deriveDestinationModuleMap` (`claude-blast-radius-derive-core.ts`). `CARRIED_KEYS` copies `version`, `shared_surfaces`, `shared_surface_globs`, `over_breadth_fraction`, `mandate_reads`, `mergeable_paths`, `conflict_tolerance`, `write_intent_extraction`, and `path_roots` verbatim from the bundled source and derives `modules` from the destination layout.
  - Python: `BlastRadiusDeriveFileSystem` in `scripts/dev_tools/push_down_claude_destination_writes.py` with `push_down_claude_blast_radius_derive_core.py`.
- The published `shared_surfaces` and `conflict_tolerance` reach every destination unchanged unless the overlay changes them. Editing the bundled file is therefore the upstream fix for destinations. Changes reach a destination only after an extension rebuild and reinstall, because push-down serves the installed payload (execution-environment brief, MCP section).

### 1.4 Overlay composition today (issue #508)

- TypeScript: `composeBlastRadiusOverlay` in `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts`, applied by `BlastRadiusOverlayFileSystem`, which `claude-customizations.ts` wires in. It reads `config/blast-radius.local.json` (`BLAST_RADIUS_OVERLAY_RELATIVE_PATH`) only when the target write is `config/blast-radius.json`.
- Python: `compose_blast_radius_overlay` in `scripts/dev_tools/push_down_claude_blast_radius_overlay.py`. It is registered as `merge_blast_radius_overlay` in `MERGED_RELATIVE_PATHS`, and `INPUT_RELATIVE_PATHS` maps `config/blast-radius.json` to `config/blast-radius.local.json` (`push_down_claude_destination_writes.py`).
- Semantics: `STRING_LIST_KEYS` (`shared_surfaces`, `shared_surface_globs`, `mandate_reads`, `mergeable_paths`, `path_roots`) take an ordered union; `modules` is added or replaced, with the forbidden-glob guard `FORBIDDEN_GLOBS` (`**`, `docs/**`, `tests/**`); other keys merge recursively; overlay-only keys are appended. Nothing removes a base entry. This is the union-only defect.
- No PowerShell or bash code composes the overlay. A search for `blast-radius.local` outside `docs/` finds only the TypeScript and Python push-down code, their tests, and the rule file.
- Parity today: the shared corpus `tests/fixtures/blast_radius_overlay/*.json` (`base_text`, `overlay_text`, `expected_text`) is asserted by `claude-blast-radius-overlay-parity.test.ts` ("composes %s to its expected text", "discovers at least six corpus files") and by `test_ac16_corpus_composition_matches_expected` in `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py`. That file also pins `test_ac16_overlay_constants_match` and `test_ac16_merged_path_sets_match`. No test pins the composer's key classification (`STRING_LIST_KEYS`) across runtimes.

### 1.5 Key-partition exhaustiveness tests today

- Python: `test_every_top_level_key_is_classified_and_shared_by_both_copies` in `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, backed by `DECLARED_TOP_LEVEL_KEYS` in `tests/scripts/dev_tools/blast_radius_parity_test_support.py` (`BYTE_EQUAL_KEYS` + `CLASS_TWO_KEY_ASSERTIONS` + `CLASS_TWO_TOLERANCE_KEY_ASSERTIONS` + `CLASS_THREE_KEY_ASSERTIONS`).
- Pester mirror: `'requires every top-level key in both copies to be classified and shared'` in `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` (`$script:ClassOneKeys`, `$script:ClassTwoKeyConsumerFile`, `$script:ClassThreeKeyConsumerFile`).
- Both cover truth-table keys only. The overlay key will never appear in a committed truth table, so "covers the new overlay key" needs a declared overlay-directive key class (section 4.3).

### 1.6 Root-surface coupling (load-bearing for change 2)

`config_root_surfaces` (`scripts/dev_tools/_blast_radius_validation.py`) and `Get-ConfigRootSurface` (`BlastRadiusConfig.psm1`) take the separator-free entries of `shared_surfaces` as the only source for accepting a separator-free token (issue #452). Removing `quality-tiers.yml` from `shared_surfaces` stops the classifier and W4 from accepting a bare `quality-tiers.yml` citation. This changes no derived radius, because `mandate_reads` already drops that citation before it can count. A planner-appended path after normalization, and an observed diff path, are not re-classified, so both keep `quality-tiers.yml` in `paths`. It then contends only on `path_overlap`, weighted `append_only` (exact-equality match in `matches_mergeable_path`), and the append-only check runs before the same_file check in `_path_pair_weight`.

## 2. Candidate Approaches and Recommendation

### 2.1 Generic contract tokens

Recommended: **a closed code constant in the token-shape leaf modules, applied at all six filtering sites.**

- Python: add to `scripts/dev_tools/_blast_radius_token_shapes.py` (a leaf, 225 lines):
  - `GENERIC_CONTRACT_STEMS: tuple[str, ...] = tuple("Sheet Chart".split())`. The `tuple("...".split())` shape matches `READ_VERBS`, so the Pester source-reading parity pattern already used for `KNOWN_FILE_NAMES` and the write-intent vocabularies works without new parsing.
  - A compiled pattern built from the stems: `(?:Sheet|Chart)[0-9]+` with `re.IGNORECASE | re.ASCII`, applied with `fullmatch`.
  - `is_generic_contract_token(token: str) -> bool`: returns `token.isascii() and <pattern>.fullmatch(token) is not None`. This is total and never raises. The ASCII guard follows the issue #903 precedent in the same module: without it, a Kelvin sign (U+212A) matches `k` case-insensitively in .NET but not under Python `re.ASCII`.
- PowerShell: add to `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` (a leaf, 269 lines): `$script:GenericContractStem = [string[]]@('Sheet', 'Chart')`, a `[regex]` anchored with `\A...\z` and built with `IgnoreCase, CultureInvariant`, and `Test-GenericContractToken -Token` with an ordinal ASCII check (`-cmatch '\A[\x00-\x7F]*\z'`) before the match. Add it to the module's `Export-ModuleMember`, and re-export it from `BlastRadiusExtraction.psm1`. This is the established pattern for `Test-FileShapedComponent`; Normalization, WriteIntent, and the facade all import the Extraction module.
- Apply `and not is_generic_contract_token(token)` / `-and -not (Test-GenericContractToken -Token $token)` at all six sites in section 1.2.
- Stem scope decision: `Sheet` is required by the issue. `Chart` is the other default sheet-tab name Excel assigns (chart sheets), so it belongs to the same class: generic tab names. `Book`, `Table`, and `PivotTable` are workbook or object names that code references through structured references and `ListObjects`, which is a different class, so they are excluded. In this repository the only inline-code `SheetN`/`ChartN`/`BookN`/`TableN` occurrences are in this feature's own `issue.md`, `spec.md`, and lifecycle record (case-insensitive search across the whole tree). The change therefore removes no existing contract in the corpus.
- Why not a truth-table key: the placeholder-marker doctrine in `.claude/rules/parallel-orchestration.md` treats shapes that never name the thing as code constants, not configuration. A new top-level key would also have to join the Class 1 partition and change both committed copies.
- Why not filter in `conflicts`: the relation is a frozen surface, and normalization is already the sanctioned re-filter point for recorded contracts (issue #489).

### 2.2 `quality-tiers.yml` default

Recommended: in **both** committed truth tables, remove `"quality-tiers.yml"` from `shared_surfaces`, append it as the last entry of `conflict_tolerance.append_only_paths`, and keep it in `mandate_reads`. `conflict_tolerance` is a Class 1 (byte-equal) key, so both copies must carry the identical three-entry list `["**/CHANGELOG.md", "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json", "quality-tiers.yml"]`. Appending keeps the existing order and matches how the overlay union appends.

### 2.3 Destination demotion

Recommended overlay directive key: `shared_surfaces_demote`, a list of strings, implemented in both composers and applied **after** every other key is composed:

1. A non-list value, or a list with a non-string member, raises `BlastRadiusOverlayError` with detail `key "shared_surfaces_demote" must be a list of strings`.
2. If the composed document has no `conflict_tolerance` object with an `append_only_paths` list, raise: `key "shared_surfaces_demote" requires conflict_tolerance.append_only_paths in the composed document`. Do not create a partial `conflict_tolerance`: `config_conflict_tolerance` requires exactly five members, so a partial object would fail later in a reader instead of at compose time.
3. Each entry must be **known**: a member of the composed `shared_surfaces` or of the composed `conflict_tolerance.append_only_paths`. An unknown entry raises `key "shared_surfaces_demote" names "<entry>", which is neither a shared surface nor an append-only path` (fail closed, for example on a typo). Accepting entries already in `append_only_paths` is required for two reasons:
   - The acceptance criterion: after change 2 the published base no longer lists `quality-tiers.yml` as shared, so the AC4 overlay `shared_surfaces_demote: ["quality-tiers.yml"]` must be a successful no-op, not an error.
   - It keeps the existing AC18 idempotence property when the result is composed again.
4. Remove each demoted entry from the composed `shared_surfaces` (the order of the remaining entries is preserved), then union the demoted entries into `conflict_tolerance.append_only_paths` with `unionStrings` / `_union_strings` semantics.
5. Consume the directive: `shared_surfaces_demote` is **not** emitted in the composed document, so the composed file stays within the truth-table key set.
6. The forbidden-glob guard on `modules` is unchanged and still runs. Demotion never touches `modules`.
7. With no overlay, or an overlay without the key, output stays byte-identical to today, so the AC01 and AC18 identity properties hold.

Documented residuals:
- A demoted entry that a `shared_surface_globs` pattern still matches stays shared through the glob. The bundled glob list is empty, and the rule text must state this.
- Demoting a separator-free surface removes separator-free token acceptance for that name (section 1.6). The planner append obligation and `detect_escaped_paths` remain the backstops.

Rejected alternatives (brief):
- A removal syntax inside `shared_surfaces` (for example a `!` prefix). It is implicit and harder to make fail closed.
- Replace semantics for `shared_surfaces`. That would let a destination silently drop `.claude/settings.json` and `config/blast-radius.json`.
- Extending `config_root_surfaces` to separator-free `append_only_paths` entries. Not needed for `quality-tiers.yml` (it is a mandate read), and it widens a frozen reader in two runtimes. Record it as a residual instead.

## 3. Behavior Semantics

- Success: a pair whose overlap is only `quality-tiers.yml` (appended or observed), generic sheet names in specs, and ordinary path or module overlap yields `hard == False`. At the committed tolerance (100) it is an edge or a tolerated overlap according to `cost * 100 > benefit * tolerance_percent`. At `tolerance_percent` 0 every detected conflict is an edge (`decide_pair` short-circuits on zero), so the edge set equals the detected-conflict set.
- The detection relation, `HARD_REASON_KINDS`, the `conflict_edges[].reason` enum, and the checkpoint schema are unchanged (the issue lists them as out of scope).
- Failure modes: a malformed `shared_surfaces_demote`, an unknown entry, or a missing `conflict_tolerance.append_only_paths` raises before any write, so the destination `config/blast-radius.json` keeps its prior bytes. This is the existing `_rejected_write` contract.
- Ordering: overlay composition, then demotion. Generic-token rejection runs after the separator and letter tests at each site. Its position does not change results, because the tests are a conjunction.

## 4. Requirements Mapping and File Changes

### 4.1 Change 1: generic contract tokens

| File | Symbols |
|---|---|
| `scripts/dev_tools/_blast_radius_token_shapes.py` | new `GENERIC_CONTRACT_STEMS`, compiled pattern, `is_generic_contract_token`; module docstring parity note |
| `scripts/dev_tools/_blast_radius_extraction.py` (468 lines) | import `is_generic_contract_token`; filter in `extract_contract_identifiers`; docstring "Returns" clause |
| `scripts/dev_tools/_blast_radius_write_intent.py` (421 lines) | import; filter in `extract_write_intent_contracts` |
| `scripts/dev_tools/compute_blast_radius.py` (473 lines) | import from `_blast_radius_token_shapes`; filter in `normalize_declared_radius` |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | `$script:GenericContractStem`, `$script:GenericContractPattern`, `Test-GenericContractToken`, export, `.DESCRIPTION` parity note |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` (464 lines) | add `Test-GenericContractToken` to `Export-ModuleMember` |
| `.claude/lib/blast-radius/BlastRadiusNormalization.psm1` | filter in `Get-ContractIdentifier` |
| `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1` (446 lines) | filter in `Get-WriteIntentSpecContract` |
| `.claude/lib/blast-radius/BlastRadius.psm1` (475 lines) | filter in `Get-NormalizedDeclaredRadius` |
| five bundle copies of the PowerShell files above | byte-identical copies |

### 4.2 Change 2: append-only `quality-tiers.yml`

| File | Change |
|---|---|
| `config/blast-radius.json` | remove from `shared_surfaces`; append to `conflict_tolerance.append_only_paths`; keep in `mandate_reads` |
| `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | the same change |
| `.claude/rules/parallel-orchestration.md` (and its bundle copy) | rewrite read-by-mandate constraint 2 (currently "`quality-tiers.yml` stays a shared surface."): it is an append-only registry and a mandate read, it contends on `path_overlap` at the `append_only` weight, and it is never hard (issue #1006). Note the root-surface consequence from section 1.6. |

### 4.3 Change 3: overlay demotion

| File | Symbols |
|---|---|
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts` (new) | `export const SHARED_SURFACES_DEMOTE_KEY = "shared_surfaces_demote"`; pure `applySharedSurfaceDemotion(composed, overlayValue, overlayPath)` |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` (447 lines) | `composeBlastRadiusOverlay` skips the directive key in its overlay-only loop and calls the demotion after composition; header docblock rules list |
| `extensions/drm-copilot/jest.config.cjs` | per-file `coverageThreshold` entry for the new module (`lines: 85`, `branches: 75`). The map has per-file entries only and no `global` key. |
| `scripts/dev_tools/push_down_claude_blast_radius_overlay.py` (286 lines) | `SHARED_SURFACES_DEMOTE_KEY`, `_apply_shared_surface_demotion`, the change in `compose_blast_radius_overlay`, `__all__`, module docstring rules list |
| `.claude/rules/parallel-orchestration.md` (and its bundle copy) | issue #508 overlay paragraph: replace "The overlay cannot remove a shipped surface or a derived module." with the demotion semantics, the fail-closed conditions, the consumed key, and the glob residual |

The TypeScript module split keeps `claude-blast-radius-overlay.ts` under the 500-line guidance tier. The Python module has headroom, so the change stays inline there.

Key-partition coverage (AC2): declare `OVERLAY_DIRECTIVE_KEYS = ("shared_surfaces_demote",)` in `blast_radius_parity_test_support.py`. Extend `test_every_top_level_key_is_classified_and_shared_by_both_copies` and the Pester `'requires every top-level key in both copies to be classified and shared'` to assert that the directive key is disjoint from the declared truth-table classes and absent from both committed copies. In `test_push_down_claude_overlay_parity.py`, add a constant parity test that reads `SHARED_SURFACES_DEMOTE_KEY` from the TypeScript source by regex, following the `_OVERLAY_CONSTANT` precedent.

### 4.4 Documentation to edit

- `.claude/rules/parallel-orchestration.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` (byte-identical). Edits:
  - Change "rejects four token shapes" to five, adding "a contract token that is a default spreadsheet sheet name (`Sheet` or `Chart` followed by ASCII digits, compared case-insensitively)".
  - Add a short subsection "Generic contract-token rejection (issue #1006)" stating that the constant is a code constant pinned equal across Python and PowerShell by a Pester parity test, and that TypeScript has no contract extractor.
  - Constraint 2 (section 4.2) and the overlay paragraph (section 4.3).
  - The "exactly as for the three shapes above" sentence in the placeholder subsection stays accurate if the new shape is listed fifth.
- No `.github/instructions/` file, no `.agents/`, `.github/`, or `.codex/` mirror, and no `quality-tiers.yml` edit is required. Neither the rule nor the blast-radius modules have mirrors outside the bundle, and no new project is added.
- `.claude/skills/parallel-plan/SKILL.md` says the extractor rejects "three token shapes". This was already stale before this change. Out of scope; record it as a follow-up note rather than edit it, which would also require its bundle mirror.

## 5. Existing Tests Affected (search: symbols, file names, `quality-tiers.yml`, constraint-2 text)

| Test (file :: name) | Why it changes | Disposition |
|---|---|---|
| `blast_radius_parity_test_support.py` :: `PORTABLE_SHARED_SURFACES` (consumed by `test_class_two_bundled_shared_surfaces_are_the_portable_set`) | the bundled `shared_surfaces` loses `quality-tiers.yml` | Update: drop the entry and its comment; add `OVERLAY_DIRECTIVE_KEYS` |
| `test_blast_radius_config_tolerance_keys.py` :: `test_committed_conflict_tolerance_values`, `test_committed_conflict_tolerance_reads_cleanly` | `COMMITTED_CONFLICT_TOLERANCE["append_only_paths"]` and the pinned tuple | Update both to the three-entry list |
| `BlastRadius.TruthTable.Tests.ps1` :: `'lists quality-tiers.yml as both a shared surface and a mandate read'` | asserts `shared_surfaces` contains it | Rewrite: in both copies, assert it is in `conflict_tolerance.append_only_paths` and `mandate_reads` and not in `shared_surfaces` |
| `config-carriage.test-helpers.ts` :: `SOURCE_BLAST_RADIUS` (pinned by `claude-config-carriage.test.ts` "keeps SOURCE_BLAST_RADIUS in step with the committed bundled blast-radius resource") | must equal the bundled file | Update the fixture and its docblock ("six-entry ... three separator-free" becomes five and two) |
| `test_blast_radius_config_parity.py` :: `test_every_top_level_key_is_classified_and_shared_by_both_copies` | AC2 coverage | Extend (section 4.3) |
| `BlastRadius.KeyPartition.Tests.ps1` :: `'requires every top-level key in both copies to be classified and shared'` | AC2 coverage | Extend |
| `test_push_down_claude_overlay_parity.py` :: `test_ac16_corpus_composition_matches_expected`; `claude-blast-radius-overlay-parity.test.ts` :: "composes %s to its expected text" | new corpus cases with an optional `expected_error` field | Update both loaders to assert the thrown message when `expected_error` is present |
| `test_class_one_keys_are_equal_across_both_committed_copies`; Pester `'declares equal values for the runtime-describing keys in both copies'` | `conflict_tolerance` changes identically in both copies | Unchanged; re-run |
| `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle`, `test_every_separator_free_bundled_shared_surface_is_wildcard_free`, `test_the_gate_compares_non_empty_collections`, Pester `'gives every separator-free bundled shared surface no wildcard'` | the separator-free set shrinks to `package-lock.json` and `poetry.lock` but stays non-empty | Unchanged; re-run |
| `test_blast_radius_verification_integrity.py` :: AFTER tests | read the committed config; recorded radii hold no `SheetN` contract, and `quality-tiers.yml` is already a mandate read | Unchanged; re-run |
| `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` `g1-plan-quality-tiers-mandate-read` (`config_ref: self_hosted`) | expects no conflict | Unchanged (still a mandate read); re-run `test_blast_radius_regression_452.py` and `BlastRadius.Regression452.Tests.ps1` |
| `test_push_down_claude_blast_radius_overlay.py` :: `test_ac18_*` (`PROPERTY_OVERLAYS`); `claude-blast-radius-overlay.test.ts` "issue #508 AC18 properties" | the domain has no directive key | Unchanged. Do not add demote overlays to `PROPERTY_OVERLAYS`: superset intentionally does not hold for `shared_surfaces` under demotion, and `test_ac18_enumerates_all_24_pairs` pins the domain size. |
| `test_ac04_overlay_only_key_is_appended_last`, TS "appends an overlay-only key after every base key" | use `custom_key` | Unchanged |
| Historical-runs AFTER (`test_blast_radius_historical_runs.py`, `BlastRadius.HistoricalRuns.Tests.ps1`) | `after.config` is embedded in the fixtures, not read from the committed file | Unchanged; the fixtures stay pinned to issue #722 |
| Contract-extraction tests (`test_blast_radius_extraction.py`, `test_blast_radius_write_intent.py`, `BlastRadiusNormalization.Tests.ps1`, `BlastRadiusWriteIntent.Tests.ps1`, `BlastRadius.Tests.ps1`) | no fixture or test names a `SheetN`/`ChartN` token (search of `tests/` returned zero) | Unchanged; re-run |
| `test_blast_radius_mandate_reads.py` :: `test_derive_without_the_mandate_reads_key_includes_the_citations` | loads the committed `config/blast-radius.json` through `committed_config()`, removes `mandate_reads`, and asserts `quality-tiers.yml` is in `radius.paths` and `radius.shared_surfaces`; after change 2 `config_root_surfaces` no longer yields it, so `classify_path_token` rejects the separator-free citation and both assertions fail | Update: the arranged config also sets `shared_surfaces` to the committed entries plus `quality-tiers.yml`, keeping the test's intent (corrected classification; an earlier revision of this table listed the file as inline-config) |
| Other tests of `test_blast_radius_mandate_reads.py` (`test_derive_excludes_mandate_read_citations_from_every_level`, `test_derive_with_an_absent_key_matches_an_empty_mandate_read_list`, `test_derive_excludes_an_artifacts_path_through_the_subtree_glob`, `test_derived_radius_validates_clean_against_its_own_mandate_citing_plan`, and the `config_mandate_reads` tests) | assert absence, identity, or the symmetric filter, or use inline mappings | Unchanged; re-run |
| `test_blast_radius_regression_452.py` :: `test_bundled_separator_free_shared_surfaces_equal_the_self_hosted_subset`; Pester `BlastRadius.Regression452.Tests.ps1` root-surface equality row | both committed copies lose the same entry, so the sets stay equal and non-empty | Unchanged; re-run |
| Pester `BlastRadius.Parity.Tests.ps1` :: `'Verification-integrity regression (issue #489)'` After state | reads the committed config; `quality-tiers.yml` is a mandate read before and after | Unchanged; re-run |
| Comments above `CONFIGURED_ROOT_SURFACES` in `test_blast_radius_extraction.py` and in the Context `'Configured separator-free root surfaces'` of `BlastRadiusExtraction.Path.Tests.ps1` | the assertions use an inline set, but each comment states the set equals the committed separator-free subset, which change 2 makes false | Update the comments only |
| Inline-config tests naming `quality-tiers.yml` (`test_blast_radius_normalization.py`, `test_blast_radius_invariants.py`, `BlastRadiusConfig.Tests.ps1`, `BlastRadiusNormalization.Tests.ps1`, `BlastRadius.Tests.ps1`, `BlastRadius.Conflict.Tests.ps1`, `BlastRadiusExtraction.Path.Tests.ps1`, the derivation and validation fixtures under `tests/fixtures/blast_radius/`) | each supplies its own config | Unchanged |
| Local tolerance constants (`blast-radius-derive-tolerance-keys.test.ts` `CONFLICT_TOLERANCE`, Pester `Get-CommittedToleranceMember`, `ZERO_TOLERANCE`) | local values, never compared to the committed file | Unchanged; "committed" comments become historical, and editing them is optional |

## 6. Strict-Identity Proof: Current Tests and How to Keep It

Current pins:
- `test_property_tolerance_zero_equals_conflict` (`test_blast_radius_scheduling_properties.py`): exhaustive over a fixed radius domain and three weight tables.
- `test_strict_identity_over_existing_conflict_fixtures` (`test_blast_radius_scheduling.py`).
- `test_before_strict_scheduling_equals_detection` (`test_blast_radius_historical_runs.py`).
- `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` (`test_blast_radius_regression_452.py`). This test carries an unconditional `@pytest.mark.skip(reason=TOLERANCE_SKIP_REASON)`, so a re-run reports it as skipped, never as passed; the pin is that it stays skipped and its file is unchanged.
- `test_tolerance_zero_output_equals_conflict_only_output` (`test_parallel_drift_scheduling.py`).
- Pester: Context `'Strict identity'` in `BlastRadiusScheduling.Tests.ps1`, and `BlastRadius.HistoricalRuns.Tests.ps1`.

Why the change keeps it: `decide_pair`, `conflicts`, `HARD_REASON_KINDS`, and the reader are untouched. The change alters only inputs: the radius contents (contracts) and the configuration (`shared_surfaces` membership). The inputs feed the same relation, and the explicit `tolerance_percent == 0` short-circuit makes edge equal conflict for any input. Every existing pin above is re-run unchanged. The new end-to-end regression (section 7) adds a tolerance-0 assertion on the issue's own scenario under both committed tables.

## 7. Testing Implications (no test code)

New test files (production-adjacent files near 500 lines get no new cases):
- `tests/scripts/dev_tools/test_blast_radius_generic_contracts.py`:
  - `is_generic_contract_token` positive cases (`Sheet1`, `sheet12`, `CHART3`).
  - Negative cases: `Sheet`, `Sheet1a`, `MySheet1`, `Sheet1.Range`, empty string, a full-width digit, a Kelvin-sign variant, `Book1`, `Table1`.
  - Each of the three sites drops `Sheet1` and keeps a genuine identifier.
  - `normalize_declared_radius` drops a recorded `Sheet1`.
  - A pin of `GENERIC_CONTRACT_STEMS`.
  - Regression for AC1: derive two radii from plans that write an ordinary shared file, specs with `Sheet1` in a `## Interface` section, and `quality-tiers.yml` appended after normalization. Under both committed tables, assert no edge is hard. At tolerance 0, assert the edge set equals the detected-conflict set.
  - Before the change, this regression fails with a `contract_dependency` or `shared_surface_overlap` hard edge: the fail-before evidence.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1`:
  - The Pester mirror of the predicate cases and the three sites.
  - A parity `It` that reads `GENERIC_CONTRACT_STEMS` from the Python source (matching `\x22` like the `KNOWN_FILE_NAMES` case) and pins `$script:GenericContractStem` equal, using the `(Get-Command Test-GenericContractToken).ScriptBlock.Module` access pattern.
  - The AC1 scenario through `Get-BlastRadiusConflictEdge` with `-Relation ${function:Test-BlastRadiusConflict}`.
- `tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay_demote.py`:
  - Demotion semantics: move, order, consumed key, no-op on an already-append-only entry, unknown entry, non-list, missing `conflict_tolerance`, and the `_rejected_write` prior-bytes contract.
  - An AC4 push: seed the bundle's `config/blast-radius.json` with the committed bundled text and the destination overlay `{"shared_surfaces_demote": ["quality-tiers.yml"], "conflict_tolerance": {"tolerance_percent": 5000}}`. Assert that `quality-tiers.yml` is in `append_only_paths`, not in `shared_surfaces`, and that `tolerance_percent` is 5000.
- `extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-demote.test.ts`: the TypeScript mirror, using `seedTree`/`publish`/`layoutLister` from `config-carriage.test-helpers.ts` for the AC4 push. `SOURCE_BLAST_RADIUS` is pinned equal to the committed bundle.
- Corpus (shared by both parity tests):
  - `tests/fixtures/blast_radius_overlay/shared-surfaces-demote.json`: a base with `quality-tiers.yml` shared, which is demoted.
  - `shared-surfaces-demote-already-append-only.json`: the post-change bundle shape, where demotion is a no-op.
  - `shared-surfaces-demote-unknown-entry.json`: carries `expected_error`.

Run the toolchain loop per language. Run the contract tests listed under "Contract Tests That Pin Mirrored Files" in the execution-environment brief after the mirrors are updated.

## Pre-Mortem

- Review checklists: a reviewer can flag the demotion as weakening fail-closed scheduling, or flag the stem set as unjustified. Mitigation: the plan cites the closed-set rationale (default sheet-tab names only) and the zero-exposure corpus search, keeps `HARD_REASON_KINDS` unchanged, and documents both residuals (glob membership, separator-free acceptance) in the rule text.
- Coverage: the new Python predicate branches (non-ASCII, match, non-match), the TypeScript demote module (new per-file Jest threshold), and `Test-GenericContractToken` can fall below 85% line / 75% branch. Mitigation: per-file measurement with dotted `--cov=` module paths and JSON branch figures; a new `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`; per-file line coverage read from `artifacts/pester/powershell-coverage.xml`.
- Mirror parity: five `.psm1` files and the rule have byte-identical bundle copies, and `config/blast-radius.json` has the published copy, which is not a mirror but shares the Class 1 `conflict_tolerance`. Mitigation: one task copies each `.claude/` file to its bundle path, then runs `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, the Class 1 parity tests, and the `SOURCE_BLAST_RADIUS` pin. No execution-environment brief fact changes, so no brief-update task is needed.
- File size: the files are near the 500-line guidance tier:
  - Production: `_blast_radius_extraction.py` 468, `compute_blast_radius.py` 473, `BlastRadius.psm1` 475, `BlastRadiusExtraction.psm1` 464, `claude-blast-radius-overlay.ts` 447.
  - Tests: `test_push_down_claude_blast_radius_overlay.py` 500, `test_blast_radius_config_parity.py` 499, `test_blast_radius_write_intent.py` 495, `claude-config-carriage.test.ts` 494, `BlastRadiusConfig.Tests.ps1` 500.

  Mitigation: new logic goes into the leaf modules and the new TypeScript module; new cases go into new test files; existing files gain at most a few lines. Nothing approaches the 800-line hard limit.
- Test isolation: the new tests read committed files only (truth tables, the Python source, corpus fixtures) through in-memory file systems. They create no temporary files, and the Pester parity reads the module's script scope without mutating it. Mitigation: run the brief's isolation checks (seeded Jest shuffle, reversed Python order, three-seed shuffled Pester, a fresh single-process `tests/scripts` run) and record each under `evidence/regression-testing/`.
- CI-only behavior: the new Pester file builds its path to the Python source with `Join-Path` and forward-slash segments, uses exact file-name case for the case-sensitive Linux shard, and contains no drive letters. Corpus JSON is LF-normalized. No test reads gitignored `artifacts/` state or diffs against `origin/main`.
- Evidence: fail-before evidence for the AC1 regression (Python and Pester), the baseline and final coverage per language, the mirror-contract runs, and the isolation runs go under `<FEATURE>/evidence/<kind>/`. Filenames carry the write-time UTC stamp. A push-down served by MCP proves nothing about the branch, because it writes the installed payload, so AC4 is proven by the in-memory push tests.

## Batch Budget

- Distinct non-test PowerShell production files: 10 (five `.claude/lib/blast-radius/*.psm1` plus five bundle copies). Distinct non-test Python production files: 5 (`_blast_radius_token_shapes.py`, `_blast_radius_extraction.py`, `_blast_radius_write_intent.py`, `compute_blast_radius.py`, `push_down_claude_blast_radius_overlay.py`). Both exceed the direct-mode cap of three per kind (`POWERSHELL_LARGE_PATH_REQUIRED` / `PYTHON_LARGE_PATH_REQUIRED`).
- The orchestrator must select the `large` route in a non-terminal `artifacts/orchestration/orchestrator-state.json` in the item worktree, and must not run the executor in an isolated subagent worktree, which has no checkpoint (orchestrator to confirm).

## Automation Feasibility

No human interaction is needed. Every change is a file edit with in-memory or committed-file tests. AC4 is proven by in-memory push-down tests in both runtimes, not by a live destination push, because a live MCP push-down needs an extension rebuild and reinstall. The only orchestrator-owned items are:
- route selection for the batch budget;
- confirming the branch base with `git` (the researcher cannot run `git`);
- CI dispatch and polling.

## Complete File List

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

Items 38 to 40 were added after the initial list (section 5); they are numbered last so the earlier numbering is unchanged.

Feature documentation (written by later phases, listed for completeness): `docs/features/active/2026-10-30-parallel-scheduling-false-hard-edges-from-shared-surface-and-sheet1-1006/spec.md` and the plan file, plus evidence files under that folder's `evidence/<kind>/`.
