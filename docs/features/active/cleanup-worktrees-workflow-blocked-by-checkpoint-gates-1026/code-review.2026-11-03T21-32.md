# Code Review: Cleanup-Context Legs for the Checkpoint Gates (#1026), Re-Review After Remediation Cycle 1

---

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
**Feature Folder Selection Rule:** the single active folder whose name carries the canonical issue number 1026; no version subfolder exists.
**Base Branch:** `main` (merge base `01706c697f3ad4a53b4a771d99d851afc7417ea9`)
**Head Branch:** `bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026` at `5dc6b1aefdd0fb8b91d1a659329822364a409b5a`
**Review Type:** Re-review after remediation cycle 1 (prior set stamped 2026-11-03T19-05; cycle inputs `remediation-inputs.2026-11-03T19-13.md`)

---

## Executive Summary

The branch makes the `cleanup-merged-worktrees` workflow executable from an agent session that has no orchestrator checkpoint, through allow-side legs in the Claude and Codex preimplementation gates, the PR-author preflight, and the model-routing receipt gate. The full diff is 129 files (+10039/-42). Remediation cycle 1 (`904a862ab..HEAD`, five code and docs commits plus evidence) closed the three carried items:

- R1-1 (prior Minor): `Get-PrAuthorCleanupPublishedHead` resolves `refs/remotes/origin/documentationandmemories` and `HEAD` through the bounded `Invoke-PrAuthorDocsOnlyGitExe` seam, and K6 now returns `CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH` when the remote ref is absent, `HEAD` is absent, or they differ. Closed.
- R1-2 (prior Info): `Get-OrchestrationCleanupContextResult` returns `Allowed` and `DenySuffix`; the gate appends the suffix only after a leg has identified the consolidation worktree as the target and then failed. Every non-consolidation and prefilter-rejected deny stays byte-identical, which the paired `Should -BeExactly` tests confirm. Closed.
- R1-3 (prior Nit): `issue.md` Status names the `-1026` folder. Closed.

Evidence reviewed: the full branch diff, the cycle 1 production hunks in full, the PR context summary (generated at the head SHA), the cycle evidence, and `artifacts/pester/powershell-coverage.xml` plus the eight shard coverage files. This review re-ran Invoke-Formatter and PSScriptAnalyzer over the 54 changed PowerShell files (0 changes, 0 findings), the 38 touched Pester suites (1395/1395), SHA-256 parity of every mirror group, and the evidence-location validator (exit 0).

**What changed in the cycle:**
- `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` (and three copies): result function and reshaped consolidation legs with four `CLEANUP_LEG_*` sub-codes; `Test-OrchestrationCleanupContextAllowed` is now a Boolean wrapper with its prior signature.
- Both `enforce-orchestration-preimplementation-gate.ps1` copies: line-neutral call site that concatenates `$cleanup.DenySuffix` to the unchanged literal.
- `.claude/hooks/enforce-pr-author-skill.cleanup.ps1`: published-head seam and the K6 check before the `origin/main` diff.
- `EpicStateIsolation.Baseline.Helpers.ps1`: a fail-closed default for the new seam.
- Cleanup skill step 4 and the execution-environment brief (six copies) describe the push-before-create condition and the sub-code.

**Top 3 risks:**
1. The published-head check compares the local remote-tracking ref, not the server. A push to `documentationandmemories` from another clone leaves the local tracking ref stale, so the check can pass while the server branch differs. Exposure is low because the documented workflow pushes from the same worktree immediately before `gh pr create`.
2. The live workflow cannot be exercised before merge, because isolated subagents run `main`'s hook copies; the post-merge manual validation in the spec remains the end-to-end confirmation on real git state.
3. The single-process full-tree Pester run on the Linux Codespace host has 409 failed tests from pre-existing causes outside the diff (Windows fixtures and a PATH leak in `run-actionlint.Tests.ps1`); the `windows-latest` CI shard jobs are the remaining full-scan confirmation.

**PR readiness recommendation:** **Go** - no Blocker, Major, or Minor finding; the Info and Nit items below are non-blocking.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/skills/execution-environment/SKILL.md` (and its five byte-identical copies) | `## Hook Execution Context`, cleanup-legs bullet, closing sentence | The sentence "A preimplementation-gate denial whose target is the consolidation worktree appends a cleanup sub-code" is broader than the implementation. A consolidation-target call rejected by a pure prefilter carries no sub-code: for example `git -C <consolidation root> add -- scripts/a.ps1` (rejected in `Test-OrchestrationCleanupSegmentShape` before target identity) or a Write of `<consolidation root>/scripts/a.ps1` (rejected by the `/docs/` tail match in `Get-OrchestrationCleanupConsolidationWriteResult`). | Reword to state that the sub-code is appended when the cleanup leg has identified the consolidation worktree as the target and a later condition fails, or name the four sub-codes. Keep the six copies byte-identical. | Operator expectation accuracy; the behavior itself matches remediation-plan DR2 and spec `Deny wording` ("may be appended only when the target is the consolidation worktree"). | Code reading of `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` lines 235-270 and 328-404; brief diff in `039bdc096`. |
| Info | `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | `Get-PrAuthorCleanupPublishedHead`, lines 95-124 | The check reads the local `refs/remotes/origin/documentationandmemories`, which reflects the last fetch or push from this clone, not the server state. | None required. Optionally state in skill step 4 that the check is local to the consolidation worktree. A `git ls-remote` leg would add a network call to a hook, which the repository avoids. | Residual gap after R1-1: a server branch updated from another clone is not detected. A rejected push leaves the tracking ref unchanged, so that case still denies. | Code reading; test `resolves the published consolidation branch and HEAD through the bounded docs-only git seam`. |
| Info | `tests/scripts/dev-tools/run-actionlint.Tests.ps1` | test `Add-DirectoryToPath handles paths with trailing separator` | Pre-existing test-order dependence outside the branch diff: the test assigns `$env:PATH` outside the context whose `AfterEach` restores it, so 8 later suites that start `pwsh` or resolve Python fail in a single-process full run. Remediation-plan tasks P0-T5 and P5-T3 stay unchecked for this reason. | File as a separate issue (fix the leaker and add a guard); it is unrelated to issue #1026. | The victims pass 356/356 without the leaker and fail identically at the cycle base; no file of this diff is involved. | `evidence/remediation-baseline/pester-coverage.2026-11-03T19-56.md`; `evidence/qa-gates/pester-coverage.2026-11-03T21-10.md`. |
| Info | `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | lines 82-85, 88, 108, 226, 230, 260, 297, 315, 395, 456, 457, 480 | The Codex copy reports 90.32% line coverage against 98.06% for the byte-identical Claude copy, because the Codex suite mocks both seams. | None required; above the 85% threshold and up from 90.14%. | The lines execute in the Claude copy of the same bytes. | `artifacts/pester/powershell-coverage.xml` and the shard union (same figure). |
| Nit | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Invoke-OrchestrationPreimplementationGateDecision`, cleanup call site (Claude line 415, Codex line 452) | `if (($cleanup = Get-OrchestrationCleanupContextResult ...).Allowed)` assigns inside the condition and then reads `$cleanup.DenySuffix` on the next line. | Accept as is; the form keeps both gates line-neutral under their caps (remediation-plan DR3). | Readability only; the result function never throws, so `$cleanup` is always assigned. | Cycle diff of both gates. |

No Blocker, Major, or Minor finding. No covered file is at or above 700 logical lines, so no file-size Warning row applies (largest: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, 506 lines; `enforce-pr-author-skill-helpers.ps1` 499 against its 500 cap and unchanged in the cycle).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The suffix is computed only after consolidation identity is established (Write leg: enclosing root equals the record root; command leg: every target equals that root), so prefilters remain process-free and every other deny text is unchanged.
- The staged-index checks are split into ordered conditions: `$null` or non-zero exit is `UNREADABLE`, empty output is `EMPTY`, non-NUL-terminated output is `UNREADABLE`, and an empty parsed list is `EMPTY`. The split preserves the prior fail-closed outcome for every input.
- `Test-OrchestrationCleanupContextAllowed` keeps its `param` block and Boolean return, so external callers are unaffected.
- `Get-PrAuthorCleanupPublishedHead` validates each value against a 40- or 64-digit lowercase hex pattern and maps throw, non-zero exit, and malformed output to an empty string; K6 also wraps the call and fails closed.
- The K6 published-head check runs before the `origin/main` resolution, so a stale publish is reported before diff evaluation.
- The baseline helper registers a fail-closed default for the new seam only for suites that request the manifest seam, and the two suites that reach K6 override it with equal commits.
- Mirror parity verified in this review: one SHA-256 for each four-file shared group, for each bundle pair, and for the six brief copies.

#### API and safety notes

- New and reshaped functions use `[CmdletBinding()]`, `[OutputType()]`, approved verbs, and `AllowNull`/`AllowEmptyString` where inputs may be empty.
- Analyzer hygiene: 0 PSScriptAnalyzer findings in 54 files; Invoke-Formatter reports no change.
- No `ShouldProcess` is required: the files make decisions and do not mutate state.
- Interpolated values in deny text (`$relative`, `$path`) come from the tool input and the staged index and are rendered as quoted text only; no command is built from them.

#### Error handling and logging

- `Get-OrchestrationCleanupContextResult` catches every error, records `PREIMPL_CLEANUP_LEG_ERROR` through `Write-Debug`, and returns `Allowed $false` with an empty suffix, so an internal failure keeps the exact existing deny.
- `CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH` texts state the condition and the corrective action (push before `gh pr create`).

---

## Test Quality Audit

Automated evidence covers each new sub-code with a direct assertion and pairs the new consolidation Write sub-code with an exact-text test for the same input beneath a non-consolidation worktree.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` (32 tests) - adds `appends CLEANUP_LEG_PATH_NOT_ALLOWLISTED to the deny for a non-allowlisted Write inside the consolidation worktree` and `keeps the exact deny text for the same Write beneath a non-consolidation worktree`; the staged-index tests assert the sub-code per variant.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` (26 tests) - the same additions on the Codex surface.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1` (17 tests) - absent, throwing, and differing published-head cases and the real seam body with the git seam mocked per ref.
- `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` - `Set-WorkflowScenario` supplies equal commits.
- `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` (12 tests) - step 4 and brief text for the new conditions.
- `evidence/other/gate-subcode-tests.2026-11-03T20-12.md`, `pr-author-remote-head-tests.2026-11-03T20-18.md`, `doc-tests.2026-11-03T20-19.md`, `contract-tests.2026-11-03T20-20.md` - focused runs, zero failures.
- `evidence/regression-testing/isolation-shuffle.2026-11-03T21-14.md` - three seeds, 1346/1346 each; `isolation-parallel.2026-11-03T21-20.md` - 0 failures in hook, runtime, and lib suites.
- This review: plain `Invoke-Pester` over 38 touched suites, 1395 passed, 0 failed, 0 failed containers; each new test name found in the passed set.

### Quality assessment prompts

- **Determinism:** all git seams mocked; the new seam has a fail-closed baseline default; no temporary files, sleeps, or wall-clock reads in added test lines.
- **Isolation:** one condition per `It`; withheld-leg helpers mock the result function rather than the wrapper.
- **Speed:** the 1346-test shuffled set completes per seed in one process.
- **Diagnostics:** exact deny strings and sub-codes are asserted, so a regression names the diverging text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials, tokens, or host paths in the diff; evidence uses the `SCRATCH` token. |
| No unsafe subprocess or command construction | ✅ PASS | git runs only through the existing bounded seam with fixed argument arrays; no Python invocation in hook lines. |
| Input validation at boundaries | ✅ PASS | Commit values validated by a hex pattern; operand and path checks unchanged. |
| Error handling remains explicit | ✅ PASS | Fail-closed results on every error path. |
| Configuration / path handling is safe | ✅ PASS | The prior K6 local-versus-remote gap is closed for the documented workflow; the remaining tracking-ref limitation is recorded as Info. |

---

## Research Log

No external research was required. All conclusions are drawn from the repository diff, the feature-folder evidence, the coverage artifacts in the item worktree, and the read-only re-runs listed above.

---

## Verdict

The change is ready for the normal PR flow. The cycle closed R1-1, R1-2, and R1-3 without changing any non-consolidation deny text, kept both gates line-neutral and the helpers file unchanged, and kept every new production file at or above 90.32% line coverage. The Info items (brief wording, tracking-ref scope, an unrelated pre-existing test leak, Codex copy coverage) and the Nit do not block merge.
