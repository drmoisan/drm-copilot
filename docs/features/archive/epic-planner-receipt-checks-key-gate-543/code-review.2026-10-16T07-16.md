# Code Review: Epic-planner per-feature receipt-checks key gate (#543), re-review after remediation cycle 2

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its `-543` suffix matches the branch name.
**Base Branch:** `main`, resolved as `origin/main` @ `b6be46b5ec394f75f99e16bc861be0380d5f1cba` (merge base `b6be46b5e`)
**Head Branch:** `bug/epic-planner-receipt-checks-key-gate-543` @ `9ae44e4f2d03ced5b8b6e1b95d8370aa32f1b73c`
**Review Type:** Re-review after remediation cycle 2 (prior review sets `*.2026-10-16T01-36.md` and `*.2026-10-16T04-40.md`)

---

## Executive Summary

Cycle 2 addressed the four same-feature non-blocking findings selected by the orchestrator from the prior review: CR-6 (unused `ASSERTED_MESSAGES` tuples), CR-8 (plan pairing re-derived the readiness `plan_path` normalization), CR-9 (uncovered lines in the touched files), and CR-10 (Python/TypeScript divergence on `.` and empty path segments). Reviewed evidence: the full branch diff (211 files; 25 code files), `artifacts/pr_context.summary.txt` (generated 07:06 UTC at head `9ae44e4f2`), the cycle-2 evidence set, both lcov artifacts, and reviewer re-runs of Black, Ruff, Pyright, Prettier, ESLint, tsc, targeted pytest (131 passed), and targeted Jest (117 passed).

**What changed in cycle 2:**
- `scripts/dev_tools/epic_planner_git_integrity.py` / `epic-planner-git-integrity.ts`: the readiness path validator moved here as exported `repository_relative_path` / `repositoryRelativePath`; `_plan_path` / `derivedPlanPath` call it, so plan pairing and the readiness gate cannot disagree on a plan's spelling.
- `scripts/dev_tools/epic_planner_readiness.py` / `epic-planner-readiness-integrity.ts`: the private validator is removed and the five call sites use the moved function. Python behaviour is unchanged (verbatim move). TypeScript now drops `.` and empty segments and returns `.` for an empty result, matching `PurePosixPath(...).as_posix()`.
- `tests/scripts/dev_tools/typescript_twin_test_support.py` and six `test_asserted_messages_match_typescript_twin` tests turn the one-off cross-runtime literal comparison into standing tests.
- Six new test files and two extended files cover every previously uncovered line in the six cycle-0/1 production files.

**Top 3 risks:**
1. The Python path validator (now in the git-integrity module) accepts drive-qualified values such as `C:/docs/x`, which escape the workspace root on a Windows host; TypeScript rejects them (CR-11, pre-existing, reported by the executor as O-1).
2. The branch now changes eight production files and the TypeScript readiness path rules, while `spec.md` lists two production files (CR-7). The PR description is the remaining place to record this.
3. `epic-planner-state-core.ts` is at 495 of 500 lines (CR-4).

**PR readiness recommendation:** **Ready** - no Blocker or Major finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/dev_tools/epic_planner_git_integrity.py` | `repository_relative_path` (lines 167-184); consumers `epic_planner_readiness.py` lines 108, 169, 207 | CR-11 (new ID, same files as this change, pre-existing): `PurePosixPath("C:/docs/x").is_absolute()` is `False`, so the function accepts a drive-qualified path; on Windows `context.workspace_root / Path("C:/docs/x")` resolves to `C:\docs\x`, outside the workspace. TypeScript `repositoryRelativePath` rejects `/^[A-Za-z]:/`. | Add the drive rejection to the Python function (aligning Python to the stricter TypeScript rule), with a twin test. Orchestrator decision: same-feature cycle or follow-up. | Not a regression: the function moved verbatim from `main`'s `_relative_path`. The readiness gate only reads files, so the effect is a read outside the workspace, not a write. | Reviewer: `python -I -c "PurePosixPath('C:/docs/x').is_absolute(); PureWindowsPath('C:/repo') / 'C:/docs/x'"` printed `False C:\docs\x`; `remediation-plan.2026-10-16T04-40.md` O-1 |
| Info | `scripts/dev_tools/epic_planner_readiness.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts` | plan-within-folder check | CR-12 (new ID, same files, pre-existing): Python accepts `plan_path == feature_folder`; TypeScript requires the `${folder}/` prefix. | Decide the intended rule and align in a follow-up. | Cross-runtime divergence that cycle 2 did not change; reported by the executor as O-2. | `remediation-plan.2026-10-16T04-40.md` O-2 |
| Nit | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | `validateReadyFeatures(featureResult.indexedFeatures, requireLaunchPaths)` | CR-3 (carried, same file): the local named `requireLaunchPaths` gates more than launch paths, and `validateReadyFeatures` takes a positional boolean. | Rename to `keyGated` and use an options object in a later change. | Spec-mandated form (AC10). | `git diff b6be46b5e..HEAD -- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` |
| Info | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | whole file (495 lines) | CR-4 (carried, same file): 5 lines of headroom under the 500-line limit. | Split `validateReadyFeatures` or the dependency-wave check into its own module before the next addition. | Within the limit. Cycle 2 did not edit the file. | reviewer `wc -l`; `evidence/qa-gates/rc2-line-counts-final.2026-10-16T06-51.md` |
| Info | `docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md` | "Files/modules to change" | CR-7 (carried and extended, same feature): the spec lists two production and four test files. The branch changes eight production files and 17 test files, and it changes behaviour beyond the receipt gate: git-integrity pairing reads `planning_commit` / `plan_hash` from the owning entry (cycle 1), and TypeScript readiness now accepts and normalizes `./x`, `a/./b`, `a//b`, `a/`, and `./` (to `.`), which it previously rejected or left unnormalized (cycle 2). | State both behaviour changes and the extra files in the PR description. Do not add AC items. | PR reviewers otherwise see changes outside the spec's file list. AC13's excluded paths are untouched. | `git diff --name-status origin/main...HEAD -- . ":!docs"` (25 files) |
| Nit | `scripts/dev_tools/epic_planner_git_integrity.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts` | `_pair_plans_with_features` fallback; `pairPlansWithFeatures` fallback | CR-13 (new, same files): the positional-fallback comprehension names each plan `item` (`for slot, item in enumerate(plans)`, `plans.map((item, slot) => ...)`) while `items` / `item` elsewhere in the same function denote checkpoint entries. | Rename to `plan` in a later change. | Readability only. | Source reading |
| Nit | `tests/scripts/dev_tools/test_epic_planner_readiness_relative_paths.py` | `FOLDER_SLASH_ERROR` (lines 28-30) | CR-14 (new, same feature test file): Black joined the two adjacent literals onto one line, leaving `"... feature_folder " "must use forward slashes."`, an implicit concatenation on a single line. | Write it as one literal (it fits within 88 columns inside the parentheses). | Readability only; recorded in cycle-2 plan deviation 4. | Source reading |
| Info | `tests/scripts/dev_tools/typescript_twin_test_support.py` | `literals_missing_from_twin` | CR-16 (new, same feature tests): the Python parity tests read the TypeScript twin test file from the repository tree. A rename of a TypeScript twin makes the Python test fail with `FileNotFoundError` rather than an assertion message. | Acceptable as is; optionally assert the file exists with a clear message. | Reading a tracked file is permitted (precedent `test_push_down_codex_and_agents_customizations.py`); it is not a temporary file. The coupling is intentional (CR-6 decision). | Source reading; `evidence/qa-gates/rc2-cr6-parity-discrimination.2026-10-16T06-24.md` |
| Info | `scripts/dev_tools/epic_planner_readiness.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts` | Python 113-114, 202-203, 207, 215, 218-219, 238; TypeScript 23 lines | CR-15 (new ID, same files, pre-existing): residual uncovered lines in the two readiness modules (executor O-3). | Optional follow-up tests. | Both files are above thresholds (95.05% / 86.05% and 93.43% / 88.41%) and improved in cycle 2; none of the lines is an added line. | Reviewer lcov re-derivation |

Prior findings disposition: CR-6 closed (six standing parity tests; discrimination run in `rc2-cr6-parity-discrimination.2026-10-16T06-24.md`); CR-8 closed (shared derivation; TypeScript fail-before in `fail-before-cr8-typescript.2026-10-16T06-26.md`, Python fail-before documented as structurally impossible in `fail-before-exception.2026-10-16T06-27.md`); CR-9 closed (every listed zero-hit line now covered; reviewer re-derivation shows 100% line coverage in `validate_epic_planner_state.py`, `_epic_orchestrator_state_launch_binding.py`, `epic_planner_git_integrity.py`, `epic-planner-state-core.ts`, `epic-orchestrator-state-launch-binding.ts`, and `epic-planner-git-integrity.ts`); CR-10 closed (TypeScript aligned to Python; fail-before in `fail-before-cr10-typescript.2026-10-16T06-26.md`). CR-3, CR-4, and CR-7 carried.

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The move is verbatim: the reviewer's comparison of string literals containing `Epic planner`, `must be`, `must match`, `must use`, or `must stay` across added and removed lines of all eight production files found no unpaired literal in either direction.
- `_plan_path` now delegates to the same function the readiness gate uses, which removes the duplicate normalization CR-8 described and the silent fallback it could cause.
- No new dependency edge: `epic_planner_readiness.py` already imported from `epic_planner_git_integrity.py`. `PurePosixPath` remains used in the readiness module.

#### Typing and API notes

- `repository_relative_path(value: object, *, field: str) -> tuple[str | None, list[str]]` is the only new public name; `validate_planning_git_integrity` keeps its signature. Pyright reports 0 errors.

#### Error handling and logging

- Validators continue to return error strings. No exceptions or logging changed.

### TypeScript implementation audit

#### What changed well

- `repositoryRelativePath` filters empty and `.` segments before the `..` check and keeps the drive and leading-slash rejections, so it accepts exactly the spellings Python accepts except drive-qualified ones (CR-11).
- `derivedPlanPath` replaces strict equality on the raw `plan_path`, so a dot-prefixed `plan_path` now pairs with its normalized plan instead of falling back to positional order (`matches a dot-prefixed plan_path to its normalized plan`).
- The wave-rethrow test replaces `computeWaveNumbers` through `jest.mock` in a dedicated file, so the mock cannot leak into other suites.

#### Type safety and maintainability

- No `any`, non-null assertions, casts, or suppressions added (reviewer `git diff -G` search over `src/` and `test/`).
- See CR-3, CR-4, and CR-13.

#### Error handling and logging

- No change to boundary validation; failures remain aggregated error strings.

---

## Test Quality Audit

Cycle 2 adds 34 Python and 28 TypeScript cases. The CR-10 TypeScript tests failed on the pre-fix tree (6 failed / 5 passed) and the CR-8 TypeScript case failed with the positional-fallback prefix (1 failed / 6 passed); both pass after the fix. The Python twins pass before and after, as expected for the unchanged authority. The parity helper was shown to discriminate (a deliberately altered literal is reported missing).

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_epic_planner_readiness_relative_paths.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-relative-paths.test.ts` - six normalized spellings, four rejections, dot-prefixed `plan_path`.
- `tests/scripts/dev_tools/test_validate_epic_planner_state_shape_errors.py` and `epic-planner-state-shape-errors.test.ts` - worthiness, missing keys, shape fields, two-feature check, path fields, non-epic next step, Python repr of `None`, list, and `True`.
- `tests/scripts/dev_tools/test_epic_orchestrator_state_launch_binding_edges.py` and `epic-orchestrator-state-launch-binding-edges.test.ts` - deployment agent, four worktree path forms, non-list child features.
- `epic-planner-state-wave-rethrow.test.ts` - non-cycle rethrow.
- `evidence/regression-testing/fail-before-cr8-typescript.2026-10-16T06-26.md`, `fail-before-cr10-typescript.2026-10-16T06-26.md`, `pass-after-cr8-cr10-python.2026-10-16T06-28.md`, `pass-after-cr8-cr10-typescript.2026-10-16T06-30.md`.
- `evidence/qa-gates/rc2-coverage-delta-verification.2026-10-16T06-51.md`, `rc2-error-strings-moved-unchanged.2026-10-16T06-37.md`, `rc2-final-qa-clean-pass.2026-10-16T06-51.md`.

### Quality assessment prompts

- **Determinism:** in-memory validation through existing fakes.
- **Isolation:** one message site or spelling per case.
- **Speed:** 131 Python tests in 1.79s (reviewer run).
- **Diagnostics:** exact-membership assertions; parity tests print the missing literals.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credentials; no suppressions added in cycles 1 or 2. |
| No unsafe subprocess or command construction | N/A | No subprocess code changed. |
| Input validation at boundaries | PASS | Path rejections (parent, absolute, backslash, blank) asserted in both runtimes. Drive-qualified paths are accepted by Python only (CR-11, pre-existing). |
| Error handling remains explicit | PASS | No error literal added, removed, or reworded (reviewer comparison). |
| Configuration / path handling is safe | PASS | No path rule was weakened in Python. TypeScript now accepts `.`-segment and empty-segment spellings, which it normalizes and which cannot escape the root (`..` and leading `/` remain rejected). |
| Codex strictness preserved | PASS | Cycle-0 and cycle-1 Codex-flag tests pass unchanged. |

---

## Research Log

No external research was required. The cycle-2 design follows `remediation-plan.2026-10-16T04-40.md` revision 1. The reviewer confirmed the CR-11 Windows path behaviour with a local `PureWindowsPath` evaluation.

---

## Verdict

The cycle-2 changes are correct and consistent across runtimes. The path validator move is verbatim in Python, TypeScript now matches Python's normalization, every previously uncovered line in the six cycle-0/1 production files is covered, and both coverage artifacts show all thresholds met with no uncovered added line. All format, lint, type, and test stages pass on reviewer re-run. No blocking finding exists; CR-3, CR-4, CR-7, and CR-11 to CR-16 are non-blocking.
