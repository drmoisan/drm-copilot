# Policy Audit: Issue #889 (argument-less sort ordering and comparator coverage gaps)

- Timestamp: 2026-10-12T15-29
- Branch: `bug/argumentless-sort-ordering-and-comparator-coverage-gaps-889`
- Head: `ef38d9dcf55fce25eed9c5341dc1d5cd3f099633`
- Base: `origin/main` (diff computed with `git diff origin/main...HEAD`)
- Work mode: `minor-audit` (AC source: `issue.md`, `## Acceptance Criteria`)
- Review type: reduced minor-audit review (three artifacts; no remediation inputs required)
- Overall verdict: **PASS** (0 Blocking, 6 Non-blocking findings; findings are recorded in `code-review.2026-10-12T15-29.md`)

## Executive Summary

The branch diff against `origin/main` contains 65 paths: 38 under the feature folder (documentation and evidence) and 27 TypeScript code paths under `extensions/drm-copilot/` (12 modified production files under `src/lib/`, 12 modified and 3 created test files under `test/lib/`). No Python, PowerShell, C#, GitHub Actions, fixture, `package.json`, or `jest.config.cjs` path is changed.

The production change replaces 19 argument-less `.sort()` calls with `.sort(compareCodePoint)` and adds 11 imports of `compareCodePoint` from `"../string-ordering"`. The reviewer independently re-ran Prettier check, ESLint, both TypeScript type checks, and the 15 changed test files (161 tests); all exited 0. The reviewer parsed `extensions/drm-copilot/coverage/lcov.info` (written 2026-10-12 15:20, after the 15:18:54 code commit `ec8695761`; later commits are documentation-only). Every changed production file reports line coverage >= 95.69% and branch coverage >= 87.10%, and repo-wide TypeScript coverage is 97.27% lines and 92.29% branches.

All policy checks evaluated below are PASS. No blocking policy finding was identified.

## Rejected Scope Narrowing

No scope narrowing was detected. The caller prompt describes the scope as 12 production TypeScript files and 15 test files; this matches the full `origin/main...HEAD` code diff exactly (verified with `git diff --name-only origin/main...HEAD`). The "reduced" designation limits the artifact set to three files and does not narrow the audit scope or skip any toolchain or coverage check. The audit covered the full branch diff.

## Evidence Location Compliance

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported paths.
- The branch diff contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All evidence lives under `docs/features/active/2026-10-11-argumentless-sort-ordering-and-comparator-coverage-gaps-889/evidence/<kind>/` (`baseline`, `other`, `qa-gates`, `regression-testing`).
- Verdict: PASS.

## 1. General Unit Test Policy Compliance

Source: `.claude/rules/general-unit-test.md`.

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence and isolation | PASS | Each new test builds its own fixture (`buildInMemoryFileSystem`, `InMemoryFileSystem`, `SequencedReadFileSystem`, `GitStub`, literal state objects). No shared mutable state was added. |
| Determinism | PASS | No `setTimeout`, `Date.now`, `Math.random`, or wall-clock use in added lines (`git diff -G` scan returned no files). Null-arm fixtures run in both input orders, which removes dependence on engine operand order. |
| Arrange-Act-Assert | PASS | All 21 new tests carry explicit `// Arrange`, `// Act`, `// Assert` sections. |
| No temporary files | PASS | Reviewer read every added test; none imports `fs`, `os`, or calls `tmpdir`/`mkdtemp`. Executor search: `evidence/qa-gates/temp-file-search.2026-10-12T15-19.md` (0 matches). |
| No external dependencies | PASS | Filesystem and git access go through in-memory fakes and stubs. |
| Test file location mirrors source | PASS | Created files: `test/lib/resolve/file-prompt-transforms.test.ts`, `test/lib/validate/epic-orchestrator-state-core.ordering.test.ts`, `test/lib/validate/orchestrator-state-model-routing-existence.test.ts`, each mirroring its `src/lib/` path. No test file was placed under `src/`. |
| Scenario completeness for changed behavior | PASS | Each of the 14 observable sites has a positive ordering test; the 7 cited null-default arms have both-order tests; the `targetRole` tiebreak has a discriminating test. |
| Coverage exclusion policy | PASS | `jest.config.cjs` is unchanged on the branch; `collectCoverageFrom` remains `["src/**/*.ts", "!src/**/*.d.ts"]`. No production path is excluded. |

### 1.1 Coverage Thresholds

Line >= 85% and branch >= 75% apply uniformly (T1-T4). `extensions/drm-copilot` is classified T3 in `quality-tiers.yml`. All 12 changed production files meet both thresholds; no changed production file is new on this branch, so the new-file rule applies to none.

### 1.2 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 27 (12 production, 15 test) | 4002 (full suite, 270 suites) | PASS | 97.25% lines, 92.07% branches | 97.27% lines, 92.29% branches | 100% of the 19 changed sort lines executed |
| Python | 0 | N/A | N/A | N/A | N/A | N/A |
| PowerShell | 0 | N/A | N/A | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

Evidence checklist:

- TypeScript baseline coverage artifact: `evidence/baseline/ts-coverage.2026-10-12T15-03.md` (97.25% lines, 92.07% branches)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` parsed by the reviewer (97.27% lines, 92.29% branches); executor record `evidence/qa-gates/ts-coverage-per-file.2026-10-12T15-19.md`
- PowerShell baseline coverage artifact: N/A, zero PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A, zero PowerShell files changed on the branch
- Per-language comparison summary: TypeScript coverage rose on every changed production file or stayed equal; Python, PowerShell, and C# have zero changed files

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.25% lines / 92.07% branches. Post-change: 97.27% lines / 92.29% branches. Change: +0.02 points lines, +0.22 points branches; no changed production file decreased. New/changed-code coverage: 100% (all 19 converted sort lines executed). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/qa-gates/coverage-delta.2026-10-12T15-19.md`.

### 1.3 Per-File Coverage (reviewer-parsed from `coverage/lcov.info`)

| File (`src/lib/...`) | Status | Baseline lines | Post lines | Baseline branch | Post branch | Changed sort lines executed | Verdict |
|---|---|---|---|---|---|---|---|
| push-down/claude-pack-selection.ts | Modified | 100% | 100.00% (309/309) | 98% | 98.00% (49/50) | Yes | PASS |
| push-down/codex-pack-selection.ts | Modified | 98.33% | 98.37% (241/245) | 97.14% | 97.18% (69/71) | Yes | PASS |
| resolve/file-prompt-transforms.ts | Modified | 100% | 100.00% (206/206) | 86.66% | 87.10% (27/31) | Yes | PASS |
| subagent-tree/tree-assembler.ts | Modified | 99.45% | 99.46% (183/184) | 90% | 90.00% (18/20) | Yes | PASS |
| subagent-tree/tree-formatter.ts | Modified | 100% | 100.00% (34/34) | 100% | 100.00% (3/3) | Yes | PASS |
| validate/codex-topology-resolver.ts | Modified | 97.38% | 97.41% (263/270) | 94.73% | 94.74% (54/57) | Yes | PASS |
| validate/epic-orchestrator-state-core.ts | Modified | 97.96% | 98.78% (486/492) | 91.2% | 93.55% (87/93) | Yes | PASS |
| validate/epic-planner-git-integrity.ts | Modified | 100% | 100.00% (291/291) | 93.9% | 93.98% (78/83) | Yes | PASS |
| validate/orchestrator-state-codex-model-routing.ts | Modified | 95.67% | 95.69% (466/487) | 93.96% | 94.07% (111/118) | Yes | PASS |
| validate/orchestrator-state-codex-topology.ts | Modified | 96.27% | 96.28% (311/323) | 95.04% | 95.05% (96/101) | Yes | PASS |
| validate/orchestrator-state-core.ts | Modified | 98.9% | 98.91% (454/459) | 96.25% | 96.25% (77/80) | Yes | PASS |
| validate/orchestrator-state-model-routing-existence.ts | Modified | 100% | 100.00% (74/74) | 100% | 100.00% (22/22) | Yes | PASS |

Comparator files exercised by the new null-arm and target-role tests (not modified on the branch):

| File (`src/lib/codex-native-converter/...`) | Baseline branch | Post branch | Post lines |
|---|---|---|---|
| reporting-render.ts | 88.63% | 100.00% (44/44) | 100.00% |
| reporting.ts | 88% | 94.00% (47/50) | 100.00% |
| validation.ts | 84.9% | 92.59% (50/54) | 99.46% |
| engine-pipeline.ts | 84.78% | 84.78% (39/46) | 98.01% |

Changed-line execution: the reviewer confirmed that none of the 19 post-change sort lines listed in `evidence/qa-gates/coverage-delta.2026-10-12T15-19.md` appears in that artifact's `Uncovered Line #s` column. For files below 100% branch coverage, the uncovered entries are at lines unrelated to this change.

## 2. General Code Change Policy Compliance

Source: `.claude/rules/general-code-change.md`.

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity and reuse | PASS | The change reuses the existing `compareCodePoint` (`src/lib/string-ordering.ts:53`) rather than introducing a new comparator. |
| Separation of concerns | PASS | No I/O was introduced in production code. |
| Mandatory toolchain loop | PASS | Executor: single-pass Phase 2 loop with empty pass-start and pass-end diffs (`evidence/qa-gates/ts-prettier-check.2026-10-12T15-19.md`, `ts-coverage-per-file.2026-10-12T15-19.md`). Reviewer re-run: Prettier, ESLint, `tsc -p ./`, `tsc -p tsconfig.jest.json` all exit 0. Architecture, contract, and integration stages: no change to module boundaries, schemas, or adapters; the full Jest run includes the existing parity and corpus suites. |
| File size limit (500 lines) | PASS | Largest changed file: `validate/epic-orchestrator-state-core.ts` at 492 lines (reviewer `wc -l`). Largest test file: `validate/orchestrator-state-core.test.ts` at 425 lines. |
| Error handling | PASS | No error-handling paths were altered. Error message order now follows code-point order for supplementary-plane input. |
| Naming | PASS | New helpers (`SequencedReadFileSystem`, `writtenMessages`) and constants (`SKILL_TEXT`, `HOOK_TEXT`) are descriptive. |
| Public API compatibility | PASS | No public signature changed. Output order changes only where a supplementary-plane character is compared with a U+E000-U+FFFF character. |
| Dependencies | PASS | No dependency added; `package.json` and lockfile unchanged. |

## 3. Language-Specific Code Change Policy Compliance

Sources: `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`.

| Requirement | Verdict | Evidence |
|---|---|---|
| Prettier formatting | PASS | Reviewer: `npx prettier --check "src/**/*.ts" "test/**/*.ts"` printed `All matched files use Prettier code style!`, exit 0. |
| ESLint | PASS | Reviewer: `npx eslint --no-error-on-unmatched-pattern src test`, exit 0, no output. |
| Type checking (strict) | PASS | Reviewer: `npx tsc -p ./ --noEmit` exit 0; `npx tsc -p tsconfig.jest.json --noEmit` exit 0. |
| Suppressions | PASS | `git diff -U0 origin/main...HEAD -G "eslint-disable|@ts-|any|as unknown|setTimeout|Date.now|Math.random" --stat -- extensions/drm-copilot` returned no files. No new suppression, `any`, or double cast. |
| Untyped escape hatches (T3: <= 5 per file, justified) | PASS | Zero introduced. |
| Import style | PASS | All 11 new imports use the mandated form `import { compareCodePoint } from "../string-ordering";`. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Jest framework, `*.test.ts` naming | PASS | All 15 test files use `@jest/globals` and the `.test.ts` suffix. |
| No host runtime required | PASS | No Office.js or VS Code host API is used in the added tests. |
| Mocking practice | PASS | No `jest.mock` added; `SequencedReadFileSystem` subclasses the existing `InMemoryFileSystem` fake rather than mocking a module. |
| Snapshot tests | PASS | None added. |
| Property tests / mutation (tier-dependent) | PASS | Not required for T3. |

## 5. Test Coverage Detail

See sections 1.2, 1.2.1, and 1.3. Coverage verdict for TypeScript: **PASS**. Python, PowerShell, and C#: N/A (zero changed files on the branch).

## 6. Test Execution Metrics

| Run | Suites | Tests | Result | Source |
|---|---|---|---|---|
| Baseline full suite | 267 | 3981 | PASS | `evidence/baseline/ts-coverage.2026-10-12T15-03.md` |
| Post-change full suite with coverage | 270 | 4002 | PASS | `evidence/qa-gates/ts-test-coverage.2026-10-12T15-19.md` |
| Red run against unconverted sources (`-t 889-cp-order`) | 11 | 14 failed | Expected fail | `evidence/regression-testing/cp-order-red.2026-10-12T15-03.md` |
| Target-role mutation (`return 0` at `engine-pipeline.ts:241`) | 1 | 1 failed | Expected fail | `evidence/regression-testing/target-role-mutation-red.2026-10-12T15-03.md` |
| Reviewer re-run of the 15 changed test files | 15 | 161 passed | PASS | This audit (2026-10-12T15-29) |

The suite increase (+3 suites, +21 tests) matches the 3 created files and 21 added tests (14 `889-cp-order`, 6 `889-null-arm`, 1 `889-target-role`).

## 7. Code Quality Checks

| Check | Command | Result |
|---|---|---|
| Format | `npx prettier --check "src/**/*.ts" "test/**/*.ts"` | exit 0 (reviewer) |
| Lint | `npx eslint --no-error-on-unmatched-pattern src test` | exit 0 (reviewer) |
| Type check (src) | `npx tsc -p ./ --noEmit` | exit 0 (reviewer) |
| Type check (test) | `npx tsc -p tsconfig.jest.json --noEmit` | exit 0 (reviewer) |
| Evidence locations | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` | exit 0 (reviewer) |

## 8. Gaps and Exceptions

- The reviewer did not re-run the full `npm run test:coverage` suite. Post-change coverage was taken from the existing `coverage/lcov.info` artifact, in line with the evidence-verification model. The artifact postdates the code commit, and the code tree has not changed since.
- The `targetRole` mutation check (AC-6) was not reproduced by the reviewer, because the review constraints prohibit editing production code. The reviewer confirmed by code reading that, with the comparator returning 0, the stable sort keeps the insertion order `["shared-skill", "hook"]`, which the test rejects. This agrees with the recorded red output.
- AC-7 evidence records `npx` equivalents of the `npm run` scripts. The mapping is documented in `evidence/other/reduced-audit-handoff.2026-10-12T15-19.md`, and the reviewer's own `npx` runs exit 0.
- Out-of-scope items listed in `issue.md` (for example `reporting-render.ts:183-184` and the `localeCompare` sites) were not evaluated as defects.

## 9. Summary of Changes

- 12 production files: 19 `.sort()` calls changed to `.sort(compareCodePoint)`; 11 import lines added (`tree-assembler.ts` already imported the comparator). `codex-pack-selection.ts` and `file-prompt-transforms.ts` have Prettier-driven line wrapping at three sites.
- 15 test files: 14 code-point ordering tests, 6 null-default tiebreak tests, 1 `targetRole` tiebreak test with a `SequencedReadFileSystem` helper.
- Feature folder: issue, plan, research, and 35 evidence files.

## 10. Compliance Verdict

**PASS.** All evaluated policies are compliant. Blocking findings: 0. Non-blocking findings: 6 (see `code-review.2026-10-12T15-29.md`). TypeScript coverage verdict: PASS. No remediation inputs are required.

## Appendix A: Test Inventory

| Test file (`extensions/drm-copilot/test/lib/...`) | Status | Added tests | Target |
|---|---|---|---|
| push-down/claude-pack-selection.test.ts | Modified | 1 | site 1 (`claude-pack-selection.ts:117`) |
| push-down/codex-pack-selection.test.ts | Modified | 2 | sites 3, 6 (`codex-pack-selection.ts:66`, `:108`) |
| resolve/file-prompt-transforms.test.ts | Created | 2 | sites 10, 11 |
| subagent-tree/tree-assembler.test.ts | Modified | 1 | site 8 |
| subagent-tree/tree-formatter.test.ts | Modified | 1 | site 9 |
| validate/codex-topology-resolver.test.ts | Modified | 1 | site 12 |
| validate/epic-orchestrator-state-core.ordering.test.ts | Created | 1 | site 13 |
| validate/epic-planner-git-integrity.test.ts | Modified | 1 | site 14 |
| validate/orchestrator-state-codex-model-routing.test.ts | Modified | 1 | site 15 |
| validate/orchestrator-state-core.test.ts | Modified | 2 | sites 17, 18 |
| validate/orchestrator-state-model-routing-existence.test.ts | Created | 1 | site 19 |
| codex-native-converter/reporting-render.test.ts | Modified | 2 | `reporting-render.ts:83`, `:189` |
| codex-native-converter/reporting-coverage.test.ts | Modified | 2 | `reporting.ts:151-152`, `:157` |
| codex-native-converter/validation.test.ts | Modified | 2 | `validation.ts:364-365`, `:370` |
| codex-native-converter/engine-pipeline.test.ts | Modified | 1 | `engine-pipeline.ts:241` |

## Appendix B: Toolchain Commands Reference

Run from `extensions/drm-copilot/`:

- `npx prettier --check "src/**/*.ts" "test/**/*.ts"`
- `npx eslint --no-error-on-unmatched-pattern src test` (`npm run lint`)
- `npx tsc -p ./ --noEmit` and `npx tsc -p tsconfig.jest.json --noEmit` (`npm run typecheck`)
- `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` (`npm run test:coverage`)
- `npx jest --config jest.config.cjs <15 changed test files>` (reviewer targeted run)

Run from the repository root:

- `git diff --name-only origin/main...HEAD`
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
