# Code Review: agent-payload-gates-resolve-session-root (#690)

---

**Review Date:** 2026-09-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690`
**Feature Folder Selection Rule:** The only active feature folder changed on the branch; its `-690` suffix matches the issue number in the branch name.
**Base Branch:** `main` (resolved `origin/main` @ `72d7ebbfda7dc6f1d6c5c321c1d01c00b8e4f8b4`; merge base `72d7ebbfda7dc6f1d6c5c321c1d01c00b8e4f8b4`)
**Head Branch:** `bug/agent-payload-gates-resolve-session-root-690` @ `268d635963e1a2d5f4a4eadb32abbc6b4508d969`
**Review Type:** Re-review after remediation pass 1 (prior review: `code-review.2026-09-30T01-45.md`)

---

## Executive Summary

This re-review covers the full branch diff against `main` (merge base `72d7ebbf`, 272 files), with specific attention to the commits added since the pass-1 review (`c127db6d`): the remediation plan and evidence, the CR-1 and CR-2 code changes in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` with their tests, the follow-up potential entry for CR-4 and CR-5, and a merge of `origin/main` into the branch (`268d6359`).

The feature design is unchanged from pass 1: nine PreToolUse gates and `Resolve-EpicScopeCheckpoint` read their run checkpoints beneath a worktree resolved from portable identity, through one resolver module with a single filesystem-read seam, and every converted gate converts a failed module import into a deny decision.

Remediation outcome for the pass-1 findings:
- CR-1 (Minor) is fixed. `Resolve-WorktreeRunTargetByRecord` now requires `[long]::TryParse` to succeed before a `pr_number` value is used, so a 20-digit value resolves `NoTarget` without enumerating live roots. Row B13 was shown failing before the fix (`evidence/regression-testing/cr1-before-fix.*`) and passing after.
- CR-2 (Minor) is fixed. `Get-WorktreeRunCheckpointText` still returns `$null` for any read failure (fail-closed) but now writes `WORKTREE_RUN_CHECKPOINT_UNREADABLE: '<path>': <message>` to stderr. Row T4 was shown failing before the fix and passing after. Writing to stderr instead of using `Write-Warning` keeps the hook's stdout limited to the decision JSON; the plan records this reason.
- CR-3 (Minor) is resolved. The canonical `artifacts/pester/powershell-coverage.xml` was regenerated through the repository PoshQC module and runsettings, and now contains `WorktreeRunResolution.psm1` (149/149), `enforce-epic-merge-gate-resolution.ps1` (32/36), and `enforce-epic-worktree-removal-gate-resolution.ps1` (22/23).
- CR-4 and CR-5 (Nit) are recorded in `docs/features/potential/2026-09-30-worktree-run-resolution-review-nits.md` and not fixed, as the remediation inputs permitted.

Reviewer-run checks at the merged head: Invoke-Formatter comparison and PSScriptAnalyzer over the 72 added or modified PowerShell files report 0 differences, 0 diagnostics, and 0 files over 500 lines; black, ruff, and pyright are clean on the changed Python file; mirrors are 19/19 hash-equal; Pester over `tests/scripts/claude-hooks`, `claude-lib`, `claude-runtime`, and `codex-hooks` reports 5430 total, 5429 passed, 0 failed, 1 skipped (the pre-existing skip). No Blocker or Major finding was identified.

**What changed since pass 1:**
- `WorktreeRunResolution.psm1`: 493 to 497 lines. The line 102 synopsis, the read-seam catch at lines 116-118, the line 413 description, and the `pr_number` guard at lines 434-436 (line numbers at the head). The bundle mirror is byte-identical.
- `WorktreeRunResolution.Record.Tests.ps1`: row B13. `WorktreeRunResolution.Signal.Tests.ps1`: row T4.
- `docs/features/potential/2026-09-30-worktree-run-resolution-review-nits.md` (new).
- Merge of `origin/main`: a union of main's changes. Where it touched files that are also changed on the branch (both runsettings copies, `core.json`, and two skill files with their mirrors), it added main's entries alongside the branch's and removed none of them. No production or test file changed on the branch was modified by the merge.

**Top 3 risks:**
1. Behaviour change for untargeted implementation-agent delegations (unchanged from pass 1): a delegation without the canonical issue-number line and `branch:` label is denied with `TARGET_WORKTREE_NOT_DERIVABLE`. The skill contract documents the lines; undocumented callers are denied until updated.
2. The bundle contract test node (AC-44) cannot pass on a host that holds `.claude/state/current-session-id`; its pass depends on a CI run, and no PR or CI run exists for the branch yet.
3. `WorktreeRunResolution.psm1` has 3 lines of headroom under the 500-line limit. The deferred CR-4 fix, or any later extension, will probably require extracting a helper module first.

**PR readiness recommendation:** **Go**, conditional on CI. The code has no open Blocker, Major, or Minor finding. The only remaining acceptance item (AC-44) needs a green CI run of the bundle contract test once the PR is open, and that is not a code change.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | lines 433-436 (`Resolve-WorktreeRunTargetByRecord`) | CR-1 (pass 1, Minor): an overlong `pr_number` could make the later `[long]` cast throw. Now guarded by `[long]::TryParse` after the `^\d+$` match, so an out-of-range value is `NoTarget`. The guard also rejects non-ASCII Unicode digits that `\d` matches but `Int64.TryParse` does not parse, which the previous cast would also have thrown on. | None. | The documented contract (a value that is not all digits or does not fit a 64-bit integer is `NoTarget`) now matches the behaviour. | `git diff c127db6d 973e8bfc -- .claude/lib/worktree-resolution/WorktreeRunResolution.psm1`; row B13; `evidence/regression-testing/cr1-after-fix.*` |
| Resolved | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | lines 116-118 (`Get-WorktreeRunCheckpointText`) | CR-2 (pass 1, Minor): the silent catch-all now writes a named stderr diagnostic before returning `$null`. | None. | This follows the repository rule against silent catch-alls. The result is still fail-closed and the hook's stdout remains JSON-only. | Same diff; row T4; `evidence/regression-testing/cr2-after-fix.*` |
| Resolved | `artifacts/pester/powershell-coverage.xml` | sourcefile list | CR-3 (pass 1, Minor): the canonical artifact now lists all three new production files. | None. | Reviewer parse: 149/149, 32/36, 22/23 lines. | Reviewer JaCoCo parse; `evidence/qa-gates/powershell-coverage-artifact.2026-09-30T02-23.md` |
| Nit | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | lines 344-358 (`Test-WorktreeRunPathEqual`) | CR-4 (carried): a UNC root recorded with different casing compares case-sensitively. | Address through the potential entry `2026-09-30-worktree-run-resolution-review-nits.md`. | Deferred by decision in remediation inputs RF-4. | Potential entry added in `fcfb2efb` |
| Nit | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | final deny | CR-5 (carried): the `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token repeats when both run kinds resolve `NoTarget`. | Address through the same potential entry. | Readability only; matching on the leading token is unaffected. | Same potential entry |
| Nit | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | line 434 (`$parsedNumber`) | CR-9 (new): `$parsedNumber` is filled by `TryParse` but not used. `Test-WorktreeRunCheckpointRecord` casts `[long] $Value` again at line 398. | Optional: pass the parsed value to `Test-WorktreeRunCheckpointRecord` instead of re-casting when the module is next edited. | Minor duplication. The second cast cannot throw now, because only values that passed `TryParse` reach it. | Module read |
| Nit | `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1` | row T4, Act line | CR-10 (new): the Act step puts four statements (`StringWriter` creation, capture of `[Console]::Error`, `SetError`, and a `try`/`finally`) on one line. | Optional: split across lines for readability. | PSScriptAnalyzer and Invoke-Formatter accept it. The `finally` restores the process error stream, so test independence holds. | Test read; reviewer format/analyze run |
| Info | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | whole file | CR-11 (new): the module is 497 lines, 3 under the limit. | Plan a helper extraction before the CR-4 follow-up adds lines. | The general code-change policy caps production files at 500 lines. | Reviewer line count |
| Info | `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml` | file timestamps | CR-12 (new): both coverage artifacts (02:07Z and 02:22Z) predate the merge of `origin/main` (`268d6359`, 02:26:58Z). The merge changed no production or test file that is changed on the branch, so per-file figures for branch files still describe the merged head. Repo-wide figures describe the pre-merge tree. | No action for this feature. | The review contract verifies coverage from existing artifacts and does not regenerate them. | `git diff --name-only 973e8bfc 268d6359` restricted to branch files returned no branch production or test file |
| Info | `.claude/hooks/*` (seven converted gates) | import-guard blocks | CR-6 (carried): repeated per-gate import-guard blocks are intentional. | No change. | A shared helper would itself be an import that could fail. | Pass-1 diff read |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | after the guard loop | CR-7 (carried): `EpicScopeReadiness.psm1` import remains outside the guard. | Covered by `docs/features/potential/2026-09-29-hook-preexisting-imports-fail-open.md`. | Out of scope per AC-36. | Pass-1 diff read |

No Blocker, Major, or Minor findings remain open.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- The only Python change on the branch is the one-line digest pin in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, unchanged since pass 1. The surface-contract suite still passes at the merged head, after the merge brought in main's changes to `parallel-orchestrate/SKILL.md`.

#### Typing and API notes

- No public Python API was added. `pyright` reports 0 errors, 0 warnings, 0 informations on the file.

#### Error handling and logging

- Not applicable; the file holds constants only.

### PowerShell implementation audit (if applicable)

#### What changed well

- The CR-1 guard sits before live-root enumeration, so an unusable value costs no filesystem access. B13 asserts `Get-WorktreeItemLiveRoot` is invoked 0 times.
- The CR-2 catch still returns `$null` for every exception type. No exception can reach a hook entry point, where it would cause a non-zero exit that PreToolUse treats as non-blocking. The comment on line 116 states this reason.
- Both live-file changes were made by a single complete write from a staged copy that passed parse, format, and analyzer checks (`evidence/qa-gates/cr1-write.2026-09-30T02-10.md`, `cr2-write.2026-09-30T02-12.md`). Each was followed by a mirror copy and a hash check.

#### API and safety notes

- No exported signature changed. The seven exports and their parameter attributes are as in pass 1.
- `[Console]::Error.WriteLine` writes only to the process error stream. For a PreToolUse hook that exits 0, stderr does not alter the decision.

#### Error handling and logging

- The unreadable-checkpoint path now has a named diagnostic token, which makes a permissions or locking failure visible when a gate denies with `TARGET_WORKTREE_NOT_DERIVABLE`.

---

## Test Quality Audit

The two new rows follow the conventions of the pass-1 suites: an Arrange-Act-Assert layout, synthetic `/synthetic-worktrees/<name>` roots, and seam mocks scoped to the `It` block.

### Reviewed test and QA artifacts

- `WorktreeRunResolution.Record.Tests.ps1` row B13: arranges a live epic checkpoint that an unguarded conversion would reach and throw on, then asserts `NoTarget`, the accessor reason code, and zero live-root enumerations.
- `WorktreeRunResolution.Signal.Tests.ps1` row T4: mocks `Test-Path` inside the module so a directory (`$PSScriptRoot`) reaches `ReadAllText`, which throws. The row captures `[Console]::Error` in a `StringWriter`, restores it in `finally`, and asserts `$null` plus the diagnostic token. It creates no file. On Linux CI, `ReadAllText` on a directory also throws, and any exception type reaches the catch.
- `evidence/regression-testing/cr1-before-fix.*`, `cr1-after-fix.*`, `cr2-before-fix.*`, `cr2-after-fix.*`: fail-before and pass-after records (28 and 45 rows after the fix).
- `evidence/qa-gates/remediation-coverage-wrr.2026-09-30T02-24.md`: 254/254 rows in `tests/scripts/claude-lib/worktree-resolution` (baseline 252 plus 2) and 149/149 lines for WRR. `remediation-changed-line-coverage.2026-09-30T02-24.md`: 5/5 changed executable lines covered.

### Quality assessment prompts

- **Determinism:** B13 and T4 use no clock, environment, or host worktree state. T4 changes the process error stream only inside a `try`/`finally`.
- **Isolation:** each row asserts one resolver outcome.
- **Speed:** the reviewer's run of the four hook and library test trees (5430 rows) completed in 217 seconds.
- **Diagnostics:** B13 asserts the invocation count, so a regression that enumerates before validating fails with an identifiable row.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff read; no credentials, tokens, or keys added |
| No unsafe subprocess or command construction | ✅ PASS | No process start in the module or the gate changes; AST rows U1-U3 pass |
| Input validation at boundaries | ✅ PASS | CR-1 closed: `pr_number` must match `^\d+$` and parse as `[long]`; `ValidateSet` on `Kind`/`RecordField`; absolute-path `ValidatePattern` on read seams |
| Error handling remains explicit | ✅ PASS | CR-2 closed: read failures are reported on stderr and resolve fail-closed |
| Configuration / path handling is safe | ✅ PASS | Checkpoint paths composed through `Join-WorktreeResolutionPath`; resolution never uses payload `cwd` |

---

## Research Log

No external research was required. The review relied on the feature's research record, `spec.md`, `remediation-inputs.2026-09-30T01-45.md`, `remediation-plan.2026-09-30T02-00.md`, the branch diff, and the PR context artifacts regenerated at 2026-09-30 02:27:26 UTC for head `268d6359`.

---

## Verdict

Remediation pass 1 closed CR-1, CR-2, and CR-3 with tests that were shown failing before each code change. The two Nits are recorded as a potential entry. The merge of `origin/main` did not alter any file the branch changes, apart from union additions to shared registration files, and the reviewer's checks at the merged head are clean. The code is ready for merge. The remaining condition is outside the code: a green CI run of the bundle contract test for AC-44 once the PR is opened.
