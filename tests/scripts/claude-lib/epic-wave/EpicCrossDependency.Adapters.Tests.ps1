#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Adapter tests for EpicCrossDependency.psm1 (issue #1162).

.DESCRIPTION
    Mocks only the two process wrappers, Invoke-EpicCrossGhExe and Invoke-EpicCrossGitExe,
    with matching parameter names. Asserts the exact argument arrays of the gather adapters
    and that a wrapper failure, invalid JSON, a thrown wrapper, and an ancestry exit of 2
    give hold with PREREQ_UNVERIFIABLE or MAIN_PREREQ_UNVERIFIABLE. Responses are keyed by
    the joined argument array and held in module script scope for the duration of one test.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    Import-Module -Name (Join-Path $script:RepoRoot '.claude/lib/epic-wave/EpicCrossDependency.psm1') -Force -ErrorAction Stop

    $script:Consumer = (@(
            '---', 'epic: consumer', 'integration_branch: epic/consumer-integration', 'features:',
            '  - issue_num: 1201', '    feature_folder: 2026-11-10-consumer-1201', '    depends_on: []',
            '    cross_epic_depends_on: [{ epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 1188 }]',
            '---') -join "`n")
    $script:ProviderText = (@(
            '---', 'epic: provider-epic', 'integration_branch: epic/provider-epic-integration', 'features:',
            '  - issue_num: 1188', '    feature_folder: docs/features/active/2026-11-01-provider-1188', '    depends_on: []', '---') -join "`n")
    $script:ShowBranch = 'show origin/epic/provider-epic-integration:docs/features/epics/provider-epic/epic.md'
    $script:ShowMain = 'show origin/main:docs/features/epics/provider-epic/epic.md'
    $script:FeatureList = 'pr list --base epic/provider-epic-integration --state merged --limit 200 --json number,headRefName,mergeCommit,files'
    $script:MainList = 'pr list --head epic/provider-epic-integration --base main --state merged --json number,mergeCommit'
    $script:Merged = '[{"number":41,"headRefName":"feature/provider-1188","mergeCommit":{"oid":"sha41"},"files":[{"path":"docs/features/active/2026-11-01-provider-1188/spec.md"}]}]'

    # Responses of a merged prerequisite that is not yet integrated (merge_required).
    $script:BaseGit = @{
        'fetch -q origin'                                                      = @{ ExitCode = 0; Output = '' }
        $script:ShowBranch                                                     = @{ ExitCode = 0; Output = $script:ProviderText }
        'merge-base --is-ancestor sha41 origin/epic/provider-epic-integration' = @{ ExitCode = 0; Output = '' }
        'merge-base --is-ancestor sha41 origin/epic/consumer-integration'      = @{ ExitCode = 1; Output = '' }
        'merge-base --is-ancestor m90 origin/main'                             = @{ ExitCode = 0; Output = '' }
    }
    $script:BaseGh = @{
        $script:FeatureList = @{ ExitCode = 0; Output = $script:Merged }
        $script:MainList    = @{ ExitCode = 0; Output = '[{"number":90,"mergeCommit":{"oid":"m90"}}]' }
    }

    # Copy a response table and apply overrides; a $null override removes the key.
    $script:Table = {
        param([hashtable] $Base, [hashtable] $Override = @{})
        $copy = @{}
        foreach ($key in $Base.Keys) { $copy[$key] = $Base[$key] }
        foreach ($key in $Override.Keys) { if ($null -eq $Override[$key]) { $copy.Remove($key) } else { $copy[$key] = $Override[$key] } }
        $copy
    }
}

AfterAll {
    Remove-Module -Name EpicCrossDependency -Force -ErrorAction SilentlyContinue
}

Describe 'Gather adapter argument arrays' {
    It 'reads the other manifest from the integration branch first' {
        InModuleScope EpicCrossDependency -Parameters @{ Text = $script:ProviderText } {
            param($Text)
            $null = @($Text)
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) $null = $GitArgs; [pscustomobject]@{ ExitCode = 0; Output = $Text } }

            $result = Read-EpicCrossManifestText -Epic 'provider-epic' -IntegrationBranch 'epic/provider-epic-integration'

            $result.Source | Should -BeExactly 'branch'
            $result.Text | Should -BeExactly $Text
            Should -Invoke Invoke-EpicCrossGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join '|') -ceq 'show|origin/epic/provider-epic-integration:docs/features/epics/provider-epic/epic.md' }
        }
    }

    It 'falls back to origin/main and then to an empty source' {
        InModuleScope EpicCrossDependency {
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) [pscustomobject]@{ ExitCode = $(if ($GitArgs[1] -like 'origin/main:*') { 0 } else { 128 }); Output = 'main text' } }
            $fromMain = Read-EpicCrossManifestText -Epic 'p' -IntegrationBranch 'epic/p-integration'

            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) $null = $GitArgs; [pscustomobject]@{ ExitCode = 128; Output = '' } }
            $absent = Read-EpicCrossManifestText -Epic 'p' -IntegrationBranch 'epic/p-integration'

            "$($fromMain.Source)|$($fromMain.Text)|$($absent.Source)|$($absent.Text)" | Should -BeExactly 'main|main text||'
            Should -Invoke Invoke-EpicCrossGitExe -Times 4 -Exactly -ParameterFilter { $GitArgs[0] -ceq 'show' }
        }
    }

    It 'lists merged PRs with the exact <Mode> arguments' -ForEach @(
        @{ Mode = 'feature'; Expected = 'pr|list|--base|epic/p-integration|--state|merged|--limit|200|--json|number,headRefName,mergeCommit,files' }
        @{ Mode = 'main'; Expected = 'pr|list|--head|epic/p-integration|--base|main|--state|merged|--json|number,mergeCommit' }
    ) {
        InModuleScope EpicCrossDependency -Parameters @{ Mode = $Mode; Expected = $Expected } {
            param($Mode, $Expected)
            $null = @($Mode, $Expected)
            Mock Invoke-EpicCrossGhExe { param([string[]] $GhArgs) [pscustomobject]@{ ExitCode = 0; Output = ($GhArgs -join '|') } }

            (Get-EpicCrossPrSnapshot -IntegrationBranch 'epic/p-integration' -Mode $Mode).Output | Should -BeExactly $Expected
        }
    }

    It 'returns the merge-base exit code <Exit> unchanged' -ForEach @(@{ Exit = 0 }, @{ Exit = 1 }, @{ Exit = 128 }) {
        InModuleScope EpicCrossDependency -Parameters @{ Exit = $Exit } {
            param($Exit)
            $null = @($Exit)
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) $null = $GitArgs; [pscustomobject]@{ ExitCode = $Exit; Output = '' } }

            Test-EpicCrossAncestor -Commit 'abc' -Ref 'origin/main' | Should -Be $Exit
            Should -Invoke Invoke-EpicCrossGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join '|') -ceq 'merge-base|--is-ancestor|abc|origin/main' }
        }
    }
}

Describe 'Feature readiness through the wrappers' {
    It 'gives <Decision> with <Reason> for <Name>' -ForEach @(
        @{ Name = 'a merged, unintegrated prerequisite'; Git = @{}; Gh = @{}; Decision = 'merge_required'; Reason = 'PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED' }
        @{ Name = 'an integrated prerequisite'; Git = @{ 'merge-base --is-ancestor sha41 origin/epic/consumer-integration' = @{ ExitCode = 0; Output = '' } }; Gh = @{}; Decision = 'release'; Reason = 'PREREQ_ALREADY_INTEGRATED' }
        @{ Name = 'a deleted branch with the commit in main'; Git = @{ 'SHOWBRANCH' = $null; 'SHOWMAIN' = @{ ExitCode = 0; Output = 'PROVIDER' }; 'merge-base --is-ancestor sha41 origin/main' = @{ ExitCode = 0; Output = '' } }; Gh = @{}; Decision = 'release'; Reason = 'PREREQ_IN_MAIN' }
        @{ Name = 'a rewritten other branch'; Git = @{ 'merge-base --is-ancestor sha41 origin/epic/provider-epic-integration' = @{ ExitCode = 1; Output = '' } }; Gh = @{}; Decision = 'hold'; Reason = 'PREREQ_NOT_ANCESTOR' }
        @{ Name = 'a gh failure'; Git = @{}; Gh = @{ 'FEATURELIST' = @{ ExitCode = 1; Output = '' } }; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Name = 'invalid snapshot JSON'; Git = @{}; Gh = @{ 'FEATURELIST' = @{ ExitCode = 0; Output = '{not json' } }; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Name = 'an ancestry exit of 2'; Git = @{ 'merge-base --is-ancestor sha41 origin/epic/provider-epic-integration' = @{ ExitCode = 2; Output = '' } }; Gh = @{}; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Name = 'a failed fetch'; Git = @{ 'fetch -q origin' = @{ ExitCode = 1; Output = '' } }; Gh = @{}; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Name = 'an unreadable other manifest'; Git = @{ 'SHOWBRANCH' = $null }; Gh = @{}; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Name = 'a prerequisite missing from the other manifest'; Git = @{ 'SHOWBRANCH' = @{ ExitCode = 0; Output = "---`nepic: provider-epic`nfeatures:`n  - issue_num: 7`n---" } }; Gh = @{}; Decision = 'hold'; Reason = 'PREREQ_UNVERIFIABLE' }
        @{ Name = 'no matching PR'; Git = @{}; Gh = @{ 'FEATURELIST' = @{ ExitCode = 0; Output = '[]' } }; Decision = 'hold'; Reason = 'PREREQ_PR_NOT_FOUND' }
    ) {
        $names = @{ SHOWBRANCH = $script:ShowBranch; SHOWMAIN = $script:ShowMain; FEATURELIST = $script:FeatureList }
        $resolve = { param([hashtable] $Raw) $out = @{}; foreach ($k in $Raw.Keys) { $key = if ($names.ContainsKey($k)) { $names[$k] } else { $k }; $value = $Raw[$k]; if ($value -is [hashtable] -and $value.Output -eq 'PROVIDER') { $value = @{ ExitCode = 0; Output = $script:ProviderText } }; $out[$key] = $value }; $out }
        $git = & $script:Table $script:BaseGit (& $resolve $Git)
        $gh = & $script:Table $script:BaseGh (& $resolve $Gh)

        InModuleScope EpicCrossDependency -Parameters @{ GitTable = $git; GhTable = $gh; Text = $script:Consumer; Expected = "$Decision|$Reason" } {
            param($GitTable, $GhTable, $Text, $Expected)
            $null = @($GitTable, $GhTable, $Text, $Expected)
            $script:TestGit = $GitTable
            $script:TestGh = $GhTable
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) $r = $script:TestGit[($GitArgs -join ' ')]; if ($null -eq $r) { $r = @{ ExitCode = 128; Output = '' } }; [pscustomobject] $r }
            Mock Invoke-EpicCrossGhExe { param([string[]] $GhArgs) $r = $script:TestGh[($GhArgs -join ' ')]; if ($null -eq $r) { $r = @{ ExitCode = 1; Output = '' } }; [pscustomobject] $r }
            Mock Get-EpicCrossUtcNow { [datetime]::new(2026, 11, 10, 12, 0, 0, [DateTimeKind]::Utc) }

            $result = Invoke-EpicCrossReadinessCommand -Mode feature -ManifestPath 'epic.md' -Issue '1201' -ReadManifestText { $Text }.GetNewClosure()
            $script:TestGit = $null
            $script:TestGh = $null

            $result.ExitCode | Should -Be 0
            $json = $result.Stdout | ConvertFrom-Json
            "$($json.Decision)|$($json.Reason)" | Should -BeExactly $Expected
        }
    }

    It 'holds with PREREQ_UNVERIFIABLE when a wrapper throws' {
        InModuleScope EpicCrossDependency -Parameters @{ Text = $script:Consumer } {
            param($Text)
            $null = @($Text)
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) if ($GitArgs[0] -eq 'fetch') { [pscustomobject]@{ ExitCode = 0; Output = '' } } else { throw 'git missing' } }
            Mock Invoke-EpicCrossGhExe { param([string[]] $GhArgs) $null = $GhArgs; throw 'gh missing' }
            Mock Get-EpicCrossUtcNow { [datetime]::new(2026, 11, 10, 12, 0, 0, [DateTimeKind]::Utc) }

            $json = (Invoke-EpicCrossReadinessCommand -Mode feature -ManifestPath 'epic.md' -ReadManifestText { $Text }.GetNewClosure()).Stdout | ConvertFrom-Json

            "$($json.Decision)|$($json.Reason)" | Should -BeExactly 'hold|PREREQ_UNVERIFIABLE'
        }
    }

    It 'holds with PREREQ_UNVERIFIABLE when the fetch wrapper throws' {
        InModuleScope EpicCrossDependency -Parameters @{ Text = $script:Consumer } {
            param($Text)
            $null = @($Text)
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) $null = $GitArgs; throw 'git missing' }
            Mock Invoke-EpicCrossGhExe { param([string[]] $GhArgs) $null = $GhArgs; [pscustomobject]@{ ExitCode = 0; Output = '[]' } }
            Mock Get-EpicCrossUtcNow { [datetime]::new(2026, 11, 10, 12, 0, 0, [DateTimeKind]::Utc) }

            $json = (Invoke-EpicCrossReadinessCommand -Mode main -ManifestPath 'epic.md' -ReadManifestText { $Text }.GetNewClosure()).Stdout | ConvertFrom-Json

            "$($json.Decision)|$($json.Reason)" | Should -BeExactly 'hold|MAIN_PREREQ_UNVERIFIABLE'
            Should -Invoke Invoke-EpicCrossGhExe -Times 0 -Exactly
        }
    }
}

Describe 'Main readiness through the wrappers' {
    It 'gives <Decision> with <Reason> for <Name>' -ForEach @(
        @{ Name = 'a merged epic PR in main'; Gh = @{ ExitCode = 0; Output = '[{"number":90,"mergeCommit":{"oid":"m90"}}]' }; AncestorExit = 0; Decision = 'release'; Reason = 'MAIN_PREREQ_RELEASED' }
        @{ Name = 'a gh failure'; Gh = @{ ExitCode = 1; Output = '' }; AncestorExit = 0; Decision = 'hold'; Reason = 'MAIN_PREREQ_UNVERIFIABLE' }
        @{ Name = 'invalid snapshot JSON'; Gh = @{ ExitCode = 0; Output = 'nope' }; AncestorExit = 0; Decision = 'hold'; Reason = 'MAIN_PREREQ_UNVERIFIABLE' }
        @{ Name = 'an ancestry exit of 2'; Gh = @{ ExitCode = 0; Output = '[{"number":90,"mergeCommit":{"oid":"m90"}}]' }; AncestorExit = 2; Decision = 'hold'; Reason = 'MAIN_PREREQ_UNVERIFIABLE' }
        @{ Name = 'no merged epic PR'; Gh = @{ ExitCode = 0; Output = '[]' }; AncestorExit = 0; Decision = 'hold'; Reason = 'MAIN_PREREQ_PR_NOT_MERGED' }
    ) {
        InModuleScope EpicCrossDependency -Parameters @{ GhResult = $Gh; AncestorExit = $AncestorExit; Text = $script:Consumer; Expected = "$Decision|$Reason" } {
            param($GhResult, $AncestorExit, $Text, $Expected)
            $null = @($GhResult, $AncestorExit, $Text, $Expected)
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) [pscustomobject]@{ ExitCode = $(if ($GitArgs[0] -eq 'fetch') { 0 } else { $AncestorExit }); Output = '' } }
            Mock Invoke-EpicCrossGhExe { param([string[]] $GhArgs) $null = $GhArgs; [pscustomobject] $GhResult }
            Mock Get-EpicCrossUtcNow { [datetime]::new(2026, 11, 10, 12, 0, 0, [DateTimeKind]::Utc) }

            $json = (Invoke-EpicCrossReadinessCommand -Mode main -ManifestPath 'epic.md' -ReadManifestText { $Text }.GetNewClosure()).Stdout | ConvertFrom-Json

            "$($json.Decision)|$($json.Reason)" | Should -BeExactly $Expected
            Should -Invoke Invoke-EpicCrossGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr list --head epic/provider-epic-integration --base main --state merged --json number,mergeCommit' }
        }
    }
}
