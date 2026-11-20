# Task Check [P1-T4] (H3 plan)

Timestamp: 2026-11-19T15-29
Plan: plan-h3-sync-writer-retirement.md
Changed files: `.vscode/tasks.json` (task labelled `Dev: Sync AGENTS.md from Instructions` removed; 22 lines deleted).
LEDGER-STEP: not applied. H3-REGION-MAP (`h3-ledger-region-map.2026-11-19T14-36.md`) lists the four `.vscode/tasks.json` revert blocks of entry 0001 as outside; no ledger file was modified.
Selection rule: for a changed configuration path, the tests that read it: `tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1` and `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1`; plus `LEDGER-CHAIN-TESTS` (`ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionLedger.Tests.ps1`) named by the acceptance.
Command: pwsh ConvertFrom-Json of .vscode/tasks.json through SCRATCH/issue-1032-r1-run.sh issue-1032-h3-jsonc.ps1 | EXIT_CODE: 0 | parsed (the file is JSON with comments; a strict JSON parser rejects its leading comment at MB as well)
Command: grep -c '"label":' .vscode/tasks.json | 54 (55 at MB: one fewer)
Command: grep -c -F -e 'Sync AGENTS.md' -e sync-agents-from-instructions -e syncAgentsFromInstructions .vscode/tasks.json | 0
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/workflows/VsCodeQualityTasks.Tests.ps1 tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1 tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1 | EXIT_CODE: 0 | 107 tests, 0 failures (15, 18, 5, 69)
Note: a first attempt passed the four paths comma-joined as one argument; the launcher found no test file and started no shard (exit 1); the space-separated form above is the run of record.
EXIT_CODE: 0
Output Summary: tasks.json parses, holds no `Sync AGENTS.md` and no WRITER-TOKENS token, and has one `"label":` fewer than at MB; the tasks.json readers and LEDGER-CHAIN-TESTS pass. Task check only; not gate evidence.
