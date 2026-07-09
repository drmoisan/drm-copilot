<#
.SYNOPSIS
    Pester tests for the persist-session-id.ps1 SessionStart hook.
#>

Set-StrictMode -Version Latest

Describe 'persist-session-id.ps1' {
    BeforeAll {
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'persist-session-id.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path
        . $script:ScriptPath

        function ConvertTo-SessionPayload {
            param([Parameter(Mandatory)][string] $SessionId)
            return ([ordered]@{ session_id = $SessionId } | ConvertTo-Json -Compress)
        }
    }

    BeforeEach {
        # Recorders capture every injected-writer invocation so assertions can
        # confirm both the target/content and the absence of writes. Capturing
        # the arguments keeps all scriptblock parameters used.
        $script:appendCalls = [System.Collections.ArrayList]::new()
        $script:stateCalls = [System.Collections.ArrayList]::new()
        $script:ensureCalls = [System.Collections.ArrayList]::new()
        $script:AppendRecorder = {
            param([string] $Path, [string] $Line)
            [void]$script:appendCalls.Add([pscustomobject]@{ Path = $Path; Line = $Line })
        }
        $script:StateRecorder = {
            param([string] $Path, [string] $Content)
            [void]$script:stateCalls.Add([pscustomobject]@{ Path = $Path; Content = $Content })
        }
        $script:EnsureRecorder = {
            param([string] $Path)
            [void]$script:ensureCalls.Add($Path)
        }
    }

    Context 'Get-PersistSessionIdDecision' {
        It 'chooses the env-file channel when CLAUDE_ENV_FILE is set' {
            $payload = ConvertTo-SessionPayload -SessionId 'ef8e8029-7c73-4346-80c7-5b0ad94b33fe'

            $decision = Get-PersistSessionIdDecision -RawPayload $payload -EnvFilePath '/env/file' -StateFilePath '/repo/.claude/state/current-session-id'

            $decision.action | Should -Be 'env-file'
            $decision.sessionId | Should -Be 'ef8e8029-7c73-4346-80c7-5b0ad94b33fe'
            $decision.path | Should -Be '/env/file'
        }

        It 'chooses the state-file channel when CLAUDE_ENV_FILE is unset' {
            $payload = ConvertTo-SessionPayload -SessionId 'session-12345'

            $decision = Get-PersistSessionIdDecision -RawPayload $payload -EnvFilePath '' -StateFilePath '/repo/.claude/state/current-session-id'

            $decision.action | Should -Be 'state-file'
            $decision.sessionId | Should -Be 'session-12345'
            $decision.path | Should -Be '/repo/.claude/state/current-session-id'
        }

        It 'returns action none for malformed JSON' {
            $decision = Get-PersistSessionIdDecision -RawPayload '{ not valid json' -EnvFilePath '/env/file' -StateFilePath '/repo/state'

            $decision.action | Should -Be 'none'
        }

        It 'returns action none for empty input' {
            $decision = Get-PersistSessionIdDecision -RawPayload '' -EnvFilePath '/env/file' -StateFilePath '/repo/state'

            $decision.action | Should -Be 'none'
        }

        It 'returns action none when session_id is absent from the payload' {
            $payload = ([ordered]@{ cwd = '/repo'; hook_event_name = 'SessionStart' } | ConvertTo-Json -Compress)

            $decision = Get-PersistSessionIdDecision -RawPayload $payload -EnvFilePath '/env/file' -StateFilePath '/repo/state'

            $decision.action | Should -Be 'none'
        }
    }

    Context 'Invoke-PersistSessionIdHook' {
        It 'appends CLAUDE_SESSION_ID=<id> to the env file when CLAUDE_ENV_FILE is set' {
            $payload = ConvertTo-SessionPayload -SessionId 'ef8e8029-7c73-4346-80c7-5b0ad94b33fe'

            $decision = Invoke-PersistSessionIdHook `
                -RawPayload $payload `
                -EnvFilePath '/env/file' `
                -StateFilePath '/repo/.claude/state/current-session-id' `
                -AppendLine $script:AppendRecorder `
                -WriteStateFile $script:StateRecorder `
                -EnsureDirectory $script:EnsureRecorder

            $decision.action | Should -Be 'env-file'
            $script:appendCalls.Count | Should -Be 1
            $script:appendCalls[0].Path | Should -Be '/env/file'
            $script:appendCalls[0].Line | Should -Be 'CLAUDE_SESSION_ID=ef8e8029-7c73-4346-80c7-5b0ad94b33fe'
            $script:stateCalls.Count | Should -Be 0
        }

        It 'writes the id to the state file (ensuring its directory) when CLAUDE_ENV_FILE is unset' {
            $payload = ConvertTo-SessionPayload -SessionId 'session-abcdef'

            $decision = Invoke-PersistSessionIdHook `
                -RawPayload $payload `
                -EnvFilePath '' `
                -StateFilePath '/repo/.claude/state/current-session-id' `
                -AppendLine $script:AppendRecorder `
                -WriteStateFile $script:StateRecorder `
                -EnsureDirectory $script:EnsureRecorder

            $expectedStateDir = Split-Path -Path '/repo/.claude/state/current-session-id' -Parent

            $decision.action | Should -Be 'state-file'
            $script:stateCalls.Count | Should -Be 1
            $script:stateCalls[0].Path | Should -Be '/repo/.claude/state/current-session-id'
            $script:stateCalls[0].Content | Should -Be 'session-abcdef'
            $script:ensureCalls | Should -Contain $expectedStateDir
            $script:appendCalls.Count | Should -Be 0
        }

        It 'performs no write on malformed JSON' {
            $decision = Invoke-PersistSessionIdHook `
                -RawPayload '{ not valid json' `
                -EnvFilePath '/env/file' `
                -StateFilePath '/repo/state' `
                -AppendLine $script:AppendRecorder `
                -WriteStateFile $script:StateRecorder `
                -EnsureDirectory $script:EnsureRecorder

            $decision.action | Should -Be 'none'
            $script:appendCalls.Count | Should -Be 0
            $script:stateCalls.Count | Should -Be 0
        }

        It 'performs no write on empty input' {
            $decision = Invoke-PersistSessionIdHook `
                -RawPayload '' `
                -EnvFilePath '/env/file' `
                -StateFilePath '/repo/state' `
                -AppendLine $script:AppendRecorder `
                -WriteStateFile $script:StateRecorder `
                -EnsureDirectory $script:EnsureRecorder

            $decision.action | Should -Be 'none'
            $script:appendCalls.Count | Should -Be 0
            $script:stateCalls.Count | Should -Be 0
        }
    }

    Context 'Read-HookPayload' {
        It 'returns the standard-input payload when present' {
            $result = Read-HookPayload -ReadStandardInput { 'STDIN-PAYLOAD' } -FallbackPayload 'FALLBACK'

            $result | Should -Be 'STDIN-PAYLOAD'
        }

        It 'falls back to CLAUDE_HOOK_INPUT when standard input is empty' {
            $result = Read-HookPayload -ReadStandardInput { '' } -FallbackPayload 'FALLBACK'

            $result | Should -Be 'FALLBACK'
        }

        It 'falls back to CLAUDE_HOOK_INPUT when reading standard input throws' {
            $result = Read-HookPayload -ReadStandardInput { throw 'no stdin' } -FallbackPayload 'FALLBACK'

            $result | Should -Be 'FALLBACK'
        }
    }

    Context 'default writers (mocked cmdlets, no disk access)' {
        It 'appends the session line via Add-Content by default when CLAUDE_ENV_FILE is set' {
            Mock Add-Content { }
            Mock Set-Content { }
            $payload = ConvertTo-SessionPayload -SessionId 'ef8e8029-7c73-4346-80c7-5b0ad94b33fe'

            $decision = Invoke-PersistSessionIdHook -RawPayload $payload -EnvFilePath '/env/file' -StateFilePath '/repo/.claude/state/current-session-id'

            $decision.action | Should -Be 'env-file'
            Should -Invoke Add-Content -Times 1 -Exactly
            Should -Invoke Set-Content -Times 0 -Exactly
        }

        It 'writes via Set-Content and creates the directory via New-Item by default when CLAUDE_ENV_FILE is unset' {
            Mock Set-Content { }
            Mock New-Item { }
            Mock Test-Path { $false }
            Mock Add-Content { }
            $payload = ConvertTo-SessionPayload -SessionId 'session-abcdef'

            $decision = Invoke-PersistSessionIdHook -RawPayload $payload -EnvFilePath '' -StateFilePath '/repo/.claude/state/current-session-id'

            $decision.action | Should -Be 'state-file'
            Should -Invoke Set-Content -Times 1 -Exactly
            Should -Invoke New-Item -Times 1 -Exactly
            Should -Invoke Add-Content -Times 0 -Exactly
        }
    }
}
