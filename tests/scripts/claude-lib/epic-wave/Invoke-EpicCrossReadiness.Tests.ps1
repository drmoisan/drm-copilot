#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    CLI contract tests for Invoke-EpicCrossReadinessCommand and Invoke-EpicCrossReadiness.ps1 (issue #1162).

.DESCRIPTION
    Covers the exit codes 0, 1, and 2, the -WaitSeconds range and default, the bounded wait
    through the injected Wait-EpicCrossInterval and Get-EpicCrossUtcNow seams (counting the
    injected sleeps; the sleep seam is mocked, so no test waits), feature mode without
    -Issue, the compressed JSON evidence fields, and the three no-key outputs of the entry
    script run in-process against the committed LF fixture. No temporary file is created.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    $script:ModulePath = Join-Path $script:RepoRoot '.claude/lib/epic-wave/EpicCrossDependency.psm1'
    $script:CliPath = Join-Path $script:RepoRoot '.claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1'
    $script:Fixture = Join-Path $script:RepoRoot 'tests/fixtures/epic_cross_dependency/epic-without-cross-edges.md'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop

    $script:Edge = '[{ epic: provider-epic, integration_branch: epic/provider-epic-integration, issue_num: 1188 }]'
    $script:Consumer = (@(
            '---', 'epic: consumer', 'integration_branch: epic/consumer-integration', 'features:',
            '  - issue_num: 1201', '    feature_folder: c-1201', '    depends_on: []', "    cross_epic_depends_on: $($script:Edge)",
            '  - issue_num: 1202', '    feature_folder: c-1202', '    depends_on: []', "    cross_epic_depends_on: $($script:Edge)",
            '  - issue_num: 1203', '    feature_folder: c-1203', '    depends_on: [1201]', '---') -join "`n")
    $script:ProviderText = "---`nepic: provider-epic`nintegration_branch: epic/provider-epic-integration`nfeatures:`n  - issue_num: 1188`n    feature_folder: p-1188`n    depends_on: []`n---"
    $script:Merged = '[{"number":41,"headRefName":"feature/p-1188","mergeCommit":{"oid":"sha41"},"files":[]}]'
}

AfterAll {
    Remove-Module -Name EpicCrossDependency -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-EpicCrossReadinessCommand usage' {
    It 'exits 2 for <Name>' -ForEach @(
        @{ Name = '-WaitSeconds 541'; Splat = @{ Mode = 'feature'; ManifestPath = 'm'; WaitSeconds = 541 } }
        @{ Name = '-WaitSeconds -1'; Splat = @{ Mode = 'main'; ManifestPath = 'm'; WaitSeconds = -1 } }
        @{ Name = 'an unknown mode'; Splat = @{ Mode = 'launch'; ManifestPath = 'm' } }
        @{ Name = 'a mode in another case'; Splat = @{ Mode = 'Feature'; ManifestPath = 'm' } }
        @{ Name = 'no manifest path'; Splat = @{ Mode = 'validate' } }
        @{ Name = 'text without frontmatter'; Splat = @{ Mode = 'validate'; ManifestPath = 'm'; ReadManifestText = { 'no frontmatter' } } }
        @{ Name = 'a reader that throws'; Splat = @{ Mode = 'validate'; ManifestPath = 'm'; ReadManifestText = { throw 'unreadable' } } }
        @{ Name = 'an -Issue outside the manifest'; Splat = @{ Mode = 'feature'; ManifestPath = 'm'; Issue = '9'; ReadManifestText = { "---`nepic: a`nfeatures:`n  - issue_num: 1`n---" } } }
    ) {
        $result = Invoke-EpicCrossReadinessCommand @Splat

        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -BeLike 'EPIC_CROSS_READINESS_USAGE:*'
        $result.Stdout | Should -BeExactly ''
    }

    It 'exits 1 with the codes on stderr for an invalid manifest' {
        $text = "---`nepic: consumer`nfeatures:`n  - issue_num: 1201`n    cross_epic_depends_on: [{ epic: consumer, integration_branch: epic/x-integration, issue_num: 1201 }]`n---"
        $result = Invoke-EpicCrossReadinessCommand -Mode feature -ManifestPath 'm' -ReadManifestText { $text }.GetNewClosure()

        $result.ExitCode | Should -Be 1
        @($result.Stderr -split [Environment]::NewLine | ForEach-Object { ($_ -split ':')[0] }) -join ',' | Should -BeExactly 'EPIC_CROSS_DEPENDENCY_SAME_EPIC,EPIC_CROSS_DEPENDENCY_BRANCH_MISMATCH'
        $result.Stdout | Should -BeExactly ''
    }

    It 'validates against the referenced manifest read through git and exits <Exit>' -ForEach @(
        @{ Exit = 0; ShowExit = 0 }
        @{ Exit = 1; ShowExit = 128 }
    ) {
        InModuleScope EpicCrossDependency -Parameters @{ Text = $script:Consumer; Provider = $script:ProviderText; ShowExit = $ShowExit; Exit = $Exit } {
            param($Text, $Provider, $ShowExit, $Exit)
            $null = @($Text, $Provider, $ShowExit, $Exit)
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) $null = $GitArgs; [pscustomobject]@{ ExitCode = $ShowExit; Output = $Provider } }

            $result = Invoke-EpicCrossReadinessCommand -Mode validate -ManifestPath 'm' -ReadManifestText { $Text }.GetNewClosure()

            $result.ExitCode | Should -Be $Exit
            if ($Exit -eq 0) { $result.Stdout | Should -BeExactly '{"Mode":"validate","Errors":[]}' } else { $result.Stderr | Should -BeLike 'EPIC_CROSS_DEPENDENCY_MANIFEST_UNREADABLE:*' }
        }
    }
}

Describe 'Invoke-EpicCrossReadinessCommand bounded wait' {
    It 'polls <Polls> times with <Sleeps> injected sleeps for <Name>' -ForEach @(
        @{ Name = 'a release on the third poll'; Mode = 'feature'; Wait = 540; ReleaseAt = 3; Final = 'release'; Polls = 3; Sleeps = 2 }
        @{ Name = 'a merge_required on the second poll'; Mode = 'feature'; Wait = 540; MergeAt = 2; Final = 'merge_required'; Polls = 2; Sleeps = 1 }
        @{ Name = 'a hold until the 540-second bound'; Mode = 'feature'; Wait = 540; Final = 'hold'; Polls = 10; Sleeps = 9 }
        @{ Name = 'a hold with a 90-second bound'; Mode = 'main'; Wait = 90; Final = 'hold'; Polls = 2; Sleeps = 1 }
        @{ Name = 'a main release on the second poll'; Mode = 'main'; Wait = 540; ReleaseAt = 2; Final = 'release'; Polls = 2; Sleeps = 1 }
        @{ Name = 'the default -WaitSeconds'; Mode = 'feature'; Final = 'hold'; Polls = 1; Sleeps = 0 }
    ) {
        $parameters = @{
            Text = $script:Consumer; Provider = $script:ProviderText; Merged = $script:Merged; Mode = $Mode
            ReleaseAt = $(if ($null -ne $ReleaseAt) { $ReleaseAt } else { 0 }); MergeAt = $(if ($null -ne $MergeAt) { $MergeAt } else { 0 })
            Wait = $Wait; Final = $Final; Polls = $Polls; Sleeps = $Sleeps
        }
        InModuleScope EpicCrossDependency -Parameters $parameters {
            param($Text, $Provider, $Merged, $Mode, $ReleaseAt, $MergeAt, $Wait, $Final, $Polls, $Sleeps)
            $null = @($Text, $Provider, $Merged, $Mode, $ReleaseAt, $MergeAt, $Wait, $Final, $Polls, $Sleeps)
            $script:TestPoll = 0
            $script:TestState = @{ Provider = $Provider; Merged = $Merged; ReleaseAt = $ReleaseAt; MergeAt = $MergeAt }
            # Each evaluation fetches once; the poll number decides whether the prerequisite
            # merged, and a release also places its merge commit in the own branch.
            Mock Invoke-EpicCrossGitExe {
                param([string[]] $GitArgs)
                $s = $script:TestState
                $merged = ($s.ReleaseAt -gt 0 -and $script:TestPoll -ge $s.ReleaseAt) -or ($s.MergeAt -gt 0 -and $script:TestPoll -ge $s.MergeAt)
                switch ($GitArgs[0]) {
                    'fetch' { $script:TestPoll++; [pscustomobject]@{ ExitCode = 0; Output = '' } }
                    'show' { [pscustomobject]@{ ExitCode = 0; Output = $s.Provider } }
                    default { [pscustomobject]@{ ExitCode = $(if ($merged -and ($GitArgs[3] -like '*provider*' -or $GitArgs[3] -eq 'origin/main' -or $s.ReleaseAt -gt 0)) { 0 } else { 1 }); Output = '' } }
                }
            }
            Mock Invoke-EpicCrossGhExe {
                param([string[]] $GhArgs)
                $s = $script:TestState
                $merged = ($s.ReleaseAt -gt 0 -and $script:TestPoll -ge $s.ReleaseAt) -or ($s.MergeAt -gt 0 -and $script:TestPoll -ge $s.MergeAt)
                $output = '[]'
                if ($merged) { $output = $(if ($GhArgs -contains '--head') { '[{"number":90,"mergeCommit":{"oid":"m90"}}]' } else { $s.Merged }) }
                [pscustomobject]@{ ExitCode = 0; Output = $output }
            }
            Mock Wait-EpicCrossInterval { param([int] $Seconds) $null = $Seconds }
            Mock Get-EpicCrossUtcNow { [datetime]::new(2026, 11, 10, 12, 0, 0, [DateTimeKind]::Utc) }

            $command = @{ Mode = $Mode; ManifestPath = 'm'; Issue = $(if ($Mode -eq 'feature') { '1201' } else { '' }); ReadManifestText = { $Text }.GetNewClosure() }
            if ($null -ne $Wait) { $command.WaitSeconds = $Wait }
            $result = Invoke-EpicCrossReadinessCommand @command
            $polls = $script:TestPoll
            $script:TestState = $null

            $result.ExitCode | Should -Be 0
            ($result.Stdout | ConvertFrom-Json).Decision | Should -BeExactly $Final
            $polls | Should -Be $Polls
            Should -Invoke Wait-EpicCrossInterval -Times $Sleeps -Exactly -ParameterFilter { $Seconds -eq 60 }
        }
    }
}

Describe 'Invoke-EpicCrossReadinessCommand output' {
    It 'returns one decision per edge-bearing feature when -Issue is omitted' {
        InModuleScope EpicCrossDependency -Parameters @{ Text = $script:Consumer; Provider = $script:ProviderText } {
            param($Text, $Provider)
            $null = @($Text, $Provider)
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) [pscustomobject]@{ ExitCode = $(if ($GitArgs[0] -eq 'merge-base') { 1 } else { 0 }); Output = $Provider } }
            Mock Invoke-EpicCrossGhExe { param([string[]] $GhArgs) $null = $GhArgs; [pscustomobject]@{ ExitCode = 0; Output = '[]' } }
            Mock Get-EpicCrossUtcNow { [datetime]::new(2026, 11, 10, 12, 0, 0, [DateTimeKind]::Utc) }

            $json = (Invoke-EpicCrossReadinessCommand -Mode feature -ManifestPath 'm' -ReadManifestText { $Text }.GetNewClosure()).Stdout | ConvertFrom-Json

            @($json.Features | ForEach-Object { "$($_.Issue):$($_.Decision)" }) -join ',' | Should -BeExactly '1201:hold,1202:hold'
            "$($json.Mode)|$($json.Decision)|$($json.Reason)" | Should -BeExactly 'feature|hold|PREREQ_PR_NOT_FOUND'
        }
    }

    It 'writes compressed JSON with the <Mode> evidence fields and the injected evaluation time' -ForEach @(
        @{ Mode = 'feature'; Expected = 'feature|merge_required|PREREQ_MERGED_INTEGRATION_MERGE_REQUIRED|41|sha41' }
        @{ Mode = 'main'; Expected = 'main|release|MAIN_PREREQ_RELEASED|90|m90' }
    ) {
        InModuleScope EpicCrossDependency -Parameters @{ Text = $script:Consumer; Provider = $script:ProviderText; Merged = $script:Merged; Mode = $Mode; Expected = $Expected } {
            param($Text, $Provider, $Merged, $Mode, $Expected)
            $null = @($Text, $Provider, $Merged, $Mode, $Expected)
            # Ancestry: in the other branch and main (exit 0), not yet in the own branch (exit 1).
            Mock Invoke-EpicCrossGitExe { param([string[]] $GitArgs) [pscustomobject]@{ ExitCode = $(if ($GitArgs[0] -eq 'merge-base' -and $GitArgs[3] -like '*consumer*') { 1 } else { 0 }); Output = $Provider } }
            Mock Invoke-EpicCrossGhExe { param([string[]] $GhArgs) [pscustomobject]@{ ExitCode = 0; Output = $(if ($GhArgs -contains '--head') { '[{"number":90,"mergeCommit":{"oid":"m90"}}]' } else { $Merged }) } }
            Mock Get-EpicCrossUtcNow { [datetime]::new(2026, 11, 10, 12, 34, 56, [DateTimeKind]::Utc) }

            $result = Invoke-EpicCrossReadinessCommand -Mode $Mode -ManifestPath 'm' -Issue $(if ($Mode -eq 'feature') { '1201' } else { '' }) -ReadManifestText { $Text }.GetNewClosure()
            $json = $result.Stdout | ConvertFrom-Json -AsHashtable
            $record = if ($Mode -eq 'feature') { $json.Features[0].Edges[0] } else { $json.Epics[0] }

            $result.Stdout | Should -Not -Match '\r|\n'
            "$($json.Mode)|$($json.Decision)|$($json.Reason)|$($record.PrNumber)|$($record.MergeCommitSha)" | Should -BeExactly $Expected
            $result.Stdout | Should -Match '"EvaluatedAt":"2026-11-10T12:34:56Z"'
        }
    }
}

Describe 'Invoke-EpicCrossReadiness.ps1 entry script without the key' {
    It 'prints <Expected> for -Mode <Mode> and exits 0' -ForEach @(
        @{ Mode = 'validate'; Expected = '{"Mode":"validate","Errors":[]}' }
        @{ Mode = 'feature'; Expected = '{"Mode":"feature","Decision":"release","Reason":"NO_CROSS_EPIC_EDGE","Features":[]}' }
        @{ Mode = 'main'; Expected = '{"Mode":"main","Decision":"not_applicable","Reason":"NO_CROSS_EPIC_EDGE","Epics":[]}' }
    ) {
        $output = & $script:CliPath -Mode $Mode -ManifestPath $script:Fixture

        $LASTEXITCODE | Should -Be 0
        $output | Should -BeExactly $Expected
    }

    It 'prints release with NO_CROSS_EPIC_EDGE for a feature of the fixture' {
        $output = & $script:CliPath -Mode feature -ManifestPath $script:Fixture -Issue 1301

        $LASTEXITCODE | Should -Be 0
        ($output | ConvertFrom-Json).Features[0].Reason | Should -BeExactly 'NO_CROSS_EPIC_EDGE'
    }

    It 'exits 2 and prints nothing on stdout for a bad -WaitSeconds' {
        $output = & $script:CliPath -Mode main -ManifestPath $script:Fixture -WaitSeconds 541 2>$null

        $LASTEXITCODE | Should -Be 2
        $output | Should -BeNullOrEmpty
    }
}
