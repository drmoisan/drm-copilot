# 2026-08-17-blast-radius-false-conflict-edges (Spec)

- **Issue:** #489
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-17
- **Status:** Ready
- **Version:** 1.0
- **Work Mode:** full-bug (this spec is the sole acceptance-criteria source)

## Context

Blast-radius computation admits paths into an item's radius that are not sources of genuine write-write or write-read contention, producing false conflict edges that serialize parallel runs which should execute concurrently. This is the third observed instance of the class (prior instances: issue #472, and a case recorded in operator memory).

Environment:

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `compute_blast_radius` / `.claude/lib/blast-radius/*.psm1` / `claude-blast-radius-derive*.ts`, consumed by the parallel planner when seeding generation-0 cohorts
- Data source or fixture: `artifacts/orchestration/parallel-orchestrator-state.json` for the `verification-integrity` parallel run (issues 485, 486, 487)

Impact / Severity: **High.** Parallel runs that should execute concurrently are serialized. The defect scales with item count: any shared policy-read path forms a complete conflict graph over the entire item set on its own, so a large lane-parallel organization degrades toward fully serial execution.

### Premise correction (material)

The original bug brief named three false-contention sources, all at the `paths` level, and implied the recorded `reason: path_overlap` identified the operative disjunct. Both premises were corrected by executing the real conflict relation over the recorded radii (evidence: `docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/other/orchestrator-fix-feasibility-demonstration.2026-08-17T21-20.md`, which supersedes the research artifact wherever the research marks a claim as not verifiable in-session):

- `conflicts()` (`scripts/dev_tools/_blast_radius_conflicts.py`) is a four-way disjunction. Over the recorded radii with the current committed config, `path_overlap` fires on all three pairs (from `.claude/rules/` policy-read citations), `module_overlap` fires on all three pairs, `shared_surface_overlap` fires on all three pairs (via `quality-tiers.yml`), and `contract_dependency` fires on 485-486 (via the punctuation token `->`).
- The recorded `reason: path_overlap` is only `reasons[0]` in `CONFLICT_KINDS` order; the other disjuncts were not silent.
- `module_overlap` on `python-dev-tools` and `vscode-extension` is reached from **genuine, disjoint writes**: 485 writes `scripts/dev_tools/pr_context/*`, 486 writes `scripts/dev_tools/plan_gate_*`, 487 writes `scripts/dev_tools/new_active_feature_folder_*`, and all three write under `extensions/drm-copilot/src/`. Therefore a fix confined to path-level extraction is **necessary but not sufficient** — the K3 triangle would survive at the module level.
- A **fourth** path-level false-contention source, not in the original brief, exists: cross-corpus document globs. 486's `docs/features/**/plan*.md` overlaps every other item's own feature-folder glob under glob×glob literal-prefix nesting.

Two further premise corrections the design depends on:

- **The bundled config is not a byte-identical mirror.** Since #472, `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` is a two-module base document consumed by the TypeScript push-down derivation. This spec does not specify or enforce byte-identity for this pair.
- **`CARRIED_KEYS` carriage gap.** The TypeScript derive core emits a fixed key set (`extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts:146-149, 432-436`). A new config key not added to `CARRIED_KEYS` and the assembly is silently dropped from every pushed-down destination config. Extending both, plus a Jest assertion that the key survives derivation, is mandatory.

## Problem Statement

The parallel planner derives conflict edges from blast radii whose `paths`, `modules`, `shared_surfaces`, and `contracts` sets contain entries produced by mandate-driven reads, directory-shaped prose tokens, evidence-output directories, cross-corpus document globs, umbrella module buckets, and punctuation contract tokens. None of these represents genuine write-write or write-read contention. For the `verification-integrity` run (issues 485, 486, 487), the true conflict graph is a single edge (486-487, on `extensions/drm-copilot/src/mcp-tools.ts`), which colors to two cohorts; the derived graph is a complete K3, which colors to three single-item cohorts and fully serial execution.

## Repro & Evidence

Steps to Reproduce:

1. Prepare the three `verification-integrity` items (issues 485, 486, 487) through the parallel planner so each records a `blast_radius`.
2. Read the recorded `blast_radius` blocks for each item from `artifacts/orchestration/parallel-orchestrator-state.json`.
3. Run `conflicts(a, b, config)` pairwise over the recorded radii with the committed `config/blast-radius.json`, then `compute_cohorts` over the derived edges.

Expected: edges `[(486, 487)]`; cohorts `[[485, 486], [487]]`.

Actual (reproduced by execution, exit code 0; see the feasibility-demonstration evidence artifact):

- BEFORE: edges `[(485, 486), (485, 487), (486, 487)]`, cohorts `[[485], [486], [487]]`.
- Every pair fires `path_overlap`, `module_overlap`, and `shared_surface_overlap`; 485-486 additionally fires `contract_dependency` on the token `->`.
- Measured exact path intersections contain zero concrete source files for 485∩486 and 485∩487; 486∩487 contains the one genuine conflict, `extensions/drm-copilot/src/mcp-tools.ts`.

The demonstration also executed the simulated fix over the same recorded radii:

- AFTER: edges `[(486, 487)]`, cohorts `[[485, 486], [487]]`. The surviving edge is the genuine conflict on `extensions/drm-copilot/src/mcp-tools.ts`.

Because `artifacts/` is gitignored, the recorded radii are invisible to CI and to a fresh checkout. This spec therefore requires the before/after demonstration to be made reproducible via a committed fixture and regression test (see Test Strategy).

## Root Cause Analysis

Six false-contention sources, the level each poisons, and the fix site for each:

| # | Source | Level poisoned | Fix site |
| --- | --- | --- | --- |
| 1 | Phase-0 policy-read paths (`.claude/rules/*.md`, `quality-tiers.yml`, mandate-read SKILLs) | paths; shared_surfaces via `quality-tiers.yml`; modules via `.claude/**` | extraction + config (mandate-read exclusion) |
| 2 | Bare directory tokens (`extensions/drm-copilot`, `scripts/dev_tools`, `docs/features`, `.claude/rules/`) | paths, modules | extraction (directory-shaped token rejection) |
| 3 | Evidence-output directories (`artifacts/`, `artifacts/*`) | paths | extraction + config (`KNOWN_TOP_LEVEL_SEGMENTS` removal plus `artifacts/**` exclusion) |
| 4 | Cross-corpus document globs (486's `docs/features/**/plan*.md`) | paths | extraction (cross-corpus doc-glob rejection) |
| 5 | Umbrella module buckets resolved from genuine, disjoint writes | modules | **config content** (#472 Defect-A fix class) |
| 6 | Punctuation contract tokens (`->` shared by 485-486) | contracts | extraction (letterless contract-token rejection) |

The extraction entry points: `classify_path_token` admits any token starting with a `KNOWN_TOP_LEVEL_SEGMENTS` prefix with no extension requirement (`scripts/dev_tools/_blast_radius_extraction.py:69-74, 277-281`); `extract_contract_identifiers` admits every separator-free inline-code token inside interface sections, including pure punctuation. Source 5 cannot be fixed by extraction alone: after any path cleanup, all three items still resolve `python-dev-tools` and `vscode-extension` from real write targets, so `module_overlap` fires for every pair.

## Goals

1. The derived conflict graph for the `verification-integrity` radii reduces to exactly the single true edge (486, 487), and recoloring yields two cohorts with 485 and 486 in the same cohort — demonstrated by a committed fixture and executable regression test, not asserted.
2. All six false-contention sources are eliminated at the extraction side or by config content.
3. The fail-closed default is preserved: any path not explicitly enumerated in the exclusion list continues to count as contention, and a genuine write to an enumerated path is caught at execution time by drift detection.
4. The #452 / PR #453 comparison hardening is preserved byte-for-byte.
5. Python / PowerShell parity is maintained through the shared fixture corpus; the TypeScript push-down derivation carries the new config key.
6. Existing recorded radii and checkpoints continue to validate unchanged.

## Non-Goals

The following are settled by ratified owner decisions (recorded in `artifacts/orchestration/orchestrator-state.json` under `owner_decisions`) and are explicitly out of scope:

- **The conflict relation is unchanged.** `conflicts()` remains a config-blind-on-comparison four-way disjunction. No demotion, conditioning, or re-weighting of any disjunct.
- **No comparison-side change.** `scripts/dev_tools/_blast_radius_conflicts.py` and `scripts/dev_tools/_blast_radius_glob.py` are not modified. The #452 hardening (root-surface admission; directory- and glob-prefix honouring in `_entries_overlap`) is preserved intact.
- **No radius-shape change.** No field is added to the `blast_radius` dict. `BlastRadius.from_dict` rejects unexpected keys (`scripts/dev_tools/compute_blast_radius.py:200-202`); the change adds a config key only.
- **No read/write radius model.** The fix is an exclusion list, not an intent classifier. Read-versus-write inference from plan prose is rejected (unbounded silent under-reporting on misclassification).
- **No TypeScript port of extraction or conflict semantics.** TypeScript implements no extraction or conflict logic; its only blast-radius role is push-down config derivation.
- **`codex-runtime` is retained** in the module map this round. It is not required for the outcome, and widening the removal set beyond the demonstrated umbrella entries would be unratified scope.
- **`quality-tiers.yml` stays in `shared_surfaces`.** Removing it would reverse #452 Gap 1 for genuine writers (any two items that each add a project genuinely write that file).
- **No imported JSON Schema.** Doctrine is prose plus validator logic only. The disqualified foreign schema with the `drmoisan.github.io/mix-calculator/` `$id` is not copied or adapted.
- **No change to `_blast_radius_thresholds.py` or `parallel_cohort_computation.py`.**

## Design

### D1 — Fix site

The entire fix is extraction-side plus config content. Modified Python production files: `scripts/dev_tools/_blast_radius_extraction.py`, `scripts/dev_tools/_blast_radius_validation.py`, `scripts/dev_tools/compute_blast_radius.py`, and `config/blast-radius.json`. Unchanged: `_blast_radius_conflicts.py`, `_blast_radius_glob.py`, `_blast_radius_thresholds.py`, `parallel_cohort_computation.py`.

### D2 — New config key: `mandate_reads`

One new **optional** key on `config/blast-radius.json`, named `mandate_reads`: a list of exact paths and `**` globs whose harvested citations are excluded from derivation's path collection (and therefore from module and shared-surface resolution of derived radii).

- Absent key → excludes nothing → byte-identical current behavior, matching the absent-key convention of `config_string_list` (`scripts/dev_tools/_blast_radius_validation.py`).
- A new config reader is added in `_blast_radius_validation.py` beside `config_root_surfaces`.
- Ratified initial membership (empirically sufficient for the demonstrated outcome): `.claude/rules/**`, `quality-tiers.yml`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `artifacts/**`, `.github/instructions/**`.
- Fail-closed is preserved: exclusion requires explicit enumeration; any path not enumerated continues to count as contention; a genuine write to an enumerated path is caught at execution time by `detect_escaped_paths` (`scripts/dev_tools/parallel_drift_detection.py`), because observed radii are built verbatim from diff paths and diffs contain writes only.
- `quality-tiers.yml` remains declared in `shared_surfaces` (correct write-contention declaration) and is additionally listed in `mandate_reads` (the only read-by-mandate entry among the shared surfaces).

### D3 — Module-map content change

Remove five umbrella entries from `modules` in `config/blast-radius.json`: `python-dev-tools`, `vscode-extension`, `claude-runtime`, `copilot-surface`, `agents-surface`. Retain `mcp-server`, `benchmarks`, `poshqc`, `powershell-dev-tools`, `codex-runtime`, `config`, `schemas`, so the module level, the `module_overlap` enum member, and the non-empty-map test pins stay live. This is truth-table content, the same fix class as issue #472 Defect A, whose own spec names "the conflict relation unchanged" as an explicit non-goal.

### D4 — Extraction rules (six)

1. **Mandate-read exclusion** applied during the derivation harvest: a harvested citation matching a `mandate_reads` entry (exact path or `**` glob) is excluded from the derived radius's path collection.
2. **Directory-shaped token rejection**: reject a wildcard-free token whose final component carries no recognized extension. Subtree claims must be written as `**` globs (already admitted and already participating in the overlap rules). Entry point: `classify_path_token`'s `KNOWN_TOP_LEVEL_SEGMENTS` acceptance (`_blast_radius_extraction.py:69-74, 277-281`).
3. **`artifacts/` segment removal**: remove `artifacts/` from `KNOWN_TOP_LEVEL_SEGMENTS`; `artifacts/**` in `mandate_reads` additionally catches extension-bearing leaks such as `artifacts/pr_context.summary.txt`.
4. **Cross-corpus doc-glob rejection**: drop harvested glob tokens rooted under `docs/features/` that span multiple feature folders. Own-folder globs (carrying a complete feature-folder segment) are retained. Rationale: a corpus-wide doc glob is a read-scan by construction; an actual cross-folder write is caught by drift detection.
5. **Letterless contract-token rejection**: a contract identifier must contain at least one ASCII letter. This removes the `->` token forming the 485-486 `contract_dependency` edge. Entry point: `extract_contract_identifiers` (`_blast_radius_extraction.py`).
6. **Normalization entry point**: a pure function `normalize_declared_radius(radius, config) -> BlastRadius` on `compute_blast_radius.py`, applicable to already-recorded radii. It filters mandate-read entries, directory-shaped tokens, cross-corpus doc globs, and letterless contract tokens, then re-resolves modules and shared surfaces against the config. The planner calls it post-derivation; the regression test calls it on the committed fixture radii. It must never be applied to an `observed` radius: the function fails fast (raises a specific exception) when given a radius whose `source == "observed"`, so diff paths stay verbatim and drift detection keeps its force.

V1 self-consistency is automatic: derivation and validation rule V1 share `extract_plan_paths`, so a token dropped from the radius is identically dropped from the plan-side extraction.

### D5 — Change surface inventory

- **Python** (authoritative): `_blast_radius_extraction.py` (rules 2-5), `_blast_radius_validation.py` (new config reader beside `config_root_surfaces`), `compute_blast_radius.py` (derivation applies exclusions; the normalization entry point), `config/blast-radius.json` (new key; five module removals).
- **PowerShell** (destination-runtime mirror): `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, `BlastRadiusConfig.psm1`, `BlastRadius.psm1`, plus the published byte-copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`. `BlastRadiusGlob.psm1` and `BlastRadiusValidation.psm1` comparison logic unchanged.
- **TypeScript**: `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` — extend `CARRIED_KEYS`, the assembly object, and the emission-order documentation so `mandate_reads` survives push-down derivation — and its Jest tests; the bundled base document `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` gains the new key. No byte-identity between the root config and the bundled base document is specified or enforced.
- **Bash**: `.claude/lib/bash/compute-cohorts.sh` consumes keys and edges only — unchanged.
- **Prose**: see D6.

### D6 — Prose and doctrine

1. `.claude/skills/parallel-plan/SKILL.md:219-225` — the F1a load-bearing paragraph currently ends "do not narrow a radius in order to suppress a conflict edge they produce." It must be reworded so the prohibition reads "do not narrow a radius **beyond the configured exclusions**"; otherwise the fix's own behavior violates the skill's text. The amended text must preserve the literal `conflicts(a, b, config)` and must not introduce the literal `conflicts(a, b)` (pinned by `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py:59-71`).
2. Rule-file doctrine documenting (a) the mandate-read classification concept (read-by-mandate paths are excluded from derived contention; the drift-detection backstop makes the read/write distinction exact at execution time) and (b) the module-map granularity criterion (an umbrella bucket that essentially every item writes into is not a coherent unit of contention — extending the #472 rationale). Location: a section in `.claude/rules/parallel-orchestration.md` or a dedicated `.claude/rules/blast-radius.md`; the pushed-down rule mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/` is updated in the same commit.
3. Enforcement remains prose plus validator logic only — never an imported JSON Schema; the disqualified foreign schema with the `drmoisan.github.io/mix-calculator/` `$id` is not copied.

## Backward Compatibility

- **No radius-shape change.** `BlastRadius.from_dict` rejects unexpected radius keys; the fix adds a config key only, so every recorded radius dict loads unchanged.
- **Absent-key default.** A config without `mandate_reads` excludes nothing; behavior is byte-identical to current.
- **Recorded checkpoints keep validating.** `validate_blast_radius_block` (invariant 9 for parallel checkpoints and manifest M6) checks the six required fields only and is tolerant of content changes. An old (junk-bearing) recorded radius validated against its plan under the new extraction still passes V1 (the radius is a superset of the narrowed plan extraction) and V2.
- **No recomputation cross-check breaks.** No surface re-derives a radius from plan text and compares; the planner's recomputation-parity obligation re-runs `compute_cohorts` over recorded `item_keys` and `conflict_edges` only.
- **Observed radii untouched.** Normalization is never applied to `observed` radii; drift detection semantics are unchanged.
- **In-flight items.** A narrowed declared radius could newly classify a write as escaped in drift detection; no item is in flight in the `verification-integrity` run (all `merge_status: not_started`).

## Data / API / Config Impact

- New optional config key `mandate_reads` on `config/blast-radius.json` (list of exact paths and `**` globs; default absent = empty exclusion).
- Module map shrinks from twelve entries to seven.
- New public Python function `normalize_declared_radius(radius, config)` on `compute_blast_radius.py`; PowerShell mirror in the blast-radius modules.
- TypeScript `CARRIED_KEYS` grows by one; bundled base document gains the key.
- No API removals; no migration of recorded data.

## Test Strategy

### Committed fixture and regression test (the empirical demonstration, made reproducible)

Because `artifacts/` is gitignored, the recorded radii exist only in a working tree. The demonstration is made durable as follows:

- **Fixture**: commit `tests/fixtures/blast_radius/verification-integrity-485-486-487.json` (final name may vary within `tests/fixtures/blast_radius/`) holding the three recorded `blast_radius` blocks for items 485, 486, 487 **verbatim** (they match `RADIUS_KEYS` exactly, so `BlastRadius.from_dict` loads them), plus the pre-fix and post-fix config content.
- **Python regression test** (`tests/scripts/dev_tools/`, e.g. `test_blast_radius_verification_integrity.py`): (a) **before-state pin** — pairwise `conflicts()` on the raw fixture radii with the pre-fix config yields all three edges `[(485, 486), (485, 487), (486, 487)]` and `compute_cohorts` yields `[[485], [486], [487]]`; (b) **after-state assertion** — `normalize_declared_radius` over the fixture radii with the fixed committed config yields the edge set exactly `[(486, 487)]` and `compute_cohorts([485, 486, 487], [(486, 487)]) == [[485, 486], [487]]`.
- **PowerShell**: matching regression cases in `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (the committed-truth-table Describe block is the precedent for committed-artifact cases).
- **Evidence**: the regression-test evidence artifact recording the before/after edge sets and cohort partitions is written under `docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/regression-testing/`. `artifacts/`-rooted evidence paths are forbidden.

### Shared parity corpus

Parity between the Python and PowerShell runtimes is bound by the genuine shared corpus at `tests/fixtures/blast_radius/*.json`, asserted from both `tests/scripts/dev_tools/test_blast_radius_parity.py` and `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` against the fixture floor (`MINIMUM_FIXTURE_COUNT = 26`). Every new extraction rule must be covered by **adding** fixtures to that corpus — derivation fixtures exercising each rule in isolation, and conflict fixtures where applicable. Additions are floor-safe (floor plus on-disk-count equality; no exact count pin).

### Unit tests

- Per extraction rule: positive, negative, and boundary cases — trailing-slash directories, line-suffixed citations (`.claude/rules/python.md:90` remains admitted and inert), own-folder versus cross-corpus `docs/features/` globs, `**`-glob subtree claims (retained), letterless versus letter-bearing contract tokens.
- Config reader: present key, absent key (byte-identical behavior), malformed entries (fail fast).
- `normalize_declared_radius`: purity (no input mutation), idempotence on an already-clean radius, fail-fast rejection of `source == "observed"` radii.
- TypeScript: Jest assertion that `mandate_reads` survives push-down derivation into every destination config.

### Test pins that must move in the same commit

- `tests/scripts/dev_tools/test_blast_radius_config.py:407-422` — `test_items_sharing_a_dev_tools_file_contend_on_path_and_module` asserts `python-dev-tools` resolves and `module_overlap` fires (#472's AC4 assertion). Rewrite against a retained module or drop the `module_overlap` clause; the path-level contention assertion must be preserved.
- `tests/scripts/dev_tools/test_blast_radius_config.py:180-191` (non-empty module map — satisfied by the retained entries) and `:444-463` (pins the `config` module — retained) must remain passing.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:302-436` — committed-truth-table and location-bucket blocks, plus any behavior-matrix case naming a removed module.
- **Preserved, not broken**: `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py:59-71` pins that the parallel-plan skill contains the literal `conflicts(a, b, config)` and does NOT contain the literal `conflicts(a, b)`.

### Constraints

- Do not weaken any test to make it pass.
- No temporary files in tests; committed fixtures only.
- Coverage per `.claude/rules/quality-tiers.md`: line >= 85% and branch >= 75% for Python and TypeScript; PowerShell is exempt from the branch threshold only.
- Full toolchain loop per language (format → lint → type-check → test), repeated until a single clean pass.

## Risks & Mitigations

| Risk | Assessment | Mitigation |
| --- | --- | --- |
| **Accepted residual false negative 1**: a genuine write to a `mandate_reads` entry is invisible at scheduling time. | Bounded to a small, reviewed, committed enumeration of policy files written rarely. | The planner remains permitted (and obliged, per the amended prose) to append an excluded path to a declared radius explicitly; `detect_escaped_paths` catches the actual write at execution time and raises a drift event (observed radii are built verbatim from diff paths). |
| **Accepted residual false negative 2**: a genuine cross-feature-folder write is invisible at scheduling time after doc-glob rejection. | Cross-folder writes are rare and policy-suspect by construction. | Same drift-detection backstop; a drift event blocks (`raised_blocking_finding` / `halted_later_started_item`). |
| Module removals reduce module-level signal for `scripts/dev_tools/**` and `extensions/drm-copilot/**` co-writers. | Post-#452 path comparison already adjudicates the same paths at file/subtree granularity; the umbrella entries provided no signal the path level does not. | Retained leaf-granularity modules keep the module level live; two items in the same retained module still serialize (deliberate remaining scope of the module level). |
| `mandate_reads` silently dropped from pushed-down destination configs. | Known `CARRIED_KEYS` carriage gap. | Extend `CARRIED_KEYS` and the assembly; Jest assertion that the key survives derivation. |
| Normalization applied to an observed radius would erase drift-detection force. | Design-level prohibition. | `normalize_declared_radius` fails fast on `source == "observed"`; unit test pins the rejection. |
| Reintroducing the #452 defect. | Comparison files untouched. | `_blast_radius_conflicts.py` and `_blast_radius_glob.py` are byte-identical; the root-surface admission chain is preserved; the regression suite for #452 fixtures stays green. |

## Rollout & Follow-up

- Single-branch delivery; all config, code, test-pin, and prose changes land in the same commit series on the feature branch for #489.
- No feature flag: the absent-key default makes the config key itself the switch; committing the ratified membership activates the behavior.
- Follow-up candidates (out of scope): removal of `codex-runtime` from the module map; trimming line-suffixed citations (optional hygiene).
- Links: issue #489; research at `docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/research/2026-08-17T23-55-blast-radius-false-conflict-edges-research.md`; executed demonstration at `docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/other/orchestrator-fix-feasibility-demonstration.2026-08-17T21-20.md`; precedents #452 (PR #453) and #472.

## Acceptance Criteria

### Group A — Config content (`config/blast-radius.json`)

- [x] AC-A1: `config/blast-radius.json` carries a new optional `mandate_reads` key whose value is exactly the ratified membership: `.claude/rules/**`, `quality-tiers.yml`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `artifacts/**`, `.github/instructions/**`. Verify by reading the committed file.
- [x] AC-A2: The `modules` map in `config/blast-radius.json` no longer contains `python-dev-tools`, `vscode-extension`, `claude-runtime`, `copilot-surface`, or `agents-surface`, and retains exactly `mcp-server`, `benchmarks`, `poshqc`, `powershell-dev-tools`, `codex-runtime`, `config`, `schemas`. Verify by reading the committed file.
- [x] AC-A3: `quality-tiers.yml` remains listed in `shared_surfaces` in `config/blast-radius.json` and is also listed in `mandate_reads`. Verify by reading the committed file.
- [x] AC-A4: A new config reader for `mandate_reads` exists in `scripts/dev_tools/_blast_radius_validation.py` beside `config_root_surfaces`, and a unit test asserts that an absent key yields an empty exclusion producing byte-identical derivation output to current behavior. Verify with `poetry run pytest tests/scripts/dev_tools/ -k mandate`.

### Group B — Extraction rules and normalization (Python)

- [x] AC-B1: Mandate-read exclusion is applied during the derivation harvest in `scripts/dev_tools/compute_blast_radius.py`: a citation matching a `mandate_reads` exact path or `**` glob does not enter the derived radius's paths (nor, transitively, its modules or shared surfaces). Verify by unit test on `derive` output with and without the key.
- [x] AC-B2: `classify_path_token` rejects a wildcard-free token whose final component carries no recognized extension (directory-shaped token rejection), while `**` glob subtree claims and line-suffixed file citations remain admitted. Verify by unit tests covering `extensions/drm-copilot`, `scripts/dev_tools`, `docs/features`, `.claude/rules/` (rejected) and `scripts/dev_tools/**`, `.claude/rules/python.md:90` (admitted).
- [x] AC-B3: `artifacts/` is removed from `KNOWN_TOP_LEVEL_SEGMENTS` in `scripts/dev_tools/_blast_radius_extraction.py`, and a unit test asserts that an extension-bearing token such as `artifacts/pr_context.summary.txt` is excluded via the `artifacts/**` `mandate_reads` entry. Verify with the extraction unit tests.
- [x] AC-B4: Harvested glob tokens rooted under `docs/features/` that span multiple feature folders are rejected, while own-folder globs carrying a complete feature-folder segment are retained. Verify by unit tests using 486's `docs/features/**/plan*.md` (rejected) and an own-feature-folder glob (retained).
- [x] AC-B5: `extract_contract_identifiers` rejects contract tokens containing no ASCII letter; a unit test asserts `->` is rejected and a letter-bearing identifier is retained. Verify with the extraction unit tests.
- [x] AC-B6: A pure function `normalize_declared_radius(radius, config)` exists on `scripts/dev_tools/compute_blast_radius.py`, filters all excluded/rejected entry classes, re-resolves modules and shared surfaces against the config, does not mutate its input, and fails fast with a specific exception when given a radius whose `source == "observed"`. Verify by unit tests including the observed-radius rejection case.
- [x] AC-B7: `git diff` for the feature branch shows zero changes to `scripts/dev_tools/_blast_radius_conflicts.py`, `scripts/dev_tools/_blast_radius_glob.py`, `scripts/dev_tools/_blast_radius_thresholds.py`, and `scripts/dev_tools/parallel_cohort_computation.py`. Verify with `git diff main --stat -- scripts/dev_tools/`.
- [x] AC-B8: No field is added to the radius shape: `BlastRadius.from_dict`'s accepted key set is unchanged, and the existing parallel-checkpoint validators (`validate_blast_radius_block`, V1-V3) pass over previously recorded radii without modification. Verify by the existing validator test suites remaining green with no assertion edits.

### Group C — PowerShell parity

- [x] AC-C1: The extraction rules and the normalization entry point are mirrored in `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, `BlastRadiusConfig.psm1`, and `BlastRadius.psm1`, with comparison logic in `BlastRadiusGlob.psm1` and `BlastRadiusValidation.psm1` unchanged. Verify by `git diff` scope and the Pester suite.
- [x] AC-C2: The published byte-copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/` are updated in the same commit as their sources and are byte-identical to them. Verify by file comparison.
- [x] AC-C3: New parity fixtures covering each new extraction rule are added to `tests/fixtures/blast_radius/` (additive; on-disk count >= 26), and both drivers — `poetry run pytest tests/scripts/dev_tools/test_blast_radius_parity.py` and the Pester run of `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` — pass over the extended corpus.

### Group D — TypeScript push-down carriage

- [x] AC-D1: `CARRIED_KEYS`, the assembly object, and the emission-order documentation in `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` are extended with `mandate_reads`, and a Jest test asserts the key survives derivation into the pushed-down destination config. Verify with the extension Jest suite.
- [x] AC-D2: The bundled base document `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` gains the `mandate_reads` key; no test or tooling asserts byte-identity between it and `config/blast-radius.json`. Verify by reading the file and confirming no byte-identity assertion was added.

### Group E — Empirical demonstration (required outcome)

- [x] AC-E1: A committed fixture under `tests/fixtures/blast_radius/` holds the three recorded `verification-integrity` `blast_radius` blocks (485: 184/6/1/40, 486: 125/3/2/45, 487: 140/4/1/10 paths/modules/shared_surfaces/contracts) verbatim. Verify by reading the fixture and loading each block through `BlastRadius.from_dict`.
- [x] AC-E2: A Python regression test pins the before state: pairwise `conflicts()` over the raw fixture radii with the pre-fix config yields edges `[(485, 486), (485, 487), (486, 487)]` and `compute_cohorts` yields `[[485], [486], [487]]`. Verify with `poetry run pytest` on the regression test file.
- [x] AC-E3: The same regression test asserts the after state: `normalize_declared_radius` over the fixture radii with the fixed committed config yields the edge set exactly `[(486, 487)]` — the genuine conflict on `extensions/drm-copilot/src/mcp-tools.ts` — and `compute_cohorts([485, 486, 487], [(486, 487)]) == [[485, 486], [487]]`, i.e. two cohorts with 485 and 486 concurrent. Verify with `poetry run pytest` on the regression test file.
- [x] AC-E4: Matching before/after regression cases exist in `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` and pass under Pester.
- [x] AC-E5: The regression evidence artifact recording the before/after edge sets and cohort partitions is committed under `docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/regression-testing/`, and no evidence for this feature is written under any `artifacts/`-rooted path. Verify by listing the evidence directory and grepping the branch diff for `artifacts/`-rooted evidence writes.

### Group F — Test pins moved in the same commit

- [x] AC-F1: `test_items_sharing_a_dev_tools_file_contend_on_path_and_module` (`tests/scripts/dev_tools/test_blast_radius_config.py:407-422`) is rewritten against a retained module or has its `module_overlap` clause dropped, with the path-level contention assertion preserved and no assertion weakened. Verify by reading the test and running it.
- [x] AC-F2: The non-empty-module-map test (`test_blast_radius_config.py:180-191`) and the `config`-module pin (`test_blast_radius_config.py:444-463`) pass unmodified against the reduced module map. Verify with `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py`.
- [x] AC-F3: The committed-truth-table and location-bucket Describe blocks in `BlastRadius.Parity.Tests.ps1` (lines 302-436 pre-change), and any behavior-matrix case naming a removed module, are amended in the same commit as the config change and pass under Pester.
- [x] AC-F4: `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py:59-71` passes unmodified: the amended parallel-plan skill still contains the literal `conflicts(a, b, config)` and does not contain the literal `conflicts(a, b)`. Verify with `poetry run pytest tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py`.

### Group G — Prose and doctrine

- [x] AC-G1: The F1a paragraph at `.claude/skills/parallel-plan/SKILL.md:219-225` is reworded so the narrowing prohibition reads "do not narrow a radius beyond the configured exclusions" (describing the mandate-read exclusion as part of the landed contract), and documents the planner's obligation to explicitly append an excluded path when a plan's diff will genuinely touch it. Verify by reading the skill.
- [x] AC-G2: Rule-file doctrine documenting the mandate-read classification concept and the module-map granularity criterion is added (in `.claude/rules/parallel-orchestration.md` or a dedicated `.claude/rules/blast-radius.md`), the pushed-down rule mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/` is updated in the same commit, and no JSON Schema file is authored, imported, or read for enforcement (the foreign `drmoisan.github.io/mix-calculator/` schema is not copied). Verify by reading the rule files and grepping the diff for schema files.

### Group H — Quality gates

- [x] AC-H1: The full toolchain passes in a single clean pass for each touched language: Python (`poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch`), PowerShell (Invoke-Formatter, PSScriptAnalyzer, Pester), TypeScript (extension format/lint/type-check/Jest). Evidence recorded under `docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/evidence/qa-gates/`.
- [x] AC-H2: Coverage on changed modules meets line >= 85% and branch >= 75% for Python and TypeScript; PowerShell meets the line threshold (branch threshold exempt per `.claude/rules/quality-tiers.md`). Verify from the coverage reports in the QA-gate evidence.
- [x] AC-H3: No existing test is weakened to pass (no removed assertions, no broadened exception checks), and no test creates temporary files; all new test inputs are committed fixtures. Verify by reviewing the branch diff over `tests/`.
