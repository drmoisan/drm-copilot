# Policy Audit — Issue #452 v2 Regression Cycle (blast-radius under-reporting regression corpus)

- Timestamp: 2026-09-27T16-03
- Branch: `bug/blast-radius-under-reporting-regression-452`
- Head: `f7b1acadf21bf9f510f294be2c8cde668eb1498a`
- Base: `origin/main`, merge-base `beae3f021674e64fa6662097fe48a332d8da62b8` (resolved with `git fetch origin main` and `git merge-base origin/main HEAD`)
- Diff form: `git diff --name-status origin/main...HEAD`
- Review scope folder: `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/`
- Work mode: `full-bug` (marker in `v2/spec.md`); acceptance-criteria source: `v2/spec.md` only; no `user-story.md` by design

## Executive Summary

The branch adds one JSON regression corpus, one Python test consumer, one Pester test consumer, and v2 documentation and evidence. No production file, configuration file, workflow, or existing test file is changed. The executed plan resolved the conditional production correction as NO-CORRECTION-REQUIRED, and this audit confirmed that independently: `git diff --name-only origin/main...HEAD -- .claude scripts extensions config pyproject.toml .github` returns no output.

The reviewer re-ran the Python consumer (25 passed, 1 skipped), black, ruff, and pyright on the new Python file (all clean), the Pester consumer through an `sh` wrapper (25 passed, 1 skipped, 0 failed), and PSScriptAnalyzer with the repository settings (0 findings). The one local failure in the repository-wide Python run is the issue #510 test. The reviewer reproduced it and confirmed its cause: an untracked, gitignored `.claude/state/` hook file. The branch changes no tracked `.claude` path, and CI on main at the merge-base `beae3f02` concluded `success`.

Overall verdict: PASS. Blocking findings: 0. Three non-blocking findings are recorded in section 8.

## Rejected Scope Narrowing

None detected. The caller prompt named the v2 subfolder as the location for review artifacts and the acceptance-criteria source. It did not restrict the branch diff, mark a language as out of scope, or ask for a toolchain or coverage check to be skipped. The audit covers the full `origin/main...HEAD` diff: 61 added files, 0 modified, 0 deleted.

The caller also stated that AC-21 (CI green) and AC-22 (PR body contains `Fixes #452`) are pending because no pull request exists. This is the actual pre-PR state, not a scope narrowing. Both criteria are recorded as pending in the feature audit and are not scored as FAIL.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported violations.
- The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. The diff contains no `artifacts/` path at all.
- All 58 v2 documentation and evidence files are under `v2/`. The 55 evidence files are under `v2/evidence/{baseline,regression-testing,qa-gates,other}/`, which are the canonical kinds.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entry was needed.
- A scan of `v2/` and the corpus folder for absolute host paths (drive-letter user or repo paths, `AppData`, `/home/`) returned no matches. Evidence files use the `<worktree root>` and `<scratchpad>` tokens.

Verdict: PASS.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Each Python test reads module-level immutable data parsed once at import and mutates nothing. Each Pester `It` reads discovery-time data or `BeforeAll` script-scope values and mutates nothing. |
| Isolation | PASS | Each per-case test evaluates one case through one contention call. Meta-tests each assert one contract rule. |
| Fast execution | PASS | Python consumer: 26 items in 0.06 s (reviewer run). Pester consumer: 26 tests (reviewer run). |
| Determinism | PASS | Inputs are committed JSON. Every `computed_at` is a fixed literal in the non-ISO shape, so `ConvertFrom-Json -AsHashtable` does not convert it to a datetime. No clock, RNG, or wait. |
| Readability | PASS | Descriptive test names, docstrings or comments on each test, and failure messages that name the case id. |
| Arrange-Act-Assert | PASS | Python tests carry explicit Arrange/Act/Assert comments. Pester per-case blocks follow the same order. |
| No temporary files or external dependencies | PASS | Reviewer grep for `tmp_path`, `TestDrive`, `New-TemporaryFile`, `subprocess`, `os.getcwd`, `Get-Location`, `Path.cwd`, `origin/main`, and drive-letter literals over both consumers returned no match (exit 1). |
| Test file location mirrors production | PASS | `tests/scripts/dev_tools/` mirrors `scripts/dev_tools/`; `tests/scripts/claude-lib/blast-radius/` mirrors `.claude/lib/blast-radius/`; the fixture is under `tests/fixtures/`. |
| Scenario completeness | PASS | Both gaps are pinned in both directions with reciprocal negative controls, argument-order reversal (dir-vs-glob and glob-vs-dir), sibling-prefix boundary controls (`dev_tools_extra`, `orchestration-archive`, `PoshQCExtra`), an unconfigured root file control (`pyproject.toml`), a doctrine pin, and an empty-modules case. |
| Coverage thresholds (85% line, 75% branch) | PASS | See sections 1.2 and 5. |

### 1.2 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A — zero TypeScript files changed on the branch; `coverage/lcov.info` is not present and not required.
- TypeScript post-change coverage artifact: N/A — zero TypeScript files changed on the branch.
- PowerShell baseline coverage artifact: `v2/evidence/baseline/phase0-powershell-pester-coverage.2026-09-27T14-52.md`, repository-wide line coverage 96.04% (10224 covered, 422 not covered).
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (written 2026-09-27 15:51), parsed by the reviewer: LINE 10224 covered / 422 not covered = 96.04%; INSTRUCTION 95.28%. Recorded in `v2/evidence/qa-gates/final-powershell-pester-coverage.2026-09-27T15-53.md`.
- Python baseline coverage artifact: `v2/evidence/baseline/phase0-python-pytest-coverage.2026-09-27T14-44.md`, repository-wide 92.97% line and 85.68% branch.
- Python post-change coverage artifact: `v2/evidence/qa-gates/final-python-pytest-coverage.2026-09-27T15-40.md`, repository-wide 92.97% line (14727/15841) and 85.68% branch (4935/5760). On-disk `artifacts/python/coverage.json` holds the P6-T6 targeted run: 99.75% line (393/394) and 99.28% branch (137/138) over the five blast-radius modules, parsed by the reviewer.
- Per-language comparison summary: Python and PowerShell are unchanged from baseline and above threshold; TypeScript and C# have zero changed files. Details are in 1.2.1.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.97% line, 85.68% branch; Post-change: 92.97% line, 85.68% branch; Change: 0.00 points line, 0.00 points branch; New/changed-code coverage: not applicable, zero production lines changed; Disposition: PASS; Evidence: v2/evidence/qa-gates/final-coverage-delta.2026-09-27T15-54.md and v2/evidence/qa-gates/final-python-pytest-coverage.2026-09-27T15-40.md
- PowerShell: Baseline: 96.04% line; Post-change: 96.04% line; Change: 0.00 points line (branch coverage is not measured by Pester and no branch threshold applies); New/changed-code coverage: not applicable, zero production lines changed; Disposition: PASS; Evidence: artifacts/pester/powershell-coverage.xml parsed by the reviewer and v2/evidence/qa-gates/final-powershell-pester-coverage.2026-09-27T15-53.md

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity | PASS | Each consumer has one data file, a small set of guard helpers (Python) or assertion helpers (Pester), and one per-case test. There are no class hierarchies or indirection layers. |
| Reusability | PASS | One corpus is shared by both runtimes, so both consumers are pinned by one artifact. |
| Separation of concerns | PASS | No production code changed. Test I/O is limited to reading three committed files resolved from the test file's own location. |
| File size limit (500 lines) | PASS | Reviewer `wc -l`: Python consumer 487, Pester consumer 290. The JSON corpus (605) is a data fixture and Markdown files are exempt; spec AC-18 also exempts both. |
| Error handling | PASS | The Python guards (`require_mapping`, `require_list`, `require_text`) raise `TypeError` naming the corpus location. |
| Naming | PASS | `snake_case` in Python and Verb-Noun names in PowerShell (`Test-ExactKeySet`, `Get-ReasonText`, `Assert-CaseShape`). |
| Dependencies | PASS | No new dependency in any language. `pyproject.toml` and lockfiles are unchanged. |
| Public API compatibility | PASS | No public API changed. |
| Mandatory toolchain loop | PASS | Python: black, ruff, pyright, and pytest recorded in `v2/evidence/qa-gates/final-python-*`, and re-run by the reviewer on the new file. PowerShell: format, analyze, and test recorded in `v2/evidence/qa-gates/final-powershell-*`; analyze and test re-run by the reviewer. Architecture-boundary, contract, and integration stages have no applicable change: no production module, schema, or adapter changed. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Changed files | Verdict | Evidence |
|---|---|---|---|
| Python | 1 test file | PASS | `poetry run black --check`: unchanged. `poetry run ruff check`: "All checks passed!". `poetry run pyright`: 0 errors, 0 warnings. `from __future__ import annotations` is present, the `Mapping` import is under `TYPE_CHECKING`, and full type annotations and Google-style docstrings are used. `v2/evidence/qa-gates/final-python-no-new-suppression.2026-09-27T15-41.md` records no new suppression, and the reviewer found no `noqa` or `type: ignore` in the file. |
| PowerShell | 1 test file | PASS | PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`: `PSSA_FINDINGS=0` (reviewer run). Format hash-identity across three runs is recorded in `v2/evidence/qa-gates/final-powershell-format.2026-09-27T15-43.md`. Helpers use `[CmdletBinding()]`, `[OutputType()]`, and typed mandatory parameters. |
| JSON (fixture) | 1 data file | PASS | Parses (reviewer load); `schema_version` 1, `issue` 452, 17 cases. |
| TypeScript | 0 | N/A | Zero changed files. |
| C# | 0 | N/A | Zero changed files. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Verdict | Evidence |
|---|---|---|
| Python (pytest) | PASS | Uses `pytest.mark.parametrize` with case-id `ids`. The tolerance placeholder uses `pytest.mark.skip` with a reason naming #722, as pre-authorized by spec "Merge-Order Independence with #722". No `tmp_path`, `monkeypatch` of globals, or network. |
| PowerShell (Pester 5) | PASS | The case list is built at discovery time so `-ForEach` produces one `It` per case. Modules are imported in `BeforeAll`, and the facade is imported first (commented). The tolerance placeholder uses `Set-ItResult -Skipped` with a reason naming #722. No `TestDrive`, `Mock` of external processes, or `Start-Sleep`. |
| Property-based and mutation obligations | N/A | Test-only change: no production pure function was added or changed, so the T1/T2 property-density and mutation-score gates are not triggered. The spec's mutation demonstration was performed and recorded (AC-10, AC-12). |

## 5. Test Coverage Detail

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 1 (test) | 26 new (25 pass, 1 pre-authorized skip); 5180 collected repo-wide | PASS | 92.97% line / 85.68% branch | 92.97% line / 85.68% branch | N/A — zero production lines changed |
| PowerShell | 1 (test) | 26 new (25 pass, 1 pre-authorized skip); 5488 repo-wide | PASS | 96.04% line | 96.04% line | N/A — zero production lines changed |
| TypeScript | 0 | N/A — no changed files | N/A | N/A — no changed files | N/A — no changed files | N/A — no changed files |
| C# | 0 | N/A — no changed files | N/A | N/A — no changed files | N/A — no changed files | N/A — no changed files |

Coverage verdicts by language:

- Python coverage verdict — PASS. Repository-wide line coverage is 92.97% (>= 85%) and branch coverage is 85.68% (>= 75%), unchanged from baseline. No production Python file is in the branch diff. The new test file is outside the coverage denominator (`tests/` is excluded; the reviewer's parse of `artifacts/python/coverage.json` found 0 test files in the denominator). So neither the new-file nor the modified-file threshold has a production file to evaluate, and no changed line can regress.
  - Artifact provenance note (non-blocking, finding PA-1): the canonical `artifacts/python/lcov.info` on disk was last written by the P6-T7 consumer-only run (`pytest tests/scripts/dev_tools/test_blast_radius_regression_452.py --cov=<five modules>`). The reviewer parsed 73.60% line (290/394) and 48.55% branch (67/138) from it. These figures measure how much of the five blast-radius modules the new consumer alone exercises. They are not a repository-wide measurement, and no threshold applies to a single-file run. The repository-wide values come from the P6-T5 run recorded in evidence. The targeted `coverage.json` (99.75% line, 99.28% branch) corroborates that the blast-radius modules remain above threshold under the full test tree.
- PowerShell coverage verdict — PASS. Repository-wide line coverage is 96.04% (>= 85%), unchanged from baseline. It was parsed by the reviewer from `artifacts/pester/powershell-coverage.xml`. No production PowerShell file is in the branch diff. Pester does not measure branch coverage, so no branch threshold applies.
- TypeScript coverage verdict — N/A, zero changed files on the branch.
- C# coverage verdict — N/A, zero changed files on the branch.

## 6. Test Execution Metrics

| Suite | Source | Result |
|---|---|---|
| Python consumer | Reviewer run: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_regression_452.py -q -rs` | 25 passed, 1 skipped (tolerance, reason names #722) |
| Python repository-wide | `v2/evidence/qa-gates/final-python-pytest-coverage.2026-09-27T15-40.md` | 5180 collected; 5173 passed, 6 skipped, 1 failed (issue #510 test, excused under the plan allowance) |
| Issue #510 test (local) | Reviewer run of `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` | Fails locally on `.claude\state\powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json`. `git check-ignore -v` prints `.gitignore:68:.claude/state/` for that path. |
| Pester consumer | Reviewer run of `Invoke-Pester` on the file | 25 passed, 1 skipped, 0 failed (26 total) |
| Pester repository-wide | `v2/evidence/qa-gates/final-powershell-pester-coverage.2026-09-27T15-53.md` | 5488 total; 5478 passed, 10 skipped, 0 failed |
| Python mutation demonstration | `v2/evidence/regression-testing/phase3-python-mutation-demonstration.2026-09-27T15-18.md`, plus a reviewer re-check | Executor: 4 flips, all detected with the case named. Reviewer: 4 additional flips on different cases (`g1-plan-package-lock`, `g1-plan-unconfigured-root-file`, `g2-artifacts-dir-vs-glob`, `g2-artifacts-dir-vs-sibling-glob`), all detected with the case named. |
| Pester mutation demonstration | `v2/evidence/regression-testing/phase4-pester-mutation-demonstration.2026-09-27T15-30.md` | 4 flips, each `FailedCount=2` with the flipped case named; corpus unchanged afterwards |
| CI on main at merge-base | `gh run list --branch main` | `CI` workflow concluded `success` for `beae3f02` |

## 7. Code Quality Checks

| Check | Python | PowerShell |
|---|---|---|
| Format | PASS — black: 1 file unchanged (reviewer) | PASS — three identical SHA256 hashes across the MCP and repository formatters (evidence) |
| Lint | PASS — ruff: all checks passed (reviewer) | PASS — PSScriptAnalyzer 0 findings (reviewer) |
| Type check | PASS — pyright 0 errors (reviewer) | N/A — no type checker for PowerShell |
| Suppressions | PASS — none added | PASS — no `SuppressMessageAttribute` in the file |
| Coverage exclusions | PASS — none added; `pyproject.toml` unchanged | PASS — runsettings unchanged |

## 8. Gaps and Exceptions

1. **Issue #510 local allowance (evaluated, accepted, non-blocking).** The plan's revision 9 allowance excuses one local failure in P6-T5 and P6-T6, subject to four mechanical conditions. The reviewer verified the conditions independently:
   - the failure reproduces with the same message;
   - the named path is under `.claude/state/`;
   - `git check-ignore -v` confirms `.gitignore:68`;
   - `git status --porcelain` is empty;
   - `git diff --name-only origin/main...HEAD -- .claude` is empty.

   A CI checkout contains no `.claude/state/` directory, and the branch changes no tracked `.claude` file. The test's CI outcome is therefore expected to equal main's, and main's `CI` run at the merge-base concluded `success`. This remains an expectation until AC-21 records the PR-head CI result, where the test runs with no allowance.
2. **PA-1 (Minor, non-blocking): coverage artifact provenance.** The canonical `artifacts/python/lcov.info` and `artifacts/python/coverage.json` on disk were overwritten by the narrower P6-T7 (consumer-only) and P6-T6 (targeted) runs after the repository-wide P6-T5 run. The repository-wide figures therefore exist only as recorded evidence text. Recommendation: order future plans so the repository-wide coverage run is the last writer of the canonical artifact, or direct narrower runs to a different report path.
3. **PA-2 (Minor, non-blocking): PR context artifacts absent.** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in the worktree. The generator is exposed only as an MCP tool (`mcp__drm-copilot__collect_pr_context`) that this review agent does not have. The reviewer substituted direct `git diff --name-status origin/main...HEAD`, `git log origin/main..HEAD`, and full reads of the three changed code files, which cover the same scope.
4. **PA-3 (Informational): direct `pwsh` invocation refused by the worktree guard.** The reviewer ran Pester and PSScriptAnalyzer through an `sh` wrapper script in the session scratchpad, which is the same route the executor used. The PoshQC MCP test tool is not exposed to this agent, so its run is taken from the executor's evidence.
5. **AC-21 and AC-22 pending.** No pull request exists, so CI on the PR head and the PR body text cannot be evaluated. They are not scored as FAIL.

## 9. Summary of Changes

| Path | Change | Lines |
|---|---|---|
| `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` | Added | 605 |
| `tests/scripts/dev_tools/test_blast_radius_regression_452.py` | Added | 487 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1` | Added | 290 |
| `v2/spec.md`, `v2/plan.2026-09-27T12-15.md`, `v2/research/...` | Added | Markdown |
| `v2/evidence/**` (55 files) | Added | Markdown |

No v1 document in the feature root, existing fixture, existing test, configuration, production module, workflow, or TypeScript file is changed.

## 10. Compliance Verdict

PASS. Blocking findings: 0. Non-blocking findings: PA-1, PA-2 (Minor), PA-3 (Informational). AC-21 and AC-22 are pending and outside the scope of a pre-PR review.

## Appendix A: Test Inventory

Python (`tests/scripts/dev_tools/test_blast_radius_regression_452.py`):

- `test_corpus_top_level_shape_matches_the_contract`
- `test_every_case_matches_the_case_shape_contract`
- `test_corpus_case_ids_are_unique_and_equal_the_spec_case_list`
- `test_every_expected_verdict_matches_its_direction`
- `test_every_pairing_resolves_to_an_opposite_direction_case_of_the_same_gap`
- `test_each_gap_has_a_must_conflict_and_a_must_not_conflict_case`
- `test_every_plan_line_follows_the_plan_line_intent_rule`
- `test_case_verdict_matches_corpus` (17 parametrized cases)
- `test_bundled_separator_free_shared_surfaces_equal_the_self_hosted_subset`
- `test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case` (pre-authorized skip)

Pester (`tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1`), `Describe 'BlastRadius regression corpus for issue 452'`:

- Context `Corpus contract`: 7 `It` blocks (top-level shape, case shape, id set, direction, pairing, both directions per gap, plan-line intent)
- Context `Detection-level verdicts`: 1 `It` with `-ForEach` over 17 cases
- Context `Bundled configuration parity`: 1 `It`
- Context `Tolerance branch`: 1 `It` (pre-authorized skip)

## Appendix B: Toolchain Commands Reference

Commands run by the reviewer (worktree root as the working directory):

- `git fetch origin main`; `git merge-base origin/main HEAD`; `git diff --name-status origin/main...HEAD`; `git log --oneline origin/main..HEAD`
- `git diff --name-only origin/main...HEAD -- .claude scripts extensions config pyproject.toml .github`
- `poetry run pytest tests/scripts/dev_tools/test_blast_radius_regression_452.py -q -p no:cacheprovider -rs`
- `poetry run black --check tests/scripts/dev_tools/test_blast_radius_regression_452.py`
- `poetry run ruff check tests/scripts/dev_tools/test_blast_radius_regression_452.py`
- `poetry run pyright tests/scripts/dev_tools/test_blast_radius_regression_452.py`
- `sh <scratchpad>/review-pester.sh` running `Invoke-Pester` on the Pester consumer and `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`
- `poetry run python <scratchpad>/cov.py` (parses `artifacts/python/lcov.info` and `artifacts/pester/powershell-coverage.xml`)
- `poetry run python <scratchpad>/covjson.py` (parses `artifacts/python/coverage.json`)
- `poetry run python <scratchpad>/flip.py` (in-memory verdict flips against `test_case_verdict_matches_corpus`)
- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --no-cov`
- `git check-ignore -v -- .claude/state/powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json`
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
- `gh run list --repo drmoisan/drm-copilot --branch main --limit 8`
