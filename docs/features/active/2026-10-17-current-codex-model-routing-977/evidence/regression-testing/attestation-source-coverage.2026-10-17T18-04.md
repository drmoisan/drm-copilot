Timestamp: 2026-10-17T18:04:49.785000+00:00
Command: & 'SCRATCH/issue-977-attestation-source.ps1'
EXIT_CODE: 0
Output Summary:

ACTUAL_TARGET: CodexDeployment.psm1; lines 68/68 (100%).
ACTUAL_TARGET: record-subagent-routing-attestation.ps1; lines 189/204 (92.6471%).
ACTUAL_TARGET: method Invoke-CodexSubagentAttestationCommand; lines 36/40 (90%).
Starting discovery in 16 files.
Discovery found 337 tests in 492ms.
Starting code coverage.
Running tests.
[+] .\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 671ms (298ms|264ms)
[+] .\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 13.03s (12.87s|105ms)
[+] .\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 382ms (328ms|38ms)
[+] .\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 315ms (230ms|66ms)
[+] .\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 343ms (259ms|61ms)
[+] .\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 338ms (266ms|52ms)
[+] .\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 134ms (77ms|40ms)
[+] .\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 200ms (104ms|65ms)
[+] .\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 24.68s (24.54s|93ms)
[+] .\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 31.01s (30.95s|45ms)
[+] .\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 14.02s (13.97s|34ms)
[+] .\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 619ms (560ms|42ms)
[+] .\tests\scripts\codex-hooks\subagent-attestation-persistence.Tests.ps1 442ms (348ms|66ms)
[+] .\tests\scripts\codex-hooks\subagent-attestation-command.Tests.ps1 316ms (256ms|44ms)
[+] .\tests\scripts\claude-lib\codex-routing\CodexDeployment.Parity.Tests.ps1 212ms (121ms|68ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexModelReceipts.Tests.ps1 332ms (235ms|75ms)
Tests completed in 87.06s
Tests Passed: 337, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 94.12% / 0%. 374 analyzed Commands in 2 Files.
ACTUAL_TARGET: CodexDeployment.psm1; lines 68/68 (100%).
ACTUAL_TARGET: record-subagent-routing-attestation.ps1; lines 189/204 (92.6471%).
ACTUAL_TARGET: method Invoke-CodexSubagentAttestationCommand; lines 36/40 (90%).
Tests passed=337, failed=0, skipped=0.

Full sanitized output: SCRATCH/issue-977-regression-testing-attestation-source-coverage.log
