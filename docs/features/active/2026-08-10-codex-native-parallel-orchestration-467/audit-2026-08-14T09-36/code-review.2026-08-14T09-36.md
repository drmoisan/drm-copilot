# Code Review: Codex-Native Parallel Orchestration (#467)

**Review Date:** 2026-08-14
**Reviewer:** `feature-reviewer`
**Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
**Feature Folder Selection Rule:** The supplied active folder matches issue `#467`, the branch suffix, and the materially changed `spec.md` and `user-story.md` scoping documents.
**Base Branch:** `main`
**Head Branch:** `feature/codex-native-parallel-orchestration-467` at `7f63b7323fc88fee0aadb83fa2e603b4480a8039`
**Merge Base:** `768e485ddf3b48b16aa7588a72709e17568ee5f5` (`2026-08-13T18:56:27-04:00`)
**Review Type:** Second-remediation full-feature re-review
**Coverage Revision:** 2026-08-14 fresh PoshQC format -> analyze -> test run against the audited HEAD plus the current test-only correction in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`

---

## Executive Summary

This review covers the complete 1,574-path feature diff relative to `main`, not only the second-remediation commit. The canonical context is `artifacts/pr_context.summary.txt` (SHA-256 `A64D70B67523188A733D1EDDC3B9876E418F6F90B44F6FECA8C304B88B2EDB6B`) with `artifacts/pr_context.appendix.txt` (SHA-256 `03D4F924827F0C2460FB92DD73BA5D8488DA02C0C11EA854285736EBADB47464`) as the exact baseline appendix. The supplied HEAD, merge base, hashes, and clean pre-review worktree were independently verified.

The second remediation closes the prior modified-owner PowerShell line-coverage gaps, canonical Python coverage regression, root `testResults.xml` delta, and the earlier tracked-file whitespace set. A fresh PowerShell rerun confirms 2,456 tests total, 2,447 passed, 9 disabled, 0 failed, and 0 errors. It generated a parseable JaCoCo report with 4,040/4,260 covered lines = 94.835681% and zero branch counters. The bundled report contains 46 unique source-file names and omits the six modified PowerShell owners, so it supplements rather than replaces the source-attributed 25-owner remediation receipt. Current exact evidence also reports 3,971 passing Python tests, 2,690 passing TypeScript tests, and 255 passing Bats tests. Three findings remain: PowerShell branch coverage is still unsupported and non-PASS; the current canonical diff contains three whitespace diagnostics in newly tracked remediation outputs; and the newly added Python coverage test omits the mandatory intent comment above its loop.

**What changed:** The feature adds Codex-native independent parallel planning and execution, deterministic cohorts and bounded batches, isolated worktree/branch/PR ownership, mutation and drift handling, durable resume and receipt validation, publisher and payload parity, native hooks, and multi-language tests. The latest remediation adds source-attributed PowerShell tests and focused Python coverage tests while recording final evidence.

**Top 3 risks:**

1. PowerShell has no source-attributable branch denominator, so the repository-wide 75% branch requirement cannot be verified or passed.
2. The exact current `main`-based feature diff fails repository whitespace validation.
3. The latest Python test change does not satisfy the mandatory loop intent-comment rule.

**PR readiness recommendation:** **Blocked** — two Blocking findings and one Major policy finding require remediation; exact-current-head hosted CI also remains unverified.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `artifacts/pester/powershell-coverage.xml`; `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/index.md` | XML coverage counters; index line 82 | The source-attributed remediation receipt records 6,529/7,035 = 92.807392% line coverage and zero branch counters. The fresh bundled report records 4,040/4,260 = 94.835681%, 476 `LINE` counter nodes, and zero `BRANCH` counter nodes. Because the bundled scan omits all six modified owners, it does not supersede the 25-owner matrix. Both scopes lack a branch denominator. The remediation evidence correctly retains `POWERSHELL_BRANCH_POLICY_UNRESOLVED`, while the older integration index still ends with `Acceptance result: PASS.` | Provide supported source-attributable PowerShell branch coverage at or above 75%, or retain a non-PASS result until a separately authorized policy decision exists. Reconcile the integration index with the final evidence; do not synthesize a waiver. | `.agents/skills/general-unit-test/SKILL.md` and `.agents/skills/quality-tiers/SKILL.md` require branch coverage of at least 75% across all tiers. Unsupported data cannot satisfy that requirement. | Fresh JUnit: 2,456 total, 2,447 passed, 9 disabled, 0 failed/errors, SHA-256 `7440CB81144BE1EDC1F0527FCE094ADCB4D74DAA0899C34E20C78A4A9B7EC8BB`. Fresh coverage XML SHA-256 `FC146941FA72DB4488278B952A3A2FA3808250757CACD6514181D31395768F67`; `evidence/qa-gates/powershell-final-test-coverage.2026-08-13T15-38.md`; `evidence/qa-gates/remediation-final-comparison.2026-08-13T15-38.md`. |
| Blocker | `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-final-kcov.2026-08-13T15-38/data/js/kcov.js`; sibling merged `kcov.js`; `evidence/qa-gates/line-counts-remediation.2026-08-13T15-38.md` | JavaScript line 53 in both generated files; Markdown line 189 | The current canonical feature diff reports two trailing-whitespace diagnostics and one new blank line at EOF. The previous whitespace receipt used the pre-rebase merge base and ran before these untracked outputs were committed, so it does not prove the current diff clean. | Normalize only the three reported whitespace defects, preserve generated coverage semantics and hashes as required, then run `git diff --check 768e485ddf3b48b16aa7588a72709e17568ee5f5..HEAD` against the eventual remediation head. | Full-diff hygiene is a required formatting and zero-regression gate. | The exact check exits nonzero and reports the two `kcov.js:53` diagnostics plus `line-counts-remediation...md:189`. |
| Major | `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` | Line 495 | The newly added `for old, new, expected in replacements:` loop has no intent comment immediately above it. | Add a short intent comment explaining that the loop verifies both cross-wired manifest and plan-branch identities. | `.agents/skills/self-explanatory-code-commenting/SKILL.md` requires an intent comment immediately above every loop and non-trivial comprehension. | Exact branch diff `7f63b732^..7f63b732`; current source lines 488-499. |

No additional Major, Minor, or Nit findings were identified.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Shared readiness, receipt, topology, routing, publisher, mutation, drift, and completion logic remains split into typed modules with deterministic diagnostics.
- The second remediation restores `scripts/dev_tools/parallel_kickoff_contract.py` to 109/109 lines and 38/38 branches and preserves all eight changed-owner comparisons.

#### Typing and API notes

- Final Black, Ruff, and Pyright receipts pass with zero findings, and no new suppression was introduced in the remediation commit.
- The latest change is test-only for Python and does not alter the public API.
- The new test file remains below the 500-line limit at 499 lines.

#### Error handling and logging

- Validation errors remain stable and specific. No broad silent exception path was identified.
- The loop intent-comment omission is a documentation-policy defect, not a runtime correctness defect.

### TypeScript implementation audit

#### What changed well

- TypeScript validation and MCP contracts remain strongly typed and preserve mutation, drift, kickoff, routing, publisher, and artifact parity.
- Final evidence records 194/194 suites and 2,690/2,690 tests passing.

#### Type safety and maintainability

- Prettier, ESLint, TSC, and Jest coverage receipts pass. The five modified owners remain above their individual baselines.
- No TypeScript source changed during the second remediation, so the accepted exact-content evidence remains applicable.

#### Error handling and logging

- Boundary validators continue to fail closed with deterministic messages. No new TypeScript finding was identified.

### PowerShell implementation audit

#### What changed well

- The second remediation raises all six previously failing modified owners above 80%, retains 25/25 source attribution, and preserves all 17 added owners at or above 90%.
- The fresh PoshQC loop reports format and analysis success and 2,447 passed, 9 disabled, 0 failed, and 0 error tests. The test-only correction scopes the cleanup assertion to the `native-hook-contract` session instead of requiring the shared `.codex/state` directory to be absent.
- The generated report is valid XML with 4,040/4,260 covered lines = 94.835681%. Its bundled scan omits the six modified owners, so per-owner conclusions remain anchored to the source-attributed remediation receipt.
- The three newly expanded test files remain under the 500-line limit.

#### API and safety notes

- Hook and launcher behavior remains fail closed with deterministic transport, sealed state, and current-runspace test seams.
- Root/bundle parity and `.claude/**` immutability receipts remain green.

#### Error handling and logging

- Resume, launch, authority, model-routing, and completion failure paths are covered. The remaining PowerShell blocker is evidence capability, not an observed runtime failure.

### Bash implementation audit

- Shfmt, ShellCheck, 255/255 Bats, and 1,339/1,461 = 91.6% line coverage pass. The shell policy expressly defines no Bash branch gate.
- The current finding is limited to whitespace in newly committed generated coverage output, not Bash runtime behavior.

---

## Test Quality Audit

The test evidence is broad and current for the changed remediation tests. The fresh PowerShell run independently confirms the repaired suite and generated coverage output. Its exact JUnit and coverage hashes are recorded below; the prior source-attributed receipt remains authoritative for the 25-owner comparison because the bundled scan omits six modified owners. The tests cover deterministic success, rejection, corruption, resume, concurrency, mutation, drift, publisher, registration, and parity cases. PowerShell branch coverage remains unavailable, and the latest Python test needs one policy-required intent comment.

### Reviewed test and QA artifacts

- `evidence/qa-gates/powershell-final-test-coverage.2026-08-13T15-38.md` — final clean-loop counts, 25-owner matrix, line thresholds, and explicit unresolved branch result.
- `artifacts/pester/pester-junit.xml` — fresh 2,456-test result, SHA-256 `7440CB81144BE1EDC1F0527FCE094ADCB4D74DAA0899C34E20C78A4A9B7EC8BB`.
- `artifacts/pester/powershell-coverage.xml` — fresh bundled JaCoCo report, 4,040/4,260 = 94.835681% lines, zero branch counters, SHA-256 `FC146941FA72DB4488278B952A3A2FA3808250757CACD6514181D31395768F67`.
- `evidence/qa-gates/python-final-test-coverage.2026-08-13T15-38.md` — 3,971 passing tests, repository line/branch coverage, and eight changed-owner comparisons.
- `evidence/qa-gates/typescript-test-coverage.2026-08-13T15-38.md` — 2,690 passing tests and line/branch metrics.
- `evidence/qa-gates/bash-test-coverage.2026-08-13T15-38.md` — 255 passing Bats tests and line-only kcov results.
- `evidence/qa-gates/remediation-final-comparison.2026-08-13T15-38.md` — R1 remains non-PASS; prior R2-R5 disposition and preservation checks.

### Quality assessment prompts

- **Determinism:** Stable fixtures, exact stream assertions, hashes, and current-runspace seams provide deterministic evidence.
- **Isolation:** Focused red/green receipts identify behavior-specific ownership. No new external-service dependency was introduced.
- **Speed:** Recorded Python, TypeScript, PowerShell, and Bash runtimes are within the repository's normal local-gate range.
- **Diagnostics:** Receipts include exact commands, exit codes, counts, file hashes, counters, and failure reasons.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff and evidence inspection found no secret-bearing addition. |
| No unsafe subprocess or command construction | PASS | Launcher tests verify sealed command, model, authority, repository, branch, worktree, and hash bindings. |
| Input validation at boundaries | PASS | Manifest, kickoff, hook, mutation, drift, resume, and receipt validators have positive and negative coverage. |
| Error handling remains explicit | PASS | Validators and hooks return deterministic rejection reasons and fail closed. |
| Configuration / path handling is safe | PASS | Provenance, canonical paths, payload-only destination, publisher selection, and worktree isolation are covered. |

---

## Research Log

No external research was required. The review used repository policy, canonical PR-context artifacts, the complete feature diff, requirements, exact-head executor evidence, machine-readable coverage, and minimal read-only reconciliation commands.

---

## Verdict

**REMEDIATION REQUIRED.** The implementation is not ready for normal PR flow because PowerShell branch coverage remains unsupported/non-PASS, the current canonical diff fails whitespace validation, and the latest Python test violates the mandatory loop intent-comment rule. The verified closures for PowerShell owner line coverage, Python canonical coverage, root `testResults.xml`, TypeScript coverage, parity, and `.claude/**` immutability must be preserved. Hosted CI remains unverified for the exact current head and must not be represented as passing.
