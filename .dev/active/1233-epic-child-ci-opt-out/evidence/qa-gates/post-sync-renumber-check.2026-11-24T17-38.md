# Post-Sync Check after the #1228 Merge and Ledger Renumber (Issue #1233)

Timestamp: 2026-11-24T17-38
Command: sh SCRATCH/issue-1233-postsync2-pester.sh (launcher `run-test-suite.sh pester -TestPath` over 18 targeted suites: child-ci-opt-out, test-cadence-wording, regeneration-path, concurrent-review, light-remediation, planning-contract, parallel-gate-wording, early-start skill contracts; HarnessGeneration.RepoGate; ProcessReductionChain*, ProcessReductionLedger*; both opt-out merge-gate suites; session-root-reads-850.Constraints; cross-tree-helper-identity)
EXIT_CODE: 0
Output Summary: Invoke-PoshQCParallelTest workers=8, exit 0 on the first attempt; merged JUnit tests=1012 failures=0 errors=0. Head fa8963062 (origin/main c030729de merged at 71fe3e9a5; ledger entry renumbered 0014 -> 0015). The ledger chain suites ran on the committed tree. Targeted selection only.

Timestamp: 2026-11-24T17-38
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: 147 passed, 0 failed.

Timestamp: 2026-11-24T17-38
Command: pwsh -NoProfile -File scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check; cmp of the four execution-environment copies and both orchestrate skill bundle pairs
EXIT_CODE: 0
Output Summary: harness-generation: no drift; every mirror pair byte-identical.
