# Code Review: planner-worktree-removal-authorization (#1161)

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161`
**Feature Folder Selection Rule:** named by the caller; matches the branch issue number 1161
**Base Branch:** `main` (merge base `eb73f1dff52e7175228a03740b53281c81e1c00c`, equal to `origin/main` at review time)
**Head Branch:** `feature/planner-worktree-removal-authorization-1161` (head `b7913c32c24e47bc29742baf71800f4573958e06`, PR #1176)
**Review Type:** Re-audit at the exit of remediation cycle 1 (S7). Inputs: `remediation-inputs.2026-11-14T00-34.md` (PA-1).

---

## Executive Summary

The branch lets the epic planner remove a fanned-in preparation worktree without `--force` and without detaching HEAD. It records each preparation worktree by branch in `planner_worktrees` and adds a planner allow branch to the three removal gates. The allow is conjunctive: the record must be eligible, the worktree must not be in use (U1 to U5), it must be clean, and its `HEAD` must be on a remote-tracking ref. The design follows the repository's pure-helper-plus-adapter pattern, and the helper is byte-identical in four copies and pinned by test.

Remediation cycle 1 closed the one blocking finding of the S7 review (PA-1, cross-runtime divergence on whitespace-only `recorded_at`). Both validators now use the same explicit six-character blank set (space, tab, LF, CR, VT, FF) instead of the native `str.strip()` and `trim()`. Four corpus fixtures pin the set, and the spec row states it. The reviewer read the full branch diff and the cycle diff. The reviewer then ran an exhaustive cross-runtime probe over every UTF-16 code unit and further strings and types (65596 values, 0 differences), and checked by mutant analysis that the new fixtures detect a revert in either runtime.

**Top 3 risks:**
1. The planner branch is a policy-level control. A same-session writer can author a record, and the git checks bound what a record can authorize. This is disclosed in the spec, the skills, and each gate's `.DESCRIPTION`.
2. On Claude, the planner check runs on every deny path that reaches it. It reads `epic-planner-state.json` beneath every live root, and the first `git worktree list` starts only when a candidate record exists. Cost is bounded to deny paths.
3. The parity corpus pins removals from the blank set and reverts to native strip or trim, but not a one-sided addition of a further character (Info row 1).

**PR readiness recommendation:** **Go**, subject to the S9 CI green gate on the final PR head. All rows are Info, and no file-size Warning applies.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/fixtures/epic_planner_state_planner_worktrees/` | `recorded-at-*` and `blank-recorded-at-ascii-controls` rows | Related to this item. The four new rows fail when a blank-set character is removed in one runtime or when either runtime reverts to its native strip or trim. A one-sided addition of a further character, for example U+00A0 in Python only, would pass both parity suites. | No change required. | The spec row and the comment on each constant, which names its twin, document the set. The reviewer probe shows the two runtimes identical at head over all 65536 single code units. | Reviewer mutant analysis; `recorded-at-fail-before.2026-11-14T01-01.md`; probe output in the policy audit section 6. |
| Info | `.claude/hooks/enforce-worktree-removal-gate-planner.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` | `Invoke-PlannerWorktreeGitExe`, `Invoke-CodexPlannerWorktreeGitExe` | Related to this item; carried from the S7 review. The wrapper seams redirect stderr with `2>$null`, while `.claude/rules/powershell.md` shows `git @GitArgs 2>&1` as the wrapper shape. | No change required. | Merging stderr would let a git warning make a clean worktree read as DIRTY. Dropping it keeps the decision on exit code and stdout, which the spec defines. | Reviewer reading of both adapters. |
| Info | `.claude/hooks/enforce-worktree-removal-gate-planner.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` | `MatchCount` | Related to this item; carried from the S7 review. Two entries with the same branch inside one planner checkpoint also yield `PLANNER_WORKTREE_AMBIGUOUS`. | No change. | Such a checkpoint already fails the validator's uniqueness rule. Refusing never widens an allow. | `Get-PlannerWorktreeRemovalDecision` refuses when `MatchCount -gt 1`. |
| Info | `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` | U5 path comparison | Related to this item; carried from the S7 review. U5 compares normalized `features[].worktree_path` values with the target using PowerShell `-eq`, which ignores case. | No change. | A case-insensitive match can only add an in-use refusal, never an allow. | Reviewer reading. |
| Info | `tests/scripts/claude-hooks/` (seven existing gate suites and the baseline helper) | baseline mocks | Related to this item; carried from the S7 review. AC-31's "passes unchanged" is applied to assertions (plan reading R5). | No change. | The adapter's read seam sits in script scope, which module-scoped mocks do not reach (plan R1). No assertion changed. | `plan.2026-11-09T16-33.md` R1, R5; `scope-check.2026-11-13T20-36.md`. |

No covered file reaches 700 logical lines (largest: `jest.config.cjs` at 582, `legacy-codex-hook-contracts.Tests.ps1` at 517, `validate_epic_planner_state.py` at 503, the two Claude gates at 500), so no file-size Warning row applies. `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- `_RECORDED_AT_BLANK_CHARS = " \t\n\r\x0b\x0c"` is a private module constant with a comment naming the TypeScript twin. The test `recorded.strip(_RECORDED_AT_BLANK_CHARS)` is truthy exactly when some character lies outside the set, which is the spec rule.
- The docstring of `_validate_planner_worktrees` states the blank rule. The `isinstance(recorded, str)` guard still precedes the strip, so non-string values are rejected as before.
- `_validate_planner_worktrees` stays key-gated, so a checkpoint without the key validates byte-identically (`valid-key-absent.json`).

#### Typing and API notes

- No signature changed; Pyright 0 errors (`python-static.2026-11-14T01-13.md`).

#### Error handling and logging

- No error string changed. The `recorded_at` error text is the same in both runtimes and in the spec.

### PowerShell implementation audit (if applicable)

#### What changed well

- No PowerShell file changed in the cycle. The S7 findings stand: the helper holds only function definitions (AST row forbids I/O), the adapters start git only as far as the decision needs, `ConvertFrom-PlannerWorktreeJson` keeps an array root an array, and the gate edits leave `Get-EpicWorktreeGateDenyDiagnostics` and the manifest branch unchanged.

#### API and safety notes

- Eligibility and status comparisons are ordinal and case-sensitive (`-ceq`). U3 reads any `locked` line regardless of `--force`. Checkpoint names reach git only after the fixed `refs/remotes/origin/` prefix.

#### Error handling and logging

- Any unexpected git exit yields `GIT_FAILED`; a dependency load failure is recorded through `Add-HookDependencyFailure`.

### TypeScript implementation audit (if applicable)

- `RECORDED_AT_BLANK = /^[ \t\n\r\v\f]*$/` has no `m` flag, so `$` anchors at end of input only. In a character class `\v` is U+000B and `\f` is U+000C, so the class is the same six characters as the Python constant.
- The test `!RECORDED_AT_BLANK.test(recordedAt)` runs only after `typeof recordedAt === "string"`, so the `test` call never coerces a non-string.
- The TSDoc on the constant names the Python twin and explains that `trim()` is not used because its set differs.
- The module's `coverageThreshold` entry is unchanged, and the module stays at 100% lines and branches.

### C# implementation audit (if applicable)

- N/A: no C# file in the branch diff.

---

## Test Quality Audit

- The four new fixtures each hold one `planner_worktrees` entry and differ only in `recorded_at`, written with JSON `\u` escapes. One rejects the six blank characters together; three accept U+FEFF, U+001F, and U+0085.
- Discrimination: the fail-before record shows the native sets failing exactly the planned rows (Python U+001F and U+0085, TypeScript U+FEFF). The reviewer's mutant analysis adds that removing any one blank character in either runtime fails `blank-recorded-at-ascii-controls`.
- `EXPECTED_CORPUS_COUNT` is 21 in both suites, so a shrunken glob fails rather than passing vacuously.
- Existing test dispositions for `recorded_at` behavior are listed in the remediation plan; only the two count constants changed.

### Reviewed test and QA artifacts

- `evidence/regression-testing/recorded-at-fail-before.2026-11-14T01-01.md` (ExpectedExitCode 1, three planned failures)
- `evidence/qa-gates/phase-gate.P1.2026-11-14T01-12.md` (stages 1 to 6 clean)
- `evidence/qa-gates/pytest-gate.2026-11-14T01-17.md` (16722 passed) and `evidence/qa-gates/jest-gate.2026-11-14T01-18.md` (5554 passed)
- Reviewer `evidence/qa-gates/jest-root-gate.2026-11-14T01-27.md` (5571 passed)
- `evidence/qa-gates/coverage-delta.2026-11-14T01-19.md`, `scope-check.2026-11-14T01-19.md`, `self-review.2026-11-14T01-21.md`
- Carried: `evidence/qa-gates/pester-gate.2026-11-13T20-34.md` (22669 passed), `pwsh-static.2026-11-13T20-15.md`

### Quality assessment prompts

- Do the tests fail when the behavior breaks? Yes: the gate allow rows have a fail-before record, and the blank-set rows have one plus the reviewer's mutant analysis.
- Are mocks at the seam level? Yes: wrapper seams with matching `param([string[]]$GitArgs)` signatures.
- Any test that reads the host? No: synthetic roots only; the corpus tests read committed fixtures.

---

## Security / Correctness Checks

- No absolute host path in fixtures, corpus, or tests; the four new fixtures carry only the synthetic corpus paths. The single evidence quotation is accepted under OD-10 (DEV-1).
- No secret, credential, or network call.
- The allow cannot be reached for the session root, an enclosing directory, the planner-checkpoint root, the main checkout, a locked worktree, a dirty worktree, or an unpushed `HEAD`.
- Registrations in `.claude/settings.json` and `.codex/config.toml` are unchanged.

---

## Research Log

- `git fetch origin main`; `origin/main` equals the merge base. `git diff eb73f1dff..b7913c32c` (full branch, 149 files) and `git diff 6c8f1d9fa..b7913c32c` (cycle).
- Read: both validator diffs, the four new fixtures, both corpus test diffs, the spec diff, and the cycle evidence files.
- Probes: esbuild bundle of the head TypeScript module and the head Python function on 65596 values (0 differences, 54 rejected in each); mutant analysis of native strip, native trim, and single-character removal against the fixture values; logical line counts of the changed validator and test files.
- Coverage: parsed `artifacts/python/lcov.info` and the reviewer-regenerated root `coverage/lcov.info`; PowerShell artifact unchanged since the S7 review and still newer than the newest PowerShell commit.
- CI: `gh pr view 1176` at review time; several jobs queued or in progress; completed jobs green.

---

## Verdict

**Go.** PA-1 is closed. No blocking finding remains; all rows are Info. Merge depends on the S9 CI green gate on the final PR head.
