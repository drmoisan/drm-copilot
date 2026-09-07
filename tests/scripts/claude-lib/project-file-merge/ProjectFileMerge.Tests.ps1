<#
.SYNOPSIS
    Behavioral tests for the keyed-union project-file merge (issue #643).

.DESCRIPTION
    Covers hunk splitting in both conflict styles, the keyed union against every
    committed fixture pair, the two version-resolution paths, the four escalation
    paths, terminator and byte-mark preservation, and the never-drop
    post-condition in its passing and both failing forms.

    Fixtures are read from tests/fixtures/project_file_merge with Get-Content
    -Raw and split so each line keeps its own terminator, which is the shape the
    entry script hands the module. These tests invoke no external process, read
    no clock, and create no file.
#>

BeforeAll {
    # Resolve the module and the fixtures four levels up: project-file-merge ->
    # claude-lib -> scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/project-file-merge/ProjectFileMerge.psm1").Path
    Import-Module $modulePath -Force
    $script:FixtureRoot = (Resolve-Path (Join-Path $script:RepoRoot 'tests/fixtures/project_file_merge')).Path

    # Split a whole file so each line retains its own terminator. A split that
    # dropped terminators would make the CRLF case pass vacuously.
    function Get-FixtureLine {
        param([Parameter(Mandatory = $true)][string] $Name)

        $text = Get-Content -LiteralPath (Join-Path $script:FixtureRoot $Name) -Raw
        $line = [System.Collections.Generic.List[string]]::new()
        foreach ($match in [regex]::Matches($text, '[^\r\n]*(?:\r\n|\n|\r)')) { $line.Add($match.Value) }
        $consumed = ($line -join '').Length
        if ($consumed -lt $text.Length) { $line.Add($text.Substring($consumed)) }
        return , $line.ToArray()
    }
}

Describe 'Get-ConflictHunk' {
    It 'parses a merge-style hunk' {
        # Arrange: a two-sided insertion with no base section.
        $line = Get-FixtureLine -Name 'compile-single-line.conflicted.csproj'

        # Act: split the file into hunks.
        $hunk = Get-ConflictHunk -Line $line

        # Assert: one hunk carrying both sides and no base text.
        $hunk.Count | Should -Be 1
        $hunk[0].Ours.Count | Should -Be 2
        $hunk[0].Theirs.Count | Should -Be 2
        $hunk[0].Base.Count | Should -Be 0
        $line[$hunk[0].Start] | Should -Match '^<{7}'
        $line[$hunk[0].End] | Should -Match '^>{7}'
    }

    It 'parses a diff3-style hunk and skips its base section' {
        # Arrange: a hunk carrying a ||||||| base section.
        $line = Get-FixtureLine -Name 'diff3-compile.conflicted.csproj'

        # Act: split the file into hunks.
        $hunk = Get-ConflictHunk -Line $line

        # Assert: the base text is collected separately and does not leak into
        # either side, which is what keeps it out of the union.
        $hunk.Count | Should -Be 1
        $hunk[0].Base.Count | Should -Be 1
        $hunk[0].Ours.Count | Should -Be 1
        $hunk[0].Theirs.Count | Should -Be 1
        $hunk[0].Base[0] | Should -Match 'Shared/Legacy.cs'
        ($hunk[0].Ours + $hunk[0].Theirs) -join '' | Should -Not -Match 'Shared/Legacy.cs'
    }

    It 'returns null for an unterminated hunk' {
        # Arrange: a hunk that opens and never closes.
        $line = @('<<<<<<< HEAD', '    <Compile Include="A.cs" />', '=======', '    <Compile Include="B.cs" />')

        # Act: split the file into hunks.
        $hunk = Get-ConflictHunk -Line $line

        # Assert: a truncated conflict is not a resolvable state.
        $hunk | Should -BeNullOrEmpty
    }
}

Describe 'Merge-ConflictedText keyed union' {
    It 'resolves <case> to the expected union' -ForEach @(
        @{ case = 'compile-single-line'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'compile-paired'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'analyzer-single-line'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'analyzer-paired'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'none-single-line'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'none-paired'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'content-single-line'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'content-paired'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'embeddedresource-single-line'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'embeddedresource-paired'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'diff3-compile'; extension = 'csproj'; kind = 'msbuild' }
        @{ case = 'packages-disjoint'; extension = 'config'; kind = 'packages' }
        @{ case = 'appconfig-disjoint'; extension = 'config'; kind = 'appconfig' }
    ) {
        # Arrange: the conflicted text and the union its fixture pair declares.
        $line = Get-FixtureLine -Name ('{0}.conflicted.{1}' -f $case, $extension)
        $expected = Get-FixtureLine -Name ('{0}.expected.{1}' -f $case, $extension)

        # Act: resolve every hunk.
        $outcome = Merge-ConflictedText -Line $line -Kind $kind

        # Assert: the merged text is the expected union byte for byte, and every
        # line outside the hunk survived unchanged.
        $outcome.Escalate | Should -BeFalse
        ($outcome.Lines -join '') | Should -BeExactly ($expected -join '')
    }

    It 'keeps the higher package version and records the resolution' {
        # Arrange: one package pinned at two versions.
        $line = Get-FixtureLine -Name 'packages-version-differs.conflicted.config'
        $expected = Get-FixtureLine -Name 'packages-version-differs.expected.config'

        # Act: resolve the hunk.
        $outcome = Merge-ConflictedText -Line $line -Kind 'packages'

        # Assert: the higher pin survives and the choice is reported, because the
        # caller cites it in the resolution message.
        $outcome.Escalate | Should -BeFalse
        ($outcome.Lines -join '') | Should -BeExactly ($expected -join '')
        $outcome.VersionResolutions.Count | Should -Be 1
        $outcome.VersionResolutions[0].key | Should -Be 'package:Newtonsoft.Json'
        $outcome.VersionResolutions[0].ours | Should -Be '13.0.1'
        $outcome.VersionResolutions[0].theirs | Should -Be '13.0.3'
        $outcome.VersionResolutions[0].chosen | Should -Be '13.0.3'
    }

    It 'keeps the higher newVersion and rewrites the oldVersion upper bound' {
        # Arrange: one assembly redirected to two different versions.
        $line = Get-FixtureLine -Name 'appconfig-newversion-differs.conflicted.config'
        $expected = Get-FixtureLine -Name 'appconfig-newversion-differs.expected.config'

        # Act: resolve the hunk.
        $outcome = Merge-ConflictedText -Line $line -Kind 'appconfig'

        # Assert: the retained block covers the version it now pins, so the
        # redirect range is widened rather than left behind.
        $outcome.Escalate | Should -BeFalse
        ($outcome.Lines -join '') | Should -BeExactly ($expected -join '')
        ($outcome.Lines -join '') | Should -Match 'oldVersion="0\.0\.0\.0-4\.0\.2\.0"'
        $outcome.VersionResolutions[0].chosen | Should -Be '4.0.2.0'
    }

    It 'escalates an unparseable package version' {
        # Arrange: a prerelease pin on one side.
        $line = Get-FixtureLine -Name 'packages-unparseable-version.conflicted.config'

        # Act: resolve the hunk.
        $outcome = Merge-ConflictedText -Line $line -Kind 'packages'

        # Assert: an unrankable pair is refused and named.
        $outcome.Escalate | Should -BeTrue
        $outcome.EscalateReason | Should -Match 'package:Contoso.Widgets'
    }

    It 'escalates a hunk line outside the grammar' {
        # Arrange: a hunk side carrying a property group.
        $line = Get-FixtureLine -Name 'non-grammar-line.conflicted.csproj'

        # Act: resolve the hunk.
        $outcome = Merge-ConflictedText -Line $line -Kind 'msbuild'

        # Assert: the whole file is refused rather than partially merged.
        $outcome.Escalate | Should -BeTrue
        $outcome.EscalateReason | Should -Match 'outside the merge grammar'
    }

    It 'escalates the same key at the same version with differing attributes' {
        # Arrange: one Include carried by both sides with different children.
        $line = Get-FixtureLine -Name 'same-key-different-attributes.conflicted.csproj'

        # Act: resolve the hunk.
        $outcome = Merge-ConflictedText -Line $line -Kind 'msbuild'

        # Assert: two genuinely opposed edits to one entry are a human decision.
        $outcome.Escalate | Should -BeTrue
        $outcome.EscalateReason | Should -Match 'differing content'
    }

    It 'preserves CRLF terminators' {
        # Arrange: a fixture whose every line ends with CRLF.
        $line = Get-FixtureLine -Name 'crlf-compile.conflicted.csproj'
        $expected = Get-FixtureLine -Name 'crlf-compile.expected.csproj'

        # Act: resolve the hunk.
        $outcome = Merge-ConflictedText -Line $line -Kind 'msbuild'

        # Assert: no line lost its terminator, because a kept line is copied
        # rather than rebuilt.
        $outcome.Escalate | Should -BeFalse
        ($outcome.Lines -join '') | Should -BeExactly ($expected -join '')
        @($outcome.Lines | Where-Object { -not $_.EndsWith("`r`n") }).Count | Should -Be 0
    }

    It 'preserves the byte prefix for a BOM fixture' {
        # Arrange: a marked fixture pair and the mark bytes themselves.
        $conflictedBytes = [System.IO.File]::ReadAllBytes((Join-Path $script:FixtureRoot 'bom-compile.conflicted.csproj'))
        $expectedBytes = [System.IO.File]::ReadAllBytes((Join-Path $script:FixtureRoot 'bom-compile.expected.csproj'))
        $line = Get-FixtureLine -Name 'bom-compile.conflicted.csproj'
        $expected = Get-FixtureLine -Name 'bom-compile.expected.csproj'

        # Act: resolve the hunk.
        $outcome = Merge-ConflictedText -Line $line -Kind 'msbuild'

        # Assert: the merge never sees or emits the mark, so the caller's own
        # HasBom reading is carried through unchanged on both sides of the pair.
        ($conflictedBytes[0..2] -join ',') | Should -Be '239,187,191'
        ($expectedBytes[0..2] -join ',') | Should -Be '239,187,191'
        $outcome.Escalate | Should -BeFalse
        ($outcome.Lines -join '') | Should -BeExactly ($expected -join '')
        ($outcome.Lines -join '') | Should -Not -Match "`u{FEFF}"
    }
}

Describe 'Test-NeverDropPostCondition' {
    It 'passes when the merged key set is the union of both sides' {
        # Arrange: the merged text and the three stage texts that produced it.
        $merged = Get-FixtureLine -Name 'script-resolved.expected.csproj'
        $ours = Get-FixtureLine -Name 'script-resolved.ours.csproj'
        $theirs = Get-FixtureLine -Name 'script-resolved.theirs.csproj'
        $base = Get-FixtureLine -Name 'script-resolved.base.csproj'

        # Act: check the post-condition.
        $isKept = Test-NeverDropPostCondition -MergedLine $merged -OursLine $ours -TheirsLine $theirs -BaseLine $base -Kind 'msbuild'

        # Assert: an honest union passes.
        $isKept | Should -BeTrue
    }

    It 'fails when a theirs key is missing from the merged text' {
        # Arrange: stage texts in which theirs carries an entry the merged text
        # never had, which is exactly the drop this gate exists to catch.
        $merged = Get-FixtureLine -Name 'script-resolved.expected.csproj'
        $ours = Get-FixtureLine -Name 'script-never-drop.ours.csproj'
        $theirs = Get-FixtureLine -Name 'script-never-drop.theirs.csproj'
        $base = Get-FixtureLine -Name 'script-never-drop.base.csproj'

        # Act: check the post-condition.
        $isKept = Test-NeverDropPostCondition -MergedLine $merged -OursLine $ours -TheirsLine $theirs -BaseLine $base -Kind 'msbuild'

        # Assert: the gate refuses the write.
        $isKept | Should -BeFalse
    }

    It 'fails when a key present in base and both sides is missing' {
        # Arrange: an entry all three stages carry, dropped from the merged text.
        $merged = @('<Project>', '  <ItemGroup>', '    <Compile Include="Ours/OursA.cs" />', '  </ItemGroup>', '</Project>')
        $ours = @('<Project>', '  <ItemGroup>', '    <Compile Include="Shared/Base1.cs" />', '    <Compile Include="Ours/OursA.cs" />', '  </ItemGroup>', '</Project>')
        $theirs = @('<Project>', '  <ItemGroup>', '    <Compile Include="Shared/Base1.cs" />', '  </ItemGroup>', '</Project>')
        $base = @('<Project>', '  <ItemGroup>', '    <Compile Include="Shared/Base1.cs" />', '  </ItemGroup>', '</Project>')

        # Act: check the post-condition.
        $isKept = Test-NeverDropPostCondition -MergedLine $merged -OursLine $ours -TheirsLine $theirs -BaseLine $base -Kind 'msbuild'

        # Assert: a key neither side removed must survive the merge.
        $isKept | Should -BeFalse
    }
}
