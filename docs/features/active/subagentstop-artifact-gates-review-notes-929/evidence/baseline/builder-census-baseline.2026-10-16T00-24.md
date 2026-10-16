# Envelope Builder Census Baseline (P0-T19)

Timestamp: 2026-10-16T00-24

Command: git grep -c New-SubagentStopEnvelopeJson -- tests
EXIT_CODE: 0
Output:
```
tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1:9
tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1:7
tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1:9
tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1:11
tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1:8
tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:11
tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1:13
```

Command: git grep -l "Builds and returns envelope JSON text only" -- tests
EXIT_CODE: 0
Output:
```
tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1
tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1
tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1
tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1
tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
```

Output Summary: the first command lists exactly the seven E3 suites with counts 8, 11, 13, 11, 9, 7, 9 (prd Tests, prd Coverage, task-researcher Tests, task-researcher Coverage, pr-author Tests, pr-author Coverage, discovery Tests), summing to 68 (7 definitions, 61 call sites). The second command lists the same seven paths. Both exited 0.
