# Feature Audit: Blast-Radius False Conflict Edges (Issue #489)

**Audit Date:** 2026-08-18
**Auditor:** feature-review agent

## Scope and Baseline

- **Base branch (resolved):** `main`
- **Merge-base SHA:** `455d07ec6637c49d9bbb34ccaf7ec42efa6d136b`
- **Head SHA:** `66261af434234202a45cfdce1f4d06682dab4fa8`
- **Branch:** `bug/blast-radius-false-conflict-edges-489`
- **Diff scope:** full branch vs base — 67 files, +6311/-601, spanning Python, PowerShell, TypeScript, JSON, Markdown
- **PR context:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, both fresh (head SHA `66261af4` present in both; regenerated against base `main`)
- **Work mode:** `full-bug` (persisted marker in `issue.md`); `spec.md` is the sole acceptance-criteria source and `user-story.md` is correctly absent
- **AC source:** `docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/spec.md`, section `## Acceptance Criteria`, 31 criteria in groups A-H

Every criterion below was re-verified independently by this audit (command execution, diff inspection, artifact re-parsing, or adversarial probing), not accepted from the executor's report.

## Acceptance Criteria Inventory

| Group | Criteria | Subject |
| --- | --- | --- |
| A | AC-A1..AC-A4 | Config content (`config/blast-radius.json`) |
| B | AC-B1..AC-B8 | Extraction rules and normalization (Python) |
| C | AC-C1..AC-C3 | PowerShell parity |
| D | AC-D1..AC-D2 | TypeScript push-down carriage |
| E | AC-E1..AC-E5 | Empirical demonstration (required outcome) |
| F | AC-F1..AC-F4 | Test pins moved in the same commit |
| G | AC-G1..AC-G2 | Prose and doctrine |
| H | AC-H1..AC-H3 | Quality gates |

Total: 31 criteria.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence (re-verified by this audit) |
| --- | --- | --- |
| AC-A1 | PASS | Read `config/blast-radius.json`: `mandate_reads` present with exactly the six ratified members (committed in sorted order; membership identical as a set). |
| AC-A2 | PASS | `modules` map carries exactly `mcp-server`, `benchmarks`, `poshqc`, `powershell-dev-tools`, `codex-runtime`, `config`, `schemas`; none of the five umbrella entries present. |
| AC-A3 | PASS | `quality-tiers.yml` appears in both `shared_surfaces` and `mandate_reads` in the committed file. |
| AC-A4 | PASS | `config_mandate_reads` exists in `_blast_radius_validation.py` beside `config_root_surfaces`; `test_config_mandate_reads_absent_key_yields_an_empty_tuple` and `test_derive_with_an_absent_key_matches_an_empty_mandate_read_list` pass; this audit's mutant probe (key deleted from the shipped config) reproduced pre-fix behavior exactly (K3 triangle), empirically confirming the absent-key default. |
| AC-B1 | PASS | `derive_blast_radius` applies `exclude_mandate_reads` before adding the feature-folder glob (diff inspected); `test_derive_excludes_mandate_read_citations_from_every_level` and `test_derive_without_the_mandate_reads_key_includes_the_citations` pass. |
| AC-B2 | PASS | `classify_path_token` rejects wildcard-free extensionless tokens (diff inspected); parametrized rejection tests over `extensions/drm-copilot`, `scripts/dev_tools`, `docs/features`, `.claude/rules/` pass; `scripts/dev_tools/**` and `.claude/rules/python.md:90` admission pinned in both runtimes. |
| AC-B3 | PASS | `artifacts/` absent from `KNOWN_TOP_LEVEL_SEGMENTS` (diff inspected); `test_derive_excludes_an_artifacts_path_through_the_subtree_glob` passes; Pester `rejects the artifacts subtree glob` passes. |
| AC-B4 | PASS | `spans_multiple_feature_folders` rejects `docs/features/**/plan*.md`, `docs/features/active/*/plan.md`, `docs/features/**`; own-folder glob retained. Tests pass in both runtimes. |
| AC-B5 | PASS | `CONTRACT_LETTER_RE` filter in `extract_contract_identifiers`; `->` rejection and letter-bearing retention pinned in both runtimes (4 parametrized letterless cases). |
| AC-B6 | PASS | `normalize_declared_radius` exists on `compute_blast_radius.py` (in `__all__`), pure (no input mutation, pinned), idempotent (pinned), fails fast with `ValueError` on `source == "observed"` (pinned in both runtimes). |
| AC-B7 | PASS | `git diff 455d07ec..66261af4` over the four named files is empty (verified directly). |
| AC-B8 | PASS | The `compute_blast_radius.py` diff contains no `RADIUS_KEYS` or `from_dict` edit; existing validator test suites pass unmodified in the full-suite re-run (3938 passed); the fixture radii load through `from_dict` at their recorded cardinalities. |
| AC-C1 | PASS | Extraction and normalization mirrored in the three named modules; `BlastRadiusGlob.psm1` zero diff; `BlastRadiusValidation.psm1`'s 12-line diff is confined to plan-side extraction filtering (the V1 self-consistency mirror of the Python validation change) — its comparison logic (V1/V2/V3 rules) is untouched, satisfying the AC's operative clause. Pester suite green (377/377 in scope re-run). |
| AC-C2 | PASS | All five byte-copies compare byte-identical (`cmp`) at head; commits `b0277bdb` and `66261af4` each touched sources and byte-copies together (per-commit `--name-only` verified). |
| AC-C3 | PASS | Six new fixtures added to `tests/fixtures/blast_radius/` (derivation-artifacts-segment-removed, derivation-cross-corpus-doc-glob-rejected, derivation-directory-shaped-rejected, derivation-letterless-contract-rejected, derivation-mandate-read-excluded, validation-mandate-read-self-consistent); on-disk top-level count 32 >= 26; `test_blast_radius_parity.py` (auto-discovering glob, floor 26) passes in the full run; `BlastRadius.Parity.Tests.ps1` passes under Pester. |
| AC-D1 | PASS | `CARRIED_KEYS` extended with `mandate_reads` (appended, position documented), assembly emits it between `shared_surface_globs` and `modules`, emission-order doc updated; Jest asserts verbatim carriage, emission position, and omission-when-absent (60/60 targeted tests re-run green). |
| AC-D2 | PASS | Bundled base document carries `mandate_reads`; grep of the branch diff shows no byte-identity assertion between the two configs (the TruthTable test reads both copies but asserts only the location-bucket pin against the bundled copy). |
| AC-E1 | PASS | `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json` committed (tracked, 712 lines); `test_fixture_radii_load_at_recorded_sizes` pins 485=(184,6,1,40), 486=(125,3,2,45), 487=(140,4,1,10) through `BlastRadius.from_dict` — re-run green. |
| AC-E2 | PASS | Before-state pin re-run green: edges `[(485, 486), (485, 487), (486, 487)]`, cohorts `[[485], [486], [487]]`, computed against the fixture-embedded pre-fix config so the pin cannot drift with the repository config. |
| AC-E3 | PASS | After-state re-run green: edges exactly `[(486, 487)]` with the surviving overlap detail `extensions/drm-copilot/src/mcp-tools.ts`, cohorts `[[485, 486], [487]]`, computed against the shipping `config/blast-radius.json`. This audit's four-variant probe confirmed both fix halves are load-bearing. |
| AC-E4 | PASS | `BlastRadius.Parity.Tests.ps1` carries the matching before/after Describe (K3 `485-486, 485-487, 486-487`; after `486-487`; surviving-overlap detail) and passes under Pester (scoped run 377/377). |
| AC-E5 | PASS | Evidence committed under `evidence/regression-testing/` (before-state-pin, verification-integrity-before-after); branch diff contains zero `artifacts/`-rooted paths (verified by `git diff --name-only` grep). |
| AC-F1 | PASS | `test_items_sharing_a_benchmarks_file_contend_on_path_and_module` rewritten against the retained `benchmarks` module; both the `path_overlap` and `module_overlap` assertions preserved (stronger than the permitted clause-drop), plus module resolution asserted on both sides. Moved in commit `40db8ecc`, the same commit as the config change. Passes. |
| AC-F2 | PASS | The non-empty-module-map test and the `config`-module pin are absent from the branch diff (unmodified) and pass in the re-run of `test_blast_radius_config.py`. |
| AC-F3 | PARTIAL | The relocated/amended Pester blocks pass under Pester at head, and no behavior-matrix case names a removed module — but the same-commit clause is not met: the config changed in `40db8ecc` while the Pester amendments (including the breaking `$pairs.Count | Should -Be 12` pin at `BlastRadiusConfig.Tests.ps1:434`) landed in `b0277bdb`, three commits later. Verified: at `40db8ecc` the committed config resolves 7 modules while the pin still demands 12, so commits `40db8ecc` and `a25fc63f` are transiently Pester-red. The Python pin did move same-commit. No forward fix exists short of rewriting pushed history; recommended disposition is operator ratification. AC-F3 unchecked in `spec.md`. |
| AC-F4 | PASS | `test_parallel_planner_surface_contracts_landed.py` is absent from the branch diff (unmodified) and passes in the re-run; the amended skill retains the literal `conflicts(a, b, config)`. |
| AC-G1 | PASS | The F1a paragraph now reads "do not narrow a radius beyond the configured exclusions in order to suppress a conflict edge" and adds the planner obligation to append an excluded path the diff will genuinely write; the planner procedure step 1 now calls `normalize_declared_radius(radius, config)`. Diff read directly. |
| AC-G2 | PASS | `## Blast-Radius Contention Doctrine (issue #489)` added to `.claude/rules/parallel-orchestration.md` covering the mandate-read classification (with the three bounding constraints) and the module-map granularity criterion; bundled mirror updated in the same commit (`008e970c`, verified per-commit) and byte-identical at head; no schema file in the diff; all `mix-calculator` occurrences in the diff are prose restatements of the prohibition. |
| AC-H1 | PASS | Re-run by this audit at head: black --check, ruff, pyright (0/0/0), pytest (3938 passed), prettier --check, eslint, tsc --noEmit, targeted Jest (60 passed), scoped Pester (377 passed) — all clean in a single pass. Executor evidence records the full loop with two documented restarts and final clean passes under `evidence/qa-gates/`. |
| AC-H2 | PASS | Re-derived from coverage artifacts, not from the evidence tables: Python changed modules 100% lines / 100% branches (312/312, 106/106 from `artifacts/python/lcov.info`); PowerShell blast-radius modules 100% except `BlastRadiusValidation.psm1` at 96.97% (from `artifacts/pester/powershell-coverage.xml`, all six modules present); TypeScript `claude-blast-radius-derive-core.ts` 452/452 lines, 47/49 = 95.92% branches (from `extensions/drm-copilot/coverage/lcov.info`). All above line >= 85% / branch >= 75%; PowerShell branch threshold exempt per `.claude/rules/quality-tiers.md`. |
| AC-H3 | PASS | Every test edit in the branch diff was reviewed against base: no assertion removed without relocation, no exception matcher broadened, count pins updated only for real contract changes with new negative pins added. Grep of all new/changed test files for temp-file and banned-API patterns returned zero hits; all new test inputs are committed fixtures. |

## Summary

- **30 of 31 acceptance criteria PASS; 1 PARTIAL (AC-F3, same-commit clause only).**
- The required outcome is delivered and reproducible from committed data: the `verification-integrity` conflict graph reduces from the K3 triangle to the single genuine edge (486, 487), and recoloring yields `[[485, 486], [487]]` — re-executed by this audit from the committed fixture, with adversarial probes confirming both fix halves (normalization and config content) are individually load-bearing and the fail-closed absent-key default holds.
- All frozen surfaces are byte-identical to `main`; the radius shape is unchanged; mirrors, registrations, and coverage thresholds are all verified.
- The AC-F3 gap is a commit-pairing hygiene property of pushed history with no head-state impact and no forward fix; it is documented in the policy audit (section 8, gap 1) and the code review (Minor finding 1) with a recommended disposition of operator ratification. It is not classified as a Blocking finding, so no remediation-inputs artifact was produced.
- Declared deviations 1-3 (Describe placement, umbrella-pin scope, import order) were each assessed and accepted with evidence (see policy audit section 8).
- Process defects (the preflight-scope violation commit `1c662c49` and the deliberate B13 carriage) are recorded in the policy audit; the committed work from the violating commit was independently re-verified as correct, and the B13 handling included a worktree-resolved coverage run whose output this audit re-parsed.

**Go/no-go:** GO — ready for PR, conditional on operator ratification of the AC-F3 same-commit gap.

## Acceptance Criteria Check-off

Per `acceptance-criteria-tracking`: all 31 criteria were already checked `[x]` by the executor in `spec.md`. This audit evaluated 30 as PASS (check-off retained) and AC-F3 as PARTIAL. Consistent with the check-off protocol (PARTIAL items must remain unchecked with the gap documented), this audit **unchecked AC-F3** in `spec.md`; the criterion text was not modified.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/spec.md`
- Total AC items: 31
- Checked off (delivered): 30
- Remaining (unchecked): 1
- Items remaining: AC-F3 (Pester test-pin amendments landed in `b0277bdb` rather than in the config-change commit `40db8ecc`; head-state green; recommended disposition: operator ratification)
