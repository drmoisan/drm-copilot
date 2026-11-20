# F1 Blast-Radius Library — Research (Issue #447)

- Date: 2026-08-07
- Timestamp: 2026-08-07T00-00 (ISO-8601, `yyyy-MM-ddTHH-mm` per `evidence-and-timestamp-conventions`)
- Feature: `docs/features/active/2026-08-07-parallel-blast-radius-447/` (Issue #447)
- Epic: `docs/features/epics/parallel-orchestration/epic.md` (F1, wave 0, band C4)
- Design source: `docs/research/2026-08-07-parallel-orchestration-design-research.md` (§5.1–§5.4, §7, §13.1, §13.2)
- Status: Research complete

## Non-Negotiable Constraints (restated)

1. The surface is named `parallel` throughout (epic Shared Design item 1).
2. The contention relation fails closed (§5.4); key-level partitioning of shared surfaces is a non-goal (§13.2, epic Non-Goals).
3. The atomic-plan contract (`.claude/skills/atomic-plan-contract/SKILL.md`) must NOT be changed (§5.3). The radius is derived heuristically from approved plan task bodies and `spec.md`; V1 exists precisely because derivation is heuristic.
4. Additive only: no modification or refactoring of existing epic implementations (epic Non-Goals).

## 1. Current State Analysis

### 1.1 No blast-radius computation exists

Verified by inspection of `scripts/dev_tools/` (72 Python files listed; none compute a radius) and `.claude/lib/` (only `model-routing/` and `orchestrator-state/`). F1 is greenfield within an established two-language reference-implementation pattern.

### 1.2 Cross-language parity prior art (verified mechanics)

The repository proves Python/PowerShell parity by **shared-truth-table pinning plus mirrored behavioral test matrices**, not by cross-process execution:

- **Python reference modules** are pure and file-read-free at runtime:
  `scripts/dev_tools/compute_complexity_floor.py` (embeds `FLOOR_SIGNAL_NAMES`, `BAND_ORDER`),
  `scripts/dev_tools/resolve_delegation_model.py` (embeds `BASE_COMPLEXITY_TO_MODEL`, overlay constants),
  `scripts/dev_tools/epic_wave_computation.py` (pure function over a caller-parsed mapping).
- **PowerShell mirror** `.claude/lib/model-routing/ModelRouting.psm1` re-embeds the same literals as `$script:` constants (`Get-ComplexityFloor`, `Resolve-DelegationModel`) and states in its header that it "never imports validator logic" and that "the Python modules remain the validator's authoritative reference."
- **Pinning tests** hold both sides to one source of truth, `config/orchestration-routing.json`:
  - Python: `tests/scripts/dev_tools/test_compute_complexity_floor.py::test_floor_signal_names_match_config_floor_true_entries` asserts the embedded set equals the config's `"floor": true` names.
  - PowerShell: `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1` asserts every embedded `$script:` constant equals the corresponding `model_policy` / `model_budget` config value (file-read-only; no external process; no temp files).
  - A byte-identity guard (`tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`) pins the config's bundled extension mirror to the canonical copy.
- **Behavioral matrices** are mirrored per language: `tests/scripts/dev_tools/test_compute_complexity_floor.py` and `tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1` / `Resolve-DelegationModel.Tests.ps1` exercise the same cases (determinism, order-independence, ceiling clamp, unknown-name handling). `tests/scripts/dev_tools/test_epic_wave_computation.py` shows the pure-function test style (diamond DAG, linear chain, cycle, empty input).

F1 should follow this pattern, with one extension justified below (§6.3): because F1's behavior is text parsing rather than a small lookup table, parity additionally needs a **shared fixture corpus** consumed by both test suites.

### 1.3 Atomic-plan format (must be parsed, must not be changed)

`.claude/skills/atomic-plan-contract/SKILL.md` defines: phase headings `### Phase N — <Title>`; tasks `- [ ] [P#-T#] <title>` (or `[x]`). The existing machine parse is in `scripts/dev_tools/validate_orchestration_artifacts.py`:

```python
PLAN_PHASE_RE = re.compile(r"^### Phase (?P<phase>\d+) — (?P<title>.+)$")
PLAN_TASK_RE = re.compile(
    r"^- \[(?P<state>[ xX])\] \[P(?P<phase>\d+)-T(?P<task>\d+)\] (?P<title>.+)$"
)
```

Line iteration uses `text.splitlines()` (line 91), which is the CRLF/CR fix landed in commit `b845c505` ("fix(plan-validator): support CRLF and CR line endings", PR #437). F1's derivation parser must reuse the same regexes and the same `splitlines()` normalization so the parser that derives the radius and the validator that gates the plan agree on what a task line is.

### 1.4 Known constraint verified: `quality-tiers.yml` does not exist

Confirmed by glob at the worktree root and repo-wide: no `quality-tiers.yml` anywhere in the tree. Only `.claude/rules/quality-tiers.md` exists, documenting the T1–T4 system in prose (its tier examples — classifier engines, `TaskMaster.Domain`, Office.js wrappers — describe a target architecture from `docs/ci.research.md`, not this repository's actual project inventory). Resolution in §2.

### 1.5 Shared-surface candidates verified in this repository

- `config/orchestration-routing.json` — exists; byte-identical bundled mirror at `extensions/drm-copilot/resources/config/orchestration-routing.json` (pinned by `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py`). Editing one requires editing both; both are shared surfaces.
- `.claude/settings.json` — exists.
- Lockfiles present (verified by glob): `poetry.lock`, `package-lock.json` (root), `extensions/drm-copilot/package-lock.json`, `packages/mcp-server/package-lock.json`. No `pnpm-lock.yaml`, no `yarn.lock`.
- Shared validators (verified files): `scripts/dev_tools/validate_orchestration_artifacts.py`, `validate_orchestrator_state.py`, `validate_epic_orchestrator_state.py`, `validate_epic_planner_state.py`, `validate_orchestration_review_artifacts.py`, `validate_policy_audit_artifact.py`, `validate_evidence_locations.py`, `validate_discovery_*.py`, and the `_orchestrator_state_*.py` / `_epic_orchestrator_state_*.py` helper modules.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — empirically high-contention: its `CodeCoverage.Path` list has been appended by at least twelve separate issues (#272, #214, #275, #301, #298, #305, #312, #328, #334, #344, #357, #366, #392, #415 per in-file comments). Nearly every feature that adds a production PowerShell file edits it.
- `quality-tiers.yml` — absent (see §2; retained in the truth table as a forward-looking entry).

### 1.6 File-size and module-split precedent

The 500-line limit (`.claude/rules/general-code-change.md`) is managed in prior art by facade-plus-helper splits: `validate_orchestrator_state.py` delegates to `_orchestrator_state_complexity.py`, `_orchestrator_state_model_routing.py`, `_orchestrator_state_model_routing_gate.py`, `_orchestrator_state_human_interaction.py`, etc. On the PowerShell side, `.claude/lib/orchestrator-state/` splits into `OrchestratorState.psm1` and `OrchestratorStateCompletion.psm1`.

### 1.7 Toolchain constraints

- Python: Black → Ruff → Pyright → Pytest with `--cov --cov-branch` (`.claude/rules/python.md`); full docstring/comment policy (`.claude/rules/self-explanatory-code-commenting.md`) materially inflates line counts.
- PowerShell: PoshQC MCP tools (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) with Pester 5.x; coverage measured only for files listed in `pester.runsettings.psd1` `CodeCoverage.Path`, so `BlastRadius.psm1` must be appended there (precedent: the issue #312 entry for `ModelRouting.psm1`).
- `hypothesis` is **not** a dependency (verified: absent from `pyproject.toml` `[tool.poetry.group.dev.dependencies]`) and is not used anywhere under `tests/` (grep: only incidental matches of the word in epic-intent fixtures). See §6.2.

## 2. Research Question 1 — Module-Resolution Source

§5.1 item 2 maps `paths` to `modules` via `quality-tiers.yml`. That file does not exist (§1.4).

### Candidate (a): create `quality-tiers.yml` at repo root as part of F1

- Description: author the machine-readable project→tier map that `.claude/rules/quality-tiers.md` describes, and have F1 read its project path globs for module resolution.
- Advantages: literal conformance with §5.1; the file is separately mandated by `.claude/rules/general-code-change.md` ("Every project must be classified in `quality-tiers.yml` at repo root").
- Limitations: the file's documented contract is much larger than F1 needs — `.claude/rules/quality-tiers.md` states a CI `tier-classification` stage validates that "every project entry has a tier and that no unclassified project exists," and no such CI stage exists in this repository. Creating the file inside F1 forces F1 to (i) author a complete, correct tier classification of every project in the repository, (ii) either build or knowingly omit the enforcing CI stage, and (iii) couple the parallel-orchestration epic to a quality-gate workstream that is out of its scope. It also requires a YAML parser in the PowerShell mirror; PowerShell 7 has no built-in YAML support, so the mirror would need a hand-rolled subset parser or a new dependency (prohibited without explicit instruction per `.claude/rules/general-code-change.md` Dependencies).
- Tier note: F1 needs only a path→module mapping; tiers themselves are never an input to derivation, validation, or `conflicts`.

### Candidate (b): module map inside the blast-radius truth-table config (RECOMMENDED)

- Description: the new `config/blast-radius.json` (see §3) carries a `modules` object mapping module names to path-glob lists for this repository. F1 resolves `paths → modules` against that map. Record in `spec.md` as an explicit deviation from §5.1: *module resolution uses the `modules` map in `config/blast-radius.json` instead of `quality-tiers.yml`, because no `quality-tiers.yml` exists at the repository root and creating one carries an unrelated CI-enforcement contract.*
- Advantages: additive and self-contained (epic Non-Goals); JSON is parseable by Python stdlib `json` and PowerShell `ConvertFrom-Json` with zero new dependencies; keeps the module map versioned next to the shared-surface list it partners with; exactly matches the config-pinning parity pattern of §1.2; leaves `quality-tiers.yml` free to be created later by a dedicated quality-gates feature, at which point the map can be re-pointed without changing the F1 API (the map is a config input, not code).
- Alignment: matches the repository convention that reference implementations are pure and receive their truth table via a pinned config (`config/orchestration-routing.json` precedent).

**Recommendation: candidate (b).** The `quality-tiers.yml` entry stays in the `shared_surfaces` truth table as a forward-looking path (harmless while absent; automatically load-bearing if the file is ever created), and the deviation is recorded in `spec.md` per the F1 acceptance criterion in `issue.md`.

Proposed initial `modules` map for this repository (module name → globs), derived from the observed tree:

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

A path matching no module glob resolves to no module (it still participates in `paths`-level overlap); the map is intentionally coarse because module overlap is the second, wider net after path overlap (§5.4), and coarseness errs in the fail-closed direction.

## 3. Research Question 2 — Shared-Surface Configuration Truth Table

**Recommended file: `config/blast-radius.json`** (new, JSON). Rationale for a new file rather than a section in `config/orchestration-routing.json`: the routing config has a byte-identical bundled mirror under `extensions/drm-copilot/resources/config/` enforced by `test_orchestration_routing_config_parity.py`; any edit obligates a synchronized mirror edit and couples F1 to the extension packaging surface. A dedicated file is additive and avoids that coupling. JSON over YAML: both runtimes parse it natively (§2 candidate (a) limitations).

Proposed shape:

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

- Every listed path/glob is verified present in this repository (§1.5) except `quality-tiers.yml`, retained deliberately (§2).
- `shared_surface_globs` defines *membership* (which concrete files count as shared surfaces). V2 still requires the item's `blast_radius.shared_surfaces` to name each touched surface **explicitly by concrete path** — §5.3 states glob coverage alone is insufficient. The globs are expanded against the item's concrete paths, never used as the enumeration itself.
- `pester.runsettings.psd1` is a repository-specific addition beyond the §5.1 item 3 list, justified by the twelve-issue append history (§1.5). Risk trade-off: it increases shared-surface serialization pressure (§13.2), but omitting it would let two concurrent items race on the coverage `Path` list — precisely the contention class shared surfaces exist to serialize. §13.2 directs measuring before building key-level partitioning; this entry is the first candidate for that future refinement.
- `over_breadth_fraction` is the V3 threshold (§5.3): a radius whose concrete coverage exceeds this fraction of tracked files is reported (Advisory). 0.25 is a starting value; V3 is Advisory, so tuning is cheap.
- Config pinning for parity: both implementations take the parsed config as a function parameter (pure, file-read-free, per §1.2 pattern); tests in both languages load the committed `config/blast-radius.json` and assert well-formedness plus the constraints above, mirroring `ModelRouting.Parity.Tests.ps1` and `test_floor_signal_names_match_config_floor_true_entries`.

## 4. Research Question 3 — Radius Derivation Heuristic

Derivation inputs (§5.3): the approved plan text, the feature `spec.md` text, the feature folder path, and the truth-table config. All are caller-supplied strings/values; the library reads no files (parity with `epic_wave_computation.py`, whose docstring states "does not read or write any manifest file; it operates purely on the mapping passed in by the caller").

### 4.1 Line handling (CRLF)

Normalize with `text.splitlines()` in Python and `-split '\r\n|\r|\n'` (or `[string]::Split` on normalized text) in PowerShell, matching the `b845c505` plan-validator fix (§1.3). Additionally strip a trailing `` `r `` from extracted tokens defensively. A dedicated CRLF fixture in the parity corpus (JSON string containing literal `\r\n`) pins this in both languages without depending on git `eol` settings.

### 4.2 Path extraction

- **Task lines:** match `PLAN_TASK_RE` (identical regex text in both languages) and scan the `title` group. Non-task lines of the plan are also scanned (plans carry path references in phase preambles and evidence clauses), but task bodies are the primary signal named by §5.3.
- **Inline-code spans first:** extract backtick-delimited spans; within each span, accept a token as a concrete repository path when it (i) contains `/`, and (ii) starts with a known top-level segment (`scripts/`, `tests/`, `docs/`, `config/`, `schemas/`, `packages/`, `extensions/`, `.claude/`, `.codex/`, `.github/`, `.agents/`, `artifacts/`) or matches `<segment>/.../<name>.<ext>` for a recognized extension set. Restricting to inline code bounds false positives from prose while matching how this repository's plans actually cite paths (verified against `plan.2026-08-07T11-11.md` and the atomic-plan contract's own examples).
- **Glob tokens:** a token containing `*` is recorded as a glob in `paths` (the §11 manifest schema types `paths` as `[<glob>, ...]`).
- **`spec.md`:** same inline-code extraction over the whole document; additionally, sections whose headings contain `API`, `Interface`, `Contract`, or `Surface` (this feature's template has `## API / CLI Surface`) are the source for contract-identifier extraction: inline-code tokens in those sections that are *not* path-like (no `/`) are recorded as `contracts` entries (function names, schema names, CLI names). This is the "extract contract identifiers from the spec's interface sections" step of §5.3.
- **Feature folder:** always append `docs/features/active/<feature-folder>/**` to `paths` (§5.3 "add the feature folder itself").
- **Then:** `modules` = resolve every concrete path and glob against the config `modules` map; `shared_surfaces` = expand `shared_surfaces` + `shared_surface_globs` against the extracted concrete paths and record each hit explicitly.

### 4.3 False-positive posture (deliberate)

Plans cite paths they only read: policy files in Phase 0 ("read `.claude/rules/python.md`"), prior-art references, command lines in fenced blocks. Extraction will over-include these. **Recommendation: accept over-inclusion; do not add an ignore list in v1.** Rationale: over-inclusion widens the radius, which is safe — it serializes more (§5.3: "An over-broad radius is safe but serializes the batch") and is surfaced by V3 (Advisory). An ignore list is an under-reporting mechanism: if it ever excluded a path an item genuinely modifies, and V1 applies the same extraction (it must, to be consistent), the escape would go undetected until F8 drift detection. Under-reporting is the dominant design risk (§13.1); the heuristic must only err wide. Phase-0 policy-read noise is bounded in practice because policy files are shared across all items — they inflate every radius equally and mostly cancel in relative contention, at the cost of some over-serialization measured under §13.2.

### 4.4 V1 consistency requirement

V1 (coverage, Blocking) re-runs the same extraction over the plan and asserts every extracted concrete path is subsumed by `blast_radius.paths` (exact match, listed-directory prefix, or glob match via `fnmatch`-equivalent semantics implemented identically in both languages — PowerShell should implement the same fnmatch subset explicitly rather than relying on `-like`, whose `[`-class semantics differ). Derivation and V1 must share one extraction function per language so a derived radius always passes its own V1; V1's force is against hand-edited or stale `declared` radii and against planner drift.

## 5. Research Question 4 — Public API Contract

This API is a cross-module contract consumed by F3 (serialization), F4 (planner validation), F8 (drift). It must be defined verbatim in `spec.md` per the issue #447 acceptance criteria.

### 5.1 Radius data shape (both languages, snake_case keys, matches §11 manifest schema)

```
blast_radius:
  paths:            [str]   # files and globs, sorted, deduplicated
  modules:          [str]   # module names from config "modules" map, sorted
  shared_surfaces:  [str]   # concrete paths, explicitly enumerated, sorted
  contracts:        [str]   # exported symbols / schema / CLI identifiers, sorted
  source:           "derived" | "declared" | "observed"     # §5.2
  computed_at:      str     # ISO-8601, caller-supplied (no wall-clock reads)
```

Python: `@dataclass(frozen=True) class BlastRadius` with `to_dict()` / `from_dict()` (F3 serializes this dict into `parallel.md` frontmatter and the checkpoint `items[].blast_radius`). PowerShell: hashtable with identical keys. Sorted, deduplicated collections make serialization deterministic (epic NFR: identical inputs → identical outputs across languages).

`computed_at` is caller-supplied, consistent with the determinism policy in `.claude/rules/general-unit-test.md` (no wall-clock reads in code under test) and the purity of all prior-art reference modules.

### 5.2 Python surface — `scripts/dev_tools/compute_blast_radius.py`

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

`tracked_file_count` is an input (caller runs `git ls-files | wc -l` or equivalent) so the library stays free of subprocess and filesystem I/O.

`conflicts` semantics (§5.4, fails closed):

- `path_overlap`: any pair from `a.paths × b.paths` overlaps. Concrete×concrete: equality. Glob×concrete: fnmatch. Glob×glob: **any pair not provably disjoint counts as overlapping** — the implementation may use a conservative shared-literal-prefix test, and when it cannot decide, it returns overlap. This is the fail-closed clause made concrete.
- `module_overlap`, `shared_surface_overlap`: non-empty set intersection.
- `contract_dependency`: non-empty intersection of `contracts` sets (v1 scope: identifier equality; a richer provides/consumes distinction is a future refinement and would only narrow, never widen, so deferring it is fail-closed).
- Empty-versus-empty radii do not conflict (nothing shared is provable-disjoint at every level); an empty radius against a non-empty one likewise has no overlap at any level. Under-reporting via emptiness is V1's problem at plan time and F8's at run time, not the relation's.

### 5.3 PowerShell surface — `.claude/lib/blast-radius/BlastRadius.psm1`

Approved-verb mirrors with identical output keys (hashtables):

- `Get-BlastRadius -PlanText -SpecText -FeatureFolder -Config -Source -ComputedAt`
- `Get-BlastRadiusFromObservedPaths -ObservedPaths -Config -ComputedAt`
- `Get-PlanPaths -PlanText`
- `Test-BlastRadius -Radius -PlanText -Config -TrackedFileCount` → array of finding hashtables (`rule`, `severity`, `subject`, `message`)
- `Test-BlastRadiusConflict -RadiusA -RadiusB -Config` → `@{ conflict = <bool>; reasons = @(@{ kind; detail }) }`

The PowerShell mirror exists because the Layer 1 enforcement hooks (F7) and the cohort-barrier hook are PowerShell (§9); `Test-BlastRadiusConflict` is what `enforce-parallel-cohort-barrier.ps1` will call. Header must carry the same "Python module remains the authoritative reference; never imports validator logic" statement as `ModelRouting.psm1`.

### 5.4 Consumer needs summary

| Consumer | Needs from F1 |
| --- | --- |
| F3 schema/validators | Stable `to_dict()` key set and enum values for `source`; the finding shape (`rule`/`severity`) for planner-state records; the `ConflictReason.kind` strings for `conflict_edges[].reason` (§12). These strings are contract literals — freeze them in `spec.md`. |
| F4 `parallel-planner` | `derive_blast_radius` + `validate_blast_radius` (V1/V2 Blocking gate, V3 Advisory report) + `conflicts` for cohort seeding. |
| F8 drift detection | `radius_from_observed_paths` (source `observed`) + `conflicts` recomputation against declared radii (§7 steps 1 and 4). |

## 6. Research Question 5 — Test Strategy

### 6.1 Unit tests

- Python: `tests/scripts/dev_tools/test_compute_blast_radius.py` plus per-helper files mirroring the module split (§7), under the mandated `tests/` mirror layout (`.claude/rules/general-unit-test.md` Test File Location).
- PowerShell: `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` (+ `BlastRadius.Parity.Tests.ps1`), matching the `tests/scripts/claude-lib/model-routing/` layout; run via `mcp__drm-copilot__run_poshqc_test` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; **append `.claude/lib/blast-radius/BlastRadius.psm1` (and any sibling module) to that file's `CodeCoverage.Path` list** with an issue-#447 comment, per the issue #312 precedent for `ModelRouting.psm1`. Note this edit itself touches a proposed shared surface — expected, and an early datum for §13.2 measurement.
- Coverage: >= 85% line / >= 75% branch in both languages (`.claude/rules/quality-tiers.md` uniform gates).
- Scenario matrix (from `issue.md` Test Conditions): each derivation stage; each of V1/V2/V3 positive and negative; each `conflicts` disjunct in isolation; fail-closed glob×glob undecidable case; empty radius; glob subsumption boundary; CRLF/CR/whitespace plan input; V3 threshold boundary (exactly at, just over).

### 6.2 Property-based tests

`compute_blast_radius.py` is a T1/T2-grade pure module, so property density rules apply (`.claude/rules/general-unit-test.md`). However, `hypothesis` is not an approved dependency (absent from `pyproject.toml`, unused in `tests/`; verified §1.7), and `.claude/rules/general-code-change.md` prohibits adding dependencies without explicit instruction. **Recommendation:** implement the property obligations as parametrized invariant tests, the established repository precedent (`test_compute_complexity_floor.py` proves determinism, order-independence, and clamp invariants with `pytest.mark.parametrize` over the live catalog, without hypothesis). Invariants to pin in both languages:

- Symmetry: `conflicts(a, b) == conflicts(b, a)` (verdict and reason multiset).
- Monotonicity: adding a path/module/surface/contract to either radius never turns a conflict into a non-conflict (fail-closed direction).
- Self-conflict: any radius with a non-empty level conflicts with itself.
- Determinism and input-order independence of derivation and validation.
- V1 self-consistency: a radius produced by `derive_blast_radius` from plan P always passes V1 against P.

Rejected alternative: adding `hypothesis` as a dev dependency. It is the letter of the test-policy text, but it requires a dependency approval F1 should not gate on; if the user grants approval during planning, the invariant tests above convert directly into hypothesis properties.

### 6.3 Cross-language parity design

Follow §1.2's pinning pattern, extended with a shared fixture corpus because the behavior under test is parsing, not a lookup table:

1. **Shared fixtures:** `tests/fixtures/blast_radius/*.json` (committed, read-only — satisfies the no-temp-files rule; precedent for committed JSON fixtures: `tests/fixtures/discovery_schemas/`). Each fixture carries `input` (`plan_text`, `spec_text`, `feature_folder`, `config`, `tracked_file_count`, optional `radius_a`/`radius_b`) and `expected` (`radius`, `findings`, `conflict` verdict + reasons). Include a CRLF fixture (literal `\r\n` inside the JSON string) and a glob-undecidable conflict fixture.
2. **Python side:** a parametrized test iterates every fixture file and asserts exact equality of derived radius dict, findings list, and conflict result.
3. **PowerShell side:** `BlastRadius.Parity.Tests.ps1` iterates the same fixture files (`Get-ChildItem` + `ConvertFrom-Json`) and asserts the same expected values, file-read-only, no external process — the same test discipline as `ModelRouting.Parity.Tests.ps1`.
4. **Config pinning:** both suites additionally load the committed `config/blast-radius.json` and assert shape constraints (every `modules` glob non-empty, `over_breadth_fraction` in (0, 1], `shared_surfaces` entries are repo-relative paths), so the two implementations and the config cannot drift — the F1 analogue of `test_floor_signal_names_match_config_floor_true_entries`.

Identical fixtures asserted identically in both languages is a strictly stronger parity proof than the model-routing constant-pinning alone, and is what the epic NFR ("identical inputs produce identical cohort assignments across Python and PowerShell implementations") requires at the radius layer.

### 6.4 Not in scope for tests

No integration with live `git`; `tracked_file_count` and observed paths are plain inputs. No test touches the network, temp files, or wall clock (`computed_at` is an input).

## 7. Research Question 6 — File-Size Budget

The docstring/comment policy (§1.7) plus the scope (data model, extraction, module/surface resolution, contract extraction, three validators, conflict relation) will not fit one 500-line Python file. Recommended split, following the `_orchestrator_state_*.py` facade-plus-helpers precedent (§1.6):

| File | Contents | Est. lines |
| --- | --- | --- |
| `scripts/dev_tools/compute_blast_radius.py` | Public facade: `BlastRadius`, `RadiusFinding`, `ConflictResult` dataclasses; `derive_blast_radius`, `radius_from_observed_paths`, `validate_blast_radius`, `conflicts`; re-exports | ~350–450 |
| `scripts/dev_tools/_blast_radius_extraction.py` | Line normalization, task/inline-code scanning, path/contract token rules, fnmatch subsumption helper | ~250–350 |

If the facade approaches 500 lines during implementation, move V1–V3 into `_blast_radius_validation.py` (third helper). PowerShell: target a single `.claude/lib/blast-radius/BlastRadius.psm1` (comment burden is lower; `ModelRouting.psm1` covers two formulas in 229 lines); the pre-planned split, if needed, is `BlastRadius.psm1` (facade: radius, validation, conflicts) + `BlastRadiusExtraction.psm1`, matching the `orchestrator-state` two-module precedent. Each PowerShell module added must also be added to the Pester `CodeCoverage.Path` list.

## 8. Behavior Semantics (success / failure / ordering / edges)

- **Derivation** never fails on well-formed text inputs; a plan with zero extractable paths yields a radius containing only the feature folder (V1 then has nothing to check; V3 cannot trigger). Malformed inputs (non-string, absent feature folder) raise specific exceptions / `throw` (fail fast per `.claude/rules/general-code-change.md`).
- **V1** emits one Blocking finding per uncovered concrete path; **V2** one Blocking finding per touched-but-unenumerated shared surface; **V3** at most one Advisory finding. Findings are sorted (rule, then subject) for deterministic output.
- **`conflicts`** returns all triggered reasons, not just the first, ordered `path_overlap`, `module_overlap`, `shared_surface_overlap`, `contract_dependency` — F3's `conflict_edges[].reason` and the epic auditability requirement need the full reason set.
- **Ordering rule everywhere:** collections are sorted and deduplicated at construction; both languages must sort by ordinal/invariant-culture string comparison to keep parity (PowerShell default sorting is culture-sensitive; use `[StringComparer]::Ordinal`).
- **Fail-closed edges:** undecidable glob×glob → overlap; a path matching a `shared_surface_globs` pattern is a shared surface even if not in the literal list; unknown `source` string rejected at construction.

## 9. Requirements Mapping (issue #447 acceptance criteria → design)

| Acceptance criterion (issue.md) | Resolution in this research |
| --- | --- |
| Python impl: four-level model, three sources, derivation, V1–V3, `conflicts` | §5.2 API; §4 heuristic; §8 semantics |
| PowerShell parity impl | §5.3; §6.3 |
| Config truth table enumerating §5.1 item 3 surfaces | §3, `config/blast-radius.json` |
| Cross-language parity test | §6.3 shared fixture corpus + config pinning |
| Fails closed; key-level partitioning out of scope | §5.2 conflict semantics; §8; constraint restated §Non-Negotiable |
| V1 Blocking / V2 Blocking / V3 Advisory | §5.2 `validate_blast_radius`; §8 |
| Module-resolution source resolved explicitly, deviation recorded in `spec.md` | §2 recommendation (b), deviation text supplied |
| Public API defined in `spec.md` as cross-module contract for F3/F4/F8 | §5 (transcribe into `spec.md` `## API / CLI Surface`) |
| Coverage >= 85% line / >= 75% branch | §6.1 (both languages; Pester coverage-path registration) |

New files: `scripts/dev_tools/compute_blast_radius.py`, `scripts/dev_tools/_blast_radius_extraction.py`, `.claude/lib/blast-radius/BlastRadius.psm1`, `config/blast-radius.json`, `tests/scripts/dev_tools/test_compute_blast_radius.py` (+ helper test files), `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1`, `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`, `tests/fixtures/blast_radius/*.json`. Modified file: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (coverage-path append only). No existing epic implementation is modified.

## 10. Automation Feasibility

Every F1 step is repository-local and achievable autonomously:

- All inputs are committed files (design doc, epic, plan contract, prior-art modules) — verified readable in this worktree.
- All outputs are new repo files plus one append-only settings edit; no external portals, credentials, tokens, or network services are involved. The GitHub issue (#447) already exists; no issue-creation step is in F1 scope.
- The full toolchain runs locally: `poetry run black/ruff/pyright/pytest` and the PoshQC MCP tools (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`).
- The only step that *could* require human interaction — approving a new `hypothesis` dev dependency — is avoided by the recommended parametrized-invariant approach (§6.2).

**Human interaction required: none.**

Evidence for the implementation phase (baselines, QA gates, coverage) must be written to `docs/features/active/2026-08-07-parallel-blast-radius-447/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`; `artifacts/` evidence sub-paths are forbidden.

## 11. Rejected Alternatives (summary)

- **Create `quality-tiers.yml` in F1** — rejected: entangles F1 with an absent CI `tier-classification` contract, a repo-wide classification exercise out of epic scope, and a YAML-parsing burden in PowerShell (§2 candidate (a)).
- **Truth table as a section of `config/orchestration-routing.json`** — rejected: byte-identical bundled-mirror obligation couples F1 to extension packaging (§3).
- **Add `hypothesis` dev dependency** — rejected for v1: dependency policy requires explicit instruction; parametrized invariant tests match repository precedent (§6.2).
- **Derivation ignore-list for read-only path references** — rejected: an under-reporting mechanism in a design whose dominant risk is under-reporting; over-breadth is the safe error and is V3's job (§4.3).
- **Runtime cross-process parity test (Python invoking PowerShell)** — rejected: no repository precedent; unit tests must not spawn external processes (`.claude/rules/powershell.md`, `.claude/rules/python.md`); shared fixtures give an equivalent or stronger guarantee (§6.3).
