# Code Review: SubagentStop artifact-gate review notes (#929)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/subagentstop-artifact-gates-review-notes-929`
**Base Branch:** `origin/main` (merge base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`)
**Head Branch:** `bug/subagentstop-artifact-gates-review-notes-929` (`af34e23e4ccc91ce2c3f8e95324958a1eb2d41c8`)
**Review Type:** Initial feature review (feature-vs-base)

**Total blocking findings: 1.**

---

## Executive Summary

The branch changes one production hook and its bundle mirror (NB-5), converts seven Pester suites to a new shared envelope helper (NB-4), and adds characterization and dispatch tests for NB-1, NB-2, NB-3, NB-9, and NB-11. The production edit is behavior-preserving: the deleted line was `$agentOutput = $assistantMessage`, and the three former alias reads now read `$assistantMessage` (`.claude/hooks/validate-task-researcher-output.ps1:244`, `:248`, `:265`). The dependency-decision statements at lines 238-239 are unchanged.

The NB-4 conversion is mechanical. The reviewer compared every removed builder body with the helper: key order, `ConvertTo-Json -Compress`, the `last_assistant_message` omission rule, and the bound-only `output` key are identical. Suites that used `prd-feature`, `task-researcher`, or `pr-author` pass that value through `-AgentType` at every converted call site; the discovery suite relies on the `general-purpose` default, which matches its removed builder.

Concurrent #928 (remote head `37545a357`) touches the same production file only in its docstring and script tail and adds no old-builder call site; a read-only trial merge with this branch completes without conflict.

**Top 3 risks:**
1. Repo-wide PowerShell coverage is not evidenced by a full-suite run (CR-2, blocking, evidence only).
2. The Linux case-sensitive dot-source path is confirmed only by the CI Linux job (AC-27, pending CI).
3. NB-2 breadth remains by design; it is pinned by characterization rows and documented in E3 Risk 5a.

**PR readiness recommendation:** **Not ready** until CR-2 is resolved; CR-1 should be fixed in the same remediation cycle.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `artifacts/pester/powershell-coverage.xml` (evidence gap; no repository file is defective) | report-level `LINE` counter | CR-2 (= PA-1): The only PowerShell coverage artifact comes from a run scoped to `tests/scripts/claude-hooks` and `tests/scripts/claude-runtime`; it reports 8623/18115 = 47.60% repo-wide across the 203 configured files. No full-suite counter is recorded in evidence. | Run the self-hosted `Invoke-PoshQCTest -Root <worktree>` without `-ScanFolders` and record the report-level `LINE` counter verbatim under `evidence/qa-gates/`, or record it from the CI `poshqc-test-results` artifact for the PR head. | The review contract requires repo-wide >= 85% per changed language; a scoped artifact cannot demonstrate it. A prior full run on a near-identical base (#936) recorded 94.57%, so a pass is likely but is not evidenced for this head. | Reviewer per-package parse of the XML; `final-pester-selfhosted.2026-10-16T05-12.md` command line |
| Minor (Non-blocking) | `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` | lines 329-336 | CR-1: The NB-11 case builds its envelope from a hand-written JSON literal (`$inputText = '{"session_id":"e3-905",...,"last_assistant_message":"Done. Findings recorded."}'`) instead of `ConvertTo-SubagentStopEnvelopeJson`; the Describe's `BeforeAll` (line 331) dot-sources the hook but not the helper. | Add `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` to the Describe's `BeforeAll` and replace line 336 with `$inputText = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage 'Done. Findings recorded.'`. | NB-4's intent is one shared envelope builder; this item introduced a second, untracked envelope construction in the same file. AC-09 does not detect it because it searches only for the old builder name. | File read; diff hunk `@@ -318,3 +325,26 @@` |
| Info | `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1` | lines 4-15 | CR-3: The new dispatch suite sits next to the pre-existing `validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` (issue #475). The two are complementary (the new file mocks the seam and tests the loop; the older file must not mock the seam), but the similar names may be confused. | No action required; the header states the placement reason. | Discoverability only. | File reads of both suites |

No other Major or Minor findings.

---

## Implementation Audit

### Python implementation audit

N/A: no Python file changed.

### TypeScript implementation audit

N/A: no TypeScript file changed.

### PowerShell implementation audit

- **Correctness (NB-5):** The alias removal reads the same value at every former read site. `Select-String`-equivalent reviewer grep for `\$agentOutput\b` returns 0 in both copies. The `-AgentOutput` parameter names of `Get-ResearchPathFromOutput` and `Test-AutomationFeasibilitySection` are unchanged.
- **Guard shape:** `$dependencyDecision = Get-HookDependencyFailureDecision ...` and `if ($null -ne $dependencyDecision) { return $dependencyDecision }` remain the first two statements of `Invoke-TaskResearcherOutputValidation` (lines 238-239), satisfying S1/S6.
- **Mirror parity:** `cmp` reports the source and the bundle mirror identical.
- **Helper (NB-4):** `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` defines one function with `[CmdletBinding()]`, `[OutputType([string])]`, `[AllowEmptyString()]` on `AssistantMessage`, and an `AgentType` default of `general-purpose`. No suppression is needed because `ConvertTo-` is not a state-changing verb. The file is not named `*.Tests.ps1`, so Pester does not run it as a container.
- **Concurrency with #928:** #928 changes line 23 (docstring) and lines 289-290 (tail `try`/`catch`); this branch changes lines 244-265. `git merge-tree --write-tree` exits 0.
- **Suppressions:** Seven removed, none added.
- **File size:** Largest touched file 420 lines.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `evidence/regression-testing/r3-prd-feature.2026-10-16T01-13.md`, `r3-task-researcher.2026-10-16T01-13.md`: NB-1/NB-2 rows pass.
- `evidence/regression-testing/r4-discovery.2026-10-16T01-16.md`: NB-3 cases pass.
- `evidence/regression-testing/nb9-dispatch.2026-10-16T01-19.md`, `evidence/other/nb9-placement-decision.2026-10-16T01-16.md`: dispatch suite and the 470-line placement rule.
- `evidence/regression-testing/nb11-dependency-decision.2026-10-16T01-22.md`: NB-11 case passes.
- `evidence/regression-testing/nb4-*.md` and `nb4-follow-up.2026-10-16T04-25.md`: per-suite conversion runs and the follow-up for call sites merged from `main`.
- `evidence/qa-gates/final-*.md`, `coverage-comparison.2026-10-16T05-13.md`, `ac09-*.2026-10-16T05-24.md`: final toolchain, coverage, and the post-merge AC-09 census.

### Quality assessment prompts

- **Determinism:** No clock, sleep, randomness, or file write in any added line.
- **Isolation:** Each `It` targets one function; dispatch cases mock `Invoke-DiscoveryValidatorExe` per test.
- **Precision:** Dispatch assertions use `-Times 1 -Exactly` with a two-argument `-ParameterFilter` per distinct reference plus a total count; the short-circuit case asserts `-Times 0` for the reference after the failing one. The message deliberately includes a duplicate, a backtick-wrapped, a parenthesized, and empty-after-trim tokens.
- **Word-boundary rows:** `allocated`, `subtree`, and `worktrees` reject rows pin the `\b` anchors of the R3 pattern; `ENTIRE WORKTREE` pins `(?i)`.
- **State restoration:** The NB-11 case restores `$script:HookDependencyFailures` to an empty `List[object]`, the same type the guard initializes (`.claude/hooks/hook-dependency-guard.ps1:22`).
- **Arrange-Act-Assert:** Markers present in every new `It`.

---

## Security / Correctness Checks

- No gate decision, exit code, or message string changed; `test_claude_planning_integrity_contracts.py` (which pins validator strings) passes (reviewer rerun, 20 passed with the parity module).
- The R3 regular expression is unchanged in both validators; `.claude/hooks/validate-prd-feature-output.ps1` is absent from the branch diff.
- No secret, credential, `.env` file, or workflow change.

---

## Research Log

- `spec.md` (decisions 1-11, AC-01 to AC-27), `issue.md` (work mode `full-bug`), `plan.2026-10-15T15-44.md` (114 checked tasks, 0 unchecked).
- `git diff origin/main...HEAD` for every non-evidence file.
- `.claude/hooks/hook-dependency-guard.ps1:22-75` (failure list type and decision function).
- `.github/workflows/_poshqc.yml:38-82` (CI full-suite coverage step and directory-based Linux hook job).
- #928 remote head `37545a357`: diff of `.claude/hooks/validate-task-researcher-output.ps1`, `git grep` for the old builder, `git merge-tree` trial merge.
- `artifacts/pester/powershell-coverage.xml` per-package `LINE` counters.

---

## Verdict

**Request changes.** 1 blocking finding (CR-2, evidence gap, autonomous). CR-1 is Minor and related to NB-4; fix it in the same remediation cycle. CR-3 is Info and needs no action.
