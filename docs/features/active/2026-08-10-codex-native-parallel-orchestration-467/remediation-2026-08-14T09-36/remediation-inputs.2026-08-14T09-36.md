# Remediation Inputs: Codex-Native Parallel Orchestration (#467)

**Timestamp:** 2026-08-14T09-36
**Review Status:** REMEDIATION_REQUIRED
**Authoritative requirements source for this remediation cycle:** This file
**Feature requirements sources:** `spec.md` and `user-story.md`
**Base:** `main` at merge base `768e485ddf3b48b16aa7588a72709e17568ee5f5` (`2026-08-13T18:56:27-04:00`)
**Reviewed head:** `7f63b7323fc88fee0aadb83fa2e603b4480a8039`
**Finding count:** 2 Blocking; 1 Major; 0 Minor; 0 Nit

## Required Context Package

- `artifacts/pr_context.summary.txt` (SHA-256 `A64D70B67523188A733D1EDDC3B9876E418F6F90B44F6FECA8C304B88B2EDB6B`)
- `artifacts/pr_context.appendix.txt` (SHA-256 `03D4F924827F0C2460FB92DD73BA5D8488DA02C0C11EA854285736EBADB47464`)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-14T09-36/policy-audit.2026-08-14T09-36.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-14T09-36/code-review.2026-08-14T09-36.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-14T09-36/feature-audit.2026-08-14T09-36.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/plan.2026-08-10T20-25.md` (original feature plan)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-inputs.2026-08-13T15-38.md` (prior-cycle requirements; preservation context only)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-plan.2026-08-13T15-38.md` (prior-cycle execution record; preservation context only)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/other/powershell-branch-capability-decision.2026-08-13T15-38.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/remediation-final-comparison.2026-08-13T15-38.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/powershell-final-test-coverage.2026-08-13T15-38.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/spec.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/user-story.md`

The planner must treat this file as the primary requirements source. The current PR-context artifacts supersede older base/head and diff counts. Prior remediation artifacts are preservation evidence only and must not override the findings below.

## Verified Closures to Preserve

1. All six previously deficient modified PowerShell owners now meet the 80% line-coverage floor. The complete final result is 25/25 source owners attributed, 17/17 added owners at or above 90%, and 8/8 modified owners meeting the applicable threshold without regression.
2. `scripts/dev_tools/parallel_kickoff_contract.py` is restored to 109/109 lines and 38/38 branches against the canonical feature-start baseline. The complete Python comparison reports 8/8 changed owners non-regressing.
3. The root `testResults.xml` feature delta is empty relative to merge base `768e485ddf3b48b16aa7588a72709e17568ee5f5`.
4. The previously identified whitespace set was normalized. Only the three newly introduced diagnostics enumerated in R2 remain in the current canonical diff.
5. TypeScript remains green with 2,690 tests, 96.47% line coverage, 89.79% branch coverage, and 5/5 modified owners non-regressing.
6. Bash applicable gates remain green with 255/255 tests and 91.6% line coverage. Bash branch coverage remains N/A/not-PASS because `.claude/rules/shell.md` defines no Bash branch gate.
7. The complete Python suite remains green with 3,971 passed and 5 skipped, 92.431562% repository line coverage, and 84.788635% repository branch coverage.
8. The complete PowerShell suite remains green with 2,447 passed, 9 skipped/disabled, and 0 failed; repository line coverage is 32,645/35,175 = 92.807392%.
9. The dedicated parallel planner/orchestrator authority, kickoff readiness, deterministic graph/cohort/batch behavior, native hook transport, mutation/drift/resume behavior, publisher parity, payload portability, 237/237 root/bundle parity, and `.claude/**` byte-invariance findings remain closed.
10. The current source files `spec.md` and `user-story.md` correctly retain 37 checked criteria and six unchecked criteria. Do not alter the 37 supported checks unless the implementation regresses them.

## Enumerated Fix List

### R1 - Implement and prove PowerShell branch coverage without a waiver

**Severity:** Blocking
**Files:** `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/convert-poshqc-coverage.ps1`, directly related PoshQC tests under `tests/scripts/powershell/PoshQC/`, PowerShell coverage configuration, `artifacts/pester/powershell-coverage.xml`, and feature-scoped regression/QA evidence. Limit changes to the smallest supported measurement implementation and its tests. Do not change policy files.

**Current evidence:** The exact current report has SHA-256 `CA3A8D470C895B4829D58DEDA5F41503943F70B14076863FF992F4632526BEE4`, 716 `LINE` counters, 32,645 covered lines, 2,530 missed lines, and zero `BRANCH` counters. The prior capability decision confirms that the installed Pester 5.6.1/PoshQC path provides command coverage but no branch denominator. The final remediation evidence correctly records `POWERSHELL_BRANCH_POLICY_UNRESOLVED`; however, `evidence/qa-gates/index.md` still ends the affected coverage section with `Acceptance result: PASS.`

**Required behavior:** Implement a deterministic, source-attributable PowerShell branch measurement that is supported by the repository toolchain and produces a non-zero branch denominator. The measurement must identify executable branch outcomes from repository PowerShell sources, associate observed outcomes with the coverage run, and fail closed on malformed, missing, or non-attributable data. It must not infer branch PASS from line or command coverage alone. The final result must prove at least 75% PowerShell branch coverage while retaining at least 85% repository line coverage, 25/25 feature-owner attribution, 17/17 added-owner line coverage at or above 90%, and all eight modified-owner line thresholds/no-regression checks. Reconcile `evidence/qa-gates/index.md` with the final supported result. If a supported measurement cannot be implemented within repository policy, stop with `POWERSHELL_BRANCH_POLICY_UNRESOLVED`; do not mark this finding or the coverage acceptance criteria PASS.

**Expected-red proof:** Add or run focused tests that reject zero denominators, absent branch records, mismatched source paths, duplicate or inconsistent outcomes, malformed reports, and below-75% results before implementation. Record exact expected-red commands and results under `evidence/regression-testing/` using the current remediation timestamp.

**Verification:** Run PoshQC format -> analyze -> coverage-enabled Pester in the required order and restart at formatting after any failure or mutation. Persist a machine-readable branch denominator, covered/missed counts, percentage, source attribution, and integrity hash. Parse the final artifacts independently and require branch coverage >=75%. Re-run the full owner comparison and the existing 2,456-result Pester inventory. Do not accept a policy exception, unsupported metric, or synthetic waiver.

### R2 - Make the exact current feature diff whitespace-clean

**Severity:** Blocking
**Files and exact current diagnostics:**

- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-final-kcov.2026-08-13T15-38/data/js/kcov.js:53` - trailing whitespace.
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-final-kcov.2026-08-13T15-38/kcov-merged/data/js/kcov.js:53` - trailing whitespace.
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/line-counts-remediation.2026-08-13T15-38.md:189` - new blank line at EOF.

**Current evidence:** `git diff --check 768e485ddf3b48b16aa7588a72709e17568ee5f5..7f63b7323fc88fee0aadb83fa2e603b4480a8039` exits non-zero with exactly these three diagnostics. The prior final diff-check used an obsolete merge base and ran before these outputs were tracked.

**Required behavior:** Normalize only the reported whitespace, preserving report semantics, readability, provenance, and any authoritative integrity references. If regeneration is the canonical method for the kcov assets, use the deterministic generation path and update affected integrity references. Do not apply broad formatter writes to unrelated evidence or generated files.

**Verification:** After the remediation changes are committed, `git diff --check 768e485ddf3b48b16aa7588a72709e17568ee5f5..HEAD` must exit 0 with no output. Revalidate links and hashes for every affected evidence artifact and confirm that Bash remains 255/255 with 1,339/1,461 = 91.6% line coverage.

### R3 - Add the required intent comment above the new Python test loop

**Severity:** Major
**File:** `tests/scripts/dev_tools/test_parallel_kickoff_contract.py`
**Location:** The loop beginning at current line 495: `for old, new, expected in replacements:`.

**Current evidence:** The loop is not immediately preceded by a comment explaining non-obvious intent. This violates `.agents/skills/self-explanatory-code-commenting/SKILL.md`, which applies to every loop in Python source and tests. The test file is 496 lines and remains below the 500-line ceiling.

**Required behavior:** Add one concise intent-first comment immediately above the loop. The comment must explain why all replacement variants are exercised and must not restate the mechanics of the loop. Preserve behavior, assertions, parameter values, file size at or below 500 lines, and the 109/109 line plus 38/38 branch closure for `parallel_kickoff_contract.py`.

**Verification:** Run the focused Python test, the repository documentation/comment-policy check used by the prior R5 audit, and the full Black -> Ruff -> Pyright -> Pytest/coverage loop. Confirm the final test file is at most 500 lines; Python remains at least 85% line and 75% branch coverage; all added owners remain at least 90%; and 8/8 changed owners remain non-regressing.

### R4 - Reconcile acceptance, QA indexes, exact-head evidence, and final review

**Severity:** Blocking until R1-R3 pass
**Files:** `spec.md`, `user-story.md`, the original feature plan, affected feature-scoped evidence indexes/comparisons, the new remediation plan, and fresh review artifacts.

**Current evidence:** S-D13, S-D14, U19, and U20 fail. S-D15 and U21 remain unverified because canonical PR context contains no hosted results for exact head `7f63b7323fc88fee0aadb83fa2e603b4480a8039`. The source files therefore remain at 37/43 checked. The older QA index contains an unsupported overall PASS that conflicts with current PowerShell branch evidence.

**Required behavior:** Keep S-D13, S-D14, U19, and U20 unchecked until R1-R3 and one clean ordered multi-language QA loop pass. Keep S-D15 and U21 unchecked until hosted CI exists for the exact final published head. Preserve all other checked criteria. Ensure every summary and QA index distinguishes supported PASS, FAIL, PARTIAL, UNVERIFIED, and N/A/not-PASS without converting unsupported metrics to PASS. Refresh PR context after the remediation commit and run another complete feature-vs-`main` review.

**Verification:** Re-run affected integrity/parity validators, validate all new review artifacts through the drm-copilot MCP validator, and independently compare the refreshed context head/hash to the final commit. Hosted exact-head CI remains an orchestrator-owned post-publication gate and must not be synthesized locally.

## Required Ordered QA and Evidence

1. Capture a clean remediation baseline before implementation, including Git status, exact base/head, PR-context hashes, current PowerShell XML hash/counters, current diff-check output, Python file size, and the expected-red results.
2. Execute only focused red/green tests while implementing R1-R3. Preserve all prior closures and avoid unrelated production changes.
3. Run PowerShell PoshQC format -> analyze -> full coverage-enabled Pester; parse line, branch, owner, and test-result metrics independently.
4. Run Python Black -> Ruff -> Pyright -> full Pytest with line and branch coverage; compare all changed owners against the canonical feature-start baseline.
5. Re-run TypeScript Prettier -> ESLint -> TSC -> Jest/coverage and Bash shfmt -> ShellCheck -> Bats/kcov when affected evidence or generated reports change. Preserve their verified metrics and parity results.
6. Run the complete feature diff whitespace check against merge base `768e485ddf3b48b16aa7588a72709e17568ee5f5` after all generated evidence is present.
7. Verify the root `testResults.xml` delta remains empty, `.claude/**` remains byte-invariant, all changed runtime/test/reusable-script files remain at or below 500 lines, no new suppressions were introduced, and root/bundle parity remains 237/237.
8. Store new feature evidence under `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/<kind>/`. Tool-owned outputs may remain at their established paths such as `artifacts/pester/powershell-coverage.xml`.
9. Refresh `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` only through the canonical PR-context mechanism after the remediation commit.
10. Perform a full feature review and validate every new policy, code, feature, and remediation artifact through the authoritative MCP validator.

## Do Not Do

- Do not narrow remediation or review scope to the latest commit or omit any current finding.
- Do not modify `AGENTS.md`, `.agents/skills/**`, `.claude/**`, coverage thresholds, or any other policy source.
- Do not request, create, infer, or synthesize a waiver or exception for PowerShell branch coverage.
- Do not report line coverage, command coverage, test counts, AST enumeration, or an absent denominator as branch coverage.
- Do not fabricate coverage, exclude feature-owned production paths, substitute a post-feature baseline for the canonical baseline, or weaken source attribution.
- Do not weaken or remove tests, assertions, failure paths, hooks, permissions, routing receipts, parity checks, or public orchestration behavior to improve metrics.
- Do not introduce temporary files in tests, external service dependencies, new suppressions, unrelated refactors, or broad generated-file rewrites.
- Do not regress the verified Python, PowerShell owner-line, TypeScript, Bash, parity, translation, publication, payload, root-report, or `.claude/**` closures.
- Do not mark S-D13, S-D14, S-D15, U19, U20, or U21 complete without exact supporting evidence.
- Do not silently skip formatter, lint, type, test, coverage, whitespace, integrity, parity, evidence-location, artifact-validator, PR-context, or exact-head gates.
- Do not implement during planning. The delegated planner may update only the plan target named below.

## Required Planner Output

Update exactly `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-2026-08-14T09-36/remediation-plan.2026-08-14T09-36.md` in place. Produce deterministic sequential phases and atomic `[P#-T#]` checkbox tasks with explicit file ownership, preconditions, expected-red/green verification, canonical evidence paths, PowerShell branch fail-closed behavior, current-merge-base diff hygiene, Python comment-policy verification, preservation checks, full ordered QA, plan/acceptance synchronization, refreshed PR context, and a complete post-remediation re-review. Do not implement the plan and do not create a sibling remediation plan for this cycle.

## Planner Routing Receipt

The current run retains a C4 orchestration ceiling. The canonical deployment resolver returned the following exact standalone planner profile:

```json
{
  "c3_overlay_applied": false,
  "c3_overlay_reason": null,
  "complexity_band": "C4",
  "deployment_agent": "atomic-planner-c4",
  "execution_context": "standalone",
  "logical_agent": "atomic-planner",
  "model": "gpt-5.6-sol",
  "model_reasoning_effort": "max",
  "orchestration_complexity_ceiling": "C4"
}
```

Delegation must use `agent_type="atomic-planner-c4"`, `fork_turns="none"`, and no model or reasoning override. The caller/orchestrator owns durable checkpoint receipt persistence and downstream preflight, execution, commit, PR-context refresh, re-review, publication, and exact-head hosted-CI lifecycle actions.
