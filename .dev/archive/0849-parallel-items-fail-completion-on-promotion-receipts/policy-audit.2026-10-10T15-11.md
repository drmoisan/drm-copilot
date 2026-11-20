# Policy Audit: parallel-items-fail-completion-on-promotion-receipts (Issue #849)

- Issue: #849
- Branch: bug/parallel-items-fail-completion-on-promotion-receipts-849
- Head: 5cbc47a0c3e846172300fd301af26db0ddfc94db
- Base: origin/main @ 0ea7978a79b2ef5b237043923bff299e2b45cddf (merge base 0ea7978a79b2ef5b237043923bff299e2b45cddf)
- Diff anchor: `git diff origin/main...HEAD` (merge commits 3412e7f5a and baf63356b carry main-side content and are excluded by the three-dot range)
- Work Mode: full-bug (AC source: `spec.md` only)
- Reviewer: feature-review agent
- Audit timestamp: 2026-10-10T15-11 (UTC)

## Executive Summary

The branch relaxes rule 9 of the `issue_adoption` resolver in three runtimes (Python authority, TypeScript port, PowerShell port plus its bundled mirror) so that `potential_record` may be absent when `origin` is `transferred` or `filed_before_orchestration`, adds five shared corpus fixtures, extends unit and parity tests in all three runtimes, adds a Python skill-contract test, and updates five `.claude/**` skill/rule documents with byte-identical bundled mirrors.

Policy compliance verdict: **PASS**. Blocking findings: 0. Non-blocking findings: 6 (listed in section 8).

Every language with changed files has an explicit coverage verdict:

| Language | Coverage verdict |
|---|---|
| Python | PASS |
| TypeScript | PASS |
| PowerShell | PASS |
| C# | N/A (zero changed files on the branch) |

## Rejected Scope Narrowing

None detected. The caller prompt supplied the base branch, head SHA, PR context bundle, and the instruction to anchor diffs with `--merge-base origin/main`. These match the authoritative scope sources and do not narrow the audit. The audit covers all 94 files in `git diff origin/main...HEAD`.

## Evidence Location Compliance

- Command: `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no violations reported.
- Command: `git diff --name-only origin/main...HEAD -- artifacts` — no output. No branch file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence is under `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/{baseline,regression-testing,other,qa-gates}/`.
- Absolute host path scan of the feature folder (patterns `[A-Za-z]:[\\/]Users`, `/home/runner`, user-profile repo path): 0 matches.
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries were required.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence / isolation | PASS | Each new test builds its own adoption record and state via helpers (`build_adoption`, `adoption()`, `Get-AdoptionRecord`); no shared mutable state. |
| Determinism | PASS | No clock, RNG, timer, or sleep usage in any new test (TS origin test header states this; verified by reading all three test diffs). |
| Arrange-Act-Assert | PASS | Python and TypeScript tests carry explicit `# Arrange / # Act / # Assert` sections; Pester cases are three-line arrange/act/assert. |
| Scenario completeness | PASS | Positive (transferred, filed_before_orchestration, preparation route), negative (epic_decomposition without record, null record, invalid path), and edge (invalid origin) cases in every runtime. |
| No temporary files | PASS | Skill-contract test reads committed repository files only; no temp file creation in any new test. |
| Test file location | PASS | Tests under `tests/` and `extensions/drm-copilot/test/` mirror production structure. |
| Coverage thresholds | PASS | See section 1.2.1 and section 5. |

### 1.1 Coverage artifacts

- TypeScript baseline coverage artifact: evidence/baseline/ts-coverage-output.2026-10-09T01-33.txt (module row 100% lines / 100% branch)
- TypeScript post-change coverage artifact: evidence/qa-gates/ts-coverage-output.2026-10-09T01-33.txt (module row 100% lines / 100% branch; totals 97.25% lines, 92.07% branches)
- PowerShell baseline coverage artifact: evidence/baseline/poshqc-local/powershell-coverage.xml (OrchestratorStateIssueAdoption.psm1 LINE 112/112 = 100.00%)
- PowerShell post-change coverage artifact: evidence/qa-gates/poshqc-local/powershell-coverage.xml (OrchestratorStateIssueAdoption.psm1 LINE 116/116 = 100.00%; run scope 13940/15837 = 88.02%)
- Python baseline coverage artifact: evidence/baseline/py-adoption-coverage.2026-10-09T01-33.json and evidence/baseline/py-full-coverage.2026-10-09T01-33.json
- Python post-change coverage artifact: evidence/qa-gates/py-adoption-coverage.2026-10-09T01-33.json and evidence/qa-gates/py-full-coverage.2026-10-09T01-33.json
- Per-language comparison summary: section 1.2.1; all three changed languages at 100.00% line coverage on the changed production module with no regression.

### 1.2 Coverage metrics table

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| Python | 4 (1 production modified, 2 tests modified, 1 test added) | 156 targeted (reviewer re-run); 6870 full suite (executor) | PASS (0 failed) | 100.00% line / 100.00% branch (module); 93.755% / 88.038% (scripts.dev_tools) | 100.00% line / 100.00% branch (module); 93.756% / 88.042% (scripts.dev_tools) | 100.00% (3/3 instrumented added lines) |
| TypeScript | 3 (1 production modified, 1 test added, 1 test modified) | 86 targeted (reviewer re-run); 3981 full suite (executor) | PASS (0 failed) | 100% line / 100% branch (module) | 100% line / 100% branch (module); 97.25% line / 92.07% branch repo | 100% (30 added lines, none uncovered) |
| PowerShell | 4 (1 production modified, 1 bundled mirror modified, 2 tests modified) | 3051 across three scan folders (CI run 38060952234) | PASS (0 failures) | 100.00% line (112/112, module) | 100.00% line (116/116, module); 88.02% line run scope | 100.00% (6/6 instrumented added lines) |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 100.00% line / 100.00% branch for `scripts/dev_tools/_orchestrator_state_issue_adoption.py` (113/113, 46/46); Post-change: 100.00% line / 100.00% branch (116/116, 48/48), reproduced by the reviewer at 100%; Change: 0.00 points, no regression; repo scope `scripts.dev_tools` 93.755% -> 93.756% line, 88.038% -> 88.042% branch; New/changed-code coverage: 100.00% (3/3 instrumented added lines 74, 255, 260); Disposition: PASS; Evidence: evidence/qa-gates/py-coverage-delta.2026-10-09T01-33.md, evidence/qa-gates/py-full-suite.2026-10-09T01-33.md
- TypeScript: Baseline: 100% line / 100% branch for `orchestrator-state-issue-adoption.ts`; Post-change: 100% line / 100% branch, reproduced by the reviewer at 100%; Change: 0 points, no regression; repo totals 97.25% line / 92.07% branch; New/changed-code coverage: 100% (no added line in Uncovered Line #s); Disposition: PASS; Evidence: evidence/qa-gates/ts-coverage-delta.2026-10-09T01-33.md, evidence/qa-gates/ts-coverage.2026-10-09T01-33.md
- PowerShell: Baseline: 100.00% line for `OrchestratorStateIssueAdoption.psm1` (112/112); Post-change: 100.00% line (116/116), confirmed by the reviewer from the coverage XML counter; Change: 0.00 points, no regression; run-scope line 88.02% (13940/15837); New/changed-code coverage: 100.00% (6/6 instrumented added lines); branch threshold does not apply because Pester measures no branch coverage; Disposition: PASS; Evidence: evidence/qa-gates/ps-coverage-delta.2026-10-09T01-33.md, evidence/qa-gates/ps-test-coverage.2026-10-09T01-33.md

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity | PASS | One early-return guard per runtime in the rule-9 helper; one new constant per runtime. |
| Reusability / parity | PASS | Same constant name and guard semantics in Python, TypeScript, PowerShell; shared corpus enforces parity. |
| Separation of concerns | PASS | Resolver modules remain pure; no I/O added (spec explicitly rejects a file-existence check). |
| Fail-fast / error handling | PASS | Error strings unchanged; fail-closed behavior (any error empties waived set) unchanged. Verified by reading the production diff: no `ERROR_*` constant or message literal is added, removed, or altered. |
| File size <= 500 lines | PASS | Production: 352 (py), 324 (ts), 396 (psm1). Tests: 338, 268, 241, 434. |
| Public API compatibility | PASS | Changed helpers are private (`_potential_record_errors`, non-exported `potentialRecordErrors`, non-exported `Get-AdoptionPotentialRecordError`). Exported surfaces unchanged. |
| Dependencies | PASS | No new dependency. |
| Policy documents unmodified | PASS | No file under `.github/instructions/` or `.claude/rules/` policy set is changed except `.claude/rules/orchestrator-state.md`, which is a repo-owned contract document edited under explicit spec scope (`spec.md` Scope and AC-13). |

## 3. Language-Specific Code Change Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| Python | Black / Ruff / Pyright clean | PASS | Reviewer re-run: `black --check` 4 files unchanged; `ruff check` all checks passed; `pyright` 0 errors, 0 warnings. |
| Python | Typed signatures, keyword-only flags | PASS | `origin: object`, `record_present: bool` declared keyword-only. |
| TypeScript | Prettier / ESLint / tsc clean | PASS | Reviewer re-run: `prettier --check` clean on three files; `npm run lint` clean; `npm run typecheck` exit 0. |
| TypeScript | No untyped escape hatch | PASS | Parameters use `unknown` and `boolean`; no `any`. |
| PowerShell | PoshQC format / analyze | PASS | CI run 38060952234: FormatStep success, AnalyzeStep success. `Invoke-PoshQCAnalyze` throws on any finding at Error/Warning/Information severity (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:181-184`), so success implies zero findings. Local MCP format left all four file digests unchanged. |
| PowerShell | Case-sensitive comparison | PASS | Uses `-ccontains`, consistent with the ordinal, case-sensitive rule in `.claude/rules/orchestrator-state.md`. |

## 4. Language-Specific Unit Test Policy Compliance

| Language | Requirement | Verdict | Evidence |
|---|---|---|---|
| Python | Pytest, AAA, docstrings | PASS | 7 new waiver tests and 11 skill-contract cases each carry a docstring and AAA sections. |
| TypeScript | Jest, AAA, no fake-timer need | PASS | 7 origin cases; no timers used. |
| PowerShell | Pester 5, Describe/It naming | PASS | 7 new `It` cases in one `Describe` block; all `status="Passed"` in the sanitized JUnit. |
| All | Tier-dependent property tests | N/A | `scripts/dev_tools` is T4, `extensions/drm-copilot` is T3, `.claude/lib/orchestrator-state` is T3 (`quality-tiers.yml`); property tests are required only for T1/T2. |

## 5. Test Coverage Detail

| File | Status | Line | Branch | Threshold met | No regression |
|---|---|---|---|---|---|
| scripts/dev_tools/_orchestrator_state_issue_adoption.py | Modified | 100.00% (116/116) | 100.00% (48/48) | Yes | Yes |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts | Modified | 100% | 100% | Yes | Yes |
| .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | Modified | 100.00% (116/116) | n/a (Pester) | Yes | Yes |

Coverage exclusion check: no `exclude` configuration was changed on the branch; no production path was added to any exclusion list.

Reviewer note on canonical artifact paths: the reviewer's targeted pytest run rewrote the gitignored `artifacts/python/lcov.info` with a single-module measurement. The Python verdict above is based on the committed evidence JSON files and the reviewer's terminal output, not on that lcov file.

## 6. Test Execution Metrics

| Suite | Source | Result |
|---|---|---|
| Python targeted (waivers, parity, adoption, skill contracts, parallel surface/planner/seam contracts, push-down bundle test) | Reviewer re-run at head 5cbc47a0c | 156 passed, 0 failed |
| Python full suite | Executor P6-T5 | 6870 passed, 6 skipped, 0 failed (6821 + 23 + MERGE_ADDED_PY 26) |
| TypeScript adoption suites (unit, parity, origin) | Reviewer re-run | 3 suites, 86 tests passed |
| TypeScript full `test:coverage` | Executor P7-T5 | 267 suites, 3981 tests passed |
| Pester three scan folders | CI run 38060952234 (sanitized copy) | 122 suites, 3051 tests, 0 failures (reviewer confirmed 0 `<failure` elements) |
| Regression fail-before | Executor P2 | Python parity: 3 failed (D1, D2, D3) with rule-9 + missing-receipt errors; skill contracts: 8 failed |

## 7. Code Quality Checks

| Check | Python | TypeScript | PowerShell |
|---|---|---|---|
| Format | PASS (black) | PASS (prettier) | PASS (PoshQC format, CI) |
| Lint | PASS (ruff) | PASS (eslint) | PASS (PSScriptAnalyzer, CI) |
| Type check | PASS (pyright) | PASS (tsc) | N/A (no type checker) |
| Architecture boundary | No new imports across boundaries | No new imports | No new module imports |
| Contract / schema | Corpus parity: 34 fixtures, all pass in three runtimes | Same | Same |
| Mirror identity | `cmp` of all six `.claude/**` files against `extensions/drm-copilot/resources/claude-customizations/.claude/**`: identical (reviewer re-run) | | |

## 8. Gaps and Exceptions

No blocking gaps. Non-blocking items:

1. NB-1: `evidence/qa-gates/ps-analyze.2026-10-09T01-33.md` states that analyzer counts "come from the H1 Source A analyzer output read in P8-T5", but P8-T5 used Source B, which produces no analyzer output file. The substantive analyzer result (AnalyzeStep success) is valid; the sentence is stale.
2. NB-2: Phase 9 evidence files record `Timestamp:` values of 15-08 through 15-17 (UTC), but the commit that adds them (5cbc47a0c) was created at 2026-10-10T15:07:07Z. The recorded timestamps do not reflect wall-clock creation time.
3. NB-3: `/parallel-add` preparation children for issue-number items still lack the issue-adoption instruction. This is documented as out of scope (overlap with #843) in `spec.md` and `evidence/other/follow-up-parallel-add.2026-10-09T01-33.md`; the follow-up item has not yet been filed.
4. NB-4: The Python repo-wide figure is measured over `scripts.dev_tools` (the executor's `--cov` scope), not every Python package. The only changed Python production file is inside that scope, so the figure is sufficient for this change.
5. NB-5: PowerShell measurements come from CI (Source B) rather than a local host run. The sanitized copies were checked by the reviewer (file counter and failure count match the evidence summary).
6. NB-6: The promoted lifecycle record and `issue.md` `Status:` line point to `docs/features/active/parallel-items-fail-completion-on-promotion-receipts/` rather than the actual dated folder. This is promotion-tooling output and does not affect behavior.

## 9. Summary of Changes

- Production: rule-9 relaxation in `scripts/dev_tools/_orchestrator_state_issue_adoption.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`, `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` (and bundled mirror).
- Documentation contracts: `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/feature-promotion-lifecycle/SKILL.md`, `.claude/rules/orchestrator-state.md` (each mirrored byte-identically).
- Fixtures: five new corpus files under `tests/fixtures/orchestrator_state_issue_adoption/` (all added; no existing fixture modified).
- Tests: Python waivers (+7), parity floor 29 -> 34, new skill-contract test (11 cases); TypeScript new origin test (7), parity floor 29 -> 34; Pester unit (+7), parity floor 29 -> 34.
- Lifecycle: `docs/features/potential/promoted/2026-10-08-parallel-items-fail-completion-on-promotion-receipts.md`; feature folder documents, plan, research, and evidence.

## 10. Compliance Verdict

**PASS.** Blocking findings: 0. All three changed languages meet the uniform line (>= 85%) threshold and, where branch coverage is measured, the branch (>= 75%) threshold, with no regression on changed lines. Toolchains are clean. Evidence locations are canonical.

## Appendix A: Test Inventory

| Runtime | File | New / changed cases |
|---|---|---|
| Python | tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py | 7 new (filed_before_orchestration bug, transferred feature, preparation route, epic_decomposition, null record, invalid path, invalid origin) |
| Python | tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py | Floor 29 -> 34; 5 new parametrized corpus cases |
| Python | tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py | 11 cases (new file) |
| TypeScript | extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts | 7 cases (new file) |
| TypeScript | extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts | Floor 29 -> 34; 5 new corpus cases |
| PowerShell | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | 7 new `It` cases |
| PowerShell | tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | Floor 29 -> 34; 5 new corpus cases |

## Appendix B: Toolchain Commands Reference

Reviewer commands (check-only, run at head 5cbc47a0c):

- `poetry run pytest -q -p no:cacheprovider <8 targeted test targets> --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing` — 156 passed; module 100% line and branch.
- `poetry run black --check <4 Python files>`; `poetry run ruff check <4 Python files>`; `poetry run pyright <4 Python files>` — clean.
- `npm --prefix extensions/drm-copilot exec -- jest test/lib/validate/orchestrator-state-issue-adoption --coverage --collectCoverageFrom=src/lib/validate/orchestrator-state-issue-adoption.ts` — 86 passed; 100% all measures.
- `npm --prefix extensions/drm-copilot exec -- prettier --check <3 TS files>`; `npm --prefix extensions/drm-copilot run lint`; `npm --prefix extensions/drm-copilot run typecheck` — clean.
- `cmp` of six `.claude/**` files against bundled mirrors — identical.
- `git diff --name-status origin/main...HEAD -- tests/fixtures/orchestrator_state_issue_adoption/` — five `A` entries only.
- Corpus count: 34 by file enumeration and 34 by `"name"` content search.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0.

Executor commands are recorded in each evidence file under `evidence/`.
