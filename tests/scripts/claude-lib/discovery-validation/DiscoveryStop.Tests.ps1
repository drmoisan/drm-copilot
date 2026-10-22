#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Decision-matrix tests for `.claude/lib/discovery-validation/DiscoveryStop.psm1` (issue #980).
.DESCRIPTION
    Proves that a discovery specialist's stop result is derived from its protected invocation
    and gateway receipt over an in-memory store and workspace: all four roles and generated
    variants, missing or blank final text, absent required path, id or kind, stale input,
    profile and evidence, wrong session, role or gate, forged workspace success, an
    output-valid failing reviewer report, valid incremental results and the unchanged
    ordinary stop. No file, process, network or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    # Leaf modules are imported last so no nested import replaces a visible one.
    Import-Module (Join-Path $lib 'DiscoveryStop.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryStartRecord.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryPayload.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryManifest.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')
    . (Join-Path $PSScriptRoot 'DiscoveryStart.TestSupport.ps1')
    . (Join-Path $PSScriptRoot 'DiscoveryStop.TestSupport.ps1')

    function Get-StopOutcome {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(Mandatory = $false)][AllowNull()][string]$Json = (Get-StopEnvelope),
            [Parameter(Mandatory = $false)][hashtable]$Environment = (Get-StartEnvironment),
            [Parameter(Mandatory = $false)][hashtable]$Store = (Get-StopStore),
            [Parameter(Mandatory = $false)][hashtable]$Workspace = (Get-StopWorkspace),
            [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$Text = 'Inventory recorded. Result: PASS',
            [Parameter(Mandatory = $false)][bool]$StopHookActive = $false
        )
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $Json
        return Get-DiscoveryStopDecision -Normalized $normalized -Environment $Environment -HostEnvironment $script:GateHostEnvironment `
            -AssistantText $Text -StopHookActive $StopHookActive -Store $Store -ReadBytes (Get-StopByteReader -Workspace $Workspace)
    }
}

Describe 'stop decision for every role' {
    It 'validates a finalized <Role> stop (<AgentType>) from its protected receipt' -ForEach @(
        @{ Role = 'legacy-parity-analyst'; AgentType = 'legacy-parity-analyst-c3' }
        @{ Role = 'runtime-characterization-analyst'; AgentType = 'runtime-characterization-analyst-c2' }
        @{ Role = 'requirements-reconciler'; AgentType = 'requirements-reconciler-c3-elevated' }
        @{ Role = 'migration-coverage-reviewer'; AgentType = 'migration-coverage-reviewer-c1' }
    ) {
        $store = Get-StopStore -Role $Role
        $outcome = Get-StopOutcome -Json (Get-StopEnvelope -AgentType $AgentType) -Store $store
        $outcome.Decision | Should -Be 'allow' -Because $outcome.Reason
        $outcome.Code | Should -Be 'VALIDATED'
        $outcome.Receipt.identity.role | Should -Be $Role
        $outcome.Invocation.invocation_id | Should -Be 'invocation-alpha'
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
        $store.Writes.Count | Should -Be 0
    }

    It 'skips <AgentType> so the ordinary stop validation applies unchanged' -ForEach @(
        @{ AgentType = 'atomic-executor' }; @{ AgentType = 'epic-planner' }; @{ AgentType = 'general-purpose' }
    ) {
        $store = Get-StopStore
        $outcome = Get-StopOutcome -Json (Get-StopEnvelope -AgentType $AgentType -Text 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.') -Store $store
        $outcome.Decision | Should -Be 'skip'
        $outcome.Code | Should -Be 'NOT_DISCOVERY_AGENT'
        $store.Reads.Count | Should -Be 0
    }

    It 'allows an output-valid failing reviewer report and blocks a failing analyst result' {
        (Get-StopOutcome -Json (Get-StopEnvelope -AgentType 'migration-coverage-reviewer-c1' -Text 'Coverage review complete. Result: FAIL') -Store (Get-StopStore -Role 'migration-coverage-reviewer' -ValidationResult 'fail') -Text 'Coverage review complete. Result: FAIL').Code | Should -Be 'VALIDATED'
        (Get-StopOutcome -Store (Get-StopStore -ValidationResult 'fail') -Text 'Result: FAIL').Code | Should -Be 'RESULT'
    }

    It 'allows a valid incremental result whose receipt names more outputs than the baseline' {
        $workspace = Get-StopWorkspace
        $workspace['docs/migration/discovery/feature-contract.json'] = [System.Text.Encoding]::UTF8.GetBytes('{"contract":1}')
        $outputs = @(
            [ordered]@{ artifact_kind = 'coverage-ledger'; id = 'ledger-alpha'; path = $script:StopOutputPath; format = 'json'; expected_sha256 = $null }
            [ordered]@{ artifact_kind = 'feature-contract'; id = 'contract-alpha'; path = 'docs/migration/discovery/feature-contract.json'; format = 'json'; expected_sha256 = ('e' * 64) }
        )
        $manifest = Get-StopRequiredOutputManifest -Outputs $outputs
        $store = Get-StopStore -InvocationOverrides @{ required_outputs = $manifest } -ReceiptOverrides @{ required_outputs = $manifest } -Workspace $workspace
        (Get-StopOutcome -Store $store -Workspace $workspace).Code | Should -Be 'VALIDATED'
    }
}

Describe 'stop decision refusals' {
    It 'blocks <Name> with code <Code>' -ForEach @(
        @{ Name = 'an unreadable envelope'; Code = 'ENVELOPE'; Json = '{'; Store = @{}; Environment = @{} }
        @{ Name = 'a stop without an agent identifier'; Code = 'IDENTITY'; AgentId = ''; Store = @{}; Environment = @{} }
        @{ Name = 'a nested specialist'; Code = 'NESTED'; Store = @{}; Environment = @{ Nested = $true } }
        @{ Name = 'a stop without a trusted parent'; Code = 'IDENTITY'; Store = @{}; Environment = @{ NoParent = $true } }
        @{ Name = 'a stop from another session'; Code = 'IDENTITY'; SessionId = 'session-beta'; Store = @{}; Environment = @{} }
        @{ Name = 'a stop without a workspace directory'; Code = 'WORKSPACE'; Cwd = ''; Store = @{}; Environment = @{} }
        @{ Name = 'a deactivated workspace'; Code = 'ACTIVATION'; Store = @{ ActivationAction = 'deactivate' }; Environment = @{} }
        @{ Name = 'a specialist without a protected invocation'; Code = 'NO_INVOCATION'; Store = @{ NoInvocation = $true }; Environment = @{} }
        @{ Name = 'an invocation bound to another agent'; Code = 'NO_INVOCATION'; Store = @{ InvocationOverrides = @{ agent_id = 'agent-beta' } }; Environment = @{} }
        @{ Name = 'a specialist that never finalized'; Code = 'NOT_FINALIZED'; Store = @{ State = 'started' }; Environment = @{} }
        @{ Name = 'a role that differs from the agent type'; Code = 'ROLE'; Store = @{ InvocationOverrides = @{ role = 'requirements-reconciler' } }; Environment = @{} }
        @{ Name = 'a missing completion receipt'; Code = 'RECEIPT'; Store = @{ NoReceipt = $true }; Environment = @{} }
        @{ Name = 'a receipt of another kind'; Code = 'RECEIPT'; Store = @{ ReceiptOverrides = @{ artifact_kind = 'capability-attestation' } }; Environment = @{} }
        @{ Name = 'a receipt for a root gate mode'; Code = 'GATE'; Store = @{ ReceiptOverrides = @{ mode = 'discovery-complete' } }; Environment = @{} }
        @{ Name = 'a receipt for another session'; Code = 'IDENTITY'; Store = @{ IdentityOverrides = @{ session_id = 'session-beta' } }; Environment = @{} }
        @{ Name = 'a receipt for another role'; Code = 'IDENTITY'; Store = @{ IdentityOverrides = @{ role = 'requirements-reconciler' } }; Environment = @{} }
        @{ Name = 'a receipt for the root principal'; Code = 'IDENTITY'; Store = @{ IdentityOverrides = @{ kind = 'native-root' } }; Environment = @{} }
        @{ Name = 'a receipt not written by the gateway'; Code = 'FORGED'; Store = @{ WriterOverrides = @{ kind = 'workspace-copy' } }; Environment = @{} }
        @{ Name = 'a receipt bound to another workspace'; Code = 'BINDING'; Store = @{ ReceiptOverrides = @{ workspace = [ordered]@{ workspace_root = 'C:/Users/Example/Repos/Other'; workspace_sha256 = ('1' * 64); profile_path = 'docs/migration/discovery/domain-profile.yaml'; profile_sha256 = ('2' * 64) } } }; Environment = @{} }
        @{ Name = 'a receipt issued before the activation changed'; Code = 'STALE_ACTIVATION'; Store = @{ ReceiptOverrides = @{ activation_sha256 = ('3' * 64) } }; Environment = @{} }
        @{ Name = 'a receipt with another build pin'; Code = 'RUNTIME'; Store = @{ ReceiptOverrides = @{ runtime = [ordered]@{ package_version = '2.0.0'; schema_version = '2.0.0'; build_sha256 = ('4' * 64); policy_version = '2.0.0'; policy_sha256 = ('c' * 64) } } }; Environment = @{} }
        @{ Name = 'a receipt without the required-output manifest'; Code = 'OUTPUTS'; Store = @{ ReceiptOverrides = @{ required_outputs = [ordered]@{ manifest_sha256 = ('5' * 64); outputs = @() } } }; Environment = @{} }
        @{ Name = 'a receipt whose outputs are not valid'; Code = 'OUTPUT_INVALID'; Store = @{ ReceiptOverrides = @{ output_valid = $false } }; Environment = @{} }
        @{ Name = 'a receipt with an invalid input manifest'; Code = 'RECEIPT'; Store = @{ ReceiptOverrides = @{ input_manifest = [ordered]@{ entries = @() } } }; Environment = @{} }
    ) {
        $envelopeParameters = @{}
        foreach ($name in @('AgentId', 'SessionId', 'Cwd')) {
            $variable = Get-Variable -Name $name -ErrorAction SilentlyContinue
            if ($null -ne $variable) { $envelopeParameters[$name] = $variable.Value }
        }
        $json = $(if (Get-Variable -Name Json -ErrorAction SilentlyContinue) { $Json } else { Get-StopEnvelope @envelopeParameters })
        $store = Get-StopStore @Store
        $outcome = Get-StopOutcome -Json $json -Environment (Get-StartEnvironment @Environment) -Store $store
        $outcome.Decision | Should -Be 'block' -Because $Name
        $outcome.Code | Should -Be $Code -Because $outcome.Reason
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
    }

    It 'blocks <Name> as stale or missing workspace state' -ForEach @(
        @{ Name = 'an edited input'; Code = 'STALE_INPUTS'; Mutate = { param($w) $w['src/Orders/OrderService.cs'] = [System.Text.Encoding]::UTF8.GetBytes('class OrderService { changed }') } }
        @{ Name = 'a deleted input'; Code = 'STALE_INPUTS'; Mutate = { param($w) $w.Remove('src/Orders/OrderService.cs') } }
        @{ Name = 'a replaced domain profile'; Code = 'STALE_INPUTS'; Mutate = { param($w) $w['docs/migration/discovery/domain-profile.yaml'] = [System.Text.Encoding]::UTF8.GetBytes("schema_version: 2.0.0`nextra: 1`n") } }
        @{ Name = 'an absent required output'; Code = 'OUTPUT_MISSING'; Mutate = { param($w) $w.Remove('docs/migration/discovery/coverage-ledger.json') } }
    ) {
        $workspace = Get-StopWorkspace
        & $Mutate $workspace
        $outcome = Get-StopOutcome -Store (Get-StopStore) -Workspace $workspace
        $outcome.Code | Should -Be $Code -Because $outcome.Reason
    }

    It 'blocks replaced evidence as stale input' {
        $workspace = Get-StopWorkspace
        $workspace['evidence/run-001.json'] = [System.Text.Encoding]::UTF8.GetBytes('{"run":1}')
        $manifest = Get-StopInputManifest -Workspace $workspace
        $manifest['entries'] = @($manifest['entries'] + @([ordered]@{ category = 'evidence'; path = 'evidence/run-001.json'; sha256 = (Get-DiscoveryBytesSha256Hex -Bytes $workspace['evidence/run-001.json']); size = $workspace['evidence/run-001.json'].Length }))
        $manifest['sha256'] = Get-DiscoveryInputManifestDigest -Manifest $manifest
        $store = Get-StopStore -ReceiptOverrides @{ input_manifest = $manifest } -Workspace $workspace
        (Get-StopOutcome -Store $store -Workspace $workspace).Code | Should -Be 'VALIDATED'
        $workspace['evidence/run-001.json'] = [System.Text.Encoding]::UTF8.GetBytes('{"run":2}')
        $outcome = Get-StopOutcome -Store $store -Workspace $workspace
        $outcome.Code | Should -Be 'STALE_INPUTS'
        $outcome.Reason | Should -BeLike '*evidence-replaced:evidence/run-001.json*'
    }

    It 'blocks a required output row without its kind, id or path' {
        $manifest = Get-StopRequiredOutputManifest -Outputs @([ordered]@{ artifact_kind = 'coverage-ledger'; id = ''; path = $script:StopOutputPath; format = 'json'; expected_sha256 = $null })
        $store = Get-StopStore -InvocationOverrides @{ required_outputs = $manifest } -ReceiptOverrides @{ required_outputs = $manifest }
        (Get-StopOutcome -Store $store).Code | Should -Be 'OUTPUTS'
    }

    It 'never lets final text grant authority: <Name>' -ForEach @(
        @{ Name = 'success prose and filenames without a receipt'; Text = 'Wrote docs/migration/discovery/coverage-ledger.json successfully. Result: PASS'; Store = @{ NoReceipt = $true }; Code = 'RECEIPT' }
        @{ Name = 'blank text with a valid receipt'; Text = ''; Store = @{}; Code = 'RESULT_TEXT' }
        @{ Name = 'text claiming PASS over a failing reviewer receipt'; Text = 'Result: PASS'; Store = @{ Role = 'migration-coverage-reviewer'; ValidationResult = 'fail' }; Code = 'RESULT_TEXT' }
        @{ Name = 'text without an explicit result'; Text = 'Done, everything passed fine.'; Store = @{}; Code = 'RESULT_TEXT' }
    ) {
        $agentType = $(if ($Store.ContainsKey('Role')) { $script:StopRoleAgentTypes[$Store['Role']] } else { 'legacy-parity-analyst-c3' })
        $outcome = Get-StopOutcome -Json (Get-StopEnvelope -AgentType $agentType -Text $Text) -Store (Get-StopStore @Store) -Text $Text
        $outcome.Decision | Should -Be 'block'
        $outcome.Code | Should -Be $Code -Because $outcome.Reason
    }

    It 'turns a block into a CONTINUED allow once a continuation was already requested, but never for an unreadable envelope' {
        $continued = Get-StopOutcome -Store (Get-StopStore -NoReceipt) -StopHookActive $true
        $continued.Decision | Should -Be 'allow'
        $continued.Code | Should -Be 'CONTINUED'
        $continued.Reason | Should -BeLike '*continuation was already requested*'
        (Get-StopOutcome -Json '{' -StopHookActive $true).Code | Should -Be 'ENVELOPE'
    }

    It 'binds exactly one invocation and reports two as ambiguous' {
        $found = Find-DiscoveryAgentInvocationForStop -Location $script:GateLocation -Principal (Get-DiscoveryTrustedPrincipal -Normalized (ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text (Get-StopEnvelope)) -Environment (Get-StartEnvironment)) -AgentType 'legacy-parity-analyst-c3' -AgentId 'agent-alpha' -Store (Get-StopStore)
        $found.Count | Should -Be 1
        $found.Directory | Should -Be $script:GateInvocationDirectory
        (Get-StopOutcome -Store (Get-StopStore -SecondInvocation)).Code | Should -Be 'AMBIGUOUS'
    }
}
