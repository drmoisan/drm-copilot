#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Integration tests for generate-reference with the 1021 check command, the 1021 front-matter
    contract, the -Json envelope schema, determinism and block removal.

.DESCRIPTION
    Invoke-DocsCommand.ps1 is dot-sourced and both subcommands run through Invoke-DocsCommandCli
    over one in-memory command context from DocsReference.TestSupport.psm1 (UtcNow and
    InvokeProcess throw). Generated pages are checked by 'check -Json' with no option other than
    -Profile, after a README.md entry page with conforming front matter is added to the
    documentation root. Front matter is parsed by 1021 ConvertFrom-DocsPageFrontMatter and
    validated by 1021 Test-DocsPageFrontMatter over COMPOSED-SET from
    New-DocsReferenceComposedSchemaSet. Envelopes are validated by Test-DocsArtifactText as
    docs-command-envelope.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsSchema.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsPageFrontMatter.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibRoot -ChildPath 'Invoke-DocsCommand.ps1')

    $script:SchemaText = Get-DocsReferenceSchemaTextMap
    $script:ComposedSet = New-DocsReferenceComposedSchemaSet -SchemaTextMap $script:SchemaText
    $script:DocsProfile = New-DocsReferenceFixedProfile
    $script:AudienceId = [string[]] @($script:DocsProfile['audiences'] | ForEach-Object { [string] $_['id'] })
    $script:RequiredField = [string[]]@('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs')
    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'
    $script:SnapshotPath = 'docs/documentation-estate/surface-inventory-snapshot.json'
    $script:CommandElement = New-DocsReferenceFixedElement -Kind 'cli-command' -Declaration 'tool run'
    $script:OptionElement = New-DocsReferenceFixedElement -Kind 'cli-option' -Declaration '--fast' -ParentId $script:CommandElement['element_id']
    $script:Element = [object[]]@(
        $script:CommandElement
        $script:OptionElement
        (New-DocsReferenceFixedElement -Kind 'cli-command' -Declaration 'tool check' -Path 'src/check.py')
        (New-DocsReferenceFixedElement -Kind 'http-route' -Declaration 'GET /items' -Path 'src/routes.ts')
        (New-DocsReferenceFixedElement -Kind 'config-key' -Declaration 'tool.level' -Path 'conf/tool.toml')
        (New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration 'Tool.Run' -Path 'src/Tool.cs')
    )
    $script:Cli = 'docs/reference/cli-reference.md'
    $script:Page = [string[]]@('docs/reference/api-reference.md', $script:Cli, 'docs/reference/config-reference.md', 'docs/reference/http-reference.md')
    $script:EntryPage = (@(
            '---'
            'owner: "maintainer-team"'
            'last_reviewed: "2026-01-02"'
            'audience: ["maintainers"]'
            'diataxis_mode: "explanation"'
            'surface_refs: []'
            '---'
            '# Documentation'
            ''
            '- [API reference](reference/api-reference.md)'
            '- [CLI reference](reference/cli-reference.md)'
            '- [Configuration reference](reference/config-reference.md)'
            '- [HTTP reference](reference/http-reference.md)'
        ) -join "`n") + "`n"

    function Get-TestMemory {
        # Returns an in-memory context over the fixed profile, Element and Page entries.
        param([object[]] $Element = $script:Element, [AllowNull()] [System.Collections.IDictionary] $Page, [AllowNull()] [string[]] $ReadFailure, [AllowNull()] [scriptblock] $BeforeCall)
        $file = New-DocsReferenceFileMap -ProfileValue $script:DocsProfile -Element $Element -Page $Page -SchemaTextMap $script:SchemaText
        return New-DocsReferenceMemoryContext -File $file -ReadTextFailurePath $ReadFailure -BeforeCall $BeforeCall
    }

    function Invoke-TestCli {
        # Runs one subcommand with -Json over Memory; returns @{ Outcome; Envelope }.
        param([hashtable] $Memory, [string] $Name = 'generate-reference', [string[]] $Argument = @())
        $outcome = Invoke-DocsCommandCli -Command $Name -CommandArgument $Argument -Context $Memory.Context -Json:$true
        return @{ Outcome = $outcome; Envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value }
    }

    function Get-TestKeySet {
        # Returns the ordinal-sorted keys of a dictionary, unrolled so that Should compares items.
        param([System.Collections.IDictionary] $Value)
        [string[]] $keys = @($Value.Keys | ForEach-Object { [string] $_ })
        [Array]::Sort($keys, [System.StringComparer]::Ordinal)
        return $keys
    }

    function Get-TestLine {
        # Splits LF-terminated page text into lines.
        param([string] $Text)
        return [string[]] $Text.Substring(0, $Text.Length - 1).Split("`n")
    }

    function Test-TestSubsequence {
        # Returns $true when every Item line appears in Line in the same relative order.
        param([string[]] $Item, [string[]] $Line)
        $at = 0
        foreach ($text in $Line) { if ($at -lt $Item.Count -and $text -ceq $Item[$at]) { $at++ } }
        return $at -eq $Item.Count
    }

    function Add-TestProse {
        # Inserts drawn prose after the page title and after every end marker of a generated page text.
        param([string] $Text, [System.Random] $Random)
        $output = [System.Collections.Generic.List[string]]::new()
        $inserted = [System.Collections.Generic.List[string]]::new()
        foreach ($line in (Get-TestLine -Text $Text)) {
            $output.Add($line)
            if ($line.StartsWith('# ', [System.StringComparison]::Ordinal) -or $line.StartsWith('<!-- docs:generated:end ', [System.StringComparison]::Ordinal)) {
                [string[]] $prose = New-DocsReferenceRandomProse -Random $Random
                $output.Add('')
                $output.AddRange($prose)
                $inserted.AddRange([string[]] @($prose | Where-Object { $_.Length -gt 0 }))
            }
        }
        return @{ Text = ($output.ToArray() -join "`n") + "`n"; Prose = [string[]] $inserted.ToArray() }
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'generate-reference with the 1021 check command' {
    It 'passes check with zero findings after -Write and a README.md entry page' {
        # Arrange
        $memory = Get-TestMemory

        # Act
        $generate = Invoke-TestCli -Memory $memory -Argument @('-Write')
        $memory.Files['docs/README.md'] = $script:EntryPage
        $check = Invoke-TestCli -Memory $memory -Name 'check' -Argument @('-Profile', $script:ProfilePath)

        # Assert
        $generate.Outcome.ExitCode | Should -Be 0
        $memory.WriteLog.Count | Should -Be 4
        $check.Outcome.ExitCode | Should -Be 0
        @($check.Envelope['findings']).Count | Should -Be 0
        $check.Envelope['result']['page_count'] | Should -Be 5 -Because 'check reads the four generated pages and the entry page'
    }

    It 'passes check again after seeded prose is inserted around and between blocks and the pages are regenerated (seed <Seed>)' -ForEach @(@{ Seed = 11 }, @{ Seed = 23 }, @{ Seed = 47 }, @{ Seed = 101 }, @{ Seed = 211 }) {
        # Arrange
        $random = [System.Random]::new($Seed)
        $memory = Get-TestMemory
        [void](Invoke-TestCli -Memory $memory -Argument @('-Write'))
        $memory.Files['docs/README.md'] = $script:EntryPage
        $inserted = @{}
        foreach ($path in $script:Page) {
            $withProse = Add-TestProse -Text $memory.Files[$path] -Random $random
            $memory.Files[$path] = $withProse.Text
            $inserted[$path] = $withProse.Prose
        }

        # Act
        $regenerate = Invoke-TestCli -Memory $memory -Argument @('-Write')
        $check = Invoke-TestCli -Memory $memory -Name 'check' -Argument @('-Profile', $script:ProfilePath)

        # Assert
        $regenerate.Outcome.ExitCode | Should -Be 0 -Because "seed $Seed"
        $check.Outcome.ExitCode | Should -Be 0 -Because "seed $Seed"
        @($check.Envelope['findings'] | ForEach-Object { $_['code'] }) | Should -Be @() -Because "seed $Seed"
        foreach ($path in $script:Page) {
            Test-TestSubsequence -Item $inserted[$path] -Line (Get-TestLine -Text $memory.Files[$path]) | Should -BeTrue -Because "seed $Seed keeps the prose of $path"
        }
    }
}

Describe 'generate-reference front matter against the 1021 page-metadata contract' {
    It 'emits a line-form block that 1021 parses and validates with COMPOSED-SET and every required field' {
        # Arrange
        $memory = Get-TestMemory

        # Act
        [void](Invoke-TestCli -Memory $memory -Argument @('-Write'))

        # Assert
        foreach ($path in $script:Page) {
            [string[]] $lines = Get-TestLine -Text $memory.Files[$path]
            $close = [array]::IndexOf($lines, '---', 1)
            $lines[0] | Should -BeExactly '---' -Because $path
            $close | Should -BeGreaterThan 1 -Because $path
            for ($index = 1; $index -lt $close; $index++) {
                $field = [regex]::Match($lines[$index], '\A(?<key>[a-z_]+): (?<value>.+)\z')
                $field.Success | Should -BeTrue -Because "$path line $($index + 1) has the key: value form"
                @((ConvertFrom-DocsJsonText -Text $field.Groups['value'].Value).Findings).Count | Should -Be 0 -Because "$path line $($index + 1) holds one JSON value"
            }
            $parsed = ConvertFrom-DocsPageFrontMatter -Text $memory.Files[$path] -PagePath $path
            @($parsed.Findings).Count | Should -Be 0 -Because $path
            [object[]] $validation = Test-DocsPageFrontMatter -FrontMatter $parsed.Value -PagePath $path -ComposedSchemaSet $script:ComposedSet -RequiredField $script:RequiredField -AudienceId $script:AudienceId -FieldLine $parsed.FieldLine
            $validation.Count | Should -Be 0 -Because $path
        }
    }

    It 'preserves valid existing owner, audience, last_reviewed, title and extensions on regeneration' {
        # Arrange
        $existing = (@(
                '---'
                'owner: "custom-owner"'
                'last_reviewed: "2025-12-31"'
                'audience: ["end-users"]'
                'diataxis_mode: "reference"'
                'surface_refs: []'
                'title: "Command line"'
                'extensions: {"acme.note":"kept"}'
                '---'
                '# Command line'
            ) -join "`n") + "`n"
        $memory = Get-TestMemory -Page @{ $script:Cli = $existing }

        # Act
        $run = Invoke-TestCli -Memory $memory -Argument @('-Write')
        $value = (ConvertFrom-DocsPageFrontMatter -Text $memory.Files[$script:Cli] -PagePath $script:Cli).Value

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $value['owner'] | Should -BeExactly 'custom-owner'
        $value['last_reviewed'] | Should -BeExactly '2025-12-31'
        @($value['audience']) | Should -Be @('end-users')
        $value['title'] | Should -BeExactly 'Command line'
        $value['extensions']['acme.note'] | Should -BeExactly 'kept'
        @($value['surface_refs']).Count | Should -Be 3
    }
}

Describe 'generate-reference -Json envelope' {
    It 'validates against docs-command-envelope with the fixed key sets for a <Case>' -ForEach @(
        @{ Case = 'dry run'; Exit = 0; HasResult = $true }
        @{ Case = 'write run'; Exit = 0; HasResult = $true }
        @{ Case = 'write conflict'; Exit = 1; HasResult = $true }
        @{ Case = 'usage error'; Exit = 2; HasResult = $false }
        @{ Case = 'read failure'; Exit = 3; HasResult = $false }
    ) {
        # Arrange
        $state = @{ Calls = 0 }
        $conflict = {
            param($Member, $Path, $Files)
            if ($Member -ceq 'TestFile' -and $Path -ceq 'docs/reference/cli-reference.md') { $state.Calls++; if ($state.Calls -eq 2) { $Files[$Path] = 'concurrent' } }
        }.GetNewClosure()
        $memory = switch ($Case) {
            'write conflict' { Get-TestMemory -BeforeCall $conflict }
            'read failure' { Get-TestMemory -ReadFailure @($script:ProfilePath) }
            default { Get-TestMemory }
        }
        [string[]] $argument = switch ($Case) { 'dry run' { @() } 'usage error' { @('-Bogus') } default { @('-Write') } }

        # Act
        $run = Invoke-TestCli -Memory $memory -Argument $argument
        [object[]] $schemaFinding = Test-DocsArtifactText -ArtifactKind 'docs-command-envelope' -JsonText $run.Outcome.Stdout -ComposedSchemaSet $script:ComposedSet

        # Assert
        $run.Outcome.ExitCode | Should -Be $Exit
        $schemaFinding.Count | Should -Be 0
        Get-TestKeySet -Value $run.Envelope | Should -Be @('command', 'exit_code', 'findings', 'ok', 'result')
        $run.Envelope['command'] | Should -BeExactly 'generate-reference'
        if (-not $HasResult) { $run.Envelope['result'] | Should -BeNullOrEmpty; return }
        $result = $run.Envelope['result']
        Get-TestKeySet -Value $result | Should -Be @('mode', 'output_directory', 'pages', 'summary', 'unrendered')
        Get-TestKeySet -Value $result['summary'] | Should -Be @('blocks_added', 'blocks_removed', 'blocks_unchanged', 'blocks_updated', 'page_count', 'pages_blocked', 'pages_changed', 'pages_unchanged')
        @($result['pages']).Count | Should -Be 4
        foreach ($page in $result['pages']) {
            Get-TestKeySet -Value $page | Should -Be @('action', 'blocks', 'diff', 'path', 'sha256_after', 'sha256_before', 'status')
            Get-TestKeySet -Value $page['blocks'] | Should -Be @('added', 'removed', 'unchanged', 'updated')
        }
    }
}

Describe 'generate-reference determinism and block removal' {
    It 'gives identical written page texts and envelope bytes across two runs and a shuffled element order' {
        # Arrange
        $shuffled = Get-DocsReferenceShuffled -Random ([System.Random]::new(7)) -Item $script:Element
        $memories = @((Get-TestMemory), (Get-TestMemory), (Get-TestMemory -Element $shuffled))

        # Act
        $runs = @($memories | ForEach-Object { Invoke-TestCli -Memory $_ -Argument @('-Write') })
        $texts = @($memories | ForEach-Object { (@($_.WriteLog | ForEach-Object { "$($_.RelativePath)|$($_.Text)" }) -join "`n") })

        # Assert
        $runs[0].Outcome.ExitCode | Should -Be 0
        $texts[0] | Should -Not -BeNullOrEmpty
        $texts[1] | Should -BeExactly $texts[0]
        $texts[2] | Should -BeExactly $texts[0]
        $runs[1].Outcome.Stdout | Should -BeExactly $runs[0].Outcome.Stdout
        $runs[2].Outcome.Stdout | Should -BeExactly $runs[0].Outcome.Stdout
    }

    It 'removes the block of an element that leaves the snapshot, reports it, exits 0 and keeps every other line' {
        # Arrange
        $memory = Get-TestMemory
        [void](Invoke-TestCli -Memory $memory -Argument @('-Write'))
        $before = @{}
        foreach ($path in $script:Page) { $before[$path] = $memory.Files[$path] }
        $optionId = [string] $script:OptionElement['element_id']
        $memory.Files[$script:SnapshotPath] = ConvertTo-DocsReferenceSnapshotText -Element @($script:Element | Where-Object { $_['element_id'] -cne $optionId })

        # Act
        $run = Invoke-TestCli -Memory $memory -Argument @('-Write')
        $cliPage = @($run.Envelope['result']['pages'] | Where-Object { $_['path'] -ceq $script:Cli })[0]
        [string[]] $oldLine = Get-TestLine -Text $before[$script:Cli]
        $start = [array]::IndexOf($oldLine, "<!-- docs:generated:start id=$optionId -->")
        $end = [array]::IndexOf($oldLine, "<!-- docs:generated:end id=$optionId -->")
        $kept = [System.Collections.Generic.List[string]]::new()
        for ($index = 0; $index -lt $oldLine.Count; $index++) { if ($index -lt $start -or $index -gt $end + 1) { $kept.Add($oldLine[$index]) } }
        # The page ends with exactly one LF, so a removal at the end of the page also drops the blank line before it.
        while ($kept.Count -gt 0 -and $kept[$kept.Count - 1].Length -eq 0) { $kept.RemoveAt($kept.Count - 1) }
        [string[]] $expected = $kept.ToArray()

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        @($cliPage['blocks']['removed']) | Should -Be @($optionId)
        @($run.Envelope['findings'] | ForEach-Object { "$($_['code'])/$($_['severity'])" }) | Should -Be @('REFERENCE_BLOCK_REMOVED/info')
        @($run.Envelope['findings'][0]['related_ids']) | Should -Contain $optionId
        $start | Should -BeGreaterThan 0
        @(Get-TestLine -Text $memory.Files[$script:Cli] | Where-Object { -not $_.StartsWith('surface_refs: ') }) | Should -Be @($expected | Where-Object { -not $_.StartsWith('surface_refs: ') })
        foreach ($path in @($script:Page | Where-Object { $_ -cne $script:Cli })) { $memory.Files[$path] | Should -BeExactly $before[$path] -Because "$path is unchanged" }
    }
}
