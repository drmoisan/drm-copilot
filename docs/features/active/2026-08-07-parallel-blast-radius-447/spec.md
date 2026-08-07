# 2026-08-07-parallel-blast-radius — Spec

- **Issue:** #447
- **Parent (optional):** epic `parallel-orchestration` (`docs/features/epics/parallel-orchestration/epic.md`, F1, wave 0)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07T12-00
- **Status:** Ready
- **Version:** 1.0

## Overview

The accepted parallel-orchestration design (`docs/research/2026-08-07-parallel-orchestration-design-research.md`, sections 5 and 5.4) schedules independent bugs and features concurrently based on computed blast-radius contention rather than a human-authored dependency graph. No blast-radius computation exists in the repository. Downstream features of the `parallel-orchestration` epic (F3 schema/validators, F4 `parallel-planner`, F8 drift detection) consume the radius shape and the `conflicts(a, b)` contention relation, so this library is the wave-0 foundation of the epic. Radius under-reporting is named in design section 13.1 as the dominant failure mode of the entire design, so the derivation and validation contract must be delivered as tested, cross-language-consistent reference implementations.

This spec transcribes the accepted recommendations of the completed research (`docs/features/active/2026-08-07-parallel-blast-radius-447/research/2026-08-07-blast-radius-library-research.md`). Section references of the form §N refer to the design document; research §N references are labeled explicitly.

## Behavior

Deliver the blast-radius library:

- `scripts/dev_tools/compute_blast_radius.py` — the canonical, tested Python reference implementation.
- `scripts/dev_tools/_blast_radius_extraction.py` — extraction helper module behind the facade (research §7 split; keeps every production file under the 500-line limit).
- `.claude/lib/blast-radius/BlastRadius.psm1` — the PowerShell parity implementation (required because the Layer 1 enforcement hooks delivered by F7 are PowerShell).
- `config/blast-radius.json` — the shared-surface configuration truth table and the module map (see `## Configuration`).
- A cross-language parity test with a shared JSON fixture corpus at `tests/fixtures/blast_radius/`, following the ModelRouting parity pattern (`tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1`, `tests/scripts/dev_tools/test_compute_complexity_floor.py`).
- The `conflicts(a, b)` contention relation of design §5.4.

The library implements:

1. **The four-level radius model (§5.1):** `paths` (files and globs, primary signal), `modules` (module names the paths resolve to), `shared_surfaces` (high-contention artifacts, explicitly enumerated by concrete path), `contracts` (exported symbols, schema names, and CLI identifiers).
2. **The three confidence sources (§5.2):** `derived` (pre-planning, provisional cohort seeding only), `declared` (planner-computed from the approved atomic plan, authoritative for scheduling), `observed` (from the actual diff, drift correction in F8).
3. **Radius derivation (§5.3):** parse concrete repository paths from the approved plan's task bodies and the feature `spec.md`; add the feature folder itself (`docs/features/active/<feature-folder>/**`); map paths to modules via the `modules` map in `config/blast-radius.json` (see the deviation subsection under `## Configuration`); intersect against the configured shared-surface list and globs; extract contract identifiers from the spec's interface sections (headings containing `API`, `Interface`, `Contract`, or `Surface`; inline-code tokens without `/` are recorded as `contracts` entries).
4. **Validation rules (§5.3):**
   - **V1 — Coverage (Blocking).** Every concrete repository path extracted from the plan must be subsumed by `blast_radius.paths` (exact match, listed-directory prefix, or fnmatch-style glob match implemented identically in both languages). One Blocking finding per uncovered concrete path.
   - **V2 — Shared-surface enumeration (Blocking).** A shared surface touched by the item must appear explicitly by concrete path in `shared_surfaces`; glob coverage alone is insufficient. One Blocking finding per touched-but-unenumerated surface.
   - **V3 — Over-breadth (Advisory).** At most one Advisory finding when the radius's concrete coverage exceeds `over_breadth_fraction` (config key, initial value 0.25) of `tracked_file_count`. An over-broad radius is safe but serializes the batch.
5. **The contention relation (§5.4):** `conflicts(a, b) = path_overlap OR module_overlap OR shared_surface_overlap OR contract_dependency`, failing closed (see `## Public API Contract` for exact semantics).

### Derivation heuristic details (research §4)

- **Line handling.** Normalize with `text.splitlines()` in Python and the equivalent `\r\n|\r|\n` split in PowerShell, matching the plan-validator CRLF fix (commit `b845c505`, PR #437). Strip trailing carriage returns from extracted tokens defensively.
- **Task-line parsing.** Reuse the exact regex text of `PLAN_PHASE_RE` and `PLAN_TASK_RE` from `scripts/dev_tools/validate_orchestration_artifacts.py` in both languages so the derivation parser and the plan validator agree on what a task line is. Non-task plan lines are also scanned; task bodies are the primary signal.
- **Path extraction.** Extract backtick-delimited inline-code spans first; accept a token as a concrete repository path when it contains `/` and starts with a known top-level segment (`scripts/`, `tests/`, `docs/`, `config/`, `schemas/`, `packages/`, `extensions/`, `.claude/`, `.codex/`, `.github/`, `.agents/`, `artifacts/`) or matches `<segment>/.../<name>.<ext>` for a recognized extension set. Tokens containing `*` are recorded as globs in `paths`.
- **False-positive posture.** Over-inclusion of read-only path references is accepted; no ignore list in v1. Over-inclusion widens the radius, which errs in the fail-closed direction and is surfaced by V3 (Advisory). An ignore list is an under-reporting mechanism and under-reporting is the dominant design risk (§13.1).
- **V1 consistency.** Derivation and V1 share one extraction function per language (`extract_plan_paths` / `Get-PlanPaths`), so a radius produced by `derive_blast_radius` from plan P always passes V1 against P. V1's force is against hand-edited or stale `declared` radii and planner drift.

### Behavior semantics (research §8)

- Derivation never fails on well-formed text inputs; a plan with zero extractable paths yields a radius containing only the feature folder. Malformed inputs (non-string, absent feature folder, unknown `source` string) raise specific exceptions / `throw` at construction (fail fast).
- Findings are sorted (rule, then subject) for deterministic output.
- `conflicts` returns all triggered reasons, not just the first, ordered `path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency`.
- All collections are sorted and deduplicated at construction using ordinal string comparison in both languages (PowerShell must use `[StringComparer]::Ordinal`, not culture-sensitive default sorting).
- Fail-closed edges: undecidable glob×glob comparison counts as overlap; a path matching a `shared_surface_globs` pattern is a shared surface even if not in the literal `shared_surfaces` list.

## Inputs / Outputs

- **Inputs:** caller-supplied strings and values only — plan text, spec text, feature folder path, parsed `config/blast-radius.json` content, `tracked_file_count`, observed path list, `computed_at` timestamp. The library reads no files and spawns no processes at runtime (purity parity with `epic_wave_computation.py`).
- **Outputs:** the radius data shape, finding records, and conflict results defined in `## Public API Contract`. No logs, no telemetry, no filesystem writes.
- **Config keys and defaults:** `version` (1), `shared_surfaces` (list), `shared_surface_globs` (list), `modules` (object), `over_breadth_fraction` (0.25). See `## Configuration`.
- **Versioning / backward compatibility:** additive-only feature; no existing API changes. The contract literals frozen in `## Public API Contract` are the compatibility surface for F3, F4, and F8; changing any of them after F3 lands is a breaking cross-module change.

## Public API Contract

This section is the cross-module contract consumed by F3 (serialization), F4 (planner validation), and F8 (drift detection). The names, keys, and enum strings below are contract literals; downstream features depend on them verbatim.

### Radius data shape (both languages, snake_case keys, matches the §11 manifest schema)

```
blast_radius:
  paths:            [str]   # files and globs, sorted, deduplicated
  modules:          [str]   # module names from config "modules" map, sorted
  shared_surfaces:  [str]   # concrete paths, explicitly enumerated, sorted
  contracts:        [str]   # exported symbols / schema / CLI identifiers, sorted
  source:           "derived" | "declared" | "observed"     # §5.2
  computed_at:      str     # ISO-8601, caller-supplied (no wall-clock reads)
```

Python: `@dataclass(frozen=True) class BlastRadius` with `to_dict()` / `from_dict()` (F3 serializes this dict into `parallel.md` frontmatter and the checkpoint `items[].blast_radius`). PowerShell: hashtable with identical keys. Sorted, deduplicated collections make serialization deterministic (epic NFR: identical inputs produce identical outputs across languages). `computed_at` is caller-supplied, consistent with the no-wall-clock determinism policy in `.claude/rules/general-unit-test.md`.

### Python surface — `scripts/dev_tools/compute_blast_radius.py`

```python
def derive_blast_radius(
    plan_text: str, spec_text: str, feature_folder: str,
    config: Mapping[str, object], *, source: str = "derived",
    computed_at: str,
) -> BlastRadius: ...

def radius_from_observed_paths(          # F8: wrap `git diff --name-only` output
    observed_paths: Sequence[str], config: Mapping[str, object], *,
    computed_at: str,
) -> BlastRadius: ...                    # source == "observed"; modules/shared_surfaces resolved

def extract_plan_paths(plan_text: str) -> tuple[str, ...]: ...   # shared by derivation and V1

def validate_blast_radius(
    radius: BlastRadius, plan_text: str, config: Mapping[str, object], *,
    tracked_file_count: int,
) -> list[RadiusFinding]: ...
# RadiusFinding (frozen dataclass): rule: "V1"|"V2"|"V3",
#   severity: "Blocking"|"Advisory", subject: str, message: str.
# V1 Blocking per uncovered concrete path; V2 Blocking per touched-but-unenumerated
# shared surface; V3 single Advisory when concrete coverage / tracked_file_count
# exceeds config["over_breadth_fraction"]. Empty list == valid.

def conflicts(
    a: BlastRadius, b: BlastRadius, config: Mapping[str, object],
) -> ConflictResult: ...
# ConflictResult (frozen dataclass): conflict: bool,
#   reasons: tuple[ConflictReason, ...] where ConflictReason carries
#   kind: "path_overlap"|"module_overlap"|"shared_surface_overlap"|"contract_dependency"
#   and detail: str (the overlapping path/glob pair, module, surface, or identifier).
```

`tracked_file_count` is an input (the caller runs `git ls-files` or equivalent) so the library stays free of subprocess and filesystem I/O.

`conflicts` semantics (§5.4, fails closed):

- `path_overlap`: any pair from `a.paths × b.paths` overlaps. Concrete×concrete: equality. Glob×concrete: fnmatch. Glob×glob: **any pair not provably disjoint counts as overlapping** — the implementation may use a conservative shared-literal-prefix test, and when it cannot decide, it returns overlap. This is the fail-closed clause made concrete.
- `module_overlap`, `shared_surface_overlap`: non-empty set intersection.
- `contract_dependency`: non-empty intersection of `contracts` sets (v1 scope: identifier equality; a richer provides/consumes distinction is a future refinement that would only narrow, never widen, so deferring it is fail-closed).
- Empty-versus-empty radii do not conflict; an empty radius against a non-empty one has no overlap at any level. Under-reporting via emptiness is V1's problem at plan time and F8's at run time, not the relation's.
- `conflicts` returns the verdict plus **all** triggered reason kinds, ordered `path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency`.

### PowerShell surface — `.claude/lib/blast-radius/BlastRadius.psm1`

Approved-verb mirrors with identical output keys (hashtables):

- `Get-BlastRadius -PlanText -SpecText -FeatureFolder -Config -Source -ComputedAt`
- `Get-BlastRadiusFromObservedPaths -ObservedPaths -Config -ComputedAt`
- `Get-PlanPaths -PlanText`
- `Test-BlastRadius -Radius -PlanText -Config -TrackedFileCount` → array of finding hashtables (`rule`, `severity`, `subject`, `message`)
- `Test-BlastRadiusConflict -RadiusA -RadiusB -Config` → `@{ conflict = <bool>; reasons = @(@{ kind; detail }) }`

The PowerShell mirror exists because the Layer 1 enforcement hooks (F7) and the cohort-barrier hook are PowerShell; `Test-BlastRadiusConflict` is what `enforce-parallel-cohort-barrier.ps1` will call. The module header must state, per the `ModelRouting.psm1` precedent, that the Python module remains the authoritative reference and that the mirror never imports validator logic.

### Downstream consumers

| Consumer | Needs from F1 |
| --- | --- |
| F3 schema/validators | Stable `to_dict()` key set and enum values for `source`; the finding shape (`rule`/`severity`) for planner-state records; the `ConflictReason.kind` strings for `conflict_edges[].reason` (§12). These strings are contract literals — frozen in this section. |
| F4 `parallel-planner` | `derive_blast_radius` + `validate_blast_radius` (V1/V2 Blocking gate, V3 Advisory report) + `conflicts` for cohort seeding. |
| F8 drift detection | `radius_from_observed_paths` (source `observed`) + `conflicts` recomputation against declared radii (§7 steps 1 and 4). |

## Configuration

`config/blast-radius.json` (new file, JSON) carries the shared-surface truth table and the module map. JSON rather than YAML because both runtimes parse it natively (Python stdlib `json`, PowerShell `ConvertFrom-Json`) with zero new dependencies. A dedicated file rather than a section of `config/orchestration-routing.json` avoids the byte-identical bundled-mirror obligation that couples the routing config to extension packaging.

Shape:

```json
{
  "version": 1,
  "shared_surfaces": [
    "config/orchestration-routing.json",
    "extensions/drm-copilot/resources/config/orchestration-routing.json",
    ".claude/settings.json",
    "poetry.lock",
    "package-lock.json",
    "extensions/drm-copilot/package-lock.json",
    "packages/mcp-server/package-lock.json",
    "quality-tiers.yml",
    "config/blast-radius.json",
    "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
  ],
  "shared_surface_globs": [
    "scripts/dev_tools/validate_*.py",
    "scripts/dev_tools/_orchestrator_state_*.py",
    "scripts/dev_tools/_epic_orchestrator_state_*.py"
  ],
  "modules": { "<module>": ["<glob>", "..."] },
  "over_breadth_fraction": 0.25
}
```

Notes:

- Every listed path/glob is verified present in this repository (research §1.5) except `quality-tiers.yml`, which is retained deliberately as a forward-looking entry (harmless while absent; automatically load-bearing if the file is ever created).
- `shared_surface_globs` defines membership only (which concrete files count as shared surfaces). V2 still requires `blast_radius.shared_surfaces` to name each touched surface explicitly by concrete path — §5.3 states glob coverage alone is insufficient. The globs are expanded against the item's concrete paths, never used as the enumeration itself.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is a repository-specific addition beyond the §5.1 item 3 list, justified by its append history across at least twelve issues: nearly every feature that adds a production PowerShell file edits its `CodeCoverage.Path` list. It is the first candidate for the key-level-partitioning refinement deferred by §13.2.
- `over_breadth_fraction` is the V3 threshold. 0.25 is a starting value; V3 is Advisory, so tuning is inexpensive.
- Both implementations take the parsed config as a function parameter (pure, file-read-free). Tests in both languages load the committed `config/blast-radius.json` and assert shape constraints, mirroring the ModelRouting config-pinning tests.

Initial `modules` map (module name → path globs), derived from the observed repository tree:

| Module | Globs |
| --- | --- |
| `python-dev-tools` | `scripts/dev_tools/**` |
| `powershell-dev-tools` | `scripts/dev-tools/**` |
| `poshqc` | `scripts/powershell/**` |
| `benchmarks` | `scripts/benchmarks/**` |
| `claude-runtime` | `.claude/**` |
| `codex-runtime` | `.codex/**` |
| `copilot-surface` | `.github/**` |
| `agents-surface` | `.agents/**` |
| `mcp-server` | `packages/mcp-server/**` |
| `vscode-extension` | `extensions/drm-copilot/**` |
| `config` | `config/**` |
| `schemas` | `schemas/**` |
| `tests` | `tests/**` |
| `docs` | `docs/**` |

A path matching no module glob resolves to no module (it still participates in `paths`-level overlap). The map is intentionally coarse: module overlap is the second, wider net after path overlap (§5.4), and coarseness errs in the fail-closed direction.

### Deviation from design §5.1 — module-resolution source

Design §5.1 item 2 specifies mapping `paths` to `modules` via `quality-tiers.yml`. This feature deviates: **module resolution uses the `modules` map in `config/blast-radius.json` instead of `quality-tiers.yml`.**

Rationale (research §2, recommendation accepted):

1. No `quality-tiers.yml` exists at the repository root; only `.claude/rules/quality-tiers.md`, which documents the tier system in prose without a machine-readable project map.
2. Creating `quality-tiers.yml` inside F1 carries an unrelated CI-enforcement contract: `.claude/rules/quality-tiers.md` states a CI `tier-classification` stage validates every project entry, and no such CI stage exists in this repository. F1 would have to author a complete tier classification of every project and either build or knowingly omit the enforcing CI stage — out of the epic's scope.
3. PowerShell 7 has no built-in YAML parser; consuming a YAML file in the mirror would require a hand-rolled parser or a new dependency, and new dependencies are prohibited without explicit instruction (`.claude/rules/general-code-change.md`, Dependencies).
4. Tiers are never an input to derivation, validation, or `conflicts`; F1 needs only a path→module mapping.

`quality-tiers.yml` remains enumerated in the `shared_surfaces` truth table as a forward-looking entry. If a dedicated quality-gates feature later creates it, the module map can be re-pointed without changing the F1 API, because the map is a config input, not code.

The absent `quality-tiers.yml` is already tracked independently as open issue
[#336](https://github.com/drmoisan/drm-copilot/issues/336) (`Bug: quality-tiers-yml-missing-at-repo-root`),
whose body is unpopulated and therefore records no chosen resolution. This deviation deliberately
leaves #336 independently resolvable: F1 neither creates the file nor closes the issue, and nothing
in F1's API depends on which way #336 is eventually settled.

Two further gaps were observed while evaluating option 2 and are recorded here because they bear on
any future attempt to resolve #336: the `tier-classification` CI stage cited by
`.claude/rules/quality-tiers.md` does not exist in any workflow under `.github/workflows/`, and
`docs/ci.research.md`, named by that rule file as the tier system's source of truth, does not exist
either. Both are outside this epic's scope.

## Data & State

- **Data flow:** caller-supplied text/config in → immutable radius, finding, and conflict values out. No storage, no persistence, no caching, no state.
- **Invariants:** all collections sorted (ordinal) and deduplicated at construction; `source` restricted to the three-value enum; findings sorted by (rule, subject); conflict reasons in fixed kind order; identical inputs produce identical outputs in both languages.
- **Migration/backfill:** none. `config/blast-radius.json` is a new file with no predecessor.

## Constraints & Risks

Non-negotiable constraints (restated from the epic Shared Design and design §5.3, §13.2):

1. The surface is named `parallel` throughout.
2. The contention relation fails closed; glob×glob pairs that cannot be proven disjoint count as overlap; key-level partitioning of shared surfaces is a non-goal (§13.2).
3. The atomic-plan contract (`.claude/skills/atomic-plan-contract/SKILL.md`) must NOT be changed (§5.3). The radius is derived heuristically from approved plan task bodies and `spec.md`.
4. Additive only: no modification or refactoring of existing epic implementations. Exactly three append-only edits to existing files are permitted (per amended AC13): the `CodeCoverage.Path` entry in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, the identical entry in its byte-parity bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and the pack-manifest module entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (issue #312 ModelRouting precedent). New `.claude/**` files must additionally be created as byte-identical bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/`; these mirrors are file creations, not edits.
5. File-size limit: no production, test, or reusable script file may exceed 500 lines; use the facade + `_blast_radius_extraction.py` helper split (research §7), adding `_blast_radius_validation.py` only if the facade approaches the limit.
6. Property-style test obligations are met with parametrized invariant tests (symmetry, monotonicity, self-conflict, determinism, V1 self-consistency); `hypothesis` must NOT be added as a dependency.

Risks:

- Heuristic derivation can under-report (§13.1, dominant design risk). V1 bounds this at plan time; drift detection (F8) bounds it at execution time and is out of scope here. The heuristic therefore only errs wide (no ignore list in v1).
- Over-inclusion of read-only path references inflates radii and may over-serialize cohorts; bounded because policy-read noise is shared across items, and surfaced by V3. Measured under the §13.2 follow-up before any partitioning work.
- The `pester.runsettings.psd1` coverage-path append itself touches a proposed shared surface — expected, and an early datum for §13.2 measurement.

## Implementation Strategy

- **New files:** `scripts/dev_tools/compute_blast_radius.py` (facade: dataclasses, `derive_blast_radius`, `radius_from_observed_paths`, `validate_blast_radius`, `conflicts`, re-exports), `scripts/dev_tools/_blast_radius_extraction.py` (line normalization, task/inline-code scanning, path/contract token rules, fnmatch subsumption helper), `.claude/lib/blast-radius/BlastRadius.psm1`, its byte-identical bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1` (plus the mirror of any sibling module if split), `config/blast-radius.json`, `tests/scripts/dev_tools/test_compute_blast_radius.py` (plus helper test files mirroring the module split), `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1`, `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`, `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`, `tests/fixtures/blast_radius/*.json`.
- **Modified files (three, append-only, per amended AC13):** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — append-only `CodeCoverage.Path` entry for `BlastRadius.psm1` (and any sibling module) with an issue #447 comment, per the issue #312 precedent for `ModelRouting.psm1`; `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — the identical append applied to the byte-parity bundled mirror; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — append-only pack-manifest entry publishing the new module, per the issue #312 ModelRouting precedent.
- **Contingent split:** if the Python facade approaches 500 lines, move V1–V3 into `_blast_radius_validation.py`. If the PowerShell module approaches 500 lines, split into `BlastRadius.psm1` (facade) + `BlastRadiusExtraction.psm1` per the `orchestrator-state` two-module precedent; each additional PowerShell module must also be appended to `CodeCoverage.Path`.
- **Dependency changes:** none. Python stdlib and existing dev dependencies only; PowerShell built-ins only; `hypothesis` is not added.
- **Logging/telemetry:** none. The library is pure; callers own reporting.
- **Rollout:** no flags. The library has no callers until F3/F4/F8 land; shipping it is inert.
- **Toolchain:** Python via Black → Ruff → Pyright → Pytest (`--cov --cov-branch`); PowerShell via the PoshQC MCP tools (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
- **Evidence:** all implementation-phase evidence (baselines, QA gates, coverage) is written to `docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`; `artifacts/` evidence sub-paths are forbidden.

## Test Strategy

- **Unit tests (Python):** `tests/scripts/dev_tools/test_compute_blast_radius.py` plus per-helper files, in the mandated `tests/` mirror layout. Scenario matrix: each derivation stage; V1/V2/V3 positive and negative; each `conflicts` disjunct in isolation; fail-closed glob×glob undecidable case; empty radius; glob subsumption boundary; CRLF/CR/whitespace plan input; V3 threshold boundary (exactly at, just over).
- **Unit tests (PowerShell):** `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1`, same scenario matrix, run via PoshQC with Pester 5.x.
- **Parametrized invariant tests (both languages, no `hypothesis`):** symmetry (`conflicts(a, b) == conflicts(b, a)`, verdict and reason multiset); monotonicity (adding a path/module/surface/contract never turns a conflict into a non-conflict); self-conflict (any radius with a non-empty level conflicts with itself); determinism and input-order independence of derivation and validation; V1 self-consistency (a derived radius always passes V1 against its source plan).
- **Cross-language parity:** shared fixture corpus `tests/fixtures/blast_radius/*.json` (committed, read-only; no temp files). Each fixture carries `input` (`plan_text`, `spec_text`, `feature_folder`, `config`, `tracked_file_count`, optional `radius_a`/`radius_b`) and `expected` (`radius`, `findings`, `conflict` verdict + reasons). Includes a CRLF fixture (literal `\r\n` inside the JSON string) and a glob-undecidable conflict fixture. The Python suite parametrizes over every fixture and asserts exact equality; `BlastRadius.Parity.Tests.ps1` iterates the same files (`Get-ChildItem` + `ConvertFrom-Json`) and asserts the same expected values, file-read-only, no external process — the discipline of `ModelRouting.Parity.Tests.ps1`.
- **Config pinning:** both suites load the committed `config/blast-radius.json` and assert shape constraints (every `modules` glob non-empty, `over_breadth_fraction` in (0, 1], `shared_surfaces` entries repo-relative), so the two implementations and the config cannot drift.
- **Out of scope:** no live `git` integration (`tracked_file_count` and observed paths are plain inputs); no network, temp files, or wall clock (`computed_at` is an input); no cross-process Python↔PowerShell execution.

## Acceptance Criteria

- [ ] `scripts/dev_tools/compute_blast_radius.py` implements the four-level radius model (`paths`, `modules`, `shared_surfaces`, `contracts`) and the three confidence sources (`derived`, `declared`, `observed`) exactly as defined in `## Public API Contract`, exposing `derive_blast_radius`, `radius_from_observed_paths`, `extract_plan_paths`, `validate_blast_radius`, and `conflicts` with the documented signatures and frozen contract literals.
- [ ] Radius derivation follows design §5.3: paths parsed from plan task bodies and `spec.md` inline-code spans, the feature folder appended, modules resolved via the config `modules` map, shared surfaces expanded from the config list and globs, contract identifiers extracted from spec interface-section headings; line handling uses `splitlines()`-equivalent CRLF/CR normalization and the plan-contract task regexes.
- [ ] `validate_blast_radius` implements V1 (coverage, Blocking, one finding per uncovered concrete path), V2 (shared-surface enumeration, Blocking, one finding per touched-but-unenumerated concrete surface; glob coverage insufficient), and V3 (over-breadth, Advisory, at most one finding when concrete coverage exceeds `over_breadth_fraction` of `tracked_file_count`), with findings sorted by (rule, subject).
- [ ] `conflicts(a, b)` implements the four §5.4 disjuncts (`path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency`), fails closed (glob×glob pairs not provably disjoint count as overlap), and returns the verdict plus all triggered reason kinds in fixed order.
- [ ] Derivation and V1 share a single extraction function per language, and a radius produced by `derive_blast_radius` from plan P passes V1 against P (proved by an invariant test in both languages).
- [ ] `.claude/lib/blast-radius/BlastRadius.psm1` provides the parity surface `Get-BlastRadius`, `Get-BlastRadiusFromObservedPaths`, `Get-PlanPaths`, `Test-BlastRadius`, `Test-BlastRadiusConflict` with output keys and values identical to the Python reference, ordinal sorting, and the authoritative-reference header statement.
- [ ] `config/blast-radius.json` exists with the documented shape: `shared_surfaces` truth table (including the forward-looking `quality-tiers.yml` entry), `shared_surface_globs`, the `modules` map, and `over_breadth_fraction`; both test suites pin its shape.
- [ ] Module resolution uses the `modules` map in `config/blast-radius.json`, and the deviation from design §5.1 is recorded in this spec under `### Deviation from design §5.1 — module-resolution source`.
- [ ] A shared JSON fixture corpus exists at `tests/fixtures/blast_radius/` (including a CRLF fixture and a glob-undecidable conflict fixture), and both the Python parity test and `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` iterate every fixture and assert identical radii, findings, and conflict results, following the ModelRouting parity pattern.
- [ ] Parametrized invariant tests pass in both languages: conflict symmetry, monotonicity (fail-closed direction), self-conflict, determinism and input-order independence, and V1 self-consistency; `hypothesis` is not added as a dependency.
- [ ] Line coverage >= 85% and branch coverage >= 75% for every new module in both languages; `BlastRadius.psm1` (and any sibling PowerShell module) is appended to the `CodeCoverage.Path` list in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` with an issue #447 comment.
- [ ] No production, test, or reusable script file exceeds 500 lines; the facade + `_blast_radius_extraction.py` split (and contingent `_blast_radius_validation.py` / `BlastRadiusExtraction.psm1` splits) is used as needed.
- [ ] `.claude/skills/atomic-plan-contract/SKILL.md` is unchanged; no existing epic implementation is modified or refactored; the only edits to existing files are the append-only Pester coverage-path entry, applied identically to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its byte-parity bundled mirror, and the append-only `core.json` pack-manifest entry publishing the new module; new `.claude/**` files are additionally created as byte-identical bundled mirrors, which are file creations rather than edits.
- [ ] The library is pure: no filesystem reads/writes, no subprocess, no network, and no wall-clock reads at runtime; `computed_at`, `tracked_file_count`, and observed paths are caller-supplied.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage: derivation from plan/spec text, path-to-module mapping, shared-surface intersection, contract extraction, each of V1/V2/V3, each of the four `conflicts` disjuncts, fail-closed behavior.
- [ ] Property/edge cases: empty radius, glob subsumption, whitespace and CRLF handling in plan parsing, over-breadth threshold boundary.
- [ ] Cross-language parity: identical fixture inputs produce identical radii, validation verdicts, and conflict edges in Python and PowerShell.
