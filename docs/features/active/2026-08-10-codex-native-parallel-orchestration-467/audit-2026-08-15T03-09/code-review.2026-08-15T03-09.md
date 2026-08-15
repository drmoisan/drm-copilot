# Code Review: Codex-Native Parallel Orchestration (#467)

**Review Date:** 2026-08-15<br>
**Reviewer:** feature-reviewer-c4<br>
**Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`<br>
**Feature Folder Selection Rule:** The branch name ends in issue 467 and both materially changed scoping documents resolve to this active folder.<br>
**Base Branch:** `main` at `768e485ddf3b48b16aa7588a72709e17568ee5f5`<br>
**Head Branch:** `feature/codex-native-parallel-orchestration-467` at `2d44e14f48706bb317ee8b81d23b2b2f7cee1c5d`<br>
**Review Type:** Final authorized remediation-cycle-2 R5 re-review

## Executive Summary

The complete 1,782-path feature comparison was reviewed using canonical PR context and the exact merge-base range. The branch adds the Codex-native parallel planner/orchestrator surface, shared validation and launch behavior, native hooks, publisher and payload parity, and multi-language tests. The current commit adds only 58 review/remediation/evidence documents over prior reviewed executable boundary `e693a2a32d1c5a936f8a95494900c840139a9b55`; the executable, test, policy, dependency, configuration, and threshold inputs are unchanged.

Implementation evidence is otherwise consistent and complete. Python, TypeScript, Bash, and PowerShell formatting, analysis, type, test, line-coverage, owner-attribution, parity, file-size, suppression, dependency, `.claude/**` invariance, and root/bundle gates pass as applicable. One Blocker remains: the PowerShell coverage XML contains no genuine `BRANCH` counter, so denominator zero cannot satisfy the uniform 75% branch threshold. Hosted CI for exact head `2d44e14f...` is unavailable; that acceptance gap is UNVERIFIED but is not an additional code-review finding.

GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO

POWERSHELL_BRANCH_POLICY_UNRESOLVED

**What changed:** Eight commits add and harden the parallel runtime, publishing surfaces, tests, and two remediation evidence cycles. The final commit is documentation/evidence only and does not alter the reviewed runtime boundary.

**Top risks:**

1. PowerShell branch coverage cannot be established from the accepted collector output.
2. Hosted required checks have not run for the exact committed head.
3. The large cross-runtime surface depends on continued root/bundle and publisher parity, currently verified as 237/237.

**PR readiness recommendation:** **Needs Revision** — the feature must not advance as PR-ready while the required PowerShell branch gate remains unresolved.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `artifacts/pester/powershell-coverage.xml` | Report-level counters; no `counter[@type='BRANCH']` | The accepted PowerShell collector reports 4,040/4,260 lines but zero genuine branch counters and denominator 0, so the uniform 75% branch policy is not satisfied. | Retain `REMEDIATION_REQUIRED`. Only separately authorized future work that produces genuine source-attributable control-flow branch evidence may close this finding; do not weaken policy, change thresholds, create a waiver, add an unapproved dependency, or relabel proxy metrics. | A zero denominator cannot demonstrate the required 75% observed branch coverage. | `evidence/qa-gates/cycle2-powershell-coverage.2026-08-15T01-09.md`; `evidence/other/cycle2-powershell-branch-decision.2026-08-15T01-09.md`; direct R5 XML parse: branch counter count 0. |

No Major, Minor, Nit, or Info findings were identified.

## Implementation Audit

### Python implementation audit

- Shared deterministic authorities, receipt validation, resume truth, kickoff contracts, routing, and publishers are exercised by 3,971 passing tests.
- Black, Ruff, and Pyright pass; line coverage is 92.431562%, branch coverage is 84.788635%, 5/5 added owners meet 90%, and 8/8 changed owners are non-regressing.
- Suppression and intent-comment checks pass. No new Python input changed after the prior review.

### TypeScript implementation audit

- MCP validation, mutation/drift parity, routing, publishing, and artifact dispatch remain strongly typed and tested.
- Prettier, ESLint, TSC, and 2,690 Jest tests pass; coverage is 96.47% lines and 89.79% branches.
- No new TypeScript input changed after the prior review and no suppression drift exists.

### PowerShell implementation audit

- Native hook, authority, launcher, resume, cohort, drift, worktree-removal, and process-transport suites pass.
- PoshQC formatting and analysis pass; 2,447 tests pass with 9 disabled and zero failures/errors.
- Line coverage and all 25 source-attributed owner checks pass. The branch counter gap in the Findings Table remains blocking.

### Bash implementation audit

- Portable normalization, manifest, cohort, batching, and payload-only contracts pass 255 Bats tests.
- Shfmt, ShellCheck, and 91.60% line coverage pass. Bash branch remains N/A/not-PASS and is not an additional finding under the applicable evidence contract.

## Test Quality Audit

The grouped evidence includes fail-before/pass-after receipts, deterministic fixtures, exact process stream assertions, current-input hashes, owner-level coverage, full language loops, parity checks, and exact artifact hashes. Cycle 2 established a 2,576-path executable-input fingerprint with zero tracked or untracked sensitive-path drift and then reran the PowerShell path fresh.

### Reviewed test and QA artifacts

- `evidence/qa-gates/cycle2-final-comparison.2026-08-15T01-09.md` — reconciles all language and repository gates.
- `evidence/qa-gates/cycle2-executable-input-freshness.2026-08-15T01-09.md` — proves exact reuse validity for Python, TypeScript, and Bash.
- `evidence/qa-gates/cycle2-powershell-test.2026-08-15T01-09.md` — records fresh 2,447/2,456 passing-or-disabled results and zero failures.
- `evidence/qa-gates/cycle2-powershell-coverage.2026-08-15T01-09.md` — records passing line/owner gates and the genuine branch denominator failure.
- `evidence/qa-gates/cycle2-root-bundle-parity.2026-08-15T01-09.md` — records 237/237 parity.

- **Determinism:** Stable fixtures, exact hashes, ordered cohorts, and explicit process contracts.
- **Isolation:** Focused matrices isolate routing, receipt, mutation, drift, resume, and transport behaviors.
- **Speed:** Accepted evidence records bounded local suites; no timing workaround was added.
- **Diagnostics:** Stable reason codes, exact stderr/stdout, and explicit mismatch messages are asserted.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Scope and suppression scans identify no secret-bearing addition. |
| No unsafe subprocess or command construction | PASS | Launcher tests enforce immutable executable/profile/repository/worktree bindings. |
| Input validation at boundaries | PASS | Python/MCP/hook matrices reject malformed, stale, incomplete, or mismatched input. |
| Error handling remains explicit | PASS | Fail-closed diagnostics and native exit/stream contracts are tested. |
| Configuration / path handling is safe | PASS | Canonical path, payload-only, root/bundle, and additive-routing checks pass. |

## Research Log

No external research was required for this re-review. Repository policies, canonical PR context, exact diff evidence, requirements, plans, prior reviews, and grouped cycle evidence were sufficient.

## Verdict

**Needs Revision.** The review contains exactly one Blocker and no lower-severity findings. Structural and implementation evidence otherwise remains consistent, but the feature is not ready for normal PR flow because `POWERSHELL_BRANCH_POLICY_UNRESOLVED` prevents the required coverage policy from passing. Hosted exact-head CI must remain UNVERIFIED until the head is published and checked.

REVIEW_STATUS: REMEDIATION_REQUIRED
