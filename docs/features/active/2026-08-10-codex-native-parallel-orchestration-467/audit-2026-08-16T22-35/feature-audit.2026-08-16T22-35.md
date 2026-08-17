# Feature Audit: Codex-Native Parallel Orchestration (#467)

**Audit Date:** 2026-08-16
**Review Timestamp:** 2026-08-16T22-35
**Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
**Base Branch:** `main`
**Head Branch:** `feature/codex-native-parallel-orchestration-467` at `0c49cc61a73d85e29b3b91b0fccf31b7b76b0980`
**Work Mode:** `full-feature`
**Audit Type:** Full-feature R5 acceptance review under the user-authorized one-time PowerShell branch exception

## Scope and Baseline

- **Base and merge base:** `main` at `768e485ddf3b48b16aa7588a72709e17568ee5f5`.
- **Head:** `feature/codex-native-parallel-orchestration-467` at exact committed head `0c49cc61a73d85e29b3b91b0fccf31b7b76b0980`.
- **Primary evidence:** `artifacts/pr_context.summary.txt`, SHA-256 `ABD8DDE704E266FFE8A555D089C91C2062A38E20F4A107364A7F3DFD8FAE1823`, 160,035 bytes.
- **Secondary evidence:** `artifacts/pr_context.appendix.txt`, SHA-256 `FBD017F43A66F70E78887E5721B717B4400EC1974605E12EEE93EA60C09B89FC`, 406,533 bytes.
- **Requirements sources:** `spec.md`, SHA-256 `1A91DE754471D6BAB3412FA64C77947495E50384DB8F91E8CB015F692EFE8D39`; `user-story.md`, SHA-256 `654BF84DE7FB80A61115C6E1E9EE007E5A2BD858D48531488021F330F58E8897`.
- **Issue source:** `issue.md`, SHA-256 `B188F6C83634860BBDBF8A3DC169DD761E24FFE23A0CB2DEEA943C93E0F67C7D`.
- **Original plan:** `plan.2026-08-10T20-25.md`, SHA-256 `1307CDB6B5641C6B29642E43162F17B8567382573C19386EC4F2F85075BCD28D`; 114/114 tasks are checked.
- **Full range:** 1,845 paths, 799,858 insertions, 1,143 deletions, and 11 commits.
- **Executable boundary:** All 143 paths after `e693a2a32d1c5a936f8a95494900c840139a9b55` are documentation, evidence, requirements, runbook, and audit moves. Exact head `0c49cc61...` adds no runtime code.
- **Supporting receipts:** Two disclosed post-commit untracked receipts were reviewed as supporting evidence but were excluded from the exact committed-head code scope.
- **Hosted CI:** The refreshed PR context does not establish exact-head green hosted checks. S-D15 and U21 remain UNVERIFIED and unchecked.

### PowerShell Exception Boundary

GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO

Source-attributable PowerShell branch numerator/denominator: `0/0`

RAW_BRANCH_RESULT: 0/0 UNAVAILABLE

COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED

No measured result demonstrates that PowerShell branch coverage is at least 75%. S-D14 and U20 pass only by the issue-scoped compliance disposition, not by measurement.

- Runbook: `runbooks/powershell-branch-coverage-one-time-exception.runbook.md`, SHA-256 `1C0761047A7EB4FF8C084A6762DC832004FBD1AB2469B84D0E8158DF9E5B2C7F`.
- Authorization receipt: `evidence/other/cycle3-pass6-powershell-branch-one-time-exception.2026-08-16T21-00.md`, SHA-256 `1BBD4C323BEB8D9F76BF4FB4916452D9087EC89C1AD88C6B9F41AAA625B68B65`.
- Scope: issue #467, this delivery, and the PowerShell raw branch requirement only.
- Unexcepted: retained gates, all other acceptance criteria, hosted CI, full feature review, and checkpoint validation.

## Acceptance Criteria Inventory

**Authoritative sources:** `spec.md` contains 22 criteria; `user-story.md` contains 21 criteria.

### From spec.md

| ID | Criterion |
|---|---|
| S-D01 | Every AC maps to named automated tests or deterministic demonstrations with canonical evidence. |
| S-D02 | Root provenance, forced routing, planning-only behavior, committed-kickoff readiness, monotonic routing, and no fallback pass. |
| S-D03 | Python, TypeScript/MCP, and Bash fixtures prove identical deterministic orchestration decisions. |
| S-D04 | Launcher and resume tests prove immutable bindings, isolation, bounded concurrency, order, and corrupt-state rejection. |
| S-D05 | Per-item origin/main worktrees, branches, PRs, exact-head checks, merge, and worktree-removal completion gates pass. |
| S-D06 | Mutation, pinning, close, detach/abandon, drift, recomputation, conflict, requeue, and resume edge cases pass. |
| S-D07 | Every new hook passes its actual-registration native process matrix. |
| S-D08 | The enforceability ledger reports 16 PRESERVED, 2 tested DEGRADED, 0 LOST, and no omission. |
| S-D09 | Authorized translation uses the corrected research basis and canonical evidence classification. |
| S-D10 | Root/bundle, registration, packs, collision, route merge, allowlisting, and publisher parity pass. |
| S-D11 | A payload-only destination validates and schedules without Python or Poetry. |
| S-D12 | Existing Codex epic and Claude parallel suites pass with no `.claude/**` source change. |
| S-D13 | All changed language surfaces pass ordered formatting, analysis/type, test, and zero-regression gates. |
| S-D14 | Repository line/branch, new-owner, changed-line, and canonical evidence coverage requirements are satisfied. |
| S-D15 | Required hosted checks pass for the exact current PR head SHA. |
| S-T01 | Differential fixtures cover normalization, conflicts, coloring, batching, mutation, open/closed state, pinning, abandon, and drift. |
| S-T02 | Hook process tests cover registration, input errors, poisoned environment, streams, and exit codes. |
| S-T03 | Launcher tests cover immutable identity, mismatch, corrupt state, resume, bounded ordering, and epic-state rejection. |
| S-T04 | Publisher tests cover equality, additive merge, assets, collisions, packs, parity, and payload execution. |
| S-T05 | Translation tests cover corrected basis, classification, canonical paths, override rejection, and complete ledger. |
| S-T06 | Regression suites preserve epic/Claude behavior and `.claude/**` bytes. |
| S-T07 | Current-head CI tests reject stale suites and retain coverage and zero-regression rules. |

### From user-story.md

| ID | Criterion |
|---|---|
| U01 | Parallel entry points resolve only forced authorized personas with no silent fallback. |
| U02 | Planning cannot implement; execution requires a committed, validated, fully preflighted kickoff. |
| U03 | Normalized inputs yield identical cross-runtime conflict edges, cohorts, and bounded batches. |
| U04 | Each item uses a distinct verified origin/main worktree with sealed launch identity. |
| U05 | Each item owns one main-targeted branch/PR and must satisfy exact-head checks, merge, and removal. |
| U06 | Both cohort layers reject later work until predecessors merge and remove worktrees. |
| U07 | Drift detection blocks, quiesces, recomputes, halts conflicts, and requeues consistently. |
| U08 | Mutations enforce order, unique sequence, pinning, destructive confirmation, and open/closed rules. |
| U09 | Resume rejects corrupt, stale, incomplete, or mismatched authoritative state. |
| U10 | Every new hook is registered and passes the complete native process matrix. |
| U11 | Hook allow, deny, and malformed-input streams and exit codes match the native contract. |
| U12 | The final enforceability ledger has 16 PRESERVED, 2 tested DEGRADED, 0 LOST, and no omission. |
| U13 | Translation uses the corrected June 16 Codex ecosystem research source. |
| U14 | Translation classifies outputs, writes canonical evidence, and records non-canonical redirection. |
| U15 | Epic and Claude parallel suites remain green, adapters preserve behavior, and `.claude/**` is unchanged. |
| U16 | Each Codex root file has a byte-identical bundle counterpart and complete pack closure. |
| U17 | Python/TypeScript publishers match, merge additively, preserve routes, enforce collisions, and ship fixed assets. |
| U18 | A payload-only destination validates manifests and computes cohorts/batches without Python or Poetry. |
| U19 | All applicable language, parity, pack, registration, destination, and regression gates pass in order. |
| U20 | Repository line/branch, new-owner, changed-line, and canonical evidence coverage requirements are satisfied. |
| U21 | Required hosted checks pass for the exact current PR head SHA. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence / verification | Notes |
|---|---|---|---|
| S-D01 | PASS | AC mapping and canonical evidence inventory | All 43 criteria were evaluated. |
| S-D02 | PASS | Routing, readiness, and no-fallback receipts | Forced authority preserved. |
| S-D03 | PASS | Python/MCP/Bats differential evidence | Deterministic parity passes. |
| S-D04 | PASS | Launcher and resume evidence | Immutable bindings and rejection paths pass. |
| S-D05 | PASS | Completion and removal suites | Main-only terminal constraints pass. |
| S-D06 | PASS | Mutation/drift/resume suites | Required state edge cases pass. |
| S-D07 | PASS | Registered-process Pester matrix | Native transport matrix passes. |
| S-D08 | PASS | Enforceability ledger | Counts are 16/2/0 with no omission. |
| S-D09 | PASS | Translation plan, diff, and snapshots | Corrected basis and canonical paths pass. |
| S-D10 | PASS | Publisher, pack, registration, parity evidence | Root/bundle parity is 237/237. |
| S-D11 | PASS | Payload-only Bats evidence | Runs without Python/Poetry. |
| S-D12 | PASS | Regression and invariance evidence | Full feature `.claude/**` delta is empty. |
| S-D13 | PASS | Retained ordered language gates | All applicable gates pass. |
| S-D14 | PASS | Coverage reports, owner matrix, runbook, exception receipt | PowerShell raw branch is 0/0 unavailable; PASS is solely by authorized disposition. |
| S-D15 | UNVERIFIED | Refreshed PR-context CI section | Exact-head hosted green result unavailable. |
| S-T01 | PASS | Differential fixture receipts | Required deterministic cases are covered. |
| S-T02 | PASS | Registered hook process receipts | Required process cases are covered. |
| S-T03 | PASS | Launcher contract receipts | Required launch/resume cases are covered. |
| S-T04 | PASS | Publisher and payload receipts | Distribution cases are covered. |
| S-T05 | PASS | Translation tests and ledger | Required translation cases are covered. |
| S-T06 | PASS | Regression and byte-invariance receipts | Existing behavior is preserved. |
| S-T07 | PASS | Current-head CI unit tests | Stale-head rejection is implemented and tested. |
| U01 | PASS | Persona/routing evidence | Authority and no-fallback rules pass. |
| U02 | PASS | Kickoff readiness/preflight tests | Planning/execution boundary passes. |
| U03 | PASS | Cross-runtime fixtures | Cohorts and batches match. |
| U04 | PASS | Worktree launcher receipts | Sealed item binding passes. |
| U05 | PASS | Per-item completion tests | Main-target and removal constraints pass. |
| U06 | PASS | Cohort barrier tests | Premature admission is rejected. |
| U07 | PASS | Drift fixtures | Python/MCP drift behavior matches. |
| U08 | PASS | Mutation fixtures | Ordered mutation behavior passes. |
| U09 | PASS | Resume fixtures | Stale/corrupt state fails closed. |
| U10 | PASS | Registered hook matrix | Registration-resolved cases pass. |
| U11 | PASS | Native stream/exit assertions | Hook transport contract passes. |
| U12 | PASS | Enforceability ledger | 16/2/0 and no LOST gate. |
| U13 | PASS | Corrected-basis tests | Correct source is enforced. |
| U14 | PASS | Apply-mode evidence | Canonical paths and redirection pass. |
| U15 | PASS | Regression and byte checks | Epic/Claude behavior is preserved. |
| U16 | PASS | Root/bundle/registration receipts | 237/237 parity and closure pass. |
| U17 | PASS | Publisher parity and merge tests | Required publisher contracts pass. |
| U18 | PASS | Payload-only validation | Portable destination execution passes. |
| U19 | PASS | Final retained comparison | Applicable ordered gates have zero regressions. |
| U20 | PASS | Coverage reports, owner matrix, runbook, exception receipt | PowerShell raw branch is 0/0 unavailable; PASS is solely by authorized disposition. |
| U21 | UNVERIFIED | Refreshed PR-context CI section | Exact-head hosted green result unavailable. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Acceptance-criteria counts:**

- PASS: 41
- FAIL: 0
- PARTIAL: 0
- UNVERIFIED: 2
- Total: 43

All non-hosted acceptance criteria pass, including S-D14 and U20 only by the authorized one-time PowerShell branch compliance disposition. S-D15 and U21 remain UNVERIFIED because exact-head hosted CI is unavailable. Separately, the authoritative checkpoint validator fails; this mandatory unexcepted gate is the only review Blocker.

### Finding and Gate Summary

- Blocker: 1 — authoritative MCP checkpoint validation.
- Major: 0.
- Minor: 0.
- Nit: 0.
- Info: 0.
- Retained QA regressions: 0.
- Policy or scope defects in the implementation: 0.

### Required Next Verification

1. Reconcile `artifacts/orchestration/orchestrator-state.json` with the authoritative validator without changing exception scope or factual coverage measurements.
2. Rerun authoritative checkpoint validation and require `ok: true`.
3. After publication, require all hosted checks green for the exact head before checking S-D15 and U21.

## Acceptance Criteria Check-off

No requirements source was edited during this review. All 41 PASS criteria were already checked. S-D15 and U21 remain unchecked and UNVERIFIED.

| Source File | Total AC | Checked / PASS | Unchecked / UNVERIFIED | FAIL | PARTIAL |
|---|---:|---:|---:|---:|---:|
| `spec.md` | 22 | 21 | 1 (S-D15) | 0 | 0 |
| `user-story.md` | 21 | 20 | 1 (U21) | 0 | 0 |
| **Total** | **43** | **41** | **2** | **0** | **0** |

## Verdict

**REMEDIATION REQUIRED.** Forty-one acceptance criteria pass, none fail or are partial, and two hosted-CI criteria remain unverified. The PowerShell branch requirement is accepted only through the one-time issue-scoped compliance disposition; the raw result remains 0/0 unavailable and is not a measured branch PASS. The unexcepted authoritative checkpoint-validation failure prevents R5 readiness.

REVIEW_STATUS: REMEDIATION_REQUIRED
