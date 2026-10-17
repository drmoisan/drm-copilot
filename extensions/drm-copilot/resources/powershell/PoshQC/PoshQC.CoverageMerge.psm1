<#
.SYNOPSIS
Loads CoverageGutters (JaCoCo-structured) XML text into an XmlDocument (issue #953).
.DESCRIPTION
Disables external resolution, so the DOCTYPE reference to report.dtd is never fetched, and keeps
whitespace so the merged report serializes with the layout of the first input.
.PARAMETER CoverageXml
The XML text of one coverage report.
#>
function ConvertFrom-PoshQCCoverageXml {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param(
        [Parameter(Mandatory)][string] $CoverageXml
    )

    $document = New-Object System.Xml.XmlDocument
    $document.XmlResolver = $null
    $document.PreserveWhitespace = $true
    $document.LoadXml($CoverageXml)
    $document
}

<#
.SYNOPSIS
Merges the coverage reports written by the shards of one test run (issue #953).
.DESCRIPTION
Takes XML text only (no file I/O). Every report must list the same set of
package/sourcefile/line-number triples, otherwise the merge throws. For each triple the merged
line carries ci = max(ci) and mi = (mi + ci of the first report) - max(ci). The LINE and
INSTRUCTION counters of every sourcefile, every package, and the report are then recomputed
bottom-up: LINE covered counts lines with ci greater than 0 and LINE missed counts lines with ci
equal to 0; INSTRUCTION covered is the sum of ci and INSTRUCTION missed is the sum of mi.
Class and method elements and every counter other than LINE and INSTRUCTION are removed, because they
cannot be recomputed from merged line hits (CR-8). No coverage threshold is enforced. Returns the merged XML text.
.PARAMETER CoverageXml
The XML text of each shard's coverage report; at least one is required.
#>
function Merge-PoshQCCoverageReport {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $CoverageXml
    )

    if ($CoverageXml.Count -lt 1) {
        throw 'Merge-PoshQCCoverageReport requires at least one coverage report.'
    }

    $indexLines = {
        param([System.Xml.XmlDocument] $Document, [int] $Position)
        $index = New-Object 'System.Collections.Generic.Dictionary[string,System.Xml.XmlElement]' ([System.StringComparer]::Ordinal)
        foreach ($package in $Document.SelectNodes('/report/package')) {
            foreach ($sourceFile in $package.SelectNodes('sourcefile')) {
                foreach ($line in $sourceFile.SelectNodes('line')) {
                    $key = '{0}|{1}|{2}' -f $package.GetAttribute('name'), $sourceFile.GetAttribute('name'), $line.GetAttribute('nr')
                    if ($index.ContainsKey($key)) {
                        throw "Coverage report $Position lists line '$key' more than once."
                    }
                    $index.Add($key, $line)
                }
            }
        }
        , $index
    }

    $merged = ConvertFrom-PoshQCCoverageXml -CoverageXml $CoverageXml[0]
    $mergedLines = & $indexLines $merged 1
    for ($position = 1; $position -lt $CoverageXml.Count; $position++) {
        $reportNumber = $position + 1
        $otherLines = & $indexLines (ConvertFrom-PoshQCCoverageXml -CoverageXml $CoverageXml[$position]) $reportNumber
        if ($otherLines.Count -ne $mergedLines.Count) {
            throw "Coverage report $reportNumber lists $($otherLines.Count) lines; report 1 lists $($mergedLines.Count)."
        }
        foreach ($entry in $otherLines.GetEnumerator()) {
            $line = $null
            if (-not $mergedLines.TryGetValue($entry.Key, [ref] $line)) {
                throw "Coverage report $reportNumber lists line '$($entry.Key)', which report 1 does not list."
            }
            $otherCovered = [long] $entry.Value.GetAttribute('ci')
            $currentCovered = [long] $line.GetAttribute('ci')
            if ($otherCovered -gt $currentCovered) {
                $commandTotal = [long] $line.GetAttribute('mi') + $currentCovered
                $line.SetAttribute('ci', [string] $otherCovered)
                $line.SetAttribute('mi', [string] ($commandTotal - $otherCovered))
            }
        }
    }

    # Issue #953 (CR-8): class and method elements, and counters other than LINE and INSTRUCTION, cannot be
    # recomputed from merged line hits and would keep the figures of report 1, so the merged report omits them.
    foreach ($staleNode in @($merged.SelectNodes("//class | //counter[@type!='LINE' and @type!='INSTRUCTION']"))) {
        [void] $staleNode.ParentNode.RemoveChild($staleNode)
    }

    $setCounter = {
        param([System.Xml.XmlElement] $Node, [string] $Type, [long] $Covered, [long] $Missed)
        $counter = $Node.SelectSingleNode("counter[@type='$Type']")
        if ($counter) {
            $counter.SetAttribute('missed', [string] $Missed)
            $counter.SetAttribute('covered', [string] $Covered)
        }
    }
    $setTotals = {
        param([System.Xml.XmlElement] $Node, [long[]] $Totals)
        & $setCounter $Node 'INSTRUCTION' $Totals[2] $Totals[3]
        & $setCounter $Node 'LINE' $Totals[0] $Totals[1]
    }

    # Totals layout: 0 = LINE covered, 1 = LINE missed, 2 = INSTRUCTION covered, 3 = INSTRUCTION missed.
    $reportTotals = New-Object 'long[]' 4
    foreach ($package in $merged.DocumentElement.SelectNodes('package')) {
        $packageTotals = New-Object 'long[]' 4
        foreach ($sourceFile in $package.SelectNodes('sourcefile')) {
            $fileTotals = New-Object 'long[]' 4
            foreach ($line in $sourceFile.SelectNodes('line')) {
                $lineCovered = [long] $line.GetAttribute('ci')
                if ($lineCovered -gt 0) { $fileTotals[0]++ } else { $fileTotals[1]++ }
                $fileTotals[2] += $lineCovered
                $fileTotals[3] += [long] $line.GetAttribute('mi')
            }
            & $setTotals $sourceFile $fileTotals
            for ($slot = 0; $slot -lt 4; $slot++) { $packageTotals[$slot] += $fileTotals[$slot] }
        }
        & $setTotals $package $packageTotals
        for ($slot = 0; $slot -lt 4; $slot++) { $reportTotals[$slot] += $packageTotals[$slot] }
    }
    & $setTotals $merged.DocumentElement $reportTotals

    $merged.OuterXml
}

<#
.SYNOPSIS
Summarizes the report-level LINE counter of a coverage report (issue #953).
.DESCRIPTION
Returns covered, missed, total, and percent (rounded to two decimals; 0 when total is 0) from the
report-level LINE counter. Takes XML text only and enforces no threshold.
.PARAMETER CoverageXml
The XML text of one coverage report.
#>
function Get-PoshQCCoverageLineSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $CoverageXml
    )

    $document = ConvertFrom-PoshQCCoverageXml -CoverageXml $CoverageXml
    $counter = $document.SelectSingleNode("/report/counter[@type='LINE']")
    if (-not $counter) {
        throw 'The coverage report has no report-level LINE counter.'
    }

    $covered = [long] $counter.GetAttribute('covered')
    $missed = [long] $counter.GetAttribute('missed')
    $total = $covered + $missed
    [pscustomobject]@{
        covered = $covered
        missed  = $missed
        total   = $total
        percent = if ($total -gt 0) { [math]::Round(100.0 * $covered / $total, 2) } else { 0 }
    }
}
