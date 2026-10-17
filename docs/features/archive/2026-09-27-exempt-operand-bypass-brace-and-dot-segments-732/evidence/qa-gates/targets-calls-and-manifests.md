# Targets calls and manifests (R-CALLS; issue #738)

Timestamp: 2026-10-09T04-07
Task: [P4-T10]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/p4-t10.sh (R-CALLS on .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1; ConvertFrom-Json on both core.json manifests)
EXIT_CODE: 0

## Output

```text
DEFINED: ConvertTo-OrchestrationTargetPath
DEFINED: Get-OrchestrationPatchMarkerPath
DEFINED: Test-OrchestrationTargetDotSegment
DEFINED: New-OrchestrationTargetResult
DEFINED: Get-OrchestrationGitSelectorTarget
DEFINED: Get-OrchestrationCommandTarget
DEFINED: Resolve-OrchestrationEpicTargetVerdict
DEFINED: Get-OrchestrationEpicTargetDenyReason
EXTERNAL_CALL: Get-CommandLineGlobalOption
EXTERNAL_CALL: Get-CommandLineInvocation
EXTERNAL_CALL: Read-CommandLineSegment
EXTERNAL_CALL: Select-Object
EXTERNAL_CALL: Where-Object
EXTERNAL_CALL: Write-Debug
DYNAMIC_CALL: & $ScopeResolver ''
DYNAMIC_CALL: & $ScopeResolver $target
TOKEN_SPLIT: 0
TOKEN_CONVERT: 0
MANIFEST: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json parsed=True entry=.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 count=1
MANIFEST: extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json parsed=True entry=.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 count=1
DISALLOWED_EXTERNAL_CALLS: 0
DISALLOWED_DYNAMIC_CALLS: 0
```

Output Summary: TOKEN_SPLIT: 0; TOKEN_CONVERT: 0; disallowed external calls 0; disallowed dynamic calls 0; manifest entries present exactly once: True.

