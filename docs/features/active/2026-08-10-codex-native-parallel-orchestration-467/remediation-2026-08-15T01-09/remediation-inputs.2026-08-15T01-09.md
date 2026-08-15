# Remediation Inputs: Codex-Native Parallel Orchestration (#467), Authorized Additional Cycle 2

**Timestamp:** 2026-08-15T01-09
**Review status:** REMEDIATION_REQUIRED
**Authorized cycle:** Additional remediation cycle 2 of 2
**Cycle budget at planning:** requested=2, consumed=1, remaining=1
**Cycle consumption point:** The cycle-2 R5 decision; planning, preflight, execution, and the pre-R4 commit do not consume the cycle.
**Authoritative requirements source for this cycle:** This file
**Feature requirements sources:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/spec.md` and `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/user-story.md`
**Base / merge base:** `main` / `768e485ddf3b48b16aa7588a72709e17568ee5f5`
**Reviewed head:** `e693a2a32d1c5a936f8a95494900c840139a9b55`
**Finding count:** 1 Blocker; 0 Major; 0 Minor; 0 Nit
**Acceptance criteria:** 39 PASS; 2 FAIL; 2 UNVERIFIED; 43 total

## Required Context Package

- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-15T00-56/policy-audit.2026-08-15T00-56.md` (SHA-256 `1667A9B5B44776376F248FF32367297F78A10131690F1833CC9FB88AC1697E15`)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-15T00-56/code-review.2026-08-15T00-56.md` (SHA-256 `2B521202862893C38210E6D98661DAEE4520472B3371FDBF2F649D655228D65D`)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-15T00-56/feature-audit.2026-08-15T00-56.md` (SHA-256 `8C623AA34C333BCDF7C127F3B2FC70250787AE37EB805692A24C2032615D3F64`)
- `artifacts/pr_context.summary.txt` (SHA-256 `8BD213C3796A8F8136AEEF386EF96459DA0C4F14BD40A74CC9E2D6DAF1586EF7`)
- `artifacts/pr_context.appendix.txt` (SHA-256 `54E58599CBD9A7B52F16AE1BD50B2B2CB98C84432974B2430AD061901F3B84C8`)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-2026-08-14T09-36/remediation-inputs.2026-08-14T09-36.md` and `remediation-plan.2026-08-14T09-36.md` as completed-cycle preservation context only
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/powershell-branch-capability-decision.2026-08-14T09-36.md` (SHA-256 `CECD63A502AF7B66D8805F0B4F3240F8D3776F93F399763F6E2CF02962845A10`)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/remediation-final-comparison.2026-08-14T09-36.md` (SHA-256 `F7F0B21EE41680492C2FFA4C3C70CCB3861768E5AE657E7AFEBEEDFC5E035AF7`)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/issue.md`, `spec.md`, `user-story.md`, and `plan.2026-08-10T20-25.md`

The complete grouped R5 set is authoritative for the current findings. The canonical PR-context pair is authoritative for the reviewed branch comparison. Earlier reviews, plans, and evidence establish closures to preserve but cannot override the current R5 verdict.

## Binding Adjudication

`GENUINE_BRANCH_COLLECTOR_ESTABLISHED=NO` and `POWERSHELL_BRANCH_POLICY_UNRESOLVED` are binding inputs for this cycle.

The installed and approved Pester/PoshQC path supplies deterministic command and line observations. It does not supply a genuine, deterministic, source-attributable control-flow branch denominator. Command hits, line hits, AST positions, and correlations among source positions are not branch outcomes. They must not be renamed, transformed, or counted as branch coverage.

This final authorized cycle therefore has no permitted implementation that can honestly change the PowerShell branch verdict. The cycle must complete the required plan, preflight, execution, pre-R4 commit, R4 re-audit, and R5 decision sequence while retaining the semantic failure. No task may require a genuine PowerShell branch PASS as its acceptance condition.

At cycle-2 R5, the budget becomes requested=2, consumed=2, remaining=0. If the expected unchanged result is `REVIEW_STATUS: REMEDIATION_REQUIRED`, orchestration must halt with no cycle 3, push, PR creation, or CI monitoring.

## Verified Closures to Preserve

1. Python remains at 14,350/15,525 = 92.431562% line coverage and 4,894/5,772 = 84.788635% branch coverage; 5/5 added owners are at least 90%, and 8/8 changed owners are non-regressing.
2. PowerShell tests remain 2,447 passed, 9 disabled, and 0 failed/errors. Bundled line coverage remains 4,040/4,260 = 94.835681%; source-attributed line coverage remains 6,529/7,035 = 92.807392%; 25/25 owners are attributed, 17/17 added owners are at least 90%, and 8/8 modified owners satisfy their thresholds.
3. PowerShell genuine branch counters remain 0 with denominator 0. This is a coverage-policy FAIL, not a percentage and not a waiver candidate.
4. TypeScript remains at 44,127/45,740 = 96.47% lines and 6,589/7,338 = 89.79% branches with 2,690 passing tests and 5/5 modified owners non-regressing.
5. Bash remains at 1,339/1,461 = 91.60% lines with 255 passing tests; branch coverage remains N/A/not-PASS under its applicable language gate.
6. The exact merge-base feature diff is whitespace-clean, root `testResults.xml` has no feature delta, `.claude/**` remains byte-invariant, root/bundle parity remains 237/237, and the accepted file-size, suppression, dependency, policy, threshold, and evidence-location checks pass.
7. The authoritative acceptance sources retain 39 checked criteria and four unchecked criteria: S-D14 and U20 are FAIL; S-D15 and U21 are UNVERIFIED.
8. The pre-existing post-commit orchestration-only working-tree files and the complete `audit-2026-08-15T00-56/` group must be preserved and included in the deterministic pre-R4 staging set.

## Enumerated Remediation Work

### R1 — Establish the final-cycle baseline without reopening completed lifecycle work

**Files:** The exact grouped R5 artifacts, canonical PR-context pair, current checkpoint, authoritative requirements, prior accepted QA evidence, and new evidence under `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/remediation-baseline/`.

**Required behavior:** Verify the exact branch, head, merge base, hashes, grouped artifact layout, 39/2/2 acceptance inventory, cycle budget, and current post-commit orchestration-only working-tree inventory. Do not repeat promotion, research, feature-document creation, the original implementation, or previously completed remediation work.

**Verification:** Every command receipt must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Every path must be under the canonical feature evidence subtree except the allowed checkpoint, commit-context, PR-context, and tool-owned Pester outputs.

### R2 — Reconfirm the PowerShell result with approved tooling and fail closed

**Files:** Approved PoshQC/Pester configuration and outputs, the preserved branch-capability decision, and new cycle-2 QA receipts under `evidence/qa-gates/`.

**Required behavior:** Run only the approved PowerShell format, analyze, and full coverage-enabled Pester sequence needed for freshness. Independently parse the resulting line and branch counters. Preserve the valid line, owner, and test results. When genuine branch covered and denominator remain 0, record coverage-policy FAIL and `POWERSHELL_BRANCH_POLICY_UNRESOLVED`.

**Verification:** PoshQC format and analyze must pass without unapproved writes or findings; Pester must pass its tests; the independent parser must report numeric line values and concrete branch covered/missed/denominator values without fabricating a branch percentage.

### R3 — Reuse exact non-PowerShell evidence and prove that reuse remains valid

**Files:** Accepted cycle-1 Python, TypeScript, Bash, parity, invariance, file-size, suppression, dependency, threshold, and evidence-location receipts plus a new cycle-2 source/test/config fingerprint and comparison receipt.

**Required behavior:** Do not rerun broad Python, TypeScript, Bash, translation, publisher, payload, or original implementation suites when deterministic path and content fingerprints prove their executable inputs are unchanged from `e693a2a32d1c5a936f8a95494900c840139a9b55`. If an executable input differs, stop and return a scope-drift blocker; do not expand the plan silently.

**Verification:** The final comparison must retain numeric coverage and test results for all languages, identify each reused evidence path and SHA-256, and explain the exact tree-equality proof that makes reuse valid.

### R4 — Preserve acceptance truth and hand control back before commit/review operations

**Files:** `spec.md`, `user-story.md`, this remediation plan, cycle-2 evidence, and one executor-to-orchestrator handback under `evidence/other/`.

**Required behavior:** Leave S-D14/U20 unchecked and FAIL; leave S-D15/U21 unchecked and UNVERIFIED; preserve all 39 checked criteria. The executor may reconcile this plan only to evidence actually present. The executor must stop at the pre-R4 handback and must not stage, collect commit context, delegate commit-steward, commit, refresh PR context, invoke feature review, decide cycle consumption, create an audit group, create a cycle-3 remediation group, push, create a PR, or monitor CI.

**Verification:** The handback must state the exact index/worktree inventory, evidence paths and hashes, QA and AC results, branch markers, and prohibited actions not taken.

### R5 — Complete orchestrator-owned pre-R4 commit, full R4 review, and terminal R5 decision

**Files:** The deterministic staging manifest, `artifacts/commit_context.txt`, a commit-steward receipt under `evidence/other/`, refreshed canonical PR context, one new `audit-<timestamp>/` group containing exactly the policy/code/feature review artifacts, cycle-2 decision evidence, and `artifacts/orchestration/orchestrator-state.json`.

**Required behavior:** After the executor handback, the orchestrator must stage only the exact preserved and cycle-2 in-scope set, collect canonical MCP commit context, delegate exactly `commit-steward-c4`, commit, refresh PR context through MCP, and delegate exactly `feature-reviewer-c4` for the complete feature-vs-`main` review. Validate the three audit artifacts separately. Record requested=2, consumed=2, remaining=0 and halt when the unchanged PowerShell branch failure produces `REVIEW_STATUS: REMEDIATION_REQUIRED`.

**Verification:** The final state must retain `GENUINE_BRANCH_COLLECTOR_ESTABLISHED=NO`, `POWERSHELL_BRANCH_POLICY_UNRESOLVED`, two failed coverage criteria, two unverified hosted-CI criteria, and explicit proof that no cycle 3, push, PR, or CI action was created or started.

## Ownership Boundary

- `atomic-executor-c4` owns plan execution only through the pre-R4 handback.
- The root orchestrator owns deterministic staging, MCP commit context, exact `commit-steward-c4` delegation, commit, MCP PR-context refresh, audit timestamp binding, exact `feature-reviewer-c4` delegation, three audit validators, cycle consumption, checkpoint transition, and terminal halt.
- The final reviewer owns only the three files in the single new audit group. Budget exhaustion prohibits creation of cycle-3 remediation inputs or a cycle-3 plan.

## Do Not Do

- Do not repeat promotion, research, feature-document creation, original implementation, or completed lifecycle work.
- Do not implement source-position correlation or relabel command, line, AST, or source-position observations as branch coverage.
- Do not fabricate a branch metric or percentage from a zero denominator.
- Do not edit `AGENTS.md`, `.agents/skills/**`, `.claude/**`, quality tiers, coverage thresholds, coverage exclusions, or policy.
- Do not create a waiver or exception, add a dependency, add a suppression, or weaken tests or assertions.
- Do not modify production code, test code, reusable scripts, or coverage configuration in this cycle.
- Do not overwrite, omit, stash, reset, clean, or otherwise discard the current post-commit orchestration-only working-tree files or grouped R5 artifacts.
- Do not mark S-D14, U20, S-D15, or U21 complete without their exact required evidence.
- Do not accept `SKIPPED` as a passing result for a command task that appears in the approved plan.
- Do not create or start cycle 3. Do not push, create a PR, or monitor CI during this cycle.

## Required Planner Output

Create and update only `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-2026-08-15T01-09/remediation-plan.2026-08-15T01-09.md`. Every task must begin unchecked, use sequential `[P#-T#]` IDs, name explicit paths, have one binary acceptance condition, retain canonical evidence locations, and remain preflightable without requiring a genuine PowerShell branch PASS.
