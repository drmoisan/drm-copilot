# Code Review: Epic-planner per-feature receipt-checks key gate (#543), re-review after remediation cycle 3

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/epic-planner-receipt-checks-key-gate-543`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its `-543` suffix matches the branch name.
**Base Branch:** `main`, resolved as `origin/main` @ `c415af626c292f38b910e3a27e70ab3e1903b31a` (merge base `c415af626`)
**Head Branch:** `bug/epic-planner-receipt-checks-key-gate-543` @ `20c1148c9a92cb7f632bc1b3daafee74564b7ed5` (PR #955)
**Review Type:** Re-review after remediation cycle 3 (prior review sets `*.2026-10-16T01-36.md`, `*.2026-10-16T04-40.md`, `*.2026-10-16T07-16.md`)

---

## Executive Summary

Cycle 3 addressed the same-feature non-blocking findings CR-11 to CR-16 from the prior review. Reviewed evidence: the full branch diff (265 files; 28 code files), `artifacts/pr_context.summary.txt` (generated 08:56 UTC at head `20c1148c9`), the cycle-3 evidence set, both lcov artifacts, and reviewer re-runs of Black, Ruff, Pyright, Prettier, ESLint, tsc, targeted pytest (111 passed), and targeted Jest (109 passed).

**What changed in cycle 3:**
- `scripts/dev_tools/epic_planner_git_integrity.py`: `DRIVE_RE = re.compile(r"^[A-Za-z]:")` is evaluated on the raw value inside `repository_relative_path`, so `C:/...` and `c:...` now produce `<field> must stay within the workspace root.`, as TypeScript already did (CR-11). The rule is a string match, so it behaves identically on Linux and Windows hosts. Plan pairing inherits it through `_plan_path`.
- `scripts/dev_tools/epic_planner_readiness.py`: `if not plan.startswith(f"{folder}/"):` replaces the `plan == folder or ...` form, matching TypeScript and the two sibling rules in the same function (CR-12).
- Both git-integrity modules: the positional-fallback variable is `fallback_plan` / `fallbackPlan` (CR-13).
- `tests/scripts/dev_tools/test_epic_planner_readiness_relative_paths.py`: one literal for `FOLDER_SLASH_ERROR` (CR-14).
- New `test_epic_planner_readiness_edges.py` and `epic-planner-readiness-edges.test.ts` cover every residual uncovered line in both readiness modules (CR-15).
- `typescript_twin_test_support.py` asserts the twin exists before reading it; `test_typescript_twin_test_support.py` pins the behaviour (CR-16).

**Top 3 risks:**
1. Python readiness now reports two inputs it previously accepted (drive-qualified paths; `plan_path` equal to `feature_folder`). Neither could pass the full readiness gate before (the drive form read outside the workspace on Windows; the folder-equal form failed the `atomic plan` read), but the PR #955 body does not yet describe the change (CR-7).
2. `epic-planner-state-core.ts` is at 495 of 500 lines (CR-4).
3. Read-error message text still differs between runtimes (`...: denied` versus `...: Error: denied`; CR-18, executor O-4).

**PR readiness recommendation:** **Ready** - no Blocker or Major finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | PR #955 description | body | CR-7 (carried and extended, same feature): the body describes cycles 1 and 2 only. It does not state that Python readiness now rejects drive-qualified paths and a `plan_path` equal to its `feature_folder`, it reports 214 changed files and cycle-2 test counts (7153 / 4051), and it names the `2026-10-16T07-16` round as the final review. | Update the body before merge with the cycle-3 behaviour changes, the new test files, and current counts (7178 Python, 4062 TypeScript). Do not add AC items. | Reviewers of the PR otherwise see validator behaviour changes that the description does not mention. The PR body is not a branch file, so no code cycle is needed. | `gh pr view 955 --json body` (reviewer) |
| Nit | `scripts/dev_tools/epic_planner_git_integrity.py` | `repository_relative_path`, clause `"." in path.parts` (line 187) | CR-17 (new, same file, pre-existing): `PurePosixPath` drops `.` segments, so `path.parts` never contains `"."` (`PurePosixPath('.').parts == ()`, `PurePosixPath('a/./b').parts == ('a', 'b')`). The clause cannot be true. | Remove the clause in a later change, or leave it with a comment. | Dead condition only; the result is correct because normalization already removes `.` segments, matching TypeScript. Present on `main` before this branch; cycle 3 only re-wrapped the condition. | Reviewer `python -I -c "from pathlib import PurePosixPath as P; print(P('.').parts, P('./x').parts, P('a/./b').parts)"` printed `() ('x',) ('a', 'b')` |
| Info | `scripts/dev_tools/epic_planner_readiness.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts` | `_read_required` (`str(exc)`); `readRequired` (`String(error)`) | CR-18 (new ID for executor O-4, same files, pre-existing): for an unreadable required file Python reports `...: denied` and TypeScript `...: Error: denied`. The cycle-3 tests assert each runtime's own text and keep it out of the parity tuple. | Decide whether the message should be identical and align in a follow-up if so. | Cross-runtime message divergence that predates the branch; no test or consumer depends on equality. | `remediation-plan.2026-10-16T07-16.md` O-4; `UNREADABLE_ISSUE_ERROR` in both edge test files |
| Nit | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | `validateReadyFeatures(featureResult.indexedFeatures, requireLaunchPaths)` | CR-3 (carried, same file): the local named `requireLaunchPaths` gates more than launch paths, and `validateReadyFeatures` takes a positional boolean. | Rename to `keyGated` and use an options object in a later change. | Spec-mandated form (AC10). | Source reading |
| Info | `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | whole file (495 lines) | CR-4 (carried, same file): 5 lines of headroom under the 500-line limit. | Split `validateReadyFeatures` or the dependency-wave check into its own module before the next addition. | Within the limit; not edited in cycle 3. | reviewer `wc -l`; `evidence/qa-gates/rc3-line-counts-final.2026-10-16T08-47.md` |

Prior findings disposition:
- CR-11 closed: Python rejects `C:/docs/features/active/feature-101` and `c:docs/features/active/feature-101` with the escape message; fail-before in `evidence/regression-testing/fail-before-cr11-cr12-python.2026-10-16T08-31.md` (4 failed), pass-after in `pass-after-cr11-cr12-python.2026-10-16T08-33.md`; TypeScript authority tests pass before the change (`rc3-typescript-authority-before.2026-10-16T08-29.md`).
- CR-12 closed: `equal-to-folder` and `dot-prefixed-folder` now report `plan_path must be inside its feature_folder.` in Python; `sibling-prefix` is a control that fails in both runtimes before and after.
- CR-13 closed: rename only; existing positional-pairing tests pass (`python-rc3-post-fix-suite.2026-10-16T08-34.md`, `typescript-rc3-post-fix-suite.2026-10-16T08-35.md`).
- CR-14 closed: one literal; the parity test still passes.
- CR-15 closed: reviewer lcov re-derivation shows 0 zero-hit lines in `epic_planner_readiness.py` (182/182) and `epic-planner-readiness-integrity.ts` (350/350).
- CR-16 closed: fail-before `fail-before-cr16-python.2026-10-16T08-25.md` (FileNotFoundError), pass-after `pass-after-cr16-python.2026-10-16T08-26.md`.
- CR-3, CR-4, and CR-7 carried.

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The drive check is a raw-string regular expression, not a host path query, so CI on Linux and a Windows host give the same answer. The message is the existing escape message, so no error literal was added (reviewer search of the cycle-3 production diff for added or removed lines containing `must`, `Epic planner`, or `Execution readiness`: none).
- The clause order keeps the backslash check first, so a backslash drive path such as `C:\x` still reports `must use forward slashes.`, which is the TypeScript order.
- The CR-12 change removes one disjunct and leaves the sibling `research_path` and `preflight_evidence_path` rules unchanged.

#### Typing and API notes

- No signature changed. `DRIVE_RE` sits beside `HASH_RE` and `COMMIT_RE`. Pyright reports 0 errors.

#### Error handling and logging

- Validators continue to return error strings. No exceptions or logging changed in production. The twin helper's `assert` is test support (`S101` ignored under `tests/**`).

### TypeScript implementation audit

#### What changed well

- The only production edit is the CR-13 rename in `pairPlansWithFeatures`; behaviour is unchanged, and the TypeScript authority tests for the drive and folder-equal cases pass before and after.

#### Type safety and maintainability

- No `any`, non-null assertions, casts, or suppressions added (reviewer search over added lines in `src/` and `test/`).
- The edge test defines a local `UNUSED_GIT`; the equivalent constant in `epic-planner-launch-evidence-test-support.ts` is not exported, so the local definition is necessary.

#### Error handling and logging

- No change to boundary validation; failures remain aggregated error strings.

---

## Test Quality Audit

Cycle 3 adds 14 Python and 11 TypeScript cases. The Python CR-11/CR-12 tests failed on the pre-fix tree (4 failed, 20 passed) and pass after the fix; the CR-16 test failed with `FileNotFoundError` before and passes after. The TypeScript twins pass before and after, as expected for the unchanged authority. Each edge test is traced to the specific readiness lines it covers in the remediation plan, and the reviewer's lcov re-derivation confirms full line coverage of both readiness modules.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_epic_planner_readiness_edges.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-edges.test.ts` - strict `plan_path` prefix (three spellings and an accepted control), non-object entry index, unreadable document, outside and unreadable preflight evidence, kickoff slug mismatch, parity tuple.
- `tests/scripts/dev_tools/test_epic_planner_readiness_relative_paths.py` and its TypeScript twin - `drive-letter` and `drive-relative` rejections.
- `tests/scripts/dev_tools/test_typescript_twin_test_support.py` - missing twin and present twin.
- `evidence/regression-testing/fail-before-cr11-cr12-python.2026-10-16T08-31.md`, `fail-before-cr16-python.2026-10-16T08-25.md`, `pass-after-cr11-cr12-python.2026-10-16T08-33.md`, `pass-after-cr16-python.2026-10-16T08-26.md`, `rc3-typescript-authority-before.2026-10-16T08-29.md`.
- `evidence/qa-gates/rc3-coverage-delta-verification.2026-10-16T08-46.md`, `rc3-final-qa-clean-pass.2026-10-16T08-46.md`, `rc3-scope-verification.2026-10-16T08-47.md`.

### Quality assessment prompts

- **Determinism:** in-memory validation through local fakes; the `C:/workspace` root follows the existing readiness fixture, which already runs on Linux CI.
- **Isolation:** one message site or spelling per case.
- **Speed:** 111 Python tests in 0.56s (reviewer run).
- **Diagnostics:** membership assertions print the full error list; the twin helper names a missing file.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credentials; no suppressions added in cycles 1 to 3. |
| No unsafe subprocess or command construction | N/A | No subprocess code changed. |
| Input validation at boundaries | PASS | Python now rejects drive-qualified paths, closing the Windows read-outside-workspace path recorded as CR-11; both runtimes reject parent, absolute, backslash, blank, and drive forms. |
| Error handling remains explicit | PASS | No error literal added, removed, or reworded in cycle 3. |
| Configuration / path handling is safe | PASS | No path rule was weakened; two Python rules became stricter and now match TypeScript. |
| Codex strictness preserved | PASS | Cycle-0 and cycle-1 Codex-flag tests pass unchanged. |

---

## Research Log

No external research was required. The cycle-3 design follows `remediation-plan.2026-10-16T07-16.md`. The reviewer confirmed the `PurePosixPath` part behaviour behind CR-17 with a local evaluation.

---

## Verdict

The cycle-3 changes are minimal, correct, and make the Python and TypeScript path rules identical for drive-qualified values and folder-equal plan paths. Every line of the eight changed production files is covered, both coverage artifacts show all thresholds met with no uncovered added line, and all format, lint, type, and test stages pass on reviewer re-run. No blocking finding exists; CR-3, CR-4, CR-7, CR-17, and CR-18 are non-blocking.
