# Policy Audit: epic-wave-barrier-violations-lack-start-guard (Issue #659)

- Timestamp: 2026-09-30T10-08
- Branch: `bug/epic-wave-barrier-violations-lack-start-guard-659`
- Head: `bcc1e260f1c8a0933d06b1ec08b49ac3a65b2486`
- Base: `origin/main` (merge base `a24a1ce30c4c386d8ff2529f5b904092c3f12a52`; current `origin/main` tip `2b0121abf74f5862a3d12929d833504668941156`)
- Work mode: `minor-audit` (AC source: `issue.md` `## Acceptance Criteria`, AC-1 to AC-7)
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated 2026-09-30 14:03:55 UTC at head `bcc1e260`; matches the audited head, so no regeneration was required.
- Reviewer: feature-review agent

## Executive Summary

The branch adds a start guard to the epic wave-barrier ordering invariant in the Python authority (relocated into the new module `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`) and in the TypeScript port (`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts`). It replaces the single inaccurate error string with two case-specific strings, pins both runtimes to a shared fixture (`tests/fixtures/epic_wave_barrier/start-guard-matrix.json`), updates the epic skill document and its bundled mirror, and re-baselines the frozen-surface digest.

Policy verdict: **PASS** with four non-blocking observations (section 8). Blocking findings: 0.

- Python and TypeScript toolchains pass. The reviewer re-ran black, ruff, pyright, and the scoped pytest suites (93 passed) and the scoped Jest suites (47 passed) at head `bcc1e260`.
- Coverage: every changed production file is at or above 85% line and 75% branch, changed-line coverage is 100.00% in all three production files, and no module regressed.
- Evidence locations are compliant: `validate_evidence_locations.py --root .` exits 0, and the branch diff contains no path under `artifacts/`.
- No suppression directives were added.

## Rejected Scope Narrowing

No scope-narrowing text was detected in the caller prompt. The caller supplied the base branch, head SHA, work mode, and executor notes to evaluate; none of these limits the audit to a plan, a phase, or a file subset. The audit scope is the full `origin/main...HEAD` diff (56 files, 3384 insertions, 81 deletions).

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` returned exit code 0 with no reported paths.
- Branch-diff scan for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: no matching path in `git diff --name-only origin/main...HEAD`.
- All plan evidence is under `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/{baseline,regression-testing,qa-gates,other}/`.
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entry was needed.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence and isolation | PASS | Each fixture case builds its own document from the envelope; no shared mutable state. |
| Determinism | PASS | No clock, RNG, or timer use; the fixture is a committed, read-only JSON file. |
| No temporary files | PASS | Both new suites only read the committed fixture; no temp file or process is created. |
| No external services | PASS | Pure validator calls. |
| Arrange-Act-Assert structure | PASS | Comments mark each section in both new suites. |
| Scenario completeness | PASS | 14 matrix cases cover unstarted, started-by-status, started-by-timestamp, absent or null status, absent dependency status, multiple edges, timing, precedence, integer references, and the two regression shapes; extra tests cover unhashable status and skip paths. |
| Regression evidence (fail-before, pass-after) | PASS | Python 13 failed / 2 passed before, 28 passed after; TypeScript 14 failed / 2 passed before, 16 passed after. |
| Test location mirrors source | PASS | `tests/scripts/dev_tools/...` and `extensions/drm-copilot/test/lib/validate/...`. |

### 1.1 Coverage Evidence Checklist

- Python baseline coverage artifact: `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-python-coverage.md`
- Python post-change coverage artifact: `artifacts/python/lcov.info` (read-only), recorded in `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-python-coverage.md`
- TypeScript baseline coverage artifact: `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/baseline/p0-typescript-coverage.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (read-only), recorded in `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/evidence/qa-gates/final-typescript-coverage.md`
- PowerShell baseline coverage artifact: N/A (no PowerShell file changed on the branch)
- PowerShell post-change coverage artifact: N/A (no PowerShell file changed on the branch)
- Per-language comparison summary: Python and TypeScript both improved on the changed modules; changed-line coverage is 100.00% in both languages; see section 1.2.1.

### 1.2 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 5 (2 production, 3 test) | 92 (scoped coverage run) | 92 passed, 0 failed | 96.64% line / 93.06% branch | 97.53% line / 94.87% branch | 100.00% (37 of 37 changed executable lines) |
| TypeScript | 3 (1 production, 2 test) | 3331 (full suite) | 3331 passed, 0 failed | 97.02% line / 91.17% branch | 97.03% line / 91.19% branch | 100.00% (40 of 40 changed lines) |
| PowerShell | 0 | N/A | N/A | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

Python rows cover the modules measured by the plan's `--cov` targets (baseline: `validate_epic_orchestrator_state.py`; post-change: that module plus the new helper). TypeScript rows are repository-wide for `extensions/drm-copilot`.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 96.64% line / 93.06% branch (`validate_epic_orchestrator_state.py`, LH 144 / LF 149, BRH 67 / BRF 72); Post-change: 97.53% line / 94.87% branch (two changed modules combined, LH 158 / LF 162, BRH 74 / BRF 78); Change: +0.89 line points, +1.81 branch points; per file the validator moved 96.64% to 96.85% line and 93.06% to 93.55% branch, and the new helper is 100.00% line and 100.00% branch; New/changed-code coverage: 100.00% (37 of 37); Disposition: PASS; Evidence: `evidence/baseline/p0-python-coverage.md`, `evidence/qa-gates/final-python-coverage.md`, `evidence/qa-gates/coverage-delta.md`, `artifacts/python/lcov.info`
- TypeScript: Baseline: 97.02% line / 91.17% branch (repository-wide), `epic-orchestrator-state-core.ts` 97.79% line / 89.87% branch; Post-change: 97.03% line / 91.19% branch (repository-wide, LH 49818 / LF 51342, BRH 7223 / BRF 7921), `epic-orchestrator-state-core.ts` 97.96% line / 91.11% branch (LH 481 / LF 491, BRH 82 / BRF 90); Change: +0.01 line points and +0.02 branch points repository-wide, +0.17 line points and +1.24 branch points on the changed file; New/changed-code coverage: 100.00% (40 of 40); Disposition: PASS; Evidence: `evidence/baseline/p0-typescript-coverage.md`, `evidence/qa-gates/final-typescript-coverage.md`, `evidence/qa-gates/coverage-delta.md`, `extensions/drm-copilot/coverage/lcov.info`

### 1.3 Coverage Threshold Evaluation

| Scope | Threshold | Observed | Verdict |
|---|---|---|---|
| New file `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` | line >= 85% (and >= 90% for new files), branch >= 75% | 100.00% line, 100.00% branch | PASS |
| Modified `scripts/dev_tools/validate_epic_orchestrator_state.py` | line >= 85%, branch >= 75%, no regression | 96.85% line, 93.55% branch, up from 96.64% / 93.06% | PASS |
| Modified `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` | line >= 85%, branch >= 75%, no regression | 97.96% line, 91.11% branch, up from 97.79% / 89.87% | PASS |
| TypeScript repository-wide | line >= 85%, branch >= 75% | 97.03% line, 91.19% branch | PASS |
| Python measured scope | line >= 85%, branch >= 75% | 97.53% line, 94.87% branch | PASS |

Python language verdict: **PASS**. TypeScript language verdict: **PASS**. PowerShell and C#: no changed files; not applicable.

Assumption recorded: `artifacts/python/lcov.info` contains only the two `--cov` targets of [P2-T4], so a repository-wide Python percentage is not derivable from the existing artifact. The audit does not rerun coverage generation (agent contract). The Python verdict rests on the per-file, changed-line, and no-regression gates, all of which the artifact does support. This is recorded as observation O-4 in section 8.

Uncovered lines in the changed TypeScript file (181-182, 190-191, 290-291, 359-360, 364-365) are pre-existing defensive `continue` or error branches; none is a changed line (`evidence/qa-gates/coverage-delta.md`). Uncovered Python validator lines 191, 198, 276, 281 are likewise outside the changed hunks.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity | PASS | The guard is a single predicate and one early `continue`; the error branch is split into `if` / `elif`. |
| Reusability and separation of concerns | PASS | The Python check moved into a pure helper module with no I/O; the validator delegates. |
| Fail fast and explicit errors | PASS | Malformed state fails closed (absent or non-string `merge_status` counts as started; unhashable dependency status is reported, not raised). |
| File size <= 500 lines | PASS | Largest changed file 496 lines (`tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`); TypeScript core 491; validator 428; helper 163 (`evidence/qa-gates/line-counts.md`, re-checked with `wc -l`). |
| Public API compatibility | PASS | `validate_epic_orchestrator_state_text` and `validateEpicOrchestratorStateText` signatures are unchanged. The private `_validate_wave_barrier_ordering` had no other callers (grep). `MERGED_STATUSES` is re-imported into the validator, so the module attribute remains available. |
| Error text change is called out | PASS | Recorded in `issue.md` Consolidated Scope and AC-4; the skill document and mirror are updated. |
| Dependencies | PASS | No dependency added. |
| No absolute host paths in artifacts | PASS | Grep of the feature folder for drive-letter or user-profile paths returned no match. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| Python | Type annotations, docstrings, module header | PASS | New module has a Purpose / Responsibilities / Invariants header; both functions carry full docstrings with Args, Returns, Raises, Side Effects. |
| Python | No new suppressions (`noqa`, `type: ignore`, `pyright: ignore`) | PASS | Zero-context diff scan found none. |
| Python | Formatting / lint / types | PASS | black: 5 files unchanged; ruff: all checks passed; pyright: 0 errors (reviewer re-run). |
| TypeScript | Strict typing, no `any` | PASS | `hasStarted(feature: Record<string, unknown>): boolean`; no `any` introduced. |
| TypeScript | No new suppressions (`eslint-disable`, `ts-ignore`, `ts-expect-error`, coverage ignores) | PASS | Zero-context diff scan found none. |
| TypeScript | Prettier / ESLint / tsc | PASS | Extension `format` 472 of 472 unchanged; `lint` clean; `typecheck` clean (`evidence/qa-gates/final-typescript-*.md`). |
| JSON fixture | Repository root Prettier configuration | Observation | `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` is reported by `prettier --check`; see O-1. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| Python | pytest, parametrized, descriptive ids | PASS | `pytest.mark.parametrize` with case-name ids; 8 predicate cases with explicit ids. |
| Python | Assertion messages | PASS | Every assertion carries an f-string failure message. |
| TypeScript | Jest, `@jest/globals` imports, `it.each` | PASS | `epic-orchestrator-state-wave-barrier.test.ts`. |
| TypeScript | Runtime narrowing of fixture data | PASS | `requireObject` / `requireArray` / `requireString` guards instead of casts. |
| Both | Shared parity fixture | PASS | Both suites load the same committed fixture and assert the case count (14) and name uniqueness. |
| Both | Property-based tests | N/A | The changed modules are repository dev tooling (T4 by the examples in `.claude/rules/quality-tiers.md`); property tests are required only for T1 and T2. `quality-tiers.yml` is absent at the repository root on `main` (pre-existing, tracked by promoted potentials); the classification is the reviewer's assumption. |

## 5. Test Coverage Detail

| File | Status | Line | Branch | Changed-line |
|---|---|---|---|---|
| `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` | added | 100.00% (35/35) | 100.00% (16/16) | 100.00% (35/35) |
| `scripts/dev_tools/validate_epic_orchestrator_state.py` | modified | 96.85% (123/127) | 93.55% (58/62) | 100.00% (2/2) |
| `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` | modified | 97.96% (481/491) | 91.11% (82/90) | 100.00% (40/40) |

Values were re-derived by the reviewer from `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info`; they match `evidence/qa-gates/coverage-delta.md`.

## 6. Test Execution Metrics

| Run | Source | Result |
|---|---|---|
| Python fail-before (new suite, unchanged production code) | `evidence/regression-testing/fail-before-python.md` | 13 failed, 2 passed (expected) |
| TypeScript fail-before | `evidence/regression-testing/fail-before-typescript.md` | 14 failed, 2 passed (expected) |
| Python final coverage run | `evidence/qa-gates/final-python-coverage.md` | 92 passed |
| Python pass-after | `evidence/regression-testing/pass-after-python.md` | 28 passed |
| TypeScript full suite with coverage | `evidence/qa-gates/final-typescript-coverage.md` | 237 suites, 3331 tests passed |
| TypeScript pass-after | `evidence/regression-testing/pass-after-typescript.md` | 2 suites, 47 tests passed |
| Frozen-surface pin | `evidence/qa-gates/frozen-surface-pin.md` | 36 passed |
| Reviewer re-run: pytest (wave-barrier, validator, surface-contract suites) | this audit | 93 passed |
| Reviewer re-run: Jest (wave-barrier and core suites, no coverage) | this audit | 47 passed |

## 7. Code Quality Checks

| Check | Result |
|---|---|
| black `--check` (5 changed Python files) | PASS (reviewer re-run) |
| ruff check (5 changed Python files) | PASS (reviewer re-run) |
| pyright (5 changed Python files) | PASS, 0 errors (reviewer re-run) |
| Prettier (extension `format` script) | PASS (`evidence/qa-gates/final-typescript-prettier.md`) |
| ESLint | PASS (`evidence/qa-gates/final-typescript-lint.md`) |
| tsc `--noEmit` | PASS (`evidence/qa-gates/final-typescript-typecheck.md`) |
| Old error text absent | PASS (`evidence/qa-gates/old-text-absence.md`) |
| Skill document equals bundled mirror | PASS; both files move from blob `845e2377` to blob `53137cfd` in the diff |
| Bundled payload parity test | Environmental-only failure on a git-ignored `.claude/state/` file (`evidence/qa-gates/bundled-payload-parity.md`); accepted (see section 8) |
| Merge with current `origin/main` | Clean (`git merge-tree --write-tree`); no overlapping paths with the commits that landed after the merge base |

## 8. Gaps and Exceptions

Blocking: none.

Non-blocking observations:

- **O-1 (Minor):** `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` is not Prettier-formatted. The repository root `format:check` script covers `tests/**/*.json` and reports this file. The same script already reports more than 100 pre-existing fixture files on `main` and exits 2 on an intentionally invalid JSON fixture; no workflow under `.github/workflows/` invokes it. The plan's declared TypeScript format gate (extension `format` script) does not cover repository-root fixtures and passes. Recommendation: run Prettier on the new fixture before merge so the file does not add to the existing backlog.
- **O-2 (Advisory):** The two follow-ups in `evidence/other/follow-ups.md` (unhashable `merge_status` crash in `_validate_merge_status_enum` / `_validate_completion`; Layer 2 documented as enforced at `SubagentStop` while the hook runs only a structural check) are recorded with disposition "not filed". The updated SKILL.md bullet retains the `SubagentStop` enforcement sentence that follow-up 2 identifies as inaccurate. Recommendation: file both as potential entries.
- **O-3 (Advisory):** The branch is behind `origin/main` by the #804 merge. The trial merge is clean and touches no branch path, but the repository practice is to rebase on `main` and force-push with lease before opening the PR.
- **O-4 (Advisory):** `artifacts/python/lcov.info` is scoped to the two changed modules, so a repository-wide Python percentage is not available from the existing artifact. Per-file, changed-line, and no-regression gates are all supported.

Executor notes evaluated:

- [P2-T13] bundled-payload parity recorded as environmental-only: accepted. The single failing path is the git-ignored `.claude/state/python-batch-budget.worktree-agent-a86c4509777292c35-1c481456.json`, the rule was pre-declared in the plan, and the reviewer independently confirmed the two SKILL.md files share blob `53137cfd`. This failure mode is a known local-only condition that is green in CI.
- [P2-T10] per-test status read from a Jest JSON-reporter re-run: accepted. The JSON run used the same two files with exit code 0 and the same totals (47 passed); the reviewer's own re-run also returned 47 passed.
- [P2-T11] `sh -c` exit-code wrapper denied by the worktree-isolation hook: accepted. The wrapper was not a plan command, was not retried or routed around, and the denial text is recorded. The empty-output result is supported by a positive calibration query on the same pathspec.

## 9. Summary of Changes

- Production (Python): new `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py` (`feature_has_started`, `validate_wave_barrier_ordering`, `MERGED_STATUSES`); `scripts/dev_tools/validate_epic_orchestrator_state.py` now imports and calls the helper, and its private implementation was removed.
- Production (TypeScript): `hasStarted` predicate and start guard in `validateWaveBarrierOrdering`; two case-specific error strings.
- Tests: new Python and Jest parity suites over the shared fixture; two existing assertions updated to the new status-case string; frozen-surface digest for `.claude/skills/epic-orchestrate/SKILL.md` re-baselined with a comment.
- Documentation: epic skill Layer 2 bullet and bundled mirror describe the guard and both strings.
- Feature folder: issue, plan, research, and evidence artifacts.

## 10. Compliance Verdict

**PASS.** Blocking findings: 0. Non-blocking observations: 4 (O-1 Minor; O-2, O-3, O-4 Advisory).

## Appendix A: Test Inventory

| Suite | Tests | Purpose |
|---|---|---|
| `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py` | 25 (1 count, 14 matrix, 8 predicate, 2 direct) | Start-guard matrix parity, predicate branches, unhashable status, skip paths |
| `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts` | 16 (1 count, 14 matrix, 1 direct) | Same matrix through the TypeScript port; unhashable status |
| `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` | existing; 1 assertion updated | Status-case string |
| `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts` | existing; 1 assertion updated | Status-case string |
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | existing; digest updated in expectations module | Frozen-surface pin |

## Appendix B: Toolchain Commands Reference

| Purpose | Command |
|---|---|
| Evidence location scan | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` |
| Python format | `poetry run black --check <5 changed Python files>` |
| Python lint | `poetry run ruff check <5 changed Python files>` |
| Python types | `poetry run pyright <5 changed Python files>` |
| Python tests | `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q -p no:cacheprovider` |
| TypeScript tests | `npm test --prefix extensions/drm-copilot -- test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts test/lib/validate/epic-orchestrator-state-core.test.ts --coverage=false` |
| Fixture format probe | `npx --prefix extensions/drm-copilot prettier --check <changed TS files> tests/fixtures/epic_wave_barrier/start-guard-matrix.json` |
| Root format probe | `npm run format:check` |
| Merge probe | `git merge-tree --write-tree --name-only origin/main HEAD` |

The reviewer backed up `artifacts/python/lcov.info` before the pytest re-run and confirmed with `cmp` that it was not modified.
