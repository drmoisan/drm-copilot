#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for .claude/lib/docs/DocsFamilyCheck.psm1 (issue #1221).

.DESCRIPTION
    Covers Read-DocsFamilyEvidence over the recording in-memory context of
    DocsLedger.TestSupport.psm1 (seam calls, distinct directories, root-file probes),
    Get-DocsFamilyStatus (entry shape, status values, profile order, page rules, the sorted legacy
    list, fail-closed evidence) and Get-DocsFamilyFinding (every row of the family findings
    table). Profiles are in-memory dictionaries; no file is written.
#>

BeforeAll {
    $script:LibraryRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib'
    foreach ($name in 'DocsJson', 'DocsFinding', 'DocsSurface', 'DocsFamilyCheck') {
        Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath "docs/$name.psm1") -Force -ErrorAction Stop
    }
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedger.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ProfilePath = 'docs/documentation-estate/docs-profile.json'

    function Get-TestFamily {
        param([string] $Id, [string] $Directory, [bool] $Required = $true, [string] $Reason)
        $family = [ordered]@{ id = $Id; directory = $Directory; diataxis_mode = 'how-to'; template = "$Id-template"; audience = @('maintainers'); review_interval_days = 90L; required = $Required }
        if ($PSBoundParameters.ContainsKey('Reason')) { $family['exclusion'] = [ordered]@{ reason = $Reason; recorded_at = '2026-11-23T00:00:00Z' } }
        $family
    }

    function Get-TestProfile {
        param([object[]] $Family = @(), [object[]] $Legacy = @())
        [ordered]@{ required_families = [object[]] @($Family); legacy_exclusions = [object[]] @($Legacy) }
    }

    function Read-TestEvidence {
        param([System.Collections.IDictionary] $ProfileDocument, [hashtable] $Test)
        Read-DocsFamilyEvidence -Profile $ProfileDocument -TestFile $Test.Context.TestFile -ListFile $Test.Context.ListFile
    }

    function Get-TestStatusFor {
        # Lists the given files in an in-memory context and returns the status of the profile.
        param([System.Collections.IDictionary] $ProfileDocument, [string[]] $File = @())
        $map = @{}
        foreach ($path in $File) { $map[$path] = '# page' }
        $test = New-DocsLedgerTestContext -File $map
        Get-DocsFamilyStatus -Profile $ProfileDocument -Evidence (Read-TestEvidence -ProfileDocument $ProfileDocument -Test $test)
    }

    function Get-TestFindingFor {
        param([System.Collections.IDictionary] $ProfileDocument, [string[]] $File = @())
        $map = @{}
        foreach ($path in $File) { $map[$path] = '# page' }
        $test = New-DocsLedgerTestContext -File $map
        $findings = Get-DocsFamilyFinding -Profile $ProfileDocument -Evidence (Read-TestEvidence -ProfileDocument $ProfileDocument -Test $test) -ProfilePath $script:ProfilePath
        , [object[]] @($findings)
    }

    function Get-TestCode {
        param([object[]] $Finding, [string] $Code)
        , @($Finding | Where-Object { $_['code'] -ceq $Code })
    }
}

AfterAll {
    Remove-Module -Name 'Docs*', 'DiscoveryEncoding' -Force -ErrorAction SilentlyContinue
}

Describe 'Read-DocsFamilyEvidence' {
    It 'makes no context call for a profile without families and legacy entries' {
        # Arrange
        $test = New-DocsLedgerTestContext -File @{ 'docs/a.md' = '# a'; 'SECURITY.md' = '# s' }

        # Act
        $empty = Read-TestEvidence -ProfileDocument (Get-TestProfile) -Test $test
        $absent = Read-TestEvidence -ProfileDocument ([ordered]@{ repository = [ordered]@{ id = 'fixture-repo' } }) -Test $test

        # Assert
        $test.CallLog.Count | Should -Be 0 -Because 'a profile without families makes no ListFile or TestFile call'
        $empty.PagePath.Count | Should -Be 0
        $empty.RootFile.Count | Should -Be 0
        $absent.PagePath.Count | Should -Be 0
    }

    It 'calls ListFile once per distinct directory and keeps each listing' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'architecture' -Directory 'docs/architecture'), (Get-TestFamily -Id 'adr' -Directory 'docs/architecture/adr'), (Get-TestFamily -Id 'ops-a' -Directory 'docs/ops'), (Get-TestFamily -Id 'ops-b' -Directory 'docs/ops'))
        $test = New-DocsLedgerTestContext -File @{ 'docs/architecture/adr/0001.md' = '# adr'; 'docs/ops/run.md' = '# run' }

        # Act
        $evidence = Read-TestEvidence -ProfileDocument $profileDocument -Test $test

        # Assert
        @($test.CallLog | ForEach-Object { "$($_.Member) $($_.RelativePath)" }) | Should -Be @('ListFile docs/architecture', 'ListFile docs/architecture/adr', 'ListFile docs/ops')
        $evidence.PagePath['docs/architecture'] | Should -Be @('docs/architecture/adr/0001.md')
        $evidence.PagePath['docs/ops'] | Should -Be @('docs/ops/run.md')
        $evidence.RootFile.Count | Should -Be 0 -Because 'no security family means no root probe'
    }

    It 'probes SECURITY.md and CODEOWNERS at the repository root only when a security entry exists' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'security' -Directory 'docs/security'))
        $test = New-DocsLedgerTestContext -File @{ 'SECURITY.md' = '# policy'; '.github/CODEOWNERS' = '* @team' }

        # Act
        $evidence = Read-TestEvidence -ProfileDocument $profileDocument -Test $test

        # Assert
        @($test.CallLog | ForEach-Object { "$($_.Member) $($_.RelativePath)" }) | Should -Be @('ListFile docs/security', 'TestFile SECURITY.md', 'TestFile CODEOWNERS')
        $evidence.RootFile['SECURITY.md'] | Should -BeTrue
        $evidence.RootFile['CODEOWNERS'] | Should -BeFalse -Because '.github/CODEOWNERS does not satisfy the repository-root probe'
    }

    It 'lists a directory once when two entries differ only by a trailing slash' {
        # Arrange: an in-memory profile dictionary passed directly, not through the profile loader (Planner Decision P-1).
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'ops' -Directory 'docs/ops'), (Get-TestFamily -Id 'ops-slash' -Directory 'docs/ops/'))
        $test = New-DocsLedgerTestContext -File @{ 'docs/ops/a.md' = '# a' }

        # Act
        $evidence = Read-TestEvidence -ProfileDocument $profileDocument -Test $test
        $status = Get-DocsFamilyStatus -Profile $profileDocument -Evidence $evidence

        # Assert
        $listCalls = @($test.CallLog | Where-Object { $_.Member -ceq 'ListFile' })
        $listCalls.Count | Should -Be 1
        $listCalls[0].RelativePath | Should -BeExactly 'docs/ops'
        @($status.entries | ForEach-Object { $_['page_count'] }) | Should -Be @(1, 1)
    }
}

Describe 'Get-DocsFamilyStatus' {
    It 'returns one entry per family in profile order with the documented shape and status values' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @(
            (Get-TestFamily -Id 'operations' -Directory 'docs/operations'),
            (Get-TestFamily -Id 'adr' -Directory 'docs/adr'),
            (Get-TestFamily -Id 'user-guides' -Directory 'docs/user-guides' -Reason 'No end users.'))

        # Act
        $status = Get-TestStatusFor -ProfileDocument $profileDocument -File @('docs/operations/runbook.md')

        # Assert
        $status.Keys | Should -Be @('entries', 'legacy_exclusions')
        @($status.entries | ForEach-Object { $_['id'] }) | Should -Be @('operations', 'adr', 'user-guides')
        @($status.entries[0].Keys) | Should -Be @('id', 'directory', 'required', 'template', 'status', 'page_count', 'missing_root_files', 'exclusion')
        @($status.entries | ForEach-Object { $_['status'] }) | Should -Be @('present', 'missing', 'not-applicable')
        $status.entries[0]['directory'] | Should -BeExactly 'docs/operations'
        $status.entries[0]['required'] | Should -BeTrue
        $status.entries[0]['template'] | Should -BeExactly 'operations-template'
        $status.entries[0]['page_count'] | Should -Be 1
        $status.entries[0]['exclusion'] | Should -BeNullOrEmpty
        @($status.entries[0]['missing_root_files']).Count | Should -Be 0
        $status.entries[2]['exclusion'].Keys | Should -Be @('reason', 'recorded_at')
        $status.entries[2]['exclusion']['reason'] | Should -BeExactly 'No end users.'
        $status.entries[2]['exclusion']['recorded_at'] | Should -BeExactly '2026-11-23T00:00:00Z'
    }

    It 'projects legacy_exclusions to path and reason sorted ordinally by path' {
        # Arrange
        $profileDocument = Get-TestProfile -Legacy @(
            [ordered]@{ path = 'docs/old/b.md'; reason = 'Second.' },
            [ordered]@{ path = 'docs/old/B.md'; reason = 'Upper.' },
            [ordered]@{ path = 'docs/old/a.md'; reason = 'First.' })

        # Act
        $status = Get-DocsFamilyStatus -Profile $profileDocument -Evidence $null

        # Assert
        @($status.entries).Count | Should -Be 0
        @($status.legacy_exclusions | ForEach-Object { $_['path'] }) | Should -Be @('docs/old/B.md', 'docs/old/a.md', 'docs/old/b.md')
        @($status.legacy_exclusions[0].Keys) | Should -Be @('path', 'reason')
        $status.legacy_exclusions[0]['reason'] | Should -BeExactly 'Upper.'
    }

    It 'reads $null evidence as empty directories and absent root files (fail closed)' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'security' -Directory 'docs/security'), (Get-TestFamily -Id 'adr' -Directory 'docs/adr'))

        # Act
        $status = Get-DocsFamilyStatus -Profile $profileDocument -Evidence $null

        # Assert
        @($status.entries | ForEach-Object { $_['status'] }) | Should -Be @('missing', 'missing')
        $status.entries[0]['missing_root_files'] | Should -Be @('SECURITY.md', 'CODEOWNERS')
        @($status.entries[1]['missing_root_files']).Count | Should -Be 0
    }

    It 'does not count a legacy-excluded page, so a family whose only page is legacy-excluded is missing' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'operations' -Directory 'docs/operations'), (Get-TestFamily -Id 'adr' -Directory 'docs/adr')) -Legacy @([ordered]@{ path = 'docs/operations/old.md'; reason = 'Retired.' })

        # Act
        $status = Get-TestStatusFor -ProfileDocument $profileDocument -File @('docs/operations/old.md', 'docs/adr/0001.md', 'docs/adr/old.md')

        # Assert
        $status.entries[0]['status'] | Should -BeExactly 'missing'
        $status.entries[0]['page_count'] | Should -Be 0
        $status.entries[1]['page_count'] | Should -Be 2
    }

    It 'does not count a page of a directory that only shares a name prefix' {
        # Arrange: docs/securityx/a.md is not a page of docs/security.
        $evidence = @{ PagePath = @{ 'docs/security' = [string[]]@('docs/securityx/a.md') }; RootFile = @{} }
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'security-docs' -Directory 'docs/security'))

        # Act
        $listed = Get-TestStatusFor -ProfileDocument $profileDocument -File @('docs/securityx/a.md')
        $injected = Get-DocsFamilyStatus -Profile $profileDocument -Evidence $evidence

        # Assert
        $listed.entries[0]['status'] | Should -BeExactly 'missing'
        $injected.entries[0]['page_count'] | Should -Be 0 -Because 'a listing path must begin with the directory followed by a slash'
    }

    It 'counts only .md pages, with an ordinal suffix comparison' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'user-guides' -Directory 'docs/user-guides'), (Get-TestFamily -Id 'adr' -Directory 'docs/adr'))

        # Act
        $status = Get-TestStatusFor -ProfileDocument $profileDocument -File @('docs/user-guides/diagram.png', 'docs/user-guides/notes.txt', 'docs/user-guides/UPPER.MD', 'docs/adr/README.md', 'docs/adr/index.md')

        # Assert
        $status.entries[0]['status'] | Should -BeExactly 'missing' -Because '.png, .txt and .MD are not family pages'
        $status.entries[0]['page_count'] | Should -Be 0
        $status.entries[1]['page_count'] | Should -Be 2 -Because 'README.md and index.md count'
    }

    It 'counts a page under a nested family directory for both families' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'architecture' -Directory 'docs/architecture'), (Get-TestFamily -Id 'adr' -Directory 'docs/architecture/adr'))

        # Act
        $status = Get-TestStatusFor -ProfileDocument $profileDocument -File @('docs/architecture/adr/0001.md')

        # Assert
        @($status.entries | ForEach-Object { $_['status'] }) | Should -Be @('present', 'present')
        @($status.entries | ForEach-Object { $_['page_count'] }) | Should -Be @(1, 1)
    }

    It 'counts a page whose front matter has surface_refs: [] as a family page' {
        # Arrange
        $page = "---`ntitle: Runbook`nsurface_refs: []`n---`n# Runbook`n"
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'operations' -Directory 'docs/operations'))
        $test = New-DocsLedgerTestContext -File @{ 'docs/operations/runbook.md' = $page }

        # Act
        $evidence = Read-TestEvidence -ProfileDocument $profileDocument -Test $test
        $status = Get-DocsFamilyStatus -Profile $profileDocument -Evidence $evidence
        $findings = Get-DocsFamilyFinding -Profile $profileDocument -Evidence $evidence -ProfilePath $script:ProfilePath

        # Assert
        $status.entries[0]['page_count'] | Should -Be 1
        $status.entries[0]['status'] | Should -BeExactly 'present'
        @($findings).Count | Should -Be 0 -Because 'a page with surface_refs: [] produces no family finding'
    }

    It 'skips the root-file check for an excluded security family' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'security' -Directory 'docs/security' -Reason 'Handled by the platform team.'))

        # Act
        $status = Get-DocsFamilyStatus -Profile $profileDocument -Evidence $null

        # Assert
        $status.entries[0]['status'] | Should -BeExactly 'not-applicable'
        @($status.entries[0]['missing_root_files']).Count | Should -Be 0
    }
}

Describe 'Get-DocsFamilyFinding' {
    It 'reports DOCS_FAMILY_PAGE_MISSING for a required family without a page' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'adr' -Directory 'docs/adr' -Required $false), (Get-TestFamily -Id 'operations' -Directory 'docs/operations'))

        # Act
        $findings = Get-TestFindingFor -ProfileDocument $profileDocument

        # Assert
        @($findings).Count | Should -Be 1 -Because 'a required: false family without an exclusion produces no finding'
        $finding = $findings[0]
        $finding['code'] | Should -BeExactly 'DOCS_FAMILY_PAGE_MISSING'
        $finding['severity'] | Should -BeExactly 'error'
        $finding['pointer'] | Should -BeExactly '/required_families/1/directory'
        $finding['artifact_path'] | Should -BeExactly $script:ProfilePath
        $finding['related_ids'] | Should -Be @('operations')
        $finding['related_paths'] | Should -Be @('docs/operations')
        $finding['message'].Contains('operations', [System.StringComparison]::Ordinal) | Should -BeTrue
        $finding['message'].Contains('docs/operations', [System.StringComparison]::Ordinal) | Should -BeTrue
        $finding['next_action'].Contains('docs/operations', [System.StringComparison]::Ordinal) | Should -BeTrue
        $finding['next_action'].Contains('exclusion', [System.StringComparison]::Ordinal) | Should -BeTrue
    }

    It 'reports no family finding once the required family has a page' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'operations' -Directory 'docs/operations'))

        # Act
        $findings = Get-TestFindingFor -ProfileDocument $profileDocument -File @('docs/operations/runbook.md')

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'reports one DOCS_FAMILY_ROOT_FILE_MISSING per absent repository-root file of the required security family' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'architecture' -Directory 'docs/architecture'), (Get-TestFamily -Id 'security' -Directory 'docs/security'))

        # Act
        $findings = Get-TestFindingFor -ProfileDocument $profileDocument -File @('docs/architecture/a.md', 'docs/security/overview.md', '.github/CODEOWNERS', 'docs/CODEOWNERS')
        $root = Get-TestCode -Finding $findings -Code 'DOCS_FAMILY_ROOT_FILE_MISSING'

        # Assert
        @($findings).Count | Should -Be 2
        $root.Count | Should -Be 2
        @($root | ForEach-Object { $_['related_paths'][0] }) | Should -Be @('SECURITY.md', 'CODEOWNERS')
        foreach ($finding in $root) {
            $name = $finding['related_paths'][0]
            $finding['severity'] | Should -BeExactly 'error'
            $finding['pointer'] | Should -BeExactly '/required_families/1'
            $finding['related_ids'] | Should -Be @('security')
            $finding['artifact_path'] | Should -BeExactly $script:ProfilePath
            $finding['message'].Contains($name, [System.StringComparison]::Ordinal) | Should -BeTrue
            $finding['next_action'].Contains($name, [System.StringComparison]::Ordinal) | Should -BeTrue
        }
    }

    It 'reports no root-file finding when both repository-root files exist' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'security' -Directory 'docs/security'))

        # Act
        $findings = Get-TestFindingFor -ProfileDocument $profileDocument -File @('docs/security/overview.md', 'SECURITY.md', 'CODEOWNERS')

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'reports no root-file finding for an optional security family' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'security' -Directory 'docs/security' -Required $false))

        # Act
        $findings = Get-TestFindingFor -ProfileDocument $profileDocument

        # Assert
        @($findings).Count | Should -Be 0
    }

    It 'reports DOCS_FAMILY_NOT_APPLICABLE for an excluded family whether or not it is required' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'security' -Directory 'docs/security' -Reason 'Handled by the platform team.'), (Get-TestFamily -Id 'adr' -Directory 'docs/adr' -Required $false -Reason 'Decisions live elsewhere.'))

        # Act
        $findings = Get-TestFindingFor -ProfileDocument $profileDocument

        # Assert
        @($findings).Count | Should -Be 2 -Because 'an excluded family produces no error and no root-file finding'
        for ($index = 0; $index -lt 2; $index++) {
            $finding = $findings[$index]
            $finding['code'] | Should -BeExactly 'DOCS_FAMILY_NOT_APPLICABLE'
            $finding['severity'] | Should -BeExactly 'info'
            $finding['pointer'] | Should -BeExactly "/required_families/$index/exclusion"
            $finding['artifact_path'] | Should -BeExactly $script:ProfilePath
            @($finding['related_paths']).Count | Should -Be 0
        }
        $findings[0]['related_ids'] | Should -Be @('security')
        $findings[0]['message'].Contains('security', [System.StringComparison]::Ordinal) | Should -BeTrue
        $findings[0]['message'].Contains('Handled by the platform team.', [System.StringComparison]::Ordinal) | Should -BeTrue
        $findings[1]['related_ids'] | Should -Be @('adr')
        $findings[1]['message'].Contains('Decisions live elsewhere.', [System.StringComparison]::Ordinal) | Should -BeTrue
    }

    It 'reports one DOCS_LEGACY_EXCLUSIONS_REPORTED naming every legacy path with its reason and the count' {
        # Arrange
        $profileDocument = Get-TestProfile -Legacy @(
            [ordered]@{ path = 'docs/old/b.md'; reason = 'Superseded by the runbook.' },
            [ordered]@{ path = 'docs/old/a.md'; reason = 'Moved to the wiki.' })

        # Act
        $findings = Get-TestFindingFor -ProfileDocument $profileDocument

        # Assert
        @($findings).Count | Should -Be 1
        $finding = $findings[0]
        $finding['code'] | Should -BeExactly 'DOCS_LEGACY_EXCLUSIONS_REPORTED'
        $finding['severity'] | Should -BeExactly 'info'
        $finding['pointer'] | Should -BeExactly '/legacy_exclusions'
        $finding['artifact_path'] | Should -BeExactly $script:ProfilePath
        @($finding['related_ids']).Count | Should -Be 0
        $finding['related_paths'] | Should -Be @('docs/old/a.md', 'docs/old/b.md')
        foreach ($fragment in 'docs/old/a.md (Moved to the wiki.)', 'docs/old/b.md (Superseded by the runbook.)', ' 2 ') {
            $finding['message'].Contains($fragment, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the message names $fragment"
        }
    }

    It 'reports no legacy finding for an empty legacy_exclusions list' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'adr' -Directory 'docs/adr'))

        # Act
        $findings = Get-TestFindingFor -ProfileDocument $profileDocument -File @('docs/adr/0001.md')

        # Assert
        (Get-TestCode -Finding $findings -Code 'DOCS_LEGACY_EXCLUSIONS_REPORTED').Count | Should -Be 0
        @($findings).Count | Should -Be 0
    }

    It 'fails closed for $null evidence with page and root-file findings' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'security' -Directory 'docs/security'))

        # Act
        $findings = Get-DocsFamilyFinding -Profile $profileDocument -Evidence $null -ProfilePath $script:ProfilePath

        # Assert
        @($findings | ForEach-Object { $_['code'] }) | Should -Be @('DOCS_FAMILY_PAGE_MISSING', 'DOCS_FAMILY_ROOT_FILE_MISSING', 'DOCS_FAMILY_ROOT_FILE_MISSING')
    }

    It 'leaves artifact_path null when the profile path is not a relative path' {
        # Arrange
        $profileDocument = Get-TestProfile -Family @((Get-TestFamily -Id 'adr' -Directory 'docs/adr'))

        # Act
        $findings = Get-DocsFamilyFinding -Profile $profileDocument -Evidence $null -ProfilePath '/abs/docs-profile.json'

        # Assert
        $findings[0]['artifact_path'] | Should -BeNullOrEmpty
    }

    It 'returns no finding for a profile without families and legacy entries' {
        # Act
        $findings = Get-DocsFamilyFinding -Profile (Get-TestProfile) -Evidence $null -ProfilePath $script:ProfilePath

        # Assert
        @($findings).Count | Should -Be 0
    }
}
