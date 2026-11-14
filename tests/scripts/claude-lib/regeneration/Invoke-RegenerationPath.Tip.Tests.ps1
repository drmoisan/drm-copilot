<#
.SYNOPSIS
    Pester call-sequence tests for the Tip flow of
    .claude/lib/regeneration/Invoke-RegenerationPath.ps1 (issue #1156).

.DESCRIPTION
    Each row's result values are asserted once by Invoke-RegenerationPath.Tests.ps1;
    this suite asserts the exact ordered git and process call list of rows R28-R42
    and each row alternative, including the restore argv of spec D18 item 4, and the
    Tip rules outside the table cells. The seams are mocked through the shared
    scenario helper. No file, git repository, process, or wait is used.
#>

BeforeDiscovery {
    $table = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'RegenerationResultTable.psd1')
    $script:TipRows = @($table.Rows | Where-Object { $number = [int] $_.Id.Substring(1); $number -ge 28 -and $number -le 42 })
}

BeforeAll {
    $script:LibRoot = Join-Path $PSScriptRoot '../../../../.claude/lib/regeneration'
    Import-Module (Join-Path $script:LibRoot 'RegenerationConfig.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:LibRoot 'RegenerationDelta.psm1') -Force -ErrorAction Stop
    Import-Module (Join-Path $script:LibRoot 'RegenerationClassifier.psm1') -ErrorAction Stop
    . (Join-Path $script:LibRoot 'Invoke-RegenerationPath.ps1')
    . (Join-Path $PSScriptRoot 'RegenerationResultScenario.ps1')
    $script:Rows = @((Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'RegenerationResultTable.psd1')).Rows)

    function Get-TipRow {
        param([string] $Id)
        return @($script:Rows | Where-Object { $_.Id -ceq $Id })[0]
    }

    function Invoke-TipScenario {
        param([hashtable] $Row, [int] $Alternative = 0, [hashtable] $Git = @{}, [string] $ConfigKind = $null)
        $context = Register-RegenerationScenarioMock -Row $Row -Alternative $Alternative
        foreach ($key in $Git.Keys) { $context.State.Git[$key] = $Git[$key] }
        if ($ConfigKind) { $context.State.ConfigText = Get-RegenerationScenarioConfigText -Kind $ConfigKind }
        $arguments = Get-RegenerationScenarioArgument -Row $Row -Alternative $Alternative
        $output = Invoke-RegenerationPathCommand @arguments -UtcNow $context.UtcNow
        return [pscustomobject]@{ Output = $output; Calls = [string[]] @($context.State.Calls) }
    }

    function Get-ForbiddenGitCall {
        param([string[]] $Calls)
        return , @($Calls | Where-Object { $_ -cmatch '^git (reset|add|commit)( |$)' })
    }
}

AfterAll {
    Remove-Module -Name RegenerationDelta, RegenerationClassifier, RegenerationConfig, BlastRadiusGlob -ErrorAction SilentlyContinue
}

Describe 'Invoke-RegenerationPath Tip call sequence' {
    It '<Id> <Scenario> makes the exact ordered git and process calls of every alternative' -ForEach $script:TipRows {
        $row = $_
        $count = Get-RegenerationScenarioAlternativeCount -Row $row
        for ($alternative = 0; $alternative -lt $count; $alternative++) {
            $run = Invoke-TipScenario -Row $row -Alternative $alternative
            $expected = Get-RegenerationScenarioCallList -Row $row -Alternative $alternative
            ($run.Calls -join ' | ') | Should -BeExactly ($expected -join ' | ') -Because "$($row.Id) alternative $alternative"
            (Get-ForbiddenGitCall -Calls $run.Calls).Count | Should -Be 0 -Because "$($row.Id) alternative $alternative stages, commits, or resets nothing"
        }
    }
}

Describe 'Invoke-RegenerationPath Tip rules outside the table cells' {
    It 'makes no restore call for <Id>' -ForEach @(@{ Id = 'R28' }, @{ Id = 'R29' }, @{ Id = 'R30' }, @{ Id = 'R31' }, @{ Id = 'R32' }) {
        $run = Invoke-TipScenario -Row (Get-TipRow -Id $Id)
        @($run.Calls | Where-Object { $_ -cmatch '^git (checkout|clean) ' }).Count | Should -Be 0
        $listings = @($run.Calls | Where-Object { $_ -ceq 'git diff --name-only -z' }).Count
        $expectedListings = if ($Id -ceq 'R28' -or $Id -ceq 'R29') { 2 } else { 0 }
        $listings | Should -Be $expectedListings -Because 'only T3 and T6 list tracked changes; RL1 is not made'
    }

    It 'makes no hash-object call for R29, whose run 1 changes nothing' {
        $run = Invoke-TipScenario -Row (Get-TipRow -Id 'R29')
        @($run.Calls | Where-Object { $_.StartsWith('git hash-object') }).Count | Should -Be 0
    }

    It 'skips checkout but still cleans and exits 1 with the other R34 cells when the restore listing RL1 fails' {
        $row = Get-TipRow -Id 'R34'
        $run = Invoke-TipScenario -Row $row -Git @{ 'diff --name-only -z' = @(128) }
        @($run.Calls | Where-Object { $_.StartsWith('git checkout') }).Count | Should -Be 0
        @($run.Calls | Where-Object { $_ -ceq 'git clean -f -q -- gen/new.json' }).Count | Should -Be 1
        $run.Output.ExitCode | Should -Be 1
        foreach ($key in @($row.Expected.Keys)) {
            $expected = Resolve-RegenerationExpectedCell -Row $row -Token $row.Expected[$key]
            (ConvertTo-Json -InputObject $run.Output.Result[$key] -Depth 10 -Compress) | Should -BeExactly (ConvertTo-Json -InputObject $expected -Depth 10 -Compress) -Because $key
        }
    }

    It 'runs no check process when idempotency_check is undeclared' {
        $run = Invoke-TipScenario -Row (Get-TipRow -Id 'R28')
        @($run.Calls | Where-Object { $_ -ceq 'process check-tool' }).Count | Should -Be 0
    }

    It 'runs no unit-gate process when unit_gate is declared' {
        $run = Invoke-TipScenario -Row (Get-TipRow -Id 'R28') -ConfigKind 'unit'
        $run.Output.ExitCode | Should -Be 0
        @($run.Calls | Where-Object { $_ -cmatch '^process ut-' }).Count | Should -Be 0
        (Get-ForbiddenGitCall -Calls $run.Calls).Count | Should -Be 0
    }
}
