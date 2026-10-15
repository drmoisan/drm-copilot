# Policy Audit — Issue #523 (Remediation Cycle 1 Re-Audit, R4)

- Timestamp: 2026-10-01T11-15
- Issue: #523 (epic #771 child), `blocked_reason` cannot express a premise-falsified halt
- Work mode: `full-bug` (AC source: `spec.md` `## Acceptance Criteria`)
- Review branch: local `resume-523-r2`, tracking remote `bug/blocked-reason-premise-falsified-halt-523-r2`
- Review head: `d65fa64afcd2e1263bfdb228d00c7c09a1b69f58`
- Base: `origin/epic/orchestrator-state-contract-correctness-integration` (scope: `git diff origin/epic/orchestrator-state-contract-correctness-integration...HEAD`, 165 paths)
- Plans: `plan.2026-09-29T15-52.md` (main), `remediation-plan.2026-09-30T15-20.md` (cycle 1)
- Cycle 1 input: `remediation-inputs.2026-09-30T15-20.md` (finding F1)

## Executive Summary

The branch extends the orchestrator-state `blocked_reason` vocabulary with five non-mechanical members in all three validator runtimes (Python authoritative, PowerShell repository and bundled copies, TypeScript), publishes a three-way partition, adds two case-sensitivity corrections in PowerShell and a non-string guard in Python, and documents the vocabulary in the approved rules and skill documents with byte-identical bundled mirrors.

Cycle 1 finding F1 (the #673 exact 499-line pin in `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` failing after the approved `OrchestratorState.psm1` edit) is resolved. The pin was replaced by a 500-line cap bound (`Should -BeGreaterThan 0`, `Should -BeLessOrEqual 500`). The reviewer verified the row passes in the iteration 2 full Pester JUnit output (6201 tests, 2 failures, both in the pre-existing P0-T26 set).

Coverage was verified for all three changed languages against the raw coverage artifacts produced by the iteration 2 QA loop, and every threshold is met. No FAIL and no blocking PARTIAL findings were identified.

- FAIL findings: 0
- Blocking PARTIAL findings: 0
- blocking_count: 0
- Verdict: COMPLIANT

## Rejected Scope Narrowing

No scope narrowing was detected in the caller prompt. The caller stated "Review scope: the full branch diff against the integration branch." The caller's statement that the two pre-existing Pester failures in `evidence/baseline/poshqc-test-baseline.md` are out of scope concerns test cases in files this branch does not modify (`enforce-pr-author-skill.ps1` and the Codex PreToolUse handler suite); it does not exclude any language, file, or toolchain stage from the audit. The reviewer confirmed both failures are present at the baseline (P0-T26) on the unmodified tree and that neither failing test file is in the branch diff.

## Standing Constraints Evaluated

| Constraint | Result | Evidence |
|---|---|---|
| Operator decision 2026-09-30 (OD-523-2, OD-523-4): edits to `.claude/rules/orchestrator-state.md` and its bundled mirror are approved; no other policy file may be modified | PASS | `git diff --name-status` over `.claude/rules`, `.github`, `.claude/hooks` lists only `M .claude/rules/orchestrator-state.md`; the hunk adds only `## Blocked-Reason Vocabulary` between `## Invariants (human_interaction block)` and `## Complexity-Assessment Scope and Backward Compatibility`; `## Enforcement` has no hunk. The checkpoint `artifacts/orchestration/orchestrator-state.json` contains the OD-523-2 and OD-523-4 decisions. |
| EA-4: member names exactly `premise_falsified`, `external_dependency`, `policy_hold`, `awaiting_ci`, `human_decision_required` | PASS | Identical literals in `scripts/dev_tools/_orchestrator_state_blocked_reason.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts`, both `OrchestratorState.psm1` copies, and `tests/fixtures/orchestrator_state_blocked_reason_partition.json`. |
| EA-5: issue #769 files untouched; no enforcement hook gains a Python leg | PASS | No path under `.claude/hooks/` and no batch-budget file appears in the branch diff. |
| Pre-existing Pester failures (P0-T26 set) out of scope | Accepted | Iteration 2 JUnit failing set equals the P0-T26 set exactly; no new failure. |

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Result | Evidence |
|---|---|---|
| Independence | PASS | New tests build in-memory checkpoints or read committed fixtures; no shared mutable state between cases. |
| Isolation | PASS | Each test targets one function (classifier, membership check, readiness check, completion check) or one corpus case. |
| Fast execution | PASS | Reviewer run: 206 Python tests in 1.70 s; 273 Jest tests in 1.34 s. |
| Determinism | PASS | No clock, RNG, sleep, or timer usage (reviewer grep over all new test files: zero matches for `setTimeout`, `Date.now`, `Start-Sleep`). |
| Readability | PASS | Arrange / Act / Assert comments, descriptive names, assertion messages on Python docs-drift tests. |

### 1.2 Coverage

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 2 production (1 new, 1 modified), 3 new test files | pytest full suite + targeted | 5885 passed, 6 skipped, 0 failed | line 98.82%, branch 97.56% (`validate_orchestrator_state.py`) | line 98.82%, branch 97.56% (`validate_orchestrator_state.py`); repo-wide `scripts.dev_tools` line 93.37%, branch 90.47% | new module line 100.00%, branch 100.00%; changed lines all covered |
| TypeScript | 2 production (1 new, 1 modified), 1 config, 3 new test files | Jest full suite with coverage | 3457 passed, 0 failed | repo-wide line 97.03%, branch 91.19%; core line 98.93%, branch 96.15% | repo-wide line 97.04%, branch 91.21%; core line 98.91%, branch 96.25% | new module line 100.00%, branch 100.00%; added core lines 2 and 32 hit |
| PowerShell | 2 production (repository and bundled copy, byte-identical), 3 new and 1 modified test files | full PoshQC Pester + targeted | 6201 tests, 2 failures (both pre-existing), 0 errors | `OrchestratorState.psm1` line 100.00% (109/109) | `OrchestratorState.psm1` line 100.00% (110/110); repo-wide line 96.25% (10689/11105) | changed lines 97, 98, 99, 286, 329 all ci > 0 (100.00%) |

Coverage evidence checklist:

- Python baseline coverage artifact: `evidence/baseline/python-coverage-derived-baseline.md` (derived from `artifacts/python/coverage-523-baseline.json`)
- Python post-change coverage artifact: `evidence/qa-gates/python-coverage-derived-final.md` and `evidence/qa-gates/pytest-full-final.md`; raw `artifacts/python/lcov.info` and `artifacts/python/coverage-523-final.json` in the executor worktree, parsed by the reviewer
- TypeScript baseline coverage artifact: `evidence/baseline/jest-coverage-baseline.md` and `evidence/baseline/jest-coverage-core-derived-baseline.md`
- TypeScript post-change coverage artifact: `evidence/qa-gates/jest-coverage-final.md` and `evidence/qa-gates/jest-coverage-derived-final.md`; raw `extensions/drm-copilot/coverage/lcov.info` in the executor worktree, parsed by the reviewer
- PowerShell baseline coverage artifact: `evidence/baseline/pester-orchestrator-state-baseline.md` (JaCoCo `artifacts/pester/coverage-523-baseline.xml`)
- PowerShell post-change coverage artifact: `evidence/qa-gates/pester-orchestrator-state-coverage-final.md`; raw `artifacts/pester/powershell-coverage.xml` (full PoshQC run, iteration 2) and `artifacts/pester/coverage-523-final.xml` in the executor worktree, parsed by the reviewer
- Per-language comparison summary: see 1.2.1; all three languages PASS with no regression on changed lines

Raw-artifact location note: this review worktree is a fresh resume worktree and does not hold the gitignored raw coverage files. The raw files produced by the iteration 2 QA loop remain in the executor worktree registered for `bug/blocked-reason-premise-falsified-halt-523-r2` (HEAD `d6d2860b`). The reviewer confirmed that `git diff --name-status d6d2860b HEAD -- scripts tests .claude .agents extensions` prints nothing, so those artifacts measure exactly the reviewed code, and parsed them directly (read-only). The parsed values match the committed evidence.

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: `validate_orchestrator_state.py` line 98.82%, branch 97.56%. Post-change: line 98.82%, branch 97.56%; repo-wide `scripts.dev_tools` line 93.37% (15862/16989), branch 90.47% (5535/6118). Change: 0.00 points on the modified file. New/changed-code coverage: `_orchestrator_state_blocked_reason.py` line 100.00% (15/15), branch 100.00% (8/8); added lines {10, 340-343} have no intersection with the two uncovered lines (116, 130). Disposition: PASS. Evidence: `evidence/qa-gates/coverage-comparison-python.md`, raw `artifacts/python/lcov.info` (reviewer parse: LF 170 LH 168 BRF 82 BRH 80; LF 15 LH 15 BRF 8 BRH 8).
- TypeScript: Baseline: repo-wide line 97.03%, branch 91.19%; `orchestrator-state-core.ts` line 98.93%, branch 96.15%. Post-change: repo-wide line 97.04%, branch 91.21%; `orchestrator-state-core.ts` line 98.91%, branch 96.25%. Change: repo-wide +0.01 line, +0.02 branch; core -0.02 line (nine covered set-literal lines moved out; uncovered count unchanged at 5) and +0.10 branch. New/changed-code coverage: `orchestrator-state-blocked-reason.ts` line 100.00% (74/74), branch 100.00% (10/10); added core lines 2 and 32 have hit count 1. Disposition: PASS. Evidence: `evidence/qa-gates/coverage-comparison-typescript.md`, raw `extensions/drm-copilot/coverage/lcov.info` (reviewer parse: repo 49902/51424 lines, 7234/7931 branches).
- PowerShell: Baseline: `OrchestratorState.psm1` line 100.00% (109/109). Post-change: `OrchestratorState.psm1` line 100.00% (110/110); repo-wide line 96.25% (10689/11105). Change: 0.00 points on the modified file. New/changed-code coverage: 100.00% of changed executable lines (97, 98, 99, 286, 329; `mi` 0, `ci` > 0). Branch coverage is not measured by Pester and no branch threshold applies. Disposition: PASS. Evidence: `evidence/qa-gates/coverage-comparison-powershell.md`, raw `artifacts/pester/powershell-coverage.xml` (reviewer parse: repo LINE covered 10689, missed 416; module LINE covered 110, missed 0).

### 1.2.2 Coverage Exclusion Policy

PASS. The only coverage-configuration change is a new per-file `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs` for `./src/lib/validate/orchestrator-state-blocked-reason.ts` (`lines: 85`, `branches: 75`). No `exclude` or `coveragePathIgnorePatterns` entry was added.

### 1.3 Scenario Completeness

PASS. Positive (each member accepted), negative (out-of-enum string, integer, list, dict), edge (case variants, `null`, absent key), error-handling (`ValueError` / `RangeError` prefixes), and gate behavior (completion and readiness for each new member) are covered in all applicable runtimes. A 20-case parity corpus and a 9-stem back-compat corpus cover cross-runtime equality.

### 1.4 Temporary Files and External Dependencies

PASS. Reviewer grep over the nine new test files found no `tmp_path`, `tempfile`, `TestDrive`, `New-TemporaryFile`, `os.tmpdir`, or file-write call. Fixtures are committed and read in place.

### 1.5 Test File Location

PASS. Python tests under `tests/scripts/dev_tools/`, Pester tests under `tests/scripts/claude-lib/orchestrator-state/`, Jest tests under `extensions/drm-copilot/test/lib/validate/` (mirroring `src/lib/validate/`).

## 2. General Code Change Policy Compliance

| Rule | Result | Evidence |
|---|---|---|
| Simplicity / separation of concerns | PASS | Vocabulary moved into dedicated pure modules (Python, TypeScript) with no I/O; validators import the union. |
| Reusability | PASS | Single source per runtime; `orchestrator-state-core.ts` re-exports the constant; Python validator imports it. |
| Public API compatibility | PASS | `validate_orchestrator_state.VALID_BLOCKED_REASONS` and the TypeScript `VALID_BLOCKED_REASONS` export remain importable (reviewer-run tests `test_validator_consumes_the_module_constant` and the Jest core-identity case pass). |
| Error handling | PASS | Classifiers raise specific exceptions with a fixed prefix; validator messages and ordering unchanged (AC-13 byte-identity evidence). |
| 500-line limit | PASS | Reviewer `wc -l`: `OrchestratorState.psm1` 492 (both copies), `orchestrator-state-core.ts` 458, `validate_orchestrator_state.py` 429, new production 80 / 74, new tests 124-302, modified cap test 167. |
| Dependencies | PASS | No new dependency. |
| Policy files unmodified (except approved) | PASS | See Standing Constraints. |

## 3. Language-Specific Code Change Policy Compliance

| Language | Result | Evidence |
|---|---|---|
| Python | PASS | Module docstring with Purpose / Usage / Invariants / Side Effects; `from __future__ import annotations`; full type hints (`frozenset[str]`, `Literal`); Google-style function docstring. Black: `539 files would be left unchanged`; Ruff: `All checks passed!`; Pyright: `0 errors, 0 warnings, 0 informations`. |
| TypeScript | PASS | JSDoc on all exports; `ReadonlySet<string>`; `unknown` parameter with type narrowing; no `any`. Prettier, ESLint, and TSC clean (`evidence/qa-gates/prettier-final.md`, `eslint-final.md`, `tsc-final.md`). |
| PowerShell | PASS | Case-sensitive operators (`-cnotcontains`, `-cne`) applied on the edited lines; `Export-ModuleMember` unchanged; no new module. Invoke-Formatter parity `True`; PSScriptAnalyzer `Findings=0 Errors=0` on changed files (`evidence/qa-gates/poshqc-format-final.md`, `pssa-direct-final.md`, `r1-format-after.md`, `r1-analyze-after.md`). |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Result | Evidence |
|---|---|---|
| Python | PASS | pytest, parametrized enumeration in lieu of property-based tests (documented in the module docstring: `hypothesis` is not a repository dependency). Reviewer run: 206 passed across the three new files plus `test_validate_orchestrator_state.py` and the four bundle/guardrail contract suites. |
| TypeScript | PASS | Jest suites for partition, parity corpus, and back-compat. Reviewer run: 8 suites, 273 passed. |
| PowerShell | PASS | Pester 5 with `-ForEach` data-driven cases, `InModuleScope` for the private readiness function and script-scoped arrays, in-memory checkpoints. Iteration 2 full run: all 99 blocked-reason-related cases passed. |

## 5. Test Coverage Detail

See section 1.2 and 1.2.1. Summary by file:

| File | Line | Branch |
|---|---|---|
| `scripts/dev_tools/_orchestrator_state_blocked_reason.py` (new) | 100.00% | 100.00% |
| `scripts/dev_tools/validate_orchestrator_state.py` (modified) | 98.82% | 97.56% |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-blocked-reason.ts` (new) | 100.00% | 100.00% |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` (modified) | 98.91% | 96.25% |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` (modified; bundled copy byte-identical) | 100.00% | not measured by Pester |

Repo-wide: Python (`scripts.dev_tools`) line 93.37%, branch 90.47%; TypeScript line 97.04%, branch 91.21%; PowerShell line 96.25%. All at or above 85% line and 75% branch.

## 6. Test Execution Metrics

| Suite | Result | Source |
|---|---|---|
| pytest full (`--cov=scripts.dev_tools --cov-branch`) | 5885 passed, 6 skipped, 0 failed | `evidence/qa-gates/pytest-full-final.md` |
| pytest targeted coverage | 749 passed | `evidence/qa-gates/pytest-targeted-coverage-final.md` |
| Jest full with coverage | 242 suites, 3457 passed | `evidence/qa-gates/jest-coverage-final.md` |
| Full PoshQC Pester | 6201 tests, 2 failures (P0-T26 set), 0 errors | `evidence/qa-gates/poshqc-test-final.md`; reviewer JUnit parse |
| Pester targeted (`OrchestratorState.psm1` coverage) | 487 passed | `evidence/qa-gates/pester-orchestrator-state-coverage-final.md` |
| F1 target file | `Passed=8 Failed=0` (before fix `Passed=7 Failed=1`) | `evidence/regression-testing/r1-cap-test-after.md`, `r1-cap-test-before.md` |
| Reviewer re-run, Python (no coverage) | 206 passed | this audit, Appendix B |
| Reviewer re-run, Jest (no coverage) | 8 suites, 273 passed | this audit, Appendix B |

## 7. Code Quality Checks

| Stage | Python | TypeScript | PowerShell |
|---|---|---|---|
| Format | PASS (Black) | PASS (Prettier) | PASS (Invoke-Formatter) |
| Lint | PASS (Ruff) | PASS (ESLint) | PASS (PSScriptAnalyzer) |
| Type check | PASS (Pyright) | PASS (TSC) | not applicable to PowerShell |
| Architecture | PASS (no tool configured; recorded at P0-T16) | PASS (`evidence/qa-gates/architecture-final.md`) | not applicable |
| Unit tests | PASS | PASS | PASS (failures limited to P0-T26 set) |
| Contract | PASS (98 passed) | PASS (72 passed) | PASS (`Passed=64 Failed=0`) |
| Integration | PASS (bundle contract tests 38 passed) | PASS | PASS (manifest `Passed=6 Failed=0`) |

Source: `evidence/qa-gates/toolchain-summary.md` (final QA loop iteration 2, no stage failed or changed a file). The contract and integration artifacts predate the loop; the summary records that the only code path changed since they ran is the F1 test file, which none of those commands executes. The reviewer re-ran the bundle and guardrail contract suites at the review head (Appendix B) and they pass.

## Evidence Location Compliance

PASS. `poetry run python -m scripts.dev_tools.validate_evidence_locations --root <worktree>` exited 0 with no output. The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (the diff contains no `artifacts/` path at all). All feature evidence is under `docs/features/active/2026-09-29-blocked-reason-premise-falsified-halt-523/evidence/{baseline,qa-gates,regression-testing,other,remediation-baseline}/`. Raw tool outputs written under `artifacts/python/` and `artifacts/pester/` during execution are gitignored tool outputs, not committed evidence.

## 8. Gaps and Exceptions

- Pre-existing Pester failures (accepted, out of scope): `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` and `Every registered Codex PreToolUse handler accepts every tool name its matcher admits...`. Both fail at P0-T26 on the unmodified tree; neither test file is in the branch diff.
- AC-24 wording ("no failing stage in a single pass"): the Pester stage reports `EXIT_CODE: 1` equal to its declared `ExpectedExitCode: 1` because of the two pre-existing failures. Under the standing constraint this is accepted and is not counted as a failing stage attributable to this branch.
- Python repo-wide coverage is measured over `scripts.dev_tools` (the pytest `--cov` scope used by the plan), which contains every Python file this branch changes.
- Raw coverage artifacts reside in the executor worktree rather than this review worktree (see 1.2). Verified by direct parse; no gap in evidence.
- Recorded follow-ups (not part of #523): `evidence/other/follow-ups.md` items 1-6.
- PR context artifacts (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`) are absent in this worktree. The reviewer used the authoritative `git diff origin/epic/orchestrator-state-contract-correctness-integration...HEAD` directly as the scope source, which is the same diff those artifacts summarize.

## 9. Summary of Changes

- Python: new `_orchestrator_state_blocked_reason.py` (partition constants, `classify_blocked_reason`); `validate_orchestrator_state.py` imports the constant and adds a non-string guard.
- TypeScript: new `orchestrator-state-blocked-reason.ts` (partition constants, `classifyBlockedReason`); `orchestrator-state-core.ts` imports and re-exports the constant; `jest.config.cjs` adds a per-file threshold.
- PowerShell: `OrchestratorState.psm1` (both copies) grouped arrays and `-cnotcontains` / `-cne`.
- Documentation: rules section and skill guidance with bundled mirrors (all five pairs byte-identical by reviewer `cmp`).
- Tests and fixtures: 9 new test files, 20 parity corpus cases, 9 back-compat fixtures plus expected file, partition oracle.
- Remediation cycle 1: `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` pin replaced by the 500-line cap bound; change-set amendment recorded in `evidence/other/change-set-amendment-p7-t14.md`.

## 10. Compliance Verdict

COMPLIANT.

- FAIL findings: 0
- Blocking PARTIAL findings: 0
- blocking_count: 0
- Cycle 1 finding F1: RESOLVED (verified from the iteration 2 JUnit output: the row `the orchestrator-state module stays within the 500-line file cap` passed; the former `four hundred ninety-nine line count` row no longer exists).
- Coverage: Python PASS, TypeScript PASS, PowerShell PASS.
- No remediation inputs are required.

## Appendix A: Test Inventory

| Test file | Runtime | Purpose |
|---|---|---|
| `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py` | pytest | Partition disjointness, union, oracle equality, classifier branches, `test_docs_` drift tests |
| `tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py` | pytest | New members in plain / completion / readiness; list and dict guard; back-compat corpus |
| `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason_parity.py` | pytest | Parity corpus reader |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason.test.ts` | Jest | Partition, classifier, oracle, core re-export identity |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason-parity.test.ts` | Jest | Parity corpus reader |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-blocked-reason-backcompat.test.ts` | Jest | Back-compat byte identity |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Tests.ps1` | Pester | Membership, case variants, readiness, grouped arrays, completion |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Parity.Tests.ps1` | Pester | Parity corpus reader |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateBlockedReason.Backcompat.Tests.ps1` | Pester | Back-compat byte identity |
| `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` (modified) | Pester | F1 fix: 500-line cap bound |

## Appendix B: Toolchain Commands Reference

Reviewer-run commands (review head `d65fa64a`):

- `git diff --stat origin/epic/orchestrator-state-contract-correctness-integration...HEAD` — 165 files.
- `git diff --name-status origin/epic/orchestrator-state-contract-correctness-integration...HEAD -- .claude/hooks .github .claude/rules tests/scripts/claude-hooks` — one line, `M .claude/rules/orchestrator-state.md`.
- `cmp` of each of the five repository / bundle pairs — all identical.
- `wc -l` over the changed code files — maximum 492.
- `git diff --name-status d6d2860b HEAD -- scripts tests .claude .agents extensions` — empty (code identical to the executor head that produced the raw coverage).
- Read-only parse of the executor worktree `artifacts/pester/powershell-coverage.xml`, `extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`, and `artifacts/pester/pester-junit.xml` — values listed in 1.2.1 and section 6.
- `poetry run pytest --no-cov -q -p no:cacheprovider` over the three new Python test files, `test_validate_orchestrator_state.py`, `test_orchestration_guardrail_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_skill_bundle_contract_repo.py` — 206 passed.
- `npx jest --coverage=false orchestrator-state-blocked-reason orchestrator-state-core` (extension config) — 8 suites, 273 passed.
- `poetry run python -m scripts.dev_tools.validate_evidence_locations --root <worktree>` — exit 0.

Executor commands are recorded verbatim in each `evidence/**` artifact's `Command:` line.
