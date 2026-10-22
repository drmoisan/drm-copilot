#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Decision-matrix tests for `.claude/lib/discovery-validation/DiscoveryPlanning.psm1` (issue #980).
.DESCRIPTION
    Proves that a planner or orchestrator launch is gated on current configured discovery
    authority over an in-memory store and workspace: discovery-complete, parity-complete and
    none prerequisites, inactive repositories, active workspaces with a missing, deleted,
    disabled or malformed locator or profile, stale, current and wrong-mode receipts, and
    structural, version-1 and agent-output receipts that must not authorize planning. No
    file, process, network, Python runtime or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    # Leaf modules are imported last so no nested import replaces a visible one.
    Import-Module (Join-Path $lib 'DiscoveryPlanning.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryStartRecord.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthorization.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryPayload.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryManifest.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')
    . (Join-Path $PSScriptRoot 'DiscoveryStart.TestSupport.ps1')
    . (Join-Path $PSScriptRoot 'DiscoveryPlanning.TestSupport.ps1')

    function Get-PlanOutcome {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(Mandatory = $false)][AllowNull()][string]$Json = (Get-PlanEnvelope),
            [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Workspace = $null,
            [Parameter(Mandatory = $false)][AllowNull()][hashtable]$Store = $null
        )
        if ($null -eq $Workspace) { $Workspace = Get-PlanWorkspace }
        if ($null -eq $Store) { $Store = Get-PlanStore -Workspace $Workspace }
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $Json
        return Get-DiscoveryPlanningDecision -Normalized $normalized -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes (Get-PlanByteReader -Workspace $Workspace)
    }
}

Describe 'planning target and prerequisite' {
    It 'recognizes <Tool> launching <Target> as planning: <Expected>' -ForEach @(
        @{ Tool = 'Agent'; Target = 'atomic-planner'; Expected = 'atomic-planner' }
        @{ Tool = 'Task'; Target = 'orchestrator-c3-elevated'; Expected = 'orchestrator-c3-elevated' }
        @{ Tool = 'spawn_agent'; Target = 'orchestrator'; Expected = 'orchestrator' }
        @{ Tool = 'Agent'; Target = 'atomic-executor'; Expected = $null }
        @{ Tool = 'Agent'; Target = 'epic-planner'; Expected = $null }
        @{ Tool = 'Read'; Target = 'atomic-planner'; Expected = $null }
    ) {
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text (Get-PlanEnvelope -ToolName $Tool -SubagentType $Target)
        Get-DiscoveryPlanningTarget -Normalized $normalized | Should -Be $Expected
    }

    It 'reads the <Case> prerequisite from the profile text' -ForEach @(
        @{ Case = 'YAML none'; Text = "schema_version: 2.0.0`ncompletion_gates:`n  planning_prerequisite: none`n"; Expected = 'none' }
        @{ Case = 'YAML parity'; Text = "completion_gates:`n  planning_prerequisite: parity-complete # root choice`n"; Expected = 'parity-complete' }
        @{ Case = 'JSON'; Text = "{`n  `"planning_prerequisite`": `"discovery-complete`",`n}"; Expected = 'discovery-complete' }
        @{ Case = 'absent (default)'; Text = "schema_version: 2.0.0`n"; Expected = 'discovery-complete' }
        @{ Case = 'unknown value (default)'; Text = "planning_prerequisite: sometimes`n"; Expected = 'discovery-complete' }
    ) {
        Get-DiscoveryPlanningPrerequisite -ProfileText $Text | Should -Be $Expected
    }
}

Describe 'planning decision' {
    It 'allows a non-planning call and an ordinary agent launch without reading the store' {
        $store = Get-PlanStore -Workspace (Get-PlanWorkspace)
        (Get-PlanOutcome -Json (Get-GateEnvelope -ToolName 'Read' -ToolInput @{ file_path = 'x' }) -Store $store).Code | Should -Be 'NOT_PLANNING'
        (Get-PlanOutcome -Json (Get-PlanEnvelope -SubagentType 'atomic-executor') -Store $store).Code | Should -Be 'NOT_PLANNING'
        $store.Reads.Count | Should -Be 0
    }

    It 'allows planning in an inactive repository (<Case>) so existing behavior applies' -ForEach @(
        @{ Case = 'no activation'; Store = @{ NoActivation = $true } }
        @{ Case = 'deactivated'; Store = @{ ActivationAction = 'deactivate' } }
    ) {
        $workspace = Get-PlanWorkspace
        $outcome = Get-PlanOutcome -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace @Store)
        $outcome.Decision | Should -Be 'allow'
        $outcome.Code | Should -Be 'NOT_ACTIVE'
    }

    It 'authorizes <Target> with a current planning receipt under the <Prerequisite> prerequisite' -ForEach @(
        @{ Target = 'atomic-planner'; Prerequisite = 'none'; Sources = @(); Targets = @() }
        @{ Target = 'orchestrator'; Prerequisite = 'discovery-complete'; Sources = @([ordered]@{ id = 'legacy-crm'; revision = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' }); Targets = @() }
        @{ Target = 'orchestrator-c3'; Prerequisite = 'parity-complete'; Sources = @([ordered]@{ id = 'legacy-crm'; revision = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' }); Targets = @([ordered]@{ id = 'target-crm'; revision = 'dddddddddddddddddddddddddddddddddddddddd' }) }
    ) {
        $workspace = Get-PlanWorkspace -Prerequisite $Prerequisite
        $store = Get-PlanStore -Workspace $workspace -ReceiptText (Get-PlanReceiptText -Workspace $workspace -SourceRepositories $Sources -TargetRepositories $Targets)
        $outcome = Get-PlanOutcome -Json (Get-PlanEnvelope -SubagentType $Target) -Workspace $workspace -Store $store
        $outcome.Decision | Should -Be 'allow' -Because $outcome.Reason
        $outcome.Code | Should -Be 'PLANNING_AUTHORIZED'
        $outcome.Prerequisite | Should -Be $Prerequisite
        $outcome.Receipt.receipt_ref | Should -Be $script:PlanReceiptRef
    }

    It 'denies <Name> with code <Code>' -ForEach @(
        @{ Name = 'an unreadable envelope'; Code = 'ENVELOPE'; Json = '{' }
        @{ Name = 'a launch without a workspace directory'; Code = 'WORKSPACE'; Cwd = '' }
        @{ Name = 'a planning receipt whose source repositories do not satisfy discovery-complete'; Code = 'PREREQUISITE'; Receipt = @{ SourceRepositories = @() } }
        @{ Name = 'a planning receipt without a target repository under parity-complete'; Code = 'PREREQUISITE'; Prerequisite = 'parity-complete'; Receipt = @{} }
        @{ Name = 'a failing planning receipt'; Code = 'RESULT'; Receipt = @{ ValidationResult = 'fail' } }
        @{ Name = 'a structural receipt'; Code = 'WRONG_MODE'; Receipt = @{ Mode = 'structural' } }
        @{ Name = 'a discovery-complete receipt'; Code = 'WRONG_MODE'; Receipt = @{ Mode = 'discovery-complete' } }
        @{ Name = 'an agent-output receipt'; Code = 'WRONG_MODE'; Receipt = @{ Mode = 'agent-output'; IdentityOverrides = @{ kind = 'discovery-agent'; role = 'legacy-parity-analyst'; invocation_id = 'invocation-alpha' } } }
        @{ Name = 'a version-1 receipt'; Code = 'RECEIPT_VERSION'; Receipt = @{ Overrides = @{ receipt_version = '1.0.0' } } }
        @{ Name = 'a receipt of another kind'; Code = 'RECEIPT_VERSION'; Receipt = @{ Overrides = @{ artifact_kind = 'capability-attestation' } } }
        @{ Name = 'a receipt for another session'; Code = 'IDENTITY'; Receipt = @{ IdentityOverrides = @{ session_id = 'session-beta' } } }
        @{ Name = 'a receipt for another host'; Code = 'IDENTITY'; Receipt = @{ HostName = 'codex' } }
        @{ Name = 'a receipt not written by the gateway'; Code = 'FORGED'; Receipt = @{ WriterOverrides = @{ kind = 'workspace-copy' } } }
        @{ Name = 'a receipt bound to another workspace'; Code = 'BINDING'; Receipt = @{ Overrides = @{ workspace = [ordered]@{ workspace_root = 'C:/Users/Example/Repos/Other'; workspace_sha256 = ('1' * 64); profile_path = 'docs/migration/discovery/domain-profile.yaml'; profile_sha256 = ('2' * 64) } } } }
        @{ Name = 'a receipt issued before the activation changed'; Code = 'STALE_ACTIVATION'; Receipt = @{ Overrides = @{ activation_sha256 = ('3' * 64) } } }
        @{ Name = 'a receipt with an invalid input manifest'; Code = 'RECEIPT_VERSION'; Receipt = @{ Overrides = @{ input_manifest = [ordered]@{ entries = @() } } } }
    ) {
        $prerequisite = $(if (Get-Variable -Name Prerequisite -ErrorAction SilentlyContinue) { $Prerequisite } else { 'discovery-complete' })
        $workspace = Get-PlanWorkspace -Prerequisite $prerequisite
        $receiptText = $(if (Get-Variable -Name Receipt -ErrorAction SilentlyContinue) { Get-PlanReceiptText -Workspace $workspace @Receipt } else { $null })
        $store = Get-PlanStore -Workspace $workspace -ReceiptText $receiptText
        $json = $(if (Get-Variable -Name Json -ErrorAction SilentlyContinue) { $Json } elseif (Get-Variable -Name Cwd -ErrorAction SilentlyContinue) { Get-PlanEnvelope -Cwd $Cwd } else { Get-PlanEnvelope })
        $outcome = Get-PlanOutcome -Json $json -Workspace $workspace -Store $store
        $outcome.Decision | Should -Be 'deny' -Because $Name
        $outcome.Code | Should -Be $Code -Because $outcome.Reason
    }

    It 'denies an active workspace with <Name>' -ForEach @(
        @{ Name = 'a deleted locator'; Code = 'LOCATOR_MISSING'; Mutate = { param($w) $w.Remove('config/discovery.json') } }
        @{ Name = 'a disabled locator'; Code = 'LOCATOR_CHANGED'; Mutate = { param($w) $w['config/discovery.json'] = Get-PlanLocatorByteArray -Enabled $false } }
        @{ Name = 'a deleted profile'; Code = 'PROFILE_MISSING'; Mutate = { param($w) $w.Remove('docs/migration/discovery/domain-profile.yaml') } }
        @{ Name = 'an edited profile'; Code = 'PROFILE_CHANGED'; Mutate = { param($w) $w['docs/migration/discovery/domain-profile.yaml'] = Get-PlanProfileByteArray -Prerequisite 'none' } }
        @{ Name = 'an edited source input'; Code = 'STALE_INPUTS'; Mutate = { param($w) $w['src/Orders/OrderService.cs'] = [System.Text.Encoding]::UTF8.GetBytes('changed') } }
    ) {
        $activated = Get-PlanWorkspace
        $store = Get-PlanStore -Workspace $activated
        $current = Get-PlanWorkspace
        & $Mutate $current
        $outcome = Get-PlanOutcome -Workspace $current -Store $store
        $outcome.Decision | Should -Be 'deny'
        $outcome.Code | Should -Be $Code -Because $outcome.Reason
    }

    It 'denies a malformed locator and a malformed profile that were activated as such' {
        $workspace = Get-PlanWorkspace
        $workspace['config/discovery.json'] = [System.Text.Encoding]::UTF8.GetBytes('{"enabled":true,"profile_path":"docs/other.yaml"}')
        (Get-PlanOutcome -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace)).Code | Should -Be 'LOCATOR_MALFORMED'
        $workspace = Get-PlanWorkspace
        $workspace['docs/migration/discovery/domain-profile.yaml'] = Get-PlanProfileByteArray -NoSchemaVersion
        (Get-PlanOutcome -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace)).Code | Should -Be 'PROFILE_MALFORMED'
        $workspace = Get-PlanWorkspace
        $workspace['docs/migration/discovery/domain-profile.yaml'] = [byte[]]@(0xff, 0xfe, 0x2d)
        (Get-PlanOutcome -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace)).Code | Should -Be 'PROFILE_MALFORMED'
    }

    It 'denies an active workspace whose session holds no receipt and names the prerequisite' {
        $workspace = Get-PlanWorkspace -Prerequisite 'parity-complete'
        $outcome = Get-PlanOutcome -Workspace $workspace -Store (Get-PlanStore -Workspace $workspace -NoReceipt)
        $outcome.Code | Should -Be 'NO_RECEIPT'
        $outcome.Prerequisite | Should -Be 'parity-complete'
        $outcome.Reason | Should -BeLike '*mode planning*'
    }

    It 'prefers the newest planning receipt and ignores an older stale one and unreadable neighbours' {
        $workspace = Get-PlanWorkspace
        $stale = Get-PlanReceiptText -Workspace $workspace -ValidationResult 'fail' -Overrides @{ issued_at = '2026-10-22T10:00:00Z'; receipt_ref = 'receipt-planning-00000000000' }
        $store = Get-PlanStore -Workspace $workspace -ExtraReceipts @{ 'receipt-planning-00000000000' = $stale; 'corrupt' = '{' }
        (Get-PlanOutcome -Workspace $workspace -Store $store).Code | Should -Be 'PLANNING_AUTHORIZED'
        $store = Get-PlanStore -Workspace $workspace -NoReceipt -ExtraReceipts @{ 'receipt-planning-00000000000' = $stale; 'structural' = (Get-PlanReceiptText -Workspace $workspace -Mode 'structural' -Overrides @{ issued_at = '2026-10-22T12:30:00Z' }) }
        (Get-PlanOutcome -Workspace $workspace -Store $store).Code | Should -Be 'RESULT'
    }
}

Describe 'hook output rendering' {
    It 'renders allow and deny with the prefix' {
        (ConvertTo-DiscoveryPlanningHookOutput -Outcome ([pscustomobject]@{ Decision = 'allow'; Code = 'NOT_ACTIVE'; Reason = 'r' }) -ReasonPrefix 'P:').hookSpecificOutput.permissionDecision | Should -Be 'allow'
        $deny = ConvertTo-DiscoveryPlanningHookOutput -Outcome ([pscustomobject]@{ Decision = 'deny'; Code = 'NO_RECEIPT'; Reason = 'no receipt' }) -ReasonPrefix 'P:'
        $deny.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $deny.hookSpecificOutput.permissionDecisionReason | Should -Be 'P: no receipt'
    }
}
