# Remediation Inputs: Codex-Native Parallel Orchestration (#467)

**Timestamp:** 2026-08-13T15-38
**Review Status:** REMEDIATION_REQUIRED
**Authoritative requirements source for remediation:** This file
**Feature requirements sources:** `spec.md` and `user-story.md`
**Base:** `main` at merge-base `fe0413d4aca1e76b2d02d05701fba79a887d5405`
**Reviewed head:** `8c7f389a7620834a41fe779116a1d2bab7bf0dd7`
**Finding count:** 5 Blocking; 0 Major; 0 Minor; 0 Nit

## Required Context Package

- `artifacts/pr_context.summary.txt` (SHA-256 `0CBC0FC3000E6793220B98D0CF1EED051530ADF10517EE231354024CE5A357EA`)
- `artifacts/pr_context.appendix.txt` (SHA-256 `74943C7BE1C5522AF85E7E7ADB9362FD5A8BFDD45D35550A562228DB130B073B`)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/policy-audit.2026-08-13T15-38.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/code-review.2026-08-13T15-38.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/feature-audit.2026-08-13T15-38.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/plan.2026-08-10T20-25.md` (original feature plan)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-plan.2026-08-12T01-42.md` (prior remediation plan; preservation context only)
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/remediation-traceability.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/spec.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/user-story.md`

## Verified Prior-Finding Closures to Preserve

1. Python added-owner coverage and R5 documentation policy are closed except for the newly isolated canonical-baseline regression in R3 below. Exact R5 inventories must remain 0 callable-contract failures and 0 actionable adjacency gaps, with the one structurally verified `any(...)` generator adjudication unchanged unless the implementation itself changes.
2. PowerShell source attribution is 25/25 and all 17 added owners are >=90%. Preserve those values while addressing R1 and R2.
3. All five prior TypeScript modified-owner regressions are closed, all TypeScript changed production owners satisfy review thresholds, and the full TypeScript gate is green. Do not alter TypeScript merely to address unrelated findings.
4. Dedicated planner/orchestrator authority is coherent across prompt, profile permission, entry skill, and bundle: planner uses `parallel-planner-workspace`, orchestrator uses `parallel-orchestrator-workspace`, ordinary authority is rejected, and root/bundle parity is 237/237. Preserve this closure.
5. Bash applicable gates pass: 255/255 Bats and 91.6% line coverage. Bash branch coverage is N/A/not-PASS because `.claude/rules/shell.md` expressly states there is no Bash branch-coverage gate. Do not invent branch evidence or treat the unsupported value as PASS.

## Enumerated Fix List

### R1 — Prove or authoritatively resolve PowerShell branch coverage

**Files:** PowerShell coverage configuration/harness and related tests only where required; `artifacts/pester/powershell-coverage.xml`; feature-scoped baseline/QA evidence; applicable policy exception documentation only if separately authorized by the policy owner.

**Current evidence:** `evidence/qa-gates/powershell-tests-coverage.txt` records zero `BRANCH` counters and correctly labels branch coverage unsupported/not-PASS. `.agents/skills/general-unit-test/SKILL.md` and `.agents/skills/quality-tiers/SKILL.md` require >=75% branch coverage across all tiers. No PowerShell-specific waiver was found.

**Required behavior:** Fail closed. Either implement supported, source-attributable PowerShell branch coverage and prove >=75%, or use a separately authorized policy change/exception process that unambiguously resolves the requirement. The executor must not edit policy files merely to make the feature pass and must not reinterpret unsupported evidence as PASS.

**Verification:** Run the complete PowerShell PoshQC format -> analyze -> coverage-enabled Pester loop. Persist a machine-readable branch denominator and percentage >=75%, or an independently authorized policy decision artifact. Reconcile it in the final policy audit without claiming unsupported evidence as PASS.

### R2 — Raise six modified PowerShell owners to the mandatory 80% line floor

**Files and current values:**

- `.codex/hooks/codex-authority-store.ps1`: 46/58 = 79.310345%
- `.codex/hooks/enforce-codex-model-routing.ps1`: 46/79 = 58.227848%
- `.codex/hooks/record-subagent-routing-attestation.ps1`: 111/229 = 48.471616%
- `.codex/hooks/validate-codex-subagent-routing.ps1`: 28/86 = 32.558140%
- `.codex/scripts/launch-epic-child-wave.ps1`: 45/225 = 20.000000%
- `.codex/scripts/resume-epic-child.ps1`: 40/178 = 22.471910%
- Directly related existing Pester owners; byte-identical bundle mirrors only if production source changes require parity updates.

**Required behavior:** Add deterministic source-attributed tests until each listed modified owner is >=80% line coverage. Preserve 25/25 attribution, all 17 added owners >=90%, no regression for the other two modified owners, public epic/parallel behavior, native hook transport, and root/bundle parity.

**Verification:** Run focused expected-red tests before implementation, then bounded green suites. Finish with PoshQC format, analyze, and full coverage-enabled Pester in one clean loop. Emit an exact 25-owner comparison and prove every modified owner >=80% and every added owner >=90%.

### R3 — Restore canonical Python no-regression coverage

**Files:** `scripts/dev_tools/parallel_kickoff_contract.py` and `tests/scripts/dev_tools/test_parallel_kickoff_contract.py`.

**Current evidence:** Canonical feature-start artifact `evidence/baseline/python-coverage.2026-08-10T20-25.json` records 91/91 = 100% lines and 26/26 = 100% branches. Current `evidence/qa-gates/python-coverage-r5-refresh.json` records 107/109 = 98.165137% lines and 36/38 = 94.736842% branches; missing lines are 409 and 413, with missing branches from 408->409 and 412->413. The remediation-start checkpoint is post-feature and cannot replace the canonical baseline.

**Required behavior:** Add focused deterministic tests that execute the two missing validation paths without changing public behavior solely to manipulate coverage. Restore `parallel_kickoff_contract.py` to 100% line and branch coverage against the canonical feature baseline. Preserve all other Python coverage and exact R5 documentation closures.

**Verification:** Capture an expected-red focused coverage receipt, implement only the required tests/seams, then run Black -> Ruff -> Pyright -> full Pytest with branch coverage in one clean loop. Persist the current JSON and an explicit canonical-baseline comparison.

### R4 — Make the complete feature diff pass whitespace validation

**Files:** The 46 paths currently reported by `git diff --check fe0413d4aca1e76b2d02d05701fba79a887d5405 HEAD`, including prior review Markdown, feature evidence receipts, generated kcov JavaScript, and generated Istanbul HTML.

**Current evidence:** The command exits 2 with 486 diagnostic lines across 46 paths for trailing whitespace and new blank lines at EOF.

**Required behavior:** Normalize only the reported whitespace while preserving evidence semantics, generated-report readability, hashes/references that remain authoritative, and repository policies. If regeneration is the canonical method for generated reports, use that method and update affected integrity references deterministically.

**Verification:** `git diff --check fe0413d4aca1e76b2d02d05701fba79a887d5405 HEAD` exits 0 with no output. Revalidate affected evidence links/hashes and all review artifacts that remain current.

### R5 — Remove the unintended partial root Pester report from the feature delta

**Files:** `testResults.xml`; canonical Pester receipts under `artifacts/pester/` and the feature evidence tree.

**Current evidence:** The root file changes by 16 insertions and 348 deletions from a 124-test report to a one-test `parallel-provenance` report with 18 not-run entries and absolute local user/domain/machine/worktree metadata. It does not represent the final 2,430-test run.

**Required behavior:** Restore the baseline-tracked root file or remove the unintended feature delta according to established repository ownership. Do not replace it with another ad hoc local execution report. Retain authoritative final Pester evidence only in approved artifact/evidence locations.

**Verification:** `git diff fe0413d4aca1e76b2d02d05701fba79a887d5405 HEAD -- testResults.xml` is empty, or a separately documented repository contract proves an intentional canonical replacement. Confirm final Pester evidence still reports 2,430 discovered / 2,421 passed / 9 skipped / 0 failed.

### R6 — Reconcile acceptance, evidence, and final review

**Files:** `spec.md`, `user-story.md`, affected evidence indexes/comparisons, the original feature plan, this remediation plan, and fresh review artifacts.

**Required behavior:** Keep S-D13, S-D14, U19, and U20 unchecked until all five findings pass. Keep S-D15 and U21 unchecked/deferred until hosted CI exists for the exact final published head. Preserve all other checked criteria. Synchronize original feature-plan status only when supported by evidence.

**Verification:** Run affected ordered gates and all preserved integrity/parity validators; regenerate canonical PR context for the remediated head; perform a complete feature-vs-`main` re-review; validate all new review artifacts through MCP. Hosted CI remains a later orchestrator-owned lifecycle gate.

## Do Not Do

- Do not narrow the review/remediation scope to the prior remediation commits or omit any of the five Blocking findings.
- Do not modify repository policy files, add an exception, lower thresholds, or reinterpret unsupported PowerShell branch data without separate authoritative approval.
- Do not fabricate coverage, exclude production owners, swap in post-feature baselines, or use test counts as numeric source coverage.
- Do not weaken tests, add suppressions, alter public orchestration semantics for coverage alone, or introduce temporary files in tests.
- Do not regress TypeScript coverage, dedicated persona permissions, source/bundle parity, 25/25 PowerShell attribution, 17/17 PowerShell new-owner coverage, Bash applicable gates, or exact R5 documentation inventories.
- Do not edit `.claude/**`; preserve the verified byte-invariance contract.
- Do not silently skip formatter, lint, type, test, coverage, whitespace, parity, evidence-location, or artifact-validator gates.
- Do not mark S-D15, U21, or any issue-level hosted exact-current-head criterion complete before hosted CI exists for that exact head.
- Do not implement during planning; the delegated planner writes only the plan target below.

## Required Planner Output

Update exactly `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-plan.2026-08-13T15-38.md` in place. Produce deterministic sequential phases and atomic `[P#-T#]` checkbox tasks with explicit ownership, expected-red/green verification, canonical evidence paths, PowerShell branch fail-closed handling, per-owner coverage proofs, whitespace/test-result cleanup, final QA, plan/AC synchronization, and full post-remediation re-review. Do not implement the plan and do not create a sibling remediation plan for this cycle.

## Planner Routing Receipt

The canonical resolvers returned a cross-cutting large topology and the following exact standalone C4 deployment. Both receipts and the C4 complexity assessment are persisted under phase `S17_remediation_planning` in `artifacts/orchestration/orchestrator-state.json`.

```json
{
  "phase": "S17_remediation_planning",
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

Delegation must use `agent_type="atomic-planner-c4"`, `fork_turns="none"`, and omit model/reasoning overrides. Local strict checkpoint validation with `--require-codex-topology --require-codex-model-routing` passed before delegation. The authoritative MCP validator presently reports only five pre-existing `commit-steward` logical-agent incompatibilities in older receipts; it does not identify the new S17 topology or model receipt as invalid.
