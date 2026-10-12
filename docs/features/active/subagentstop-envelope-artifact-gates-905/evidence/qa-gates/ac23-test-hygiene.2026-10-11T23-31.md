# AC-23 test hygiene (plan [P11-T12], issue #905)

Timestamp: 2026-10-11T23-31
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-envref.ps1 <the seven W-SUITES-CHANGED files>; Select-String -Path <the seven paths> -Pattern 'New-TemporaryFile','GetTempFileName','TestDrive' (through <SCRATCHPAD>/e905-scan.ps1)
EXIT_CODE: 0
Output Summary: R-ENVREF lists twelve `$env:CLAUDE_HOOK_INPUT` references, three in each of D6, P3, F3, and T3 (save, assign, restore in `finally`); ENV-REF-VIOLATIONS: 0. The temporary-file scan returns zero matches.

```text
ENV-REF: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1:276 | IT: blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1:278 | IT: blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1:282 | IT: blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1:76 | IT: blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1:78 | IT: blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1:82 | IT: blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1:86 | IT: blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1:88 | IT: blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1:92 | IT: blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:86 | IT: blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:88 | IT: blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:92 | IT: blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF-VIOLATIONS: 0
```

```text
SCAN: Select-String -Path tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1,tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1,tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1,tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1,tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1,tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1,tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 -Pattern 'New-TemporaryFile','GetTempFileName','TestDrive'
MATCH-COUNT: 0
```
