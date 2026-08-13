#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'PowerShell attribution batch 1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:CoverageSettingsPath = Join-Path $script:RepoRoot `
            'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
        $script:RuntimePaths = @(
            '.codex/hooks/authorize-root-parallel-invocation.ps1'
            '.codex/hooks/enforce-parallel-root-invocation.ps1'
            '.codex/hooks/parallel-hook-common.ps1'
        )
        foreach ($runtimePath in $script:RuntimePaths) {
            . (Join-Path $script:RepoRoot $runtimePath)
        }

        function Get-Batch1Attestation {
            return [pscustomobject]@{
                agent_type                = 'parallel-planner'
                agent_id                  = 'agent-1'
                surface                   = 'parallel'
                provenance_valid          = $true
                root_authorized           = $true
                root_entry_kind           = 'parallel-plan'
                routing_valid             = $true
                profile_validation_error  = ''
                expected_model            = 'gpt-5.6-sol'
                actual_model              = 'gpt-5.6-sol'
                profile_model             = 'gpt-5.6-sol'
                expected_reasoning_effort = 'ultra'
                actual_reasoning_effort   = 'ultra'
                fallback_used             = $false
                parallel_identity         = 'parallel-1'
                mutation_identity         = 'parallel-1'
            }
        }
    }

    It 'registers <RuntimePath> for attributable coverage' -ForEach @(
        @{ RuntimePath = '.codex/hooks/authorize-root-parallel-invocation.ps1' }
        @{ RuntimePath = '.codex/hooks/enforce-parallel-root-invocation.ps1' }
        @{ RuntimePath = '.codex/hooks/parallel-hook-common.ps1' }
    ) {
        $settings = Get-Content -LiteralPath $script:CoverageSettingsPath -Raw

        $settings | Should -Match ([regex]::Escape("'$RuntimePath'"))
    }

    It 'exposes callable root-entry seams for source-attributable coverage' {
        Get-Command Invoke-RootParallelAuthorization -CommandType Function |
            Should -Not -BeNullOrEmpty
        Get-Command Invoke-CodexParallelRootGate -CommandType Function |
            Should -Not -BeNullOrEmpty
        (Get-Command Write-RootParallelInvocationReceipt).Parameters.Keys |
            Should -Contain 'OpenStream'
    }

    It 'classifies root entry prompts and their forced personas' {
        Get-RootParallelEntryKind -Prompt '/parallel-plan run-a' | Should -Be 'parallel-plan'
        Get-RootParallelEntryKind -Prompt '$parallel-run run-a' | Should -Be 'parallel-run'
        Get-RootParallelEntryKind -Prompt 'ordinary request' | Should -Be ''
        Get-RootParallelRequestedPersona -EntryKind 'parallel-plan' | Should -Be 'parallel-planner'
        Get-RootParallelRequestedPersona -EntryKind 'parallel-run' | Should -Be 'parallel-orchestrator'
    }

    It 'derives bounded references and rejects malformed root payloads' {
        Get-RootParallelReference -Prompt '/parallel-run docs/runs/run-a/parallel-kickoff.md' `
            -EntryKind 'parallel-run' | Should -Be 'docs/runs/run-a/parallel-kickoff.md'
        Get-RootParallelSlug -Reference 'docs/runs/run-a/parallel-kickoff.md' | Should -Be 'run-a'
        { ConvertFrom-RootParallelHookPayload -PayloadRaw '{' } | Should -Throw '*malformed JSON*'
    }

    It 'validates root payload shape, entry variants, slugs, and session origin' {
        { ConvertFrom-RootParallelHookPayload -PayloadRaw '' } | Should -Throw '*input is empty*'
        { ConvertFrom-RootParallelHookPayload -PayloadRaw '[]' } | Should -Throw '*one JSON object*'
        Get-RootParallelEntryKind -Prompt 'parallel-orchestrate run-a' |
            Should -Be 'parallel-orchestrate'
        Get-RootParallelRequestedPersona -EntryKind 'parallel-orchestrate' |
            Should -Be 'parallel-orchestrator'
        Get-RootParallelRequestedPersona -EntryKind '' | Should -Be ''
        Get-RootParallelReference -Prompt '/parallel-run' -EntryKind 'parallel-run' |
            Should -Be ''
        Get-RootParallelSlug -Reference '' | Should -Be ''
        Get-RootParallelSlug -Reference 'run-a,' | Should -Be 'run-a'
        Test-RootParallelSessionOrigin -Payload ([pscustomobject]@{}) | Should -BeTrue
        Test-RootParallelSessionOrigin -Payload ([pscustomobject]@{ parent_agent_id = 'p' }) |
            Should -BeFalse
    }

    It 'constructs valid root receipts and rejects incomplete authority inputs' {
        $now = [datetimeoffset]'2026-08-12T00:00:00Z'
        $base = [pscustomobject]@{
            prompt     = '/parallel-run docs/features/parallel/run-a/parallel-kickoff.md'
            session_id = 'session-1'
            turn_id    = 'turn-1'
        }
        $receipt = Get-RootParallelInvocationReceipt `
            -Payload $base `
            -Now $now `
            -RepositoryRoot 'C:/repo' `
            -HeadSha ('a' * 40)
        $receipt.requested_persona | Should -Be 'parallel-orchestrator'
        $receipt.parallel_slug | Should -Be 'run-a'
        $receipt.kickoff_path | Should -Be 'docs/features/parallel/run-a/parallel-kickoff.md'
        $receipt.expires_at | Should -Be $now.AddMinutes(60).ToString('o')

        Get-RootParallelInvocationReceipt `
            -Payload ([pscustomobject]@{ prompt = 'ordinary'; session_id = 's'; turn_id = 't' }) `
            -Now $now -RepositoryRoot 'C:/repo' -HeadSha ('a' * 40) |
            Should -BeNullOrEmpty
        { Get-RootParallelInvocationReceipt `
                -Payload ([pscustomobject]@{ prompt = '/parallel-plan run'; agent_id = 'child'; session_id = 's'; turn_id = 't' }) `
                -Now $now -RepositoryRoot 'C:/repo' -HeadSha ('a' * 40) } |
            Should -Throw '*root session*'
        { Get-RootParallelInvocationReceipt `
                -Payload ([pscustomobject]@{ prompt = '/parallel-plan run'; session_id = ''; turn_id = '' }) `
                -Now $now -RepositoryRoot 'C:/repo' -HeadSha ('a' * 40) } |
            Should -Throw '*requires session_id and turn_id*'
        { Get-RootParallelInvocationReceipt `
                -Payload ([pscustomobject]@{ prompt = '/parallel-plan'; session_id = 's'; turn_id = 't' }) `
                -Now $now -RepositoryRoot 'C:/repo' -HeadSha ('a' * 40) } |
            Should -Throw '*explicit reference*'
        { Get-RootParallelInvocationReceipt `
                -Payload ([pscustomobject]@{ prompt = '/parallel-plan /'; session_id = 's'; turn_id = 't' }) `
                -Now $now -RepositoryRoot 'C:/repo' -HeadSha ('a' * 40) } |
            Should -Throw '*identity could not be resolved*'
    }

    It 'writes a receipt through an in-memory stream without filesystem access' {
        $receipt = [ordered]@{ session_id = 'session-1'; turn_id = 'turn-1' }
        $createdPath = ''
        $openedPath = ''
        $result = Write-RootParallelInvocationReceipt `
            -RepositoryRoot 'C:/repo' `
            -Receipt $receipt `
            -CreateDirectory { param($path) $script:Batch1CreatedPath = $path } `
            -OpenStream {
            param($path)
            $script:Batch1OpenedPath = $path
            [System.IO.MemoryStream]::new()
        }
        $createdPath = $script:Batch1CreatedPath
        $openedPath = $script:Batch1OpenedPath

        $result | Should -Be $openedPath
        $createdPath | Should -Not -BeNullOrEmpty
    }

    It 'executes root authorization through injected head and receipt boundaries' {
        $script:Batch1WrittenReceipt = $null
        $raw = '{"prompt":"/parallel-plan run-a","session_id":"session-1","turn_id":"turn-1"}'
        $result = Invoke-RootParallelAuthorization `
            -PayloadRaw $raw `
            -RepositoryRoot 'C:/repo' `
            -Now ([datetimeoffset]'2026-08-12T00:00:00Z') `
            -HeadResolver { 'a' * 40 } `
            -ReceiptWriter {
            param($root, $receipt)
            $root | Should -Be 'C:/repo'
            $script:Batch1WrittenReceipt = $receipt
            'receipt.json'
        }
        $result.hookSpecificOutput.additionalContext | Should -Match 'parallel-planner'
        $script:Batch1WrittenReceipt.repository_head_sha | Should -Be ('a' * 40)
        Invoke-RootParallelAuthorization `
            -PayloadRaw '{"prompt":"ordinary"}' `
            -RepositoryRoot 'C:/repo' |
            Should -BeNullOrEmpty
        { Invoke-RootParallelAuthorization `
                -PayloadRaw $raw `
                -RepositoryRoot 'C:/repo' `
                -HeadResolver { 'invalid' } } |
            Should -Throw '*HEAD could not be resolved*'
    }

    It 'recognizes parallel-scoped inputs and nested mutation identities' {
        Test-CodexParallelScopedInput -ToolInput $null | Should -BeFalse
        Test-CodexParallelScopedInput -ToolInput ([pscustomobject]@{ surface = 'parallel' }) |
            Should -BeTrue
        Test-CodexParallelScopedInput -ToolInput ([pscustomobject]@{ mutation = @{} }) |
            Should -BeTrue
        $inputValue = [pscustomobject]@{
            mutation = [pscustomobject]@{ mutation_identity = ' identity-1 ' }
        }
        Get-CodexParallelMutationIdentity -ToolInput $inputValue | Should -Be 'identity-1'
        Test-CodexParallelScopedInput `
            -ToolInput ([pscustomobject]@{ route_id = 'parallel' }) | Should -BeTrue
        Test-CodexParallelScopedInput `
            -ToolInput ([pscustomobject]@{ artifact_type = 'parallel-kickoff' }) | Should -BeTrue
        Test-CodexParallelScopedInput `
            -ToolInput ([pscustomobject]@{ artifact_type = 'plan' }) | Should -BeFalse
        Get-CodexParallelMutationIdentity -ToolInput $null | Should -Be ''
        Get-CodexParallelMutationIdentity `
            -ToolInput ([pscustomobject]@{ parallel_identity = ' direct ' }) |
            Should -Be 'direct'
        Get-CodexParallelMutationIdentity -ToolInput ([pscustomobject]@{}) | Should -Be ''
    }

    It 'returns stable provenance errors for every root-attestation gate' {
        $payload = [pscustomobject]@{ agent_type = 'parallel-planner'; agent_id = 'agent-1' }
        $inputValue = [pscustomobject]@{ surface = 'parallel' }
        Get-CodexParallelRootError `
            -ToolInput ([pscustomobject]@{}) `
            -Payload ([pscustomobject]@{ agent_type = 'worker'; agent_id = 'agent-1' }) `
            -AttestationRaw '' | Should -BeNullOrEmpty
        Get-CodexParallelRootError -ToolInput $inputValue -Payload $payload -AttestationRaw '' |
            Should -Match 'no matching'
        Get-CodexParallelRootError -ToolInput $inputValue -Payload $payload -AttestationRaw '{' |
            Should -Match 'malformed JSON'

        $cases = @(
            @{ Mutate = { param($a) $a.agent_id = 'other' }; Expected = 'identity does not match' }
            @{ Mutate = { param($a) $a.root_authorized = $false }; Expected = 'lacks valid root-session authority' }
            @{ Mutate = { param($a) $a.root_entry_kind = 'parallel-run' }; Expected = 'does not authorize' }
            @{ Mutate = { param($a) $a.root_entry_kind = 'unknown' }; Expected = 'does not authorize' }
            @{ Mutate = { param($a) $a.actual_model = 'other' }; Expected = 'lacks exact Sol/Ultra' }
            @{ Mutate = { param($a) $a.fallback_used = $true }; Expected = 'does not prove no-fallback' }
            @{ Mutate = { param($a) $a.mutation_identity = 'other' }; Expected = 'lacks one shared' }
        )
        foreach ($case in $cases) {
            $attestation = Get-Batch1Attestation
            & $case.Mutate $attestation
            Get-CodexParallelRootError `
                -ToolInput $inputValue `
                -Payload $payload `
                -AttestationRaw ($attestation | ConvertTo-Json -Compress) |
                Should -Match $case.Expected
        }

        $valid = Get-Batch1Attestation
        Get-CodexParallelRootError `
            -ToolInput $inputValue -Payload $payload `
            -AttestationRaw ($valid | ConvertTo-Json -Compress) |
            Should -BeNullOrEmpty
        Get-CodexParallelRootError `
            -ToolInput ([pscustomobject]@{ mutation = [pscustomobject]@{ parallel_identity = 'wrong' } }) `
            -Payload $payload `
            -AttestationRaw ($valid | ConvertTo-Json -Compress) |
            Should -Match 'mutation identity does not match'
    }

    It 'executes the root gate through an injected attestation lookup' {
        $payload = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'parallel_add'
            tool_input      = [pscustomobject]@{ surface = 'parallel' }
            agent_type      = 'parallel-planner'
            agent_id        = 'agent-1'
        }
        $raw = $payload | ConvertTo-Json -Compress
        $result = Invoke-CodexParallelRootGate `
            -PayloadRaw $raw `
            -RepositoryRoot 'C:/repo' `
            -AttestationFinder { (Get-Batch1Attestation | ConvertTo-Json -Compress) }
        $result.ExitCode | Should -Be 0
        $result.Stdout | Should -Be ''
    }

    It 'resolves transcript-bound attestations through the established authority store' {
        Get-CodexParallelRootAttestationKey -TranscriptPath 'transcript.jsonl' |
            Should -Be (Get-CodexAuthoritySha256 -Text 'transcript.jsonl')
        Find-CodexParallelRootAttestation `
            -Payload ([pscustomobject]@{}) `
            -RepositoryRoot 'C:/repo' | Should -Be ''

        Mock Get-CodexAuthorityStateRoot { 'state' }
        Mock Get-CodexAuthorityAttestationPath { 'attestation.json' }
        Mock Test-Path {
            param($LiteralPath, $PathType)
            $null = $PathType
            return $LiteralPath -eq 'attestation.json'
        }
        Mock Get-Content { '{"agent_id":"agent-1"}' }
        $payload = [pscustomobject]@{
            session_id      = 'session-1'
            transcript_path = 'transcript.jsonl'
            agent_id        = 'agent-1'
        }
        Find-CodexParallelRootAttestation -Payload $payload -RepositoryRoot 'C:/repo' |
            Should -Match 'agent-1'
    }

    It 'falls back to agent identity when no transcript attestation exists' {
        Mock Get-CodexAuthorityStateRoot { 'state' }
        Mock Test-Path {
            param($LiteralPath, $PathType)
            $null = $PathType
            return $LiteralPath -eq 'state'
        }
        Mock Get-ChildItem {
            @(
                [pscustomobject]@{ FullName = 'malformed.json' }
                [pscustomobject]@{ FullName = 'matching.json' }
            )
        }
        Mock Get-Content {
            param($LiteralPath)
            if ($LiteralPath -eq 'malformed.json') {
                return '{'
            }
            return '{"agent_id":"agent-1"}'
        }
        $payload = [pscustomobject]@{ session_id = 'session-1'; agent_id = 'agent-1' }
        Find-CodexParallelRootAttestation -Payload $payload -RepositoryRoot 'C:/repo' |
            Should -Match 'agent-1'
        $payload.agent_id = 'missing'
        Find-CodexParallelRootAttestation -Payload $payload -RepositoryRoot 'C:/repo' |
            Should -Be ''
    }

    It 'uses the default attestation lookup for root-gate evaluation' {
        Mock Find-CodexParallelRootAttestation {
            Get-Batch1Attestation | ConvertTo-Json -Compress
        }
        $payload = [pscustomobject]@{
            hook_event_name = 'PreToolUse'
            tool_name       = 'parallel_add'
            tool_input      = [pscustomobject]@{ surface = 'parallel' }
            agent_type      = 'parallel-planner'
            agent_id        = 'agent-1'
        }
        $result = Invoke-CodexParallelRootGate `
            -PayloadRaw ($payload | ConvertTo-Json -Compress) `
            -RepositoryRoot 'C:/repo'
        $result.ExitCode | Should -Be 0
    }

    It 'normalizes valid, invalid, and denied native hook transport' {
        $raw = '{"hook_event_name":"PreToolUse","tool_name":"parallel_add","tool_input":{"surface":"parallel"}}'
        $payload = ConvertFrom-CodexParallelHookPayload -PayloadRaw $raw -HookName 'BATCH1'
        $payload.tool_name | Should -Be 'parallel_add'
        { ConvertFrom-CodexParallelHookPayload -PayloadRaw '' -HookName 'BATCH1' } |
            Should -Throw '*input is empty*'
        $envelope = ConvertTo-CodexParallelHookDenyEnvelope `
            -HookEventName 'PreToolUse' `
            -Reason 'denied'
        $envelope.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $envelope.hookSpecificOutput.permissionDecisionReason | Should -Be 'denied'
    }

    It 'rejects every malformed native payload shape' {
        $cases = @(
            @{ Raw = '[]'; Expected = '*one JSON object*' }
            @{ Raw = '{"tool_name":"Read","tool_input":{}}'; Expected = '*missing hook_event_name*' }
            @{ Raw = '{"hook_event_name":"PostToolUse","tool_name":"Read","tool_input":{}}'; Expected = '*unexpected hook_event_name*' }
            @{ Raw = '{"hook_event_name":"PreToolUse","tool_input":{}}'; Expected = '*missing tool_name*' }
            @{ Raw = '{"hook_event_name":"PreToolUse","tool_name":"Read"}'; Expected = '*missing object-valued tool_input*' }
        )
        foreach ($case in $cases) {
            { ConvertFrom-CodexParallelHookPayload `
                    -PayloadRaw $case.Raw -HookName 'BATCH1' } |
                Should -Throw $case.Expected
        }
    }

    It 'normalizes allow, deny, and validator-error results' {
        $raw = '{"hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{}}'
        $allow = Invoke-CodexParallelHookValidation `
            -HookName 'BATCH1' -ReasonCode 'BLOCKED' -PayloadRaw $raw `
            -Validator { }
        $allow.ExitCode | Should -Be 0
        $allow.Stdout | Should -Be ''
        $deny = Invoke-CodexParallelHookValidation `
            -HookName 'BATCH1' -ReasonCode 'BLOCKED' -PayloadRaw $raw `
            -Validator { ' first '; ''; 'second' }
        $deny.Stdout | Should -Match 'BLOCKED: first; second'
        $errorResult = Invoke-CodexParallelHookValidation `
            -HookName 'BATCH1' -ReasonCode 'BLOCKED' -PayloadRaw $raw `
            -Validator { throw 'failure' }
        $errorResult.ExitCode | Should -Be 2
        $errorResult.Stderr | Should -Match '^BATCH1 validation failed:'
        (ConvertTo-CodexParallelHookResult -ExitCode 2 -Stdout 'out' -Stderr 'err').ExitCode |
            Should -Be 2
    }

    It 'reads omitted payload input and writes both native result streams' {
        $originalIn = [Console]::In
        $originalOut = [Console]::Out
        $originalError = [Console]::Error
        $outputWriter = [System.IO.StringWriter]::new()
        $errorWriter = [System.IO.StringWriter]::new()
        try {
            [Console]::SetIn([System.IO.StringReader]::new(
                    '{"hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{}}'
                ))
            (ConvertFrom-CodexParallelHookPayload -HookName 'BATCH1').tool_name |
                Should -Be 'Read'
            [Console]::SetOut($outputWriter)
            [Console]::SetError($errorWriter)
            Write-CodexParallelHookResult -Result (
                ConvertTo-CodexParallelHookResult -ExitCode 2 -Stdout 'out' -Stderr 'err'
            ) | Should -Be 2
        } finally {
            [Console]::SetIn($originalIn)
            [Console]::SetOut($originalOut)
            [Console]::SetError($originalError)
        }
        $outputWriter.ToString() | Should -Match 'out'
        $errorWriter.ToString() | Should -Match 'err'
    }
}
