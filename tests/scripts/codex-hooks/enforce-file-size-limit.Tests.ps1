#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Pester tests for the Codex enforce-file-size-limit.ps1 PreToolUse hook (issue #990).

.DESCRIPTION
    Drives Invoke-CodexFileSizeLimitEntryPoint in process with Codex stdin payloads for
    Write, Edit, and apply_patch Add, Update, rename, and Delete. File content comes from
    an injected ReadFileContent seam over an in-memory map, and the apply_patch Update
    reconstruction helper Resolve-CodexUpdatedFileContent is mocked, so no row reads or
    writes a file. Console output and error streams are redirected to StringWriter
    instances for the duration of each call. Roots are '/repo'-style with forward slashes
    so the rows hold on the case-sensitive Linux hook job.
#>

BeforeAll {
    $script:HookPath = Join-Path $PSScriptRoot '../../../.codex/hooks/enforce-file-size-limit.ps1'
    . $script:HookPath

    $script:Root = '/repo'

    function Get-CodexFileSizeTestText {
        param([Parameter(Mandatory)][int] $LineCount)
        return ((1..$LineCount | ForEach-Object { "line $_" }) -join "`n") + "`n"
    }

    function ConvertTo-CodexFileSizePayload {
        param([Parameter(Mandatory)][string] $ToolName, [Parameter(Mandatory)][hashtable] $ToolInput)
        return (@{ session_id = 's'; hook_event_name = 'PreToolUse'; tool_name = $ToolName; tool_input = $ToolInput } | ConvertTo-Json -Compress -Depth 6)
    }

    function ConvertTo-CodexFileSizePatchPayload {
        param([Parameter(Mandatory)][string] $Patch)
        return ConvertTo-CodexFileSizePayload -ToolName 'apply_patch' -ToolInput @{ command = $Patch }
    }

    # Reader seam over an in-memory map keyed by forward-slash path. THROW raises.
    function Get-CodexFileSizeTestReader {
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

    # Runs the entry point with redirected console streams and returns exit code, stdout, stderr.
    function Invoke-CodexFileSizeHook {
        param([AllowEmptyString()][string] $PayloadRaw, [scriptblock] $Reader = (Get-CodexFileSizeTestReader))
        $originalOut = [Console]::Out
        $originalError = [Console]::Error
        $out = [System.IO.StringWriter]::new()
        $err = [System.IO.StringWriter]::new()
        try {
            [Console]::SetOut($out)
            [Console]::SetError($err)
            $exitCode = Invoke-CodexFileSizeLimitEntryPoint -PayloadRaw $PayloadRaw -RepositoryRoot $script:Root -ReadFileContent $Reader
        } finally {
            [Console]::SetOut($originalOut)
            [Console]::SetError($originalError)
        }
        $stdout = $out.ToString().Trim()
        $decision = $null
        if ($stdout) { $decision = $stdout | ConvertFrom-Json }
        return [pscustomobject]@{ ExitCode = $exitCode; Stdout = $stdout; Stderr = $err.ToString().Trim(); Decision = $decision }
    }

    $script:ThrowingReader = { param([string] $Path) throw "reader must not be called for $Path" }
}

Describe 'Codex enforce-file-size-limit.ps1' {
    Context 'Write and apply_patch Add' {
        It 'denies a Write of a new covered file with 801 lines' {
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Write' -ToolInput @{ file_path = 'scripts/new.py'; content = (Get-CodexFileSizeTestText -LineCount 801) }

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $result.Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -Match '^FILE_SIZE_LIMIT_BLOCKED:.*801 logical lines'
        }

        It 'allows a Write of a new covered file with 800 lines silently without a read' {
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Write' -ToolInput @{ file_path = 'scripts/new.py'; content = (Get-CodexFileSizeTestText -LineCount 800) }

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $script:ThrowingReader

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'allows a Write that shrinks an already-large file' {
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/scripts/large.ps1' = (Get-CodexFileSizeTestText -LineCount 900) }
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Write' -ToolInput @{ file_path = 'scripts/large.ps1'; content = (Get-CodexFileSizeTestText -LineCount 850) }

            (Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $reader).Stdout | Should -BeNullOrEmpty
        }

        It 'denies an apply_patch Add of an 801-line covered file' {
            $added = (1..801 | ForEach-Object { "+line $_" }) -join "`n"
            $payload = ConvertTo-CodexFileSizePatchPayload -Patch "*** Begin Patch`n*** Add File: scripts/example.py`n$added`n*** End Patch"

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload

            $result.Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'FILE_SIZE_LIMIT_BLOCKED'
        }

        It 'denies a Write above 800 lines when the existing file cannot be read' {
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/scripts/large.ps1' = 'THROW' }
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Write' -ToolInput @{ file_path = 'scripts/large.ps1'; content = (Get-CodexFileSizeTestText -LineCount 805) }

            (Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $reader).Decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be read'
        }
    }

    Context 'Edit' {
        It 'denies an Edit that grows an 810-line file to 815' {
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/scripts/large.ps1' = (Get-CodexFileSizeTestText -LineCount 810) }
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = "line 810`n"; new_string = (Get-CodexFileSizeTestText -LineCount 6) }

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $reader

            $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -Match '815 logical lines'
        }

        It 'allows an Edit that keeps an 810-line file at 810' {
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/scripts/large.ps1' = (Get-CodexFileSizeTestText -LineCount 810) }
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = "line 42`n"; new_string = "line forty-two`n" }

            (Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $reader).Stdout | Should -BeNullOrEmpty
        }

        It 'honors replace_all given as <Label>' -ForEach @(
            @{ Label = 'the string true'; Flag = 'true'; Lines = 400; Denied = $false }
            @{ Label = 'a boolean'; Flag = $true; Lines = 401; Denied = $true }
        ) {
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/scripts/large.ps1' = ("x`n" * $Lines) }
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = 'x'; new_string = "x`nx"; replace_all = $Flag }

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $reader

            [bool]$result.Stdout | Should -Be $Denied
        }

        It 'fails closed on an Edit that cannot be resolved (<Code>)' -ForEach @(
            @{ Code = 'not-found'; ToolInput = @{ file_path = 'scripts/large.ps1'; old_string = 'absent'; new_string = 'y'; replace_all = 3 } }
            @{ Code = 'ambiguous'; ToolInput = @{ file_path = 'scripts/large.ps1'; old_string = 'a'; new_string = 'y' } }
        ) {
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/scripts/large.ps1' = "a`na`n" }

            $result = Invoke-CodexFileSizeHook -PayloadRaw (ConvertTo-CodexFileSizePayload -ToolName 'Edit' -ToolInput $ToolInput) -Reader $reader

            $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -Match ([regex]::Escape("($Code)"))
        }

        It 'fails closed on an Edit to a covered file that <Label>' -ForEach @(
            @{ Label = 'cannot be read'; Files = @{ '/repo/scripts/large.ps1' = 'THROW' }; Marker = 'access denied' }
            @{ Label = 'does not exist'; Files = @{}; Marker = 'does not exist' }
        ) {
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Edit' -ToolInput @{ file_path = 'scripts/large.ps1'; old_string = 'a'; new_string = 'b' }

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader (Get-CodexFileSizeTestReader -Files $Files)

            $result.Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -Match $Marker
        }
    }

    Context 'apply_patch Update, rename, and Delete' {
        It 'denies an Update that grows an 810-line file to 815' {
            Mock Resolve-CodexUpdatedFileContent { Get-CodexFileSizeTestText -LineCount 815 }
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/scripts/large.ps1' = (Get-CodexFileSizeTestText -LineCount 810) }
            $payload = ConvertTo-CodexFileSizePatchPayload -Patch "*** Begin Patch`n*** Update File: scripts/large.ps1`n@@`n line 1`n+added`n*** End Patch"

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $reader

            $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -Match '815 logical lines'
            Should -Invoke Resolve-CodexUpdatedFileContent -Times 1 -Exactly -ParameterFilter { $SourcePath -eq 'scripts/large.ps1' }
        }

        It 'allows an Update that shrinks an 810-line file to 805' {
            Mock Resolve-CodexUpdatedFileContent { Get-CodexFileSizeTestText -LineCount 805 }
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/scripts/large.ps1' = (Get-CodexFileSizeTestText -LineCount 810) }
            $payload = ConvertTo-CodexFileSizePatchPayload -Patch "*** Begin Patch`n*** Update File: scripts/large.ps1`n@@`n-line 1`n*** End Patch"

            (Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $reader).Stdout | Should -BeNullOrEmpty
        }

        It 'allows an Update whose reconstructed size is at most 800 without reading the file' {
            Mock Resolve-CodexUpdatedFileContent { Get-CodexFileSizeTestText -LineCount 20 }
            $payload = ConvertTo-CodexFileSizePatchPayload -Patch "*** Begin Patch`n*** Update File: src/app.ts`n@@`n+x`n*** End Patch"

            (Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $script:ThrowingReader).Stdout | Should -BeNullOrEmpty
        }

        It 'denies an Update whose content cannot be reconstructed' {
            Mock Resolve-CodexUpdatedFileContent { '' }
            $payload = ConvertTo-CodexFileSizePatchPayload -Patch "*** Begin Patch`n*** Update File: src/app.ts`n@@`n+x`n*** End Patch"

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $script:ThrowingReader

            $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be reconstructed'
        }

        It 'evaluates a rename at the destination with the source size as the pre-edit size (<Label>)' -ForEach @(
            @{ Label = 'equal size allowed'; SourceLines = 900; Denied = $false }
            @{ Label = 'smaller source denied'; SourceLines = 850; Denied = $true }
        ) {
            Mock Resolve-CodexUpdatedFileContent { Get-CodexFileSizeTestText -LineCount 900 }
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/scripts/old.py' = (Get-CodexFileSizeTestText -LineCount $SourceLines) }
            $payload = ConvertTo-CodexFileSizePatchPayload -Patch "*** Begin Patch`n*** Update File: scripts/old.py`n*** Move to: scripts/new.py`n@@`n line 1`n*** End Patch"

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $reader

            [bool]$result.Stdout | Should -Be $Denied
            if ($Denied) { $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'scripts/new.py' }
        }

        It 'allows a Delete of a covered file without reading it' {
            $payload = ConvertTo-CodexFileSizePatchPayload -Patch "*** Begin Patch`n*** Delete File: scripts/large.ps1`n*** End Patch"

            (Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $script:ThrowingReader).Stdout | Should -BeNullOrEmpty
        }
    }

    Context 'non-covered and fail-closed handling' {
        It 'allows a <Label> of any size silently without reading' -ForEach @(
            @{ Label = 'Markdown Write'; ToolName = 'Write'; ToolInput = @{ file_path = 'README.md'; content = ("x`n" * 5000) } }
            @{ Label = 'JSON Edit'; ToolName = 'Edit'; ToolInput = @{ file_path = 'config/data.json'; old_string = 'a'; new_string = 'b' } }
            @{ Label = 'outside-root Write'; ToolName = 'Write'; ToolInput = @{ file_path = '/scratch/issue-990/tool.ps1'; content = ("x`n" * 5000) } }
            @{ Label = 'apply_patch with no file'; ToolName = 'apply_patch'; ToolInput = @{ command = 'noop' } }
        ) {
            $result = Invoke-CodexFileSizeHook -PayloadRaw (ConvertTo-CodexFileSizePayload -ToolName $ToolName -ToolInput $ToolInput) -Reader $script:ThrowingReader

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'exits 2 with a stderr message for <Label>' -ForEach @(
            @{ Label = 'empty stdin'; Raw = ''; Marker = 'empty' }
            @{ Label = 'malformed JSON'; Raw = '{not json'; Marker = 'malformed' }
            @{ Label = 'a missing tool_input'; Raw = '{"session_id":"s","tool_name":"Edit"}'; Marker = 'tool_input' }
        ) {
            $result = Invoke-CodexFileSizeHook -PayloadRaw $Raw -Reader $script:ThrowingReader

            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Match 'enforce-file-size-limit'
            $result.Stderr | Should -Match $Marker
        }

        It 'returns the dependency-failure decision before evaluating a record' {
            Mock Get-HookDependencyFailureDecision {
                [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = "$ReasonPrefix the dependency 'file-size-policy.ps1' failed to load" } }
            }
            Mock ConvertTo-FileSizeRelativePath { throw 'policy must not run' }
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Write' -ToolInput @{ file_path = 'README.md'; content = 'x' }

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $script:ThrowingReader

            $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'FILE_SIZE_LIMIT_BLOCKED:*file-size-policy.ps1*'
            Should -Invoke ConvertTo-FileSizeRelativePath -Times 0 -Exactly
        }

        It 'reads an absolute source path under the root at that path' {
            $reader = Get-CodexFileSizeTestReader -Files @{ '/repo/src/big.cs' = (Get-CodexFileSizeTestText -LineCount 900) }
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Write' -ToolInput @{ file_path = '/repo/src/big.cs'; content = (Get-CodexFileSizeTestText -LineCount 900) }

            (Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $reader).Stdout | Should -BeNullOrEmpty
        }

        It 'denies an Update when the reconstruction call yields no record for the patched path' {
            Mock ConvertTo-CodexFileEditInput { @() } -ParameterFilter { $ResolveUpdateContent }
            $payload = ConvertTo-CodexFileSizePatchPayload -Patch "*** Begin Patch`n*** Update File: src/app.ts`n@@`n+x`n*** End Patch"

            $result = Invoke-CodexFileSizeHook -PayloadRaw $payload -Reader $script:ThrowingReader

            $result.Decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'could not be reconstructed'
        }

        It 'defaults the repository root to the current location' {
            # Arrange: a Markdown record is not covered, so no file is read.
            $record = [pscustomobject]@{ file_path = 'README.md'; source_path = 'README.md'; operation = 'Write'; content = 'x' }

            # Act / Assert: both entry points run with their default root.
            Invoke-CodexFileSizeLimitDecision -Record $record -Payload ([pscustomobject]@{ tool_input = @{} }) | Should -BeNullOrEmpty
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Write' -ToolInput @{ file_path = 'README.md'; content = 'x' }
            Invoke-CodexFileSizeLimitEntryPoint -PayloadRaw $payload | Should -Be 0
        }

        It 'exits 0 and allows silently when the script runs in process' {
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Write' -ToolInput @{ file_path = 'README.md'; content = 'safe' }
            $originalIn = [Console]::In
            $originalOut = [Console]::Out
            $out = [System.IO.StringWriter]::new()
            try {
                [Console]::SetIn([System.IO.StringReader]::new($payload))
                [Console]::SetOut($out)
                & $script:HookPath
                $exitCode = $LASTEXITCODE
            } finally {
                [Console]::SetIn($originalIn)
                [Console]::SetOut($originalOut)
            }

            $exitCode | Should -Be 0
            $out.ToString() | Should -BeNullOrEmpty
        }

        It 'uses the default file reader when no seam is supplied' {
            $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
            $payload = ConvertTo-CodexFileSizePayload -ToolName 'Edit' -ToolInput @{ file_path = '.codex/hooks/enforce-file-size-limit.ps1'; old_string = 'function Invoke-CodexFileSizeLimitEntryPoint {'; new_string = 'function Invoke-CodexFileSizeLimitEntryPoint {' }
            $originalOut = [Console]::Out
            $out = [System.IO.StringWriter]::new()
            try {
                [Console]::SetOut($out)
                $exitCode = Invoke-CodexFileSizeLimitEntryPoint -PayloadRaw $payload -RepositoryRoot $repoRoot
            } finally {
                [Console]::SetOut($originalOut)
            }

            $exitCode | Should -Be 0
            $out.ToString() | Should -BeNullOrEmpty
        }
    }
}
