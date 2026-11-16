# Task Check: P2-T5 (remediation cycle 1, C1 atomic-plan-contract)

Timestamp: 2026-11-14T14-38
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 (red run after adding -TestPath to $canonicalRequired and before the skill edit); sh SCRATCH/issue-1158-ps-filestatic.sh; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <13 files that read atomic-plan-contract>; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the Pester files that read atomic-plan-contract and the ledger suites>
EXIT_CODE: 0
Output Summary: the six TCW-CANONICAL rows failed on the pre-edit text (130 passed, 6 failed) and pass after it. Scoped Pester run (8 workers): 1359 tests in 36 files, 0 failures, 1 skipped, including test-cadence-wording 136, parallel-gate-wording 108 (PGW-PLAN rows), planning-contract-wording 114, less-evidence-contract 77, ledger chain 5, ledger index 15, and the blast-radius and orchestrator-state suites that read the skill. pytest over the 13 contract files that read the skill: 128 passed. The copies keep their P0-T2 classes: three byte-identical pairs (.claude with its bundle, .agents with its bundle, .github with its bundle), SHA256 equal per pair. Format 0 diffs and PSScriptAnalyzer 0 findings on test-cadence-wording.Tests.ps1.

## Changed Files

- .claude/skills/atomic-plan-contract/SKILL.md, .agents/skills/atomic-plan-contract/SKILL.md, .github/skills/atomic-plan-contract/SKILL.md: one sentence added to the Task check (after each task). bullet of ## Test Cadence (Mandatory); every existing token of the bullet is kept. The three bundle copies are re-copied.
- tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1: -TestPath added to $canonicalRequired.
- docs/engineering/process-reductions/0011-task-check-cadence.md: the three blocks whose Current is the ## Test Cadence (Mandatory) section carry the sentence; the Rebased over #1158 paragraph is extended.

## Selection and Rule

Every test file that reads atomic-plan-contract (found by searching tests/ for the skill name) and the two ledger suites.

| Command | EXIT_CODE |
|---|---|
| scoped pester, test-cadence-wording only, before the skill edit (expected red) | 1 |
| format check and PSScriptAnalyzer, test-cadence-wording | 0 |
| launcher pytest, 13 files | 0 |
| scoped pester, 36 files | 0 |
