# Feature Audit: Blast-radius placeholder-token rejection (#502)

**Audit Date:** 2026-08-23
**Feature Folder:** `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502`
**Base Branch:** `main` @ `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`
**Head Branch:** `bug/get-plan-paths-angle-bracket-placeholders-502` @ `e3cc1f76ae6a79e3c986be668f83c1cd4c4b0e66`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`)
- **Head branch/commit:** `bug/get-plan-paths-angle-bracket-placeholders-502` (commit `e3cc1f76ae6a79e3c986be668f83c1cd4c4b0e66`)
- **Merge base:** `d782ee1c8b05192ed1bda40936ba5e37d9a5512e` — equal to the `main` tip, so the branch is rebased and current and the diff is the complete feature-vs-base delta
- **Diff:** 75 files changed, 11203 insertions, 190 deletions; 20 non-documentation files
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (refreshed 2026-08-23T11:01, base and head resolve to the two SHAs above)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (same refresh)
  - Feature evidence: 47 artifacts under `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/**`
  - Canonical coverage artifacts: `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`
  - Reviewer-executed commands, recorded in Appendix B of `policy-audit.2026-08-23T11-12.md`
- **Feature folder used:** the folder above. Selected because its `-502` suffix matches the issue number in the branch name, and it is the only active feature folder whose scoping documents changed in this diff.
- **Requirements source:** `spec.md` only.
- **Work mode resolution note:** The marker `- Work Mode: full-bug` is present and well-formed at line 13 of `issue.md`. Under the `acceptance-criteria-tracking` mode table, `full-bug` resolves the acceptance-criteria source to `spec.md` alone. `user-story.md` does not exist in this folder and its absence is correct for this mode, not a gap. No fail-closed fallback was needed.
- **Scope note:** The audit covers the full branch diff `d782ee1c..e3cc1f76`. No caller instruction narrowed scope; see the `## Rejected Scope Narrowing` section of `policy-audit.2026-08-23T11-12.md`, which records that no narrowing was attempted. Two acceptance criteria carried recorded dispositions from execution (AC-8 withdrawn, AC-36 partial) and both were re-evaluated independently rather than carried forward.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md` — only source (work mode `full-bug`)

The `## Acceptance Criteria` section contains 41 numbered checkbox criteria, AC-1 through AC-41, grouped into seven lettered subsections, followed by an 11-row `### Traceability to issue.md` table. The four impact/severity radios and the one logs-attached checkbox in `issue.md` sit outside any acceptance-criteria section and are not criteria; they are not evaluated here.

### Acceptance criteria (transcribed from the source; wording preserved)

**A. Marker rejection in both runtimes, paired per runtime**

1. **AC-1** `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` contains a parametrized test over all five marker probes asserting the placeholder predicate reports each as marker-bearing; `poetry run pytest tests/scripts/dev_tools/test_blast_radius_token_shapes.py` passes.
2. **AC-2** `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` contains a parametrized test asserting the classifier yields no classification for each of the same five probes — the paired classifier-level assertion for the Python runtime.
3. **AC-3** `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` contains, for each of the five probes, a paired assertion: the predicate reports the token as marker-bearing **and** `Get-PathTokenKind` returns no classification for it.
4. **AC-4** Every probe string in that Pester file is single-quoted or built by character concatenation, each case asserts the probe's literal content before classification, and the single-quote constraint is stated as a comment inside the file.
5. **AC-5** A marker in the filename position is rejected in both runtimes, asserted by a named test in each.
6. **AC-6** The empty string, a marker-only token, and a bare bracket pair are handled without raising in both runtimes, asserted by a named test in each.

**B. Real-path acceptance preserved (negative controls)**

7. **AC-7** A real path cited on the **same** plan task line as a rejected placeholder is still harvested, asserted in both runtimes by a named test and by `tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json`.
8. **AC-8** `tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json` exists; two radii whose only shared entry is a placeholder token with disjoint real files report conflict false in both parity suites.
9. **AC-9** Two items sharing a real file still conflict on `path_overlap`, asserted by a fixture with expected conflict true, and the planner's decision to add `conflict-real-path-overlap-preserved.json` or to reuse the existing `tests/fixtures/blast_radius/conflict-path-overlap.json` is recorded explicitly in the plan.
10. **AC-10** All 32 pre-existing fixtures under `tests/fixtures/blast_radius/` produce unchanged expected results in both parity suites, with no fixture edited to accommodate the change.
11. **AC-11** A named test asserts the normalization entry point strips a placeholder entry from an already-recorded radius while preserving its real entries and re-resolving `modules` and `shared_surfaces`.
12. **AC-12** `tests/fixtures/blast_radius/validation-placeholder-self-consistent.json` exists and a radius derived from a placeholder-citing plan validates clean against that same plan, with an empty findings list, in both parity suites.
13. **AC-13** A named test pins the fail-open trade: a placeholder-bearing token whose shape matches a configured shared-surface glob is dropped and is no longer reported as a touched shared surface, with a docstring recording the trade and citing the planner's explicit-enumeration obligation.

**C. Corpus measurement, before and after, with positive control**

14. **AC-14** A baseline artifact under the feature folder's `evidence/baseline/` records the executed, single-quoted five-marker probe results for **both** runtimes pre-fix.
15. **AC-15** One evidence artifact under that folder's `evidence/qa-gates/` directory records, before and after: item count (asserted non-zero), edge count, density to one decimal place, cohort count, and maximum cohort width, over the 58 top-level plans with a constant derivation timestamp.
16. **AC-16** The same artifact records the total `paths`-entry count before and after and the exact set difference, and asserts that **every** dropped entry contains a marker character. A marker-free drop fails this criterion.
17. **AC-17** The same artifact records the named-survivor assertion result for a fixed list containing at least one path per acceptance rule: a recognized-extension file, a line-suffixed citation, a known-segment subtree glob, a configured root surface, and an own-feature-folder documentation glob. All must survive.
18. **AC-18** The same artifact records that the known-genuine 486-487 edge survives with its reason unchanged.
19. **AC-19** The numeric edge-count delta prediction is recorded in the plan **before** the after-measurement is run, and the artifact reports prediction against actual, with any deviation explained rather than absorbed.
20. **AC-20** The artifact reports that the nine-item clique on the mandated evidence-path token is gone, and that any surviving edge among those nine pairs is attributable to a shared real path.

**D. Parity fixtures and corpus-floor counters**

21. **AC-21** Every new fixture carries the same input/expected shape as the existing directory-shaped-rejection fixture and is asserted by **both** `tests/scripts/dev_tools/test_blast_radius_parity.py` and `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`.
22. **AC-22** `MINIMUM_FIXTURE_COUNT` in `tests/scripts/dev_tools/test_blast_radius_parity.py` and `$minimumFixtureCount` in `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` are both raised from 26 to 26 plus the number of newly added fixtures, and are equal to each other.
23. **AC-23** Both parity suites pass with byte-comparable radius, findings, conflict verdict, and conflict-reason results across the whole corpus, and the three non-vacuity tests in each suite still pass.

**E. Byte-mirror parity and registration surfaces**

24. **AC-24** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes, confirming a byte-identical bundled mirror for **every** new or changed file under `.claude/`.
25. **AC-25** `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the new bundled module; the manifest Pester suite and the pack-manifest-completeness Jest suite both pass.
26. **AC-26** The new module appears in the `CodeCoverage.Path` allow-list in **both** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes.
27. **AC-27** No coverage `exclude` entry matching a production source path is added anywhere, and both new production modules appear in their runtime's coverage denominator.
28. **AC-28** This item's declared blast radius enumerates `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` in `shared_surfaces`, and blast-radius validation reports no V2 Blocking finding.

**F. Rule-file prose amendment**

29. **AC-29** `.claude/rules/parallel-orchestration.md` states **four** rejected token shapes, names the fourth as a placeholder or interpolation marker, states the marker set explicitly, and cross-references `.claude/rules/plan-acceptance-gates.md` as the set's origin.
30. **AC-30** The same amendment records: the never-matches-a-tracked-path rationale including the Windows-reserved-character argument; the mandated-artifact origin of the dominant token; the planner obligation to append a concrete path when an item really writes one; the fail-open trade with its measured-empty exposure; and the whitespace-split residual as a known residual.
31. **AC-31** The amendment introduces no JSON Schema file and no schema reference; enforcement remains prose plus validator logic.
32. **AC-32** `git diff` shows `.claude/rules/plan-acceptance-gates.md` and every file under `.github/` unmodified.

**G. Structural limits, toolchain, and scope containment**

33. **AC-33** After the change, `scripts/dev_tools/_blast_radius_extraction.py`, `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, and both new modules are each at or under 500 lines, verified by a line count over each file.
34. **AC-34** The relocated feature-corpus-span predicate remains exported from `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, verified by a module-export assertion or an existing consumer test.
35. **AC-35** The Python toolchain completes in a single pass with no failure and no auto-fix: `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Line coverage >= 85% and branch coverage >= 75%, with no regression on changed lines.
36. **AC-36** The PowerShell toolchain completes in a single pass: format, analyze, test with coverage. Line coverage >= 85%, with the new module measured.
37. **AC-37** The TypeScript suites pass, confirming the change is a no-op for that runtime.
38. **AC-38** No signature, return type, artifact type, CLI flag, MCP input-schema property, finding-rule literal, or `config/blast-radius.json` key is added or changed, verified by inspecting the diff.
39. **AC-39** No diagnostic, warning, or advisory finding is emitted for a rejected token, verified by the absence of any new finding rule in the diff and by the unchanged expected-findings blocks of all pre-existing fixtures.
40. **AC-40** The repro from the Repro & Evidence section reports conflict false post-fix in both runtimes, recorded in the QA-gate evidence artifact.
41. **AC-41** The issue #500 rule-file sequencing decision is recorded in the plan: either the two items are sequenced, or the single `path_overlap` edge on the rule file is declared and accepted.

### Traceability to `issue.md` (11 rows, also evaluated)

The spec's traceability table maps each `issue.md` obligation to the numbered criteria that cover it, under the header assertion "No criterion from `issue.md` is dropped, weakened, or reinterpreted."

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| AC-1 | Parametrized predicate test over all five markers | PASS | `test_blast_radius_token_shapes.py:34-43`, `MARKER_PROBES` with five `pytest.param` entries and stable ids | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_token_shapes.py` | One marker per probe, so a failure names the marker that regressed rather than "markers" |
| AC-2 | Paired classifier-level assertion, Python | PASS | `test_blast_radius_extraction_rules.py`, `test_classify_path_token_rejects_placeholder_marker` over `PLACEHOLDER_MARKER_PROBES` (5 params) | included in the 152-test targeted run, 0 failures | The probe comment records why the two angle probes are deliberately not a matched pair |
| AC-3 | Paired predicate-and-classifier assertion per probe, PowerShell | PASS | `BlastRadiusTokenShape.Tests.ps1`, five cases each asserting `Test-PlaceholderMarker` true and `Get-PathTokenKind` null on the same probe | `Invoke-Pester` over `tests/scripts/claude-lib/blast-radius` — 409 tests, 0 failed | — |
| AC-4 | Single-quoted probes, content asserted, constraint commented | PASS | Every probe single-quoted or concatenated; `$script:PairPlaceholder | Should -Be '<FEATURE>/spec.md'` and `.Length | Should -Be 17` asserted before use; the single-quote constraint stated as a comment inside the file | reviewer inspection of the two Pester files | Load-bearing: the original defect report was invalidated by a double-quoted probe, and the retraction is recorded in `issue.md` |
| AC-5 | Filename-position marker rejected in both runtimes | PASS | Python `test_contains_placeholder_marker_reads_the_filename_position` with `.claude/state/powershell-batch-budget.<session_id>.json`; PowerShell filename-position case | both suites green | The predicate is position-blind by design; the docstring states why scoping to leading segments would admit the shape it exists to reject |
| AC-6 | Empty string, marker-only, bare bracket pair handled without raising | PASS | Python `test_contains_placeholder_marker_handles_a_degenerate_token` (3 params: `""`→False, `"<"`→True, `"<>"`→True); three PowerShell degenerate cases | both suites green | The totality contract is required because the classifier runs over every inline-code span; a raise would abort a whole derivation |
| AC-7 | Real path on the same task line still harvested | PASS | `test_real_path_on_same_task_line_survives_placeholder_rejection`; `derivation-placeholder-token-rejected.json` expects `scripts/dev_tools/compute_blast_radius.py` retained alongside the own-folder glob while both `<FEATURE>/...` tokens are dropped | both parity suites | The control asserts survival only, so it holds before and after the guard exists — which is what makes it a scope check rather than a duplicate rejection assertion |
| AC-8 | Conflict fixture `conflict-placeholder-only-overlap.json` exists; placeholder-only overlap reports conflict false in both parity suites | **PARTIAL** | The fixture does not exist. The substance is delivered by `test_placeholder_only_overlap_stops_conflicting_after_normalization` (Python) and `It 'conflicts before normalization and stops conflicting after it'` (PowerShell), plus the executed repro in `evidence/qa-gates/conflict-graph-density.md` | `grep -rn "classify_path_token" scripts/ --include=*.py`; inspection of `test_blast_radius_parity.py:417-465` | See the dedicated finding below. The literal clause is unsatisfiable and the withdrawal is correct; the criterion is nonetheless unmet as written, so it stays unchecked |
| AC-9 | Real-file overlap still conflicts; reuse-or-add decision recorded in the plan | PASS | `conflict-path-overlap.json` reused byte-unmodified; the reuse decision and its rationale are recorded in the plan and reproduced in `spec.md`'s Outcome section | `evidence/qa-gates/negative-control-reuse.md`; fixture unmodified in the diff | The reasoning for reuse over addition is sound: a fixture authored before the fix and committed unmodified proves the fix did not perturb an independently authored assertion |
| AC-10 | All 32 pre-existing fixtures unchanged, none edited | PASS | The fixture directory holds 35 top-level JSON files (32 pre-existing + 3 new). No pre-existing fixture appears in the diff | `git diff --name-status d782ee1c..HEAD -- tests/fixtures/blast_radius/` shows three `A` entries and zero `M` entries | Both parity suites pass over the whole corpus |
| AC-11 | Normalization strips a placeholder entry, preserves real entries, re-resolves modules and shared surfaces | PASS | Named tests in `test_blast_radius_normalization.py` and `BlastRadiusNormalization.Tests.ps1`; all three levels asserted | both suites green | `normalize_declared_radius` re-runs `classify_path_token` per recorded entry at `compute_blast_radius.py:344`, which is what makes the strip happen |
| AC-12 | `validation-placeholder-self-consistent.json` exists; derived radius validates clean against its own plan with empty findings | PASS | Fixture present; `expected.findings` is `[]`; executed by both parity suites | both parity suites | This pins the derivation/validation symmetry. Without it, every plan in the corpus would emit V1 findings for its own mandated citations — a corpus-wide regression that is easy to overlook |
| AC-13 | Named test pins the fail-open trade with a docstring recording the trade and the planner obligation | PASS | `test_placeholder_shaped_shared_surface_glob_match_is_dropped`, whose docstring records the placement rationale, the measured-empty corpus exposure, and the planner's explicit-enumeration obligation; paired with `test_concrete_shared_surface_glob_match_is_still_reported` | targeted run green | The control is essential: without it the companion could be satisfied by a change that stopped resolving shared-surface globs entirely |
| AC-14 | Baseline artifact records executed single-quoted five-marker probes pre-fix in both runtimes | PASS | `evidence/baseline/marker-probe-python.md`, `evidence/baseline/marker-probe-powershell.md` | artifact inspection | The executed determination replaced an assumption; it is what overturned the incorrect scope claim retracted in `issue.md` |
| AC-15 | One artifact records item count (non-zero), edges, density to 1dp, cohorts, max width, before and after, over 58 plans with a constant timestamp | PASS | `evidence/qa-gates/conflict-graph-density.md`: items 58 both states; edges 1282 → 1267; density 77.6% → 76.6%; cohorts 32 → 32; max width 4 → 4 | reviewer reproduction: items 58, edges 1279 → 1263, density 77.4% → 76.4% | Reviewer figures differ by ≤4 edges and 0.2 pp because the reviewer concatenated every `plan*.md` at HEAD rather than replicating the executor's exact selection. Direction and magnitude reproduce |
| AC-16 | Total `paths`-entry count before and after, exact set difference, every dropped entry contains a marker | PASS | Artifact records 3729 → 2472 with the full set difference enumerated per item, zero marker-free drops, zero additions | reviewer reproduction: 3780 → 2473; dropped 1307; marker-bearing before 1307; marker-bearing after **0** | **Exact independent reproduction of the criterion's central assertion.** Dropped count equals the pre-fix marker-bearing count, so no marker-free entry was lost |
| AC-17 | Named-survivor assertion over a fixed list covering each acceptance rule; all survive | PASS | All five probes survive; three with pre-registered carrier counts match exactly at 8, 16, and 7 | `evidence/qa-gates/conflict-graph-density.md` | The pre-registered counts are what make this non-vacuous |
| AC-18 | The known-genuine 486-487 edge survives with its reason unchanged | PASS | Reason kind and detail byte-identical to the before state | `evidence/qa-gates/conflict-graph-density.md` | — |
| AC-19 | Delta prediction recorded before the after-measurement; prediction vs actual reported; deviation explained not absorbed | PASS | Prediction 53 fixed at `[P0-T15]` with a witnessed SHA and clean status; actual 15; the margin of 38 is itemized pair by pair, and the measured pair set of 63 exceeding the pre-registered 53 by 10 is itemized as required | `evidence/baseline/edge-delta-prediction.md`; `evidence/qa-gates/conflict-graph-density.md:1425-1504` | The artifact states "the margin is not absorbed as success" and then does the accounting, including the two removed edges the plan's single-equation identity did not anticipate. Reviewer delta of 16 is consistent and far below the bound |
| AC-20 | Nine-item clique gone; any surviving edge among those pairs attributable to a shared real path | PASS | Clique matches the pre-registered set (334, 344, 369, 396, 413, 423, 442, 462, 479); all 36 pairs lost the placeholder reason; 12 removed, 24 survive, zero retaining a marker-bearing reason | `evidence/qa-gates/conflict-graph-density.md:1567-1578` | The artifact discloses that one of the 24 survives on a shared module rather than a shared path, and gives the exact argument for why it is still real evidence: after the fix every radius entry is marker-free, so any module resolved in the after state is resolved from marker-free real paths in both radii |
| AC-21 | Every new fixture carries the template shape and is asserted by both parity suites | PASS | All three fixtures follow the `derivation-directory-shaped-rejected.json` shape and are picked up by both suites' glob discovery across the radius and findings channels | both parity suites green | — |
| AC-22 | Both floors raised from 26 to 26 + new fixtures, and equal to each other | **PASS** (documented deviation) | `test_blast_radius_parity.py:60` `MINIMUM_FIXTURE_COUNT = 30`; `BlastRadius.Parity.Tests.ps1:61` `$minimumFixtureCount = 30`; 35 fixtures on disk | reviewer inspection of both literals and `ls tests/fixtures/blast_radius/*.json` | See the dedicated finding below. Literal arithmetic reads 29; both substantive properties hold and 30 is the stricter value |
| AC-23 | Both parity suites pass byte-comparable across four channels; three non-vacuity tests still pass in each | PASS | 73 Python and 76 PowerShell parity passes, 0 failures; radius, findings, conflict verdict, and conflict-reason channels agree; three non-vacuity tests green per suite | reviewer runs: 152 targeted Python tests and 409 blast-radius Pester tests, 0 failures | — |
| AC-24 | Bundled-mirror contract test passes for every new or changed `.claude/` file | PASS | Named test passes. Reviewer additionally confirmed by SHA-256 that all three mirrored files are byte-identical | `poetry run pytest ...::test_bundled_claude_payload_contains_all_repo_runtime_contracts` — passed; `sha256sum` on three pairs — identical | Covers the new module, the changed extraction module, and the amended rule file |
| AC-25 | Pack manifest lists the new module; manifest Pester and pack-manifest Jest suites pass | PASS | One entry added at `core.json` in the blast-radius block; Jest suite 1 suite / 15 tests passed | `npx jest --testPathPatterns "pack-manifest"` — 15 passed | Reviewer-executed; matches the executor's recorded count exactly |
| AC-26 | New module in the `CodeCoverage.Path` allow-list in both runsettings; bundled-parity test passes | PASS | Both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror gained the entry in identical diffs; parity test passes | `git diff` on both files; `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` — passed | The registration comment states the consequence of omission, which is appropriate for a surface that fails silently |
| AC-27 | No coverage exclusion matching a production path added; both new modules in their coverage denominator | PASS | Zero exclusion entries added anywhere. `pyproject.toml` `omit` lists only `tests/*`, `*/tests/*`, `*/__pycache__/*`, `*/site-packages/*`. Neither runsettings contains an exclusion key | reviewer inspection; `_blast_radius_token_shapes.py` present in `lcov.info` with `LF=14`; `BlastRadiusTokenShape.psm1` present with `LINE` 19 in a repository-allow-list run | — |
| AC-28 | Declared radius enumerates the runsettings in `shared_surfaces`; validation reports no V2 Blocking finding | PASS | Radius enumerates the runsettings; validation reports 0 findings of any severity, hence 0 Blocking | `evidence/qa-gates/declared-radius-validation.md` | The related over-declaration (84 → 85 entries) is recorded as informational; it moves in the fail-closed direction and cannot cause a missed edge |
| AC-29 | Rule file states four shapes, names the fourth, states the marker set, cross-references the acceptance-gate rule file | PASS | "rejects four token shapes" on a single line; fourth named "a token containing a placeholder or interpolation marker"; marker set in a fenced block; `.claude/rules/plan-acceptance-gates.md` cross-referenced as the set's origin | reviewer read of the full amendment diff | — |
| AC-30 | Amendment records all five additional items | PASS | All five present as substantive paragraphs: never-matches-a-tracked-path with the Windows-reserved-character argument; mandated-artifact origin of the dominant token; planner obligation to append a concrete path; fail-open trade with measured-empty exposure and a re-measurement obligation; whitespace-split residual as a known residual | reviewer read of the full amendment diff | The reviewer additionally tested the first item rather than accepting it: zero of 9685 tracked paths carry a marker |
| AC-31 | No JSON Schema file and no schema reference; enforcement stays prose plus validator logic | PASS | Zero schema paths in the diff. The amendment closes by restating that enforcement is prose plus validator logic and that `config/blast-radius.json` gains no key | `git diff --name-only` shows no schema file; reviewer read of the closing paragraph | Respects the foreign-schema prohibition at the top of the same rule file |
| AC-32 | `plan-acceptance-gates.md` and all of `.github/` unmodified | PASS | `git diff --name-only d782ee1c..HEAD -- .github/ .claude/rules/plan-acceptance-gates.md` returns no output | that command | — |
| AC-33 | Both extraction modules and both new modules at or under 500 lines | PASS | 475, 472, 144, 187 | `wc -l` on each | Both extraction modules have more headroom than at baseline (497 → 475, 498 → 472) |
| AC-34 | Relocated span predicate still exported from the extraction module | PASS | `Export-ModuleMember` in `BlastRadiusExtraction.psm1` lists both `Test-PlaceholderMarker` and `Test-MultipleFeatureFolderSpan`; a module-export assertion confirms both resolve | reviewer read of the export block; Pester suite green | This is what makes the relocation source-compatible rather than a silent breaking change |
| AC-35 | Python toolchain single pass, no failure, no auto-fix; line >= 85%, branch >= 75%, no changed-line regression | PASS | `black --check .` 442 unchanged; `ruff check --no-fix .` all passed; `pyright` 0/0/0; `pytest` 4112 passed / 5 skipped / 0 failed; line 92.61%, branch 85.19% (lcov aggregate); both changed files at 100% line | all four commands re-executed by the reviewer | `--check` and `--no-fix` are the read-only forms and are what prove the no-auto-fix clause. A bare `ruff check` would rewrite source and still exit 0 (issue #515) |
| AC-36 | PowerShell toolchain single pass; line >= 85%, with the new module measured | **PASS** (upgraded from the executor's PARTIAL) | Format clean, analyze 0 diagnostics, 3389 tests / 0 failures, repo line 96.46%. New module measured at **19/19 lines = 100%** and 22/22 instructions in a run driven by the repository allow-list | `Invoke-Formatter`, `Invoke-ScriptAnalyzer`, `Invoke-Pester` with `CodeCoverage.Path` set to the repository paths — reviewer-executed; plus `grep -c BlastRadiusTokenShape` over all nine npx-cache runsettings copies → 0 | See the dedicated finding below |
| AC-37 | TypeScript suites pass, confirming a no-op for that runtime | PASS | Zero `.ts`/`.tsx` files changed. 195 suites / 2654 tests unchanged from baseline; reviewer re-ran the suite that consumes the one changed JSON resource | `npx jest --testPathPatterns "pack-manifest"` — 1 suite, 15 tests passed | The no-op claim is structurally supported by the absence of any TypeScript source change in the diff |
| AC-38 | No signature, return type, artifact type, CLI flag, MCP property, finding-rule literal, or config key added or changed | PASS | `classify_path_token`/`Get-PathTokenKind` signatures and return types unchanged; `PathTokenKind` values unchanged; no CLI flag, artifact type, MCP input-schema property, or finding rule in the diff; `config/blast-radius.json` absent from the diff | reviewer diff inspection | The two new functions are new surface, not changed surface, and the relocated function is re-exported from its original module so no caller breaks |
| AC-39 | No diagnostic, warning, or advisory emitted for a rejected token | PASS | No new finding rule, no severity literal, no emission site in either runtime; all three new fixtures declare `findings: []`; zero pre-existing fixtures modified | `evidence/qa-gates/silent-drop-audit.md`; reviewer diff inspection | The empty `findings` blocks are themselves the assertion that the rejection is silent |
| AC-40 | Repro reports conflict false post-fix in both runtimes, recorded in the QA-gate artifact | PASS | Both runtimes report conflict false post-fix; the negative control remains false | `evidence/qa-gates/conflict-graph-density.md` | The control is what isolates the placeholder as the cause |
| AC-41 | Issue #500 sequencing decision recorded: sequenced, or the single edge declared and accepted | PASS | Decision recorded in the plan and reproduced with its three-part rationale in `evidence/qa-gates/declared-radius-validation.md`: the edge is declared and accepted, because under the per-edge cohort barrier the two items are already mutually excluded and a dependency key is prohibited on this surface | artifact inspection; reviewer confirmed #500 merged as PR #514 before this branch completed, and that the rebase merged both rule-file amendments cleanly with byte-identical mirrors | The reasoning is correct: on a surface where `depends_on` is a prohibited key, declaring the edge *is* the sequencing decision |

### Traceability rows

| # | `issue.md` item | Spec coverage | Status | Notes |
|---|---|---|---|---|
| 1 | Placeholder feature-doc tokens not harvested | AC-1, AC-2, AC-3, AC-7 | PASS | All four PASS |
| 2 | A real path on the same task line still is | AC-7 | PASS | — |
| 3 | Interpolation forms behave as separately specified rather than by assumption | AC-1, AC-2, AC-3, AC-14 | PASS | The executed per-marker determination replaced the assumption and overturned the incorrect scope claim, which is retracted in `issue.md` |
| 4 | Two-item conflict probe reports conflict false with the placeholder | AC-8, AC-40 | PASS | AC-40 passes outright. AC-8's underlying obligation is met by the two named pair-level tests, which the reviewer verified route through the classifier. The row's obligation is satisfied even though AC-8's fixture clause is not |
| 5 | Existing conflict true preserved for two items sharing a real file | AC-9, AC-10, AC-18 | PASS | All three PASS |
| 6 | Re-derive radii over committed plans; record density and cohort count before and after | AC-15, AC-20 | PASS | Independently reproduced |
| 7 | Keep a positive control; a fix that drops real paths must be caught immediately | AC-16, AC-17, AC-18, AC-19 | PASS | AC-16 independently reproduced exactly: every dropped entry carried a marker |
| 8 | Reuse the acceptance-gate marker set rather than inventing a second one | AC-29, AC-32, AC-38 | PASS | Additionally pinned equal by a named test |
| 9 | Decide silent drop versus diagnostic | AC-39 | PASS | Decision: silent drop, with the rationale recorded in both runtimes' help text and in the rule prose |
| 10 | Accept the false-negative trade knowingly, or narrow to bracket pairs | AC-29, AC-30 | PASS | The five-marker set is reused and the narrowing alternative is rejected under Risks, with the trade's exposure measured rather than asserted |
| 11 | Logs attached | AC-14, AC-15 supersede with executed evidence | PASS | — |

### Dedicated findings on the three examined dispositions

**AC-8 — PARTIAL. The withdrawal is correct; the criterion as written is not met.**

The reviewer verified the seam independently rather than accepting the executor's analysis. `classify_path_token` has exactly two callers in the repository: `compute_blast_radius.py:344` inside `normalize_declared_radius`, and `_blast_radius_extraction.py:372` inside `extract_plan_paths`. The conflict-fixture harness at `test_blast_radius_parity.py:417-465` builds both radii with `BlastRadius.from_dict(...)` from fixture literals and calls `conflicts(...)` directly, invoking neither caller. A conflict fixture's verdict is therefore invariant under this fix: with the placeholder present it reports `conflict=true` before and after, and with it absent it reports `false` before and after and duplicates the existing `conflict-none-disjoint.json`. The fixture can be satisfiable or discriminating, never both. The withdrawal is the right call.

The substance is discharged, and the replacement is stronger than the fixture would have been. `test_placeholder_only_overlap_stops_conflicting_after_normalization` and its PowerShell counterpart assert both halves: that the un-normalized pair conflicts on the shared placeholder and nothing else (the control proving the pair really shares an entry), and that the normalized pair does not conflict (the assertion that routes through the classifier and therefore fails on a tree where the guard is absent). The executed repro in `evidence/qa-gates/conflict-graph-density.md` discharges it a second time at the integration level.

Graded PARTIAL and left unchecked nonetheless. The criterion's first clause asserts that a specific file exists, and it does not. Checking the box would record a claim about the repository that is false. The corrective action is a documentation reconciliation of the criterion text — strike the fixture clause and restate the criterion as the property actually delivered — not code. **This PARTIAL does not warrant a remediation cycle:** it is not a coverage gap, not a behavioral gap, and not a test gap. It is one sentence of spec text that no longer describes the delivered design.

**AC-22 — PASS with a documented deviation. Leaving the floors at 30 is defensible.**

Both floors read 30 and are equal. Both were raised from 26. Three fixtures were added, so the criterion's literal arithmetic reads 29. The floor exists to make the parity corpus non-vacuous — to fail if a glob silently matched nothing or matched a truncated set — and 30 serves that purpose strictly better than 29 while remaining satisfiable against the 35 fixtures on disk. Both of the criterion's substantive properties therefore hold, and the executed value is the more conservative of the two candidates. The discrepancy arose because the floors were set when four fixtures were planned and revision 6 later replaced one fixture with a named test per runtime.

Graded PASS. Lowering the floors to 29 would weaken the gate to satisfy an arithmetic identity, and would force a Phase 8 restart for no functional gain. The criterion's *text* should be reconciled in the same documentation follow-up as AC-8, so a later auditor does not have to re-derive this reasoning.

**AC-36 — PASS. Upgraded from the executor's PARTIAL on independently gathered evidence.**

The executor recorded this as partial because the "with the new module measured" clause is not observable through the MCP gate command. That is factually correct and the reviewer confirmed the stated cause rather than accepting it: `.mcp.json` configures the server as `npx -y @danmoisan/drm-copilot-mcp`, and all nine `pester.runsettings.psd1` copies in the npx cache carry zero `BlastRadiusTokenShape` entries. The canonical artifact `artifacts/pester/powershell-coverage.xml` accordingly contains six blast-radius source files and not the seventh. The cause is a published-package publish boundary, outside this branch and outside this repository.

The reviewer then measured the clause directly. Running Pester over `tests/scripts/claude-lib/blast-radius` with `CodeCoverage.Path` set to the two repository module paths produced 409 tests, 0 failures, 120 of 120 commands executed, and per-file JaCoCo counters of `BlastRadiusTokenShape.psm1` LINE 19/19 = 100% with INSTRUCTION 22/22, and `BlastRadiusExtraction.psm1` LINE 85/85 = 100% with INSTRUCTION 98/98. Both in-repository allow-lists carry the entry, added in the same commit as the module.

Graded PASS. The criterion is a statement about this repository's toolchain configuration and this repository's coverage, and both are satisfied and independently verified. The unmet element is an observability property of a stale artifact in an npx cache. Leaving the criterion unchecked would imply a repository gap that does not exist. The caveat is recorded here and in `policy-audit.2026-08-23T11-12.md` so the limitation is not lost: until the next MCP package publish, a regression in `BlastRadiusTokenShape.psm1` would not be reflected in the MCP gate's coverage figure. The behavioral risk is low — the module has a dedicated 197-line Pester suite whose cases run inside the full 3389-test suite — but the attribution gap is real and is worth closing at the next publish.

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 40 of 41 numbered criteria; 11 of 11 traceability rows
- **PARTIAL:** 1 (AC-8 — literal fixture clause unsatisfiable; substance discharged and independently verified)
- **UNVERIFIED:** 0
- **FAIL:** 0

**Change from the executor's recorded status:** AC-36 moves from partial to PASS on evidence the reviewer gathered directly. AC-8 moves from "withdrawn" to PARTIAL — the withdrawal reasoning is upheld in full, but a withdrawn criterion is not a passed criterion, and the checkbox tracks the criterion as written. AC-22 is confirmed PASS with its deviation restated.

**Top gaps preventing a clean 41/41:**

1. AC-8's fixture clause is unsatisfiable and the spec text still asserts it. This is a documentation-text gap, not a delivery gap. Nothing in the delivered behavior, tests, or coverage is missing.
2. No other gap. Every remaining criterion is PASS, and 14 of them were re-verified by the reviewer with independently executed commands rather than by reading the executor's artifacts.

**Recommended follow-up verification steps:**

1. In a documentation-only follow-up, strike AC-8's fixture clause and restate the criterion as the property delivered; reconcile AC-22's arithmetic to match the executed floors of 30; refresh the stale `4095` Python test count in the `## Outcome` section to 4112. None of these gates the merge.
2. At the next MCP package publish, confirm `BlastRadiusTokenShape.psm1` appears in the MCP-driven `artifacts/pester/powershell-coverage.xml`, closing AC-36's observability caveat.
3. Before opening the pull request, set the auto-close list to `#502` only. The generated list in `artifacts/pr_context.summary.txt` contains 52 entries of which 45 are not issue references, caused by the pattern at `scripts/dev_tools/pr_context/render_pr_helpers.py:104`. File that defect as its own issue.
4. Disclose in the pull-request body that the diff also lands issue #501's promoted lifecycle record, and why.
5. Separately from this feature: investigate the residual conflict-graph density. This fix cut radius entries by 34% and removed a provably-spurious edge class, yet cohort count and maximum cohort width did not move (32 and 4, before and after). The concurrency objective that motivated the issue is not yet met, and the remaining 1267 edges need their own analysis.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** are checked off in the authoritative source file.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** remain unchecked.
- No criterion text was modified, and no criterion was added or removed.

**Change made to the source file in this audit:** AC-36 was changed from `- [ ]` to `- [x]` in `spec.md`, following its PASS evaluation on independently measured evidence. Criterion text was not altered.

**Left unchecked:** AC-8, graded PARTIAL. Its literal clause names a file that does not exist and cannot usefully exist; the substance is discharged elsewhere and verified, but the criterion as written is not met.

**Not touched:** the four impact/severity radios and the logs-attached checkbox in `issue.md`. They sit outside any acceptance-criteria section and are not acceptance criteria under the `full-bug` work mode, which resolves the source to `spec.md` alone.

### AC Status Summary

- Source: `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md`
- Total AC items: 41
- Checked off (delivered): 40
- Remaining (unchecked): 1
- Items remaining: **AC-8** — "`tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json` exists; two radii whose only shared entry is a placeholder token with disjoint real files report conflict false in both parity suites." Unchecked because the fixture clause is unsatisfiable; the second clause is delivered and verified by a named test in each runtime.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 41 | 40 | 1 | Checkbox-backed, sole authoritative source under work mode `full-bug` |
| `issue.md` | — | — | — | Not an AC source under `full-bug`. Its 11 traceability obligations are evaluated above via the spec's traceability table; all 11 PASS |
| `user-story.md` | — | — | — | Does not exist. Correct for `full-bug`; not a gap |
