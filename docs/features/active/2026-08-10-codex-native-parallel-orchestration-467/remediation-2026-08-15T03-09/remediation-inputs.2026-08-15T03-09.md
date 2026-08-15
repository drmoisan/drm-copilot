# Remediation Inputs: Issue #467 Final Authorized R5

Timestamp: 2026-08-15T03-09<br>
Feature: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`<br>
Reviewed base: `main` / merge base `768e485ddf3b48b16aa7588a72709e17568ee5f5`<br>
Reviewed exact committed HEAD: `2d44e14f48706bb317ee8b81d23b2b2f7cee1c5d`<br>
Work mode: `full-feature`<br>
REVIEW_STATUS: REMEDIATION_REQUIRED<br>
TERMINAL_HANDOFF_ONLY: YES<br>
EXECUTION_AUTHORIZED: NO<br>
CYCLE_3_AUTHORIZED: NO

## Authority and Purpose

This file is the primary requirements source for the terminal remediation plan. The plan is a planning artifact only. Creating it does not authorize preflight, execution, another remediation cycle, source/test/policy/configuration edits, staging, committing, pushing, pull-request work, or CI monitoring.

The final R5 adjudication is binding:

- Overall policy status: `NON-COMPLIANT`.
- Overall feature readiness: `NEEDS REVISION`.
- Code-review findings: exactly 1 Blocker; Major 0; Minor 0; Nit 0; Info 0.
- Acceptance criteria: 43 total; 39 PASS; 2 FAIL; 2 UNVERIFIED; 0 PARTIAL.
- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`.
- `POWERSHELL_BRANCH_POLICY_UNRESOLVED`.

## Primary Blocking Finding

### R5-B1 — PowerShell genuine branch coverage is not established

- **Severity:** Blocker.
- **Affected acceptance criteria:** `spec.md` S-D14 and `user-story.md` U20.
- **Observed evidence:** The fresh PowerShell run passed 2,447 tests with 9 disabled and zero failures/errors. Report-level line coverage is 4,040/4,260 = 94.835681%; source-attributed line coverage is 6,529/7,035 = 92.807392%; all 25/25 owners are attributed; 17/17 added owners meet the 90% line threshold; and 8/8 modified owners satisfy applicable line/no-regression requirements.
- **Blocking result:** `artifacts/pester/powershell-coverage.xml` contains no report-level `BRANCH` counter. Covered branches = 0, missed branches = 0, denominator = 0. The uniform branch threshold is 75%.
- **Required behavior:** A future separately authorized execution may close this finding only by producing genuine source-attributable observed control-flow branch outcomes through the repository-approved toolchain, then proving the numeric result is at least 75% and non-regressing.
- **Fail-closed behavior:** If genuine branch evidence cannot be produced without violating the prohibitions below, the plan must preserve `REMEDIATION_REQUIRED` and explicitly stop. It must not manufacture a passing metric.

Command hits, line hits, AST positions, source positions, source-position correlations, or synthetic counters are not distinct observed control-flow branch outcomes and cannot satisfy this finding.

## Unverified Hosted-CI Criteria

- `spec.md` S-D15 and `user-story.md` U21 remain UNVERIFIED because canonical PR context reports no hosted required-check result for exact head `2d44e14f48706bb317ee8b81d23b2b2f7cee1c5d`.
- The remediation plan must not treat publication, PR mutation, or CI monitoring as authorized by this handoff.
- Exact-head hosted checks may be evaluated only in a later coordinator-authorized publication/CI phase.

## Required Plan Outcomes

The remediation plan must:

1. Use this file as the primary requirements source and write only the exact target `remediation-plan.2026-08-15T03-09.md`.
2. Use deterministic atomic phase headings and sequential `[P#-T#]` checkbox IDs.
3. Include Phase 0 policy reads and baseline/evidence validation under the canonical `<FEATURE>/evidence/<kind>/` hierarchy.
4. Preserve the reviewed base/head identities, the 43-criterion inventory, and the binding branch adjudication.
5. Bound any hypothetical future implementation to genuine branch evidence using already approved repository capabilities; no dependency addition is authorized.
6. Require a fail-before or schema-valid exception dossier under `evidence/regression-testing/` for any future test-first work.
7. Require check-only/full QA verification in repository order, with numeric coverage and no-regression evidence, if and only if a future coordinator separately authorizes execution.
8. Require the exact plan validator `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type=plan` before returning the plan.
9. Record `TERMINAL_HANDOFF_ONLY: YES`, `EXECUTION_AUTHORIZED: NO`, and `CYCLE_3_AUTHORIZED: NO`.
10. End at validated planning. Do not include or initiate a preflight handoff, executor handoff, staging, commit, push, PR, or CI action in this turn.

## Verification Requirements for a Future Separately Authorized Execution

These commands and checks are plan requirements only and must not be run by the planner:

- `mcp__drm-copilot__run_poshqc_format` with the explicit workspace root.
- `mcp__drm-copilot__run_poshqc_analyze` with the explicit workspace root.
- `mcp__drm-copilot__run_poshqc_test` with the repository-default scan configuration and coverage output.
- Independent parse of `artifacts/pester/powershell-coverage.xml` that requires a genuine positive branch denominator and at least 75% observed branch coverage.
- Source-attributed owner verification: all added owners at least 90%, all modified owners at least 80% with no regression, and repository line coverage at least 85%.
- Exact executable-input freshness checks for Python, TypeScript, and Bash before reusing their accepted evidence; otherwise run their complete ordered toolchains.
- `git diff --check <merge-base>..HEAD`, `.claude/**` invariance, root/bundle parity, file-size, suppression, dependency, policy/threshold, evidence-location, and scope checks.
- Re-evaluate all 43 acceptance criteria and keep hosted-CI criteria UNVERIFIED until exact-head hosted evidence exists.

## Do Not Do

- Do not edit `AGENTS.md`, `.agents/skills/**`, quality tiers, coverage thresholds, coverage exclusions, or policy documents.
- Do not create or apply a waiver, exception, suppression, or synthetic branch metric.
- Do not add, update, or substitute any dependency or lockfile.
- Do not relabel command hits, line hits, AST positions, source positions, or correlations as branch coverage.
- Do not modify source, tests, configuration, generated runtime assets, `.claude/**`, acceptance sources, the active cycle-2 plan, or `artifacts/orchestration/orchestrator-state.json` during planning.
- Do not create additional audit or remediation siblings.
- Do not run preflight, launch `atomic-executor`, execute plan tasks, start cycle 3, stage, commit, push, create/update a PR, or monitor CI.
- Do not convert either UNVERIFIED hosted-CI criterion to PASS from local evidence.

## Canonical Context Package

The planner must read these exact files before writing the plan:

### Primary requirements

- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/remediation-2026-08-15T03-09/remediation-inputs.2026-08-15T03-09.md`

### Canonical PR context

- `artifacts/pr_context.summary.txt` — SHA-256 `C9728A9A536ED0C87D13610440EC04B73450AAB09BBDA391B77B2EF59449EB86`
- `artifacts/pr_context.appendix.txt` — SHA-256 `7AFFF5088C330E43E3E032980A06A4AE251B92CA22CB596E793F79EE5B7C150A`

### New R5 review artifacts

- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-15T03-09/policy-audit.2026-08-15T03-09.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-15T03-09/code-review.2026-08-15T03-09.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/audit-2026-08-15T03-09/feature-audit.2026-08-15T03-09.md`

### Original feature requirements and plan

- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/issue.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/spec.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/user-story.md`
- `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/plan.2026-08-10T20-25.md` — SHA-256 `1307CDB6B5641C6B29642E43162F17B8567382573C19386EC4F2F85075BCD28D`

### Prior review/remediation cycle artifacts

- `audit-2026-08-14T09-36/policy-audit.2026-08-14T09-36.md`
- `audit-2026-08-14T09-36/code-review.2026-08-14T09-36.md`
- `audit-2026-08-14T09-36/feature-audit.2026-08-14T09-36.md`
- `audit-2026-08-15T00-56/policy-audit.2026-08-15T00-56.md`
- `audit-2026-08-15T00-56/code-review.2026-08-15T00-56.md`
- `audit-2026-08-15T00-56/feature-audit.2026-08-15T00-56.md`
- `remediation-2026-08-14T09-36/remediation-inputs.2026-08-14T09-36.md`
- `remediation-2026-08-14T09-36/remediation-plan.2026-08-14T09-36.md`
- `remediation-2026-08-15T01-09/remediation-inputs.2026-08-15T01-09.md`
- `remediation-2026-08-15T01-09/remediation-plan.2026-08-15T01-09.md`

All relative prior-cycle paths above resolve beneath `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/`.

### Grouped cycle-2 evidence

- `evidence/other/cycle2-executor-to-orchestrator-handback.2026-08-15T01-09.md`
- `evidence/other/cycle2-powershell-branch-decision.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-executable-input-freshness.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-final-comparison.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-powershell-format.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-powershell-analyze.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-powershell-test.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-powershell-coverage.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-python-reuse.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-typescript-reuse.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-bash-reuse.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-policy-thresholds.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-semantic-consistency.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-root-bundle-parity.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-claude-invariance.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-dependencies.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-suppressions.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-evidence-locations.2026-08-15T01-09.md`
- `evidence/qa-gates/cycle2-final-scope.2026-08-15T01-09.md`

## Terminal Planning Return Contract

The planner must return:

- exact plan path;
- SHA-256 and byte count;
- phase count and atomic task count;
- exact nested agent path and route `atomic-planner-c4`;
- exact MCP plan-validator result;
- confirmation that only the target plan file was written;
- explicit `TERMINAL_HANDOFF_ONLY: YES`, `EXECUTION_AUTHORIZED: NO`, and `CYCLE_3_AUTHORIZED: NO`.
