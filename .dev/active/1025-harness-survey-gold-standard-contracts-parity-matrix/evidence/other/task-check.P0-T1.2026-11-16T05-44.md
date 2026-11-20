# Task Check — [P0-T1] Light Remediation Cycle 1 (Finding R1)

Timestamp: 2026-11-16T05-44
Plan: docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/remediation-inputs.2026-11-16T05-19.md (`## Light Fix Tasks`)
Issue: 1025

## Changed Files

`## Observable Behaviors` items rewritten as complete, tool-neutral sentences from the named `SKILL.md` section; the `- **OB-<n>** ` prefix, numbering and AC citations are unchanged. Each file below is changed in `.agents/skills/<name>/references/standard.md` and copied byte for byte to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md` (42 files, 26 lines per tree).

| Contract | Items |
|---|---|
| csharp-change-budget-router | OB-2 |
| csharp-qa-gate | OB-1, OB-5 |
| docs-author-page | OB-1 |
| docs-init | OB-1 |
| docs-inventory-surface | OB-1 |
| docs-plan-ia | OB-1 |
| docs-reconcile-behavior | OB-1 |
| docs-review-coverage | OB-1 |
| docs-validate | OB-1 |
| documentation-workflow | OB-1 |
| epic-plan | OB-4 |
| epic-run | OB-1 |
| feature-promotion-lifecycle | OB-2 |
| human-exception-runbook | OB-5 |
| powershell-change-budget-router | OB-2, OB-4 |
| powershell-qa-gate | OB-1, OB-5 |
| pr-base-branch-merge-base | OB-5 |
| python-change-budget-router | OB-4 |
| python-qa-gate | OB-1, OB-5 |
| remediation-handoff-atomic-planner | OB-1 |
| test-execution-policy | OB-1, OB-5 |

Count note: the R1 location list names 26 items in 21 files; the finding's summary sentence states 25. All 26 listed items were fixed.

## Selection

Rule: a changed Markdown path selects the contract tests that read that path. `tests/` files that name `references/standard.md` or `HarnessSkillContract`: `tests/scripts/harness/HarnessInventory.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`, `tests/scripts/harness/HarnessSkillContract.Tests.ps1`. The three sweep suites that scan `.agents/skills` and the bundle: `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1`.

## Commands

1. Format / lint / type check: N/A — the changed files are Markdown; no formatter, linter or type checker in the toolchain applies to them.

2. Contract lint
Command: `sh SCRATCH/issue-1025-lint-contracts.sh <21 R1 contract names>` (imports `scripts/harness/HarnessSkillContract.psm1` and calls `Get-HarnessSkillContractViolation` on the base and bundle copy of each contract)
EXIT_CODE: 0
Output Summary: CONTRACTS_CHECKED: 21 (x2 copies); VIOLATIONS: 0

3. R1 grep
Command: `grep -n ";\.$\|,\.$\|:\.$\|listed above" .agents/skills/*/references/standard.md` (and the same over the bundle copies)
EXIT_CODE: 1 (no match) for both trees
Output Summary: empty output

4. Mirror identity
Command: `cmp -s` of each `.agents/skills/*/references/standard.md` against its bundle copy
EXIT_CODE: 0
Output Summary: no differing pair among the 65 contracts

5. Task Pester selection
Command: `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/harness/HarnessInventory.Tests.ps1 tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1 tests/scripts/harness/HarnessSkillContract.Tests.ps1 tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1`
EXIT_CODE: 0
Output Summary: workers=6; 335 tests, 0 failures, 0 errors (artifacts/pester/pester-junit.xml): test-cadence-wording 136, parallel-gate-wording 108, policy-toolchain-naming 18, HarnessInventory 41, HarnessParityMatrix.RepoGate 7, HarnessSkillContract 25. Task-check evidence only; not a gate and not coverage evidence.

A first launcher call that passed the six paths comma-separated found no test file and started no shard (exit 1); it was re-run with space-separated paths as the launcher documents.
