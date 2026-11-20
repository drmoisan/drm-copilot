# Task Check — [P4-T3]

Timestamp: 2026-11-17T23-05
Command: sh SCRATCH/issue-1028-retry.sh pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py; sh SCRATCH/issue-1028-retry.sh pester -TestPath tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1 tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1; sh SCRATCH/issue-1028-gen.sh rules check
EXIT_CODE: 0
Output Summary: pytest selection: 105 passed. Pester selection: 220 passed, 0 failed. `-Surface rules -Check`: "harness-generation: no drift".

Changed files: the four Copilot instruction files and their bundle copies listed in `evidence/qa-gates/rules-generation.2026-11-17T23-05.md`.
Selection rule: `## Test Cadence (Mandatory)`. The selection is the acceptance suites named for [P4-T3], plus `test-cadence-wording.Tests.ps1` (it pins Copilot instruction wording, D-4), `ProcessReductionLedger.Tests.ps1` and the parity-matrix repository gate. A search of `tests/` and `extensions/drm-copilot/test/` for the four changed file names found one other suite, `sync-agents-from-instructions.Tests.ps1`. It reads mocked paths only, so it was not added.
