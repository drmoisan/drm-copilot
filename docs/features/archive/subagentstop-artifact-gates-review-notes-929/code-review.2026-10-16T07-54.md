# Code Review: SubagentStop artifact-gate review notes (#929)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/subagentstop-artifact-gates-review-notes-929`
**Base Branch:** `origin/main` (merge base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`)
**Head Branch:** `bug/subagentstop-artifact-gates-review-notes-929` (`09f319079`)
**Review Type:** Re-audit after remediation cycle 1 (feature-vs-base)
**Prior review:** `code-review.2026-10-16T05-25.md` (Request changes; CR-2 blocking, CR-1 Minor, CR-3 Info)

**Total blocking findings: 0.**

---

## Executive Summary

Cycle 1 changed one test file and added evidence. The test change (commit `bb386ed6b`) adds `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` to the NB-11 Describe's `BeforeAll` (`tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:332`) and replaces the hand-written JSON literal with `ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage 'Done. Findings recorded.'` (`:337`). The helper emits keys in the same order with the same values, and the executor recorded a case-sensitive equality check against the removed literal (`IDENTICAL=True`). CR-1 is resolved.

CR-2 (repo-wide PowerShell coverage evidence) is resolved by a full self-hosted PoshQC run on `bb386ed6b`: 10405 passed, 0 failed, report-level `LINE missed="1731" covered="16384"` = 90.44%. No PowerShell file changed after that run.

The reviewer re-read the full item diff for non-evidence files. The production edit (NB-5) and the NB-4 conversion are unchanged since r1 and remain correct. No new Major or Minor defect was found in the code.

**Top 3 risks:**
1. The branch is behind `origin/main` by two merged PRs (#948, #950). A trial merge is clean and the AC-09 census holds on the merged tree, but the branch must be updated before the PR is opened (CR-5).
2. The Linux case-sensitive helper dot-source path is confirmed only by the CI Linux job (AC-27, pending CI).
3. NB-2 breadth remains by design; it is pinned by characterization rows and documented in E3 Risk 5a.

**PR readiness recommendation:** **Ready** after the branch is brought up to date with `origin/main`.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved | `artifacts/pester/powershell-coverage.xml` (evidence gap in r1) | report-level `LINE` counter | CR-2 (= PA-1, r1 blocking): resolved. Full run without `-ScanFolders` records 16384/18115 = 90.44%; per-file counter for the changed hook `missed="2" covered="100"`. | None. | The 85% default repo-wide line threshold is met; root `CLAUDE.md` states no threshold. | `evidence/qa-gates/coverage-repo-wide.2026-10-16T07-38.md`; `rc1-f1-currency.2026-10-16T07-50.md` |
| Resolved | `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` | lines 332, 337 | CR-1 (= PA-4, r1 Minor): resolved. The NB-11 case now builds its envelope with the shared helper; the helper fragment count in this file is 2. | None. | One envelope builder for all converted suites, as NB-4 intends. | Diff `8d9bad34c..HEAD`; `rc1-f2-envelope-identity.2026-10-16T07-09.md`; `rc1-f2-suite.2026-10-16T07-15.md` |
| Info | `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1` | lines 4-15 | CR-3: unchanged from r1. The new dispatch suite and the pre-existing `validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` have similar names and complementary purposes. | No action required; the header states the placement reason. | Discoverability only. | File reads |
| Info | `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` | line 15 | CR-4: `ConvertTo-DiscoveryEnvelopeJson` still builds a SubagentStop envelope locally (without `agent_type`). It predates the branch (E3 commit `e2284acf4`) and spec.md line 44 lists folding it into the shared helper as not adopted. | No action in this item. | Explicitly out of scope; not introduced by this branch. | `git log -L` on `origin/main`; spec.md:44 |
| Minor (Non-blocking) | Branch state | `origin/main` `a880c46b9` vs merge base `5bc97774b` | CR-5 (= PA-7): `origin/main` advanced by PRs #948 and #950 (`scripts/dev-tools/*`, `tests/scripts/dev-tools/*`, and feature folders for #930 and #931). None of those paths overlap this branch. `git merge-tree --write-tree HEAD origin/main` completes without conflict, and `git grep New-SubagentStopEnvelopeJson` on the merged tree returns nothing. | Merge or rebase onto `origin/main` and push before opening the PR. | A PR diff and its CI must reflect the current base. | Reviewer `git log 5bc97774b..origin/main`, `git merge-tree`, `git grep` |
| Info | Commit metadata | `git log origin/main..HEAD` trailers | CR-6 (= PA-8): every non-merge commit carries `Co-Authored-By`; `Claude-Session` is absent on 13 commits (including `8d9bad34c`) and four different session URLs appear on the rest. The caller attributes this to attribution guidance changing during the run. No policy file or workflow makes a trailer a merge requirement. | No action; history is not rewritten. | Observation only. | Reviewer `git log --format=%(trailers)`; repository search for `Claude-Session` |

No other Major or Minor findings.

---

## Implementation Audit

### Python implementation audit

N/A: no Python file changed.

### TypeScript implementation audit

N/A: no TypeScript file changed.

### PowerShell implementation audit

- **Correctness (NB-5):** Unchanged since r1. The alias assignment is removed and the three former read sites read `$assistantMessage` (`.claude/hooks/validate-task-researcher-output.ps1:244`, `:248`, `:265`). The dependency-decision statements remain first in `Invoke-TaskResearcherOutputValidation`.
- **Mirror parity:** Reviewer `cmp` of the hook and its bundle mirror: exit 0.
- **Production scope:** `git diff --name-only origin/main...HEAD -- .claude .codex extensions scripts .github` lists only the two NB-5 paths; the cycle 1 diff lists none.
- **Helper (NB-4):** Unchanged since r1. `[CmdletBinding()]`, `[OutputType([string])]`, `[AllowEmptyString()]`, `AgentType` default `general-purpose`, no suppression.
- **F2 edit:** The added dot-source follows the hook dot-source in the same `BeforeAll`, matching the pattern used by the other converted Describes. The helper is defined after the hook loads, and the hook defines no function of the same name, so no shadowing occurs.
- **File size:** F2 file 351 lines; largest touched file 420 lines.

---

## Test Quality Audit

### Reviewed test and QA artifacts

- Cycle 1: `evidence/regression-testing/rc1-f2-*.md` (file state, envelope identity, format, analyze, suite), `evidence/qa-gates/rc1-*.md` (final format, analyze, MCP test, suite coverage, coverage comparison, F1 currency, file state, scope diff, spec unchanged, remediation status), `evidence/qa-gates/coverage-repo-wide.2026-10-16T07-38.md`, `evidence/remediation-baseline/*.md`.
- Item: the evidence reviewed in r1 (`r3-*`, `r4-discovery`, `nb9-*`, `nb11-*`, `nb4-*`, `final-*`, `ac09-*`).

### Quality assessment prompts

- **Determinism:** No clock, sleep, randomness, or file write in any added line, including the F2 edit.
- **Isolation:** Unchanged; the NB-11 case still restores `$script:HookDependencyFailures` in `finally`.
- **Precision:** The NB-11 assertions are unchanged (`ExitCode` 2, ordinal prefix, dependency name), each with `-Because $result.Reason`.
- **Regression check for F2:** Single-suite hook coverage missed 18 of 102 before and after; 66 passed before and after (`rc1-coverage-comparison.2026-10-16T07-50.md`).
- **Full-suite run:** 10415 discovered, 10405 passed, 10 skipped, 0 failed; JUnit `FAILURES=0 ERRORS=0`. The branch adds no `-Skip` marker.

---

## Security / Correctness Checks

- No gate decision, exit code, or message string changed; `test_claude_planning_integrity_contracts.py` and `test_push_down_claude_resource_contracts.py` pass (reviewer rerun at `09f319079`: 20 passed).
- The R3 pattern is unchanged in both validators.
- No secret, credential, `.env` file, or workflow change.
- `validate_evidence_locations.py --root <worktree>`: exit 0.

---

## Research Log

- `remediation-inputs.2026-10-16T05-25.md`, `remediation-plan.2026-10-16T05-25.md` (47 of 47 tasks checked).
- `git diff 8d9bad34c..HEAD` (cycle 1) and `git diff origin/main...HEAD` (item) for every non-evidence file.
- `git log 5bc97774b..origin/main`, `git diff --name-only 5bc97774b origin/main`, `git merge-tree --write-tree HEAD origin/main`, `git grep` on the merged tree.
- `git log --format=%(trailers)` on `origin/main..HEAD`; search of `.github/instructions/`, `.github/workflows/`, `.claude/` for `Claude-Session`.
- `artifacts/pester/powershell-coverage.xml`, regenerated by the reviewer with a full run at `09f319079` (90.44%; see policy audit PA-6).

---

## Verdict

**Approve.** 0 blocking findings. CR-1 and CR-2 are resolved. CR-5 (branch behind `origin/main`, conflict-free) is a pre-PR step. CR-3, CR-4, and CR-6 are informational. AC-26 and AC-27 remain pending CI on the PR head.
