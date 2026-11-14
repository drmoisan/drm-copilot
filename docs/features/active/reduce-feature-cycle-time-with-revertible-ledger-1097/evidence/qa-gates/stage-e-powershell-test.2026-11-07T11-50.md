# Stage E PowerShell Test Gate

Timestamp: 2026-11-07T11-50
Command: sh SCRATCH/issue-1097-pester.sh stagee-final (one Invoke-PoshQCParallelTest run from a launched PowerShell 7 that imports scripts/powershell/PoshQC/PoshQC.psd1); counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
  Invoke-PoshQCParallelTest: ExitCode 0, workers 8, wall-clock 288.9 s, all 8 shards exit 0 (run 2026-11-07T11-45 to 2026-11-07T11-50 UTC)
    junit tests=15653 failures=0 errors=0 disabled=10
    suite planning-contract-wording.Tests.ps1 tests=87 failures=0 errors=0 skipped=0
    suite ProcessReductionLedger.Replay.Tests.ps1 tests=4 failures=0 errors=0 skipped=0
    suite ProcessReductionLedger.Tests.ps1 tests=72 failures=0 errors=0 skipped=0
    suite ProcessReductionLedger.Index.Tests.ps1 tests=14 failures=0 errors=0 skipped=0
    suite validate-planner-output.Tests.ps1 tests=26 failures=0 errors=0 skipped=0
    suite OrchestratorStateCheckpointValue.Tests.ps1 tests=51 failures=0 errors=0 skipped=0
    suite OrchestratorStateRemediationLoop.Parity.Tests.ps1 tests=116 failures=0 errors=0 skipped=0
    case Checkpoint ordinal member accessor.reports an exactly named member as present with its value failed=0
    case Checkpoint ordinal member accessor.reports a member whose name differs only in case as absent failed=0
    case Checkpoint ordinal member accessor.reports a present null member as present with a null value failed=0
    case Checkpoint ordinal member accessor.reports a member as absent when the owner is not an object failed=0
    case Process-reduction ledger replay of the policy-read removal.PRR-ENTRY-FOUND finds one entry with at least one hook block failed=0
    case Process-reduction ledger replay of the policy-read removal.PRR-REVERTED-RETURNS-POLICY-READ-ERROR reports the policy-read error from the reverted hook failed=0
    case Process-reduction ledger replay of the policy-read removal.PRR-LIVE-RETURNS-NO-POLICY-READ-ERROR reports no policy-read error from the live hook failed=0
    case Process-reduction ledger replay of the policy-read removal.PRR-BASELINE-ERROR-SURVIVES-REVERT reports the missing Phase 0 baseline from both hooks failed=0
    case Remediation-loop corpus parity.keeps the case name equal to the file stem for light_path_key_case_variant failed=0
    case Remediation-loop corpus parity.keeps the case name equal to the file stem for light_scope_key_case_variant failed=0
    case Remediation-loop corpus parity.reproduces the expected remediation errors for light_path_key_case_variant failed=0
    case Remediation-loop corpus parity.reproduces the expected remediation errors for light_scope_key_case_variant failed=0
    coverage covered=24050 missed=1532 total=25582 percent=94.01
    file .claude/hooks/validate-planner-output.ps1 covered=209 missed=1 percent=99.52
    file .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 covered=72 missed=0 percent=100
    file .claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1 covered=123 missed=0 percent=100
    file .claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1 covered=146 missed=0 percent=100
    exit=0

Acceptance:
- ExitCode 0 and failed tests 0 (15653 tests; the JUnit root also reports 10 disabled, none in the seven suites named below).
- Suite counts above zero: planning-contract-wording 87, ProcessReductionLedger.Replay 4, ProcessReductionLedger 72, ProcessReductionLedger.Index 14, validate-planner-output 26, OrchestratorStateCheckpointValue 51, OrchestratorStateRemediationLoop.Parity 116.
- The two `*_key_case_variant` parity rows pass, with their stem rows; the four `Checkpoint ordinal member accessor` rows and the four `PRR-` rows pass.
- Line coverage from this run: `.claude/hooks/validate-planner-output.ps1` 99.52% (209 of 210), `OrchestratorStateCheckpointValue.psm1` 100% (72 of 72), `OrchestratorStateReceipts.psm1` 100% (123 of 123), `OrchestratorStateRemediationAccounting.psm1` 100% (146 of 146); each is at least 85%.
- Repo-wide PowerShell line coverage 94.01% (24050 of 25582), at least 85%. Pester measures no branch coverage, so no branch figure applies.
- The bundle copies under `extensions/drm-copilot/resources/claude-customizations/` lie outside the roots of `config/poshqc-coverage.json` and carry no counters; their byte equality with the sources is recorded by the bundle hash checks of [P2-T1] and [P3-T4].
- No figure comes from MCP output.
