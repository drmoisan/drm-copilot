Set-StrictMode -Version Latest

# Unit tests for scripts/powershell/PoshQC/PoshQC.CoverageMerge.psm1 (issue #953, FR-09).
# Every report is an in-memory CoverageGutters (JaCoCo-structured) XML string; no file is read or written.

BeforeAll {
    # Module-collision guard: keep exactly one PoshQC instance, loaded from the repo-root module.
    $modulePath = Join-Path $PSScriptRoot '../../../../scripts/powershell/PoshQC/PoshQC.psm1'
    $resolvedModulePath = (Resolve-Path -Path $modulePath).Path
    foreach ($module in Get-Module -Name PoshQC) {
        $loadedPath = if ($module.Path) { (Resolve-Path -Path $module.Path).Path } else { $null }
        if ($loadedPath -ne $resolvedModulePath) {
            Remove-Module -ModuleInfo $module -Force
        }
    }

    Import-Module -Name $resolvedModulePath -Force

    # Builds a two-package report: a.ps1 holds lines 1 and 2, b.ps1 holds lines 5 and SecondNr
    # (plus line 9 when -Extra is set). Every line has three commands; Ci gives the covered
    # commands per line in that order. The counters are computed from the lines.
    $script:NewReport = {
        param([int[]] $Ci, [int] $SecondNr = 6, [switch] $Extra)
        $commands = 3
        $counters = {
            param([int[]] $Values)
            $lineCovered = @($Values | Where-Object { $_ -gt 0 }).Count
            $instructionCovered = 0
            foreach ($value in $Values) { $instructionCovered += $value }
            $instructionMissed = ($commands * $Values.Count) - $instructionCovered
            "<counter type=`"INSTRUCTION`" missed=`"$instructionMissed`" covered=`"$instructionCovered`" />" +
            "<counter type=`"LINE`" missed=`"$($Values.Count - $lineCovered)`" covered=`"$lineCovered`" />" +
            '<counter type="METHOD" missed="0" covered="1" />'
        }
        $lineXml = { param([int] $Nr, [int] $Covered) "<line nr=`"$Nr`" mi=`"$($commands - $Covered)`" ci=`"$Covered`" mb=`"0`" cb=`"0`" />" }
        $fileA = @($Ci[0], $Ci[1])
        $fileB = @($Ci[2], $Ci[3])
        $linesB = (& $lineXml 5 $Ci[2]) + (& $lineXml $SecondNr $Ci[3])
        if ($Extra) {
            $fileB += 0
            $linesB += & $lineXml 9 0
        }
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<!DOCTYPE report PUBLIC "-//JACOCO//DTD Report 1.1//EN" "report.dtd"[]>' +
        '<report name="Pester"><sessioninfo id="this" start="1" dump="2" />' +
        '<package name="C:/repo/scripts/a"><sourcefile name="a.ps1">' + (& $lineXml 1 $Ci[0]) + (& $lineXml 2 $Ci[1]) + (& $counters $fileA) + '</sourcefile>' + (& $counters $fileA) + '</package>' +
        '<package name="C:/repo/scripts/b"><sourcefile name="b.ps1">' + $linesB + (& $counters $fileB) + '</sourcefile>' + (& $counters $fileB) + '</package>' +
        (& $counters ($fileA + $fileB)) + '</report>'
    }

    $script:Counter = {
        param([xml] $Report, [string] $XPath)
        $node = $Report.SelectSingleNode($XPath)
        '{0}/{1}' -f $node.GetAttribute('covered'), $node.GetAttribute('missed')
    }
    $script:Line = {
        param([xml] $Report, [string] $File, [int] $Nr)
        $node = $Report.SelectSingleNode("//sourcefile[@name='$File']/line[@nr='$Nr']")
        'ci={0} mi={1}' -f $node.GetAttribute('ci'), $node.GetAttribute('mi')
    }
}

Describe 'Merge-PoshQCCoverageReport' {
    It 'CM01-MERGE-MAX-CI takes the maximum ci per line and derives mi from the first report total' {
        # Arrange
        $reports = @((& $script:NewReport @(0, 1, 3, 0)), (& $script:NewReport @(2, 0, 1, 0)), (& $script:NewReport @(1, 1, 0, 0)))

        # Act
        [xml] $merged = Merge-PoshQCCoverageReport -CoverageXml $reports

        # Assert
        & $script:Line $merged 'a.ps1' 1 | Should -BeExactly 'ci=2 mi=1'
        & $script:Line $merged 'a.ps1' 2 | Should -BeExactly 'ci=1 mi=2'
        & $script:Line $merged 'b.ps1' 5 | Should -BeExactly 'ci=3 mi=0'
        & $script:Line $merged 'b.ps1' 6 | Should -BeExactly 'ci=0 mi=3'
    }

    It 'CM02-MERGE-RECOMPUTES-LINE-COUNTERS for every sourcefile, package, and the report' {
        # Arrange
        $reports = @((& $script:NewReport @(0, 1, 3, 0)), (& $script:NewReport @(2, 0, 1, 0)))

        # Act
        [xml] $merged = Merge-PoshQCCoverageReport -CoverageXml $reports

        # Assert: covered = lines with ci > 0; INSTRUCTION covered = sum of ci, missed = sum of mi.
        & $script:Counter $merged "//sourcefile[@name='a.ps1']/counter[@type='LINE']" | Should -BeExactly '2/0'
        & $script:Counter $merged "//sourcefile[@name='b.ps1']/counter[@type='LINE']" | Should -BeExactly '1/1'
        & $script:Counter $merged "//package[@name='C:/repo/scripts/a']/counter[@type='LINE']" | Should -BeExactly '2/0'
        & $script:Counter $merged "//package[@name='C:/repo/scripts/b']/counter[@type='LINE']" | Should -BeExactly '1/1'
        & $script:Counter $merged "/report/counter[@type='LINE']" | Should -BeExactly '3/1'
        & $script:Counter $merged "/report/counter[@type='INSTRUCTION']" | Should -BeExactly '6/6'
        & $script:Counter $merged "//sourcefile[@name='a.ps1']/counter[@type='INSTRUCTION']" | Should -BeExactly '3/3'
        $merged.SelectNodes("//counter[@type='METHOD']").Count | Should -Be 0 -Because 'METHOD figures cannot be recomputed from merged line hits, so the merged report omits them (CR-8)'
    }

    It 'CM03-MERGE-PRESERVES-DENOMINATOR keeps the line set and every line command total' {
        # Arrange
        $reports = @((& $script:NewReport @(0, 0, 0, 0)), (& $script:NewReport @(3, 2, 1, 0)), (& $script:NewReport @(1, 3, 0, 2)))

        # Act
        [xml] $merged = Merge-PoshQCCoverageReport -CoverageXml $reports

        # Assert
        $lines = @($merged.SelectNodes('//line'))
        $lines.Count | Should -Be 4
        foreach ($line in $lines) {
            ([int] $line.GetAttribute('ci') + [int] $line.GetAttribute('mi')) | Should -Be 3 -Because "line $($line.GetAttribute('nr')) keeps its command total"
        }
        $summary = Get-PoshQCCoverageLineSummary -CoverageXml $merged.OuterXml
        $summary.total | Should -Be 4
        $summary.covered | Should -Be 4
    }

    It 'CM04-MERGE-MISMATCHED-LINES-THROWS when the reports list different line sets' {
        # Arrange
        $base = & $script:NewReport @(1, 1, 1, 1)
        $extra = & $script:NewReport @(1, 1, 1, 1) -Extra
        $moved = & $script:NewReport @(1, 1, 1, 1) -SecondNr 7
        $duplicate = & $script:NewReport @(1, 1, 1, 1) -SecondNr 5

        # Act / Assert
        { Merge-PoshQCCoverageReport -CoverageXml @($base, $extra) } | Should -Throw '*report 2 lists 5 lines; report 1 lists 4*'
        { Merge-PoshQCCoverageReport -CoverageXml @($base, $moved) } | Should -Throw '*b.ps1|7*which report 1 does not list*'
        { Merge-PoshQCCoverageReport -CoverageXml @($duplicate) } | Should -Throw '*more than once*'
    }

    It 'CM05-MERGE-SINGLE-REPORT-IDENTITY returns the same lines and counters for one report' {
        # Arrange
        $text = & $script:NewReport @(0, 2, 3, 1)
        [xml] $original = $text

        # Act
        [xml] $merged = Merge-PoshQCCoverageReport -CoverageXml @($text)

        # Assert
        $before = @($original.SelectNodes("//line | //counter[@type='LINE' or @type='INSTRUCTION']") | ForEach-Object { $_.OuterXml })
        $after = @($merged.SelectNodes("//line | //counter[@type='LINE' or @type='INSTRUCTION']") | ForEach-Object { $_.OuterXml })
        $after.Count | Should -Be $before.Count
        ($after -join "`n") | Should -BeExactly ($before -join "`n")
    }

    It 'CM08-MERGE-OMITS-CLASS-AND-METHOD-FIGURES removes class and method elements and every counter other than LINE and INSTRUCTION' {
        # Arrange: each report also carries a class element with one method and a report-level CLASS counter, as Pester writes them.
        $classXml = '<class name="C:/repo/scripts/a/a" sourcefilename="a.ps1"><method name="Invoke-A" desc="()" line="1"><counter type="LINE" missed="1" covered="0" /><counter type="METHOD" missed="1" covered="0" /></method><counter type="CLASS" missed="1" covered="0" /></class>'
        $reports = foreach ($ci in @(@(0, 1, 3, 0), @(2, 0, 1, 0))) {
            (& $script:NewReport $ci).Replace('<package name="C:/repo/scripts/a">', '<package name="C:/repo/scripts/a">' + $classXml).Replace('</report>', '<counter type="CLASS" missed="1" covered="0" /></report>')
        }

        # Act
        [xml] $merged = Merge-PoshQCCoverageReport -CoverageXml $reports

        # Assert
        $merged.SelectNodes('//class').Count | Should -Be 0
        $merged.SelectNodes('//method').Count | Should -Be 0
        $merged.SelectNodes("//counter[@type!='LINE' and @type!='INSTRUCTION']").Count | Should -Be 0
        $merged.SelectNodes('//sourcefile').Count | Should -Be 2 -Because 'sourcefile elements and their lines are kept'
        & $script:Counter $merged "/report/counter[@type='LINE']" | Should -BeExactly '3/1' -Because 'the LINE counters stay exact'
    }

    It 'CM06-MERGE-EMPTY-INPUT-THROWS when no report is supplied' {
        { Merge-PoshQCCoverageReport -CoverageXml @() } | Should -Throw '*requires at least one coverage report*'
    }
}

Describe 'Get-PoshQCCoverageLineSummary' {
    It 'CM07-SUMMARY-REPORT-LINE returns covered, missed, total, and percent from the report LINE counter' {
        # Arrange
        $text = & $script:NewReport @(0, 2, 3, 1)

        # Act
        $summary = Get-PoshQCCoverageLineSummary -CoverageXml $text

        # Assert
        $summary.covered | Should -Be 3
        $summary.missed | Should -Be 1
        $summary.total | Should -Be 4
        $summary.percent | Should -Be 75
    }

    It 'returns percent 0 for an empty report and throws when the report LINE counter is absent' {
        # Arrange
        $empty = '<report name="Pester"><counter type="LINE" missed="0" covered="0" /></report>'
        $noCounter = '<report name="Pester"></report>'

        # Act / Assert
        (Get-PoshQCCoverageLineSummary -CoverageXml $empty).percent | Should -Be 0
        { Get-PoshQCCoverageLineSummary -CoverageXml $noCounter } | Should -Throw '*no report-level LINE counter*'
    }
}
