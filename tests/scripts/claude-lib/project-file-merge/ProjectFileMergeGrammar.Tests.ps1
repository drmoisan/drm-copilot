<#
.SYNOPSIS
    Behavioral tests for the project-file merge line grammar (issue #643).

.DESCRIPTION
    Covers the three exported functions of ProjectFileMergeGrammar.psm1: path
    classification for each admitted kind and for a path outside them, the four
    admitted element shapes with their keys and versions, the refusal of a line
    outside the grammar, blank-line skipping, and the three rankable outcomes and
    the unrankable one of the version comparison.

    Every input is an in-memory string array. These tests invoke no external
    process, read no clock, and create no file.
#>

BeforeAll {
    # Resolve the module four levels up: project-file-merge -> claude-lib ->
    # scripts -> tests -> repo root. Resolve-Path normalizes the separators so
    # Pester's coverage breakpoints bind to the path the run settings name.
    $modulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1").Path
    Import-Module $modulePath -Force

    # Lines are written with their own terminator throughout, because that is the
    # shape Read-ConflictedFile hands the grammar in production.
    $script:Terminator = "`n"
}

Describe 'Get-ProjectFileKind' {
    It 'classifies packages.config as the packages kind' {
        # Arrange / Act: a nested packages.config path.
        $kind = Get-ProjectFileKind -Path 'src/Proj/packages.config'

        # Assert: the leaf name alone decides this kind.
        $kind | Should -Be 'packages'
    }

    It 'classifies app.config as the appconfig kind' {
        # Arrange / Act: a nested app.config path.
        $kind = Get-ProjectFileKind -Path 'src/Proj/app.config'

        # Assert: app.config and packages.config share an extension and must not
        # share a kind.
        $kind | Should -Be 'appconfig'
    }

    It 'classifies a project extension as the msbuild kind' {
        # Arrange: the three extensions that share the item grammar.
        $path = @('src/Proj/Proj.csproj', 'src/Proj/Proj.vbproj', 'build/Common.props')

        # Act / Assert: each classifies as one kind.
        foreach ($entry in $path) {
            Get-ProjectFileKind -Path $entry | Should -Be 'msbuild'
        }
    }

    It 'returns null for an unrecognised leaf name' {
        # Arrange / Act: a source file the merge step must never touch.
        $kind = Get-ProjectFileKind -Path 'src/Proj/Program.cs'

        # Assert: an unclassified path is what makes the caller escalate.
        $kind | Should -BeNullOrEmpty
    }
}

Describe 'Get-MergeableUnit' {
    It 'parses a single-line <ItemType> item' -ForEach @(
        @{ ItemType = 'Compile' }
        @{ ItemType = 'Analyzer' }
        @{ ItemType = 'None' }
        @{ ItemType = 'Content' }
        @{ ItemType = 'EmbeddedResource' }
    ) {
        # Arrange: one self-closing item element of the item type under test.
        $line = @(('    <{0} Include="Shared/Entry.cs" />' -f $ItemType) + $script:Terminator)

        # Act: parse the side.
        $unit = Get-MergeableUnit -Line $line -Kind 'msbuild'

        # Assert: one unit, keyed on the item type and the Include value.
        $unit.Count | Should -Be 1
        $unit[0].Key | Should -Be ('{0}:Shared/Entry.cs' -f $ItemType)
        $unit[0].Lines.Count | Should -Be 1
    }

    It 'parses the paired form with metadata children' {
        # Arrange: an open/close item whose children are metadata elements.
        $line = @(
            ('    <Compile Include="Shared/Form1.Designer.cs">' + $script:Terminator),
            ('      <DependentUpon>Form1.cs</DependentUpon>' + $script:Terminator),
            ('      <SubType>Designer</SubType>' + $script:Terminator),
            ('    </Compile>' + $script:Terminator))

        # Act: parse the side.
        $unit = Get-MergeableUnit -Line $line -Kind 'msbuild'

        # Assert: one unit carrying the whole element, close tag included.
        $unit.Count | Should -Be 1
        $unit[0].Key | Should -Be 'Compile:Shared/Form1.Designer.cs'
        $unit[0].Lines.Count | Should -Be 4
    }

    It 'parses a package line with its version' {
        # Arrange: one packages.config entry.
        $line = @('  <package id="Newtonsoft.Json" version="13.0.3" targetFramework="net48" />' + $script:Terminator)

        # Act: parse the side as the packages kind.
        $unit = Get-MergeableUnit -Line $line -Kind 'packages'

        # Assert: the id keys the unit and the version is carried separately, so
        # two sides pinning one package are comparable.
        $unit.Count | Should -Be 1
        $unit[0].Key | Should -Be 'package:Newtonsoft.Json'
        $unit[0].Version | Should -Be '13.0.3'
    }

    It 'parses a dependentAssembly block keyed on the assembly name' {
        # Arrange: one binding-redirect block.
        $line = @(
            ('      <dependentAssembly>' + $script:Terminator),
            ('        <assemblyIdentity name="System.Buffers" publicKeyToken="cc7b13ffcd2ddd51" culture="neutral" />' + $script:Terminator),
            ('        <bindingRedirect oldVersion="0.0.0.0-4.0.3.0" newVersion="4.0.3.0" />' + $script:Terminator),
            ('      </dependentAssembly>' + $script:Terminator))

        # Act: parse the side as the appconfig kind.
        $unit = Get-MergeableUnit -Line $line -Kind 'appconfig'

        # Assert: the identity supplies the key and the redirect the version.
        $unit.Count | Should -Be 1
        $unit[0].Key | Should -Be 'bindingRedirect:System.Buffers'
        $unit[0].Version | Should -Be '4.0.3.0'
        $unit[0].Lines.Count | Should -Be 4
    }

    It 'returns null for a line outside the grammar' {
        # Arrange: a property group, which the grammar does not admit.
        $line = @(('    <PropertyGroup>' + $script:Terminator))

        # Act: parse the side.
        $unit = Get-MergeableUnit -Line $line -Kind 'msbuild'

        # Assert: the whole side fails, because a partial parse would let the
        # merge drop the line it did not understand.
        $unit | Should -BeNullOrEmpty
    }

    It 'skips blank lines' {
        # Arrange: two items separated by a blank line and a whitespace-only line.
        $line = @(
            ('    <Compile Include="A.cs" />' + $script:Terminator),
            $script:Terminator,
            ('   ' + $script:Terminator),
            ('    <Compile Include="B.cs" />' + $script:Terminator))

        # Act: parse the side.
        $unit = Get-MergeableUnit -Line $line -Kind 'msbuild'

        # Assert: blank separators are not units and are not a parse failure.
        $unit.Count | Should -Be 2
        $unit[0].Key | Should -Be 'Compile:A.cs'
        $unit[1].Key | Should -Be 'Compile:B.cs'
    }
}

Describe 'Compare-UnitVersion' {
    It 'selects the higher four-part version' {
        # Arrange / Act: a pair in each argument order.
        $theirsHigher = Compare-UnitVersion -Ours '4.0.0.0' -Theirs '4.0.2.0'
        $oursHigher = Compare-UnitVersion -Ours '4.0.2.0' -Theirs '4.0.0.0'

        # Assert: the ranking names the side, not the value, and is symmetric.
        $theirsHigher | Should -Be 'theirs'
        $oursHigher | Should -Be 'ours'
    }

    It 'reports equal versions' {
        # Arrange / Act: the same version written on both sides.
        $verdict = Compare-UnitVersion -Ours '13.0.3' -Theirs '13.0.3'

        # Assert: an equal pin needs no choice, so neither side is named.
        $verdict | Should -Be 'equal'
    }

    It 'escalates an unparseable version on either side' {
        # Arrange / Act: a prerelease pin on each side in turn, and an absent one.
        $oursPrerelease = Compare-UnitVersion -Ours '1.0.0-beta1' -Theirs '1.0.0'
        $theirsPrerelease = Compare-UnitVersion -Ours '1.0.0' -Theirs '1.0.0-beta1'
        $absent = Compare-UnitVersion -Ours '' -Theirs '1.0.0'

        # Assert: an unrankable pair goes to a human rather than to a guess.
        $oursPrerelease | Should -Be 'escalate'
        $theirsPrerelease | Should -Be 'escalate'
        $absent | Should -Be 'escalate'
    }
}
