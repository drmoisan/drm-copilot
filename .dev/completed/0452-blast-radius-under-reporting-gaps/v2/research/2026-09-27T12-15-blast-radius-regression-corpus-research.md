# Research: Blast-Radius Under-Reporting Regression Corpus (Issue #452, v2)

- Issue: #452 (Bug: Blast-radius under-reporting gaps (F1 follow-up))
- Branch: `bug/blast-radius-under-reporting-regression-452`
- Baseline: `main` at `beae3f02`
- Scope: v2 cycle. The v1 documents in the feature root (`spec.md`, `plan.2026-08-08T09-43.md`, `research/`, `feature-audit.2026-08-08T13-26.md`) are read-only background and were not modified.
- Date: 2026-09-27

## Findings Summary

1. Both gaps are corrected on current `main` in every runtime that evaluates contention. Verification was by code reading with line citations; see "Verification Method" for why no command was executed in this session.
   - Gap 1 (separator-free root surfaces): Python `classify_path_token` admits a token that is an exact ordinal member of `root_surfaces` (`scripts/dev_tools/_blast_radius_extraction.py:281-282`), fed by `config_root_surfaces` (`scripts/dev_tools/_blast_radius_validation.py:136-171`). PowerShell `Get-PathTokenKind` does the same (`.claude/lib/blast-radius/BlastRadiusExtraction.psm1:293-297`), fed by `Get-ConfigRootSurface` (`.claude/lib/blast-radius/BlastRadiusConfig.psm1:233-283`).
   - Gap 2 (listed-directory prefixes on both sides): Python `_entries_overlap` (`scripts/dev_tools/_blast_radius_glob.py:273-316`) and PowerShell `Test-EntryOverlap` (`.claude/lib/blast-radius/BlastRadiusGlob.psm1:273-348`) both apply the anchored directory rule in the concrete-concrete branch and a two-way literal-prefix nest in both mixed branches.
2. TypeScript does not evaluate contention and does not extract path tokens. The three `claude-blast-radius-derive*.ts` modules only derive a destination module map and carry `shared_surfaces` verbatim. TypeScript should be excluded from corpus consumption.
3. The bash library does not evaluate contention (no `path_overlap`, `shared_surface_overlap`, or `entries_overlap` in `.claude/lib/bash/`); it only colors a caller-supplied edge list.
4. The bundled config is not byte-identical to the root config by design (issue #500 doctrine). Its separator-free `shared_surfaces` subset is identical to the root's: `package-lock.json`, `poetry.lock`, `quality-tiers.yml`.
5. `quality-tiers.yml` is admitted by Gap 1 at the token level, but a plan citation of it never reaches a derived radius, because it is also a `mandate_reads` entry and `derive_blast_radius` removes mandate reads after extraction (`scripts/dev_tools/compute_blast_radius.py:280`). This is the designed doctrine (`.claude/rules/parallel-orchestration.md`, "Read-by-mandate classification", constraint 2), not an under-report. The corpus must pin it as a documented exclusion rather than assert a conflict.
6. There is no `conflict_tolerance`, `integration_cost`, or tolerance scheduling layer on `main` in any runtime.
7. No runtime needs a production correction. The v2 work is test-only: one new shared JSON corpus plus one new Python consumer and one new Pester consumer.

## Verification Method

This research session exposed only the Read, Grep, Glob, Write, Edit, and WebFetch tools. No Bash or PowerShell tool was available, so no `poetry run python` snippet and no `pwsh -NoProfile -Command` invocation could be executed. Every verdict below was derived by tracing the cited source lines. This is stated plainly so the plan schedules a Phase 0 runtime confirmation (script provided in "Proposed Phase 0 Runtime Confirmation").

Line counts were measured with `Grep` pattern `^` in count mode, which counts lines per file.

## 1. Python Authority

### Modules and functions

| Concern | Module | Function | Lines |
|---|---|---|---|
| Token classification (Gap 1 admission) | `scripts/dev_tools/_blast_radius_extraction.py` | `classify_path_token(token: str, *, root_surfaces: Sequence[str] = ()) -> PathTokenKind \| None` | 243-341 |
| Line-level extraction | same | `extract_paths_from_lines(lines: Sequence[str], *, root_surfaces: Sequence[str] = ()) -> tuple[str, ...]` | 344-375 |
| Plan extraction | same | `extract_plan_paths(plan_text: str, *, root_surfaces: Sequence[str] = ()) -> tuple[str, ...]` | 378-413 |
| Root-surface source | `scripts/dev_tools/_blast_radius_validation.py` | `config_root_surfaces(config: Mapping[str, object]) -> tuple[str, ...]` | 136-171 |
| Mandate-read source | same | `config_mandate_reads(config) -> tuple[str, ...]` | 174-203 |
| Surface resolution | same | `resolve_shared_surfaces(concrete_paths, config) -> tuple[str, ...]` | 265-293 |
| Derivation facade | `scripts/dev_tools/compute_blast_radius.py` | `derive_blast_radius(plan_text, spec_text, feature_folder, config, *, source="derived", computed_at) -> BlastRadius` | 223-291 |
| Radius model | same | `BlastRadius` (frozen dataclass; `paths`, `modules`, `shared_surfaces`, `contracts`, `source`, `computed_at`; `from_dict`, `to_dict`) | 103-220 |
| Contention relation | `scripts/dev_tools/_blast_radius_conflicts.py` | `conflicts(a: BlastRadius, b: BlastRadius, config: Mapping[str, object]) -> ConflictResult` | 160-208 |
| Path level | same | `_smallest_path_overlap(a_paths, b_paths) -> str \| None` | 211-240 |
| Set levels | same | `_smallest_common(left, right) -> str \| None` | 243-257 |
| Entry overlap (Gap 2) | `scripts/dev_tools/_blast_radius_glob.py` | `_entries_overlap(entry_a: str, entry_b: str) -> bool` | 273-316 |
| Directory anchor | same | `_directory_prefix(entry) -> str` (`entry.rstrip("/") + "/"`) | 225-246 |
| Two-way nest | same | `_prefixes_nest(left, right) -> bool` | 249-270 |
| Literal prefix | same | `_literal_prefix(entry) -> str` | 207-222 |
| Mergeable filter | `scripts/dev_tools/_blast_radius_mergeable.py` | `config_mergeable_paths`, `exclude_mergeable_paths` | 60-79, 137-160 |

The facade re-exports `BlastRadius`, `ConflictReason`, `ConflictResult`, `conflicts`, `derive_blast_radius`, `extract_plan_paths` (`compute_blast_radius.py:65-77`). `classify_path_token` is not in `__all__` but is importable from `scripts.dev_tools._blast_radius_extraction`; `config_root_surfaces` is importable from `scripts.dev_tools._blast_radius_validation`.

### Returned structure

`ConflictResult(conflict: bool, reasons: tuple[ConflictReason, ...])` (`_blast_radius_conflicts.py:102-157`). `ConflictReason(kind: str, detail: str)` (`:69-99`). Reason kinds, in fixed order: `path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency` (`:52-61`). `conflict` equals `bool(reasons)` and is enforced at construction (`:132-133`). The path detail is the ordinally smallest overlapping pair, each pair ordered and joined with `" ~ "` (`:66`, `:228-240`). The set-level detail is the smallest common element (`:254-257`).

### How config is supplied

`conflicts` receives a parsed mapping, validates it with `require_mapping`, and reads exactly one key, `mergeable_paths` (`:181-191`). It does not apply `mandate_reads`, does not re-resolve modules, and reads `modules`, `shared_surfaces`, and `contracts` from the radius objects only (`:198-206`). `derive_blast_radius` reads `shared_surfaces` (via `config_root_surfaces`), `mandate_reads`, `modules`, and `shared_surface_globs` from the same mapping (`compute_blast_radius.py:261-289`).

### Gap 1 trace (Python)

`classify_path_token("poetry.lock", root_surfaces=("package-lock.json", "poetry.lock", "quality-tiers.yml"))`: line 281 matches exact equality and returns `"concrete"`. Without the kwarg, line 304 rejects the separator-free token (`"/" not in token`), returning `None`. `derive_blast_radius` passes `config_root_surfaces(config)` to both extraction calls (`compute_blast_radius.py:261, 267-272`); `validate_blast_radius` passes it to V1/V2 extraction (`_blast_radius_validation.py:332`); `normalize_declared_radius` passes it to reclassification (`compute_blast_radius.py:338-347`).

### Gap 2 trace (Python)

- `_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")`: `b` is a glob, so line 309-312 runs. `matches_glob("scripts/dev_tools/**", "scripts/dev_tools")` is false (regex `scripts/dev_tools/.*` requires the separator). `_prefixes_nest(_literal_prefix("scripts/dev_tools/**") = "scripts/dev_tools/", _directory_prefix("scripts/dev_tools") = "scripts/dev_tools/")` is true. Result: `True`.
- Reversed arguments take lines 305-308 with the same operands. Result: `True`.
- Concrete-concrete directory containment: lines 299-304.

## 2. PowerShell Port

| Concern | Module | Function | Lines |
|---|---|---|---|
| Token classification | `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | `Get-PathTokenKind -Token <string> [-RootSurface <string[]>]` returns `'concrete'`, `'glob'`, or `$null` | 242-373 (constants 98-99) |
| Line extraction | same | `Get-PathFromLine -Line <string[]> [-RootSurface <string[]>]` | 375-417 |
| Plan extraction | same | `Get-PlanPaths -PlanText <string> [-RootSurface <string[]>]` | 419-463 |
| Root-surface source | `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | `Get-ConfigRootSurface -Config <object>` | 233-283 |
| Derivation | `.claude/lib/blast-radius/BlastRadius.psm1` | `Get-BlastRadius -PlanText -SpecText -FeatureFolder -Config [-Source] -ComputedAt` returns a hashtable with the six radius keys | 106-200 |
| Contention | same | `Test-BlastRadiusConflict -RadiusA -RadiusB -Config` returns `@{ conflict = <bool>; reasons = @(@{ kind; detail }, ...) }` | 342-430 |
| Entry overlap (Gap 2) | `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | `Test-EntryOverlap -EntryA -EntryB` | 273-348 |
| Path/set levels | `.claude/lib/blast-radius/BlastRadiusConflict.psm1` | `Get-SmallestPathOverlap`, `Get-SmallestCommonEntry`, `Get-NonMergeablePathEntry` | 193-241, 243-283, 148-191 |

The facade exports `Get-PlanPaths`, `Get-BlastRadius`, `Get-NormalizedDeclaredRadius`, `Get-BlastRadiusFromObservedPaths`, `Test-BlastRadius`, `Test-BlastRadiusConflict` (`BlastRadius.psm1:432-438`). `Get-PathTokenKind` is exported by `BlastRadiusExtraction.psm1:465-473` and `Get-ConfigRootSurface` by `BlastRadiusConfig.psm1:464-469`, so a Pester consumer imports those two modules directly for token cases. The verdict must be read from `$result['conflict']`; the hashtable itself is always truthy (`BlastRadius.psm1:371-380`).

Gap 1: the exact-ordinal loop at `BlastRadiusExtraction.psm1:293-297` precedes the separator guard at `:315-318`. Gap 2: concrete-concrete branch `BlastRadiusGlob.psm1:314-324`; mixed branches `:329-342` compute `TrimEnd('/') + '/'` and test `StartsWith` in both directions, matching Python operand for operand.

Runtime reproduction via `pwsh -NoProfile -Command` was not attempted because no shell tool was available in this session (see "Verification Method"). Code reading shows the PowerShell logic is operand-equivalent to Python for every corpus case below.

Bundled PowerShell copy: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/*.psm1` carries the same Gap 1 and Gap 2 lines (`BlastRadiusGlob.psm1:323, 334, 341`; `BlastRadiusExtraction.psm1:288`; `BlastRadiusConfig.psm1:240`), and each of the eight files has the same line count as its root counterpart. Text equality is enforced by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143`).

## 3. TypeScript

Siblings under `extensions/drm-copilot/src/lib/push-down/`:

| File | Role |
|---|---|
| `claude-blast-radius-derive.ts` | I/O layer: `realDirectoryLister` (`:114`), `collectDestinationObservations` (`:163`); scans the destination directory tree. |
| `claude-blast-radius-derive-manifests.ts` | Manifest vocabulary and `classifyProjectDirectories` (`:177`); classifies project directories. |
| `claude-blast-radius-derive-core.ts` | Pure core: `deriveDestinationModuleMap(observations, sourceDocumentText): string` (`:342-380`); derives `modules` and copies `version`, `shared_surfaces`, `shared_surface_globs`, `mandate_reads`, `mergeable_paths`, `over_breadth_fraction` verbatim from the bundled source (`:132-139`, `:369-377`). |

Evidence that TypeScript does not evaluate contention or extract plan tokens:

- `Grep` for `blast_radius|entriesOverlap|pathOverlap|function .*[Cc]onflict` under `extensions/drm-copilot/src` returns only validator shape checks (`parallel-state-shared.ts:235-271`, `parallel-planner-state-core.ts:360-364`) and `validateConflictEdges` (`parallel-state-structures.ts:416`), which validates recorded edge shape, not overlap.
- `Grep` for `conflict|overlap|shared_surfaces|separator` in `claude-blast-radius*.ts` returns only doc comments and the verbatim `shared_surfaces` copy (`claude-blast-radius-derive-core.ts:371`).

Decision: exclude TypeScript from corpus consumption. The existing TS config assertions already cover the carried surface list: `blast-radius-derive-core.test.ts:263-264` (`shared_surfaces` carried verbatim) and `claude-config-carriage.test.ts:110` (source constant in step with the committed bundled resource).

## 4. Bundled Config Versus Root Config

Not byte-identical, by design. Root `config/blast-radius.json` lists 10 `shared_surfaces` (`:3-14`), 3 `shared_surface_globs`, and 7 modules. Bundled `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` lists 6 `shared_surfaces` (`:3-10`), an empty `shared_surface_globs`, and `modules: {"config": ["config/**"]}`. `version`, `mandate_reads`, `mergeable_paths`, and `over_breadth_fraction` are byte-equal.

The separator-free subset is identical in both copies: `package-lock.json`, `poetry.lock`, `quality-tiers.yml` (see "Numeric Derivation Evidence").

Parity is held by tests, not a build step:

- Python: `tests/scripts/dev_tools/test_blast_radius_config_parity.py` — `test_class_one_keys_are_equal_across_both_committed_copies` (`:183`), `test_class_two_bundled_shared_surfaces_are_the_portable_set` (`:242`), `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle` (`:300`), `test_every_top_level_key_is_classified_and_shared_by_both_copies` (`:205`), `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` (`:146`). The portable set constant is `PORTABLE_SHARED_SURFACES` in `blast_radius_parity_test_support.py:64-81`.
- PowerShell mirror: `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` (`:71`, `:96`, `:130`).
- TypeScript: `claude-config-carriage.test.ts:110`.

## 5. Existing Tests and Fixtures

### Fixture corpus `tests/fixtures/blast_radius/`

37 top-level `.json` files (15 `conflict-*`, 14 `derivation-*`, 8 `validation-*`) plus one subfolder file `verification-integrity/verification-integrity-485-486-487.json`. Format: one JSON object per file with `description`, `input`, `expected`; a conflict fixture is identified by `input.radius_a`.

Parity drivers:

- Python `tests/scripts/dev_tools/test_blast_radius_parity.py`: `FIXTURE_DIR.glob("*.json")` (`:174`) is non-recursive; the on-disk cross-check uses `FIXTURE_DIR.iterdir()` (`:341-345`); floor `MINIMUM_FIXTURE_COUNT = 30` (`:60`).
- Pester `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`: `Get-ChildItem -Filter '*.json' -File` without `-Recurse` (`:39`); on-disk cross-check `:215-222`; floor `$minimumFixtureCount = 30` (`:61`).

Consequence: a file placed in a subfolder is not discovered by either driver and does not change either count assertion.

Existing Gap 1 and Gap 2 assertions:

| Gap | Fixture / test | What it covers |
|---|---|---|
| 1 | `derivation-root-surface-reached.json` | `poetry.lock` admitted in derivation (inline config) |
| 1 | `derivation-root-surface-not-configured.json` | `README.md` rejected |
| 1 | `test_blast_radius_extraction.py:239-246` (`CONFIGURED_ROOT_SURFACES`) | token matrix, three surfaces |
| 1 | `test_blast_radius_config.py:261-266` | separator-free subset of committed config |
| 1 | `test_blast_radius_validation.py:110-116` | V2 fires for `poetry.lock` |
| 1 | `test_blast_radius_invariants.py:121-124` | invariants plan cites `poetry.lock` |
| 1 | `test_blast_radius_config_parity.py:146-179` | `package-lock.json` pair contends under bundled table (Python only) |
| 1 | `BlastRadiusExtraction.Path.Tests.ps1:232-270` | token matrix, three surfaces |
| 1 | `BlastRadius.Tests.ps1:248-265` | root surface reached from plan text |
| 2 | `conflict-directory-vs-glob.json` | `scripts/dev_tools` vs `scripts/dev_tools/**`, one argument order only |
| 2 | `conflict-directory-vs-file.json` | directory vs file |
| 2 | `conflict-sibling-prefix-disjoint.json` | `scripts/dev_toolsX/a.py` vs `scripts/dev_tools` (concrete vs concrete) |
| 2 | `test_blast_radius_conflicts.py:288-371` | entry-level overlap, symmetry, disjoint and monotonicity matrices |
| 2 | `BlastRadiusGlob.Tests.ps1:311-320, 377+` | entry-level mirror |

Coverage gaps the v2 corpus closes: no relation-level reversed-order glob-vs-directory case; no sibling-prefix control of the glob-vs-directory shape; no `artifacts/` case; no deserialized empty-modules case under a config whose module map would otherwise match; no plan-to-verdict end-to-end case for `package-lock.json` or `quality-tiers.yml` under the self-hosted table; no PowerShell plan-to-verdict root-surface case at all.

### Test file line counts (500-line limit)

| File | Lines | Headroom |
|---|---|---|
| `tests/scripts/dev_tools/test_blast_radius_config.py` | 499 | 1 |
| `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | 499 | 1 |
| `tests/scripts/dev_tools/test_blast_radius_parity.py` | 469 | 31 |
| `tests/scripts/dev_tools/test_blast_radius_extraction.py` | 462 | 38 |
| `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` | 401 | 99 |
| `tests/scripts/dev_tools/test_blast_radius_conflicts.py` | 371 | 129 |
| `tests/scripts/dev_tools/test_blast_radius_normalization.py` | 365 | 135 |
| `tests/scripts/dev_tools/test_compute_blast_radius.py` | 361 | 139 |
| `tests/scripts/dev_tools/test_blast_radius_validation.py` | 354 | 146 |
| `tests/scripts/dev_tools/test_blast_radius_invariants.py` | 278 | 222 |
| `tests/scripts/dev_tools/test_blast_radius_verification_integrity.py` | 273 | 227 |
| `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | 257 | 243 |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` | 225 | 275 |
| `tests/scripts/dev_tools/test_blast_radius_mandate_reads.py` | 224 | 276 |
| `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` | 146 | 354 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` | 500 | 0 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` | 490 | 10 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` | 489 | 11 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` | 460 | 40 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1` | 453 | 47 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1` | 444 | 56 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` | 419 | 81 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | 409 | 91 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | 391 | 109 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` | 271 | 229 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1` | 267 | 233 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1` | 212 | 288 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` | 197 | 303 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` | 76 | 424 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | 486 | 14 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | 472 | 28 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts` | 183 | 317 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts` | 149 | 351 |

Several existing files are at or near the limit, and #722 is likely to edit the conflicts and extraction test files. New dedicated test files are recommended rather than extending existing ones.

Production line counts, for reference: `_blast_radius_extraction.py` 475, `_blast_radius_validation.py` 464, `compute_blast_radius.py` 421, `_blast_radius_glob.py` 316, `_blast_radius_conflicts.py` 257; `BlastRadiusExtraction.psm1` 474, `BlastRadiusConfig.psm1` 473, `BlastRadius.psm1` 438, `BlastRadiusGlob.psm1` 431. No production change is proposed.

## 6. Tolerance Layer and Scheduling Edge Functions

- `Grep` for `conflict_tolerance|integration_cost|integrationCost|conflictTolerance` over the whole worktree: no files.
- `Grep` for `tolerance` (case-insensitive) in code and JSON files: matches only unrelated parse-tolerance comments (for example `_parallel_state_structures.py:72`, `claude-blast-radius-derive.ts:27`). None is a scheduling layer.

Scheduling functions that consume pairwise conflicts:

| Runtime | Function | Location | Signature |
|---|---|---|---|
| Python | `compute_cohorts` | `scripts/dev_tools/parallel_cohort_computation.py:350` | `compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]) -> list[list[int]]` (Welsh-Powell greedy coloring) |
| Python | `recompute_conflicts_with_observed` | `scripts/dev_tools/parallel_drift_detection.py:271` | calls `conflicts(observed_radius, peer, config).conflict` at `:499` |
| Python | admission / recolor | `scripts/dev_tools/parallel_mutation_protocol.py:130-170, 312` | consumes caller-supplied edges; "this function never calls it" (`:150-151`) |
| bash | `pcoh_compute_cohorts` | `.claude/lib/bash/parallel-cohorts.sh:259` | `$1` = space-separated keys, `$2` = space-separated `a:b` edges; entry point `.claude/lib/bash/compute-cohorts.sh` |
| PowerShell | none | `BlastRadius.Parity.Tests.ps1:403-404` states the port has no cohort computation | n/a |

No library function maps pairwise `conflicts` results to edges. That mapping is performed by the planner and orchestrator agents per skill prose (`.claude/skills/parallel-plan/SKILL.md:195-228, 285`; `.claude/agents/parallel-planner.md:160-175`). The #452 corpus should therefore assert at the `conflicts` / `Test-BlastRadiusConflict` level and must not call `compute_cohorts`.

## 7. Proposed Corpus Path, Schema, and Loading

### Path

`tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`

`Glob tests/fixtures/blast_radius/**` shows only one existing subfolder (`verification-integrity/`); `regression-452/` does not exist. The issue-numbered subfolder name makes a collision with #722 unlikely, and the subfolder is outside both parity drivers' non-recursive discovery, so neither `MINIMUM_FIXTURE_COUNT` nor the on-disk count assertion changes.

### Schema

```json
{
  "schema_version": 1,
  "issue": 452,
  "description": "Shared regression corpus for issue #452 under-reporting gaps.",
  "cases": [
    {
      "id": "g2-dir-vs-glob",
      "gap": "gap2",
      "kind": "radius_pair",
      "direction": "must_conflict",
      "control_id": "g2-dir-vs-sibling-glob",
      "config_ref": null,
      "config": { "version": 1 },
      "input": {
        "radius_a": { "paths": ["scripts/dev_tools"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15" },
        "radius_b": { "paths": ["scripts/dev_tools/**"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-27T12-15" }
      },
      "expected": {
        "conflict": true,
        "reasons": [ { "kind": "path_overlap", "detail": "scripts/dev_tools ~ scripts/dev_tools/**" } ]
      }
    }
  ]
}
```

Field rules:

- `kind`: `token_classification`, `radius_pair`, or `plan_pair`.
- `direction`: `must_conflict` or `must_not_conflict` for pair kinds; `must_admit` or `must_reject` for `token_classification`.
- `control_id`: on every positive case, the id of its matched negative control; every negative control names its positive in `control_id` as well, so the pairing is checkable in both directions.
- Exactly one of `config` (inline mapping) or `config_ref` (`"self_hosted"` or `"bundled"`) is set. A `token_classification` case may use `config_refs` (list) to run against both committed tables.
- `input` by kind: `{ "token": "<t>" }`; `{ "radius_a": {...}, "radius_b": {...} }` in the exact six-key `BlastRadius.from_dict` shape; `{ "plan_a", "plan_b", "feature_folder_a", "feature_folder_b", "computed_at" }` with `spec_text` empty.
- `expected` by kind: `{ "token_kind": "concrete" | null }`; `{ "conflict": <bool>, "reasons": [ { "kind", "detail" } ] }` with reasons in `CONFLICT_KINDS` order.
- `doctrine_pin: true` marks a case that pins designed non-conflict behaviour (the `quality-tiers.yml` mandate-read case) so reviewers do not read it as an under-report.
- `computed_at` uses the non-ISO `YYYY-MM-DDTHH-MM` shape the existing fixtures use, so `ConvertFrom-Json -AsHashtable` does not materialize a `[datetime]` (the issue #489 fixture needed `-DateKind String` for real ISO instants; `BlastRadius.Parity.Tests.ps1:314-318`).

### Loading

- Python: `REPO_ROOT = Path(__file__).resolve().parents[3]` (the pattern at `test_blast_radius_parity.py:49`), then `REPO_ROOT / "tests" / "fixtures" / "blast_radius" / "regression-452" / "under-reporting-corpus.json"`. `config_ref` resolves to `REPO_ROOT / "config" / "blast-radius.json"` or the bundled path already defined as `BUNDLED_CONFIG_PATH` in `tests/scripts/dev_tools/test_blast_radius_config.py:36`.
- PowerShell: `$repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path` (pattern at `BlastRadius.Parity.Tests.ps1:68`), then `Join-Path $repoRoot 'tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json'`, parsed with `ConvertFrom-Json -AsHashtable`. The case list must be built at discovery time (outside `BeforeAll`) for `-ForEach`, as `BlastRadius.Parity.Tests.ps1:37-51` does.
- Neither loader depends on the current working directory, `origin/main`, gitignored `artifacts/`, or a Windows-only path.

## 8. Corpus Cases

Verdicts below were derived by tracing the cited Python and PowerShell lines; runtime confirmation is deferred to Phase 0.

### Gap 1 — token classification (`config_refs: ["self_hosted", "bundled"]`)

| id | direction | token | expected `token_kind` | control_id | Trace |
|---|---|---|---|---|---|
| g1-token-poetry-lock | must_admit | `poetry.lock` | `concrete` | g1-token-poetry-lock-case-variant | exact member, `_blast_radius_extraction.py:281` |
| g1-token-package-lock | must_admit | `package-lock.json` | `concrete` | g1-token-pyproject | exact member |
| g1-token-quality-tiers | must_admit | `quality-tiers.yml` | `concrete` | g1-token-quality-tiers-yaml | exact member |
| g1-token-poetry-lock-case-variant | must_reject | `Poetry.lock` | `null` | g1-token-poetry-lock | ordinal comparison fails; separator guard `:304` |
| g1-token-pyproject | must_reject | `pyproject.toml` | `null` | g1-token-package-lock | not configured; separator guard |
| g1-token-quality-tiers-yaml | must_reject | `quality-tiers.yaml` | `null` | g1-token-quality-tiers | not configured; separator guard |

None of these tokens carries a placeholder marker (`<`, `>`, `${`, `$(`, `%`), so the marker guard at `:297` does not intervene.

### Gap 1 — plan to verdict (`config_ref: "self_hosted"`)

Feature folders `2026-09-27-regression-452-left` and `2026-09-27-regression-452-right`; their `docs/features/active/<folder>/**` globs have diverging literal prefixes and never overlap.

| id | direction | plan_a citation | plan_b citation | expected reasons | control_id |
|---|---|---|---|---|---|
| g1-plan-poetry-lock | must_conflict | `` `poetry.lock` `` | `` `poetry.lock` `` | `path_overlap: poetry.lock ~ poetry.lock`; `shared_surface_overlap: poetry.lock` | g1-plan-different-surfaces |
| g1-plan-package-lock | must_conflict | `` `package-lock.json` `` | `` `package-lock.json` `` | `path_overlap: package-lock.json ~ package-lock.json`; `shared_surface_overlap: package-lock.json` | g1-plan-unconfigured-root-file |
| g1-plan-different-surfaces | must_not_conflict | `` `poetry.lock` `` | `` `package-lock.json` `` | none | g1-plan-poetry-lock |
| g1-plan-unconfigured-root-file | must_not_conflict | `` `pyproject.toml` `` | `` `pyproject.toml` `` | none | g1-plan-package-lock |
| g1-plan-quality-tiers-mandate-read (`doctrine_pin`) | must_not_conflict | `` `quality-tiers.yml` `` | `` `quality-tiers.yml` `` | none | g1-radius-quality-tiers |

Trace for `g1-plan-poetry-lock`: extraction admits `poetry.lock`; no `mandate_reads` entry matches it (exact list and glob containment, `_blast_radius_normalization.py:71-80`); `paths = [docs glob, "poetry.lock"]`; no module glob in the self-hosted map matches; `resolve_shared_surfaces` returns `["poetry.lock"]`; `conflicts` finds the equal concrete pair and the common surface. Trace for the `doctrine_pin` case: `quality-tiers.yml` is admitted at `:281` and then removed by `exclude_mandate_reads` (`compute_blast_radius.py:280`) because it is an exact `mandate_reads` entry (`config/blast-radius.json:26`), leaving only the two diverging docs globs.

Plan line shape: `- [ ] [P1-T1] Regenerate \`poetry.lock\`.` matches `PLAN_TASK_RE` (`_blast_radius_extraction.py:61-63`).

### Gap 1 — declared radius (inline `config: {"version": 1}`)

| id | direction | radius_a | radius_b | expected reasons | control_id |
|---|---|---|---|---|---|
| g1-radius-quality-tiers | must_conflict | paths and shared_surfaces `["quality-tiers.yml"]` | same | `path_overlap: quality-tiers.yml ~ quality-tiers.yml`; `shared_surface_overlap: quality-tiers.yml` | g1-radius-quality-tiers-vs-poetry-lock |
| g1-radius-quality-tiers-vs-poetry-lock | must_not_conflict | paths and shared_surfaces `["quality-tiers.yml"]` | paths and shared_surfaces `["poetry.lock"]` | none | g1-radius-quality-tiers |

This expresses the genuine-write path the doctrine requires: the planner appends `quality-tiers.yml` to the declared radius after normalization, and `conflicts` does not apply `mandate_reads`.

### Gap 2 — radius pairs (all `modules`, `shared_surfaces`, `contracts` empty)

Inline `config: {"version": 1}` unless stated.

| id | direction | radius_a paths | radius_b paths | expected reasons | control_id |
|---|---|---|---|---|---|
| g2-dir-vs-glob | must_conflict | `scripts/dev_tools` | `scripts/dev_tools/**` | `path_overlap: scripts/dev_tools ~ scripts/dev_tools/**` | g2-dir-vs-sibling-glob |
| g2-glob-vs-dir | must_conflict | `scripts/dev_tools/**` | `scripts/dev_tools` | `path_overlap: scripts/dev_tools ~ scripts/dev_tools/**` | g2-sibling-glob-vs-dir |
| g2-dir-vs-sibling-glob | must_not_conflict | `scripts/dev_tools` | `scripts/dev_tools_extra/**` | none | g2-dir-vs-glob |
| g2-sibling-glob-vs-dir | must_not_conflict | `scripts/dev_tools_extra/**` | `scripts/dev_tools` | none | g2-glob-vs-dir |
| g2-artifacts-dir-vs-glob | must_conflict | `artifacts/orchestration` | `artifacts/orchestration/**` | `path_overlap: artifacts/orchestration ~ artifacts/orchestration/**` | g2-artifacts-dir-vs-sibling-glob |
| g2-artifacts-glob-vs-dir | must_conflict | `artifacts/orchestration/**` | `artifacts/orchestration` | `path_overlap: artifacts/orchestration ~ artifacts/orchestration/**` | g2-artifacts-sibling-glob-vs-dir |
| g2-artifacts-dir-vs-sibling-glob | must_not_conflict | `artifacts/orchestration` | `artifacts/orchestration-archive/**` | none | g2-artifacts-dir-vs-glob |
| g2-artifacts-sibling-glob-vs-dir | must_not_conflict | `artifacts/orchestration-archive/**` | `artifacts/orchestration` | none | g2-artifacts-glob-vs-dir |
| g2-empty-modules-dir-vs-glob | must_conflict | `scripts/powershell/PoshQC` | `scripts/powershell/PoshQC/**` | `path_overlap: scripts/powershell/PoshQC ~ scripts/powershell/PoshQC/**` (and no `module_overlap`) | g2-empty-modules-dir-vs-sibling-glob |
| g2-empty-modules-dir-vs-sibling-glob | must_not_conflict | `scripts/powershell/PoshQC` | `scripts/powershell/PoshQCExtra/**` | none | g2-empty-modules-dir-vs-glob |

The two `g2-empty-modules-*` cases use inline `config: {"version": 1, "modules": {"poshqc": ["scripts/powershell/**"]}}`, so a module map that would match both radii is present but unused: `conflicts` reads modules only from the deserialized radii (`_blast_radius_conflicts.py:198-201`).

Traces: in every must-conflict row `matches_glob` is false (the directory entry lacks the trailing separator the `/**` regex requires) and `_prefixes_nest` is true because the glob's literal prefix equals the directory's anchored prefix. In every control row the literal prefix and the anchored directory prefix diverge at the character after the shared stem (`_` vs `/`, `-` vs `/`, `E` vs `/`), so neither `startswith` holds. Details are ordinally ordered: a string sorts before any extension of itself, so the directory entry precedes its `/**` glob. The `artifacts/` entries are not filtered by `conflicts`, which applies only `mergeable_paths`; none of the five mergeable patterns matches these entries (`_blast_radius_mergeable.py:82-134`).

Totals: 6 token cases, 5 plan-pair cases, 2 declared-radius Gap 1 cases, 10 Gap 2 cases; 23 cases, 11 positive and 12 negative (the doctrine pin counted as negative).

## 9. CI Coverage

| Suite | Workflow / job | Runner | Discovers new file by |
|---|---|---|---|
| pytest | `.github/workflows/_quality-checks.yml` job `quality-checks7`, step "Run tests with Pytest" (`:74-80`) | `ubuntu-latest`, Python 3.10-3.13 | `testpaths = ["tests"]` (`pyproject.toml:116`) |
| Pester | `.github/workflows/_poshqc.yml` job `poshqc`, step "Test PowerShell" (`:38-42`) | `windows-latest` only | runsettings `Path = @('scripts', 'tests/powershell', 'tests/scripts')` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:3`) |
| jest (extension) | `.github/workflows/_drm-copilot-extension-tests.yml` | `windows-latest`, `ubuntu-latest` | not affected; TypeScript excluded |
| bats | `.github/workflows/_shell-coverage.yml` | `ubuntu-latest` | no bats test evaluates contention; `tests/shell/parallel_*.bats` mention blast radius only for manifest shape and library membership |

All jobs are called from `.github/workflows/ci.yml` on push and pull request to `main` and `development`.

State dependencies: no blast-radius test reads `origin/main`, runs `git`, or starts a subprocess (`Grep` for `origin/main|subprocess|git ` over the blast-radius test files returns only string literals naming `artifacts/` paths). `test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates the working-tree `.claude/` with `rglob` (`test_push_down_claude_resource_contracts.py:51-60, 118-143`), so untracked local files under `.claude/` can fail it locally while CI stays green. The v2 change does not touch `.claude/`, so this is background only.

## Numeric Derivation Evidence

### Claim N1: the self-hosted `config/blast-radius.json` declares exactly 3 separator-free `shared_surfaces` entries

- Complete Family: every entry of the `shared_surfaces` array in `config/blast-radius.json`.
- Exhaustive Search Scope: the whole file `config/blast-radius.json`, all 50 lines, with the `shared_surfaces` array bounded at lines 3-14.
- Inclusion Rules: a string element of `shared_surfaces` containing no `/`.
- Exclusion Rules: elements containing `/`; strings in any other key (`shared_surface_globs`, `mandate_reads`, `mergeable_paths`, `modules`).
- Primary Search Strategy or Query Expression: full `Read` of the file and manual filtering of lines 4-13 by the absence of `/`.
- Primary Member Set: `poetry.lock` (line 7), `package-lock.json` (line 8), `quality-tiers.yml` (line 11).
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: `Grep` pattern `^\s+"[^"/]+",?$` over the whole file with line numbers, then restriction to hits inside lines 3-14.
- Cross-check Member Set: raw hits at lines 7, 8, 11, 26; line 26 (`quality-tiers.yml`) is in `mandate_reads` (lines 20-32) and is excluded; remaining `poetry.lock`, `package-lock.json`, `quality-tiers.yml`.
- Cross-check Count: 3.
- Member-set Comparison: normalized sets `{package-lock.json, poetry.lock, quality-tiers.yml}` are identical. A third independent source agrees: `CONFIGURED_ROOT_SURFACES` in `tests/scripts/dev_tools/test_blast_radius_extraction.py:242-246`.

### Claim N2: the bundled config declares exactly 3 separator-free `shared_surfaces` entries, the same set as N1

- Complete Family: every entry of `shared_surfaces` in `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`.
- Exhaustive Search Scope: the whole file, 36 lines, with `shared_surfaces` bounded at lines 3-10.
- Inclusion Rules: as N1.
- Exclusion Rules: as N1.
- Primary Search Strategy or Query Expression: full `Read` and manual filtering of lines 4-9.
- Primary Member Set: `package-lock.json` (7), `poetry.lock` (8), `quality-tiers.yml` (9).
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: `Grep` pattern `^\s+"[^"/]+",?$` with line numbers, restricted to lines 3-10.
- Cross-check Member Set: raw hits at lines 7, 8, 9, 18; line 18 is in `mandate_reads` (lines 12-24) and is excluded.
- Cross-check Count: 3.
- Member-set Comparison: identical to each other and to N1's set. A third source agrees: `PORTABLE_SHARED_SURFACES` separator-free members in `blast_radius_parity_test_support.py:72-79`.

### Claim N3: 23 corpus cases

This count is authored by this research, not derived from repository state, so no exhaustive search applies. If a `spec.md` acceptance criterion states it, the plan should assert it against the committed corpus with two independent reads (a JSON parse count of `cases` and a `Grep` count of `"id":` lines within the corpus file).

## Proposed Phase 0 Runtime Confirmation

Write this to the session scratchpad as a `.py` file and run it with `poetry run python <file>`; a multi-line `poetry run python -c` is a silent no-op in this repository.

```python
from scripts.dev_tools._blast_radius_extraction import classify_path_token
from scripts.dev_tools._blast_radius_glob import _entries_overlap
from scripts.dev_tools._blast_radius_validation import config_root_surfaces
import json, pathlib
cfg = json.loads(pathlib.Path("config/blast-radius.json").read_text(encoding="utf-8"))
roots = config_root_surfaces(cfg)
print("roots", roots)
for token in ("poetry.lock", "package-lock.json", "quality-tiers.yml", "Poetry.lock", "pyproject.toml"):
    print(token, classify_path_token(token, root_surfaces=roots))
for a, b in (("scripts/dev_tools", "scripts/dev_tools/**"), ("scripts/dev_tools/**", "scripts/dev_tools"),
             ("scripts/dev_tools", "scripts/dev_tools_extra/**"), ("artifacts/orchestration", "artifacts/orchestration/**"),
             ("artifacts/orchestration", "artifacts/orchestration-archive/**")):
    print(a, "|", b, _entries_overlap(a, b))
```

Expected output by code reading: `roots ('package-lock.json', 'poetry.lock', 'quality-tiers.yml')`; the first three tokens `concrete`, the last two `None`; overlaps `True`, `True`, `False`, `True`, `False`. The PowerShell equivalent imports `BlastRadiusExtraction.psm1`, `BlastRadiusConfig.psm1`, and `BlastRadiusGlob.psm1` and calls `Get-PathTokenKind` and `Test-EntryOverlap`; if the worktree guard refuses `pwsh`, run the Pester consumer through the PoshQC MCP test tool instead.

## Candidate Approaches

### Selected: one shared JSON corpus in an issue-numbered subfolder, consumed by two new dedicated test files

Add `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json`, `tests/scripts/dev_tools/test_blast_radius_regression_452.py`, and `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`. Each consumer iterates every case, dispatches on `kind`, and asserts verdict and exact reasons, plus corpus meta-assertions: non-empty per kind, every positive has a resolvable negative `control_id` and vice versa, both directions present for both gaps, and case ids unique.

Advantages: one artifact pins both runtimes; no edit to the existing parity drivers, their floors, or files near the 500-line limit; no production change; low overlap with #722's likely edits to `_blast_radius_conflicts.py`, `_blast_radius_extraction.py`, and their tests. Limitations: the `plan_pair` kind depends on extraction, which #722 may change (see below).

### Rejected alternatives

- Add one fixture file per case to the top-level `tests/fixtures/blast_radius/` so the existing parity drivers pick them up: the existing conflict-fixture shape has no direction, control pairing, or token kind; top-level additions share a directory #722 may also add to; and the plan-pair and token cases do not fit either existing fixture kind.
- Extend `test_blast_radius_conflicts.py` and `BlastRadius.Conflict.Tests.ps1` with parametrized cases: `BlastRadius.Conflict.Tests.ps1` is at 490 lines, and both files are probable #722 edit targets.

## Merge-Order Conditional With #722

- `token_classification` and `radius_pair` cases depend only on `classify_path_token` / `Get-PathTokenKind` and `conflicts` / `Test-BlastRadiusConflict`. They remain valid if #722 adds a tolerance layer, because that layer schedules on top of the relation rather than changing it.
- `plan_pair` cases depend on `derive_blast_radius` / `Get-BlastRadius`. If #722 merges first and its write-intent-only extraction changes whether `Regenerate \`poetry.lock\`.` is harvested, re-verify those five cases against merged `main` before asserting them. Using an explicit write verb in every plan line reduces that risk.
- If #722 changes the signature of `conflicts` or `Test-BlastRadiusConflict`, update only the corpus consumers' call site. Do not assert any cohort or tolerance outcome; `compute_cohorts` is out of scope.

## Automation Feasibility

No step requires human interaction. Creating the corpus, the two test files, running the Python and PowerShell toolchains (via `poetry run` and the PoshQC MCP tools), and authoring a PR whose body contains `Closes #452` are all automatable. The only constraint observed is environmental: this research session had no shell tool, so the runtime confirmation above must run in the implementation session.

## Recommendations

1. Runtimes needing a correction: none. Python, the root PowerShell port, and the bundled PowerShell copy implement both gaps; TypeScript and bash do not evaluate contention.
2. TypeScript: exclude from corpus consumption. Do not add a TS config-parity test; existing coverage (`blast-radius-derive-core.test.ts:263-264`, `claude-config-carriage.test.ts:110`) plus the Python and Pester config-parity suites already pin the carried surface list.
3. Corpus path: `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` (confirmed absent), with the schema in section 7.
4. Consumers: new `tests/scripts/dev_tools/test_blast_radius_regression_452.py` and new `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`, each well under 500 lines, loading the corpus via `__file__` / `$PSScriptRoot` repo-root resolution.
5. Case list: the 23 cases in section 8, including the `quality-tiers.yml` doctrine pin and its declared-radius counterpart.
6. Phase 0: run the runtime confirmation script and the PowerShell equivalent, and record outputs under the feature's `evidence/` tree before authoring tests.
7. Assert detection only: verdict and ordered reasons from `conflicts` / `Test-BlastRadiusConflict`, and `token_kind` from the classifiers; never cohorts or tolerance.
8. The PR body must include `Closes #452`.
