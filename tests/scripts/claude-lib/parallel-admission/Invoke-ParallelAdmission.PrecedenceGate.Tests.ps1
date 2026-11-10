<#
.SYNOPSIS
    Behavioral tests for the test-precedence and access-paths subcommands (issue #1164).

.DESCRIPTION
    Covers the subcommand wiring of
    .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 (spec B5.2, B6.3,
    B6.5). The script is dot-sourced, so its guarded entry-point body does not
    run and Invoke-ParallelAdmissionCli is called in-process. The file seam
    Read-ParallelAdmissionJsonText is mocked with in-memory text: no file is read
    or created, no git process is started, and no clock is read.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:EntryScriptPath = (Resolve-Path (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1')).Path

    # The guarded entry-point body does not run under dot-sourcing.
    . $script:EntryScriptPath

    # A truth table carrying the recalibrated committed minutes.
    $script:ConfigText = @{
        conflict_tolerance = @{
            tolerance_percent = 100
            weights           = @{ same_file = 90; possible_overlap = 20; append_only = 10; module = 10; separable = 15; contract = 90 }
            band_durations    = @{ C1 = 30; C2 = 45; C3 = 90; C4 = 180 }
            default_band      = 'C1'
            append_only_paths = @('**/CHANGELOG.md')
        }
    } | ConvertTo-Json -Depth 6

    # A scheduling result: edge 1:2 (C2 and C2), tolerated overlap 3:4 (C3 and C3, a tie).
    function New-PrecedenceEntryText {
        param([hashtable] $Precedence)
        return @{
            edges              = @(@{ a = 1; b = 2; reason = 'path_overlap'; hard = $false; cost = 90; benefit = 45 })
            tolerated_overlaps = @(@{ a = 3; b = 4; reasons = @('path_overlap'); cost = 90; benefit = 90 })
            items              = @(@{ issue_num = 1; complexity_band = 'C2' }, @{ issue_num = 2; complexity_band = 'C2' }, @{ issue_num = 3; complexity_band = 'C3' }, @{ issue_num = 4; complexity_band = 'C3' })
            precedence         = @($Precedence)
        } | ConvertTo-Json -Depth 6
    }
}

Describe 'Invoke-ParallelAdmission precedence gate subcommands' {
    BeforeEach {
        Mock Read-ParallelAdmissionJsonText {
            param([string] $Path)
            if ($Path.EndsWith('blast-radius.json')) { return $script:ConfigText }
            throw "unexpected read of $Path"
        }
    }

    It 'test-precedence exits 0 for a justified cost entry' {
        $entry = New-PrecedenceEntryText -Precedence @{ before = 1; after = 2; source = 'operator'; recorded_at = '2026-11-09T10-00'; kind = 'cost' }

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-precedence' -Entry $entry

        $outcome.ExitCode | Should -Be 0
        ($outcome.Stdout | ConvertFrom-Json).checked | Should -Be 1
        $outcome.Stderr | Should -BeNullOrEmpty
    }

    It 'test-precedence exits 1 with the exact precedence_not_justified line' {
        $entry = New-PrecedenceEntryText -Precedence @{ before = 3; after = 4; source = 'operator'; recorded_at = '2026-11-09T10-00'; kind = 'cost' }

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-precedence' -Entry $entry

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeExactly 'PARALLEL_ADMISSION_REJECTED: precedence_not_justified: --after 4:3 fails the parallel scheduling rule (merge time 90 min does not exceed parallel gain 90 min); add --reason "<text>" to record a correctness ordering'
    }

    It 'test-precedence exits 1 for an empty correctness reason' {
        $entry = New-PrecedenceEntryText -Precedence @{ before = 3; after = 4; source = 'operator'; recorded_at = '2026-11-09T10-00'; kind = 'correctness'; reason = ' ' }

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-precedence' -Entry $entry

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeExactly 'PARALLEL_ADMISSION_REJECTED: precedence_not_justified: --after 4:3 is marked as a correctness ordering with an empty reason'
    }

    It 'test-precedence exits 2 without -Entry' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-precedence'

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -BeExactly 'parallel admission usage error: test-precedence requires -Entry.'
        Should -Invoke Read-ParallelAdmissionJsonText -Times 0 -Exactly
    }

    It 'access-paths returns derived read paths per item' {
        Mock Read-ParallelAdmissionJsonText {
            param([string] $Path)
            if ($Path.EndsWith('plan-7.md')) { return "- [ ] [P0-T1] Read ``docs/rule.md``.`n- [ ] [P1-T1] Update ``src/app.py``." }
            return '- [ ] [P1-T1] Update `docs/rule.md`.'
        }
        $entry = @{
            items = @(
                @{ issue_num = 9; plan_path = 'docs/features/active/b/plan-9.md'; blast_radius = @{ paths = @('docs/rule.md') } },
                @{ issue_num = 7; plan_path = 'docs/features/active/a/plan-7.md'; blast_radius = @{ paths = @('docs/rule.md', 'src/app.py') } }
            )
        } | ConvertTo-Json -Depth 6

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'access-paths' -Entry $entry

        $outcome.ExitCode | Should -Be 0
        $readPaths = ($outcome.Stdout | ConvertFrom-Json -AsHashtable)['read_paths']
        @($readPaths.Keys) | Should -Be @('7', '9')
        @($readPaths['7']) | Should -Be @('docs/rule.md')
        @($readPaths['9']).Count | Should -Be 0
    }
}
