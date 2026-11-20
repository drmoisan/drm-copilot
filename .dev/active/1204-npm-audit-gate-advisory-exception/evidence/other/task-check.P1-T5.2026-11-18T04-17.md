# Task check P1-T5

Timestamp: 2026-11-18T04-17
Changed files: scripts/ci/Invoke-NpmAuditGate.ps1 (new), tests/scripts/ci/Invoke-NpmAuditGate.Tests.ps1 (new).
Selection and rule: mirrored test of the changed script (tests/scripts/ci/Invoke-NpmAuditGate.Tests.ps1) plus the test of the module it imports (tests/scripts/ci/NpmAuditGate.Tests.ps1, rule: every test that imports or names a changed module or file).
Command: Invoke-PoshQCFormat then Invoke-PoshQCAnalyze over scripts/ci and tests/scripts/ci (SCRATCH helper); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/ci/Invoke-NpmAuditGate.Tests.ps1 tests/scripts/ci/NpmAuditGate.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Format: `FORMAT_FORMATTED_COUNT=0`, 21 already formatted. Analyze: `ANALYZE_FINDING_COUNT=0`.
- Test selection: `Invoke-PoshQCParallelTest: workers=2; exit code=0`; shard logs of the selection: 27 passed (entry script) and 68 passed (module), 0 failed.
- The six required names ran and pass: INA-EXIT-0-PASS, INA-EXIT-1-FOR-EACH-CODE (five codes, each printed in the log and exit code 1), INA-NPM-ARGS (production call `audit --omit=dev --audit-level=high` with the level unchanged, full call exactly `audit --json`, no `--omit` on the full call, mock parameter name `NpmArgs`), INA-OUTPUT-WRITER (applied exception fields in Summary and Log), INA-DOT-SOURCE-GUARD (functions defined, explicit exit 0 and exit 1), INA-FAIL-CLOSED-ENVELOPE (a throwing clock seam yields exit 1).
- The tests start no npm process (Invoke-NpmAuditExe is mocked) and read or write no file (Get-Content and Add-Content are mocked); the one environment read is of an unset variable name.
- Not a gate: no coverage measured.
