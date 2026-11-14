<#
.SYNOPSIS
    Pester call-sequence tests for the Merge flow of
    .claude/lib/regeneration/Invoke-RegenerationPath.ps1 (issue #1156).

.DESCRIPTION
    Each row's result values are asserted once by Invoke-RegenerationPath.Tests.ps1;
    this suite asserts the exact ordered git and process call list of rows R47-R74
    and each row alternative, the rules outside the table cells, and the D18 item 6
    -ConfigPath suffix of the evidence Command line. The seams are mocked through
    the shared scenario helper. No file, git repository, process, or wait is used.
#>

BeforeDiscovery {
    $table = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'RegenerationResultTable.psd1')
    $script:MergeRows = @($table.Rows | Where-Object { [int] $_.Id.Substring(1) -ge 47 })
}

BeforeAll {
    $script:LibRoot = Join-Path $PSScriptRoot '../../../../.claude/lib/regeneration'
    Import-Module (Join-Path $script:LibRoot 'RegenerationConfig.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:LibRoot 'RegenerationDelta.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:LibRoot 'RegenerationClassifier.psm1') -ErrorAction Stop
    . (Join-Path $script:LibRoot 'Invoke-RegenerationPath.ps1')
    . (Join-Path $PSScriptRoot 'RegenerationResultScenario.ps1')
    $script:Rows = @((Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'RegenerationResultTable.psd1')).Rows)
    $script:Nul = [string] [char] 0

    function Get-MergeRow {
        param([string] $Id)
        return @($script:Rows | Where-Object { $_.Id -ceq $Id })[0]
    }

    function Invoke-MergeScenario {
        param([hashtable] $Row, [int] $Alternative = 0, [hashtable] $Git = @{}, [hashtable] $Arguments = $null)
        $context = Register-RegenerationScenarioMock -Row $Row -Alternative $Alternative
        foreach ($key in $Git.Keys) { $context.State.Git[$key] = $Git[$key] }
        if ($null -eq $Arguments) { $Arguments = Get-RegenerationScenarioArgument -Row $Row -Alternative $Alternative }
        $output = Invoke-RegenerationPathCommand @Arguments -UtcNow $context.UtcNow
        return [pscustomobject]@{ Output = $output; Calls = [string[]] @($context.State.Calls); State = $context.State }
    }
}

AfterAll {
    Remove-Module -Name RegenerationDelta, RegenerationClassifier, RegenerationConfig, BlastRadiusGlob -ErrorAction SilentlyContinue
}

Describe 'Invoke-RegenerationPath Merge call sequence' {
    It '<Id> <Scenario> makes the exact ordered git and process calls of every alternative' -ForEach $script:MergeRows {
        $row = $_
        $count = Get-RegenerationScenarioAlternativeCount -Row $row
        for ($alternative = 0; $alternative -lt $count; $alternative++) {
            $run = Invoke-MergeScenario -Row $row -Alternative $alternative
            $expected = Get-RegenerationScenarioCallList -Row $row -Alternative $alternative
            ($run.Calls -join ' | ') | Should -BeExactly ($expected -join ' | ') -Because "$($row.Id) alternative $alternative"
            @($run.Calls | Where-Object { $_ -cmatch '^git (commit|reset)( |$)' }).Count | Should -Be 0 -Because "$($row.Id) alternative $alternative commits or resets nothing"
        }
    }
}

Describe 'Invoke-RegenerationPath Merge rules outside the table cells' {
    It 'makes exactly the two command process calls for R73 without idempotency_check' {
        $run = Invoke-MergeScenario -Row (Get-MergeRow -Id 'R73')
        @($run.Calls | Where-Object { $_.StartsWith('process ') }) -join ' | ' | Should -BeExactly 'process gen-tool --write | process gen-tool --write'
    }

    It 'makes no checkout --ours and no add call when the conflict listing is empty' {
        $run = Invoke-MergeScenario -Row (Get-MergeRow -Id 'R73') -Git @{ 'diff --name-only -z --diff-filter=U' = @('') }
        @($run.Calls | Where-Object { $_ -cmatch '^git (checkout --ours|add --)' }).Count | Should -Be 0
        $run.Output.ExitCode | Should -Be 0
    }

    It 'makes no add -A call and returns changed_paths [] with exit 0 when run 1 changes nothing' {
        $run = Invoke-MergeScenario -Row (Get-MergeRow -Id 'R73') -Git @{
            'diff --name-only -z' = @(''); 'ls-files --others --exclude-standard -z' = @('')
            'diff --cached --name-only -z --no-renames HEAD'       = @("gen/a.json${script:Nul}src/main.ps1$script:Nul")
            'diff --cached --name-only -z --no-renames MERGE_HEAD' = @("gen/a.json${script:Nul}src/feature.ps1$script:Nul")
        }
        @($run.Calls | Where-Object { $_ -cmatch '^git add -A' }).Count | Should -Be 0
        $run.Output.ExitCode | Should -Be 0
        (ConvertTo-Json -InputObject $run.Output.Result.changed_paths -Compress) | Should -BeExactly '[]'
    }

    It 'classifies only the listing intersection when the merge output names another path' {
        $run = Invoke-MergeScenario -Row (Get-MergeRow -Id 'R73') -Git @{ 'merge --no-commit --no-ff origin/epic/x' = @("CONFLICT (content): Merge conflict in src/merge-only.ps1`nAuto-merging gen/a.json") }
        $run.Output.Result.reason | Should -BeExactly 'all_match'
        @($run.Output.Result.unmatched_paths).Count | Should -Be 0
    }

    It 'reaches the not-confined path of R60 for an untracked run-1 file present only in the M13 listing' {
        $run = Invoke-MergeScenario -Row (Get-MergeRow -Id 'R73') -Git @{
            'diff --name-only -z'                     = @('', "gen/a.json$script:Nul", '')
            'ls-files --others --exclude-standard -z' = @('', "stray.txt$script:Nul", '')
        }
        $run.Output.ExitCode | Should -Be 3
        $run.Output.Result.confined | Should -BeFalse
    }

    It 'reaches R66 for a run-2 file present only in the M16 untracked listing with M15 empty' {
        $run = Invoke-MergeScenario -Row (Get-MergeRow -Id 'R73') -Git @{
            'diff --name-only -z'                     = @('', "gen/a.json$script:Nul", '')
            'ls-files --others --exclude-standard -z' = @('', "gen/new.json$script:Nul", "gen/late.json$script:Nul")
        }
        $run.Output.ExitCode | Should -Be 3
        $run.Output.Result.idempotent | Should -BeFalse
    }
}

Describe 'Invoke-RegenerationPath evidence Command -ConfigPath suffix (spec D18 items 3 and 6)' {
    BeforeAll {
        $script:R73 = Get-MergeRow -Id 'R73'
        $script:Main = @{ Mode = 'Merge'; MergeRef = 'origin/main'; Trigger = 'main_sync' }
        $script:MainGit = @{ 'merge --no-commit --no-ff origin/main' = @('') }
    }

    It 'ends the Command line with the supplied -ConfigPath config/alt.json' {
        $run = Invoke-MergeScenario -Row $script:R73 -Git $script:MainGit -Arguments ($script:Main + @{ ConfigPath = 'config/alt.json' })
        $command = @($run.Output.Result.evidence_text -split "`n" | Where-Object { $_.StartsWith('Command: ') })[0]
        $command.EndsWith(' -ConfigPath config/alt.json') | Should -BeTrue -Because $command
    }

    It 'ends the Command line with -Trigger main_sync and holds no -ConfigPath when it is omitted' {
        $run = Invoke-MergeScenario -Row $script:R73 -Git $script:MainGit -Arguments $script:Main.Clone()
        $command = @($run.Output.Result.evidence_text -split "`n" | Where-Object { $_.StartsWith('Command: ') })[0]
        $command.EndsWith(' -Trigger main_sync') | Should -BeTrue -Because $command
        $command.Contains('-ConfigPath') | Should -BeFalse -Because $command
    }

    It 'ends the Command line with the explicitly supplied default -ConfigPath' {
        $run = Invoke-MergeScenario -Row $script:R73 -Git $script:MainGit -Arguments ($script:Main + @{ ConfigPath = 'config/orchestration-regeneration.json' })
        $command = @($run.Output.Result.evidence_text -split "`n" | Where-Object { $_.StartsWith('Command: ') })[0]
        $command.EndsWith(' -ConfigPath config/orchestration-regeneration.json') | Should -BeTrue -Because $command
    }
}
