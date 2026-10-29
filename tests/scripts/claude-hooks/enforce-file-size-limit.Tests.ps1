#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the enforce-file-size-limit.ps1 PreToolUse hook (issue #990).

.DESCRIPTION
    Drives Invoke-FileSizeLimitDecision with the nested PreToolUse envelope and an
    injected ReadFileContent seam that serves in-memory content keyed by path, so no
    row creates a file. Roots are '/repo'-style with forward slashes, and paths are
    joined with Join-Path, so the rows hold on the case-sensitive Linux hook job.

    One row runs the hook script in process with '&' and a redirected console input,
    and one row reads this hook's own file through the default reader.
#>

BeforeAll {
    $script:HookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-file-size-limit.ps1'
    . $script:HookPath

    $script:Root = '/repo'

    function Get-FileSizeTestText {
        param([Parameter(Mandatory)][int] $LineCount, [string] $Terminator = "`n")
        if ($LineCount -eq 0) { return '' }
        return ((1..$LineCount | ForEach-Object { "line $_" }) -join $Terminator) + $Terminator
    }

    function ConvertTo-FileSizeEnvelope {
        param([Parameter(Mandatory)][string] $ToolName, [Parameter(Mandatory)][hashtable] $ToolInput)
        return (@{ tool_name = $ToolName; tool_input = $ToolInput } | ConvertTo-Json -Compress -Depth 5)
    }

    # Reader seam over an in-memory map. A key mapped to the string THROW raises.
    function Get-FileSizeTestReader {
        param([hashtable] $Files = @{})
        $map = $Files
        return {
            param([string] $Path)
            $key = $Path.Replace('\', '/')
            if ($map.ContainsKey($key)) {
                if ($map[$key] -eq 'THROW') { throw 'access denied' }
                return $map[$key]
            }
            return $null
        }.GetNewClosure()
    }

    $script:ThrowingReader = { param([string] $Path) throw "reader must not be called for $Path" }
    $script:ExistingPath = '/repo/scripts/large.ps1'
}

AfterAll {
    Remove-Module -Name FileSizePolicy -Force -ErrorAction SilentlyContinue
    Remove-Module -Name HookPayload -Force -ErrorAction SilentlyContinue
}

Describe 'enforce-file-size-limit.ps1' {
    Context 'Write' {
        It 'denies a Write of a new covered file with 801 logical lines' {
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Write' -ToolInput @{ file_path = 'scripts/new.py'; content = (Get-FileSizeTestText -LineCount 801) }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent (Get-FileSizeTestReader)

            $result.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $result.hookSpecificOutput.permissionDecisionReason
            $reason | Should -Match '^FILE_SIZE_LIMIT_BLOCKED:'
            $reason | Should -Match '500'
            $reason | Should -Match '700'
            $reason | Should -Match 'scripts/new.py'
            $reason | Should -Match '801 logical lines'
        }

        It 'allows a Write of a new covered file with 800 lines without reading the file' {
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Write' -ToolInput @{ file_path = 'scripts/new.py'; content = (Get-FileSizeTestText -LineCount 800) }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $script:ThrowingReader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'counts CRLF content identically and denies 801 CRLF lines' {
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Write' -ToolInput @{ file_path = 'src/app.ts'; content = (Get-FileSizeTestText -LineCount 801 -Terminator "`r`n") }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent (Get-FileSizeTestReader)

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows a Write that shrinks an already-large file' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = (Get-FileSizeTestText -LineCount 900) }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Write' -ToolInput @{ file_path = 'scripts/large.ps1'; content = (Get-FileSizeTestText -LineCount 850) }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies a Write that grows an already-large file' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = (Get-FileSizeTestText -LineCount 810) }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Write' -ToolInput @{ file_path = 'scripts/large.ps1'; content = (Get-FileSizeTestText -LineCount 815) }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'It has 810 lines now'
        }

        It 'reads an absolute path under the root at that path' {
            $reader = Get-FileSizeTestReader -Files @{ '/repo/src/big.cs' = (Get-FileSizeTestText -LineCount 900) }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Write' -ToolInput @{ file_path = '/repo/src/big.cs'; content = (Get-FileSizeTestText -LineCount 900) }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies a Write above 800 lines when the existing file cannot be read' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = 'THROW' }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Write' -ToolInput @{ file_path = 'scripts/large.ps1'; content = (Get-FileSizeTestText -LineCount 805) }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be read'
        }
    }

    Context 'Edit' {
        It 'denies an Edit that grows a pre-edit 810-line file to 815' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = (Get-FileSizeTestText -LineCount 810) }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = "line 810`n"; new_string = (Get-FileSizeTestText -LineCount 6) }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match '815 logical lines'
        }

        It 'allows an Edit that shrinks a pre-edit 810-line file to 805' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = (Get-FileSizeTestText -LineCount 810) }
            $old = "line 806`nline 807`nline 808`nline 809`nline 810`n"
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = $old; new_string = '' }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an Edit that leaves a pre-edit 810-line file at 810' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = (Get-FileSizeTestText -LineCount 810) }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = "line 42`n"; new_string = "line forty-two`n" }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'applies replace_all given as the string true' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = ("x`n" * 400) }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = 'x'; new_string = "x`nx"; replace_all = 'true' }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            # 400 lines doubled to 800 is at the limit and allowed.
            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'applies replace_all given as a boolean and denies the grown result' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = ("x`n" * 401) }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = 'x'; new_string = "x`nx"; replace_all = $true }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'treats replace_all false as one replacement and fails closed on an ambiguous match' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = ("x`n" * 3) }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = 'x'; new_string = 'y'; replace_all = 'false' }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match '\(ambiguous\)'
        }

        It 'fails closed on an Edit whose old_string is <Code>' -ForEach @(
            @{ Code = 'no-old-string'; ToolInput = @{ file_path = 'scripts/large.ps1'; new_string = 'y' } }
            @{ Code = 'not-found'; ToolInput = @{ file_path = 'scripts/large.ps1'; old_string = 'absent text'; new_string = 'y'; replace_all = 7 } }
        ) {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = "a`nb`n" }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput $ToolInput

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match ([regex]::Escape("($Code)"))
        }

        It 'fails closed on an Edit to a covered file that cannot be read' {
            $reader = Get-FileSizeTestReader -Files @{ $script:ExistingPath = 'THROW' }
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = 'a'; new_string = 'b' }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $reader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'access denied'
        }

        It 'fails closed on an Edit to a covered file that does not exist' {
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/missing.py'; old_string = 'a'; new_string = 'b' }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent (Get-FileSizeTestReader)

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -Match 'does not exist'
        }

        It 'reads this hook file through the default reader and allows a size-neutral Edit' {
            $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Edit' -ToolInput @{ file_path = '.claude/hooks/enforce-file-size-limit.ps1'; old_string = 'function Invoke-FileSizeLimitEntryPoint {'; new_string = 'function Invoke-FileSizeLimitEntryPoint {' }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $repoRoot

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'non-covered paths' {
        It 'allows a <Tool> of a <Kind> path of any size without reading the file' -ForEach @(
            @{ Tool = 'Write'; Kind = 'Markdown'; Path = 'docs/guide.md' }
            @{ Tool = 'Edit'; Kind = 'Markdown'; Path = 'README.md' }
            @{ Tool = 'Write'; Kind = 'JSON'; Path = 'config/data.json' }
            @{ Tool = 'Edit'; Kind = 'JSON'; Path = 'config/data.json' }
            @{ Tool = 'Write'; Kind = 'outside-root'; Path = '/scratch/issue-990/tool.ps1' }
            @{ Tool = 'Write'; Kind = 'no file_path'; Path = '' }
        ) {
            $envelope = ConvertTo-FileSizeEnvelope -ToolName $Tool -ToolInput @{ file_path = $Path; content = (Get-FileSizeTestText -LineCount 5000); old_string = 'a'; new_string = 'b' }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $envelope -RepositoryRoot $script:Root -ReadFileContent $script:ThrowingReader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'fail-closed envelope and dependency handling' {
        It 'denies an unreadable envelope: <Label>' -ForEach @(
            @{ Label = 'empty payload'; Raw = '' }
            @{ Label = 'malformed JSON'; Raw = '{not json' }
            @{ Label = 'missing tool_input'; Raw = '{"tool_name":"Write"}' }
        ) {
            $result = Invoke-FileSizeLimitDecision -ToolInputRaw $Raw -RepositoryRoot $script:Root -ReadFileContent $script:ThrowingReader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'FILE_SIZE_LIMIT_BLOCKED: payload anomaly*'
        }

        It 'returns the dependency-failure decision before reading the payload' {
            Mock Get-HookDependencyFailureDecision {
                [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = "$ReasonPrefix the dependency 'FileSizePolicy.psm1' failed to load" } }
            }
            Mock Resolve-ClaudeHookToolInput { throw 'payload must not be read' }

            $result = Invoke-FileSizeLimitDecision -ToolInputRaw '{}' -RepositoryRoot $script:Root -ReadFileContent $script:ThrowingReader

            $result.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'FILE_SIZE_LIMIT_BLOCKED:*FileSizePolicy.psm1*'
            Should -Invoke Resolve-ClaudeHookToolInput -Times 0 -Exactly
        }
    }

    Context 'entry point' {
        It 'writes the decision JSON and returns 0 from the entry-point function' {
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Write' -ToolInput @{ file_path = 'notes.md'; content = 'x' }

            $output = @(Invoke-FileSizeLimitEntryPoint -ReadPayload { $envelope }.GetNewClosure())

            $output[-1] | Should -Be 0
            ($output[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'writes a deny decision and exits 0 when the script runs in process' {
            $envelope = ConvertTo-FileSizeEnvelope -ToolName 'Write' -ToolInput @{ file_path = 'scripts/issue-990-absent-probe.py'; content = (Get-FileSizeTestText -LineCount 801) }
            $originalIn = [System.Console]::In
            $originalHookInput = $env:CLAUDE_HOOK_INPUT
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($envelope))
                $env:CLAUDE_HOOK_INPUT = $envelope
                $stdout = & $script:HookPath
                $exitCode = $LASTEXITCODE
            } finally {
                [System.Console]::SetIn($originalIn)
                $env:CLAUDE_HOOK_INPUT = $originalHookInput
            }

            $exitCode | Should -Be 0
            $decision = (@($stdout) -join "`n") | ConvertFrom-Json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'FILE_SIZE_LIMIT_BLOCKED: *'
        }
    }
}
