Set-StrictMode -Version Latest

# Unit tests for scripts/dev-tools/KcovFunctionCoverageGate.ps1 (issue #824).
#
# Every input is an in-memory string. Invoke-KcovFunctionCoverageGate is driven through a
# Get-Content mock, so no file is read or written, and no process, network call, or clock
# is used.

Describe 'KcovFunctionCoverageGate.ps1' -Tag 'Issue824' {
    BeforeAll {
        $script:scriptPath = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/dev-tools/KcovFunctionCoverageGate.ps1')).Path
        # Dot-source so the on-disk lines run under Pester coverage instrumentation. The file
        # defines functions only and runs nothing when loaded.
        . $script:scriptPath

        # Lines: 1 shebang, 2 'alpha() {', 3-4 body, 5 '}', 6 blank, 7 'beta() {', 8 body,
        # 9 '}', 10 a top-level call.
        $script:SourceText = @('#!/usr/bin/env bash', 'alpha() {', '  echo a', '  echo b', '}', '', 'beta() {', '  echo c', '}', 'alpha') -join "`n"
        $script:ClassTemplate = '<coverage><packages><package name="p"><classes>{0}</classes></package></packages></coverage>'
        $script:LineTemplate = '<class name="c" filename="{0}"><lines>{1}</lines></class>'
        $script:AllHit = $script:ClassTemplate -f ($script:LineTemplate -f 'src/setup.sh', '<line number="3" hits="2"/><line number="4" hits="1"/><line number="8" hits="1"/><line number="10" hits="1"/>')
        $script:Line4Missed = $script:ClassTemplate -f ($script:LineTemplate -f 'src/setup.sh', '<line number="3" hits="1"/><line number="4" hits="0"/><line number="8" hits="1"/>')
    }

    Context 'Get-KcovLineHit' {
        It 'G824-1 maps line numbers to hits for the one class whose file name matches' {
            # Arrange
            $classes = ($script:LineTemplate -f 'other.sh', '<line number="3" hits="9"/>') + ($script:LineTemplate -f 'src/setup.sh', '<line number="3" hits="2"/><line number="4" hits="0"/>')
            $xml = $script:ClassTemplate -f $classes

            # Act
            $hits = Get-KcovLineHit -CoberturaXml $xml -SourceLeaf 'setup.sh'

            # Assert
            $hits.Count | Should -Be 2
            $hits[3] | Should -Be 2
            $hits[4] | Should -Be 0
        }

        It 'G824-2 throws when no class names the file' {
            # Arrange
            $xml = $script:ClassTemplate -f ($script:LineTemplate -f 'other.sh', '')

            # Act and assert
            { Get-KcovLineHit -CoberturaXml $xml -SourceLeaf 'setup.sh' } | Should -Throw -ExpectedMessage '*found 0*'
        }

        It 'G824-3 throws when two classes name the file' {
            # Arrange
            $xml = $script:ClassTemplate -f (($script:LineTemplate -f 'a/setup.sh', '') + ($script:LineTemplate -f 'b/setup.sh', ''))

            # Act and assert
            { Get-KcovLineHit -CoberturaXml $xml -SourceLeaf 'setup.sh' } | Should -Throw -ExpectedMessage '*found 2*'
        }
    }

    Context 'Get-BashFunctionLineRange' {
        It 'G824-4 returns the 1-based definition and closing lines of each function' {
            # Arrange
            $lines = $script:SourceText -split "`n"

            # Act
            $alpha = Get-BashFunctionLineRange -SourceLine $lines -Name 'alpha'
            $beta = Get-BashFunctionLineRange -SourceLine $lines -Name 'beta'

            # Assert
            "$($alpha.Start)-$($alpha.End) $($beta.Start)-$($beta.End)" | Should -BeExactly '2-5 7-9'
        }

        It 'G824-5 throws when the definition line is absent' {
            # Arrange
            $lines = $script:SourceText -split "`n"

            # Act and assert
            { Get-BashFunctionLineRange -SourceLine $lines -Name 'gamma' } | Should -Throw -ExpectedMessage '*found 0*'
        }

        It 'G824-6 throws when the function has no closing line' {
            # Act and assert
            { Get-BashFunctionLineRange -SourceLine @('alpha() {', '  echo a') -Name 'alpha' } | Should -Throw -ExpectedMessage '*no closing line*'
        }
    }

    Context 'Get-AddedLineNumber' {
        It 'G824-7 expands counted and single-line hunks into new-file line numbers' {
            # Arrange
            $diff = "diff --git a/s.sh b/s.sh`n@@ -1,0 +2,3 @@`n+x`n+y`n+z`n@@ -9 +12 @@`n-q`n+r"

            # Act
            $added = @(Get-AddedLineNumber -DiffText $diff)

            # Assert
            ($added -join ',') | Should -BeExactly '2,3,4,12'
        }

        It 'G824-8 returns no line for a deletion-only hunk or an empty diff' {
            # Act
            $deletionOnly = @(Get-AddedLineNumber -DiffText "@@ -4,2 +3,0 @@`n-a`n-b")
            $empty = @(Get-AddedLineNumber -DiffText '')

            # Assert
            $deletionOnly.Count | Should -Be 0
            $empty.Count | Should -Be 0
        }
    }

    Context 'Get-KcovFunctionCoverageReport' {
        It 'G824-9 passes when every function meets the threshold and every instrumented changed line was hit' {
            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $script:AllHit -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('alpha', 'beta') -DiffText '@@ -1,0 +2,3 @@' -CheckChangedLine

            # Assert
            $report.ExitCode | Should -Be 0
            ($report.Message -join '|') | Should -BeExactly 'FUNCTION alpha lines=2-5 instrumented=2 covered=2 pct=100 missed=NONE PASS|FUNCTION beta lines=7-9 instrumented=1 covered=1 pct=100 missed=NONE PASS|CHANGED-LINES=3 INSTRUMENTED=2 UNCOVERED-CHANGED=NONE|GATE-FAILED=False'
        }

        It 'G824-10 fails a function whose line coverage is below the threshold' {
            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $script:Line4Missed -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('alpha') -Threshold 85

            # Assert
            $report.ExitCode | Should -Be 1
            $report.Message[0] | Should -BeExactly 'FUNCTION alpha lines=2-5 instrumented=2 covered=1 pct=50 missed=4 FAIL'
            $report.Message[-1] | Should -BeExactly 'GATE-FAILED=True'
        }

        It 'G824-11 fails a function with no instrumented line' {
            # Arrange
            $xml = $script:ClassTemplate -f ($script:LineTemplate -f 'src/setup.sh', '<line number="10" hits="1"/>')

            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $xml -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('alpha')

            # Assert
            $report.ExitCode | Should -Be 1
            $report.Message[0] | Should -BeExactly 'FUNCTION alpha lines=2-5 instrumented=0 FAIL'
        }

        It 'G824-12 fails an instrumented changed line with no hit and ignores changed lines kcov did not instrument' {
            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $script:Line4Missed -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('beta') -DiffText '@@ -2,0 +3,4 @@' -CheckChangedLine

            # Assert
            $report.ExitCode | Should -Be 1
            $report.Message[1] | Should -BeExactly 'CHANGED-LINES=4 INSTRUMENTED=2 UNCOVERED-CHANGED=4'
        }

        It 'G824-13 reports the changed-line check as not checked when it is not requested' {
            # Act
            $report = Get-KcovFunctionCoverageReport -CoberturaXml $script:Line4Missed -SourceText $script:SourceText -SourceLeaf 'setup.sh' -Function @('beta') -DiffText '@@ -2,0 +3,4 @@'

            # Assert
            $report.ExitCode | Should -Be 0
            $report.Message[1] | Should -BeExactly 'CHANGED-LINES=NOT-CHECKED'
        }
    }

    Context 'Invoke-KcovFunctionCoverageGate' {
        It 'G824-14 reads the report, the script, and the diff, and checks the changed lines' {
            # Arrange
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'kcov/cov.xml' } -MockWith { $script:AllHit }
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'src/setup.sh' } -MockWith { $script:SourceText }
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'kcov/changed.diff' } -MockWith { '@@ -1,0 +2,3 @@' }

            # Act
            $report = Invoke-KcovFunctionCoverageGate -CoberturaPath 'kcov/cov.xml' -SourcePath 'src/setup.sh' -DiffPath 'kcov/changed.diff' -Function @('alpha', 'beta')

            # Assert
            $report.ExitCode | Should -Be 0
            $report.Message[2] | Should -BeExactly 'CHANGED-LINES=3 INSTRUMENTED=2 UNCOVERED-CHANGED=NONE'
            Should -Invoke Get-Content -Times 3 -Exactly
        }

        It 'G824-15 skips the changed-line check and reads no diff when DiffPath is empty' {
            # Arrange
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'kcov/cov.xml' } -MockWith { $script:AllHit }
            Mock Get-Content -ParameterFilter { $LiteralPath -eq 'src/setup.sh' } -MockWith { $script:SourceText }

            # Act
            $report = Invoke-KcovFunctionCoverageGate -CoberturaPath 'kcov/cov.xml' -SourcePath 'src/setup.sh' -Function @('alpha')

            # Assert
            $report.ExitCode | Should -Be 0
            $report.Message[1] | Should -BeExactly 'CHANGED-LINES=NOT-CHECKED'
            Should -Invoke Get-Content -Times 2 -Exactly
        }
    }
}
