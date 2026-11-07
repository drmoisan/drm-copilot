#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the ResolveRevision and ReadRevisionText members of New-DocsCommandContext
    in .claude/lib/docs/Invoke-DocsCommand.ps1 (issue #1034).

.DESCRIPTION
    The script is dot-sourced to load its functions. The private operations
    Resolve-DocsContextRevision and Read-DocsContextRevisionText are driven with a recording
    stand-in scriptblock passed as InvokeProcess, and the two members are driven with injected
    -InvokeProcess and -Operation stand-ins and with Invoke-DocsProcess mocked. No test starts a
    process, runs git, or writes a file.
#>

BeforeAll {
    $script:RepositoryRootPath = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    . (Join-Path -Path $script:RepositoryRootPath -ChildPath '.claude/lib/docs/Invoke-DocsCommand.ps1')

    $script:Revision = '0123456789abcdef0123456789abcdef01234567'

    function Get-TestRecordingProcess {
        # Returns @{ Calls; Process } where Process records each call and returns Result.
        param([hashtable] $Result = @{ ExitCode = 0; Stdout = ''; Stderr = ''; TimedOut = $false }, [string] $Throw)
        $calls = [System.Collections.Generic.List[object]]::new()
        $value = $Result
        $message = $Throw
        $process = {
            param($FilePath, $ArgumentList, $StdinText, $TimeoutSeconds)
            $calls.Add([pscustomobject]@{ FilePath = $FilePath; ArgumentList = [string[]] $ArgumentList; StdinText = $StdinText; TimeoutSeconds = $TimeoutSeconds })
            if ($message) { throw $message }
            return $value
        }.GetNewClosure()
        return @{ Calls = $calls; Process = $process }
    }
}

AfterAll {
    Remove-Module -Name DocsSchema, DocsSchemaWalk, DocsSurface, DocsFinding, DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
}

Describe 'Resolve-DocsContextRevision' {
    It 'returns the trimmed full revision and makes one bounded git call with the six-element argv' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = 0; Stdout = "$($script:Revision)`n"; Stderr = ''; TimedOut = $false }

        # Act
        $result = Resolve-DocsContextRevision 'root-dir' 'main' $recorder.Process

        # Assert
        $result | Should -BeExactly $script:Revision
        $recorder.Calls.Count | Should -Be 1
        $recorder.Calls[0].FilePath | Should -BeExactly 'git'
        $recorder.Calls[0].ArgumentList | Should -Be @('-C', 'root-dir', 'rev-parse', '--verify', '--end-of-options', 'main^{commit}')
        $recorder.Calls[0].StdinText | Should -BeExactly ''
        $recorder.Calls[0].TimeoutSeconds | Should -Be 30
    }

    It 'returns $null when git exits non-zero' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = 128; Stdout = ''; Stderr = 'fatal'; TimedOut = $false }

        # Act and Assert
        Resolve-DocsContextRevision 'root-dir' 'missing-ref' $recorder.Process | Should -BeNullOrEmpty
    }

    It 'throws DOCS_CONTEXT_REF_INVALID for a <Case> ref with no process call' -ForEach @(
        @{ Case = 'null'; Ref = $null }
        @{ Case = 'empty'; Ref = '' }
        @{ Case = 'blank'; Ref = '   ' }
    ) {
        # Arrange
        $recorder = Get-TestRecordingProcess

        # Act and Assert
        { Resolve-DocsContextRevision 'root-dir' $Ref $recorder.Process } | Should -Throw 'DOCS_CONTEXT_REF_INVALID*'
        $recorder.Calls.Count | Should -Be 0
    }

    It 'throws DOCS_CONTEXT_PROCESS_OUTPUT_INVALID when exit 0 prints no full revision' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = 0; Stdout = 'not-a-revision'; Stderr = ''; TimedOut = $false }

        # Act and Assert
        { Resolve-DocsContextRevision 'root-dir' 'main' $recorder.Process } | Should -Throw 'DOCS_CONTEXT_PROCESS_OUTPUT_INVALID*'
    }

    It 'throws DOCS_CONTEXT_PROCESS_TIMEOUT naming git and the timeout' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = $null; Stdout = ''; Stderr = ''; TimedOut = $true }

        # Act and Assert
        { Resolve-DocsContextRevision 'root-dir' 'main' $recorder.Process } | Should -Throw "DOCS_CONTEXT_PROCESS_TIMEOUT: the process 'git' did not exit within 30 seconds."
    }

    It 'propagates a DOCS_PROCESS_START_FAILED error unchanged' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Throw "DOCS_PROCESS_START_FAILED: the process 'git' could not be started: not found"

        # Act and Assert
        { Resolve-DocsContextRevision 'root-dir' 'main' $recorder.Process } | Should -Throw "DOCS_PROCESS_START_FAILED: the process 'git' could not be started: not found"
    }
}

Describe 'Read-DocsContextRevisionText' {
    It 'returns stdout without its leading BOM and records argv ending in show and the revision-qualified path' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = 0; Stdout = ([string][char]0xFEFF) + '{"a":1}'; Stderr = ''; TimedOut = $false }

        # Act
        $result = Read-DocsContextRevisionText 'root-dir' $script:Revision 'docs/a.json' $recorder.Process

        # Assert
        $result | Should -BeExactly '{"a":1}'
        $recorder.Calls.Count | Should -Be 1
        $recorder.Calls[0].FilePath | Should -BeExactly 'git'
        $recorder.Calls[0].ArgumentList | Should -Be @('-C', 'root-dir', 'show', "$($script:Revision):docs/a.json")
        $recorder.Calls[0].StdinText | Should -BeExactly ''
        $recorder.Calls[0].TimeoutSeconds | Should -Be 30
    }

    It 'returns stdout unchanged when it has no BOM' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = 0; Stdout = 'plain'; Stderr = ''; TimedOut = $false }

        # Act and Assert
        Read-DocsContextRevisionText 'root-dir' $script:Revision 'docs/a.json' $recorder.Process | Should -BeExactly 'plain'
    }

    It 'returns $null when the path is absent at the revision (non-zero exit)' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = 128; Stdout = ''; Stderr = 'fatal: path does not exist'; TimedOut = $false }

        # Act and Assert
        Read-DocsContextRevisionText 'root-dir' $script:Revision 'docs/a.json' $recorder.Process | Should -BeNullOrEmpty
    }

    It 'throws DOCS_CONTEXT_PATH_INVALID for the path <Case> with no process call' -ForEach @(
        @{ Case = '/abs/a.json'; Path = '/abs/a.json' }
        @{ Case = '../a.json'; Path = '../a.json' }
        @{ Case = 'null'; Path = $null }
    ) {
        # Arrange
        $recorder = Get-TestRecordingProcess

        # Act and Assert
        { Read-DocsContextRevisionText 'root-dir' $script:Revision $Path $recorder.Process } | Should -Throw 'DOCS_CONTEXT_PATH_INVALID*'
        $recorder.Calls.Count | Should -Be 0
    }

    It 'throws DOCS_CONTEXT_REVISION_INVALID for the revision <Case> with no process call' -ForEach @(
        @{ Case = 'main'; Revision = 'main' }
        @{ Case = 'uppercase hex'; Revision = '0123456789ABCDEF0123456789ABCDEF01234567' }
    ) {
        # Arrange
        $recorder = Get-TestRecordingProcess

        # Act and Assert
        { Read-DocsContextRevisionText 'root-dir' $Revision 'docs/a.json' $recorder.Process } | Should -Throw 'DOCS_CONTEXT_REVISION_INVALID*'
        $recorder.Calls.Count | Should -Be 0
    }

    It 'throws DOCS_CONTEXT_PROCESS_TIMEOUT for a timed-out read' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = $null; Stdout = ''; Stderr = ''; TimedOut = $true }

        # Act and Assert
        { Read-DocsContextRevisionText 'root-dir' $script:Revision 'docs/a.json' $recorder.Process } | Should -Throw 'DOCS_CONTEXT_PROCESS_TIMEOUT*'
    }
}

Describe 'New-DocsCommandContext revision members' {
    BeforeAll {
        $script:Context = New-DocsCommandContext -RepositoryRoot $script:RepositoryRootPath
    }

    It 'exposes ResolveRevision and ReadRevisionText as script blocks with their leading parameters' {
        # Act
        $resolveNames = @($script:Context.ResolveRevision.Ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })
        $readNames = @($script:Context.ReadRevisionText.Ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })

        # Assert
        $script:Context.ResolveRevision | Should -BeOfType ([scriptblock])
        $script:Context.ReadRevisionText | Should -BeOfType ([scriptblock])
        $resolveNames[0] | Should -BeExactly 'Ref'
        $readNames[0..1] | Should -Be @('Revision', 'RelativePath')
    }

    It 'ResolveRevision runs the injected InvokeProcess with the context root after -C' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = 0; Stdout = $script:Revision; Stderr = ''; TimedOut = $false }

        # Act
        $result = & $script:Context.ResolveRevision 'main' -InvokeProcess $recorder.Process

        # Assert
        $result | Should -BeExactly $script:Revision
        $recorder.Calls[0].ArgumentList[1] | Should -BeExactly $script:Context.RepositoryRoot
    }

    It 'ReadRevisionText runs the injected InvokeProcess with the context root after -C' {
        # Arrange
        $recorder = Get-TestRecordingProcess -Result @{ ExitCode = 0; Stdout = 'text'; Stderr = ''; TimedOut = $false }

        # Act
        $result = & $script:Context.ReadRevisionText $script:Revision 'docs/a.json' -InvokeProcess $recorder.Process

        # Assert
        $result | Should -BeExactly 'text'
        $recorder.Calls[0].ArgumentList[1] | Should -BeExactly $script:Context.RepositoryRoot
    }

    It 'passes the root and its arguments to an injected Operation' {
        # Act
        $resolved = & $script:Context.ResolveRevision 'main' -Operation { param($Root, $Ref, $InvokeProcess) "$Root|$Ref|$($null -ne $InvokeProcess)" }
        $read = & $script:Context.ReadRevisionText $script:Revision 'docs/a.json' -Operation { param($Root, $Revision, $RelativePath, $InvokeProcess) "$Root|$Revision|$RelativePath|$($null -ne $InvokeProcess)" }

        # Assert
        $resolved | Should -BeExactly "$($script:Context.RepositoryRoot)|main|True"
        $read | Should -BeExactly "$($script:Context.RepositoryRoot)|$($script:Revision)|docs/a.json|True"
    }

    It 'routes the default wiring of <Member> through Invoke-DocsProcess once with git and a 30-second wait' -ForEach @(
        @{ Member = 'ResolveRevision' }
        @{ Member = 'ReadRevisionText' }
    ) {
        # Arrange
        Mock -CommandName Invoke-DocsProcess -MockWith { @{ ExitCode = 0; Stdout = '0123456789abcdef0123456789abcdef01234567'; Stderr = ''; TimedOut = $false } }
        $context = New-DocsCommandContext -RepositoryRoot $script:RepositoryRootPath

        # Act
        if ($Member -eq 'ResolveRevision') { $null = & $context.ResolveRevision 'main' } else { $null = & $context.ReadRevisionText $script:Revision 'docs/a.json' }

        # Assert
        Should -Invoke -CommandName Invoke-DocsProcess -Times 1 -Exactly -ParameterFilter { $FilePath -ceq 'git' -and $TimeoutSeconds -eq 30 }
    }
}
