#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsPageDiataxis.psm1.

.DESCRIPTION
    Covers the path-or-glob rule (exact, prefix plus slash, case-sensitive wildcard with * across
    /), first-match directory modes, the mode signals with fences and comments ignored, each of
    the five DOCS_PAGE_MODE_* rule codes at its catalog pointer, and seeded property tests:
    the verdict is unchanged under insertion of plain paragraph lines, and ordered-list lines
    inside a fence never count as steps. Every page is an in-memory string.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageDiataxis.psm1') -Force -ErrorAction Stop
    # No -Force: bind to the sibling instance that DocsPageDiataxis imported.
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsPageMarkdown.psm1') -ErrorAction Stop

    $script:Policy = [ordered]@{
        modes                 = @('tutorial', 'how-to', 'reference', 'explanation')
        required_front_matter = @()
        directory_modes       = @(
            [ordered]@{ path_or_glob = 'docs/reference'; mode = 'reference' }
            [ordered]@{ path_or_glob = 'docs/guides/**'; mode = 'how-to' }
            [ordered]@{ path_or_glob = 'docs/guides/special.md'; mode = 'tutorial' }
        )
    }
    $script:Marker = '<!-- docs:generated:start id=cli-command-' + ('a' * 64) + ' -->'

    function Get-TestDiataxisCode {
        param([string] $PagePath = 'docs/page.md', [string] $Mode, [string[]] $Line, [System.Collections.IDictionary] $Policy = $script:Policy)
        $findings = Get-DocsPageDiataxisFinding -PagePath $PagePath -DeclaredMode $Mode -LineModel (Get-DocsPageLineModel -Line $Line) -DiataxisPolicy $Policy
        @($findings | ForEach-Object { $_.code })
    }
}

AfterAll {
    Remove-Module -Name DocsPageDiataxis, DocsPageMarkdown, DocsFinding -Force -ErrorAction SilentlyContinue
}

Describe 'Test-DocsPagePathMatch' {
    It 'returns <Expected> for <Path> against <Pattern>' -ForEach @(
        @{ Path = 'docs/reference'; Pattern = 'docs/reference'; Expected = $true }
        @{ Path = 'docs/reference/cli.md'; Pattern = 'docs/reference'; Expected = $true }
        @{ Path = 'docs/reference-old/cli.md'; Pattern = 'docs/reference'; Expected = $false }
        @{ Path = 'docs/Reference/cli.md'; Pattern = 'docs/reference'; Expected = $false }
        @{ Path = 'docs/guides/a/b/c.md'; Pattern = 'docs/guides/*'; Expected = $true }
        @{ Path = 'docs/guides/x.md'; Pattern = 'docs/*.md'; Expected = $true }
        @{ Path = 'docs/Guides/x.md'; Pattern = 'docs/guides/*'; Expected = $false }
        @{ Path = 'docs/a1.md'; Pattern = 'docs/a?.md'; Expected = $true }
        @{ Path = 'docs/b.md'; Pattern = 'docs/[ab].md'; Expected = $true }
        @{ Path = 'docs/c.md'; Pattern = 'docs/[ab].md'; Expected = $false }
    ) {
        Test-DocsPagePathMatch -Path $Path -PathOrGlob $Pattern | Should -Be $Expected
    }
}

Describe 'Get-DocsPageDirectoryMode' {
    It 'returns the first covering entry in profile order' {
        # Act
        $mode = Get-DocsPageDirectoryMode -PagePath 'docs/guides/special.md' -DirectoryMode $script:Policy.directory_modes

        # Assert
        $mode.Mode | Should -BeExactly 'how-to'
        $mode.PathOrGlob | Should -BeExactly 'docs/guides/**'
        $mode.Index | Should -Be 1
    }

    It 'returns $null when no entry covers the page' {
        Get-DocsPageDirectoryMode -PagePath 'docs/other.md' -DirectoryMode $script:Policy.directory_modes | Should -BeNullOrEmpty
    }
}

Describe 'Get-DocsPageModeSignal' {
    It 'records the first ordered step, instructional heading and generated block lines' {
        # Arrange
        $model = Get-DocsPageLineModel -Line @('# Title', 'text', '2) second', '1. first', '## How to install', '## Step 3 finish', $script:Marker) -FirstLineNumber 10

        # Act
        $signal = Get-DocsPageModeSignal -LineModel $model

        # Assert
        $signal.OrderedStepLine | Should -Be 12
        $signal.InstructionHeadingLine | Should -Be 14
        $signal.InstructionHeadingText | Should -BeExactly 'How to install'
        $signal.GeneratedBlockLine | Should -Be 16
    }

    It 'recognizes STEP 2 case-insensitively and ignores How-to without the trailing space' {
        $first = Get-DocsPageModeSignal -LineModel (Get-DocsPageLineModel -Line @('## STEP 2: go'))
        $second = Get-DocsPageModeSignal -LineModel (Get-DocsPageLineModel -Line @('## How-to notes', '## Stepping 1'))
        $first.InstructionHeadingLine | Should -Be 1
        $second.InstructionHeadingLine | Should -Be 0
        $second.InstructionHeadingText | Should -BeNullOrEmpty
    }

    It 'ignores signals inside fences and comments and an ordered list with more than three spaces of indentation' {
        # Arrange
        $model = Get-DocsPageLineModel -Line @('```', '1. fenced', '# How to fenced', $script:Marker, '```', '<!--', '1. commented', '## How to commented', '-->', '<!-- 1. inline -->', '    1. indented')

        # Act
        $signal = Get-DocsPageModeSignal -LineModel $model

        # Assert
        $signal.OrderedStepLine | Should -Be 0
        $signal.InstructionHeadingLine | Should -Be 0
        $signal.GeneratedBlockLine | Should -Be 0
    }
}

Describe 'Get-DocsPageDiataxisFinding' {
    It 'returns no finding for a reference page in the reference directory' {
        Get-TestDiataxisCode -PagePath 'docs/reference/cli.md' -Mode 'reference' -Line @('# CLI', $script:Marker, '- item') | Should -Be @()
    }

    It 'reports DOCS_PAGE_MODE_NOT_IN_POLICY at /diataxis_mode when the policy omits the mode' {
        # Arrange
        $policy = [ordered]@{ modes = @('reference'); directory_modes = @() }

        # Act
        $findings = Get-DocsPageDiataxisFinding -PagePath 'docs/page.md' -DeclaredMode 'explanation' -LineModel (Get-DocsPageLineModel -Line @('text')) -DiataxisPolicy $policy

        # Assert
        $findings.Count | Should -Be 1
        $findings[0].code | Should -BeExactly 'DOCS_PAGE_MODE_NOT_IN_POLICY'
        $findings[0].pointer | Should -BeExactly '/diataxis_mode'
        $findings[0].artifact_path | Should -BeExactly 'docs/page.md'
        $findings[0].severity | Should -BeExactly 'error'
        $findings[0].message | Should -BeExactly "diataxis_mode 'explanation' is not listed in diataxis_policy.modes"
    }

    It 'reports DOCS_PAGE_MODE_DIRECTORY_MISMATCH naming the required mode and the entry' {
        # Act
        $findings = Get-DocsPageDiataxisFinding -PagePath 'docs/reference/cli.md' -DeclaredMode 'explanation' -LineModel (Get-DocsPageLineModel -Line @('text')) -DiataxisPolicy $script:Policy

        # Assert
        $findings[0].code | Should -BeExactly 'DOCS_PAGE_MODE_DIRECTORY_MISMATCH'
        $findings[0].pointer | Should -BeExactly '/diataxis_mode'
        $findings[0].message | Should -BeExactly "diataxis_mode 'explanation' differs from 'reference' required for 'docs/reference'"
    }

    It 'reports DOCS_PAGE_MODE_STEPS_MISSING for <_> without an ordered step' -ForEach @('tutorial', 'how-to') {
        $findings = Get-DocsPageDiataxisFinding -PagePath 'docs/page.md' -DeclaredMode $_ -LineModel (Get-DocsPageLineModel -Line @('# Page', '- bullet')) -DiataxisPolicy $script:Policy
        @($findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PAGE_MODE_STEPS_MISSING')
        $findings[0].pointer | Should -BeExactly '/diataxis_mode'
    }

    It 'reports DOCS_PAGE_MODE_INSTRUCTION_HEADING with its line for <_>' -ForEach @('reference', 'explanation') {
        $findings = Get-DocsPageDiataxisFinding -PagePath 'docs/page.md' -DeclaredMode $_ -LineModel (Get-DocsPageLineModel -Line @('text', '## How to run it') -FirstLineNumber 4) -DiataxisPolicy $script:Policy
        @($findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PAGE_MODE_INSTRUCTION_HEADING')
        $findings[0].pointer | Should -BeExactly ''
        $findings[0].message | Should -BeExactly "line 5: heading 'How to run it' is instructional, which diataxis_mode '$_' does not allow"
    }

    It 'reports DOCS_PAGE_MODE_GENERATED_BLOCK for <_> holding a start marker' -ForEach @('tutorial', 'how-to', 'explanation') {
        $findings = Get-DocsPageDiataxisFinding -PagePath 'docs/page.md' -DeclaredMode $_ -LineModel (Get-DocsPageLineModel -Line @('1. step', $script:Marker)) -DiataxisPolicy $script:Policy
        @($findings | ForEach-Object { $_.code }) | Should -Be @('DOCS_PAGE_MODE_GENERATED_BLOCK')
        $findings[0].pointer | Should -BeExactly ''
        $findings[0].message | Should -BeExactly "line 2: generated reference block in a page whose diataxis_mode is '$_'"
    }

    It 'reads a policy without modes or directory_modes as empty' {
        Get-TestDiataxisCode -Mode 'reference' -Line @('text') -Policy ([ordered]@{}) | Should -Be @('DOCS_PAGE_MODE_NOT_IN_POLICY')
    }
}

Describe 'Get-DocsPageDiataxisFinding properties' {
    It 'returns the same verdict under seeded insertion of plain paragraph lines' {
        # Arrange
        $seed = 1021
        $random = [System.Random]::new($seed)
        $cases = @(
            @{ Mode = 'how-to'; Line = @('# Install', '1. Download', '2. Run') }
            @{ Mode = 'tutorial'; Line = @('# Learn', 'intro') }
            @{ Mode = 'reference'; Line = @('# CLI', '## How to call', $script:Marker) }
            @{ Mode = 'explanation'; Line = @('# Why', $script:Marker) }
        )
        foreach ($case in $cases) {
            $expected = (Get-TestDiataxisCode -Mode $case.Mode -Line $case.Line) -join '|'
            for ($round = 0; $round -lt 20; $round++) {
                $lines = [System.Collections.Generic.List[string]]::new()
                foreach ($line in $case.Line) {
                    for ($n = 0; $n -lt $random.Next(0, 3); $n++) { $lines.Add('Plain paragraph text ' + $random.Next(0, 1000)) ; $lines.Add('') }
                    $lines.Add($line)
                }

                # Act
                $actual = (Get-TestDiataxisCode -Mode $case.Mode -Line $lines.ToArray()) -join '|'

                # Assert (the seed is printed through -Because on failure)
                $actual | Should -BeExactly $expected -Because "seed $seed round $round mode $($case.Mode)"
            }
        }
    }

    It 'never counts ordered-list lines inside a fence as steps' {
        # Arrange
        $seed = 7
        $random = [System.Random]::new($seed)
        for ($round = 0; $round -lt 25; $round++) {
            $fence = if ($random.Next(0, 2) -eq 0) { '```' } else { '~~~~' }
            $lines = [System.Collections.Generic.List[string]]::new()
            $lines.Add('# Guide')
            $lines.Add($fence)
            for ($n = 0; $n -lt $random.Next(1, 6); $n++) { $lines.Add(('{0}{1}{2} step' -f (' ' * $random.Next(0, 4)), $random.Next(1, 100), $(if ($random.Next(0, 2) -eq 0) { '.' } else { ')' }))) }
            if ($random.Next(0, 2) -eq 0) { $lines.Add($fence) }

            # Act
            $signal = Get-DocsPageModeSignal -LineModel (Get-DocsPageLineModel -Line $lines.ToArray())

            # Assert (the seed is printed through -Because on failure)
            $signal.OrderedStepLine | Should -Be 0 -Because "seed $seed round $round"
            (Get-TestDiataxisCode -Mode 'how-to' -Line $lines.ToArray()) | Should -Be @('DOCS_PAGE_MODE_STEPS_MISSING') -Because "seed $seed round $round"
        }
    }
}
