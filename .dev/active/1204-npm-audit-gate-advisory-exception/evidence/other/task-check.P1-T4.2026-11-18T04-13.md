# Task check P1-T4

Timestamp: 2026-11-18T04-13
Changed files: config/npm-audit-exceptions.json (new), tests/scripts/ci/NpmAuditGate.Tests.ps1 (case NAG-EXC-COMMITTED-FILE added).
Selection and rule: the test that reads the changed configuration path (tests/scripts/ci/NpmAuditGate.Tests.ps1). A search of tests/ and config/ for the file name finds no other reader.
Command: Invoke-PoshQCFormat then Invoke-PoshQCAnalyze over scripts/ci and tests/scripts/ci (SCRATCH helper); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/ci/NpmAuditGate.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Format: `FORMAT_FORMATTED_COUNT=0`, 19 already formatted. Analyze: `ANALYZE_FINDING_COUNT=0`.
- Test selection: `Invoke-PoshQCParallelTest: workers=1; exit code=0`; shard log `Tests Passed: 68, Failed: 0`. NAG-EXC-COMMITTED-FILE passes: the committed file is valid, has exactly one entry (GHSA-fc5q-39xc-vjpf, picomatch, expires 2026-12-18), and approved_at sorts before expires.
- `approved_at` is 2026-11-18, read from the UTC clock (`date -u +%Y-%m-%d`) when the file was written; it equals the spec value, so there is no deviation to record.
