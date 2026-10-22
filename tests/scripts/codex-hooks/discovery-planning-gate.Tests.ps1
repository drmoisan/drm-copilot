#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Codex discovery planning gate (issue #980).
.DESCRIPTION
    .codex/hooks/enforce-discovery-planning-gate.ps1 is dot-sourced in-process; the shared modules
    resolve to .claude/lib because this repository publishes .codex/lib only into destinations.
    Every seam is injected from the shared fixtures; entry-point rows redirect stdout and stderr
    and restore them in finally. No file, process, network, Python runtime or clock is touched.
#>

Describe 'Codex enforce-discovery-planning-gate.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-discovery-planning-gate.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryPlanning.TestSupport.ps1')

        function Get-CodexPlanOutcome {
            param(
                [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Json = (Get-PlanEnvelope -HostName 'codex' -ToolName 'spawn_agent'),
                [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Workspace = $null,
                [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null
            )
            if ($null -eq $Workspace) { $Workspace = Get-PlanWorkspace }
            if ($null -eq $Store) { $Store = Get-PlanStore -Workspace $Workspace -ReceiptText (Get-PlanReceiptText -Workspace $Workspace -HostName 'codex') }
            return Invoke-DiscoveryPlanningGateDecision -ToolInputRaw $Json -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes (Get-PlanByteReader -Workspace $Workspace)
        }

        function Invoke-CodexPlanEntryPoint {
            param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$PayloadRaw)
            $originalOut = [System.Console]::Out
            $originalError = [System.Console]::Error
            $outWriter = [System.IO.StringWriter]::new()
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetOut($outWriter)
                [System.Console]::SetError($errorWriter)
                $exitCode = Invoke-DiscoveryPlanningGateEntryPoint -PayloadRaw $PayloadRaw
                return [pscustomobject]@{ ExitCode = $exitCode; Stdout = $outWriter.ToString(); Stderr = $errorWriter.ToString() }
            } finally {
                [System.Console]::SetOut($originalOut)
                [System.Console]::SetError($originalError)
            }
        }
    }

    It 'resolves the helper modules from the published location first and the repository second' {
        ((Get-DiscoveryPlanningHelperModulePath -ModuleName 'DiscoveryPlanning.psm1' -ScriptRoot 'C:/dest/.codex/hooks') -replace '\\', '/') | Should -Be 'C:/dest/.codex/hooks/../lib/discovery-validation/DiscoveryPlanning.psm1'
        Test-Path -LiteralPath (Get-DiscoveryPlanningHelperModulePath -ModuleName 'DiscoveryPlanning.psm1') | Should -BeTrue
    }

    It 'authorizes a Codex planner launch with a current planning receipt bound to the codex host' {
        $outcome = Get-CodexPlanOutcome
        $outcome.Decision | Should -Be 'allow' -Because $outcome.Reason
        $outcome.Code | Should -Be 'PLANNING_AUTHORIZED'
    }

    It 'denies a Codex launch whose planning receipt was issued to the Claude host' {
        $workspace = Get-PlanWorkspace
        (Get-CodexPlanOutcome -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace)).Code | Should -Be 'IDENTITY'
    }

    It 'allows an inactive repository and a non-planning call' {
        $workspace = Get-PlanWorkspace
        (Get-CodexPlanOutcome -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace -NoActivation)).Code | Should -Be 'NOT_ACTIVE'
        (Get-CodexPlanOutcome -Json (Get-GateEnvelope -HostName 'codex' -ToolName 'apply_patch' -ToolInput @{ input = 'p' })).Code | Should -Be 'NOT_PLANNING'
    }

    Context 'entry point' {
        It 'exits 2 with the reason on stderr for an unreadable envelope' {
            $result = Invoke-CodexPlanEntryPoint -PayloadRaw '{'
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -BeLike 'DISCOVERY_PLANNING_GATE_BLOCKED:*'
        }

        It 'allows silently for a non-planning call' {
            $result = Invoke-CodexPlanEntryPoint -PayloadRaw (Get-GateEnvelope -HostName 'codex' -ToolName 'shell' -ToolInput @{ command = @('ls') })
            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'writes the deny decision for a planner launch without a receipt' {
            Mock Get-DiscoveryTrustedHostEnvironment { $script:GateHostEnvironment }
            Mock Get-DiscoveryStartStore { Get-PlanStore -Workspace (Get-PlanWorkspace) -NoReceipt }
            $result = Invoke-CodexPlanEntryPoint -PayloadRaw (Get-PlanEnvelope -HostName 'codex' -ToolName 'spawn_agent')
            $result.ExitCode | Should -Be 0
            $decision = ($result.Stdout | ConvertFrom-Json).hookSpecificOutput
            $decision.permissionDecision | Should -Be 'deny'
            $decision.permissionDecisionReason | Should -BeLike 'DISCOVERY_PLANNING_GATE_BLOCKED:*'
        }
    }
}
