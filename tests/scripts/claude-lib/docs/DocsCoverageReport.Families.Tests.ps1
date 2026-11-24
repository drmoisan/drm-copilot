#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the documentation family section of the coverage report in
    .claude/lib/docs/DocsCoverageReport.psm1 and its assignment in Invoke-DocsCoverageCommand
    (issue #1221).

.DESCRIPTION
    Covers Get-DocsCoverageFamilySection (shape, empty arrays), ConvertTo-DocsCoverageFamilyLine
    (summary line, family lines with the missing_root_files suffix, legacy-exclusion lines), the
    delegating line in ConvertTo-DocsCoverageReportLine, the unchanged six keys of
    Get-DocsCoverageReport, and the coverage command over the recording in-memory context of
    DocsLedger.TestSupport.psm1. Profiles and evidence are in-memory; no file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsSchema', 'DocsProfile', 'DocsLedger', 'DocsLedgerRules', 'DocsParity', 'DocsEvidencePins', 'DocsStaleness', 'DocsReceipt', 'DocsFamilyCheck', 'DocsValidation', 'DocsLedgerMutation', 'DocsCoverageReport', 'DocsLedgerCommands') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'

    function Get-TestFamily {
        param([string] $Id, [string] $Directory = "docs/$Id", [bool] $Required = $true, [string] $Reason)
        $family = [ordered]@{ id = $Id; directory = $Directory; diataxis_mode = 'how-to'; template = 'runbook'; audience = @('maintainers'); review_interval_days = 90L; required = $Required }
        if ($PSBoundParameters.ContainsKey('Reason')) { $family['exclusion'] = [ordered]@{ reason = $Reason; recorded_at = '2026-11-23T00:00:00Z' } }
        $family
    }

    function Get-TestEvidence {
        param([hashtable] $Listing = @{}, [hashtable] $Root = @{})
        $pagePath = [System.Collections.Generic.Dictionary[string, string[]]]::new([System.StringComparer]::Ordinal)
        foreach ($key in $Listing.Keys) { $pagePath[[string] $key] = [string[]] @($Listing[$key]) }
        $rootFile = [System.Collections.Generic.Dictionary[string, bool]]::new([System.StringComparer]::Ordinal)
        foreach ($key in $Root.Keys) { $rootFile[[string] $key] = [bool] $Root[$key] }
        @{ PagePath = $pagePath; RootFile = $rootFile }
    }

    function Get-TestReport {
        # A minimal report in the shape ConvertTo-DocsCoverageReportLine reads, plus an optional families section.
        param([object] $Families)
        $report = [ordered]@{
            totals           = [ordered]@{ elements_total = 0; undocumented = 0; stale_pages = 0; by_disposition = [ordered]@{ documented = 0; excluded = 0; deferred = 0 }; by_analysis_method = [ordered]@{ native = 0; scanner = 0 } }
            undocumented     = [object[]] @()
            deferred         = [object[]] @()
            precision_limits = [object[]] @()
            stale_pages      = [object[]] @()
            parity           = [ordered]@{}
        }
        if ($null -ne $Families) { $report['families'] = $Families }
        $report
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsCoverageFamilySection' {
    It 'returns entries and legacy_exclusions as empty arrays for a profile without families' {
        # Act
        $section = Get-DocsCoverageFamilySection -Profile ([ordered]@{ required_families = @(); legacy_exclusions = @() }) -Evidence (Get-TestEvidence)
        $absent = Get-DocsCoverageFamilySection -Profile ([ordered]@{}) -Evidence $null

        # Assert
        @($section.Keys) | Should -Be @('entries', 'legacy_exclusions')
        @($section['entries']).Count | Should -Be 0
        @($section['legacy_exclusions']).Count | Should -Be 0
        @($absent['entries']).Count | Should -Be 0
        (ConvertTo-DocsJsonText -Value $section).TrimEnd() | Should -BeExactly '{"entries":[],"legacy_exclusions":[]}'
    }

    It 'returns the status entries and the sorted legacy list of the profile' {
        # Arrange
        $profileDocument = [ordered]@{ required_families = @((Get-TestFamily -Id 'operations'), (Get-TestFamily -Id 'adr')); legacy_exclusions = @([ordered]@{ path = 'docs/z.md'; reason = 'Z.' }, [ordered]@{ path = 'docs/a.md'; reason = 'A.' }) }

        # Act
        $section = Get-DocsCoverageFamilySection -Profile $profileDocument -Evidence (Get-TestEvidence -Listing @{ 'docs/operations' = @('docs/operations/run.md') })

        # Assert
        @($section['entries'] | ForEach-Object { "$($_['id']) $($_['status'])" }) | Should -Be @('operations present', 'adr missing')
        @($section['legacy_exclusions'] | ForEach-Object { $_['path'] }) | Should -Be @('docs/a.md', 'docs/z.md')
    }
}

Describe 'ConvertTo-DocsCoverageFamilyLine' {
    It 'adds the zero summary line through ConvertTo-DocsCoverageReportLine for a profile without families' {
        # Arrange
        $report = Get-TestReport -Families (Get-DocsCoverageFamilySection -Profile ([ordered]@{}) -Evidence $null)

        # Act
        $lines = ConvertTo-DocsCoverageReportLine -Report $report

        # Assert
        $lines[-1] | Should -BeExactly 'families: required=0 present=0 missing=0 not_applicable=0 legacy_exclusions=0'
        @($lines | Where-Object { $_.StartsWith('famil', [System.StringComparison]::Ordinal) }).Count | Should -Be 1
    }

    It 'emits no family line from ConvertTo-DocsCoverageReportLine for a report without a families key' {
        # Act
        $lines = ConvertTo-DocsCoverageReportLine -Report (Get-TestReport)

        # Assert
        @($lines | Where-Object { $_.StartsWith('famil', [System.StringComparison]::Ordinal) }).Count | Should -Be 0
    }

    It 'emits one family line per entry with the missing_root_files suffix only when it is not empty' {
        # Arrange
        $profileDocument = [ordered]@{ required_families = @((Get-TestFamily -Id 'security'), (Get-TestFamily -Id 'operations')) }
        $section = Get-DocsCoverageFamilySection -Profile $profileDocument -Evidence (Get-TestEvidence -Listing @{ 'docs/security' = @('docs/security/a.md'); 'docs/operations' = @('docs/operations/a.md', 'docs/operations/b.md') } -Root @{ 'SECURITY.md' = $false; 'CODEOWNERS' = $false })

        # Act
        $lines = ConvertTo-DocsCoverageFamilyLine -Section $section

        # Assert
        $lines | Should -Be @(
            'families: required=2 present=2 missing=0 not_applicable=0 legacy_exclusions=0',
            'family security present pages=1 docs/security missing_root_files=SECURITY.md,CODEOWNERS',
            'family operations present pages=2 docs/operations')
    }

    It 'emits one legacy-exclusion line per legacy entry' {
        # Arrange
        $profileDocument = [ordered]@{ legacy_exclusions = @([ordered]@{ path = 'docs/old/b.md'; reason = 'Superseded.' }, [ordered]@{ path = 'docs/old/a.md'; reason = 'Moved.' }) }

        # Act
        $lines = ConvertTo-DocsCoverageFamilyLine -Section (Get-DocsCoverageFamilySection -Profile $profileDocument -Evidence $null)

        # Assert
        $lines | Should -Be @(
            'families: required=0 present=0 missing=0 not_applicable=0 legacy_exclusions=2',
            'legacy-exclusion docs/old/a.md: Moved.',
            'legacy-exclusion docs/old/b.md: Superseded.')
    }

    It 'counts a mixed families section in the summary line' {
        # Arrange: required with a page, required without a page, required with an exclusion, optional without exclusion or page.
        $profileDocument = [ordered]@{
            required_families = @(
                (Get-TestFamily -Id 'operations'),
                (Get-TestFamily -Id 'adr'),
                (Get-TestFamily -Id 'security' -Reason 'Platform owned.'),
                (Get-TestFamily -Id 'user-guides' -Required $false))
            legacy_exclusions = @([ordered]@{ path = 'docs/old/a.md'; reason = 'Moved.' }, [ordered]@{ path = 'docs/old/b.md'; reason = 'Superseded.' })
        }
        $evidence = Get-TestEvidence -Listing @{ 'docs/operations' = @('docs/operations/run.md') }

        # Act
        $lines = ConvertTo-DocsCoverageFamilyLine -Section (Get-DocsCoverageFamilySection -Profile $profileDocument -Evidence $evidence)

        # Assert: status counts span every entry (Planner Decision P-2).
        $lines[0] | Should -BeExactly 'families: required=3 present=1 missing=2 not_applicable=1 legacy_exclusions=2'
        $lines[3] | Should -BeExactly 'family security not-applicable pages=0 docs/security'
        $lines.Count | Should -Be 7
    }
}

Describe 'Get-DocsCoverageReport keys' {
    It 'still returns exactly its six keys' {
        # Arrange
        $text = ConvertTo-DocsJsonText -Value (New-DocsLedgerTestSnapshot)
        $view = ConvertTo-DocsSnapshotView -Snapshot (ConvertFrom-DocsJsonText -Text $text).Value -SnapshotSha256 (Get-DocsSha256Hex -Text $text)

        # Act
        $report = Get-DocsCoverageReport -SnapshotView $view -Ledger (New-DocsLedgerTestLedger -SnapshotSha256 $view.Sha256 -Entry @()) -Matrix (New-DocsLedgerTestMatrix -SnapshotSha256 $view.Sha256 -LedgerSha256 ('0' * 64) -Row @()) -PinSet (New-DocsLedgerTestPinSet -Pin @())

        # Assert
        @($report.Keys) | Should -Be @('totals', 'undocumented', 'deferred', 'precision_limits', 'stale_pages', 'parity')
    }
}

Describe 'Invoke-DocsCoverageCommand families section' {
    It 'reports a present family through the coverage command' {
        # Arrange
        $profileDocument = New-DocsLedgerTestProfile -RequiredFamily @((Get-TestFamily -Id 'onboarding' -Directory 'docs/onboarding'))
        $test = New-DocsLedgerTestContext -File ([ordered]@{
                $script:ProfilePath                      = (ConvertTo-DocsJsonText -Value $profileDocument -Indented)
                'estate/surface-inventory-snapshot.json' = (ConvertTo-DocsJsonText -Value (New-DocsLedgerTestSnapshot) -Indented)
                'docs/onboarding/index.md'               = '# Onboarding'
            })

        # Act
        $run = Invoke-DocsCoverageCommand -Argument @{ Profile = $script:ProfilePath } -Context $test.Context

        # Assert
        $run.ExitCode | Should -Be 0
        $run.Result['families']['entries'][0]['status'] | Should -BeExactly 'present'
        $run.Result['families']['entries'][0]['page_count'] | Should -Be 1
        @($test.CallLog | Where-Object { $_.Member -ceq 'ListFile' -and $_.RelativePath -ceq 'docs/onboarding' }).Count | Should -Be 1
        $run.Line | Should -Contain 'family onboarding present pages=1 docs/onboarding'
    }
}
