# Feature Audit: blast-radius path extractor misses real plan writes (Issue #797)

- Timestamp: 2026-10-09T07-51
- Branch: `bug/blast-radius-path-extractor-misses-real-plan-writes-797`
- Work mode: `full-bug` (from `issue.md` marker `- Work Mode: full-bug`); AC source: `spec.md` only
- AC section: `spec.md` `## Acceptance Criteria` (19 checkbox items)

## Scope and Baseline

- Resolved base: `origin/main` @ `e7d3779b398604af919678c16c877c8539a86cc0` (merge base). Head: `9608477a2903b9076d021aa12ff7e51cd0cc981e`. The audit covers the full branch diff `e7d3779b..9608477a`. The caller-supplied range `3d5a8446..9608477a` was widened to this; see `policy-audit.2026-10-09T07-51.md` "Rejected Scope Narrowing".
- Execution base: `3d5a8446` (plan commit; recorded in `evidence/baseline/base-sha.txt`). Baseline evidence was captured in commit `2f883b01` (phase 0), before the first production edit in `268de18a` (phase 2).
- Evidence sources:
  - Local executor evidence under `evidence/{baseline,regression-testing,qa-gates}/`.
  - CI run 37900002916 (workflow_dispatch of `ci.yml` at head `9608477a`), recorded in `evidence/qa-gates/ci-run-37900002916.2026-10-09T07-51.md`. The CI `poshqc-test-results` artifact was parsed read-only in this review.
- Baseline behavior: on the unmodified branch, `classify_path_token` returned `None` for `tests/shell/foo.bats`, `extensions/drm-copilot/jest.config.cjs`, `tests/out/run.out`, `.agents/skills/x/refs/foo.bats`, and `.claude/lib/x/.shellcheckrc` (`evidence/baseline/repro-classifier.2026-10-09T02-51.md`).
- Reliability of the local PowerShell route: the executor read local Pester counts and coverage from the JUnit and JaCoCo files written by the PoshQC MCP test tool, not from the tool's return value. The CI artifact reproduces the same per-suite counts (TokenShape 57, Extraction.Path 61, Parity 82, HistoricalRuns 9, WriteIntent 28; 0 failures) and the same per-module coverage (80/80, 31/31). This review therefore treats the local JUnit/JaCoCo-derived values as corroborated. That includes the pre-change values (AC-1 baseline, AC-3 fail-before), which CI cannot re-run.

## Acceptance Criteria Inventory

| AC | Short text | State before review | State after review |
|---|---|---|---|
| AC-1 | Baseline evidence before any production edit | unchecked | checked |
| AC-2 | Classifier regression (Python), fail-before/pass-after | checked | checked |
| AC-3 | Classifier regression (PowerShell) | unchecked | checked |
| AC-4 | Pipeline-level regression, shared fixture | checked | checked |
| AC-5 | Python/PowerShell parity on the fixture corpus | unchecked | checked |
| AC-6 | Known-name and pattern parity pin | unchecked | checked |
| AC-7 | Predicate unit tests | checked | checked |
| AC-8 | False-positive guards unchanged | unchecked | checked |
| AC-9 | Accepted behavior change recorded | unchecked | checked |
| AC-10 | Allowlist removed | checked | checked |
| AC-11 | Bundled mirrors byte-identical | checked | checked |
| AC-12 | Documentation subsection and false-negative note | checked | checked |
| AC-13 | Historical fixture re-pin | unchecked | checked |
| AC-14 | Other suites stay green | unchecked | checked |
| AC-15 | Python coverage | checked | checked |
| AC-16 | PowerShell coverage | unchecked | checked |
| AC-17 | Python toolchain clean | checked | checked |
| AC-18 | PowerShell toolchain clean | unchecked | checked |
| AC-19 | File-size limit | checked | checked |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence and reasoning |
|---|---|---|
| AC-1 | PASS | Repro output shows `None` for all five tokens (`evidence/baseline/repro-classifier.2026-10-09T02-51.md`). Python historical-runs, verification-integrity, and parity suites: 107 passed (`baseline/python-fixture-suites.2026-10-09T02-51.md`). Pester Parity and HistoricalRuns suites: 89 passed, 0 failed, with the verification-integrity Describe inside the parity file (`baseline/pester-fixture-suites.2026-10-09T02-51.md`). These were captured in commit `2f883b01`, before any production edit. The Pester count was read from the run's JUnit file, a route this review corroborated against CI (see Scope and Baseline). |
| AC-2 | PASS | Already checked by the executor. Tests exist at `test_blast_radius_extraction_rules.py` (`FILE_SHAPED_TOKENS_797`, 7 cases including `.devcontainer/codespaces/Dockerfile`). Fail-before and pass-after are recorded in `regression-testing/python-fail-before.2026-10-09T03-10.md` and `python-pass-after.2026-10-09T03-25.md`. CI Python passed on 3.10-3.13. |
| AC-3 | PASS | `BlastRadiusTokenShape.Tests.ps1` asserts `concrete` for the same seven tokens as the Python regression. Fail-before shows 9 expected failures with exact names (`regression-testing/pester-fail-before.2026-10-09T03-10.md`). Pass-after shows TokenShape 57/57 and Path 61/61 (`pester-pass-after.2026-10-09T03-45.md`). CI artifact: TokenShape 57 tests, 0 failures; 41 cases naming `797`, 0 failed. |
| AC-4 | PASS | Already checked. `derivation-file-shaped-tokens.json` expects the five realistic paths in the derived radius. Python fail-before and pass-after are recorded. CI Python passed. |
| AC-5 | PASS | `BlastRadius.Parity.Tests.ps1` discovers fixtures by directory glob, so the new fixture is included without edits. CI artifact: Parity 82 tests, 0 failures; both `derivation-file-shaped-tokens` cases (radius and findings) passed. Python parity: 109 passed (`regression-testing/python-fixture-suites-after.2026-10-09T04-00.md`). Both runtimes match the same expected block. |
| AC-6 | PASS | The Pester Its `pins the known file names to the Python source` and `pins the extension pattern text to the Python source` read `scripts/dev_tools/_blast_radius_token_shapes.py` and assert ordinal equality (18 names) and exact pattern text. They follow the `BlastRadiusWriteIntent.Tests.ps1` source-read pattern. CI artifact: 2 `Python source` cases, 0 failed. |
| AC-7 | PASS | Already checked. `test_is_file_shaped_component_classifies_a_component` covers all ten required case classes plus hyphenated, non-ASCII, alphanumeric, known dotfile, and unknown extensionless cases. |
| AC-8 | PASS | All 15 listed tokens are asserted `None` in Python (`NON_FILE_TOKENS_797`) and `$null` in Pester (`still rejects the non-file token <_>`). Both pass in CI (Python 3.10-3.13; Pester 0 failures across the 41 `797` cases). Pre-existing directory-shaped, root-surface, and placeholder-marker tests are unmodified: the numstat deleted column is 0 for the three additive files, and the only deletions are the two permitted `unknownext` edits (`qa-gates/unmodified-tests.2026-10-09T04-40.md`; reconfirmed by the diff read in this review). |
| AC-9 | PASS | `alpha/beta.unknownext` is in the Python accepting list. The Pester It `accepts a token outside the known segments with an unlisted letter-led extension` asserts `concrete` (CI: 1 case, 0 failed). `src/TaskMaster.Domain` is asserted `concrete` in both runtimes (Python `test_classify_path_token_admits_the_dotted_directory_residual_797`; Pester `classifies the dotted-directory residual as concrete`, CI 1 case, 0 failed). |
| AC-10 | PASS | Already checked. A repository search in this review for `RECOGNIZED_PATH_EXTENSIONS|RecognizedPathExtension` under `scripts .claude extensions tests` returned no matches. |
| AC-11 | PASS | Already checked. In this review, `cmp` reported all three pairs identical. CI Python (`test_push_down_claude_resource_contracts.py` is part of the suite) passed. |
| AC-12 | PASS | Already checked. The subsection `### File-shape recognition (issue #797)` and Known false negatives item 7 are present. A wording observation is recorded as CR-2 (non-blocking); it does not affect the AC literal. |
| AC-13 | PASS | `backlog-2026-09-26.json` edge 588-622 cost changed 152 -> 160. Python (P4-T1, P4-T3) and PowerShell (P4-T2) agree on 160, and the before and after values are listed in `regression-testing/historical-repin.2026-10-09T03-55.md`. Python historical-runs passed (109 in the fixture-suite run; CI full suite passed). CI artifact: HistoricalRuns 9 tests, 0 failures; 3 `backlog-2026-09-26` cases, 0 failed. |
| AC-14 | PASS | Python `test_blast_radius_verification_integrity.py`, `test_blast_radius_write_intent.py`, and `test_blast_radius_extraction.py` pass locally (`regression-testing/other-suites-after.2026-10-09T04-00.md`, 112 passed) and in CI. CI artifact: `BlastRadiusWriteIntent.Tests.ps1` 28 tests, 0 failures. No pin in `verification-integrity-485-486-487.json` changed (`regression-testing/verification-integrity-repin.2026-10-09T03-55.md`), so no re-derivation record is required. |
| AC-15 | PASS | Already checked. Both modules are at 100.0% line and 100.0% branch with no uncovered changed line (`qa-gates/pytest-focused-coverage.2026-10-09T04-20.md`, `changed-line-coverage.2026-10-09T04-20.md`; local `artifacts/python/lcov.info` reconfirmed in this review). |
| AC-16 | PASS | The CI PowerShell QC job is a self-hosted PoshQC Pester run with coverage. Its JaCoCo report gives `BlastRadiusExtraction.psm1` 80/80 = 100.0% and `BlastRadiusTokenShape.psm1` 31/31 = 100.0% line (>= 85%). This matches the local values in `qa-gates/pester-coverage.2026-10-09T04-30.md` and `qa-gates/pester-coverage-final.xml`. The CI output summary is saved at `qa-gates/ci-run-37900002916.2026-10-09T07-51.md`. |
| AC-17 | PASS | Already checked. black, ruff, pyright, and focused pytest are clean (`qa-gates/*.2026-10-09T04-20.md`). CI quality-checks7 passed on all four Python versions. |
| AC-18 | PASS | In a single CI PowerShell QC job pass at `9608477a`, the formatter reported `Already formatted` for both edited `.psm1` files, their mirrors, and both edited `.Tests.ps1` files. PSScriptAnalyzer reported `no findings`, and Pester reported 6567 passed, 0 failed. Locally, PoshQC format, analyze, and test returned ok with no rewrites (hashes identical before and after). |
| AC-19 | PASS | Already checked. Line counts were reconfirmed in this review: 468, 218, 464, 267, 460, 357, 466, 313, 213 (all <= 500). |

## Summary

- All 19 acceptance criteria evaluate as PASS. No AC is PARTIAL, FAIL, or UNVERIFIED.
- The ten ACs the executor left PARTIAL (AC-1, 3, 5, 6, 8, 9, 13, 14, 16, 18) were PARTIAL only because of the verification route (inline `pwsh` denied). This review resolves that gap with CI run 37900002916 at the same head. The CI per-suite counts and per-module coverage match the executor's local JUnit/JaCoCo-derived values exactly.
- The baseline intent of issue #797 is met. The five issue tokens that were dropped now classify as `concrete` in both runtimes; directory, version, ref, URL, rooted, and separator-free tokens stay rejected; and the derived radius in the shared fixture now contains the `.bats`, `.cjs`, `.out`, `.gitignore`, and `Dockerfile` writes.
- Blocking findings across the three review artifacts: 0. Non-blocking: PA-1, PA-2, PA-3 (policy audit); CR-1, CR-2, CR-3, CR-4 (code review).
- Out-of-scope follow-up candidates already recorded in the spec (not AC): an independent V1 cross-check, and confirmation of the `.agents/skills/**` mandate-read exclusion.

## Acceptance Criteria Check-off

Newly checked in `spec.md` by this review (only `- [ ]` changed to `- [x]`, one item at a time, criterion text unchanged):

1. AC-1 Baseline evidence
2. AC-3 Classifier regression (PowerShell)
3. AC-5 Python/PowerShell parity
4. AC-6 Known-name and pattern parity
5. AC-8 False-positive guards unchanged
6. AC-9 Accepted behavior change recorded
7. AC-13 Historical fixture re-pin
8. AC-14 Other suites stay green
9. AC-16 PowerShell coverage
10. AC-18 PowerShell toolchain clean

Previously checked by the executor and confirmed PASS: AC-2, AC-4, AC-7, AC-10, AC-11, AC-12, AC-15, AC-17, AC-19.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md`
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: none
