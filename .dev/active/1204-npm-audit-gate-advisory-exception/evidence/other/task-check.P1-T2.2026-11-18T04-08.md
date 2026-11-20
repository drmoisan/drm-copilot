# Task check P1-T2

Timestamp: 2026-11-18T04-08
Changed files: tests/scripts/ci/NpmAuditGate.Tests.ps1 (advisory extraction cases added); scripts/ci/NpmAuditGate.psm1 already carries `Get-NpmAuditAdvisories` (written with the module in P1-T1 because the file is one unit; the exported behavior is asserted from this task).
Selection and rule: mirrored test of the changed module, tests/scripts/ci/NpmAuditGate.Tests.ps1.
Command: Invoke-PoshQCFormat then Invoke-PoshQCAnalyze over scripts/ci and tests/scripts/ci (SCRATCH helper); sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/ci/NpmAuditGate.Tests.ps1
EXIT_CODE: 0
Output Summary:
- Format: `FORMAT_FORMATTED_COUNT=0`, 19 already formatted. Analyze: `ANALYZE_FINDING_COUNT=0`.
- Test selection: `Invoke-PoshQCParallelTest: workers=1; exit code=0`; shard log `Tests Passed: 42, Failed: 0`.
- The five required names ran and pass: NAG-ADV-GHSA-FROM-URL, NAG-ADV-SOURCE-FALLBACK (no url, url without a GHSA id, and neither url nor source giving UNIDENTIFIED), NAG-ADV-STRING-VIA-IGNORED, NAG-ADV-DEDUPLICATED (highest severity kept), NAG-ADV-UNPARSEABLE (blank, plain text, npm error object, array root, vulnerabilities not an object).
- Fixture shape (source, name, url, severity on the via object; string via entries for dependents) follows the P0-T3 observation.
