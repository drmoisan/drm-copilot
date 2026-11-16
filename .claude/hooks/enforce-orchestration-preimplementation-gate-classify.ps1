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

    Get-OrchestrationGateWrappedPatternIndex (issue #1195) returns the stage-1 indexes 1 to 4 that
    a literal wrapper payload matches, so 'sh -c "pytest -q"' is classified as the bare command. The
    wrappers are the sh family with -c or a bundle containing c, pwsh and powershell with -c, a
    -Command prefix, -CommandWithArgs, or -cwa, and eval, after assignments, env with its value
    options, timeout, time, command, nohup, or xargs injected words; literal nested wrappers are
    followed to depth 4. Each payload is scanned as a bare command line (every ScanText against the
    gate's patterns 1 to 4, plus the supplement above). Index 0 is never returned, and every index
    still passes stage 2 against the whole command, so a payload mention stays unclassified.
    Out of scope under decision D18 of issue #1160: a variable-held payload, an EncodedCommand
    payload (-e, -ec, or a prefix of -EncodedCommand), a payload built at run time, an env -S split
    string, and an unbalanced payload quote.
.NOTES
    PowerShell 7+. Pure string logic (no file system, process, clock, or environment access; no
    dot-source); Read-CommandLineSegment, Test-CommandLineWordPresent, ConvertTo-CommandLineNormalizedText,
    Split-CommandLinePosixWord, ConvertTo-CommandLineLeafWord, Skip-CommandLineTransparentWrapper, and
    Get-CommandLineWrapperPayload are loaded by the gate.
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

function Get-OrchestrationGateWrapperPayloadText {
    <#
    .SYNOPSIS
        Returns the literal payload of a segment's words when they lead, after assignments and env
        with its value options, with a sh-family -c, pwsh or powershell -c/-Command/-CommandWithArgs,
        or eval wrapper, following xargs injected words. Returns nothing for any other segment, for an
        env split string (-S, --split-string), an Opaque PowerShell payload, or an encoded command.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]] $Word)

    $position = 0
    while ($position -lt $Word.Count) {
        if ($Word[$position] -match '^[A-Za-z_][A-Za-z0-9_]*=') { $position++; continue }
        if ((ConvertTo-CommandLineLeafWord -Word $Word[$position]).ToLowerInvariant() -cne 'env') { break }
        $position++
        # env value options (decision D-2): -u and -C (and their long forms) take a separate value.
        while ($position -lt $Word.Count -and ($Word[$position].StartsWith('-') -or $Word[$position] -match '^[A-Za-z_][A-Za-z0-9_]*=')) {
            $option = $Word[$position]
            if ($option -ceq '-S' -or $option -ceq '--split-string' -or $option.StartsWith('--split-string=', [System.StringComparison]::Ordinal)) { return }
            $position += $(if (@('-u', '--unset', '-C', '--chdir') -ccontains $option) { 2 } else { 1 })
        }
    }
    $remaining = [string[]]@($Word | Select-Object -Skip $position)
    $hops = 0
    while ($remaining.Count -gt 0 -and $hops -lt 8) {
        $hops++
        $wrapper = Get-CommandLineWrapperPayload -Word $remaining
        if ($wrapper.Kind -ceq 'Words') { $remaining = [string[]]@($wrapper.Words); continue }
        if ($wrapper.Kind -ceq 'Posix') { return [string]$wrapper.Payload }
        if ($wrapper.Kind -cne 'PowerShell' -or $wrapper.Opaque) { return }
        # The payload result decodes an encoded command, so the host flags are read from the words.
        foreach ($word in @($remaining | Select-Object -Skip ((Skip-CommandLineTransparentWrapper -Token $remaining).Index + 1))) {
            $flag = $word.ToLowerInvariant()
            if ($flag -eq '-c' -or $flag -in @('-cwa', '-commandwithargs') -or ($flag.Length -ge 4 -and '-command'.StartsWith($flag, [System.StringComparison]::Ordinal))) { break }
            if ($flag -in @('-e', '-ec') -or ($flag.Length -ge 3 -and '-encodedcommand'.StartsWith($flag, [System.StringComparison]::Ordinal))) { return }
        }
        return [string]$wrapper.Payload
    }
}

function Get-OrchestrationGateWrappedPatternIndex {
    <#
    .SYNOPSIS
        Returns the subset of the stage-1 indexes 1 to 4 that a literal wrapper payload of CommandText
        matches at nesting depth 1 to 4, in ascending order and without duplicates. Pattern is the
        gate's stage-1 pattern array; index 0 is never returned.
    #>
    [CmdletBinding()]
    [OutputType([int[]])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $CommandText,
        [Parameter(Mandatory)][string[]] $Pattern
    )

    $found = [System.Collections.Generic.SortedSet[int]]::new()
    $pending = [System.Collections.Generic.Queue[pscustomobject]]::new()
    $pending.Enqueue([pscustomobject]@{ Text = $CommandText; Depth = 0 })
    while ($pending.Count -gt 0) {
        $item = $pending.Dequeue()
        foreach ($segment in @(Read-CommandLineSegment -CommandText (ConvertTo-CommandLineNormalizedText -CommandText $item.Text))) {
            # An unbalanced segment yields no payload.
            if ($segment.Unbalanced) { continue }
            foreach ($payload in @(Get-OrchestrationGateWrapperPayloadText -Word ([string[]]@(Split-CommandLinePosixWord -Text ([string]$segment.TokenText))))) {
                foreach ($record in @(Read-CommandLineSegment -CommandText (ConvertTo-CommandLineNormalizedText -CommandText $payload))) {
                    for ($index = 1; $index -le 4; $index++) { if ([string]$record.ScanText -match $Pattern[$index]) { [void]$found.Add($index) } }
                }
                foreach ($index in @(Get-OrchestrationGateSupplementalPatternIndex -CommandText $payload)) { [void]$found.Add($index) }
                if ($item.Depth + 1 -lt 4) { $pending.Enqueue([pscustomobject]@{ Text = $payload; Depth = $item.Depth + 1 }) }
            }
        }
    }
    return [int[]]@($found)
}
