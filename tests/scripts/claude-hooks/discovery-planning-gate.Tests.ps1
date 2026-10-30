#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Claude Code discovery planning gate (issue #980).
.DESCRIPTION
    .claude/hooks/enforce-discovery-planning-gate.ps1 is dot-sourced in-process; the host roots,
    protected store and workspace bytes are injected from the shared fixtures, so no file,
    process, network, Python runtime or clock is touched. Planning delegations are gated on
    the protected planning receipt; inactive repositories and non-planning calls pass through.
#>

Describe 'enforce-discovery-planning-gate.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.claude/hooks/enforce-discovery-planning-gate.ps1'
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryStart.TestSupport.ps1')
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryPlanning.TestSupport.ps1')

        function Invoke-PlanningGate {
            param(
                [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Json = (Get-PlanEnvelope),
                [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Workspace = $null,
                [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null
            )
            if ($null -eq $Workspace) { $Workspace = Get-PlanWorkspace }
            if ($null -eq $Store) { $Store = Get-PlanStore -Workspace $Workspace }
            return Invoke-DiscoveryPlanningGateDecision -ToolInputRaw $Json -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes (Get-PlanByteReader -Workspace $Workspace)
        }
    }

    It 'denies an unreadable envelope with the gate prefix' {
        $decision = Invoke-PlanningGate -Json '{not-json'
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DISCOVERY_PLANNING_GATE_BLOCKED: payload anomaly*'
    }

    It 'allows <Name> without reading the protected store' -ForEach @(
        @{ Name = 'a non-planning tool call'; Tool = 'Write'; Target = 'atomic-planner' }
        @{ Name = 'an executor delegation'; Tool = 'Agent'; Target = 'atomic-executor' }
    ) {
        $store = Get-PlanStore -Workspace (Get-PlanWorkspace)
        (Invoke-PlanningGate -Json (Get-PlanEnvelope -ToolName $Tool -SubagentType $Target) -Store $store).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $store.Reads.Count | Should -Be 0
    }

    It 'allows a planner delegation in an inactive repository' {
        $workspace = Get-PlanWorkspace
        (Invoke-PlanningGate -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace -NoActivation)).hookSpecificOutput.permissionDecision | Should -Be 'allow'
    }

    It 'allows <Target> with a current planning receipt under <Prerequisite>' -ForEach @(
        @{ Target = 'atomic-planner'; Prerequisite = 'discovery-complete' }
        @{ Target = 'orchestrator'; Prerequisite = 'none' }
    ) {
        $workspace = Get-PlanWorkspace -Prerequisite $Prerequisite
        $decision = Invoke-PlanningGate -Json (Get-PlanEnvelope -SubagentType $Target) -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace)
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because ($decision | ConvertTo-Json -Compress -Depth 4)
    }

    It 'denies <Name> before the delegation runs' -ForEach @(
        @{ Name = 'an active workspace without a planning receipt'; Store = @{ NoReceipt = $true }; Text = '*no planning receipt*' }
        @{ Name = 'a structural receipt'; Store = @{ ReceiptText = 'structural' }; Text = "*mode 'structural'*" }
        @{ Name = 'a failing planning receipt'; Store = @{ ReceiptText = 'fail' }; Text = '*incomplete*' }
        @{ Name = 'a version-1 receipt'; Store = @{ ReceiptText = 'v1' }; Text = '*v1 check*' }
    ) {
        $workspace = Get-PlanWorkspace
        $parameters = @{ Workspace = $workspace }
        if ($Store.ContainsKey('NoReceipt')) { $parameters['NoReceipt'] = $true }
        switch ($Store['ReceiptText']) {
            'structural' { $parameters['ReceiptText'] = Get-PlanReceiptText -Workspace $workspace -Mode 'structural' }
            'fail' { $parameters['ReceiptText'] = Get-PlanReceiptText -Workspace $workspace -ValidationResult 'fail' }
            'v1' { $parameters['ReceiptText'] = Get-PlanReceiptText -Workspace $workspace -Overrides @{ receipt_version = '1.0.0' } }
        }
        $decision = Invoke-PlanningGate -Workspace $workspace -Store (Get-PlanStore @parameters)
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because $Name
        $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "DISCOVERY_PLANNING_GATE_BLOCKED:$Text"
    }

    It 'denies an active workspace whose locator or profile was deleted' {
        $activated = Get-PlanWorkspace
        $store = Get-PlanStore -Workspace $activated
        $current = Get-PlanWorkspace
        $current.Remove('config/discovery.json')
        (Invoke-PlanningGate -Workspace $current -Store $store).hookSpecificOutput.permissionDecisionReason | Should -BeLike '*locator config/discovery.json is absent*'
        $current = Get-PlanWorkspace
        $current.Remove('docs/migration/discovery/domain-profile.yaml')
        (Invoke-PlanningGate -Workspace $current -Store $store).hookSpecificOutput.permissionDecisionReason | Should -BeLike '*profile docs/migration/discovery/domain-profile.yaml is absent*'
    }

    It 'invokes no Python interpreter in its own source' {
        (Get-Content -LiteralPath $script:UnderTest -Raw) | Should -Not -Match 'python -m|python\.exe|poetry run|Invoke-Expression'
    }
}
