#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the GitHub Copilot discovery planning gate (issue #980).
.DESCRIPTION
    .github/hooks/discovery-planning.ps1 is dot-sourced in-process over camelCase envelopes;
    every seam is injected from the shared fixtures, so no file, process, network, Python
    runtime or clock is touched.
#>

Describe 'discovery-planning.ps1 (GitHub Copilot)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.github/hooks/discovery-planning.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryPlanning.TestSupport.ps1')

        function Invoke-CopilotPlanning {
            param(
                [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Json = (Get-PlanEnvelope -HostName 'github-copilot' -ToolName 'runSubagent'),
                [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Workspace = $null,
                [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null
            )
            if ($null -eq $Workspace) { $Workspace = Get-PlanWorkspace }
            if ($null -eq $Store) { $Store = Get-PlanStore -Workspace $Workspace -ReceiptText (Get-PlanReceiptText -Workspace $Workspace -HostName 'github-copilot') }
            return Invoke-DiscoveryPlanningDecision -ToolInputRaw $Json -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes (Get-PlanByteReader -Workspace $Workspace)
        }
    }

    It 'loads every helper module without a recorded failure' {
        $script:DiscoveryPlanningDependencyFailures.Count | Should -Be 0
    }

    It 'allows a Copilot planner launch with a current planning receipt' {
        $decision = Invoke-CopilotPlanning
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because ($decision | ConvertTo-Json -Compress -Depth 4)
    }

    It 'denies a Copilot planner launch whose receipt belongs to another host or is absent' {
        $workspace = Get-PlanWorkspace
        (Invoke-CopilotPlanning -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace)).hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DISCOVERY_PLANNING_GATE_BLOCKED:*native-root principal*'
        (Invoke-CopilotPlanning -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace -NoReceipt)).hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DISCOVERY_PLANNING_GATE_BLOCKED:*no planning receipt*'
    }

    It 'allows an inactive repository and a non-planning camelCase call' {
        $workspace = Get-PlanWorkspace
        (Invoke-CopilotPlanning -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace -NoActivation)).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        (Invoke-CopilotPlanning -Json (Get-GateEnvelope -HostName 'github-copilot' -ToolName 'read_file' -ToolInput @{ path = 'x' })).hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'denies an unreadable envelope with the gate prefix' {
        (Invoke-CopilotPlanning -Json '').hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DISCOVERY_PLANNING_GATE_BLOCKED: payload anomaly*'
    }
}
