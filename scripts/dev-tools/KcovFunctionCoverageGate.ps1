<#
.SYNOPSIS
    Gate kcov line coverage of named bash functions and of the changed lines of one bash
    script.

.DESCRIPTION
    Issue #824 added this gate for .codex/codex-web-setup.sh, which lies outside the
    shell-QC kcov include roots. The shell-coverage job in
    .github/workflows/_shell-coverage.yml runs that script's bats file under kcov with the
    include pattern restricted to the script, then dot-sources this file and calls
    Invoke-KcovFunctionCoverageGate.

    For each named function the report counts the kcov-instrumented lines inside the
    function body and the lines that were hit. It fails when a function is absent, has no
    instrumented line, or has a line coverage below the threshold. When a zero-context
    unified diff of the script is supplied, every added line that kcov instrumented must
    have been hit; added lines that kcov did not instrument (comments, blank lines,
    closing braces) are counted but not gated.

    A function body runs from the line 'name() {' to the first later line that is exactly
    '}'. Every decision is made by the pure functions below; only
    Invoke-KcovFunctionCoverageGate reads files. The file defines functions only and runs
    nothing when it is dot-sourced.
#>

Set-StrictMode -Version Latest

function Get-KcovLineHit {
    <#
    .SYNOPSIS
        Map each line number of one measured file to its kcov hit count.
    .DESCRIPTION
        Selects the single Cobertura class whose filename attribute ends with the given
        file name and returns a hashtable from line number to hit count. Throws when no
        class or more than one class matches.
    .PARAMETER CoberturaXml
        The text of a kcov Cobertura report.
    .PARAMETER SourceLeaf
        The file name of the measured script, for example 'codex-web-setup.sh'.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)][string] $CoberturaXml,
        [Parameter(Mandatory)][string] $SourceLeaf
    )

    [xml] $report = $CoberturaXml
    $classes = @($report.SelectNodes('//class') | Where-Object { (($_.GetAttribute('filename') -replace '\\', '/') -split '/')[-1] -ceq $SourceLeaf })
    if ($classes.Count -ne 1) {
        throw "Expected exactly one Cobertura class for '$SourceLeaf'; found $($classes.Count)."
    }
    $hits = @{}
    foreach ($line in @($classes[0].SelectNodes('lines/line'))) {
        $hits[[int]$line.GetAttribute('number')] = [int]$line.GetAttribute('hits')
    }
    return $hits
}

function Get-BashFunctionLineRange {
    <#
    .SYNOPSIS
        Locate the body of one bash function by its definition and closing lines.
    .DESCRIPTION
        Returns the 1-based numbers of the line 'name() {' and of the first later line
        that is exactly '}'. Throws when the definition line does not occur exactly once
        or when no closing line follows it.
    .PARAMETER SourceLine
        The lines of the bash script.
    .PARAMETER Name
        The function name.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string[]] $SourceLine,
        [Parameter(Mandatory)][string] $Name
    )

    $header = "$Name() {"
    $starts = [System.Collections.Generic.List[int]]::new()
    for ($index = 0; $index -lt $SourceLine.Count; $index++) {
        if ($SourceLine[$index] -ceq $header) {
            $starts.Add($index)
        }
    }
    if ($starts.Count -ne 1) {
        throw "Expected exactly one definition line '$header'; found $($starts.Count)."
    }
    for ($index = $starts[0] + 1; $index -lt $SourceLine.Count; $index++) {
        if ($SourceLine[$index] -ceq '}') {
            return [pscustomobject]@{ Name = $Name; Start = $starts[0] + 1; End = $index + 1 }
        }
    }
    throw "Function '$Name' has no closing line '}'."
}

function Get-AddedLineNumber {
    <#
    .SYNOPSIS
        List the new-file line numbers that a zero-context unified diff adds.
    .DESCRIPTION
        Reads every hunk header '@@ -a,b +c,d @@' and emits the numbers c to c+d-1; a
        header without ',d' adds one line. Emits nothing for an empty diff or for a
        deletion-only hunk.
    .PARAMETER DiffText
        The output of 'git diff --unified=0' for one file.
    .OUTPUTS
        System.Int32
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $DiffText
    )

    foreach ($match in [regex]::Matches($DiffText, '(?m)^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@')) {
        $start = [int]$match.Groups[1].Value
        $count = if ($match.Groups[2].Success) { [int]$match.Groups[2].Value } else { 1 }
        for ($number = $start; $number -lt ($start + $count); $number++) {
            $number
        }
    }
}

function Get-KcovFunctionCoverageReport {
    <#
    .SYNOPSIS
        Decide the coverage gate for named functions and the changed lines of one script.
    .DESCRIPTION
        Returns an object whose Message property holds the report lines and whose ExitCode
        property is 0 when every function has at least one instrumented line and meets
        the threshold and, when CheckChangedLine is set, no added instrumented line has
        zero hits; ExitCode is 1 otherwise.
    .PARAMETER CoberturaXml
        The text of a kcov Cobertura report.
    .PARAMETER SourceText
        The text of the measured bash script.
    .PARAMETER SourceLeaf
        The file name of the measured script.
    .PARAMETER Function
        The names of the functions to gate.
    .PARAMETER Threshold
        The minimum line coverage percentage per function. Defaults to 85.
    .PARAMETER DiffText
        A zero-context unified diff of the script. Read only when CheckChangedLine is set.
    .PARAMETER CheckChangedLine
        Gate the added lines of DiffText. Without it the changed-line check is reported as
        not checked.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $CoberturaXml,
        [Parameter(Mandatory)][AllowEmptyString()][string] $SourceText,
        [Parameter(Mandatory)][string] $SourceLeaf,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $Function,
        [double] $Threshold = 85,
        [AllowEmptyString()][string] $DiffText = '',
        [switch] $CheckChangedLine
    )

    $hits = Get-KcovLineHit -CoberturaXml $CoberturaXml -SourceLeaf $SourceLeaf
    $sourceLines = @($SourceText -split '\r?\n')
    $messages = [System.Collections.Generic.List[string]]::new()
    $failed = $false
    foreach ($name in $Function) {
        $range = Get-BashFunctionLineRange -SourceLine $sourceLines -Name $name
        $measured = @($hits.Keys | Where-Object { $_ -ge $range.Start -and $_ -le $range.End } | Sort-Object)
        $missed = @($measured | Where-Object { $hits[$_] -eq 0 })
        $span = "lines=$($range.Start)-$($range.End) instrumented=$($measured.Count)"
        if ($measured.Count -eq 0) {
            $failed = $true
            $messages.Add("FUNCTION $name $span FAIL")
            continue
        }
        $covered = $measured.Count - $missed.Count
        $pct = [math]::Round(100.0 * $covered / $measured.Count, 2)
        $status = 'PASS'
        if ($pct -lt $Threshold) {
            $failed = $true
            $status = 'FAIL'
        }
        $missedText = if ($missed.Count -gt 0) { $missed -join ',' } else { 'NONE' }
        $messages.Add("FUNCTION $name $span covered=$covered pct=$pct missed=$missedText $status")
    }
    if ($CheckChangedLine) {
        $added = @(Get-AddedLineNumber -DiffText $DiffText)
        $instrumented = @($added | Where-Object { $hits.ContainsKey($_) })
        $uncovered = @($instrumented | Where-Object { $hits[$_] -eq 0 })
        if ($uncovered.Count -gt 0) {
            $failed = $true
        }
        $uncoveredText = if ($uncovered.Count -gt 0) { $uncovered -join ',' } else { 'NONE' }
        $messages.Add("CHANGED-LINES=$($added.Count) INSTRUMENTED=$($instrumented.Count) UNCOVERED-CHANGED=$uncoveredText")
    } else {
        $messages.Add('CHANGED-LINES=NOT-CHECKED')
    }
    $messages.Add("GATE-FAILED=$failed")
    return [pscustomobject]@{ Message = $messages.ToArray(); ExitCode = [int]$failed }
}

function Invoke-KcovFunctionCoverageGate {
    <#
    .SYNOPSIS
        Read the kcov report, the script, and an optional diff, and decide the gate.
    .DESCRIPTION
        The only function in this file that reads files. An empty DiffPath disables the
        changed-line check; a DiffPath that names an empty file checks zero lines.
    .PARAMETER CoberturaPath
        Path of the kcov Cobertura report.
    .PARAMETER SourcePath
        Path of the measured bash script.
    .PARAMETER DiffPath
        Path of a zero-context unified diff of the script, or an empty string.
    .PARAMETER Function
        The names of the functions to gate.
    .PARAMETER Threshold
        The minimum line coverage percentage per function. Defaults to 85.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $CoberturaPath,
        [Parameter(Mandatory)][string] $SourcePath,
        [AllowEmptyString()][string] $DiffPath = '',
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]] $Function,
        [double] $Threshold = 85
    )

    $checkChangedLine = -not [string]::IsNullOrEmpty($DiffPath)
    $diffText = ''
    if ($checkChangedLine) {
        $diffText = [string](Get-Content -Raw -LiteralPath $DiffPath -ErrorAction Stop)
    }
    $coberturaXml = [string](Get-Content -Raw -LiteralPath $CoberturaPath -ErrorAction Stop)
    $sourceText = [string](Get-Content -Raw -LiteralPath $SourcePath -ErrorAction Stop)
    return Get-KcovFunctionCoverageReport -CoberturaXml $coberturaXml -SourceText $sourceText -SourceLeaf (Split-Path -Leaf $SourcePath) -Function $Function -Threshold $Threshold -DiffText $diffText -CheckChangedLine:$checkChangedLine
}
