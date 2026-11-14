# Code Review: planner-worktree-removal-authorization (#1161)

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161`
**Feature Folder Selection Rule:** named by the caller; matches the branch issue number 1161
**Base Branch:** `main` (merge base `eb73f1dff52e7175228a03740b53281c81e1c00c`, equal to `origin/main` at review time)
**Head Branch:** `feature/planner-worktree-removal-authorization-1161` (head `6c8f1d9faf651b8244f997fd05c5b21ffb1390fb`, PR #1176)
**Review Type:** Initial feature review (S7).

---

## Executive Summary

The branch lets the epic planner remove a fanned-in preparation worktree without `--force` and without detaching HEAD. It records each preparation worktree by branch in `planner_worktrees` and adds a planner allow branch to the three removal gates. The allow is conjunctive: the record must be eligible, the worktree must not be in use (U1 to U5), it must be clean, and its `HEAD` must be on a remote-tracking ref. The design follows the repository's pure-helper-plus-adapter pattern. The helper is byte-identical in four copies and pinned by test. The adapters start git only after a record names the target, so existing gate suites stay process-free. Unrecorded deny text stays byte-identical because the suffix is the empty string.

The reviewer read the full branch diff against the merge base. The reviewer also probed the Python and TypeScript validators against each other outside the corpus, using an esbuild bundle of the head TypeScript module and the head Python function on eight single-entry checkpoints. Three of the eight values diverge (finding row 1).

**Top 3 risks:**
1. Cross-runtime validator divergence on whitespace-only `recorded_at` values (row 1). The MCP validator and the Python CLI can give different verdicts for the same checkpoint.
2. The planner branch is a policy-level control. A same-session writer can author a record, and the git checks bound what a record can authorize. This is disclosed in the spec, the skills, and each gate's `.DESCRIPTION`.
3. On Claude, the planner check now runs on every deny path that reaches it. It reads `epic-planner-state.json` beneath every live root, and the first `git worktree list` starts only when a candidate record exists. Cost is bounded to deny paths.

**PR readiness recommendation:** **No-Go** until row 1 is fixed. All other rows are Info, and no file-size Warning applies.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts` | Python `_validate_planner_worktrees` (`recorded.strip()`); TypeScript `validateEntryFields` (`recordedAt.trim()`) | Blocking (PA-1). The two runtimes use different whitespace sets for the `recorded_at` non-blank rule. For `"﻿"` Python reports no error and TypeScript reports the `recorded_at` error. For `"\u001f"` and `"\u0085"` Python reports the error and TypeScript reports none. U+00A0 and U+200B agree. | Define the whitespace set once and apply it in both runtimes, for example an explicit character class such as ASCII space, tab, CR, LF, FF, VT. Add corpus files for U+FEFF, U+001F, and U+0085 under `tests/fixtures/epic_planner_state_planner_worktrees/` so both parity suites pin the definition. | Spec D11 and `### Validator error strings` require byte-identical results in Python and TypeScript, and user-story criterion 1 requires both validators to reject malformed entries with the same strings. The corpus does not cover the whitespace definition, so the parity suites cannot detect the divergence. | Reviewer probe: esbuild bundle of the head module and `_validate_planner_worktrees` on the same eight entries (SCRATCH `probe.cjs`, `probe.py`); output recorded in the policy audit section 8. |
| Info | `.claude/hooks/enforce-worktree-removal-gate-planner.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` | `Invoke-PlannerWorktreeGitExe`, `Invoke-CodexPlannerWorktreeGitExe` | Related to this item. The wrapper seams redirect stderr with `2>$null`, while `.claude/rules/powershell.md` shows `git @GitArgs 2>&1` as the wrapper shape. | No change required. Optionally add a one-line comment that stderr is dropped so a git warning on stderr cannot be read as dirty `status --porcelain` output. | Merging stderr would let a warning make a clean worktree read as DIRTY. Dropping it keeps the decision on exit code and stdout, which the spec defines. | Reviewer reading of both adapters. |
| Info | `.claude/hooks/enforce-worktree-removal-gate-planner.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` | `MatchCount` | Related to this item. Two entries with the same branch inside one planner checkpoint also yield `PLANNER_WORKTREE_AMBIGUOUS`. The spec names only records from more than one checkpoint or more than one live root. | No change. | Such a checkpoint already fails the validator's uniqueness rule. Refusing is the conservative reading and never widens an allow. | Reviewer reading; `Get-PlannerWorktreeRemovalDecision` refuses when `MatchCount -gt 1`. |
| Info | `.codex/hooks/enforce-epic-worktree-removal-gate-planner.ps1` | U5 path comparison | Related to this item. U5 compares normalized `features[].worktree_path` values with the target using PowerShell `-eq`, which ignores case on every platform. Other comparisons in the helper are ordinal for POSIX roots. | No change. | A case-insensitive match can only add an in-use refusal, never an allow. | Reviewer reading of line 126. |
| Info | `tests/scripts/claude-hooks/` (seven existing gate suites and the baseline helper) | baseline mocks | Related to this item. AC-31's "passes unchanged" is applied to assertions (plan reading R5). The existing suites gain one `Mock Get-PlannerWorktreeCheckpointText` line or a baseline-helper registration. Two suites gain an order-dependence reset. | No change. | The adapter's read seam sits in script scope, which module-scoped mocks do not reach (plan R1). No assertion changed. | `plan.2026-11-09T16-33.md` R1, R5, `## Existing Test Dispositions`; `scope-check.2026-11-13T20-36.md`. |

No covered file reaches 700 logical lines (largest: the two Claude gates at 500, the helper at 482, `jest.config.cjs` at 582, `legacy-codex-hook-contracts.Tests.ps1` at 517), so no file-size Warning row applies. `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- `_validate_planner_worktrees` is private, key-gated (`if "planner_worktrees" not in state: return []`), and runs immediately after the `max_parallel_features` check. A checkpoint without the key therefore validates byte-identically, which the `valid-key-absent.json` row asserts.
- The branch rule uses `fullmatch`, so a trailing newline does not slip past `$` (probe value `"abc\n"` is rejected in both runtimes).

#### Typing and API notes

- Fully typed signature; `cast` is used only to narrow `json` values. Pyright 0 errors.

#### Error handling and logging

- Errors are appended in the spec order per entry. The whitespace rule for `recorded_at` relies on `str.strip()`, whose character set differs from ECMAScript `trim()` (row 1).

### PowerShell implementation audit (if applicable)

#### What changed well

- `hook-planner-worktree-removal.ps1` holds only function definitions. An AST row in the helper suite forbids `Set-StrictMode`, file cmdlets, `Get-Location`, process start, and `git`.
- `Get-PlannerWorktreeRemovalDecision` returns `Pending` for the next git fact. The adapters call git only as far as the decision needs, and the argument lists are built by `Get-PlannerWorktreeGitFactArgument`. The listing uses `-C <SessionRoot>` and the target checks use `-C <target>`, with no `fetch`, `pull`, or `ls-remote`.
- `ConvertFrom-PlannerWorktreeJson` keeps a JSON array root an array (`-NoEnumerate` plus the unary comma). A malformed checkpoint therefore never reads as an object with a `planner_worktrees` property.
- The gate edits are one guarded dot-source, two lines in the target-denial function, and the suffix appended to the final deny expression. `Get-EpicWorktreeGateDenyDiagnostics` and the manifest branch are unchanged.

#### API and safety notes

- Eligibility and status comparisons are ordinal and case-sensitive (`-ceq`), as D3 requires.
- U3 reads any `locked` line, with or without a reason, regardless of `--force`.
- The Claude gates pass `(Get-Location).Path` as the session root, the same expression the gates already use for `Get-WorktreeRunMainCheckoutRoot` and the branch resolver. The adapter itself never calls `Get-Location`.
- The integration and branch names from the checkpoint reach git only after the fixed `refs/remotes/origin/` prefix. A value cannot be read as an option.

#### Error handling and logging

- Any git exit other than the expected codes yields `GIT_FAILED`, and a wrapper that cannot start git returns exit -1. A dependency load failure is recorded through `Add-HookDependencyFailure`, so the gate denies naming the file.

### TypeScript implementation audit (if applicable)

- `validatePlannerWorktrees` is pure, imports nothing, and is called once from `validateEpicPlannerStateText` at the same position as the Python call.
- The `"path" in entry` and `"recorded_at" in entry` presence checks are safe for parsed JSON, because neither name is an `Object.prototype` member.
- `recordedAt.trim()` defines the blank set differently from Python (row 1).
- The new module has its own `coverageThreshold` entry (85 / 75) and reaches 100% / 100%.

### C# implementation audit (if applicable)

- N/A: no C# file in the branch diff.

---

## Test Quality Audit

- The helper suite runs against both helper copies and covers one row per code, per U condition (U1 in three forms), per status value plus case variants, both ancestry refs, an absent integration branch, record-parsing rejections, and the porcelain shapes.
- Each gate suite has allow rows (`prepared` and `fanned_in`, integration ref and branch ref), DIRTY with and without `--force`, U3 with and without `--force`, every refusal code, the literal unrecorded deny text, and a manifest allow after a planner refusal (AC-20).
- Sentinel rows: under the baseline helper, with the live-root and git seams mocked to throw, an unrecorded deny returns the literal text, and the throwing seams are invoked zero times.
- Fail-before evidence: 45 failures in the five new suites before the gate edits (`planner-allow-fail-before.2026-11-11T05-00.md`, ExpectedExitCode 1), including all ten gate-level allow rows.
- Gap: the corpus pins every error string but not the whitespace definition of `recorded_at` (row 1).

### Reviewed test and QA artifacts

- `evidence/qa-gates/pester-gate.2026-11-13T20-34.md` (22669 passed, 0 failed)
- `evidence/qa-gates/pytest-gate.2026-11-13T20-08.md` (16714 passed, 0 failed)
- `evidence/qa-gates/jest-gate.2026-11-13T20-09.md` (5546 passed) and reviewer `evidence/qa-gates/jest-root-gate.2026-11-14T00-29.md` (5563 passed)
- `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md`, `python-static.2026-11-13T18-55.md`, `typescript-static.2026-11-13T18-55.md`
- `evidence/qa-gates/scope-check.2026-11-14T00-18.md`, `self-review.2026-11-14T00-20.md`
- `evidence/regression-testing/planner-allow-fail-before.2026-11-11T05-00.md`

### Quality assessment prompts

- Do the tests fail when the behavior breaks? Yes for the gate allow rows (fail-before record). For parity, only within the corpus.
- Are mocks at the seam level? Yes: wrapper seams with matching `param([string[]]$GitArgs)` signatures.
- Any test that reads the host? No: synthetic forward-slash and UNC roots only.

---

## Security / Correctness Checks

- No absolute host path in fixtures, corpus, or tests. The only drive-shaped value in the corpus is the rejection token in `path-drive-prefix.json`. The single evidence quotation is accepted under OD-10 (DEV-1).
- No secret, credential, or network call. The pushed check reads local remote-tracking refs only.
- The allow cannot be reached for the session root, an enclosing directory, the planner-checkpoint root, the main checkout, a locked worktree, a dirty worktree, or an unpushed `HEAD`.
- Registrations in `.claude/settings.json` and `.codex/config.toml` are unchanged.

---

## Research Log

- `git diff eb73f1dff..6c8f1d9fa` (full branch), `git log` per language for freshness, `git fetch origin main` for drift.
- Read: the helper, both adapters, the three gate diffs, the Python and TypeScript validator changes, `WorktreeItemResolution.psm1` `Get-WorktreeItemLiveRoot`.
- Probes: esbuild bundle of the head TypeScript module compared with the head Python function on eight values; `cmp` of 13 mirror pairs and the four helper copies; logical line counts of every covered changed file.
- Coverage: parsed `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, and the reviewer-generated root `coverage/lcov.info`.
- CI: `gh pr view 1176` at review time; Python, PowerShell, and shell jobs in progress; completed jobs green.

---

## Verdict

**No-Go.** One blocking finding (row 1, PA-1, autonomous, contained). Remediation: one shared whitespace definition in both validators, plus three corpus rows. All other rows are Info.
