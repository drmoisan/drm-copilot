# Code Review: Codex-Native Parallel Orchestration (#467)

**Review Date:** 2026-08-17
**Reviewer:** feature-reviewer-c4
**Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
**Feature Folder Selection Rule:** The branch, issue marker, and materially changed `spec.md` and `user-story.md` deterministically resolve to active issue #467.
**Base Branch:** requested `main`; resolved `origin/main` at `eb4ce14c245ecff8a4491e4a8fda3e43e14356e3`; merge base `768e485ddf3b48b16aa7588a72709e17568ee5f5`
**Head Branch:** `feature/codex-native-parallel-orchestration-467` at `d770a36150f471b4e3b9d672d63f6fd4e99a2670`
**Review Type:** Full-feature pass-7 R5 review under the user-authorized one-time PowerShell branch exception

## Executive Summary

The complete 1,878-path, 12-commit merge-base-to-head comparison was reviewed using the refreshed canonical PR-context pair, exact diff anchors, requirements, original plan, prior grouped audits, retained QA evidence, pass-7 candidate evidence, and direct current-checkpoint validation. The branch adds the Codex-native parallel planner/orchestrator surface, deterministic cross-runtime authorities, isolated launch/resume behavior, native hook enforcement, publishing parity, and multi-language tests. No implementation, test, security, or correctness defect was identified.

The pass-7 head commit is evidence-only: 33 paths, all in the active feature folder, with zero governed executable inputs. All 166 paths after executable boundary `e693a2a32d1c5a936f8a95494900c840139a9b55` are under `docs/` or `artifacts/`. Retained implementation gates remain green as applicable.

One Blocker prevents readiness: the authoritative MCP validator rejects the live checkpoint. The local strict validator passes but cannot override MCP failure. Exact-current-head hosted CI is also UNVERIFIED under S-D15/U21, but it is tracked as an acceptance gap rather than a second code finding.

GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO

RAW_BRANCH_RESULT: 0/0 UNAVAILABLE

COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED

No measured result demonstrates PowerShell branch coverage >=75%.

**Top 3 risks:**

1. The active MCP runtime and repository routing contract disagree on `commit-steward`, so authoritative checkpoint validation fails.
2. Exact-current-head hosted checks are not available in the refreshed PR context.
3. The PowerShell branch exception is delivery-specific and cannot be broadened, reused, or treated as a measured PASS.

**PR readiness recommendation:** **Blocked / No-go** — reconcile the authoritative checkpoint validator and then obtain exact-head hosted CI without changing the exception boundary.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `artifacts/orchestration/orchestrator-state.json` | `model_routing_receipts`; `codex_model_routing_receipts[162,166,172,199,200,216,225,242,255]` in the live R5-start state | Authoritative MCP validation fails. The live call reports 11 missing legacy receipts and unsupported `commit-steward` inputs at nine indexes, with the unsupported-index diagnostics duplicated. | Reconcile the checkpoint/runtime schema through the authorized outer orchestration workflow and rerun the authoritative validator to `ok: true`. Preserve historical facts and do not extend the PowerShell exception. | Checkpoint validation is an independent mandatory completion gate. The local strict result cannot supersede the authoritative MCP result. | Direct R5 MCP call with `require_complete=false`, `require_model_routing=true`, `require_codex_model_routing=true`, and `require_codex_topology=true`; local strict current validator exit 0. |

No Major, Minor, Nit, or Info findings were identified.

### Pass-7 Candidate Boundary

Pass 7 ended `PRE_R5_STATUS: ACTIVE_RUNTIME_INCOMPATIBILITY` at `POST_P0_FAILURE: P3-T2`. The repository-local candidate validator passed. The authoritative candidate validator rejected preserved historical `logical_agent=commit-steward` entries at indexes 162, 166, 172, 199, 200, 216, 225, and 242, each duplicated. Candidate SHA-256 `0BD8705F88E9288460D9A0A3D29AA21112BD68557AC9BB5DFDC5C839BE6A5F9C` was not applied. Before outer lifecycle reconciliation, the real checkpoint was byte-identical to execution baseline SHA-256 `81024F3C6C1DB26B51F733D7712CBFBEA020F087275709C008CFDC7360974477`.

The live R5-start index 255 is a later outer-lifecycle receipt and is not retroactively attributed to the pass-7 candidate. Authorization before R5 was `requested=2 consumed=1 remaining=1`; this reviewer does not consume or mutate it.

## Implementation Audit

### Python implementation audit

- Shared deterministic authorities, receipt validation, resume truth, kickoff contracts, routing, and publishers are covered by 3,971 passing tests.
- Black, Ruff, and Pyright pass in retained current-input evidence.
- Coverage is 92.431562% lines and 84.788635% branches; 5/5 added owners meet 90%, and 8/8 changed owners are non-regressing.
- No new executable Python delta exists after `e693a2a3`.

### TypeScript implementation audit

- MCP validation, mutation/drift parity, routing, publishing, and artifact dispatch remain strongly typed and fail closed.
- Prettier, ESLint, TSC, and 2,690 Jest tests pass.
- Coverage is 96.47% lines and 89.79% branches; 5/5 modified owners are non-regressing.
- The observed issue is an active-runtime contract mismatch, not a newly identified TypeScript implementation defect in the reviewed head.

### PowerShell implementation audit

- Native authority, hook, launcher, resume, cohort, drift, removal, and registered-process suites pass.
- PoshQC format and analysis pass; 2,447 tests pass, 9 are disabled, and failures/errors are zero.
- Line coverage is 4,040/4,260 = 94.835681%; 25/25 owners are attributed; 17/17 added owners meet 90%; 8/8 modified owners pass retained thresholds.
- Raw source-attributable branches remain 0/0 unavailable. The exception changes compliance disposition only.

### Bash implementation audit

- Portable normalization, manifest, cohort, batching, and payload-only contracts pass 255 Bats tests.
- Shfmt, ShellCheck, and 1,339/1,461 = 91.60% line coverage pass. Bash branch remains N/A/not-PASS.

## Test Quality Audit

Evidence includes fail-before/pass-after receipts, differential fixtures, exact registered-process stream assertions, owner coverage, current-input hashes, parity checks, and deterministic artifact identities. `evidence/qa-gates/cycle3-pass6-final-comparison.2026-08-15T10-36.md` reports zero retained gate, policy, and scope regressions. Pass-7 evidence records zero governed executable-input paths, so retained language results remain applicable.

### Reviewed test and QA artifacts

- `evidence/qa-gates/cycle3-pass6-final-comparison.2026-08-15T10-36.md` — retained language and repository gate reconciliation.
- `evidence/other/cycle3-pass6-exception-no-implementation-delta.2026-08-16T21-00.md` — governed-input stability.
- `evidence/other/cycle3-pass6-exception-retained-gates.2026-08-16T21-00.md` — PowerShell test, line, and owner facts.
- `evidence/other/cycle3-pass6-exception-raw-branch-reconciliation.2026-08-16T21-00.md` — raw 0/0 result without a synthetic percentage.
- `evidence/qa-gates/local-candidate-validator.2026-08-16T22-50.txt` and `evidence/qa-gates/mcp-candidate-validator.2026-08-16T22-50.json` — split local/authoritative candidate outcomes.
- `evidence/other/pre-r5-handback.2026-08-16T22-50.md` — exact pass-7 stop boundary and ownership.

| Test-quality property | Status | Basis |
|---|---|---|
| Determinism | PASS | Stable hashes, ordering, identities, streams, and reason codes. |
| Isolation | PASS | Focused routing, receipt, mutation, drift, resume, and transport matrices. |
| Speed | PASS | Retained bounded local suites; no sleep/retry stabilization. |
| Diagnostics | PASS | Exact stdout, stderr, exit, mismatch, and validator diagnostics. |
| Coverage | PASS with scoped exception | Measured line/owner and Python/TypeScript branch gates pass; PowerShell branch remains 0/0 unavailable under authorization. |

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Full-scope policy/suppression evidence found no secret-bearing executable addition. |
| No unsafe subprocess or command construction | PASS | Launch tests enforce immutable executable, profile, repository, branch, and worktree bindings. |
| Input validation at boundaries | PASS | Python, MCP, and hook matrices reject malformed, stale, incomplete, and mismatched inputs. |
| Error handling remains explicit | PASS | Fail-closed diagnostics and exact native exit/stream contracts are asserted. |
| Configuration/path handling is safe | PASS | Canonical path, payload-only, root/bundle, collision, and additive-routing tests pass. |
| Root/bundle parity | PASS | Retained evidence reports 237/237 byte-identical files. |
| `.claude/**` invariance | PASS | Direct merge-base-to-head `.claude/**` diff is empty. |
| Checkpoint completion authority | FAIL | Live authoritative MCP validation returns `ok=false`. |

## Research Log

No external research was required for this review. Repository policies, canonical PR context, exact diffs, requirement sources, plan, issue-scoped runbook, retained evidence, pass-7 handback, and direct validators were sufficient.

## Verdict

**Needs Revision / No-go.** Finding count: 1 Blocker, 0 Major, 0 Minor, 0 Nit, 0 Info. The implementation and retained tests pass their applicable gates. S-D14 and U20 pass only through the authorized one-time PowerShell raw-branch disposition; there is no measured PowerShell branch PASS. The independent authoritative checkpoint failure prevents review PASS. S-D15 and U21 remain UNVERIFIED until hosted checks are green for the exact current PR head.

REVIEW_STATUS: REMEDIATION_REQUIRED
