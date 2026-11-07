#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Manifest and dependency-graph tests for the documentation-estate epic template (issue #1038).

.DESCRIPTION
    Reads the committed template extensions/drm-copilot/resources/feature-templates/epic/
    documentation-estate/epic.md once and checks it with the pure functions of
    EpicManifest.TestSupport.psm1: the frontmatter parses within the supported YAML subset, the
    manifest meets the epic-orchestrate schema rules, every depends_on entry resolves, the waves are
    cycle-free and equal the '## Planned Waves' list. Positive controls mutate the template text in
    memory and assert the finding code each mutation produces. The suite writes no file, starts no
    process and invokes no Python.
#>

BeforeAll {
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'EpicManifest.TestSupport.psm1') -Force -ErrorAction Stop
    $script:TemplateRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../../extensions/drm-copilot/resources/feature-templates/epic/documentation-estate'))
    $script:TemplateText = Get-Content -LiteralPath (Join-Path -Path $script:TemplateRoot -ChildPath 'epic.md') -Raw
    $script:Manifest = ConvertFrom-EpicManifestFrontmatter -Text $script:TemplateText
    $script:Foundation = @('900001', '900002', '900003', '900004', '900005')
    $script:PageFamily = @('900006', '900007', '900008', '900009', '900010')
    $script:ExitGate = '900011'

    function Get-MutatedTemplateText {
        # Pure: replaces the first occurrence of Old with New in the template text.
        param([Parameter(Mandatory = $true)] [string] $Old, [Parameter(Mandatory = $true)] [string] $New)
        $position = $script:TemplateText.IndexOf($Old, [System.StringComparison]::Ordinal)
        if ($position -lt 0) { throw "The template text holds no '$Old'." }
        return $script:TemplateText.Substring(0, $position) + $New + $script:TemplateText.Substring($position + $Old.Length)
    }

    function Get-FindingCode {
        # Pure: returns the sorted unique codes of a finding list.
        param([AllowNull()] [AllowEmptyCollection()] [object[]] $Finding)
        return [string[]]@(@($Finding) | Where-Object { $null -ne $_ } | ForEach-Object { $_.Code } | Sort-Object -Unique)
    }
}

AfterAll {
    Remove-Module -Name EpicManifest.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'documentation-estate epic template manifest' {
    It 'ships epic.md and README.md and no epic-status.md' {
        # Act
        $names = @(Get-ChildItem -LiteralPath $script:TemplateRoot -File | ForEach-Object { $_.Name } | Sort-Object)

        # Assert
        $names | Should -Be @('epic.md', 'README.md') -Because 'the template folder ships exactly the manifest and its usage page'
        $names | Should -Not -Contain 'epic-status.md'
    }

    It 'parses the frontmatter within the supported subset' {
        # Act
        $parsed = ConvertFrom-EpicManifestFrontmatter -Text $script:TemplateText

        # Assert
        $parsed.Features.Count | Should -Be 11
        $parsed.Intent | Should -Not -BeNullOrEmpty
    }

    It 'declares the documentation-estate epic and its integration branch' {
        # Assert
        $script:Manifest.Scalar['epic'] | Should -BeExactly 'documentation-estate'
        $script:Manifest.Scalar['integration_branch'] | Should -BeExactly 'epic/documentation-estate-integration'
        @(Get-FindingCode -Finding (Get-EpicManifestSchemaFinding -Manifest $script:Manifest)) | Should -Not -Contain 'EPIC_MANIFEST_BRANCH_MISMATCH'
    }

    It 'has a valid created_at timestamp' {
        # Assert
        $script:Manifest.Scalar['created_at'] | Should -Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'
        @(Get-FindingCode -Finding (Get-EpicManifestSchemaFinding -Manifest $script:Manifest)) | Should -Not -Contain 'EPIC_MANIFEST_CREATED_AT_INVALID'
    }

    It 'has an intent block that meets the schema rules' {
        # Assert
        $script:Manifest.Intent['epic_type'] | Should -BeExactly 'enabler'
        $script:Manifest.Intent['business_outcome_hypothesis'].Trim().Length | Should -BeGreaterThan 0
        $script:Manifest.Intent['leading_indicators'].Count | Should -BeGreaterThan 0
        $script:Manifest.Intent['nfrs'].Count | Should -BeGreaterThan 0
        @(Get-FindingCode -Finding (Get-EpicManifestSchemaFinding -Manifest $script:Manifest)) | Should -Not -Contain 'EPIC_MANIFEST_INTENT_INVALID'
    }

    It 'has unique integer issue_num values and unique feature_folder values' {
        # Act
        $issueNums = @($script:Manifest.Features | ForEach-Object { $_['issue_num'] })
        $folders = @($script:Manifest.Features | ForEach-Object { $_['feature_folder'] })

        # Assert
        foreach ($issue in $issueNums) { $issue | Should -Match '^[1-9][0-9]*$' }
        @($issueNums | Sort-Object -Unique).Count | Should -Be $issueNums.Count
        @($folders | Sort-Object -Unique).Count | Should -Be $folders.Count
        @(Get-EpicManifestSchemaFinding -Manifest $script:Manifest).Count | Should -Be 0 -Because 'the template conforms to the manifest schema'
    }

    It 'resolves every depends_on entry to another features entry' {
        # Act
        $result = Get-EpicManifestWave -Manifest $script:Manifest

        # Assert
        @(Get-FindingCode -Finding $result.Findings) | Should -Not -Contain 'EPIC_MANIFEST_UNRESOLVED_DEPENDENCY'
        $result.Wave.Count | Should -Be 11
    }
}

Describe 'documentation-estate epic template waves' {
    BeforeAll {
        $script:Result = Get-EpicManifestWave -Manifest $script:Manifest
    }

    It 'has no self-edge and no cycle' {
        # Assert
        @($script:Result.Findings).Count | Should -Be 0
    }

    It 'places every foundation child in wave 0' {
        # Assert
        foreach ($issue in $script:Foundation) { $script:Result.Wave[$issue] | Should -Be 0 -Because "$issue is a foundation child" }
    }

    It 'places every page-family child in wave 1' {
        # Assert
        foreach ($issue in $script:PageFamily) { $script:Result.Wave[$issue] | Should -Be 1 -Because "$issue is a page-family child" }
    }

    It 'places the exit-gate child alone in the final wave depending on every page-family child' {
        # Arrange
        $final = ($script:Result.Wave.Values | Measure-Object -Maximum).Maximum
        $gate = @($script:Manifest.Features | Where-Object { $_['issue_num'] -ceq $script:ExitGate })[0]

        # Assert
        $script:Result.Wave[$script:ExitGate] | Should -Be $final
        @($script:Result.Wave.Keys | Where-Object { $script:Result.Wave[$_] -eq $final }) | Should -Be @($script:ExitGate)
        @($gate['depends_on'] | Sort-Object) | Should -Be $script:PageFamily
    }

    It 'computes waves equal to the Planned Waves list' {
        # Act
        $planned = Get-EpicPlannedWave -Text $script:TemplateText

        # Assert
        $planned.Count | Should -Be $script:Result.Wave.Count
        foreach ($issue in $script:Result.Wave.Keys) { $planned[$issue] | Should -Be $script:Result.Wave[$issue] -Because "the planned wave of $issue matches the computed wave" }
    }
}

Describe 'documentation-estate epic template positive controls' {
    It 'fails with EPIC_MANIFEST_CYCLE for a two-node cycle' {
        # Arrange: 900001 is the first entry, so its depends_on is the first empty list.
        $text = Get-MutatedTemplateText -Old 'depends_on: []' -New 'depends_on: [900006]'

        # Act
        $result = Get-EpicManifestWave -Manifest (ConvertFrom-EpicManifestFrontmatter -Text $text)

        # Assert
        @(Get-FindingCode -Finding $result.Findings) | Should -Be @('EPIC_MANIFEST_CYCLE')
    }

    It 'fails with EPIC_MANIFEST_UNRESOLVED_DEPENDENCY for an unknown depends_on entry' {
        # Arrange
        $text = Get-MutatedTemplateText -Old 'depends_on: []' -New 'depends_on: [900099]'

        # Act
        $result = Get-EpicManifestWave -Manifest (ConvertFrom-EpicManifestFrontmatter -Text $text)

        # Assert
        @(Get-FindingCode -Finding $result.Findings) | Should -Be @('EPIC_MANIFEST_UNRESOLVED_DEPENDENCY')
    }

    It 'fails with EPIC_MANIFEST_DUPLICATE_ISSUE_NUM for a repeated issue_num' {
        # Arrange
        $text = Get-MutatedTemplateText -Old 'issue_num: 900002' -New 'issue_num: 900001'

        # Act
        $findings = Get-EpicManifestSchemaFinding -Manifest (ConvertFrom-EpicManifestFrontmatter -Text $text)

        # Assert
        @(Get-FindingCode -Finding $findings) | Should -Be @('EPIC_MANIFEST_DUPLICATE_ISSUE_NUM')
    }

    It 'fails with EPIC_MANIFEST_ISSUE_NUM_INVALID for a non-integer issue_num' {
        # Arrange
        $text = Get-MutatedTemplateText -Old 'issue_num: 900002' -New 'issue_num: not-a-number'

        # Act
        $findings = Get-EpicManifestSchemaFinding -Manifest (ConvertFrom-EpicManifestFrontmatter -Text $text)

        # Assert
        @(Get-FindingCode -Finding $findings) | Should -Be @('EPIC_MANIFEST_ISSUE_NUM_INVALID')
    }

    It 'fails with EPIC_MANIFEST_SELF_EDGE for a self-dependency' {
        # Arrange
        $text = Get-MutatedTemplateText -Old 'depends_on: []' -New 'depends_on: [900001]'

        # Act
        $result = Get-EpicManifestWave -Manifest (ConvertFrom-EpicManifestFrontmatter -Text $text)

        # Assert
        @(Get-FindingCode -Finding $result.Findings) | Should -Be @('EPIC_MANIFEST_SELF_EDGE')
    }

    It 'fails with EPIC_MANIFEST_UNSUPPORTED for a flow mapping' {
        # Arrange
        $text = Get-MutatedTemplateText -Old 'epic: documentation-estate' -New "epic: documentation-estate`nowner: {name: someone}"

        # Act and Assert
        { ConvertFrom-EpicManifestFrontmatter -Text $text } | Should -Throw -ExpectedMessage 'EPIC_MANIFEST_UNSUPPORTED*'
    }

    It 'states placement, paired fields, the /epic-plan invocation and that no command copies the template' {
        # Arrange
        $readme = Get-Content -LiteralPath (Join-Path -Path $script:TemplateRoot -ChildPath 'README.md') -Raw
        $normalized = ($readme -replace "`r`n", "`n") -replace '\s+', ' '

        # Assert
        foreach ($statement in @(
                'Copy `epic.md` to `docs/features/epics/<slug>/epic.md`',
                'change `epic` and `integration_branch` together',
                'Run `/epic-plan docs/features/epics/<slug>/epic.md`',
                'No command copies the template'
            )) {
            $normalized.Contains($statement) | Should -BeTrue -Because "the template README states '$statement'"
        }
    }
}
