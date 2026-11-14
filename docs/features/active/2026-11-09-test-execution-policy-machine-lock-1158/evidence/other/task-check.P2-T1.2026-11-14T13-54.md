# Task Check: P2-T1 (remediation cycle 1, F1 executor toolchain list)

Timestamp: 2026-11-14T13-54
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 (red run before the surface edit); sh SCRATCH/issue-1158-gen-write.sh and SCRATCH/issue-1158-gen-check.sh (Codex generator write, then --check); sh SCRATCH/issue-1158-ps-filestatic.sh; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <wording, cadence, ledger, architecture-doc suites>; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <five contract test files>
EXIT_CODE: 0
Output Summary: the eight PGW-LAUNCHER rows failed on the pre-edit text (88 passed, 8 failed: EXEC-CLAUDE, EXEC-CLAUDE-BUNDLE, EXEC-CODEX, EXEC-CODEX-C1, -C2, -C3, -C3-ELEVATED, -C4) and pass after it. Generator --check exit 0; bundle and variant hashes equal; format 0 diffs and PSScriptAnalyzer 0 findings on the wording test; scoped Pester 259 tests, 0 failures (parallel-gate-wording 96, test-cadence-wording 136, ProcessReductionChain.Ledger 5, ProcessReductionLedger.Index 15, claude-architecture-doc 7); contract pytest 61 passed.

## Changed Files

- .claude/agents/atomic-executor.md and its bundle copy (re-copied; SHA256 equal)
- .codex/agents/atomic-executor.toml; the five atomic-executor-c*.toml variants and the six bundle copies (generator write; each pair SHA256 equal)
- tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 ($script:DirectPytestForbidden, PGW-LAUNCHER rows)
- docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch (28 + lines in the 14 executor sections; the parallel-gate-wording creation hunk)
- docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch (parallel-gate-wording hunks regenerated)
- docs/engineering/process-reductions/0001-parallel-only-test-gates.md and 0006-test-suite-baseline-restored.md (Rebased over #1158 paragraphs)

## Selection and Rule

Contract tests that read the changed agent files and ledger paths: parallel-gate-wording.Tests.ps1 (PGW-EXEC and PGW-LAUNCHER rows), test-cadence-wording.Tests.ps1 (EXECUTOR rows), claude-architecture-doc.Tests.ps1 (agent tool names), the two ledger suites, test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_codex_agent_wrapper_contracts.py, test_codex_handoff_contract_parity.py, test_scratch_location_contracts.py, and the generator --check.

| Command | EXIT_CODE |
|---|---|
| scoped pester, parallel-gate-wording only, before the surface edit (expected red) | 1 |
| Codex generator write | 0 |
| Codex generator --check | 0 |
| format check and PSScriptAnalyzer, wording test | 0 |
| scoped pester, five suites | 0 |
| launcher pytest, five contract files | 0 |
