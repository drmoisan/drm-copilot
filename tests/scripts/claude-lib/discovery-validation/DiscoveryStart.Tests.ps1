#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Decision-matrix tests for `.claude/lib/discovery-validation/DiscoveryStart.psm1` and
    `DiscoveryStartRecord.psm1` (issue #980).
.DESCRIPTION
    Proves the discovery agent grammar, the per-host agent-profile readers, the started
    transition of a protected invocation record, prepared-invocation binding and the full
    SubagentStart decision over an in-memory protected store: receipt kind, payload
    parent/session, exact role/model/effort/profile hash, schema/runtime/build and
    capability pins, missing or wrong receipts, mirror tampering, and the unchanged
    ordinary and epic starts. The start is observational: a binding that cannot
    complete is observed with its code and never claims to block the host. No file,
    process, network or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    # Leaf modules are imported last so no nested import replaces a visible one.
    Import-Module (Join-Path $lib 'DiscoveryStart.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryStartRecord.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryPayload.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')
    . (Join-Path $PSScriptRoot 'DiscoveryStart.TestSupport.ps1')

    function Get-StartOutcome {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(Mandatory = $false)][AllowNull()][string]$Json = (Get-StartEnvelope),
            [Parameter(Mandatory = $false)][hashtable]$Store = (Get-StartStore),
            [Parameter(Mandatory = $false)][AllowNull()][pscustomobject]$AgentProfile = (Get-StartProfile),
            [Parameter(Mandatory = $false)][AllowNull()][string]$ActualModel = 'gpt-6.1-sol',
            [Parameter(Mandatory = $false)][AllowNull()][string]$ActualReasoningEffort = 'high',
            [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
        )
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text $Json
        $parameters = @{
            Normalized = $normalized; HostEnvironment = $script:GateHostEnvironment; HandlerSha256 = ('9' * 64)
            Store = $Store; Now = $script:GateNow; Nonce = $script:GateNonce; ActualModel = $ActualModel; ActualReasoningEffort = $ActualReasoningEffort
        }
        if ($null -ne $AgentProfile) { $parameters['AgentProfile'] = $AgentProfile }
        if ($null -ne $ReadBytes) { $parameters['ReadBytes'] = $ReadBytes }
        return Get-DiscoveryStartDecision @parameters
    }
}

Describe 'discovery agent grammar and profile locations' {
    It 'maps <AgentType> to role <Role>' -ForEach @(
        @{ AgentType = 'legacy-parity-analyst'; Role = 'legacy-parity-analyst' }
        @{ AgentType = 'legacy-parity-analyst-c3-elevated'; Role = 'legacy-parity-analyst' }
        @{ AgentType = 'runtime-characterization-analyst-c1'; Role = 'runtime-characterization-analyst' }
        @{ AgentType = 'requirements-reconciler-c4'; Role = 'requirements-reconciler' }
        @{ AgentType = 'migration-coverage-reviewer-c2'; Role = 'migration-coverage-reviewer' }
        @{ AgentType = 'Legacy-Parity-Analyst'; Role = $null }
        @{ AgentType = 'legacy-parity-analyst-c5'; Role = $null }
        @{ AgentType = 'atomic-executor-c3'; Role = $null }
        @{ AgentType = 'epic-planner'; Role = $null }
        @{ AgentType = ''; Role = $null }
    ) {
        Get-DiscoveryAgentRole -AgentType $AgentType | Should -Be $Role
    }

    It 'locates the <HostName> profile of a specialist' -ForEach @(
        @{ HostName = 'claude-code'; Path = '.claude/agents/legacy-parity-analyst.md' }
        @{ HostName = 'codex'; Path = '.codex/agents/legacy-parity-analyst.toml' }
        @{ HostName = 'github-copilot'; Path = '.github/agents/legacy-parity-analyst.agent.md' }
    ) {
        Get-DiscoveryAgentProfilePath -HostName $HostName -AgentType 'legacy-parity-analyst' | Should -Be $Path
    }

    It 'rejects a traversal agent name before any path is formed' {
        { Get-DiscoveryAgentProfilePath -HostName 'claude-code' -AgentType '../orchestrator' } | Should -Throw '*not a valid agent profile name*'
    }
}

Describe 'Markdown agent profile reader' {
    It 'reads name, model and effort from the front matter and strips quotes' {
        $text = "---`nname: `"legacy-parity-analyst`"`nmodel: 'opus'`neffort: high # comment`ntools:`n  - x`n---`n# body`nname: other`n"
        $reading = ConvertFrom-DiscoveryMarkdownProfile -Text $text -RelativePath 'p.md' -Sha256 ('a' * 64)
        $reading.ProfileName | Should -Be 'legacy-parity-analyst'
        $reading.ProfileModel | Should -Be 'opus'
        $reading.ProfileReasoningEffort | Should -Be 'high'
        $reading.ProfilePath | Should -Be 'p.md'
        $reading.ProfileSha256 | Should -Be ('a' * 64)
    }

    It 'leaves model and effort null when the host profile declares none' {
        $reading = ConvertFrom-DiscoveryMarkdownProfile -Text (Get-StartProfileMarkdown) -RelativePath 'p.md' -Sha256 ('a' * 64)
        $reading.ProfileName | Should -Be 'legacy-parity-analyst-c3'
        $reading.ProfileModel | Should -BeNullOrEmpty
        $reading.ProfileReasoningEffort | Should -BeNullOrEmpty
    }

    It 'rejects <Case>' -ForEach @(
        @{ Case = 'a profile without front matter'; Text = "# title`nname: x`n"; Message = '*no YAML front matter*' }
        @{ Case = 'an unterminated front-matter block'; Text = "---`nname: x`n"; Message = '*unterminated*' }
        @{ Case = 'a front matter without a name'; Text = "---`ndescription: x`n---`n"; Message = '*declares no name*' }
    ) {
        { ConvertFrom-DiscoveryMarkdownProfile -Text $Text -RelativePath 'p.md' -Sha256 ('a' * 64) } | Should -Throw $Message
    }

    It 'hashes the profile bytes it reads through the seam' {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes((Get-StartProfileMarkdown))
        $reading = Read-DiscoveryAgentProfile -HostName 'claude-code' -AgentType 'legacy-parity-analyst-c3' -WorkspaceRoot $script:GateWorkspaceRoot -ReadBytes (Get-StartProfileReader)
        $reading.ProfileSha256 | Should -Be (Get-DiscoveryBytesSha256Hex -Bytes $bytes)
        $reading.ProfilePath | Should -Be '.claude/agents/legacy-parity-analyst-c3.md'
    }

    It 'rejects a missing profile and invalid UTF-8 bytes' {
        { Read-DiscoveryAgentProfile -HostName 'github-copilot' -AgentType 'legacy-parity-analyst-c3' -WorkspaceRoot $script:GateWorkspaceRoot -ReadBytes (Get-StartProfileReader) } | Should -Throw '*does not exist*'
        { Read-DiscoveryAgentProfile -HostName 'claude-code' -AgentType 'legacy-parity-analyst-c3' -WorkspaceRoot $script:GateWorkspaceRoot -ReadBytes { [byte[]]@(0xff, 0xfe, 0x2d) } } | Should -Throw '*not valid UTF-8*'
    }
}

Describe 'record primitives' {
    It 'coerces <Case> to a UTC instant' -ForEach @(
        @{ Case = 'an ISO string'; Value = '2026-10-22T13:00:00Z'; Expected = [datetime]::new(2026, 10, 22, 13, 0, 0, [System.DateTimeKind]::Utc) }
        @{ Case = 'an offset string'; Value = '2026-10-22T15:00:00+02:00'; Expected = [datetime]::new(2026, 10, 22, 13, 0, 0, [System.DateTimeKind]::Utc) }
        @{ Case = 'a decoded DateTime'; Value = [datetime]::new(2026, 10, 22, 13, 0, 0, [System.DateTimeKind]::Utc); Expected = [datetime]::new(2026, 10, 22, 13, 0, 0, [System.DateTimeKind]::Utc) }
        @{ Case = 'garbage'; Value = 'later'; Expected = $null }
    ) {
        Get-DiscoveryStartAttestationFileName | Should -Be 'start-attestation.json'
        $actual = ConvertTo-DiscoveryUtcInstant -Value $Value
        if ($null -eq $Expected) { $actual | Should -BeNullOrEmpty } else { $actual | Should -Be $Expected; $actual.Kind | Should -Be ([System.DateTimeKind]::Utc) }
    }

    It 'moves a prepared record to started and keeps every other value verbatim' {
        $text = Get-StartInvocationText
        $started = ConvertTo-DiscoveryStartedInvocationText -Text $text -AgentId 'agent-alpha' -StartAttestationRef 'start-0123456789abcdef0123'
        $started | Should -Match '"created_at": "2026-10-22T11:00:00Z"'
        $started | Should -Match '"state": "started"'
        $record = $started | ConvertFrom-Json
        $record.agent_id | Should -Be 'agent-alpha'
        $record.start_attestation_ref | Should -Be 'start-0123456789abcdef0123'
        $record.completion_receipt_ref | Should -BeNullOrEmpty
        @($record.PSObject.Properties.Name | Sort-Object) | Should -Be @(($text | ConvertFrom-Json).PSObject.Properties.Name | Sort-Object)
        { ConvertTo-DiscoveryStartedInvocationText -Text '[1]' -AgentId 'a' -StartAttestationRef 's' } | Should -Throw '*not a JSON object*'
    }

    It 'returns a 20-character lowercase hex nonce' {
        Get-DiscoveryAuthorizationNonceText | Should -Match '^[0-9a-f]{20}$'
    }
}

Describe 'prepared invocation binding' {
    BeforeAll {
        $script:Principal = Get-DiscoveryTrustedPrincipal -Normalized (ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text (Get-StartEnvelope))
    }

    It 'finds exactly the prepared record bound to this host, session, parent and agent type' {
        $found = Find-DiscoveryPreparedInvocation -Location $script:GateLocation -Principal $script:Principal -AgentType 'legacy-parity-analyst-c3' -Store (Get-StartStore)
        $found.Count | Should -Be 1
        $found.Record.invocation_id | Should -Be 'invocation-alpha'
        $found.Directory | Should -Be $script:GateInvocationDirectory
    }

    It 'ignores <Case>' -ForEach @(
        @{ Case = 'a started record'; Overrides = @{ state = 'started' } }
        @{ Case = 'another parent'; Overrides = @{ parent_agent_id = 'root-beta' } }
        @{ Case = 'another host'; Overrides = @{ host = 'codex' } }
        @{ Case = 'another artifact kind'; Overrides = @{ artifact_kind = 'validation-receipt' } }
        @{ Case = 'another agent type'; Overrides = @{ deployment = [ordered]@{ agent_name = 'legacy-parity-analyst-c1' } } }
    ) {
        (Find-DiscoveryPreparedInvocation -Location $script:GateLocation -Principal $script:Principal -AgentType 'legacy-parity-analyst-c3' -Store (Get-StartStore -InvocationOverrides $Overrides)).Count | Should -Be 0
    }

    It 'skips an unreadable neighbour and reports two matches as ambiguous' {
        $store = Get-StartStore -SecondInvocation
        $store.Files["$($script:StartSessionDirectory)/invocations/zz-corrupt/invocation.json"] = '{'
        (Find-DiscoveryPreparedInvocation -Location $script:GateLocation -Principal $script:Principal -AgentType 'legacy-parity-analyst-c3' -Store $store).Count | Should -Be 2
    }
}

Describe 'start decision' {
    It 'skips <AgentType> so the ordinary or epic start attestation applies unchanged' -ForEach @(
        @{ AgentType = 'atomic-executor-c3' }; @{ AgentType = 'epic-planner' }; @{ AgentType = 'orchestrator' }
    ) {
        $store = Get-StartStore
        $outcome = Get-StartOutcome -Json (Get-StartEnvelope -AgentType $AgentType) -Store $store -AgentProfile $null
        $outcome.Decision | Should -Be 'skip'
        $outcome.Code | Should -Be 'NOT_DISCOVERY_AGENT'
        $store.Reads.Count | Should -Be 0
        $store.Writes.Count | Should -Be 0
    }

    It 'observes <Name> with code <Code> and writes nothing' -ForEach @(
        @{ Name = 'an unreadable envelope'; Code = 'ENVELOPE'; Json = '{'; Store = $null }
        @{ Name = 'a start without an agent identifier'; Code = 'IDENTITY'; Json = $null; AgentId = ''; Store = $null }
        @{ Name = 'a start without a workspace directory'; Code = 'WORKSPACE'; Json = $null; Cwd = ''; Store = $null }
        @{ Name = 'a missing activation'; Code = 'ACTIVATION'; Json = $null; Store = @{ NoActivation = $true } }
        @{ Name = 'a deactivated workspace'; Code = 'ACTIVATION'; Json = $null; Store = @{ ActivationAction = 'deactivate' } }
        @{ Name = 'a missing prepared invocation'; Code = 'NO_INVOCATION'; Json = $null; Store = @{ NoInvocation = $true } }
        @{ Name = 'an invocation prepared for another parent'; Code = 'NO_INVOCATION'; Json = $null; Store = @{ InvocationOverrides = @{ parent_agent_id = 'root-beta' } } }
        @{ Name = 'an invocation prepared for another session'; Code = 'NO_INVOCATION'; Json = $null; Store = @{ InvocationOverrides = @{ session_id = 'session-beta' } } }
        @{ Name = 'an envelope from another host'; Code = 'NO_INVOCATION'; Json = $null; Store = @{ HostName = 'codex' } }
        @{ Name = 'a receipt of another kind'; Code = 'NO_INVOCATION'; Json = $null; Store = @{ InvocationOverrides = @{ artifact_kind = 'validation-receipt' } } }
        @{ Name = 'two prepared invocations'; Code = 'AMBIGUOUS'; Json = $null; Store = @{ SecondInvocation = $true } }
        @{ Name = 'a record with production writes'; Code = 'RECEIPT'; Json = $null; Store = @{ InvocationOverrides = @{ production_write_count = 1 } } }
        @{ Name = 'a record of another schema version'; Code = 'RECEIPT'; Json = $null; Store = @{ InvocationOverrides = @{ schema_version = '1.0.0' } } }
        @{ Name = 'a role that differs from the agent type'; Code = 'ROLE'; Json = $null; Store = @{ InvocationOverrides = @{ role = 'requirements-reconciler' } } }
        @{ Name = 'an actual model that differs from the deployment'; Code = 'MODEL'; Json = $null; ActualModel = 'gpt-6-astra'; Store = $null }
        @{ Name = 'a profile effort that differs from the deployment'; Code = 'EFFORT'; Json = $null; ActualReasoningEffort = 'medium'; Store = $null }
        @{ Name = 'an agent profile naming another agent'; Code = 'PROFILE'; Json = $null; ProfileOverrides = @{ ProfileName = 'legacy-parity-analyst-c1' }; Store = $null }
        @{ Name = 'an agent profile without a hash'; Code = 'PROFILE'; Json = $null; ProfileOverrides = @{ ProfileSha256 = 'none' }; Store = $null }
        @{ Name = 'a domain profile hash from another activation'; Code = 'BINDING'; Json = $null; Store = @{ InvocationOverrides = @{ workspace = [ordered]@{ workspace_root = 'C:/Users/Example/Repos/Workspace'; workspace_sha256 = '77f077989d4b47c3249dcb4b1f5d5c59fa91f1045e244879660ef1ef212a19b6'; profile_path = 'docs/migration/discovery/domain-profile.yaml'; profile_sha256 = ('0' * 64) } } } }
        @{ Name = 'a schema version outside the activation'; Code = 'BINDING'; Json = $null; Store = @{ InvocationOverrides = @{ runtime = [ordered]@{ package_version = '2.0.0'; schema_version = '3.0.0'; build_sha256 = ('b' * 64); policy_version = '2.0.0'; policy_sha256 = ('c' * 64) } } } }
        @{ Name = 'a missing capability attestation'; Code = 'CAPABILITY'; Json = $null; Store = @{ NoCapability = $true } }
        @{ Name = 'a capability attestation for another reference'; Code = 'CAPABILITY'; Json = $null; Store = @{ CapabilityOverrides = @{ attestation_ref = 'capability-beta' } } }
        @{ Name = 'an unsupported capability attestation'; Code = 'CAPABILITY'; Json = $null; Store = @{ CapabilityOverrides = @{ status = 'unsupported' } } }
        @{ Name = 'an expired capability attestation'; Code = 'CAPABILITY'; Json = $null; Store = @{ CapabilityOverrides = @{ expires_at = '2026-10-22T11:59:59Z' } } }
        @{ Name = 'a capability attestation of another session'; Code = 'CAPABILITY'; Json = $null; Store = @{ CapabilityOverrides = @{ session_id = 'session-beta' } } }
        @{ Name = 'a build pin that differs from the capability'; Code = 'RUNTIME'; Json = $null; Store = @{ RuntimeOverrides = @{ build_sha256 = ('1' * 64) } } }
        @{ Name = 'a capability runtime missing a pin'; Code = 'RUNTIME'; Json = $null; Store = @{ CapabilityOverrides = @{ runtime = [ordered]@{ package_version = '2.0.0' } } } }
    ) {
        $envelopeParameters = @{}
        if (Get-Variable -Name AgentId -ErrorAction SilentlyContinue) { $envelopeParameters['AgentId'] = $AgentId }
        if (Get-Variable -Name Cwd -ErrorAction SilentlyContinue) { $envelopeParameters['Cwd'] = $Cwd }
        $json = $(if ($null -ne $Json) { $Json } else { Get-StartEnvelope @envelopeParameters })
        $store = $(if ($null -ne $Store) { Get-StartStore @Store } else { Get-StartStore })
        $outcomeParameters = @{ Json = $json; Store = $store }
        if (Get-Variable -Name ActualModel -ErrorAction SilentlyContinue) { $outcomeParameters['ActualModel'] = $ActualModel }
        if (Get-Variable -Name ActualReasoningEffort -ErrorAction SilentlyContinue) { $outcomeParameters['ActualReasoningEffort'] = $ActualReasoningEffort }
        if (Get-Variable -Name ProfileOverrides -ErrorAction SilentlyContinue) { $outcomeParameters['AgentProfile'] = Get-StartProfile -Overrides $ProfileOverrides }
        $outcome = Get-StartOutcome @outcomeParameters
        $outcome.Decision | Should -Be 'observe' -Because $Name
        $outcome.Code | Should -Be $Code -Because $outcome.Reason
        $store.Writes.Count | Should -Be 0
        $store.Replacements.Count | Should -Be 0
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
    }

    It 'observes a profile the host cannot read and never consults the mirror' {
        $store = Get-StartStore
        $outcome = Get-StartOutcome -Store $store -AgentProfile $null -ActualModel $null -ActualReasoningEffort $null -ReadBytes (Get-StartProfileReader -Text $null)
        $outcome.Decision | Should -Be 'observe'
        $outcome.Code | Should -Be 'PROFILE'
        $outcome.Reason | Should -BeLike '*does not exist*'
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
    }

    It 'observes a Markdown profile whose declared model differs from the deployment when the host exposes no model' {
        $reader = Get-StartProfileReader -Text "---`nname: legacy-parity-analyst-c3`nmodel: other-model`n---`n"
        (Get-StartOutcome -AgentProfile $null -ActualModel $null -ActualReasoningEffort $null -ReadBytes $reader).Code | Should -Be 'MODEL'
    }

    It 'attests a start whose Copilot payload carries the parent it was prepared under' {
        $store = Get-StartStore -HostName 'github-copilot' -InvocationOverrides @{ parent_agent_id = 'parent-alpha' }
        $json = Get-StartEnvelope -HostName 'github-copilot' -ParentAgentId 'parent-alpha'
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName 'github-copilot' -Text $json
        $outcome = Get-DiscoveryStartDecision -Normalized $normalized -HostEnvironment $script:GateHostEnvironment -HandlerSha256 ('9' * 64) -Store $store -Now $script:GateNow -Nonce $script:GateNonce -AgentProfile (Get-StartProfile -HostName 'github-copilot') -ActualModel 'gpt-6.1-sol' -ActualReasoningEffort 'high'
        $outcome.Decision | Should -Be 'attest' -Because $outcome.Reason
        ($store.Files[$outcome.AttestationPath] | ConvertFrom-Json).parent_agent_id | Should -Be 'parent-alpha'
    }

    It 'attests the start, records the attestation exclusively and moves the invocation to started' {
        $store = Get-StartStore
        $outcome = Get-StartOutcome -Store $store
        $outcome.Decision | Should -Be 'attest'
        $outcome.Code | Should -Be 'ATTESTED'
        $outcome.AttestationPath | Should -Be "$($script:GateInvocationDirectory)/start-attestation.json"
        $store.Writes | Should -Be @($outcome.AttestationPath)
        $store.Replacements | Should -Be @("$($script:GateInvocationDirectory)/invocation.json")
        $store.Reads | Should -Not -Contain $script:StartMirrorPath
        $attestation = $store.Files[$outcome.AttestationPath] | ConvertFrom-Json
        $attestation.artifact_kind | Should -Be 'start-attestation'
        $attestation.start_attestation_ref | Should -Be 'start-0123456789abcdef0123'
        $attestation.invocation_ref | Should -Be 'invocation-alpha'
        $attestation.parent_agent_id | Should -Be 'root'
        $attestation.agent_id | Should -Be 'agent-alpha'
        $attestation.agent_type | Should -Be 'legacy-parity-analyst-c3'
        $attestation.role | Should -Be 'legacy-parity-analyst'
        $attestation.deployment.actual_model | Should -Be 'gpt-6.1-sol'
        $attestation.agent_profile.sha256 | Should -Be ('a' * 64)
        $attestation.capability_ref | Should -Be 'capability-alpha-000000000001'
        $attestation.runtime.build_sha256 | Should -Be ('b' * 64)
        $attestation.writer.handler_sha256 | Should -Be ('9' * 64)
        $store.Files[$outcome.AttestationPath] | Should -Match '"attested_at": "2026-10-22T12:00:00Z"'
        $started = $store.Files["$($script:GateInvocationDirectory)/invocation.json"] | ConvertFrom-Json
        $started.state | Should -Be 'started'
        $started.agent_id | Should -Be 'agent-alpha'
        $started.start_attestation_ref | Should -Be 'start-0123456789abcdef0123'
        $started.deployment.model | Should -Be 'gpt-6.1-sol'
    }

    It 'attests a Markdown-profile host without an exposed model when the profile declares none' {
        $store = Get-StartStore
        $outcome = Get-StartOutcome -Store $store -AgentProfile $null -ActualModel $null -ActualReasoningEffort $null -ReadBytes (Get-StartProfileReader)
        $outcome.Decision | Should -Be 'attest'
        ($store.Files[$outcome.AttestationPath] | ConvertFrom-Json).deployment.actual_model | Should -BeNullOrEmpty
    }

    It 'refuses a second start for the same invocation through the exclusive write' {
        $store = Get-StartStore
        (Get-StartOutcome -Store $store).Decision | Should -Be 'attest'
        $store.Files["$($script:GateInvocationDirectory)/invocation.json"] = Get-StartInvocationText
        $outcome = Get-StartOutcome -Store $store
        $outcome.Code | Should -Be 'STORE'
        $store.Replacements.Count | Should -Be 1
    }

    It 'binds the started record so the PreToolUse adapter finds exactly it' {
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryAuthorization.psm1') -Force
        $store = Get-StartStore
        (Get-StartOutcome -Store $store).Decision | Should -Be 'attest'
        $principal = Get-DiscoveryTrustedPrincipal -Normalized (ConvertFrom-DiscoveryHostPayloadText -HostName 'claude-code' -Text (Get-GateEnvelope -ToolName 'Read' -ToolInput @{}))
        (Find-DiscoveryAgentInvocation -Location $script:GateLocation -Principal $principal -Store $store).Record.invocation_id | Should -Be 'invocation-alpha'
    }
}

Describe 'hook output rendering' {
    It 'stays silent for a skipped or attested start and reports an observed start without a blocking field' {
        $prefix = 'DISCOVERY_START_ATTESTATION_BLOCKED:'
        ConvertTo-DiscoveryStartHookOutput -Outcome ([pscustomobject]@{ Decision = 'skip'; Code = 'NOT_DISCOVERY_AGENT'; Reason = 'r' }) -ReasonPrefix $prefix | Should -BeNullOrEmpty
        ConvertTo-DiscoveryStartHookOutput -Outcome ([pscustomobject]@{ Decision = 'attest'; Code = 'ATTESTED'; Reason = 'r' }) -ReasonPrefix $prefix | Should -BeNullOrEmpty
        $output = ConvertTo-DiscoveryStartHookOutput -Outcome ([pscustomobject]@{ Decision = 'observe'; Code = 'NO_INVOCATION'; Reason = 'no prepared invocation' }) -ReasonPrefix $prefix
        $output.systemMessage | Should -Be "$prefix no prepared invocation"
        $output.hookSpecificOutput.hookEventName | Should -Be 'SubagentStart'
        $output.hookSpecificOutput.additionalContext | Should -BeLike "$prefix the start was not attested at launch*"
        @($output.Keys) | Should -Not -Contain 'continue'
        @($output.Keys) | Should -Not -Contain 'decision'
        @($output.hookSpecificOutput.Keys) | Should -Not -Contain 'permissionDecision'
    }
}
