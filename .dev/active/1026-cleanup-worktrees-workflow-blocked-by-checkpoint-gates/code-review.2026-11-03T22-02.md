# Code Review: Cleanup-Context Legs for the Checkpoint Gates (#1026), Re-Review After Remediation Cycle 2

---

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
**Feature Folder Selection Rule:** the single active folder whose name carries the canonical issue number 1026; no version subfolder exists.
**Base Branch:** `main` (merge base `01706c697f3ad4a53b4a771d99d851afc7417ea9`)
**Head Branch:** `bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026` at `18da54246fead6a55b32ef866b055a3c952c45b8`
**Review Type:** Re-review after remediation cycle 2 (prior set stamped 2026-11-03T21-32; cycle inputs `remediation-inputs.2026-11-03T21-39.md`)

---

## Executive Summary

The branch makes the `cleanup-merged-worktrees` workflow executable from an agent session that has no orchestrator checkpoint, through allow-side legs in the Claude and Codex preimplementation gates, the PR-author preflight, and the model-routing receipt gate. The full diff is 149 files (+11268/-42). Remediation cycle 2 (`fc1f6b1ca..HEAD`: one docs commit plus plan and evidence commits) addressed R2-1, the prior Info item on the execution-environment brief:

- R2-1 (prior Info N1): the closing sentence of the `Cleanup legs (#1026)` bullet now reads that a preimplementation-gate denial appends the `Cleanup leg not applied` sub-code only after a cleanup leg has identified the consolidation worktree as the target and a later condition fails, and that a call rejected by a prefilter keeps the unchanged deny text. This review compared it with the code: `Get-OrchestrationCleanupConsolidationWriteResult` returns an empty `DenySuffix` for the non-local, non-absolute, and tail-match prefilters, an absent consolidation record, and a different enclosing root, and sets `CLEANUP_LEG_PATH_NOT_ALLOWLISTED` only after the enclosing root equals the consolidation root (lines 249-270); `Get-OrchestrationCleanupConsolidationCommandResult` returns an empty suffix for unresolvable text, unbalanced segments, a segment rejected by `Test-OrchestrationCleanupSegmentShape`, unresolved targets, an absent record, and a non-consolidation target, and sets the `CLEANUP_LEG_STAGED_*` sub-codes only after every target equals the consolidation root (lines 343-403). The sentence also matches the file header (lines 38-51). Closed.

Evidence reviewed: the full branch diff, the cycle 2 diff in full, the PR context summary (generated 2026-11-03 22:00:05 UTC at the head SHA), the cycle 2 evidence, and `artifacts/pester/powershell-coverage.xml`. This review re-ran Invoke-Formatter and PSScriptAnalyzer over the 54 changed PowerShell files (0 changes, 0 findings), 9 cleanup and runtime Pester suites (176/176), the brief and bundle contract tests (42/42), SHA-256 parity of every mirror group, git blob identity of the six brief copies, and the evidence-location validator (exit 0).

**What changed in the cycle:**
- The six execution-environment brief copies: one sentence replaced; one git blob (`f01fd81ed32e023f236f60122e911433c640df84`) across all six.
- `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1`: two `Should -Match` assertions on the new wording and one `Should -Not -Match` on the superseded wording, inside the existing test. Fail-before (1 expected failure) and pass-after (12/12) are recorded.

**Top 3 risks:**
1. The published-head check compares the local remote-tracking ref, not the server; a push to `documentationandmemories` from another clone is not detected. Exposure is low because the documented workflow pushes from the same worktree immediately before `gh pr create`. Unchanged from the prior review; the cycle recorded a no-change decision with reasoning.
2. The live workflow cannot be exercised before merge, because isolated subagents run `main`'s hook copies; the post-merge manual validation in the spec remains the end-to-end confirmation on real git state.
3. The single-process full-tree Pester run on the Linux Codespace host has pre-existing failures outside the diff (Windows fixtures and a PATH leak in `run-actionlint.Tests.ps1`); the `windows-latest` CI shard jobs are the remaining full-scan confirmation.

**PR readiness recommendation:** **Go** - no Blocker, Major, or Minor finding; the Info and Nit items below are non-blocking and were each given a recorded no-change disposition in `remediation-inputs.2026-11-03T21-39.md`.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | `Get-PrAuthorCleanupPublishedHead`, lines 95-124 | The check reads the local `refs/remotes/origin/documentationandmemories`, which reflects the last fetch or push from this clone, not the server state. Related to issue #1026. | None required; the cycle 2 inputs record the no-change reason (a server read would add a network call to a PreToolUse hook). | A rejected push leaves the tracking ref unchanged, so that case still denies. | Code reading; `remediation-inputs.2026-11-03T21-39.md` section `Review items with no change`. |
| Info | `tests/scripts/dev-tools/run-actionlint.Tests.ps1` | test `Add-DirectoryToPath handles paths with trailing separator` | Pre-existing test-order dependence outside the branch diff: `$env:PATH` is assigned outside the restoring context, so later suites that start `pwsh` fail in a single-process full run. Unrelated to issue #1026. | File as a separate issue (fix the leaker and add a guard). | No file of this diff is involved; victims fail identically at the cycle 1 base. | `evidence/remediation-baseline/pester-coverage.2026-11-03T19-56.md`; `evidence/qa-gates/pester-coverage.2026-11-03T21-10.md`. |
| Info | `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | `Get-OrchestrationCleanupContextResult` and the consolidation legs (uncovered lines 82-85, 88, 108, 226, 230, 260, 297, 315, 395, 456, 457, 480) | The Codex copy reports 90.32% line coverage against 98.06% for the byte-identical Claude copy, because the Codex suite mocks both seams. Related to issue #1026. | None required; above the 85% threshold. | The lines execute in the Claude copy of the same bytes. | `artifacts/pester/powershell-coverage.xml` parsed in this review (140/155). |
| Nit | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Invoke-OrchestrationPreimplementationGateDecision`, cleanup call site | `if (($cleanup = Get-OrchestrationCleanupContextResult ...).Allowed)` assigns inside the condition. Related to issue #1026. | Accept as is; the form keeps both gates within their line caps. | Readability only; the result function never throws. | Branch diff of both gates. |

No Blocker, Major, or Minor finding. No new finding was introduced by cycle 2. No covered file is at or above 700 logical lines, so no file-size Warning row applies (largest: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, 506 lines; `enforce-pr-author-skill-helpers.ps1` 499).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The reworded sentence is accurate for both consolidation legs and names the prefilter case explicitly, which the prior wording omitted.
- The sentence stays on the bullet's single physical line and keeps every token that the existing SkillText test `states the cleanup legs and the scratch rule in Hook Execution Context` and the brief contract tests pin.
- The six copies share one git blob; the bundle-parity and brief byte-identity contract tests pass.
- No production file changed, so the cycle 1 coverage record still describes the production code at HEAD.

#### API and safety notes

- No API change in the cycle.
- Analyzer hygiene: 0 PSScriptAnalyzer findings in 54 files; Invoke-Formatter reports no change.

#### Error handling and logging

- Unchanged since cycle 1: `Get-OrchestrationCleanupContextResult` catches every error and returns `Allowed $false` with an empty suffix.

---

## Test Quality Audit

The edited test pins both the new limitation and the absence of the superseded wording, so a regression to the broader statement fails a named assertion.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` (12 tests, 123 logical lines) - three assertions added in `states the published-head condition and the consolidation sub-code in Hook Execution Context`.
- `evidence/regression-testing/fail-before.2026-11-03T21-51.md` - the updated test fails on the unedited brief (exit 1, expected 1); 11 other tests pass.
- `evidence/regression-testing/pass-after.2026-11-03T21-52.md` - 12/12.
- `evidence/regression-testing/isolation-shuffle.2026-11-03T21-57.md` - serial and three seeds, 699/699 each.
- `evidence/regression-testing/isolation-parallel.2026-11-03T21-57.md` - contract modules, 16 workers, 175/175.
- `evidence/qa-gates/contract-tests.2026-11-03T21-53.md` - 175/175, generator exit 0, parity suite 4/4.
- `evidence/qa-gates/scope-check.2026-11-03T21-58.md` and `self-review.2026-11-03T21-58.md`.
- This review: `Invoke-Pester` over the SkillText, parity, predicate, Claude and Codex gate-cleanup, PR-author cleanup, model-routing cleanup, end-to-end, and test-name-uniqueness suites, 176 passed, 0 failed, 0 failed containers.

### Quality assessment prompts

- **Determinism:** fixed-string regex assertions over committed text.
- **Isolation:** one subject per `It`.
- **Speed:** the suite reads two committed files.
- **Diagnostics:** each assertion names the expected phrase.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials, tokens, or host paths in the cycle diff; evidence uses the `SCRATCH` token. |
| No unsafe subprocess or command construction | ✅ PASS | No code change in the cycle. |
| Input validation at boundaries | ✅ PASS | Unchanged since cycle 1. |
| Error handling remains explicit | ✅ PASS | Unchanged since cycle 1. |
| Configuration / path handling is safe | ✅ PASS | The tracking-ref limitation is recorded as Info with a no-change reason. |

---

## Research Log

No external research was required. All conclusions are drawn from the repository diff, the feature-folder evidence, the coverage artifact in the item worktree, and the read-only re-runs listed above.

---

## Verdict

The change is ready for the normal PR flow. Cycle 2 closed R2-1 with a sentence that matches the gate-cleanup implementation and its header, kept the six brief copies byte-identical, and changed no production file. The remaining Info and Nit items do not block merge.
