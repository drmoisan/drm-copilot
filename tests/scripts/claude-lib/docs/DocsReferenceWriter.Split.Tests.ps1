#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Command tests of the reference page split in generate-reference (issue #1173 B5).

.DESCRIPTION
    Every test runs Invoke-DocsCommandCli -Command generate-reference -Write (Invoke-DocsCommand.ps1
    is dot-sourced) against an in-memory command context from DocsReference.TestSupport.psm1. The
    API family holds three elements whose declarations make the rendered family page larger than
    921,600 UTF-8 bytes, under the profile source root 'src'. Covered: the index at the family path
    plus one page per group, each written text at or below the budget; a listed existing split
    page updated in place; and a stale listed split page reported and neither written nor deleted.
    No file is read or written outside the in-memory map.
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop
    . (Join-Path -Path $script:LibRoot -ChildPath 'Invoke-DocsCommand.ps1')

    $script:SchemaText = Get-DocsReferenceSchemaTextMap
    $script:DocsProfile = New-DocsReferenceFixedProfile
    $script:Budget = 921600
    $script:Large = [object[]]@(
        (New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration ('Alpha' + ('a' * 350000)) -Path 'src/alpha/a.py')
        (New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration ('Beta' + ('b' * 350000)) -Path 'src/beta/b.py')
        (New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration ('Top' + ('c' * 350000)) -Path 'src/c.py')
    )
    $script:Api = 'docs/reference/api-reference.md'
    $script:Alpha = 'docs/reference/api-reference/alpha.md'
    $script:Beta = 'docs/reference/api-reference/beta.md'
    $script:Root = 'docs/reference/api-reference/_root.md'

    function Invoke-TestSplitGenerate {
        # Runs generate-reference -Write; returns @{ Outcome; Memory; Envelope }.
        param([AllowNull()] [System.Collections.IDictionary] $Page, [AllowNull()] [hashtable] $Memory)
        if ($null -eq $Memory) {
            $map = New-DocsReferenceFileMap -ProfileValue $script:DocsProfile -Element $script:Large -Page $Page -SchemaTextMap $script:SchemaText
            $Memory = New-DocsReferenceMemoryContext -File $map
        }
        $outcome = Invoke-DocsCommandCli -Command 'generate-reference' -CommandArgument @('-Write') -Context $Memory.Context -Json
        return @{ Outcome = $outcome; Memory = $Memory; Envelope = (ConvertFrom-DocsJsonText -Text $outcome.Stdout).Value }
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Function:\Invoke-TestSplitGenerate -ErrorAction SilentlyContinue
}

Describe 'generate-reference split of a family above the budget' {
    It 'writes the index at the family path plus one page per group, each at or below 921,600 UTF-8 bytes' {
        # Act
        $run = Invoke-TestSplitGenerate

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        @($run.Memory.WriteLog | ForEach-Object { $_.RelativePath }) | Should -Be @($script:Api, $script:Root, $script:Alpha, $script:Beta)
        foreach ($entry in $run.Memory.WriteLog) {
            [System.Text.Encoding]::UTF8.GetByteCount($entry.Text) | Should -BeLessOrEqual $script:Budget -Because "$($entry.RelativePath) stays within the page budget"
        }
        $index = $run.Memory.Files[$script:Api]
        $index | Should -Match ([regex]::Escape('- [alpha](api-reference/alpha.md)'))
        $index | Should -Match ([regex]::Escape('- [beta](api-reference/beta.md)'))
        $index | Should -Match ([regex]::Escape('- [_root](api-reference/_root.md)'))
        $run.Memory.Files[$script:Alpha] | Should -Match 'Alpha'
        $run.Memory.Files[$script:Alpha] | Should -Not -Match 'Beta'
        $run.Memory.CallLog | Should -Contain 'ListFile docs/reference'
    }

    It 'updates a listed existing split page in place and leaves an unchanged group page untouched' {
        # Arrange: the first run writes the split pages; the snapshot then gains one alpha element.
        $first = Invoke-TestSplitGenerate
        $extra = New-DocsReferenceFixedElement -Kind 'public-symbol' -Declaration 'AlphaExtra' -Path 'src/alpha/z.py'
        $first.Memory.Files['docs/documentation-estate/surface-inventory-snapshot.json'] = ConvertTo-DocsReferenceSnapshotText -Element (@($script:Large) + @($extra))
        $first.Memory.WriteLog.Clear()

        # Act
        $second = Invoke-TestSplitGenerate -Memory $first.Memory

        # Assert
        $second.Outcome.ExitCode | Should -Be 0
        @($second.Memory.WriteLog | ForEach-Object { "$($_.RelativePath)=$($_.Mode)" }) | Should -Be @("$($script:Alpha)=overwrite")
        $actions = @($second.Envelope['result']['pages'] | ForEach-Object { "$($_['path'])=$($_['action'])" })
        $actions | Should -Contain "$($script:Alpha)=update"
        $actions | Should -Contain "$($script:Beta)=none"
        $second.Memory.Files[$script:Alpha] | Should -Match 'AlphaExtra'
    }

    It 'reports a stale listed split page as REFERENCE_SPLIT_GROUP_STALE and neither writes nor deletes it' {
        # Arrange
        $stale = 'docs/reference/api-reference/gone.md'
        $staleText = "# Gone`n`nAuthor text.`n"

        # Act
        $run = Invoke-TestSplitGenerate -Page @{ $stale = $staleText }

        # Assert
        $run.Outcome.ExitCode | Should -Be 0
        $finding = @($run.Envelope['findings'] | Where-Object { $_['code'] -ceq 'REFERENCE_SPLIT_GROUP_STALE' })
        $finding.Count | Should -Be 1
        $finding[0]['severity'] | Should -BeExactly 'warning'
        $finding[0]['artifact_path'] | Should -BeExactly $stale
        @($run.Memory.WriteLog | Where-Object { $_.RelativePath -ceq $stale }).Count | Should -Be 0
        $run.Memory.Files[$stale] | Should -BeExactly $staleText
    }
}
