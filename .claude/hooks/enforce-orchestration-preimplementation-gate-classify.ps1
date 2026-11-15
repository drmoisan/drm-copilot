<#
.SYNOPSIS
    Stage-1 classification supplement for Test-ImplementationCommand of the preimplementation gate (issue #1188).

.DESCRIPTION
    Get-OrchestrationGateSupplementalPatternIndex returns the stage-1 pattern indexes 2 (npm scripts)
    and 3 (npx tools) that two command forms match, which the per-segment scan of
    Test-ImplementationCommand cannot see:

    1. A joined shell word. Read-CommandLineSegment splits an unquoted word at $(, ${, or a backtick,
       so 'npm --prefix $(pwd) run lint' yields the segments 'npm --prefix ', 'pwd', and ' run lint',
       and no segment holds both npm and the script word. A run starts at a record followed by a
       substitution opener and continues while the text between two records consists only of
       substitution openers and closers ($(, {, ), }, backtick); its joined text is the members'
       ScanText with that text between them. A run whose openers are not all closed is discarded.
       Index 2 (or 3) is returned when, for some record of the run that carries npm (or npx) as a
       whole word, the joined text from that record to the run end matches the unchanged npm (or
       npx) pattern.
    2. npx options. Index 3 is returned when a record's ScanText or a joined text matches npx
       followed by one or more of --prefix <v>, --prefix=<v>, -C <v>, --yes, -y, --no, -q, or
       --quiet, then prettier, eslint, tsc, or jest. Any other option keeps the current
       classification.

    Each returned index still passes stage 2 (Test-OrchestrationGateInvocationConfirmed) and the
    index-0 bookkeeping rule in the gate. This narrows the spec non-goal "no command is newly
    classified" to: no command other than these two forms is newly classified.
.NOTES
    PowerShell 7+. Pure string logic (no file system, process, clock, or environment access; no
    dot-source); Read-CommandLineSegment and Test-CommandLineWordPresent are loaded by the gate.
    Byte-identical in .claude/hooks, .codex/hooks, and both bundles
    (enforce-orchestration-preimplementation-gate-classify.Parity.Tests.ps1).
#>

# The npm and npx stage-1 patterns of Test-ImplementationCommand (indexes 2 and 3), unchanged.
$script:OrchestrationGateSupplementNpmPattern = '(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b'
$script:OrchestrationGateSupplementNpxPattern = '(^|\s)npx\s+(prettier|eslint|tsc|jest)\b'
# Form 2: accepted npx options before the tool word.
$script:OrchestrationGateSupplementNpxOptionPattern = '(^|\s)npx\s+((--prefix\s+\S+|--prefix=\S+|-C\s+\S+|--yes|-y|--no|-q|--quiet)\s+)+(prettier|eslint|tsc|jest)\b'
# Text that may lie between two records of one shell word.
$script:OrchestrationGateSupplementJoinPattern = '^(\$\(|\{|\)|\}|`)+$'

function Get-OrchestrationGateJoinedWordText {
    <#
    .SYNOPSIS
        Returns one object per joined-word run (Form 1): Text (the joined ScanText), First (the
        RawText of the run's first record), and Member (one object per run record: Raw, its RawText,
        and Tail, the joined text from that record to the run end), limited to the records that lie
        outside every unclosed substitution. Records are located in
        CommandText in order.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject[]])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText, [Parameter(Mandatory)][AllowEmptyCollection()][object[]] $Record)

    $runs = [System.Collections.Generic.List[pscustomobject]]::new()
    $count = $Record.Count
    $start = [int[]]::new($count)
    $cursor = 0
    for ($index = 0; $index -lt $count; $index++) {
        $position = $CommandText.IndexOf([string]$Record[$index].RawText, $cursor, [System.StringComparison]::Ordinal)
        if ($position -lt 0) { return [pscustomobject[]]@() }
        $start[$index] = $position
        $cursor = $position + ([string]$Record[$index].RawText).Length
    }
    $index = 0
    while ($index -lt $count - 1) {
        $raw = [string]$Record[$index].RawText
        $gap = $CommandText.Substring($start[$index] + $raw.Length, $start[$index + 1] - $start[$index] - $raw.Length)
        $opens = $gap.StartsWith('$(') -or $gap.StartsWith('`') -or ($gap.StartsWith('{') -and $raw.EndsWith('$'))
        if (-not $opens -or $gap -notmatch $script:OrchestrationGateSupplementJoinPattern) { $index++; continue }
        $text = [System.Text.StringBuilder]::new()
        $memberOffset = [System.Collections.Generic.List[int]]::new()
        $member = $index
        while ($true) {
            $memberRaw = [string]$Record[$member].RawText
            $memberOffset.Add($text.Length)
            [void]$text.Append([string]$Record[$member].ScanText)
            if ($member -ge $count - 1) { break }
            $between = $CommandText.Substring($start[$member] + $memberRaw.Length, $start[$member + 1] - $start[$member] - $memberRaw.Length)
            if ($between -notmatch $script:OrchestrationGateSupplementJoinPattern) { break }
            [void]$text.Append($between)
            $member++
        }
        $joined = $text.ToString()
        $openers = ([regex]::Matches($joined, '\$\(|\$\{')).Count
        $closers = ([regex]::Matches($joined, '\)|\}')).Count
        $backticks = ([regex]::Matches($joined, '`')).Count
        if ($closers -ge $openers -and $backticks % 2 -eq 0) {
            $members = for ($offsetIndex = 0; $offsetIndex -lt $memberOffset.Count; $offsetIndex++) {
                # A record inside an unclosed substitution is not at the top level of the word.
                $before = $joined.Substring(0, $memberOffset[$offsetIndex])
                $beforeOpeners = ([regex]::Matches($before, '\$\(|\$\{')).Count
                $beforeClosers = ([regex]::Matches($before, '\)|\}')).Count
                $beforeBackticks = ([regex]::Matches($before, '`')).Count
                if ($beforeClosers -lt $beforeOpeners -or $beforeBackticks % 2 -ne 0) { continue }
                [pscustomobject]@{ Raw = [string]$Record[$index + $offsetIndex].RawText; Tail = $joined.Substring($memberOffset[$offsetIndex]) }
            }
            $runs.Add([pscustomobject]@{ Text = $joined; First = $raw; Member = [pscustomobject[]]@($members) })
        }
        $index = $member + 1
    }
    return [pscustomobject[]]$runs.ToArray()
}

function Get-OrchestrationGateSupplementalPatternIndex {
    <#
    .SYNOPSIS
        Returns the subset of the stage-1 indexes 2 and 3 that the joined-word and npx-option forms
        match in CommandText, in ascending order.
    #>
    [CmdletBinding()]
    [OutputType([int[]])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)

    $indexes = [System.Collections.Generic.List[int]]::new()
    if ([string]::IsNullOrWhiteSpace($CommandText)) { return [int[]]@() }
    $records = @(Read-CommandLineSegment -CommandText $CommandText)
    $npx = $false
    foreach ($record in $records) {
        if ([string]$record.ScanText -match $script:OrchestrationGateSupplementNpxOptionPattern) { $npx = $true }
    }
    $npm = $false
    foreach ($run in @(Get-OrchestrationGateJoinedWordText -CommandText $CommandText -Record $records)) {
        foreach ($member in $run.Member) {
            if ($member.Tail -match $script:OrchestrationGateSupplementNpmPattern -and (Test-CommandLineWordPresent -RawText $member.Raw -Word 'npm')) { $npm = $true }
            $npxText = $member.Tail -match $script:OrchestrationGateSupplementNpxPattern -or $member.Tail -match $script:OrchestrationGateSupplementNpxOptionPattern
            if ($npxText -and (Test-CommandLineWordPresent -RawText $member.Raw -Word 'npx')) { $npx = $true }
        }
    }
    if ($npm) { $indexes.Add(2) }
    if ($npx) { $indexes.Add(3) }
    return [int[]]$indexes.ToArray()
}
