#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/Invoke-DocsCommand.ps1.

.DESCRIPTION
    The script is dot-sourced to load its functions. Covers the dispatch table and its anchors,
    argument parsing, exit codes 0/1/2/3, the -Json envelope (validated with the real Test-Json
    against the composed envelope schema; Test-Json is never mocked here), the text report, the
    real command context read-only against committed files with Write-DocsFileText mocked, the
    guarded top-level body run in process through the call operator with in-memory console
    writers, the InvokeProcess member with Invoke-DocsProcess mocked, and the two pure process
    functions with plain values. The -WhatIf tests run the real Write-DocsFileText and the real
    WriteText member under -WhatIf and assert that nothing is created. No test writes a file or
    starts a child.
#>

BeforeAll {
    $script:RepositoryRootPath = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:ScriptPath = Join-Path -Path $script:RepositoryRootPath -ChildPath '.claude/lib/docs/Invoke-DocsCommand.ps1'
    . $script:ScriptPath
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:Composed = (Get-DocsComposedSchemaSet -SchemaSet (Get-DocsTestSchemaText)).Schemas
    $script:ExampleProfile = (Get-DocsTestExampleText)['docs-profile']
    $script:ScriptText = Get-Content -LiteralPath $script:ScriptPath -Raw

    function Test-TestEnvelope {
        # Returns $true when the -Json stdout validates against the composed envelope schema.
        param([string] $Stdout)
        $findings = Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $Stdout -ComposedSchemaSet $script:Composed
        $schemaOk = [bool] (Test-Json -Json $Stdout -Schema $script:Composed['docs-command-envelope'].Text -ErrorAction SilentlyContinue)
        ($findings.Count -eq 0) -and $schemaOk
    }

    function ConvertFrom-TestEnvelope {
        param([string] $Stdout)
        (ConvertFrom-DocsJsonText -Text $Stdout).Value
    }

    function New-TestThrowingContext {
        # A context whose members fail the test if any of them is invoked.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test file; it changes no system state.')]
        param()
        $fail = { throw 'A context member was invoked.' }
        [pscustomobject]@{ RepositoryRoot = 'unused'; ReadText = $fail; ReadBytes = $fail; TestFile = $fail; ListFile = $fail; WriteText = $fail; UtcNow = $fail; InvokeProcess = $fail }
    }
}

AfterAll {
    Remove-Module -Name DocsProfileCommands, DocsProfile, DocsAnalyzerRegistry, DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Dispatch table' {
    It 'returns no finding for the committed table' {
        (Test-DocsCommandTable -Table (Get-DocsCommandTable)).Count | Should -Be 0
    }

    It 'rejects <Case>' -ForEach @(
        @{ Case = 'a duplicate name'; Pointer = '/1/Name'; Rows = { @([pscustomobject]@{ Name = 'a'; Function = 'Invoke-DocsACommand'; Option = @{} }, [pscustomobject]@{ Name = 'a'; Function = 'Invoke-DocsBCommand'; Option = @{} }) } }
        @{ Case = 'a reserved option name'; Pointer = '/0/Option/Json'; Rows = { @([pscustomobject]@{ Name = 'a'; Function = 'Invoke-DocsACommand'; Option = @{ Json = 'switch' } }) } }
        @{ Case = 'an option kind outside value, multi and switch'; Pointer = '/0/Option/Path'; Rows = { @([pscustomobject]@{ Name = 'a'; Function = 'Invoke-DocsACommand'; Option = @{ Path = 'list' } }) } }
        @{ Case = 'a function outside the grammar'; Pointer = '/0/Function'; Rows = { @([pscustomobject]@{ Name = 'a'; Function = 'Get-Thing'; Option = @{} }) } }
    ) {
        # Act
        $result = Test-DocsCommandTable -Table (& $Rows)

        # Assert
        @($result | Where-Object { $_.code -eq 'DOCS_CLI_TABLE_INVALID' -and $_.pointer -eq $Pointer }).Count | Should -Be 1
    }

    It 'carries the anchors 1020, 1021, 1022, 1023, 1024 and 1034 in order, with no placeholder or 1031 anchor' {
        # Arrange
        $anchors = @(
            '# --- 1020: init, validate-profile ---'
            '# --- 1021: check ---'
            '# --- 1022: inventory ---'
            '# --- 1023: coverage, update-ledger, validate ---'
            '# --- 1024: generate-reference ---'
            '# --- 1034: surface-delta ---'
        )
        $positions = @($anchors | ForEach-Object { $script:ScriptText.IndexOf($_, [System.StringComparison]::Ordinal) })

        # Assert
        $positions[0] | Should -BeGreaterThan 0
        for ($index = 1; $index -lt $positions.Count; $index++) { $positions[$index] | Should -BeGreaterThan $positions[$index - 1] }
        $lines = $script:ScriptText -split "`n"
        @($lines | Where-Object { $_ -match '# --- 900[0-9]{3}:' }).Count | Should -Be 0
        @($lines | Where-Object { $_ -match '# --- 1031:' }).Count | Should -Be 0
        $script:ScriptText.IndexOf("Name = 'init'", [System.StringComparison]::Ordinal) | Should -BeGreaterThan $positions[0]
        $script:ScriptText.IndexOf("Name = 'validate-profile'", [System.StringComparison]::Ordinal) | Should -BeLessThan $positions[1]
    }
}

Describe 'ConvertFrom-DocsCommandArgument' {
    It 'parses value, multi and switch options case-insensitively' {
        # Act
        $parsed = ConvertFrom-DocsCommandArgument -CommandArgument @('-profile', 'a.json', '-Tag', 'x', '-tag', 'y', '-Write') -OptionSpec @{ Profile = 'value'; Tag = 'multi'; Write = 'switch' }

        # Assert
        $parsed.Error | Should -BeNullOrEmpty
        $parsed.Argument['Profile'] | Should -BeExactly 'a.json'
        $parsed.Argument['Tag'] | Should -Be @('x', 'y')
        $parsed.Argument['Write'] | Should -BeTrue
    }

    It 'reports an unexpected positional argument' {
        (ConvertFrom-DocsCommandArgument -CommandArgument @('loose') -OptionSpec @{}).Error | Should -Match 'Unexpected argument'
    }
}

Describe 'Invoke-DocsCommandCli exit codes and output' {
    It 'exits 0 with no error finding for validate-profile on the example profile through the real context' {
        # Act
        $outcome = Invoke-DocsCommandCli -Command 'validate-profile' -CommandArgument @('-Profile', 'examples/docs/v1/docs-profile.example.json') -RepositoryRoot $script:RepositoryRootPath -Json
        $envelope = ConvertFrom-TestEnvelope -Stdout $outcome.Stdout

        # Assert
        $outcome.ExitCode | Should -Be 0
        @($envelope['findings'] | Where-Object { $_['severity'] -eq 'error' }).Count | Should -Be 0
        $envelope['command'] | Should -BeExactly 'validate-profile'
        Test-TestEnvelope -Stdout $outcome.Stdout | Should -BeTrue
    }

    It 'exits 1 for an invalid profile through an in-memory context' {
        # Arrange
        $test = New-DocsTestContext -File @{ 'p.json' = '{"id":"a"}' }

        # Act
        $outcome = Invoke-DocsCommandCli -Command 'validate-profile' -CommandArgument @('-Profile', 'p.json') -Context $test.Context -Json

        # Assert
        $outcome.ExitCode | Should -Be 1
        (ConvertFrom-TestEnvelope -Stdout $outcome.Stdout)['ok'] | Should -BeFalse
        Test-TestEnvelope -Stdout $outcome.Stdout | Should -BeTrue
    }

    It 'exits 2 with exactly one DOCS_CLI_ARGUMENTS and result null for <Case>' -ForEach @(
        @{ Case = 'a missing -Command'; Name = $null; Arguments = @(); CommandIsNull = $true }
        @{ Case = 'an unknown command'; Name = 'no-such-command'; Arguments = @(); CommandIsNull = $true }
        @{ Case = 'an unknown option'; Name = 'validate-profile'; Arguments = @('-Bogus', 'x'); CommandIsNull = $false }
        @{ Case = 'a missing value'; Name = 'validate-profile'; Arguments = @('-Profile'); CommandIsNull = $false }
        @{ Case = 'a repeated non-multi option'; Name = 'validate-profile'; Arguments = @('-Profile', 'a.json', '-Profile', 'b.json'); CommandIsNull = $false }
        @{ Case = 'a non-relative path'; Name = 'validate-profile'; Arguments = @('-Profile', '/abs/p.json'); CommandIsNull = $false }
    ) {
        # Act
        $outcome = Invoke-DocsCommandCli -Command $Name -CommandArgument $Arguments -Context (New-DocsTestContext).Context -Json
        $envelope = ConvertFrom-TestEnvelope -Stdout $outcome.Stdout

        # Assert
        $outcome.ExitCode | Should -Be 2
        @($envelope['findings']).Count | Should -Be 1
        $envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_CLI_ARGUMENTS'
        $envelope['result'] | Should -BeNullOrEmpty
        ($null -eq $envelope['command']) | Should -Be $CommandIsNull
        $outcome.Stderr | Should -BeExactly ''
        Test-TestEnvelope -Stdout $outcome.Stdout | Should -BeTrue
    }

    It 'exits 3 with exactly one DOCS_RUNTIME_UNSUPPORTED and one stderr line below PowerShell 7.4' {
        # Act
        $outcome = Invoke-DocsCommandCli -Command 'validate-profile' -Context (New-TestThrowingContext) -PowerShellVersion ([version] '7.3') -Json
        $envelope = ConvertFrom-TestEnvelope -Stdout $outcome.Stdout

        # Assert
        $outcome.ExitCode | Should -Be 3
        @($envelope['findings']).Count | Should -Be 1
        $envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_RUNTIME_UNSUPPORTED'
        @($outcome.Stderr.TrimEnd("`n") -split "`n").Count | Should -Be 1
        Test-TestEnvelope -Stdout $outcome.Stdout | Should -BeTrue
    }

    It 'exits 3 with exactly one DOCS_CLI_RUNTIME and one stderr line when the command function throws' {
        # Act
        $outcome = Invoke-DocsCommandCli -Command 'validate-profile' -Context (New-DocsTestContext).Context -CommandFunction { throw 'injected failure' } -Json
        $envelope = ConvertFrom-TestEnvelope -Stdout $outcome.Stdout

        # Assert
        $outcome.ExitCode | Should -Be 3
        @($envelope['findings']).Count | Should -Be 1
        $envelope['findings'][0]['code'] | Should -BeExactly 'DOCS_CLI_RUNTIME'
        $envelope['result'] | Should -BeNullOrEmpty
        @($outcome.Stderr.TrimEnd("`n") -split "`n").Count | Should -Be 1
        Test-TestEnvelope -Stdout $outcome.Stdout | Should -BeTrue
    }

    It 'exits 0 for -Help and reads nothing; with -Json the envelope has no findings and result usage' {
        # Act
        $text = Invoke-DocsCommandCli -Help -Context (New-TestThrowingContext)
        $json = Invoke-DocsCommandCli -Help -Json -Context (New-TestThrowingContext)
        $envelope = ConvertFrom-TestEnvelope -Stdout $json.Stdout

        # Assert
        $text.ExitCode | Should -Be 0
        $text.Stdout | Should -Match 'validate-profile'
        $json.ExitCode | Should -Be 0
        @($envelope['findings']).Count | Should -Be 0
        @($envelope['result']['usage']).Count | Should -BeGreaterThan 1
        $envelope['command'] | Should -BeNullOrEmpty
        Test-TestEnvelope -Stdout $json.Stdout | Should -BeTrue
    }

    It 'writes one envelope with exactly the five keys and identical bytes for identical inputs' {
        # Arrange
        $first = New-DocsTestContext -File @{ 'p.json' = $script:ExampleProfile }
        $second = New-DocsTestContext -File @{ 'p.json' = $script:ExampleProfile }

        # Act
        $one = Invoke-DocsCommandCli -Command 'validate-profile' -CommandArgument @('-Profile', 'p.json') -Context $first.Context -Json
        $two = Invoke-DocsCommandCli -Command 'validate-profile' -CommandArgument @('-Profile', 'p.json') -Context $second.Context -Json

        # Assert
        @((ConvertFrom-TestEnvelope -Stdout $one.Stdout).Keys | Sort-Object) | Should -Be @('command', 'exit_code', 'findings', 'ok', 'result')
        ($one.Stdout.TrimEnd("`n") -split "`n").Count | Should -Be 1
        $two.Stdout | Should -BeExactly $one.Stdout
    }

    It 'ends the text report with the summary line without -Json' {
        # Act
        $outcome = Invoke-DocsCommandCli -Command 'validate-profile' -CommandArgument @('-Profile', 'missing.json') -Context (New-DocsTestContext).Context

        # Assert
        $outcome.ExitCode | Should -Be 1
        @($outcome.Stdout.TrimEnd("`n") -split "`n")[-1] | Should -Match '^validate-profile: exit=1 errors=1 warnings=0 infos=0$'
    }
}

Describe 'New-DocsCommandContext (read-only against committed files)' {
    BeforeAll {
        $script:RealContext = New-DocsCommandContext -RepositoryRoot $script:RepositoryRootPath
        $script:ExampleRelative = 'examples/docs/v1/docs-profile.example.json'
    }

    It 'reads text through ConvertFrom-DocsUtf8Bytes and bytes unchanged' {
        # Arrange
        $bytes = [System.IO.File]::ReadAllBytes((Join-Path -Path $script:RepositoryRootPath -ChildPath $script:ExampleRelative))

        # Act
        $text = & $script:RealContext.ReadText $script:ExampleRelative
        $readBytes = & $script:RealContext.ReadBytes $script:ExampleRelative

        # Assert
        $text | Should -BeExactly (ConvertFrom-DocsUtf8Bytes -Bytes $bytes)
        $readBytes.Length | Should -Be $bytes.Length
    }

    It 'throws an item-not-found error for an absent path' {
        { & $script:RealContext.ReadText 'examples/docs/v1/absent.json' } | Should -Throw -ExceptionType ([System.Management.Automation.ItemNotFoundException])
    }

    It 'tests existence and lists files sorted' {
        # Act
        $listed = & $script:RealContext.ListFile 'examples/docs/v1'

        # Assert
        & $script:RealContext.TestFile $script:ExampleRelative | Should -BeTrue
        & $script:RealContext.TestFile 'examples/docs/v1/absent.json' | Should -BeFalse
        @($listed | Where-Object { $_ -like '*docs-profile.example.json' }).Count | Should -Be 1
        [string[]] $sorted = @($listed)
        [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
        $listed | Should -Be $sorted
        $absent = & $script:RealContext.ListFile 'examples/docs/absent-directory'
        $absent.Count | Should -Be 0
    }

    It 'returns a UTC DateTime from UtcNow' {
        $now = & $script:RealContext.UtcNow
        $now | Should -BeOfType ([datetime])
        $now.Kind | Should -Be ([System.DateTimeKind]::Utc)
    }

    It 'rejects a non-relative path in <_>' -ForEach @('ReadText', 'ReadBytes', 'TestFile', 'ListFile') {
        { & $script:RealContext.$_ '/abs/path' } | Should -Throw -ExpectedMessage '*DOCS_CONTEXT_PATH_INVALID*'
    }

    It 'forwards the full path, text and mode of WriteText to Write-DocsFileText once' {
        # Arrange
        Mock -CommandName Write-DocsFileText -MockWith { }

        # Act
        & $script:RealContext.WriteText 'docs/new.md' 'body' 'create'

        # Assert
        $expected = Join-Path -Path $script:RepositoryRootPath -ChildPath 'docs/new.md'
        Should -Invoke -CommandName Write-DocsFileText -Times 1 -Exactly -ParameterFilter { $FullPath -eq $expected -and $Text -ceq 'body' -and $Mode -ceq 'create' }
    }

    It 'rejects a non-relative WriteText path without calling Write-DocsFileText' {
        # Arrange
        Mock -CommandName Write-DocsFileText -MockWith { }

        # Act and Assert
        { & $script:RealContext.WriteText '/abs/new.md' 'body' 'create' } | Should -Throw -ExpectedMessage '*DOCS_CONTEXT_PATH_INVALID*'
        Should -Invoke -CommandName Write-DocsFileText -Times 0 -Exactly
    }
}

Describe 'Write-DocsFileText and the WriteText member under -WhatIf' {
    BeforeAll {
        $script:WhatIfContext = New-DocsCommandContext -RepositoryRoot $script:RepositoryRootPath
        $script:WhatIfRelativeDirectory = 'artifacts/docs-whatif-never-created'
    }

    It 'creates neither the file nor its directory when Write-DocsFileText runs with -WhatIf' {
        # Arrange
        $directory = Join-Path -Path $script:RepositoryRootPath -ChildPath "$script:WhatIfRelativeDirectory/direct"
        $path = Join-Path -Path $directory -ChildPath 'never.md'

        # Act
        Write-DocsFileText -FullPath $path -Text 'body' -Mode 'create' -WhatIf

        # Assert
        [System.IO.File]::Exists($path) | Should -BeFalse -Because 'the ShouldProcess gate returns before the stream write'
        [System.IO.Directory]::Exists($directory) | Should -BeFalse -Because 'the ShouldProcess gate returns before the directory creation'
        [System.IO.Directory]::Exists((Join-Path -Path $script:RepositoryRootPath -ChildPath $script:WhatIfRelativeDirectory)) | Should -BeFalse
    }

    It 'writes nothing and throws nothing when the real WriteText member runs under a true WhatIfPreference' {
        # Arrange
        $relative = "$script:WhatIfRelativeDirectory/member/never.md"
        $target = Join-Path -Path $script:RepositoryRootPath -ChildPath $relative
        $writeText = $script:WhatIfContext.WriteText

        # Act and Assert
        { $WhatIfPreference = $true; & $writeText $relative 'body' 'create' } | Should -Not -Throw
        [System.IO.File]::Exists($target) | Should -BeFalse -Because 'the inherited WhatIfPreference reaches the ShouldProcess gate of Write-DocsFileText'
        [System.IO.Directory]::Exists((Split-Path -Path $target -Parent)) | Should -BeFalse
    }
}

Describe 'Guarded top-level body' {
    It 'writes usage and sets exit code 0 for -Help, and exit code 2 with an empty stderr without -Command' {
        # Arrange
        $originalOut = [Console]::Out
        $originalError = [Console]::Error
        $helpOut = [System.IO.StringWriter]::new()
        $helpError = [System.IO.StringWriter]::new()
        $missingOut = [System.IO.StringWriter]::new()
        $missingError = [System.IO.StringWriter]::new()

        # Act
        try {
            [Console]::SetOut($helpOut); [Console]::SetError($helpError)
            $global:LASTEXITCODE = 99
            & $script:ScriptPath -Help -RepositoryRoot $script:RepositoryRootPath
            $helpExit = $global:LASTEXITCODE
            [Console]::SetOut($missingOut); [Console]::SetError($missingError)
            $global:LASTEXITCODE = 99
            & $script:ScriptPath
            $missingExit = $global:LASTEXITCODE
        } finally {
            [Console]::SetOut($originalOut)
            [Console]::SetError($originalError)
        }

        # Assert
        $helpExit | Should -Be 0
        $helpOut.ToString() | Should -Match 'Usage: Invoke-DocsCommand\.ps1'
        $missingExit | Should -Be 2
        $missingOut.ToString() | Should -Match 'exit=2'
        $missingError.ToString() | Should -BeExactly ''
    }
}

Describe 'InvokeProcess member and process functions' {
    It 'exposes the same member names as the in-memory context and the four InvokeProcess parameters' {
        # Arrange
        $real = New-DocsCommandContext -RepositoryRoot $script:RepositoryRootPath
        $fake = (New-DocsTestContext).Context

        # Act
        $realNames = @($real.PSObject.Properties | ForEach-Object { $_.Name })
        $fakeNames = @($fake.PSObject.Properties | ForEach-Object { $_.Name })
        $parameterNames = @($real.InvokeProcess.Ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })

        # Assert
        $realNames | Should -Be $fakeNames
        $real.InvokeProcess | Should -BeOfType ([scriptblock])
        $parameterNames | Should -Be @('FilePath', 'ArgumentList', 'StdinText', 'TimeoutSeconds')
    }

    It 'forwards the four arguments unchanged to Invoke-DocsProcess and returns its result' {
        # Arrange
        Mock -CommandName Invoke-DocsProcess -MockWith { @{ ExitCode = 7; Stdout = 'out'; Stderr = 'err'; TimedOut = $false } }
        $real = New-DocsCommandContext -RepositoryRoot $script:RepositoryRootPath

        # Act
        $result = & $real.InvokeProcess 'issue-1020-tool' @('first', 'second') 'stdin text' 5

        # Assert
        $result.ExitCode | Should -Be 7
        $result.Stdout | Should -BeExactly 'out'
        $result.Stderr | Should -BeExactly 'err'
        $result.TimedOut | Should -BeFalse
        Should -Invoke -CommandName Invoke-DocsProcess -Times 1 -Exactly -ParameterFilter {
            $FilePath -ceq 'issue-1020-tool' -and (@($ArgumentList) -join '|') -ceq 'first|second' -and $StdinText -ceq 'stdin text' -and $TimeoutSeconds -eq 5
        }
    }

    It 'throws DOCS_PROCESS_ARGUMENT_INVALID naming <Name> for <Case>' -ForEach @(
        @{ Case = 'a blank FilePath'; Name = 'FilePath'; Values = @{ FilePath = ' '; ArgumentList = @(); StdinText = ''; TimeoutSeconds = 1 } }
        @{ Case = 'a null argument item'; Name = 'ArgumentList'; Values = @{ FilePath = 't'; ArgumentList = @('a', $null); StdinText = ''; TimeoutSeconds = 1 } }
        @{ Case = 'a non-string StdinText'; Name = 'StdinText'; Values = @{ FilePath = 't'; ArgumentList = @(); StdinText = 5; TimeoutSeconds = 1 } }
        @{ Case = 'TimeoutSeconds 0'; Name = 'TimeoutSeconds'; Values = @{ FilePath = 't'; ArgumentList = @(); StdinText = ''; TimeoutSeconds = 0 } }
        @{ Case = 'TimeoutSeconds -1'; Name = 'TimeoutSeconds'; Values = @{ FilePath = 't'; ArgumentList = @(); StdinText = ''; TimeoutSeconds = -1 } }
        @{ Case = 'TimeoutSeconds null'; Name = 'TimeoutSeconds'; Values = @{ FilePath = 't'; ArgumentList = @(); StdinText = ''; TimeoutSeconds = $null } }
        @{ Case = 'TimeoutSeconds abc'; Name = 'TimeoutSeconds'; Values = @{ FilePath = 't'; ArgumentList = @(); StdinText = ''; TimeoutSeconds = 'abc' } }
    ) {
        { ConvertTo-DocsProcessRequest @Values } | Should -Throw -ExpectedMessage "*DOCS_PROCESS_ARGUMENT_INVALID*$Name*"
    }

    It 'converts timeouts to whole milliseconds and defaults null arguments and stdin' {
        # Act
        $one = ConvertTo-DocsProcessRequest -FilePath 't' -ArgumentList $null -StdinText $null -TimeoutSeconds 1
        $fraction = ConvertTo-DocsProcessRequest -FilePath 't' -ArgumentList @('a') -StdinText 'x' -TimeoutSeconds 1.5

        # Assert
        $one.TimeoutMilliseconds | Should -Be 1000
        $one.ArgumentList.Count | Should -Be 0
        $one.StdinText | Should -BeExactly ''
        $fraction.TimeoutMilliseconds | Should -Be 1500
        $fraction.ArgumentList | Should -Be @('a')
    }

    It 'shapes exited, timed-out and not-started results with plain values' {
        # Act
        $exited = ConvertTo-DocsProcessResult -FilePath 't' -Started $true -Exited $true -ExitCode 4 -Stdout 'o' -Stderr 'e'
        $nullStreams = ConvertTo-DocsProcessResult -FilePath 't' -Started $true -Exited $true -ExitCode 0 -Stdout $null -Stderr $null
        $timedOut = ConvertTo-DocsProcessResult -FilePath 't' -Started $true -Exited $false

        # Assert
        $exited.ExitCode | Should -Be 4
        $exited.ExitCode | Should -BeOfType ([int])
        $exited.Stdout | Should -BeExactly 'o'
        $exited.Stderr | Should -BeExactly 'e'
        $exited.TimedOut | Should -BeFalse
        $nullStreams.Stdout | Should -BeExactly ''
        $nullStreams.Stderr | Should -BeExactly ''
        $timedOut.ExitCode | Should -BeNullOrEmpty
        $timedOut.TimedOut | Should -BeTrue
        { ConvertTo-DocsProcessResult -FilePath 'issue-1020-tool' -Started $false -Exited $false -StartError 'not found' } | Should -Throw -ExpectedMessage '*DOCS_PROCESS_START_FAILED*issue-1020-tool*not found*'
    }

    It 'records two fake calls with their four arguments in order' {
        # Arrange
        $test = New-DocsTestContext -ProcessResult @{ ExitCode = 3; Stdout = 'x' }

        # Act
        $first = & $test.Context.InvokeProcess 'tool-a' @('1') 'in-a' 2
        [void](& $test.Context.InvokeProcess 'tool-b' @('2', '3') 'in-b' 4)

        # Assert
        $first.ExitCode | Should -Be 3
        $first.Stdout | Should -BeExactly 'x'
        $first.Stderr | Should -BeExactly ''
        $test.ProcessCallLog.Count | Should -Be 2
        $test.ProcessCallLog[0].FilePath | Should -BeExactly 'tool-a'
        $test.ProcessCallLog[1].FilePath | Should -BeExactly 'tool-b'
        @($test.ProcessCallLog[1].ArgumentList) | Should -Be @('2', '3')
        $test.ProcessCallLog[1].StdinText | Should -BeExactly 'in-b'
        $test.ProcessCallLog[1].TimeoutSeconds | Should -Be 4
    }
}
