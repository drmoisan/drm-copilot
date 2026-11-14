#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Command tests for generate-reference: dry run, write mode, write conflicts, write failure,
    determinism and the dispatch row.

.DESCRIPTION
    Every test runs Invoke-DocsCommandCli -Command generate-reference (Invoke-DocsCommand.ps1 is
    dot-sourced) against an in-memory command context from DocsReference.TestSupport.psm1. Its
    map holds the committed runtime schema texts (read-only), the profile, the snapshot and any
    existing pages; WriteText records every write, and UtcNow and InvokeProcess throw, so every
    passing test also proves that the command reads no clock and starts no process. The real
    context and Write-DocsFileText are never called. Exit-code, loading-error and page-blocking
    cases are in DocsReferenceWriter.Errors.Tests.ps1.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibRoot -ChildPath 'Invoke-DocsCommand.ps1')

    $script:SchemaText = Get-DocsReferenceSchemaTextMap
    $script:DocsProfile = New-DocsReferenceFixedProfile
    $script:CommandElement = New-DocsReferenceFixedElement -Kind 'cli-command' -Declaration 'tool run'
    $script:OptionElement = New-DocsReferenceFixedElement -Kind 'cli-option' -Declaration '--fast' -ParentId $script:CommandElement['element_id']
    $script:Element = [object[]]@(
        $script:CommandElement
        $script:OptionElement
        (New-DocsReferenceFixedElement -Kind 'http-route' -Declaration 'GET /items' -Path 'src/routes.ts')
        (New-DocsReferenceFixedElement -Kind 'config-key' -Declaration 'tool.level' -Path 'conf/tool.toml')
        (New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration 'Tool.Run' -Path 'src/Tool.cs')
        (New-DocsReferenceFixedElement -Kind 'architecture-component' -Declaration 'Core engine' -Path 'src/core')
    )
    $script:Api = 'docs/reference/api-reference.md'
    $script:Cli = 'docs/reference/cli-reference.md'
    $script:Config = 'docs/reference/config-reference.md'
    $script:Http = 'docs/reference/http-reference.md'
    $script:SnapshotPath = 'docs/documentation-estate/surface-inventory-snapshot.json'

    function Get-TestFileMap {
        # Returns the in-memory repository map with the default profile and elements plus Page.
        param([AllowNull()] [System.Collections.IDictionary] $Page, [object[]] $Element = $script:Element)
        return New-DocsReferenceFileMap -ProfileValue $script:DocsProfile -Element $Element -Page $Page -SchemaTextMap $script:SchemaText
    }

    function Invoke-TestGenerate {
        # Runs generate-reference; returns @{ Outcome; Memory; Envelope } (Envelope is $null for -Text).
        param(
            [string[]] $Argument = @(),
            [AllowNull()] [System.Collections.IDictionary] $File,
            [AllowNull()] [hashtable] $Memory,
            [AllowNull()] [string[]] $WriteFailure,
            [AllowNull()] [scriptblock] $BeforeCall,
            [switch] $Text
        )
        if ($null -eq $Memory) {
            $map = if ($null -eq $File) { Get-TestFileMap } else { $File }
            $Memory = New-DocsReferenceMemoryContext -File $map -WriteTextFailurePath $WriteFailure -BeforeCall $BeforeCall
        }
        $outcome = Invoke-DocsCommandCli -Command 'generate-reference' -CommandArgument $Argument -Context $Memory.Context -Json:(-not $Text)
        $envelope = if ($Text) { $null } else { (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value }
        return @{ Outcome = $outcome; Memory = $Memory; Envelope = $envelope }
    }

    function Get-TestLine {
        # Splits LF-terminated stdout into lines.
        param([string] $Stdout)
        return [string[]] $Stdout.TrimEnd("`n").Split("`n")
    }

    function Get-TestPageField {
        # Returns path=value pairs of one page field from an envelope, in page order.
        param([System.Collections.IDictionary] $Envelope, [string] $Field)
        return [string[]] @($Envelope['result']['pages'] | ForEach-Object { "$($_['path'])=$($_[$Field])" })
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'generate-reference dry run' {
    It 'records no write, exits 0, and prints page lines and hunk headers before the dry-run line' {
        # Act
        $run = Invoke-TestGenerate -Text
        $lines = Get-TestLine -Stdout $run.Outcome.Stdout

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Outcome.Stderr | Should -BeExactly ''
        $run.Memory.WriteLog.Count | Should -Be 0
        $lines | Should -Contain "create $($script:Api) (+1 ~0 -0)"
        $lines | Should -Contain "create $($script:Cli) (+2 ~0 -0)"
        $lines | Should -Contain "create $($script:Config) (+1 ~0 -0)"
        $lines | Should -Contain "create $($script:Http) (+1 ~0 -0)"
        $lines | Should -Contain '--- /dev/null'
        $lines | Should -Contain "+++ b/$($script:Cli)"
        $dryRunAt = [array]::IndexOf($lines, 'dry run, nothing written')
        $dryRunAt | Should -BeGreaterThan ([array]::LastIndexOf($lines, "+++ b/$($script:Http)"))
        $lines[$lines.Count - 1] | Should -BeExactly 'generate-reference: exit=0 errors=0 warnings=0 infos=0'
    }

    It 'returns mode dry-run, status planned and a non-null diff for every create and update page' {
        # Arrange: the API page exists empty and the CLI page exists with author prose.
        $file = Get-TestFileMap -Page @{ $script:Api = ''; $script:Cli = "# CLI reference`n`nAuthor text.`n" }

        # Act
        $run = Invoke-TestGenerate -File $file
        $result = $run.Envelope['result']

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $run.Memory.WriteLog.Count | Should -Be 0
        $result['mode'] | Should -BeExactly 'dry-run'
        $result['output_directory'] | Should -BeExactly 'docs/reference'
        $result['unrendered']['architecture-component'] | Should -Be 1
        Get-TestPageField -Envelope $run.Envelope -Field 'action' | Should -Be @("$($script:Api)=update", "$($script:Cli)=update", "$($script:Config)=create", "$($script:Http)=create")
        Get-TestPageField -Envelope $run.Envelope -Field 'status' | Should -Be @("$($script:Api)=planned", "$($script:Cli)=planned", "$($script:Config)=planned", "$($script:Http)=planned")
        foreach ($page in $result['pages']) {
            $prefix = if ($page['action'] -ceq 'create') { "--- /dev/null`n+++ b/$($page['path'])`n" } else { "--- a/$($page['path'])`n+++ b/$($page['path'])`n" }
            $page['diff'] | Should -Not -BeNullOrEmpty -Because "$($page['path']) is changed"
            $page['diff'].StartsWith($prefix) | Should -BeTrue -Because "$($page['path']) has the hunk header of its action"
        }
    }

    It 'keeps the author prose of an existing page in the planned diff as context, never as an edit' {
        # Arrange
        $file = Get-TestFileMap -Page @{ $script:Cli = "# CLI reference`n`nAuthor text.`n" }

        # Act
        $diff = @((Invoke-TestGenerate -File $file).Envelope['result']['pages'] | Where-Object { $_['path'] -ceq $script:Cli })[0]['diff']
        $diffLines = Get-TestLine -Stdout $diff

        # Assert
        $diffLines | Should -Contain ' Author text.'
        $diffLines | Should -Not -Contain '-Author text.'
    }
}

Describe 'generate-reference write mode' {
    It 'writes one entry per changed page in ordinal path order with create and overwrite modes' {
        # Arrange
        $file = Get-TestFileMap -Page @{ $script:Cli = "# CLI reference`n`nAuthor text.`n" }

        # Act
        $run = Invoke-TestGenerate -Argument @('-Write') -File $file

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        @($run.Memory.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @($script:Api, $script:Cli, $script:Config, $script:Http)
        @($run.Memory.WriteLog | ForEach-Object { $_.Mode }) | Should -Be @('create', 'overwrite', 'create', 'create')
        Get-TestPageField -Envelope $run.Envelope -Field 'status' | Should -Be @("$($script:Api)=created", "$($script:Cli)=updated", "$($script:Config)=created", "$($script:Http)=created")
        $run.Envelope['result']['mode'] | Should -BeExactly 'write'
        @($run.Envelope['result']['pages'] | Where-Object { $null -ne $_['diff'] }).Count | Should -Be 0
    }

    It 'prints one DOCS_PAGE_ORPHAN note per created page and the wrote line' {
        # Act
        $lines = Get-TestLine -Stdout (Invoke-TestGenerate -Argument @('-Write') -Text).Outcome.Stdout
        [string[]] $notes = @($lines | Where-Object { $_.StartsWith('note: ', [System.StringComparison]::Ordinal) })

        # Assert
        $notes.Count | Should -Be 4
        foreach ($note in $notes) { $note | Should -Match 'is new; link it from a documentation entry page so that the check command does not report DOCS_PAGE_ORPHAN$' }
        $lines | Should -Contain 'wrote 4 page(s)'
    }

    It 'records no write on an immediate second run and reports action none and status skipped' {
        # Arrange
        $first = Invoke-TestGenerate -Argument @('-Write')

        # Act
        $second = Invoke-TestGenerate -Argument @('-Write') -Memory $first.Memory
        $text = Invoke-TestGenerate -Argument @('-Write') -Memory $first.Memory -Text

        # Assert
        $second.Outcome.ExitCode | Should -Be 0
        $first.Memory.WriteLog.Count | Should -Be 4
        Get-TestPageField -Envelope $second.Envelope -Field 'action' | Should -Be @("$($script:Api)=none", "$($script:Cli)=none", "$($script:Config)=none", "$($script:Http)=none")
        Get-TestPageField -Envelope $second.Envelope -Field 'status' | Should -Be @("$($script:Api)=skipped", "$($script:Cli)=skipped", "$($script:Config)=skipped", "$($script:Http)=skipped")
        Get-TestLine -Stdout $text.Outcome.Stdout | Should -Contain 'nothing written'
    }
}

Describe 'generate-reference write conflicts and failures' {
    It 'stops at a create conflict, keeps the earlier write and marks later pages not-attempted' {
        # Arrange: the CLI page appears between planning and its write.
        $state = @{ Calls = 0 }
        $hook = {
            param($Member, $Path, $Files)
            if ($Member -ceq 'TestFile' -and $Path -ceq 'docs/reference/cli-reference.md') {
                $state.Calls++
                if ($state.Calls -eq 2) { $Files[$Path] = 'concurrent text' }
            }
        }.GetNewClosure()

        # Act
        $run = Invoke-TestGenerate -Argument @('-Write') -BeforeCall $hook

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        @($run.Envelope['findings'] | ForEach-Object { $_['code'] }) | Should -Be @('REFERENCE_WRITE_CONFLICT')
        $run.Envelope['findings'][0]['artifact_path'] | Should -BeExactly $script:Cli
        $run.Envelope['result'] | Should -Not -BeNullOrEmpty
        @($run.Memory.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @($script:Api)
        Get-TestPageField -Envelope $run.Envelope -Field 'status' | Should -Be @("$($script:Api)=created", "$($script:Cli)=conflict", "$($script:Config)=not-attempted", "$($script:Http)=not-attempted")
        $run.Memory.Files[$script:Cli] | Should -BeExactly 'concurrent text'
    }

    It 'stops at an update conflict when the ReadBytes digest differs from sha256_before' {
        # Arrange: the CLI page exists and changes between planning and its write.
        $state = @{ Calls = 0 }
        $hook = {
            param($Member, $Path, $Files)
            if ($Member -ceq 'ReadBytes' -and $Path -ceq 'docs/reference/cli-reference.md') {
                $state.Calls++
                if ($state.Calls -eq 2) { $Files[$Path] = "# Edited concurrently`n" }
            }
        }.GetNewClosure()
        $file = Get-TestFileMap -Page @{ $script:Cli = "# CLI reference`n" }

        # Act
        $run = Invoke-TestGenerate -Argument @('-Write') -File $file -BeforeCall $hook

        # Assert
        $run.Outcome.ExitCode | Should -Be 1
        @($run.Envelope['findings'] | ForEach-Object { $_['code'] }) | Should -Be @('REFERENCE_WRITE_CONFLICT')
        @($run.Memory.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @($script:Api)
        Get-TestPageField -Envelope $run.Envelope -Field 'status' | Should -Be @("$($script:Api)=created", "$($script:Cli)=conflict", "$($script:Config)=not-attempted", "$($script:Http)=not-attempted")
        $run.Memory.Files[$script:Cli] | Should -BeExactly "# Edited concurrently`n"
    }

    It 'exits 3 with only REFERENCE_WRITE_FAILED, result null and one stderr line when WriteText throws' {
        # Act
        $run = Invoke-TestGenerate -Argument @('-Write') -WriteFailure @($script:Cli)
        $finding = $run.Envelope['findings'][0]

        # Assert
        $run.Outcome.ExitCode | Should -Be 3
        @($run.Envelope['findings'] | ForEach-Object { $_['code'] }) | Should -Be @('REFERENCE_WRITE_FAILED')
        @($finding['related_paths']) | Should -Be @($script:Cli)
        $finding['message'] | Should -Match 'after 1 page\(s\) were written'
        $run.Envelope['result'] | Should -BeNullOrEmpty
        $run.Outcome.Stderr | Should -BeExactly "Invoke-DocsCommand.ps1: exit 3 (REFERENCE_WRITE_FAILED)`n"
        @($run.Memory.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @($script:Api)
    }
}

Describe 'generate-reference determinism' {
    It 'runs with a context whose UtcNow throws and writes LF-only pages with one final LF, no trailing spaces and no BOM' {
        # Act
        $run = Invoke-TestGenerate -Argument @('-Write')
        $clock = $run.Memory.Context.UtcNow

        # Assert
        { & $clock } | Should -Throw
        $run.Outcome.ExitCode | Should -Be 0
        $run.Memory.WriteLog.Count | Should -Be 4
        foreach ($write in $run.Memory.WriteLog) {
            $write.Text.Contains("`r") | Should -BeFalse -Because "$($write.RelativePath) is LF-only"
            $write.Text.EndsWith("`n") | Should -BeTrue -Because "$($write.RelativePath) ends with LF"
            $write.Text.EndsWith("`n`n") | Should -BeFalse -Because "$($write.RelativePath) ends with exactly one LF"
            $write.Text.StartsWith([char]0xFEFF) | Should -BeFalse -Because "$($write.RelativePath) has no BOM"
            @($write.Text.Split("`n") | Where-Object { $_.EndsWith(' ') -or $_.EndsWith("`t") }).Count | Should -Be 0 -Because "$($write.RelativePath) has no trailing spaces"
        }
    }

    It 'reports action none for every page after every analysis_method and digest changes' {
        # Arrange: the same identities with analysis method native and a different source text.
        $first = Invoke-TestGenerate -Argument @('-Write')
        $changed = [object[]] @(foreach ($item in $script:Element) {
                New-DocsReferenceFixedElement -Kind $item['kind'] -Declaration $item['declaration'] -Path $item['path'] -ParentId $item['parent_id'] -AnalysisMethod 'native' -SourceText "changed source`n"
            })
        $first.Memory.Files[$script:SnapshotPath] = ConvertTo-DocsReferenceSnapshotText -Element $changed

        # Act
        $second = Invoke-TestGenerate -Argument @('-Write') -Memory $first.Memory

        # Assert
        @($changed | ForEach-Object { $_['source_sha256'] }) | Should -Not -Be @($script:Element | ForEach-Object { $_['source_sha256'] })
        $second.Outcome.ExitCode | Should -Be 0
        Get-TestPageField -Envelope $second.Envelope -Field 'action' | Should -Be @("$($script:Api)=none", "$($script:Cli)=none", "$($script:Config)=none", "$($script:Http)=none")
        $first.Memory.WriteLog.Count | Should -Be 4
    }
}

Describe 'generate-reference dispatch row' {
    It 'is registered directly under the 1024 anchor with its module, function and options' {
        # Arrange: the loaded dispatch-table function text, not a file read.
        [string[]] $tableLine = @(${function:Get-DocsCommandTable}.ToString().Split("`n") | ForEach-Object { $_.Trim() })
        $anchorAt = [array]::IndexOf($tableLine, '# --- 1024: generate-reference ---')

        # Act
        # Get-DocsCommandTable returns its rows with the unary comma; the assignment unwraps them.
        $table = Get-DocsCommandTable
        $row = @($table | Where-Object { $_.Name -ceq 'generate-reference' })

        # Assert
        $anchorAt | Should -BeGreaterOrEqual 0
        $tableLine[$anchorAt + 1] | Should -BeLike "``[pscustomobject``]@{ Name = 'generate-reference';*"
        $row.Count | Should -Be 1
        Split-Path -Path $row[0].Module -Leaf | Should -BeExactly 'DocsReferenceWriter.psm1'
        $row[0].Function | Should -BeExactly 'Invoke-DocsGenerateReferenceCommand'
        [string[]] $optionName = @($row[0].Option.Keys | ForEach-Object { [string] $_ })
        [Array]::Sort($optionName, [System.StringComparer]::Ordinal)
        $optionName | Should -Be @('OutputDirectory', 'Profile', 'Snapshot', 'Write')
        @('OutputDirectory', 'Profile', 'Snapshot', 'Write' | ForEach-Object { $row[0].Option[$_] }) | Should -Be @('value', 'value', 'value', 'switch')
        [object[]] $tableFinding = Test-DocsCommandTable -Table $table
        $tableFinding.Count | Should -Be 0
    }
}
