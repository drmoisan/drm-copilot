# Code Review: Blast-radius write-intent extraction and conflict tolerance (#722)

**Review Date:** 2026-09-27
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722`
**Feature Folder Selection Rule:** The only active feature folder changed on the branch; its suffix matches issue 722 in the branch name.
**Base Branch:** `main` (merge base `beae3f021674e64fa6662097fe48a332d8da62b8`)
**Head Branch:** `bug/blast-radius-over-reports-and-zero-overlap-tolerance-722` (`a1c480ba678814da02c76a89a8fd2433ae7641d0`)
**Review Type:** Initial review

---

## Executive Summary

The branch implements the two layers of the spec in one plan. Part A adds a pure integration-cost scheduling function in Python (`scripts/dev_tools/_blast_radius_scheduling.py`) and PowerShell (`.claude/lib/blast-radius/BlastRadiusScheduling.psm1`) that calls the unchanged detection relation once per unordered pair and turns a detected conflict into an edge only when it is hard (shared surface or contract dependency) or its integer cost exceeds the configured share of the pairwise benefit. Drift recomputation now routes each in-flight peer pair through the same rule via a new helper (`scripts/dev_tools/_parallel_drift_scheduling.py`), and the drift module shrank from 499 to 460 lines. Part B adds write-intent extraction (rules W1-W6) in both runtimes behind the `write_intent_extraction` flag, with a single plan-path selector shared by derivation and validation. The TypeScript push-down carries the three new keys verbatim.

Evidence reviewed: the full branch diff, all new and modified production modules in both runtimes, the new tests, the rule-file amendment and its mirror, the PR-context artifacts regenerated at 18:24 for head `a1c480ba`, the executor evidence tree, the Python and TypeScript lcov files, and the PowerShell JaCoCo file. This review re-ran 340 targeted Python tests, 31 targeted Jest tests, black, ruff, and pyright, and confirmed `git hash-object` identity for all nine mirrored pairs. Implementation quality is high: the two runtimes are line-for-line parallel, every new function is pure, and both new layers fail closed.

**What changed:**
- Python: two new library modules and one new drift helper; `compute_blast_radius.py` re-exports the scheduling API and branches derivation and normalization on the flag; `_blast_radius_validation.py` uses the shared selector for V1/V2; `parallel_drift_detection.py` delegates the per-peer decision.
- PowerShell: two new modules exported through the facade (8 new exports, total 14); `Get-BlastRadius`, `Get-NormalizedDeclaredRadius`, and `Test-BlastRadius` gain the flag branch; `Test-BlastRadiusConflict` is byte-unchanged.
- TypeScript: `CARRIED_KEYS` and the emitted literal gain `conflict_tolerance`, `write_intent_extraction`, and `path_roots`.
- Configuration: both truth tables gain the three keys and the Copilot instructions mandate read; self-hosted `path_roots` equals the 17 tracked top-level directories; bundled `path_roots` is empty.
- Documentation: operator-approved amendment of `.claude/rules/parallel-orchestration.md` (spec design point 5) and its mirror; parallel-plan and parallel-add skills and the parallel-planner agent now call the scheduling entry point.

**Top 3 risks:**
1. Tolerated pairs rely on the existing per-item sync-with-main path to absorb real merge conflicts; the scheduling layer accepts that cost by design, and the committed tolerance (100) admits every non-hard pair whose cost does not exceed the benefit. Actual integration cost will be observed only in the next parallel runs (spec follow-up).
2. Write-intent extraction can drop a genuine write (six documented false-negative classes). In normalization, W1 removes every declared glob except the feature-folder glob, so a planner-appended genuine write survives only as a concrete path.
3. PowerShell repository-wide coverage and the Linux/Windows CI legs have not yet run (AC-38).

**PR readiness recommendation:** **Conditional Go** — no Blocker or Major finding; merge once the coordinator-owned CI gate (AC-38) is green.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/qa-gates/final-powershell-pester-coverage.2026-09-27T18-09.md` | Command line | The PowerShell post-change coverage file was written to the session scratchpad (`pester-final.xml`), not to `artifacts/pester/powershell-coverage.xml`, and the run was scoped to the four changed modules, so no repository-wide PowerShell percentage exists. Non-blocking. | Confirm the repository-wide figure from the CI Pester job; in future plans write coverage to the canonical path. | The canonical path is what later reviewers inspect; a scratchpad file is not durable. Every changed module is measured and above threshold, so the gap concerns reproducibility, not the result. | This review re-parsed the JaCoCo file: LINE 429 covered / 3 not covered; per-module 122/122, 102/102, 107/107, 98/101. |
| Minor | `tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py` | module level (`RADII`, `domain`) | The four exhaustive property tests do not assert that the domain contains conflicts, edges, tolerated overlaps, hard pairs, and edge-to-tolerated transitions. Non-vacuity was measured once by a scratch script only. A later edit to `RADII` could make monotonicity or symmetry hold vacuously without any test failing. Non-blocking. | Add one test that counts these classes over the domain for each truth table and asserts each count is at least 1. | Spec decision 11 relies on non-vacuity to justify replacing hypothesis; the guarantee should be enforced in code. | evidence/other/property-test-framework-deviation.2026-09-27T15-17.md (DISCRIMINATION lines from SCRATCH/prop-discrimination.py). |
| Minor | `scripts/dev_tools/_blast_radius_scheduling.py` and `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | `config_conflict_tolerance` lines 234-236; `Get-ConfigConflictTolerance` lines 162-170 | A JSON `null` value for `conflict_tolerance` reads as the strict (absent) semantics in both runtimes, although the spec's error-handling list rejects "a non-object conflict_tolerance". The same null-as-absent reading applies to `write_intent_extraction` and `path_roots`. The behavior is fail-closed and identical across runtimes, but it is not tested and not stated in the rule file. Non-blocking. | Either reject `null` with an error naming the key, or state the null-as-absent reading in the rule file and add one test per runtime. | Keeps the documented contract and the implementation aligned; a typo producing `null` currently disables tolerance silently. | Code inspection; `INVALID_SHAPES` in `test_blast_radius_scheduling.py` covers a list, not `null`. |
| Minor | `docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/spec.md` | header, line 6 | `Last Updated: 2026-09-27T19-30` was set by commit e88c9fbe at 16:27 and was still ahead of the clock at review time (18:28). Status remains `Draft` although all but the CI criterion are checked. Non-blocking. | Set `Last Updated` to the time of the last spec edit (the AC check-off commit) and update `Status`. | Future-dated metadata undermines the evidence-timestamp discipline the branch otherwise corrected (22 artifacts renamed in Phase 17). | `git log -S "Last Updated:** 2026-09-27T19-30"`; `date` at review. |
| Nit | `scripts/dev_tools/_blast_radius_scheduling.py` and `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | `schedule_conflict_edges`; `Get-BlastRadiusConflictEdge` | Item bands are validated only when a pair conflicts (inside `pair_benefit`), so an invalid band on an item that conflicts with nothing is accepted silently. | Validate every item band once in `_ordered_items` / `Get-OrderedSchedulingItem`. | Fail-fast at the boundary; the planner records bands for every item. | Code inspection. |
| Nit | `scripts/dev_tools/_blast_radius_write_intent.py` and `.claude/lib/blast-radius/BlastRadiusWriteIntent.psm1` | `_WRITE_VERB_RE`; `$script:WriteVerbPattern` | The W3 write-verb override matches whole words only, so an inflected verb ("Verify updates", "Review and fixes") does not override the read verb and the window's tokens are dropped. This is within documented false-negative class 4, but the rule text does not mention inflection. | Document that inflected forms do not override, or add inflected forms to both pinned vocabularies together. | Reduces surprise for plan authors. | Code inspection of both regexes. |
| Nit | `scripts/dev_tools/_blast_radius_scheduling.py` | `__all__` (lines 55-70) | `BAND_NAMES` and `WEIGHT_NAMES` are imported by `_parallel_drift_scheduling.py` but are not in `__all__`. | Add them to `__all__`. | Keeps the declared public surface complete. | `from scripts.dev_tools._blast_radius_scheduling import BAND_NAMES, decide_pair`. |
| Info | `scripts/dev_tools/_blast_radius_scheduling.py` and `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | `decide_pair` lines 354-358; `Get-BlastRadiusPairDecision` line 398 | The edge rule adds an explicit `tolerance_percent == 0` term to the spec's inequality. Given validated weights of at least 1 it is equivalent to the spec formula for the real relation, and it keeps strict identity for an injected relation whose reasons the cost enumeration cannot reproduce. Both runtimes carry it. | None required. | Strengthens the fail-closed guarantee without changing any verdict. | Code inspection; property `test_property_tolerance_zero_equals_conflict`. |
| Info | `scripts/dev_tools/compute_blast_radius.py`, `.claude/lib/blast-radius/BlastRadius.psm1` | normalization flag branch | In write-intent mode, normalization applies W1 to recorded radii, removing every glob other than the feature-folder glob. The rule file's mitigation 1 says the planner appends the "exact path", which is consistent, but it does not state that an appended glob will be removed by a later normalization. | Add one sentence to the rule file: appended genuine writes must be concrete paths. | Prevents a planner from appending a directory glob that normalization then discards. | `test_normalization_keeps_feature_folder_glob_in_write_intent_mode` shows `src/**/*.py` removed. |
| Info | `tests/scripts/dev_tools/test_blast_radius_mandate_reads.py`, `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` | committed-config helpers | Spec decision 10: the helpers remove `write_intent_extraction` and `path_roots` so these modules keep testing current-extraction semantics. The edit is scoped (two `pop` calls), no assertion changed, and neither module asserts on the key set. Judged sound. | None. | Write-intent semantics are covered by the dedicated write-intent tests and fixtures. | Diff inspection; grep for key-set assertions returned nothing. |
| Info | `tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py` | module docstring | Spec decision 11: hypothesis is not a project dependency (no entry in `pyproject.toml`) and existing property suites state it stays absent; a seeded RNG would require an unauthorized S311 suppression. Exhaustive enumeration over 13,689 decisions per truth table checks every domain point. Judged sound, subject to the Minor non-vacuity finding above. | None beyond the Minor finding. | Enumeration is at least as strong as sampling over the same domain. | `grep hypothesis pyproject.toml` returned nothing. |
| Info | `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` | Exported facade surface | Spec decision 12: the exact-count assertion was kept and raised from 6 to 14, and each new name is asserted individually. Judged sound; the test was not weakened. | None. | The facade surface remains pinned exactly. | Diff inspection. |
| Info | `tests/scripts/dev_tools/test_blast_radius_historical_runs.py` | `test_before_cohorts_match_pins` | Spec decision 13: cohort coloring is asserted in Python only, because PowerShell has no coloring function and the destination colors with the bash entry point. The PowerShell tests assert the edge sets that feed coloring. Judged sound. | None. | Coloring is a pure function of the edge set, which is asserted equal in both runtimes. | Pester file header and tests. |
| Info | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | Known local-only failure (issue #510, KL-510): the test enumerates gitignored `.claude/state/` files. Not a defect of this branch. The byte identity it protects was confirmed with `git hash-object` for all nine mirrored pairs. | Confirm green in CI. | CI checkouts carry no `.claude/state/`. | evidence/qa-gates/final-python-pytest-coverage.2026-09-27T18-03.md (case (b) message). |
| Info | `docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/spec.md` | Scope & Non-Goals, recorded follow-up | The spec assigns filing a potential entry for noisy spec contract tokens to the review phase. This reviewer does not write lifecycle entries. | Coordinator to file the potential entry. | Keeps the recorded follow-up from being lost. | Spec "Recorded follow-up, not implemented here". |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `decide_pair` reads the tolerance before calling the relation, calls the relation exactly once, and derives hard, cost, and benefit only for a detected conflict, so a non-conflicting pair cannot become an edge; the property tests confirm edge implies conflict, tolerance 0 equals conflict, monotonicity, and symmetry.
- Cost enumeration reuses `_entries_overlap`, `exclude_mergeable_paths`, and `matches_mergeable_path`, so no overlap semantics are redefined.
- The write-intent extractor iterates the same spans the current extractor harvests and applies the current classifier first, so every rule can only remove a token. Verified by reading `extract_plan_paths` (task, phase, and prose lines are all scanned; the task and phase prefixes carry no inline code) and `extract_contract_identifiers` (the write-intent contract walk adds only the W1 and W2 filters). Normalization applies a filter over already-accepted entries. Contention therefore cannot widen through extraction.
- `select_plan_paths` is the single selector for derivation and V1/V2, so a derived radius passes validation against its own plan in both modes.
- Drift keeps its fail-closed handling: an unevaluable peer radius is an edge before the relation runs.

#### Typing and API notes

- Frozen dataclasses throughout; `ConflictTolerance` wraps both maps in `MappingProxyType`. Keyword-only optional parameters. `ConflictRelation` is typed as a `Callable` alias under `TYPE_CHECKING`. Pyright reports 0 errors.

#### Error handling and logging

- Readers raise `TypeError`/`ValueError` with messages naming the key; booleans are rejected where integers are required; `_require_names` reports missing and unknown names in one message. No logging in pure library code, consistent with the existing modules.

### TypeScript implementation audit

#### What changed well

- The three keys are appended to `CARRIED_KEYS` (preserving positional indices) and placed before `modules` in the emitted literal; absent keys emit no property because `JSON.stringify` drops `undefined`.

#### Type safety and maintainability

- No `any` or suppression added. The doc comments were updated to the new emission order.

#### Error handling and logging

- No new boundary; the source document is parsed by the existing `parseSourceDocument`.

### PowerShell implementation audit

#### What changed well

- `BlastRadiusScheduling.psm1` and `BlastRadiusWriteIntent.psm1` mirror the Python modules function by function, with the same constants, the same explicit tolerance-0 term, ordinal comparisons, and the same null-as-absent reader semantics. The three vocabularies are pinned equal to the Python constants by parity tests in both directions.
- `Test-BlastRadiusConflict` is resolved at call time with `Get-Command`, avoiding a circular import with the facade, and a missing command fails fast naming the facade (tested).
- `Test-BlastRadiusConflict` itself is unchanged (no diff hunk touches it; executor function-body comparison printed `BODY-EQUAL=True`).

#### API and safety notes

- Advanced functions with `[OutputType()]`; approved verbs; `Set-StrictMode -Version Latest`; `$ErrorActionPreference = 'Stop'`; sibling imports with `-ErrorAction Stop`. The facade exports exactly 14 functions.

#### Error handling and logging

- Readers `throw` with the key name; integer checks reject `[bool]` explicitly to match Python.

---

## Test Quality Audit

Automated evidence is complete for the local toolchain in all three languages. CI is pending.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_blast_radius_scheduling.py` and `BlastRadiusScheduling.Tests.ps1` — one named test per edge-rule term in each runtime, 14 reader rejections, fixture reproduction, strict identity over every existing conflict fixture, ordering, symmetry.
- `tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py` — four properties by exhaustive enumeration; see the Minor non-vacuity finding.
- `tests/scripts/dev_tools/test_blast_radius_write_intent.py` and `BlastRadiusWriteIntent.Tests.ps1` — W1-W6, shared-surface read citation, flag absent and false identity, V1/V2 self-consistency, vocabulary parity, never-adds-a-token property, eight fixtures, reader rejections.
- `tests/scripts/dev_tools/test_blast_radius_historical_runs.py` and `BlastRadius.HistoricalRuns.Tests.ps1` — BEFORE and AFTER pins from committed fixtures only; `test_after_edges_are_subset_of_before_edges`.
- `tests/scripts/dev_tools/test_parallel_drift_scheduling.py` — within-tolerance, becomes-hard, exceeds-tolerance, tolerance-0 identity, fail-closed, injected relation.
- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts` — verbatim carriage and omission for each key.
- `docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/evidence/qa-gates/historical-before-after-summary.2026-09-27T17-38.md` — BEFORE/AFTER edges, cohorts, and maximum width for three runs, including plan-text AFTER values for W2, W3, and W5 (followups-2026-09-27: 46/8/2 before, 15/5/4 after).

### Quality assessment prompts

- **Determinism:** No RNG, clock, subprocess, network, or temporary file in changed tests; fixtures are committed; `origin/...` appears only as recorded data.
- **Isolation:** Each test targets one term or rule; fixtures embed their own truth tables and radii (the #452 scheduling fixtures embed radii, so the tests are merge-order independent).
- **Speed:** 340 targeted Python tests in 9.42 s.
- **Diagnostics:** Assertions carry the failing domain point or the run name (`-Because $Run`).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; configuration contains only path lists and integers. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess in new code; PowerShell uses `Get-Command` plus call operator on a fixed command name. |
| Input validation at boundaries | ✅ PASS | Strict readers for all new keys; item-key validation. See Minor finding on `null` and Nit on band validation. |
| Error handling remains explicit | ✅ PASS | Specific exceptions; fail-closed drift handling retained. |
| Configuration / path handling is safe | ✅ PASS | Absent keys fail closed; bundled `path_roots` empty; self-hosted `path_roots` equals `git ls-tree -d --name-only HEAD`. |
| Detection relation unchanged | ✅ PASS | No diff for `_blast_radius_conflicts.py`, `_blast_radius_glob.py`, `_blast_radius_mergeable.py`, `BlastRadiusConflict.psm1`; no hunk in `Test-BlastRadiusConflict`. |
| Mirror parity | ✅ PASS | `git hash-object` equal for rule file, four modules, two skills, agent, and runsettings pairs. |
| Policy files | ✅ PASS | Only `.claude/rules/parallel-orchestration.md` (operator-approved, design point 5) and its mirror changed; no `.github/instructions/` file changed. |

---

## Research Log

No external research was required. All conclusions derive from the repository diff, the executor evidence, and the commands listed in the policy audit's Appendix B.

---

## Verdict

The change is ready for normal PR flow once the coordinator-owned CI gate (AC-38) is green. The scheduling and write-intent layers are pure, parallel across Python and PowerShell, and fail closed; the detection relation is untouched; tolerance 0 and an absent key reproduce the previous edge set exactly; and write-intent extraction can only remove tokens. Coverage exceeds thresholds on every new and changed file in all three languages.

No finding is blocking. The four Minor findings (PowerShell coverage artifact location and scope, property-test non-vacuity not asserted in code, null-as-absent reader semantics, future-dated spec metadata) and the Nits can be addressed in a follow-up or before merge at the coordinator's discretion.
