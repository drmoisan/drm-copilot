Timestamp: 2026-10-17T18:02:38.893526+00:00
Command: & 'SCRATCH/issue-977-attestation-source.ps1'
EXIT_CODE: 1
Output Summary:

ACTUAL_TARGET: CodexDeployment.psm1; lines 68/68 (100%).
ACTUAL_TARGET: record-subagent-routing-attestation.ps1; lines 189/204 (92.6471%).
ACTUAL_TARGET: method Invoke-CodexSubagentAttestationCommand; lines 36/40 (90%).
[+] .\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 192ms (98ms|70ms)
[+] .\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 25.41s (25.27s|96ms)
[+] .\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 30.89s (30.83s|43ms)
[+] .\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 14.06s (14.01s|36ms)
[-] Codex epic runtime configuration and distribution contracts.keeps root and tracked bundle runtime copies byte-identical 28ms (28ms|1ms)
 at Should -Be (Get-FileHash -LiteralPath $rootPath -Algorithm SHA256).Hash, .\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1:189
 at <ScriptBlock>, .\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1:188
 Expected strings to be the same, but they were different.
 String lengths are both 64.
 Strings differ at index 0.
 Expected: 'DF203E233CD824DB0F549A4B3572C88296191D966F08A74E6052DAC215EB7700'
 But was:  'A363F81883893C3E5DF5B30BB57C9F87288C36D12511A8D436BB7B41855ECD3A'
            ^
[-] Subagent attestation persistence with memory streams.consumes only an authorized receipt and durably flushes before disposal 32ms (32ms|1ms)
 at $receipt.consumed_at | Should -Be $script:Now.ToUniversalTime().ToString('o'), .\tests\scripts\codex-hooks\subagent-attestation-persistence.Tests.ps1:155
 at <ScriptBlock>, .\tests\scripts\codex-hooks\subagent-attestation-persistence.Tests.ps1:155
 Expected '2026-07-10T15:00:00.0000000+00:00', but got 2026-07-10T11:00:00.0000000-04:00.
[+] .\tests\scripts\codex-hooks\subagent-attestation-command.Tests.ps1 311ms (252ms|47ms)
[+] .\tests\scripts\claude-lib\codex-routing\CodexDeployment.Parity.Tests.ps1 197ms (108ms|67ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexModelReceipts.Tests.ps1 310ms (225ms|65ms)
Tests completed in 87.39s
Tests Passed: 334, Failed: 2, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 94.12% / 0%. 374 analyzed Commands in 2 Files.
ACTUAL_TARGET: CodexDeployment.psm1; lines 68/68 (100%).
ACTUAL_TARGET: record-subagent-routing-attestation.ps1; lines 189/204 (92.6471%).
ACTUAL_TARGET: method Invoke-CodexSubagentAttestationCommand; lines 36/40 (90%).
Tests passed=334, failed=2, skipped=0.

Full sanitized output: SCRATCH/issue-977-regression-testing-attestation-source-coverage.log
