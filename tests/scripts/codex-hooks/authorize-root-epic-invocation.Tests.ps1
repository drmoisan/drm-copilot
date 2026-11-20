#Requires -Version 7.0

<#
.SYNOPSIS
    Unit tests for the Codex root epic-invocation authorization hook (issue #1035, remediation F1).

.DESCRIPTION
    Dot-sources .codex/hooks/authorize-root-epic-invocation.ps1 and covers payload parsing, the
    persona, reference, entry-kind and slug helpers, receipt construction, the receipt write
    through the -EnsureDirectory and -OpenFile seams, and the three outcomes of
    Invoke-RootEpicInvocationHook. Receipt writes go to MemoryStream seams; the default seams run
    only against paths that already exist, so CreateDirectory is a no-op and CreateNew refuses
    to open. No row creates a file or runs git.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
    # The hook imports the development-docs module when dot-sourced; remove it in AfterAll when
    # this suite was the one that loaded it.
    $script:DocsModuleWasLoaded = $null -ne (Get-Module -Name DevelopmentDocsRoot)
    . (Join-Path $script:HookRoot 'authorize-root-epic-invocation.ps1')
    $script:Now = [datetimeoffset]'2026-07-10T15:00:00Z'
    $script:HeadSha = 'a' * 40
}

AfterAll {
    if (-not $script:DocsModuleWasLoaded) {
        Remove-Module -Name DevelopmentDocsRoot -ErrorAction SilentlyContinue
    }
}

Describe 'ConvertFrom-RootEpicHookPayload' {
    It 'throws EPIC_INVOCATION_ORIGIN_BLOCKED for whitespace-only input' {
        { ConvertFrom-RootEpicHookPayload -PayloadRaw '   ' } | Should -Throw '*EPIC_INVOCATION_ORIGIN_BLOCKED: UserPromptSubmit hook input is empty.*'
    }

    It 'throws EPIC_INVOCATION_ORIGIN_BLOCKED for malformed JSON' {
        { ConvertFrom-RootEpicHookPayload -PayloadRaw '{ not json' } | Should -Throw '*EPIC_INVOCATION_ORIGIN_BLOCKED: UserPromptSubmit hook input is malformed JSON*'
    }

    It 'returns the parsed payload for valid JSON' {
        (ConvertFrom-RootEpicHookPayload -PayloadRaw '{"prompt":"x","turn_id":"t"}').turn_id | Should -Be 't'
    }
}

Describe 'Root epic prompt helpers' {
    It 'maps <Prompt> to persona <Persona>' -ForEach @(
        @{ Prompt = '/epic-plan deliver it'; Persona = 'epic-planner' }
        @{ Prompt = 'please invoke the Codex epic-planner now'; Persona = 'epic-planner' }
        @{ Prompt = '$epic-orchestrate sample'; Persona = 'epic-orchestrator' }
        @{ Prompt = 'delegate this to epic-orchestrator'; Persona = 'epic-orchestrator' }
        @{ Prompt = 'Summarize the plan.'; Persona = '' }
    ) {
        Get-RootEpicRequestedPersona -Prompt $Prompt | Should -BeExactly $Persona
    }

    It 'reads the reference after an explicit epic command' {
        Get-RootEpicReference -Prompt "/epic-run docs/features/epics/sample/epic.md  `nmore" | Should -BeExactly 'docs/features/epics/sample/epic.md'
    }

    It 'reads an epics-area path from prose and normalizes separators and trailing punctuation' {
        Get-RootEpicReference -Prompt 'run the epic at .dev\epics\sample\epic.md.' | Should -BeExactly '.dev/epics/sample/epic.md'
    }

    It 'returns an empty reference when the prompt names no epic' {
        Get-RootEpicReference -Prompt 'invoke the epic-planner' | Should -BeExactly ''
    }

    It 'maps <Prompt> to entry kind <Kind>' -ForEach @(
        @{ Prompt = '/epic-plan x'; Kind = 'epic-plan' }
        @{ Prompt = '/epic-run x'; Kind = 'epic-run' }
        @{ Prompt = '/epic-orchestrate x'; Kind = 'epic-orchestrate' }
        @{ Prompt = 'use the epic-orchestrator'; Kind = 'direct' }
    ) {
        Get-RootEpicEntryKind -Prompt $Prompt | Should -BeExactly $Kind
    }

    It 'derives slug <Expected> from reference <Reference>' -ForEach @(
        @{ Reference = ''; Expected = '' }
        @{ Reference = 'docs/features/epics/sample/epic-kickoff.md'; Expected = 'sample' }
        @{ Reference = 'docs\features\epics\other\'; Expected = 'other' }
        @{ Reference = 'epic.md'; Expected = 'epic.md' }
    ) {
        Get-RootEpicSlug -Reference $Reference | Should -BeExactly $Expected
    }

    It 'replaces unsafe turn-id characters in the receipt file name' {
        Get-RootEpicReceiptFileName -TurnId 'turn/1:a b' | Should -BeExactly 'epic-root-invocation.turn_1_a_b.json'
    }
}

Describe 'Get-RootEpicInvocationReceipt' {
    BeforeEach {
        Mock Resolve-DevelopmentDocsRoot { [pscustomobject]@{ Succeeded = $true; Root = 'docs/features'; Reason = $null } }
    }

    It 'requires a session id and a turn id for an epic prompt' {
        $payload = [pscustomobject]@{ session_id = 'session-1'; turn_id = ' '; prompt = '/epic-plan x' }
        { Get-RootEpicInvocationReceipt -Payload $payload -Now $script:Now -RepositoryRoot $script:RepoRoot -HeadSha $script:HeadSha } |
            Should -Throw '*requires session_id and turn_id*'
    }

    It 'builds the epic-run kickoff path from the resolved development-docs root' {
        Mock Resolve-DevelopmentDocsRoot { [pscustomobject]@{ Succeeded = $true; Root = '.dev'; Reason = $null } }
        $payload = [pscustomobject]@{ session_id = 'session-1'; turn_id = 'turn-1'; prompt = '/epic-run sample' }

        $receipt = Get-RootEpicInvocationReceipt -Payload $payload -Now $script:Now -RepositoryRoot $script:RepoRoot -HeadSha $script:HeadSha

        $receipt.kickoff_path | Should -BeExactly '.dev/epics/sample/epic-kickoff.md'
        $receipt.entry_kind | Should -BeExactly 'epic-run'
        $receipt.expires_at | Should -BeExactly $script:Now.AddMinutes(60).ToUniversalTime().ToString('o')
    }

    It 'blocks the receipt when the development-docs root cannot be resolved' {
        Mock Resolve-DevelopmentDocsRoot { [pscustomobject]@{ Succeeded = $false; Root = $null; Reason = 'routing unreadable' } }
        $payload = [pscustomobject]@{ session_id = 'session-1'; turn_id = 'turn-1'; prompt = '/epic-run sample' }
        { Get-RootEpicInvocationReceipt -Payload $payload -Now $script:Now -RepositoryRoot $script:RepoRoot -HeadSha $script:HeadSha } |
            Should -Throw '*EPIC_INVOCATION_ORIGIN_BLOCKED: routing unreadable*'
    }

    It 'leaves the kickoff path empty for a direct persona request' {
        $payload = [pscustomobject]@{ session_id = 'session-1'; turn_id = 'turn-1'; prompt = 'invoke the epic-orchestrator' }

        $receipt = Get-RootEpicInvocationReceipt -Payload $payload -Now $script:Now -RepositoryRoot $script:RepoRoot -HeadSha $script:HeadSha

        $receipt.entry_kind | Should -BeExactly 'direct'
        $receipt.kickoff_path | Should -BeExactly ''
        Should -Invoke Resolve-DevelopmentDocsRoot -Times 0 -Exactly
    }
}

Describe 'Write-RootEpicInvocationReceipt' {
    BeforeAll {
        $script:Receipt = [ordered]@{ session_id = 'session-1'; turn_id = 'turn-1'; requested_persona = 'epic-planner' }
    }

    It 'creates the authority directory and writes the receipt JSON through the seams' {
        # Arrange: the authority paths are synthetic; the stream is in memory.
        Mock Get-CodexAuthorityStateRoot { 'memory-authority' }
        Mock Get-CodexAuthorityReceiptPath { 'memory-authority/epic-root-invocation.turn-1.json' }
        $state = [pscustomobject]@{ Directory = $null; Path = $null; Stream = $null }
        $ensure = { param([string] $DirectoryPath) $state.Directory = $DirectoryPath }.GetNewClosure()
        $open = {
            param([string] $FilePath)
            $state.Path = $FilePath
            $state.Stream = [System.IO.MemoryStream]::new()
            return $state.Stream
        }.GetNewClosure()

        # Act
        $path = Write-RootEpicInvocationReceipt -RepositoryRoot $script:RepoRoot -Receipt $script:Receipt -EnsureDirectory $ensure -OpenFile $open

        # Assert
        $path | Should -BeExactly 'memory-authority/epic-root-invocation.turn-1.json'
        $state.Directory | Should -BeExactly 'memory-authority'
        $state.Path | Should -BeExactly $path
        $written = [System.Text.Encoding]::UTF8.GetString($state.Stream.ToArray()) | ConvertFrom-Json
        $written.turn_id | Should -BeExactly 'turn-1'
        $written.requested_persona | Should -BeExactly 'epic-planner'
    }

    It 'refuses through the default seams to overwrite a receipt that already exists' {
        # Arrange: an existing directory and an existing file, so the default CreateDirectory is a
        # no-op and the default CreateNew open throws without creating anything.
        $script:ExistingDirectory = $PSScriptRoot
        $script:ExistingFile = Join-Path $PSScriptRoot 'authorize-root-epic-invocation.Tests.ps1'
        Mock Get-CodexAuthorityStateRoot { $script:ExistingDirectory }
        Mock Get-CodexAuthorityReceiptPath { $script:ExistingFile }

        # Act / Assert
        { Write-RootEpicInvocationReceipt -RepositoryRoot $script:RepoRoot -Receipt $script:Receipt } | Should -Throw '*exists*'
    }
}

Describe 'Invoke-RootEpicInvocationHook' {
    BeforeEach {
        Mock Invoke-RootEpicGitExe { [pscustomobject]@{ Output = @('b' * 40); ExitCode = 0 } }
        Mock Write-RootEpicInvocationReceipt { 'memory-authority/receipt.json' }
    }

    It 'exits 0 with no output for a non-epic prompt' {
        $result = Invoke-RootEpicInvocationHook -PayloadRaw '{"prompt":"Fix a bug.","session_id":"s","turn_id":"t"}' -RepositoryRoot $script:RepoRoot -Now $script:Now

        $result.ExitCode | Should -Be 0
        $result.Output | Should -BeNullOrEmpty
        $result.ErrorText | Should -BeNullOrEmpty
        Should -Invoke Invoke-RootEpicGitExe -Times 0 -Exactly
    }

    It 'exits 0 with the UserPromptSubmit JSON after writing a receipt' {
        $result = Invoke-RootEpicInvocationHook -PayloadRaw '{"prompt":"/epic-plan x","session_id":"s","turn_id":"t"}' -RepositoryRoot $script:RepoRoot -Now $script:Now

        $result.ExitCode | Should -Be 0
        $output = $result.Output | ConvertFrom-Json
        $output.hookSpecificOutput.hookEventName | Should -BeExactly 'UserPromptSubmit'
        $output.hookSpecificOutput.additionalContext | Should -BeExactly 'Root epic invocation authorized for epic-planner; receipt: memory-authority/receipt.json'
        Should -Invoke Invoke-RootEpicGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq "-C $($script:RepoRoot) rev-parse HEAD" }
        Should -Invoke Write-RootEpicInvocationReceipt -Times 1 -Exactly
    }

    It 'exits 0 with no output when no receipt is minted' {
        Mock Get-RootEpicInvocationReceipt { $null }

        $result = Invoke-RootEpicInvocationHook -PayloadRaw '{"prompt":"/epic-plan x","session_id":"s","turn_id":"t"}' -RepositoryRoot $script:RepoRoot -Now $script:Now

        $result.ExitCode | Should -Be 0
        $result.Output | Should -BeNullOrEmpty
        Should -Invoke Write-RootEpicInvocationReceipt -Times 0 -Exactly
    }

    It 'exits 2 with the blocking text when HEAD cannot be resolved' {
        Mock Invoke-RootEpicGitExe { [pscustomobject]@{ Output = @('fatal: not a git repository'); ExitCode = 128 } }

        $result = Invoke-RootEpicInvocationHook -PayloadRaw '{"prompt":"/epic-plan x","session_id":"s","turn_id":"t"}' -RepositoryRoot $script:RepoRoot -Now $script:Now

        $result.ExitCode | Should -Be 2
        $result.Output | Should -BeNullOrEmpty
        $result.ErrorText | Should -BeLike '*EPIC_INVOCATION_ORIGIN_BLOCKED: repository HEAD could not be resolved.*'
        Should -Invoke Write-RootEpicInvocationReceipt -Times 0 -Exactly
    }

    It 'returns the exit code after writing nothing for an empty result' {
        $writes = [System.Collections.Generic.List[string]]::new()
        $record = { param([string] $Text) $writes.Add($Text) }.GetNewClosure()

        Write-RootEpicInvocationHookResult -Result ([pscustomobject]@{ ExitCode = 0; Output = $null; ErrorText = $null }) -WriteStdout $record -WriteStderr $record | Should -Be 0
        $writes.Count | Should -Be 0
    }

    It 'writes the output to stdout and the error text to stderr through the seams' {
        $stdout = [System.Collections.Generic.List[string]]::new()
        $stderr = [System.Collections.Generic.List[string]]::new()
        $writeOut = { param([string] $Text) $stdout.Add($Text) }.GetNewClosure()
        $writeErr = { param([string] $Text) $stderr.Add($Text) }.GetNewClosure()

        $code = Write-RootEpicInvocationHookResult -Result ([pscustomobject]@{ ExitCode = 2; Output = '{"a":1}'; ErrorText = 'EPIC_INVOCATION_ORIGIN_BLOCKED: x' }) -WriteStdout $writeOut -WriteStderr $writeErr

        $code | Should -Be 2
        @($stdout) | Should -Be @('{"a":1}')
        @($stderr) | Should -Be @('EPIC_INVOCATION_ORIGIN_BLOCKED: x')
    }

    It 'returns only the exit code when the default console writers run' {
        $code = @(Write-RootEpicInvocationHookResult -Result ([pscustomobject]@{ ExitCode = 0; Output = 'hook-output-line'; ErrorText = 'hook-error-line' }))

        $code | Should -Be @(0)
    }

    It 'exits 2 with the blocking text for a malformed payload' {
        $result = Invoke-RootEpicInvocationHook -PayloadRaw '{ not json' -RepositoryRoot $script:RepoRoot -Now $script:Now

        $result.ExitCode | Should -Be 2
        $result.ErrorText | Should -BeLike '*EPIC_INVOCATION_ORIGIN_BLOCKED: UserPromptSubmit hook input is malformed JSON*'
    }
}
