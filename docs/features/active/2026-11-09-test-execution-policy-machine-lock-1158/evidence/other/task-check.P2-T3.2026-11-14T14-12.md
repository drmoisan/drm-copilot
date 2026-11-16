# Task Check: P2-T3 (remediation cycle 1, C1 test-execution-policy skill)

Timestamp: 2026-11-14T14-12
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 (red run before the skill edit); sh SCRATCH/issue-1158-ps-filestatic.sh; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <wording, cadence, ledger suites, and tests/scripts/claude-skills/test-execution-policy>; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <three push-down contract files>
EXIT_CODE: 0
Output Summary: the six PGW-SCOPED rows (CLAUDE, AGENTS, GITHUB, and the three bundle copies) failed on the pre-edit text (102 passed, 6 failed) and pass after it. Scoped Pester run: 321 tests in 6 files, 0 failures (parallel-gate-wording 108 including PGW-SWEEP-SURFACES and PGW-SWEEP-HELPER, test-cadence-wording 136, ledger chain 5, ledger index 15, and the two launcher test files); test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, and test_push_down_issue_824_follow_ups.py: 85 passed. The six copies of the skill are byte-identical (P0-T2 class), re-copied from the .claude source, SHA256 equal. Format 0 diffs and PSScriptAnalyzer 0 findings on the wording test.

## Changed Files

- .claude/skills/test-execution-policy/SKILL.md (new subsection ### Scoped Pester runs under ## Commands) and its five byte-identical copies (.agents, .github, three bundle copies)
- tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 (PGW-SCOPED rows)
- docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch (parallel-gate-wording creation hunk) and 0001-parallel-only-test-gates.md (Rebased over #1158 paragraph extended); the skill files lie in no ledger region, and the 0006 hunks needed no change

## Selection and Rule

Contract tests that read the skill and the changed test file: parallel-gate-wording.Tests.ps1, test-cadence-wording.Tests.ps1, the launcher tests under tests/scripts/claude-skills/test-execution-policy, the two ledger suites, and the push-down resource contract tests.

| Command | EXIT_CODE |
|---|---|
| scoped pester, parallel-gate-wording only, before the skill edit (expected red) | 1 |
| format check and PSScriptAnalyzer, wording test | 0 |
| scoped pester, six files | 0 |
| launcher pytest, three contract files | 0 |
