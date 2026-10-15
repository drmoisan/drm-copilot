# Code Review: agent-payload-gates-resolve-session-root (#690)

---

**Review Date:** 2026-09-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690`
**Feature Folder Selection Rule:** The only active feature folder changed on the branch; its `-690` suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `91805f15ddc5930759d877cf6147467096ad91fe`)
**Head Branch:** `bug/agent-payload-gates-resolve-session-root-690` @ `c47504ae770b5716aa93c572fbb82f3655b27118`
**Review Type:** Initial review

---

## Executive Summary

The branch converts nine PreToolUse gates and one shared library function from session-root-relative checkpoint reads to reads beneath a worktree resolved from portable identity (integration branch, parallel slug, pull request number, worktree path, file operand, or `git -C` selector). A new module, `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (493 lines), holds all matching logic and exposes one filesystem-read seam. Two new dot-sourced hook siblings (`enforce-epic-merge-gate-resolution.ps1`, `enforce-epic-worktree-removal-gate-resolution.ps1`) keep the gate files inside the 500-line cap. Every converted gate gains an import guard that turns a failed module import into a deny decision instead of a non-zero exit. The diff also adds 12 Pester suites (138 rows), default seam mocks in existing suites, skill contract text, bundle mirrors, registration entries, and a one-line Python digest-pin re-baseline.

Evidence reviewed: the full diff against the merge base, the PR context summary and appendix, the feature evidence folder, and reviewer-run check-only commands (Invoke-Formatter comparison and PSScriptAnalyzer over 72 PowerShell files with 0 differences and 0 diagnostics; Pester over all changed suites with 1139/1139 passing; the full `tests/scripts/claude-hooks` tree with 2150/2150 passing; mirror hashes 19/19 equal; coverage parse of `artifacts/pester/powershell-coverage.xml`). The implementation is consistent with the spec's design, keeps each gate's decision semantics, and fails closed on unresolved targets and import failures. No Blocker or Major code defects were found.

**What changed:**
- New resolver module with pure signal extraction (`Find-WorktreeRunIdentitySignal`), a single read seam (`Get-WorktreeRunCheckpointText`), epic/parallel/record/operand resolvers, and a zero/one/many decision shared through `Resolve-WorktreeRunMatch`.
- `WorktreeItemResolution.psm1` exports `ConvertTo-WorktreeItemResolvedResult` so resolved-result labelling has one implementation.
- Preimplementation gate: `Get-CheckpointContent` and `Get-OrchestrationModeDenyReason` relocated to the epic-scope sibling; three read seams now take a mandatory absolute path; `Resolve-OrchestrationGateTarget` and `Read-OrchestrationGateCheckpoint` route every leg through resolution unless a raw checkpoint is injected.
- Wave barrier, cohort barrier, drift gate, merge gate, and both removal gates: relative checkpoint literals replaced by resolution seams plus absolute-path read seams.
- `Resolve-EpicScopeCheckpoint` keys `Resolve-WorktreeEpicTarget` on the matched branch and adds reason `target-worktree-ambiguous`.

**Top 3 risks:**
1. Behaviour change for untargeted implementation-agent delegations: a delegation without the canonical issue-number line and `branch:` label is now denied with `TARGET_WORKTREE_NOT_DERIVABLE`. The skill contract text documents the lines, but undocumented callers outside the edited skills will be denied until updated.
2. Coverage evidence for the three new production files rests on executor QA records because the canonical Pester coverage artifact was generated with the installed extension's runsettings, which lack the new entries.
3. The bundle contract test node (AC-44) cannot pass on a host that has `.claude/state/current-session-id`; its pass depends on CI.

**PR readiness recommendation:** **Conditional Go** — the code is ready; merge readiness depends on producing the Python coverage artifact required by the review policy and on a green CI run for the bundle contract test.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | lines 389-396 (`Test-WorktreeRunCheckpointRecord`) | CR-1: `[long] $Value` is cast after a `^\d+$` check only. A digit string longer than 19 digits passes the check and the cast throws, so `Resolve-WorktreeRunTargetByRecord` raises instead of returning `NoTarget`. The merge gate passes an `[int]`, so current gate callers cannot reach it; a direct caller can. | Parse with `[long]::TryParse` in `Resolve-WorktreeRunTargetByRecord` and return `NoTarget` on failure, matching the documented contract ("a pr_number that is not all digits is NoTarget"). Add one row. | The function documents a total mapping from input to status; an exception is outside that contract. Hook entry points would still deny, so this is not a fail-open. | Module read; `Resolve-EpicMergeGateRunTarget -PrNumber [int]` in `enforce-epic-merge-gate-resolution.ps1` line 146 |
| Minor | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | line 116 (`Get-WorktreeRunCheckpointText`) | CR-2: `try { ReadAllText } catch { return $null }` swallows every exception type without a debug record. | Narrow the catch to `[System.IO.IOException]` and `[System.UnauthorizedAccessException]`, or emit `Write-Debug` with the exception message before returning `$null`. | The repository PowerShell rule discourages silent catch-alls. The outcome is fail-closed (an unreadable checkpoint never matches), so the impact is diagnosability only. | Module read; `.claude/rules/powershell.md` "avoid silent catch-alls" |
| Minor | `artifacts/pester/powershell-coverage.xml` | sourcefile list | CR-3: The canonical coverage artifact contains no entry for `WorktreeRunResolution.psm1`, `enforce-epic-merge-gate-resolution.ps1`, or `enforce-epic-worktree-removal-gate-resolution.ps1`. The installed extension's `pester.runsettings.psd1` contains 0 of the three entries, while the repo copy contains all three; the MCP test runner reads the installed copy. | Regenerate the canonical artifact with the repo runsettings (self-hosted PoshQC module) so the new files appear, or record in the QA evidence that the per-file figures come from direct Pester coverage runs. | Reviewers verify coverage from the canonical artifact; the three new files are otherwise only covered by executor-recorded figures (100%, 88.89%, 95.65%). | Reviewer coverage parse (3 files reported NOT IN COVERAGE REPORT); grep of the installed extension runsettings returned 0 |
| Nit | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | lines 342-356 (`Test-WorktreeRunPathEqual`) | CR-4: Case-insensitive comparison applies only when either side starts with a drive letter. A UNC path (`\\server\share\wt`) recorded with different casing compares case-sensitively. | Treat a leading `//` after normalisation as a Windows path as well, or document that UNC worktree roots are compared case-sensitively. | The spec states comparison is case-insensitive on Windows paths; UNC roots are an edge case not covered by a row. | Module read |
| Nit | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | final deny (lines ~415-420) | CR-5: When both run kinds resolve `NoTarget`, the deny text repeats the `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token twice. | Build the reason as one token followed by the reason code and the existing message. | Downstream matching on the leading token still works; the duplication only affects readability of the deny message. | `git diff 91805f15 HEAD -- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1` |
| Info | `.claude/hooks/*` (seven converted gates) | import-guard blocks | CR-6: Each converted gate carries its own import-guard block and failure variable. | No change. A shared helper would itself be an import that could fail, which is the condition the guard handles. | Recorded so later reviewers do not treat the repetition as accidental duplication. | Diff read of each gate |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | line after the guard loop | CR-7: `EpicScopeReadiness.psm1` is still imported with `-ErrorAction Stop` outside the guard, so a failure there remains fail-open. | No change on this branch; covered by the potential entry `docs/features/potential/2026-09-29-hook-preexisting-imports-fail-open.md`. | The spec places pre-existing imports out of scope (AC-36). | Diff read; potential entry added on this branch |
| Info | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | one pinned digest | CR-8: One SHA-256 pin replaced to match the intended `epic-orchestrate/SKILL.md` edit. | No change. | The change is data-only; black, ruff, and pyright are clean and the surface-contract tests pass (36 in the targeted run). | Reviewer run: `poetry run black --check`, `ruff check`, `pyright` on the file; `pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- The only Python change is a one-line constant replacement in a test-support module. The spec criterion (AC-62) was amended with a dated Change Log entry before the change, and the re-baseline follows the precedent of issues #663 and #762.

#### Typing and API notes

- No new public Python API surface was added. `pyright` reports 0 errors, 0 warnings on the file.

#### Error handling and logging

- Not applicable; the file holds constants only.

### PowerShell implementation audit (if applicable)

#### What changed well

- Matching logic is concentrated in one module with one filesystem seam, which keeps each gate's change to a resolution call, a `switch`-equivalent on `Status`, and an absolute-path read. This follows the PR #695 pattern and keeps the gates testable without temporary files.
- There is no session-root-first shortcut: every resolver enumerates live roots and applies the same zero/one/many rule, so a stale checkpoint copy at the session root cannot win (row R12 asserts this).
- `ConvertFrom-WorktreeRunCheckpointText` uses `-NoEnumerate` plus a `PSCustomObject` type test, which correctly rejects one-element JSON arrays.
- Read seams validate absolute paths with `ValidatePattern('^([A-Za-z]:[\\/]|/)')`, which enforces the "no relative literal" invariant at the parameter boundary.
- Injection parameters (`-CheckpointRaw`, `-EpicCheckpointRaw`, `-ParallelCheckpointRaw`) bypass resolution, so pre-existing rows keep their meaning.
- Commit sequencing matches the rollout plan: the module commit (`d120a539`) touches no hook, and each gate commit carries its sibling and mirrors.

#### API and safety notes

- All new functions are advanced functions with `[CmdletBinding()]`, `[OutputType()]`, and explicit parameter attributes; PSScriptAnalyzer reports 0 diagnostics with repo settings.
- No new state-changing function is introduced, so `SupportsShouldProcess` is not required.
- Script-scoped variables added are constants (patterns, relative paths, route IDs) and import-failure records set once at load time.
- Function names use approved verbs (`Find`, `Get`, `Resolve`, `Read`, `Test`, `ConvertTo`, `ConvertFrom`).

#### Error handling and logging

- Unresolved targets deny behind each gate's existing leading token with the accessor reason code and a `Detail` clause that names the remedy.
- Import failures are recorded and converted into a deny before any other decision logic, so a missing module no longer produces a non-zero exit (which PreToolUse treats as non-blocking).
- CR-1 and CR-2 above are the only error-handling observations; neither produces a fail-open.

---

## Test Quality Audit

The 12 added suites exercise the module through a mocked live-root enumeration and a mocked text-read seam over synthetic `/synthetic-worktrees/<name>` roots. Gate suites dot-source the hook, mock the gate's resolution seam or the module's read seam, and assert both the decision and the exact path passed to the read seam. Existing suites for converted gates add a default `BeforeAll` mock that returns a `SessionRoot` target, so no existing row enumerates the host's worktrees.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1` (22 rows), `.Signal.Tests.ps1` (16), `.Record.Tests.ps1` (27) — cover zero/one/many, tie-break, slug disagreement, malformed checkpoint shapes, record matching, and signal extraction including the trailing full stop.
- `tests/scripts/claude-hooks/*.WorktreeResolution.Tests.ps1` (eight suites, 69 rows) and `enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` (10 rows) — per-gate other-worktree, NoTarget, Ambiguous, and import-failure rows.
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` with `EpicStateIsolation.Helpers.ps1` — structural guard extended to the new read seam; predicate moved to a helper file to stay under the line cap.
- `evidence/qa-gates/coverage-*.2026-09-30T01-17.md` and `changed-line-coverage.2026-09-30T01-18.md` — per-file and changed-line coverage from direct Pester coverage runs.
- `evidence/other/p12-coverage-fix-deviation.2026-09-30T01-05.md` — records that four import-failure rows were changed to reach the real guard through a mocked throwing `Import-Module`, with assertions unchanged.

### Quality assessment prompts

- **Determinism:** No test reads wall-clock time, environment variables, or the host's worktrees; added test lines contain no `TestDrive`, file-writing cmdlets, or sleeps (reviewer scan of the added test diff).
- **Isolation:** Each `It` asserts one decision or one resolver outcome; seam mocks are scoped per suite.
- **Speed:** The 12 new suites run in about 7 seconds; the full claude-hooks tree runs in about 39 seconds.
- **Diagnostics:** Rows assert the exact read path with `Should -Invoke ... -ParameterFilter`, so a regression to a session-root read fails with an identifiable row.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff read; no credentials, tokens, or keys added |
| No unsafe subprocess or command construction | ✅ PASS | The module and gate changes start no process; AST row U1-U3 asserts the module has no subprocess, clock, or location call |
| Input validation at boundaries | ✅ PASS | Absolute-path `ValidatePattern` on read seams; `ValidateSet` on `Kind`/`RecordField`; blank and non-digit record values map to `NoTarget` (CR-1 notes the overflow edge) |
| Error handling remains explicit | ⚠️ PARTIAL | Fail-closed on every unresolved path; CR-2 notes one silent catch in the read seam |
| Configuration / path handling is safe | ✅ PASS | Checkpoint paths are composed through `Join-WorktreeResolutionPath`; resolution never uses the payload `cwd` or a prompt-declared path to select a worktree |

---

## Research Log

No external research was required. The review relied on the repository's research record (`research/2026-09-29T21-55-agent-payload-gates-session-root-research.md`), the spec, and the diff.

---

## Verdict

The implementation is consistent with the spec, keeps single-worktree decisions unchanged, and closes the session-root read defect across the in-scope gates with fail-closed handling for unresolved targets and import failures. The findings are Minor, Nit, or Info and none blocks merge on code grounds.

Merge readiness is conditional on two items outside the code: the Python coverage artifact required by the review policy (see the policy audit and remediation inputs), and a green CI run of the bundle contract test for AC-44. CR-1, CR-2, and CR-3 are recommended but non-blocking.
