# Policy Audit: blast-radius path extractor misses real plan writes (Issue #797)

- Timestamp: 2026-10-09T07-51
- Branch: `bug/blast-radius-path-extractor-misses-real-plan-writes-797`
- Base: `origin/main` @ `e7d3779b398604af919678c16c877c8539a86cc0` (merge base)
- Head: `9608477a2903b9076d021aa12ff7e51cd0cc981e`
- Audited range: `e7d3779b..9608477a` (10 commits; full branch diff against the resolved base)
- Work mode: `full-bug` (AC source: `spec.md` only)
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, regenerated in this review (both were absent); generated 2026-10-09 07:47:53 UTC, Head SHA `9608477a2903b9076d021aa12ff7e51cd0cc981e`, matching the current head.

## Executive Summary

The branch replaces the blast-radius classifier's extension allowlist with a file-shape predicate in the Python authority (`scripts/dev_tools/_blast_radius_token_shapes.py`, `_blast_radius_extraction.py`) and the PowerShell port (`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`, `BlastRadiusExtraction.psm1`), syncs byte-identical bundled mirrors, documents the rule in `.claude/rules/parallel-orchestration.md`, and adds or updates tests and fixtures in both runtimes.

Policy compliance is PASS. Both coverage languages with changed files (Python, PowerShell) meet the changed-file thresholds at 100.0% line coverage (Python branch 100.0%). Toolchains are clean locally and in CI run 37900002916 at head `9608477a`. No file exceeds 500 lines. No evidence file is written outside the canonical feature evidence tree.

Blocking findings: 0. Non-blocking findings: 3 (PA-1 pre-existing PowerShell repository-wide aggregate below 85%; PA-2 pre-existing npm audit failures; PA-3 local PowerShell verification route substituted, corroborated by CI).

## Rejected Scope Narrowing

- Caller text: "Review diff range: `git diff 3d5a8446..9608477a` (3d5a8446 is the plan commit / execution base; 9608477a is HEAD, pushed)."
  - Justification: the audit scope is the full branch diff against the resolved base (`origin/main` merge base `e7d3779b`), so the plan commit `3d5a8446` (feature folder `issue.md`, `spec.md`, `plan`, `research`, and the promoted lifecycle record `docs/features/potential/promoted/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes.md`) is included in this audit.

No other narrowing was detected. The caller statement that the npm audit failure is out of scope was independently verified (the branch diff changes no `package.json` or lockfile) rather than accepted as given.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence, isolation, determinism | PASS | New Python tests are parametrized pure-function calls; new Pester tests call pure functions and read one repository source file (`scripts/dev_tools/_blast_radius_token_shapes.py`) read-only. No clock, RNG, network, or sleep. |
| No temporary files in tests | PASS | No `tmp_path`, `TestDrive`, `New-TemporaryFile`, or file writes in the changed tests. |
| Arrange-Act-Assert structure | PASS | Every added test carries Arrange/Act/Assert comments (`test_blast_radius_extraction_rules.py:243-313`, `test_blast_radius_token_shapes.py:152-213`, `BlastRadiusTokenShape.Tests.ps1:199-357`). |
| Scenario completeness (positive, negative, edge) | PASS | Positive tokens (7), false-positive guards (15), residual (1), predicate cases (15 including empty, lone dot, trailing dot, digit-led, hyphenated, non-ASCII, case variant). |
| Test location mirrors source | PASS | `tests/scripts/dev_tools/` and `tests/scripts/claude-lib/blast-radius/`; no colocated tests. |
| Line coverage >= 85% (uniform) | PASS | Changed modules 100.0% in both languages; see section 5. |
| Branch coverage >= 75% (branch-capable languages) | PASS | Python changed modules 100.0% branch; PowerShell exempt (Pester measures no branch coverage). |
| No regression on changed lines | PASS | Python `missing_lines []`, `missing_branches []` for both modules (`evidence/qa-gates/changed-line-coverage.2026-10-09T04-20.md`); PowerShell 0 missed lines in both modules (CI JaCoCo). |
| Coverage exclusion policy (no production path excluded) | PASS | The branch does not change any coverage configuration (`pyproject.toml`, `config/poshqc-coverage.json`, Jest configs are not in the diff). |

### 1.1 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (zero TypeScript files changed on the branch)
- TypeScript post-change coverage artifact: N/A (zero TypeScript files changed on the branch)
- PowerShell baseline coverage artifact: `evidence/baseline/pester-coverage-baseline.xml` (BlastRadiusExtraction.psm1 86/86 = 100.0%, BlastRadiusTokenShape.psm1 20/20 = 100.0%)
- PowerShell post-change coverage artifact: `evidence/qa-gates/pester-coverage-final.xml` and CI artifact `poshqc-test-results` of run 37900002916 (BlastRadiusExtraction.psm1 80/80 = 100.0%, BlastRadiusTokenShape.psm1 31/31 = 100.0%)
- Python baseline coverage artifact: `evidence/baseline/python-coverage-baseline.json` (extraction 100.0% line / 100.0% branch; token_shapes 100.0% / 100.0%)
- Python post-change coverage artifact: `evidence/qa-gates/python-coverage-final.json` and `artifacts/python/lcov.info` (extraction 97/97 = 100.0% line, 44/44 = 100.0% branch; token_shapes 25/25 = 100.0% line, 8/8 = 100.0% branch)
- Per-language comparison summary: Python 100.0% -> 100.0% (no change); PowerShell 100.0% -> 100.0% (no change) for the changed modules; see section 1.2.1.

### 1.2 Coverage Metrics Table

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 2 production, 3 test | focused 316; CI full 6645 | PASS (0 failed) | 100.0% line / 100.0% branch (changed modules) | 100.0% line / 100.0% branch (changed modules); repo-wide 93.59% line / 91.07% branch | 100.0% line / 100.0% branch |
| PowerShell | 2 production (+2 mirrors), 2 test | CI 6567 passed | PASS (0 failed) | 100.0% line (changed modules) | 100.0% line (changed modules); repo-wide 84.69% line / 84.34% instruction | 100.0% line |
| TypeScript | 0 | n/a | n/a | N/A | N/A | N/A |
| C# | 0 | n/a | n/a | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 100.0% line / 100.0% branch for `_blast_radius_extraction` and `_blast_radius_token_shapes`; Post-change: 100.0% line / 100.0% branch for both modules (repo-wide CI 93.59% line / 91.07% branch); Change: no change on the changed modules, no uncovered changed line or branch; New/changed-code coverage: 100.0%; Disposition: PASS; Evidence: `evidence/qa-gates/coverage-delta.2026-10-09T04-40.md`, `evidence/qa-gates/changed-line-coverage.2026-10-09T04-20.md`, `evidence/qa-gates/ci-run-37900002916.2026-10-09T07-51.md`.
- PowerShell: Baseline: 100.0% line for `BlastRadiusExtraction.psm1` and `BlastRadiusTokenShape.psm1`; Post-change: 100.0% line for both modules (repo-wide CI 84.69% line, see PA-1); Change: no change on the changed modules, 0 missed lines; New/changed-code coverage: 100.0%; Disposition: PASS; Evidence: `evidence/qa-gates/pester-coverage.2026-10-09T04-30.md`, `evidence/qa-gates/ci-run-37900002916.2026-10-09T07-51.md`.

### 1.2.2 Coverage Verdict per Language with Changed Files

- Python: PASS. All changed files are modified (not new). Both are at 100.0% line and 100.0% branch, with no regression. Repo-wide 93.59% line / 91.07% branch (CI, enforced by `check_python_coverage_thresholds --min-line 85 --min-branch 75`).
- PowerShell: PASS. All changed files are modified (not new). Both are at 100.0% line, with no regression, and no branch threshold applies. The repository-wide aggregate is 84.69% line (84.34% instruction), which is below the 85% uniform threshold and above the reviewer procedure's 80% FAIL trigger. The shortfall predates this branch: issue #847 was opened 2026-10-08T07:40Z, before execution began. The branch-attributable effect on the aggregate is non-negative, because every line the branch adds or keeps in the two modules is covered and the removed lines were also covered. This is recorded as non-blocking finding PA-1.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity / separation of concerns | PASS | The predicate is a pure function in the leaf module; the classifier change is a one-line call-site substitution in each runtime. |
| Reusability (no copy-paste) | PASS | One predicate per runtime, consumed at both consult sites. |
| File size <= 500 lines | PASS | `_blast_radius_extraction.py` 468, `_blast_radius_token_shapes.py` 218, `BlastRadiusExtraction.psm1` 464, `BlastRadiusTokenShape.psm1` 267, `BlastRadiusExtraction.Path.Tests.ps1` 460, `BlastRadiusTokenShape.Tests.ps1` 357, `test_blast_radius_extraction.py` 466, `test_blast_radius_extraction_rules.py` 313, `test_blast_radius_token_shapes.py` 213 (measured in this review with `wc -l`). |
| Error handling | PASS | No new error paths; the predicate is total (empty string and lone dot return false). |
| Naming | PASS | `is_file_shaped_component`, `KNOWN_FILE_NAMES`, `FILE_EXTENSION_PATTERN_TEXT`; `Test-FileShapedComponent`, `$script:KnownFileName`. |
| Public API compatibility | PASS | `RECOGNIZED_PATH_EXTENSIONS` removal is a documented deliberate change (spec "Data / API / Config Impact"); repository search in this review returned no remaining reference in `scripts`, `.claude`, `extensions`, `tests`. |
| Dependencies | PASS | No dependency added (`re` is standard library). |
| Tier classification | PASS | No new project; `scripts/dev_tools` T4, `.claude/lib/blast-radius` T3 (spec constraints). No property or mutation obligation applies. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Verdict | Evidence |
|---|---|---|
| Python | PASS | Black/Ruff/Pyright clean (`evidence/qa-gates/black-check.2026-10-09T04-20.md`, `ruff.2026-10-09T04-20.md`, `pyright.2026-10-09T04-20.md`); CI quality-checks7 passed on 3.10-3.13. Full type annotations; docstring with Args/Returns/Raises/Side Effects on the new predicate. |
| PowerShell | PASS | CI PowerShell QC: formatter `Already formatted` for all edited `.psm1` and `.Tests.ps1` files, `PSScriptAnalyzer passed: no findings`. `[CmdletBinding()]`, `[OutputType([bool])]`, comment-based help, approved verb `Test-`. |
| Markdown (rules document) | PASS | CI docs-validation passed; bundled mirror byte-identical (`cmp` in this review). |
| TypeScript, C#, bash | N/A | Zero changed files on the branch. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Verdict | Evidence |
|---|---|---|
| Python (pytest) | PASS | Parametrized tests with `pytest.param` ids, descriptive docstrings, assertion messages on the classifier and predicate tests; two constant-pin tests rely on pytest assertion introspection (CR-4, informational). |
| PowerShell (Pester 5) | PASS | `-ForEach` data-driven Its, `Should -BeExactly` for ordinal parity, ASCII-only test file preserved (non-ASCII case built with `[char]0xE9`). Test-name uniqueness suite passed (`evidence/qa-gates/pester-name-uniqueness.2026-10-09T04-30.md`). |

## 5. Test Coverage Detail

| File | Status | Line | Branch | Source |
|---|---|---|---|---|
| `scripts/dev_tools/_blast_radius_extraction.py` | modified | 97/97 = 100.0% | 44/44 = 100.0% | `artifacts/python/lcov.info`; `evidence/qa-gates/python-coverage-final.json` |
| `scripts/dev_tools/_blast_radius_token_shapes.py` | modified | 25/25 = 100.0% | 8/8 = 100.0% | same |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | modified | 80/80 = 100.0% | n/a (Pester) | CI JaCoCo; local `artifacts/pester/powershell-coverage.xml` |
| `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | modified | 31/31 = 100.0% | n/a (Pester) | same |
| Bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/` | modified (byte copies) | identical source | n/a | byte equality verified with `cmp` |

Local coverage artifacts (`artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`) are scoped runs (two Python modules; the blast-radius Pester folder), so their file totals are not repository-wide figures. Repository-wide figures are taken from CI run 37900002916.

## 6. Test Execution Metrics

| Suite | Result | Source |
|---|---|---|
| Python focused (8 blast-radius files) | 316 passed, 0 failed | `evidence/qa-gates/pytest-focused-coverage.2026-10-09T04-20.md` |
| Python full (CI 3.13) | 6645 passed, 6 skipped | CI job 113720084007 |
| Pester full (CI) | 6567 passed, 0 failed, 10 skipped | CI job 113720084085 |
| Pester BlastRadiusTokenShape / Extraction.Path / Parity / HistoricalRuns / WriteIntent | 57 / 61 / 82 / 9 / 28 tests, 0 failures each | CI artifact `poshqc-test-results` |
| Fail-before (Python) | expected failures recorded | `evidence/regression-testing/python-fail-before.2026-10-09T03-10.md` |
| Fail-before (Pester) | 9 expected failures with exact names, plus the new parity fixture case | `evidence/regression-testing/pester-fail-before.2026-10-09T03-10.md` |

## 7. Code Quality Checks

| Stage | Python | PowerShell |
|---|---|---|
| Format | PASS (black --check; CI) | PASS (CI `Already formatted`) |
| Lint | PASS (ruff; CI) | PASS (CI PSScriptAnalyzer no findings) |
| Type check | PASS (pyright; CI) | n/a (skipped for PowerShell by policy) |
| Architecture boundary | n/a (no tool configured; `evidence/baseline/architecture-tool-presence.2026-10-09T02-51.md`) | n/a (same) |
| Unit tests | PASS | PASS |
| Contract / schema | PASS (shared Python/PowerShell parity corpus, 2 new fixture cases pass in both runtimes) | PASS |
| Integration | n/a (pure classification functions; no adapter) | n/a |

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 in this review.
- The branch diff contains no file under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence files are under `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/{baseline,qa-gates,regression-testing}/`.
- Verdict: PASS (0 violations).

## 8. Gaps and Exceptions

| ID | Severity | Classification | Description | Disposition |
|---|---|---|---|---|
| PA-1 | Non-blocking | Pre-existing | PowerShell repository-wide aggregate line coverage is 84.69% (instruction 84.34%) in CI, below the uniform 85% threshold. The changed modules are at 100.0% and the branch does not lower the aggregate. | Tracked by open issue #847 (opened before this branch). No branch action required. |
| PA-2 | Non-blocking | Pre-existing, out of scope | Non-required NPM Audit Gate jobs `(.)` and `(extensions/drm-copilot)` failed on handlebars advisories GHSA-xw65-4hp5-5hc7, GHSA-8r5x-fm3f-whwj, GHSA-p8wg-vrv2-v86f. The branch changes no `package.json` or lockfile. | File or link a dependency-update follow-up item. |
| PA-3 | Non-blocking | Process deviation | Local PowerShell format/analyze/test and coverage evidence used the PoshQC MCP route with counts read from its JUnit/JaCoCo output files, because inline `pwsh` was denied by the worktree-isolation hook. | Resolved by CI run 37900002916, whose per-suite counts and per-module coverage equal the local values. |

## 9. Summary of Changes

- Production (Python): `scripts/dev_tools/_blast_radius_token_shapes.py` (+`is_file_shaped_component`, `KNOWN_FILE_NAMES`, `FILE_EXTENSION_PATTERN_TEXT`); `scripts/dev_tools/_blast_radius_extraction.py` (allowlist removed, predicate called at both consult sites).
- Production (PowerShell): `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` (+`Test-FileShapedComponent`); `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` (allowlist removed, predicate called and re-exported); two byte-identical bundled mirrors.
- Documentation: `.claude/rules/parallel-orchestration.md` "File-shape recognition (issue #797)" subsection and Known false negatives item 7; bundled mirror.
- Tests and fixtures: 3 Python test files, 2 Pester test files, new `derivation-file-shaped-tokens.json`, description-only change in `derivation-directory-shaped-rejected.json`, one re-pinned value in `historical-runs/backlog-2026-09-26.json` (edge 588-622 cost 152 -> 160).
- Feature folder: issue, spec, research, plan, promoted lifecycle record, and evidence.

## 10. Compliance Verdict

PASS. Blocking findings: 0. Non-blocking findings: PA-1, PA-2, PA-3.

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py`: `test_classify_path_token_admits_a_file_shaped_token_797` (7 cases), `test_classify_path_token_still_rejects_a_non_file_token_797` (15 cases), `test_classify_path_token_admits_the_dotted_directory_residual_797`.
- `tests/scripts/dev_tools/test_blast_radius_token_shapes.py`: `test_is_file_shaped_component_classifies_a_component` (15 cases), `test_known_file_names_are_the_adopted_set`, `test_file_extension_pattern_text_uses_explicit_ascii_classes`.
- `tests/scripts/dev_tools/test_blast_radius_extraction.py`: `alpha/beta.unknownext` moved from the rejecting to the accepting parameter list.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1`: Describe `File-shaped token classification (issue #797)` (7 + 15 + 1 cases), Describe `Test-FileShapedComponent (issue #797)` (15 predicate cases, 2 Python-source parity pins, 1 export-surface case).
- `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1`: `weird/thing.unknownext` It inverted to `concrete`.
- `tests/fixtures/blast_radius/derivation-file-shaped-tokens.json`: consumed by `test_blast_radius_parity.py` and `BlastRadius.Parity.Tests.ps1` through their fixture-directory globs (2 cases per runtime).

## Appendix B: Toolchain Commands Reference

- `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/main --head HEAD` (PR context regeneration, this review)
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0, this review)
- `cmp <repo file> <bundled mirror>` for the three mirror pairs (all identical, this review)
- `wc -l` over the nine changed production and test files (this review)
- `gh run view 37900002916`, `gh run view 37900002916 --job 113720084085 --log`, `gh run view 37900002916 --job 113720084007 --log`, `gh run download 37900002916 -n poshqc-test-results` (this review; read-only)
- Executor commands as recorded in the evidence artifacts: `poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, the focused pytest command from spec "Test Strategy", and PoshQC format/analyze/test via the MCP route.
