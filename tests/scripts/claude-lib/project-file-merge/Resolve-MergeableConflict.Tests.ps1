<#
.SYNOPSIS
    Behavioral tests for the project-file conflict entry script (issue #643).

.DESCRIPTION
    Covers Invoke-MergeableConflictResolution against mocked seams: the resolved
    path with its reported entries, the all-or-nothing refusal of a conflict set
    containing a non-mergeable path, the never-drop refusal, the shared
    blast-radius classification of a root-level packages.config, the absence of
    any staging or revision-creating git call, and the published result shape.

    A second block exercises the two byte-level seams for real against committed
    fixtures, with no mock registered, so the reader and the writer are covered
    by something other than a stub. git is never executed: Invoke-GitExe is the
    single executable seam and it is mocked, per .claude/rules/powershell.md. No
    test writes a file; the one Write-MergedFile call runs under -WhatIf.
#>

BeforeAll {
    # Resolve the repository root four levels up: project-file-merge ->
    # claude-lib -> scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:ScriptPath = (Resolve-Path (Join-Path $script:RepoRoot '.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1')).Path
    $script:FixtureRoot = (Resolve-Path (Join-Path $script:RepoRoot 'tests/fixtures/project_file_merge')).Path
    $script:ConfigPath = (Resolve-Path (Join-Path $script:RepoRoot 'config/blast-radius.json')).Path

    # The guarded entry-point body does not run under dot-sourcing, so this loads
    # the functions without executing the step.
    . $script:ScriptPath

    # Split a fixture so each line keeps its own terminator, matching what the
    # real Read-ConflictedFile hands the merge.
    function Get-FixtureLine {
        param([Parameter(Mandatory = $true)][string] $Name)

        $text = Get-Content -LiteralPath (Join-Path $script:FixtureRoot $Name) -Raw
        $line = [System.Collections.Generic.List[string]]::new()
        foreach ($match in [regex]::Matches($text, '[^\r\n]*(?:\r\n|\n|\r)')) { $line.Add($match.Value) }
        $consumed = ($line -join '').Length
        if ($consumed -lt $text.Length) { $line.Add($text.Substring($consumed)) }
        return , $line.ToArray()
    }

    # git prints stage text without terminators, so the stage stubs match that.
    function Get-StageLine {
        param([Parameter(Mandatory = $true)][string] $Name)

        return , @(Get-Content -LiteralPath (Join-Path $script:FixtureRoot $Name))
    }
}

Describe 'Invoke-MergeableConflictResolution' {
    BeforeAll {
        # Default scenario: one conflicted csproj whose stage texts agree with it.
        $script:ConflictedPath = @('Proj/Proj.csproj')
        $script:ConflictedLine = Get-FixtureLine -Name 'script-resolved.conflicted.csproj'
        $script:StageOurs = Get-StageLine -Name 'script-resolved.ours.csproj'
        $script:StageTheirs = Get-StageLine -Name 'script-resolved.theirs.csproj'
        $script:StageBase = Get-StageLine -Name 'script-resolved.base.csproj'

        # The single executable seam. Branching on the argument shape keeps the
        # stub honest about which call the code under test actually made.
        Mock Invoke-GitExe {
            param([string[]] $GitArgs)

            if ($GitArgs -contains '--diff-filter=U') { return , $script:ConflictedPath }
            $spec = $GitArgs[$GitArgs.Count - 1]
            if ($spec.StartsWith(':2:')) { return , $script:StageOurs }
            if ($spec.StartsWith(':3:')) { return , $script:StageTheirs }
            return , $script:StageBase
        }

        # A no-op sink. No assertion inspects the arguments, so the mock declares
        # no parameters and Pester binds the call through the real command's metadata.
        Mock Write-MergedFile { }

        # The stub answers with the scenario's lines whatever path it is handed,
        # so it declares no parameters.
        Mock Read-ConflictedFile {
            return [pscustomobject]@{ Bytes = [byte[]] @(); HasBom = $false; Line = $script:ConflictedLine }
        }
    }

    BeforeEach {
        # Restore the default scenario so each It states only its own changes.
        $script:ConflictedPath = @('Proj/Proj.csproj')
        $script:ConflictedLine = Get-FixtureLine -Name 'script-resolved.conflicted.csproj'
        $script:StageOurs = Get-StageLine -Name 'script-resolved.ours.csproj'
        $script:StageTheirs = Get-StageLine -Name 'script-resolved.theirs.csproj'
        $script:StageBase = Get-StageLine -Name 'script-resolved.base.csproj'
    }

    It 'resolves a csproj-only conflict set and reports the added entries' {
        # Arrange: the default single-csproj scenario.

        # Act: resolve the worktree against the committed truth table.
        $result = Invoke-MergeableConflictResolution -Worktree $script:RepoRoot -ConfigPath $script:ConfigPath

        # Assert: the verdict, the path, and the entries the caller cites in its
        # resolution message.
        $result.result | Should -Be 'resolved'
        $result.resolved.Count | Should -Be 1
        $result.resolved[0].path | Should -Be 'Proj/Proj.csproj'
        $result.resolved[0].entries_added_from_ours | Should -Be @('Compile:Ours/OursA.cs')
        $result.resolved[0].entries_added_from_theirs | Should -Be @('Compile:Theirs/TheirsA.cs')
        $result.escalate_paths.Count | Should -Be 0
        Should -Invoke Write-MergedFile -Times 1 -Exactly
    }

    It 'escalates when any conflicted path is outside mergeable_paths' {
        # Arrange: a conflict set mixing a project file with a source file.
        $script:ConflictedPath = @('Proj/Proj.csproj', 'Proj/Foo.cs')

        # Act: resolve the worktree.
        $result = Invoke-MergeableConflictResolution -Worktree $script:RepoRoot -ConfigPath $script:ConfigPath

        # Assert: the set is refused whole, before any file is read, and the one
        # git call made is the conflicted-path listing.
        $result.result | Should -Be 'escalate'
        $result.escalate_paths | Should -Be @('Proj/Foo.cs')
        Should -Invoke Write-MergedFile -Times 0 -Exactly
        Should -Invoke Invoke-GitExe -Times 1 -Exactly
    }

    It 'escalates and writes nothing when the never-drop post-condition fails' {
        # Arrange: a theirs stage carrying an entry the conflicted text lacks.
        $script:StageOurs = Get-StageLine -Name 'script-never-drop.ours.csproj'
        $script:StageTheirs = Get-StageLine -Name 'script-never-drop.theirs.csproj'
        $script:StageBase = Get-StageLine -Name 'script-never-drop.base.csproj'

        # Act: resolve the worktree.
        $result = Invoke-MergeableConflictResolution -Worktree $script:RepoRoot -ConfigPath $script:ConfigPath

        # Assert: a merge that would drop an entry never reaches the filesystem.
        $result.result | Should -Be 'escalate'
        $result.escalate_paths | Should -Be @('Proj/Proj.csproj')
        Should -Invoke Write-MergedFile -Times 0 -Exactly
    }

    It 'classifies paths with the shared blast-radius matcher' {
        # Arrange: a root-level packages.config, which an anchored **/ pattern
        # only admits through the shared matcher's anchor-stripping step.
        $script:ConflictedPath = @('packages.config')
        $script:ConflictedLine = @(
            '<packages>',
            '<<<<<<< HEAD',
            '  <package id="Ours.Alpha" version="1.2.0" targetFramework="net48" />',
            '=======',
            '  <package id="Theirs.Gamma" version="3.1.0" targetFramework="net48" />',
            '>>>>>>> origin/main',
            '</packages>')
        $script:StageOurs = @('<packages>', '  <package id="Ours.Alpha" version="1.2.0" targetFramework="net48" />', '</packages>')
        $script:StageTheirs = @('<packages>', '  <package id="Theirs.Gamma" version="3.1.0" targetFramework="net48" />', '</packages>')
        $script:StageBase = @('<packages>', '</packages>')

        # Act: resolve the worktree.
        $result = Invoke-MergeableConflictResolution -Worktree $script:RepoRoot -ConfigPath $script:ConfigPath

        # Assert: the path is mergeable and resolves rather than escalating.
        $result.result | Should -Be 'resolved'
        $result.escalate_paths.Count | Should -Be 0
        $result.resolved[0].path | Should -Be 'packages.config'
    }

    It 'never invokes a staging or commit git command' {
        # Arrange: the default resolved scenario, which is the only path that
        # reaches the filesystem at all.

        # Act: resolve the worktree.
        $null = Invoke-MergeableConflictResolution -Worktree $script:RepoRoot -ConfigPath $script:ConfigPath

        # Assert: creating history is the caller's step, so no recorded argument
        # array names either subcommand.
        Should -Invoke Invoke-GitExe -Times 0 -Exactly -ParameterFilter {
            $GitArgs -contains 'add' -or $GitArgs -contains 'commit'
        }
        Should -Invoke Invoke-GitExe -Times 4 -Exactly
    }

    It 'returns exactly the three documented result keys and one JSON call site' {
        # Arrange: the script text, read from disk rather than restated.
        $text = Get-Content -LiteralPath $script:ScriptPath -Raw

        # Act: resolve the worktree.
        $result = Invoke-MergeableConflictResolution -Worktree $script:RepoRoot -ConfigPath $script:ConfigPath

        # Assert: the published contract is three keys, serialised once. The
        # guarded entry-point body is not executed here, because it runs git.
        @($result.Keys) | Should -Be @('result', 'resolved', 'escalate_paths')
        ([regex]::Matches($text, 'ConvertTo-Json')).Count | Should -Be 1
    }
}

Describe 'Byte-level seams' {
    BeforeAll {
        # Pester It blocks do not share locals, so the one real read this block
        # performs is stored at script scope.
        $script:BomFile = Read-ConflictedFile -Path (Join-Path $script:FixtureRoot 'bom-compile.conflicted.csproj')
        $script:WhatIfPath = Join-Path $script:FixtureRoot 'whatif-never-written.csproj'
    }

    It 'reads the byte-order mark and the retained terminators from a BOM fixture' {
        # Arrange / Act: the real read performed in this block's BeforeAll.
        $file = $script:BomFile

        # Assert: the mark is reported as metadata and stripped from the lines,
        # and every line still carries its own terminator.
        $file.HasBom | Should -BeTrue
        ($file.Bytes[0..2] -join ',') | Should -Be '239,187,191'
        $file.Line[0] | Should -Not -Match "`u{FEFF}"
        @($file.Line | Where-Object { -not $_.EndsWith("`n") }).Count | Should -Be 0
    }

    It 'reads a CRLF fixture with its terminators retained' {
        # Arrange / Act: the real read of the exempted CRLF fixture.
        $file = Read-ConflictedFile -Path (Join-Path $script:FixtureRoot 'crlf-compile.conflicted.csproj')

        # Assert: an unmarked file reports no mark, and no terminator was
        # normalized on the way in.
        $file.HasBom | Should -BeFalse
        @($file.Line | Where-Object { -not $_.EndsWith("`r`n") }).Count | Should -Be 0
    }

    It 'returns $null for a file that is not valid UTF-8' {
        # Arrange: a committed fixture carrying the byte 0xFF, which is not a
        # legal UTF-8 start byte.

        # Act: the real read, with the strict decoder the production path uses.
        $file = Read-ConflictedFile -Path (Join-Path $script:FixtureRoot 'invalid-utf8.conflicted.csproj')

        # Assert: the decoder fallback is reported as $null rather than a lossy
        # rewrite, which is what the caller turns into an escalation.
        $file | Should -BeNullOrEmpty
    }

    It 'assembles the merged bytes without writing under -WhatIf' {
        # Arrange: the lines of the real BOM read, and a path no fixture uses.

        # Act: run the real writer with the write itself suppressed.
        Write-MergedFile -Path $script:WhatIfPath -Line $script:BomFile.Line -HasBom $true -WhatIf

        # Assert: every line of the writer ran except the one inside the guard,
        # so the fixture directory is unchanged.
        Test-Path -LiteralPath $script:WhatIfPath | Should -BeFalse
    }
}
