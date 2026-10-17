# AC-23 test hygiene after the Phase 12 loop pass 1 fix (issue #905)

Timestamp: 2026-10-11T23-40
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-envref.ps1 <the seven W-SUITES-CHANGED files>; Select-String -Path <the seven paths> -Pattern 'New-TemporaryFile','GetTempFileName','TestDrive' (through <SCRATCHPAD>/e905-scan.ps1)
EXIT_CODE: 0
Output Summary: re-scan required by the Phase 12 loop preamble after the seven suites were edited (loop pass 1 lint fix: one `SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', ...)` line added to each `New-SubagentStopEnvelopeJson` builder). ENV-REF-VIOLATIONS: 0 (twelve references, all inside D6, P3, F3, T3). The temporary-file scan returns zero matches.

```text
ENV-REF: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1:277 | IT: blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1:279 | IT: blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1:283 | IT: blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1:77 | IT: blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1:79 | IT: blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1:83 | IT: blocks when the PR reference is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1:87 | IT: blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1:89 | IT: blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1:93 | IT: blocks when spec-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:87 | IT: blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:89 | IT: blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF: tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:93 | IT: blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT
ENV-REF-VIOLATIONS: 0
```

```text
SCAN: Select-String -Path tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1,tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1,tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1,tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1,tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1,tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1,tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 -Pattern 'New-TemporaryFile','GetTempFileName','TestDrive'
MATCH-COUNT: 0
```
