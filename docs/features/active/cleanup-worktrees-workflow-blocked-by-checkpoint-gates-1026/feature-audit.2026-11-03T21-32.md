# Feature Audit: Cleanup-Context Legs for the Checkpoint Gates (#1026), Re-Audit After Remediation Cycle 1

---

**Audit Date:** 2026-11-03
**Feature Folder:** `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
**Base Branch:** `main`
**Head Branch:** `bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 1 (prior audit `feature-audit.2026-11-03T19-05.md`)

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` at `01706c697f3ad4a53b4a771d99d851afc7417ea9`)
- **Head branch/commit:** `bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026` (commit `5dc6b1aefdd0fb8b91d1a659329822364a409b5a`)
- **Merge base:** `01706c697f3ad4a53b4a771d99d851afc7417ea9`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-03 21:25:47 UTC at the head SHA)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 01706c697f3ad4a53b4a771d99d851afc7417ea9 HEAD`
  - Feature evidence: `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/evidence/**`, including the cycle 1 records under `evidence/remediation-baseline/`, `evidence/other/` (20-12 to 20-20), `evidence/qa-gates/` (20-21 to 21-21), and `evidence/regression-testing/` (21-14, 21-20)
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/parallel/shard-{1..8}/powershell-coverage.xml` (parsed in this review); a plain `Invoke-Pester` run of 38 touched suites in this review (1395 passed, 0 failed); test-name matching against the passed set
- **Feature folder used:** `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the only AC source. Checkbox items in other `issue.md` sections are not AC for this mode.
- **Scope note:** full branch diff against the merge base. The cycle changed test expectations only inside the new cleanup suites (sub-code assertions on consolidation-target denials) and kept every non-consolidation exact-text assertion. No spec AC text changed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/spec.md` - only source (`## Acceptance Criteria`, 21 checkbox items)

### Acceptance criteria

1. `enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` passes the manifest Write allow test and the four deny tests (wrong `tool`, wrong `schema_version`, non-session-root path, Edit of the manifest), each asserting the unchanged `PREIMPLEMENTATION_GATE_BLOCKED` text.
2. The same suite passes `allows git -C <consolidation root> add of docs/ and .claude/agent-memory/ operands` and `denies git add in the consolidation worktree when any operand is outside the allowlist` (scripts/ operand, root `.md`, `-A`, `-f`, missing `-C`).
3. The same suite passes the four commit tests (allowlisted staged index allow; non-allowlisted path, empty or failed seam, and `-a`/`--amend`/`--pathspec-from-file`/pathspec denies).
4. The same suite passes `identifies the consolidation worktree by porcelain branch documentationandmemories and not by path` with prunable, detached, main-stanza, and different-branch denies.
5. The same suite passes the long-name and 8.3 short-name temporary-root allows and the scratch deny cases, with the temporary root supplied through its seam.
6. The same suite passes the receipt Write allow beneath the consolidation worktree and the deny beneath a non-consolidation worktree.
7. `enforce-pr-author-skill.Cleanup.Tests.ps1` passes the `gh pr create --head documentationandmemories --base main` allow and the K1 to K6 failure tests, each returning `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` with its sub-code.
8. The same suite passes `still requires the orchestrator preflight for a non-consolidation PR with no checkpoint`, `evaluates the docs-only exemption before the cleanup exemption with unchanged results`, and `runs the receipt checks unchanged after the cleanup exemption`.
9. `enforce-model-routing-receipt.Cleanup.Tests.ps1` passes the `Agent(pr-author)` allow and the absent/invalid manifest, non-pr-author, and different-label denies, asserting the unchanged `MODEL_ROUTING_RECEIPT_BLOCKED` text.
10. `enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` (Codex) passes the Codex equivalents plus the `apply_patch` Add allow, the Update/Delete/Move deny, and the entry-tail content forwarding test.
11. `CleanupWorktreeManifestGateMatrix.Tests.ps1` and `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1` pass unchanged, and the end-to-end suite asserts the manifest-authorized removal is allowed by both removal gates with no checkpoint.
12. `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` passes with one `Context` per workflow step, each allowed by every registered hook.
13. Each new cleanup suite pairs every allow case with non-consolidation and session-root denies asserting today's deny text, and the existing preimplementation, PR-author, model-routing, manifest, removal, resolver, and docs-only suites pass without expected-string changes.
14. `hook-cleanup-context.Tests.ps1` passes, covering every fail-closed branch of the four predicates, including prefix case sensitivity and `**/*.md` rejection.
15. `hook-cleanup-context.Parity.Tests.ps1` passes, asserting byte identity of every copy and literal equality with `CleanupWorktreeManifest.psm1` and `CLEANUP_WT_CONSOLIDATION_BRANCH`.
16. `cleanup-merged-worktrees.SkillText.Tests.ps1` passes, asserting the skill and brief text requirements and the removal of `--require-pr-creation-ready` for consolidation PRs.
17. `test_execution_environment_brief_contracts.py` passes, confirming every brief copy is byte-identical.
18. The push-down contract tests, `generate_codex_agent_variants.py --check`, the helpers and targets Parity suites, `legacy-codex-hook-contracts.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1` pass.
19. Each new PowerShell production file reports line coverage at or above 85% in `artifacts/pester/powershell-coverage.xml`, and no changed line in an existing production file reduces coverage.
20. `session-root-reads-850.Constraints.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1` pass with line caps unchanged, and no changed or new file exceeds the hard block.
21. No new Python file is added and no hook invokes Python; all new hook and library logic is PowerShell.

(Items are abbreviated faithfully from `spec.md`; the source text is unchanged.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Manifest Write allow and four denies | PASS | Claude cleanup suite passed in this review's 1395-test run; manifest leg returns an empty `DenySuffix`, so the exact text is kept | `Invoke-Pester` over touched suites; code reading of `Get-OrchestrationCleanupContextResult` | |
| 2 | Consolidation `git add` allow and denies | PASS | Same run; non-allowlisted operands are rejected in `Test-OrchestrationCleanupSegmentShape` before target identity, so the denies keep the unchanged text | Code reading of gate-cleanup lines 273-326 | |
| 3 | Consolidation `git commit` allow and denies | PASS | Same run; the staged-index tests now also assert `CLEANUP_LEG_STAGED_INDEX_EMPTY`, `CLEANUP_LEG_STAGED_INDEX_UNREADABLE`, and `CLEANUP_LEG_STAGED_PATH_NOT_ALLOWLISTED` per variant (`evidence/other/gate-subcode-tests.2026-11-03T20-12.md`) | Test-name match in passed set | The criterion names the tests and does not require unchanged text; the spec permits the consolidation sub-code. |
| 4 | Consolidation identity by porcelain branch | PASS | Same run; listing denials leave `DenySuffix` empty | Code reading of `Find-CleanupConsolidationRecord` use | |
| 5 | Scratch allows in both spellings and denies | PASS | Same run; scratch leg unchanged in the cycle | Test-name match | |
| 6 | Receipt Write allow and non-consolidation deny | PASS | Same run | Test-name match | |
| 7 | PR-author allow and K1 to K6 sub-codes | PASS | `evidence/other/pr-author-remote-head-tests.2026-11-03T20-18.md`; this review's run includes both `CLEANUP_EXEMPTION_REMOTE_HEAD_MISMATCH` tests and the allow with equal commits | Test-name match in passed set | K6 now also covers the published-head condition (R1-1). |
| 8 | Non-consolidation preflight, docs-only ordering, receipt checks after | PASS | Same run; `Get-PrAuthorPreflightExemption` returns before K6 when no consolidation branch is named | Code reading | |
| 9 | Model-routing pr-author allow and denies | PASS | `enforce-model-routing-receipt.Cleanup.Tests.ps1` passed in this review's run; file unchanged in the cycle | `Invoke-Pester` | |
| 10 | Codex equivalents, `apply_patch`, content forwarding | PASS | Codex cleanup suite passed in this review's run (26 tests), including the two new sub-code tests | Test-name match | |
| 11 | Removal suites unchanged; end-to-end removal allowed | PASS | `git diff --name-only` over the two removal suites lists 0 files; end-to-end suite passed in this review's run | `git diff --name-only <merge base> HEAD -- <two suites>` | |
| 12 | End-to-end composition with one Context per step | PASS | End-to-end suite passed; `Set-WorkflowScenario` supplies equal published-head commits | `Invoke-Pester` | |
| 13 | Paired denies; existing suites unchanged in expected strings | PASS | `evidence/qa-gates/scope-check.2026-11-03T21-20.md`; the new test `keeps the exact deny text for the same Write beneath a non-consolidation worktree` pairs the new sub-code case; no pre-existing suite changed an expected string in the cycle | Cycle diff review of test files | |
| 14 | Pure predicate suite | PASS | `hook-cleanup-context.Tests.ps1` passed in this review's run; file unchanged in the cycle | `Invoke-Pester` | |
| 15 | Parity and literal pinning | PASS | Parity suite passed in this review's run; SHA-256 recomputed: one hash per four-file group | `Get-FileHash` over the eight files | |
| 16 | Skill and brief text | PASS | `evidence/other/doc-tests.2026-11-03T20-19.md`; SkillText suite (12 tests) passed in this review's run | `Invoke-Pester` | Brief sub-code sentence is broader than the implementation (code-review Info); the AC tokens are present. |
| 17 | Brief byte-identity contract | PASS | `evidence/other/doc-tests.2026-11-03T20-19.md`; six brief copies share one SHA-256 in this review | `Get-FileHash` over six copies | |
| 18 | Contract, generator, parity, and guard suites | PASS | `evidence/qa-gates/contract-tests.2026-11-03T21-11.md` (zero failures, generator exit 0); `legacy-codex-hook-contracts.Tests.ps1` passed in this review's run | Evidence inspection; `Invoke-Pester` | |
| 19 | New-file coverage at or above 85%; no changed-line regression | PASS | `artifacts/pester/powershell-coverage.xml`: new files 97.94%, 97.94%, 98.06%, 90.32%, 98.44%; no changed line in a modified file is uncovered; Codex gate 100% in the shard union | JaCoCo parse and shard union (scratchpad scripts) | Codex gate single-process 95.32% is a host effect of the pre-existing PATH leak on entry-tail lines that the branch did not change. |
| 20 | Line caps unchanged; no file above the hard block | PASS | Logical counts in this review: largest 506, helpers 499, Codex gate 493; `session-root-reads-850.Constraints.Tests.ps1` passed in this review's run | `@(Get-Content).Count` over changed covered files | |
| 21 | No new Python; no hook invokes Python | PASS | `git diff --name-only <merge base> HEAD` lists 0 `.py` files; cycle hook hunks call only PowerShell seams | Diff scan | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 21 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. At the CI gate, confirm the `windows-latest` `poshqc / PowerShell QC` shard jobs and the Linux hook-suite job pass on the PR head.
2. After merge, run the live manual validation in `spec.md` `## Test Strategy` (full cleanup workflow from a main session with no checkpoint, including a push before `gh pr create`) and record it under `evidence/`.
3. File the pre-existing `run-actionlint.Tests.ps1` PATH leak as a separate issue; it is unrelated to this item.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### Acceptance Criteria Status

- Source: `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/spec.md`
- Total AC items: 21
- Checked off (delivered): 21
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/spec.md` | 21 | 21 | 0 | Checkbox-backed; all 21 were already checked |

No source-file checkbox change was made in this review: all 21 items evaluated PASS and were already `- [x]`.
