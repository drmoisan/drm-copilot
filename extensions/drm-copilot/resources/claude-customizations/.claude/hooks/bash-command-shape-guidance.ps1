<#
.SYNOPSIS
    Intent detection and rewrite guidance for the cd-chained deny of validate-bash.ps1 (issue #1165).

.DESCRIPTION
    Pure helper for .claude/hooks/validate-bash.ps1. It runs only after
    Get-CdChainedReadCommandMatch has reported a match, and it builds the guidance text of the
    deny reason; it never decides whether a command is allowed or denied.

    Get-CdChainedCommandIntent reads the segment list of the command and reports the 'cd'
    target and the tools (git, poetry, npm, npx) that follow the 'cd'.
    Get-CdChainedRewriteGuidance turns that intent into the replacement form for each tool.

    The file defines functions and constants only and dot-sources nothing. It relies on
    Read-CommandLineSegment and Test-CommandLineSegmentRawScan from hook-command-scanner.ps1,
    which validate-bash.ps1 loads before it.

    Pure string logic only: no disk, process, network, clock, or environment access.
#>

# Tools whose directory option or script route the guidance names, in reporting order.
$script:CdChainedIntentToolNames = @('git', 'poetry', 'npm', 'npx')

# A whole-word 'cd' and its argument inside raw scan text (the wrapper-led leg, where a nested
# command line stays one segment). The argument stops at whitespace, a delimiter, or a quote.
$script:CdChainedIntentCdPattern = '(?<![\w./-])cd\s+([^\s;&|"''()]+)'

# A whole-word tool name inside raw scan text. A path component such as '/usr/bin/git' or a
# hyphenated word such as 'npm-run' is not a mention.
$script:CdChainedIntentToolPattern = '(?<![\w./-])(git|poetry|npm|npx)(?![\w.-])'

function Get-CdChainedToolMention {
    <#
    .SYNOPSIS
        Return the tool names mentioned as whole words in a text, in order of appearance.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)

    foreach ($toolMatch in [regex]::Matches($Text, $script:CdChainedIntentToolPattern)) {
        $toolMatch.Groups[1].Value
    }
}

function Get-CdChainedCommandIntent {
    <#
    .SYNOPSIS
        Report the 'cd' target and the tools that follow the 'cd' in a cd-chained command.
    .DESCRIPTION
        Walks the segment list in order. The first 'cd' segment with at least two tokens
        supplies CdTarget (its second token). A segment the scanner reads raw (wrapper-led, a
        live substitution, or unbalanced quoting) that carries a nested 'cd' supplies CdTarget
        from the 'cd' argument in its ScanText, and the tools mentioned after that 'cd' in the
        same text.

        After the 'cd', a segment whose CommandWord is a tool adds that tool, and a segment
        read raw adds every tool mentioned in its ScanText as a whole word, which is how a tool
        behind a wrapper such as 'env' is found. Tools is the ordered distinct list;
        IsMultiStep is true when it holds two or more tools.

        Empty or null input returns an intent with no tools and a null CdTarget.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with ReadOp, CdTarget, Tools, IsMultiStep.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string] $Command,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string] $ReadOp
    )

    $tools = [System.Collections.Generic.List[string]]::new()
    $cdTarget = $null
    $seenCd = $false

    $segments = @()
    if (-not [string]::IsNullOrWhiteSpace($Command)) {
        $segments = @(Read-CommandLineSegment -CommandText $Command)
    }

    foreach ($segment in $segments) {
        $tokens = @($segment.Tokens)
        $word = [string]$segment.CommandWord
        $isRaw = Test-CommandLineSegmentRawScan -Segment $segment
        $mentions = @()

        if (-not $seenCd) {
            if ($word -eq 'cd' -and $tokens.Count -ge 2) {
                $seenCd = $true
                $cdTarget = [string]$tokens[1]
                continue
            }
            if (-not $isRaw) {
                continue
            }
            $cdMatch = [regex]::Match([string]$segment.ScanText, $script:CdChainedIntentCdPattern)
            if (-not $cdMatch.Success) {
                continue
            }
            $seenCd = $true
            $cdTarget = $cdMatch.Groups[1].Value
            $afterCd = ([string]$segment.ScanText).Substring($cdMatch.Index + $cdMatch.Length)
            $mentions = @(Get-CdChainedToolMention -Text $afterCd)
        } else {
            if ($script:CdChainedIntentToolNames -contains $word) {
                $mentions += $word
            }
            if ($isRaw) {
                $mentions += @(Get-CdChainedToolMention -Text ([string]$segment.ScanText))
            }
        }

        foreach ($tool in $mentions) {
            if (-not $tools.Contains($tool)) {
                $tools.Add($tool)
            }
        }
    }

    return [pscustomobject]@{
        ReadOp      = $ReadOp
        CdTarget    = $cdTarget
        Tools       = [string[]]$tools.ToArray()
        IsMultiStep = ($tools.Count -ge 2)
    }
}

function Get-CdChainedRewriteGuidance {
    <#
    .SYNOPSIS
        Return the rewrite guidance for a cd-chained command, chosen by its detected intent.
    .DESCRIPTION
        No tool: read with the Read or Grep tool, or run the read command against the absolute
        path. One tool: that tool's directory-option form. Several tools: a script under the
        scratch directory run with 'sh', followed by each tool's form. Every result ends with
        one sentence on the agent-isolated versus sibling-worktree split and a pointer to the
        rule file and the brief table; that sentence names no tool form.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowNull()][object] $Intent)

    $tools = @()
    $readOp = 'the read command'
    $target = 'the directory'
    if ($null -ne $Intent) {
        $tools = @($Intent.Tools | Where-Object { $_ })
        if ($Intent.ReadOp) { $readOp = [string]$Intent.ReadOp }
        if ($Intent.CdTarget) { $target = "'$($Intent.CdTarget)'" }
    }

    $toolForms = @{
        git    = 'for git use git -C <abs> <subcommand>'
        poetry = 'for Poetry use env -u VIRTUAL_ENV poetry -C <abs> <command> (long form --directory <abs>)'
        npm    = 'for npm use npm --prefix <abs> <command>'
        npx    = 'for npx, which has no directory option, use npm --prefix <abs> run <script> when a package script exists, otherwise sh <SCRATCH>/<file>.sh'
    }

    $sentences = [System.Collections.Generic.List[string]]::new()
    if ($tools.Count -eq 0) {
        $sentences.Add("Read the file with the Read or Grep tool, or run $readOp against the absolute path, with no leading 'cd'.")
    } elseif ($tools.Count -eq 1) {
        $sentences.Add("Drop the 'cd' and name the directory on the tool instead, where <abs> is the absolute path of ${target}: $($toolForms[$tools[0]]).")
        $sentences.Add("Piping the output into $readOp is fine once the 'cd' is gone; read any file against its absolute path.")
    } else {
        $forms = @($tools | ForEach-Object { $toolForms[$_] }) -join '; '
        $sentences.Add("These steps share one directory, so write them to a script under the scratch directory (it may 'cd' internally) and run it as sh <SCRATCH>/<file>.sh.")
        $sentences.Add("To run a step on its own, where <abs> is the absolute path of ${target}: $forms.")
    }
    $sentences.Add('In an agent-isolated worktree the Bash working directory is already the worktree root, so drop the ''cd'' and call the tool directly; a non-isolated agent working in a sibling worktree names the directory on each call; see .claude/rules/bash-command-shape.md and the Command-Text Restrictions table of the execution-environment skill.')

    return ($sentences -join ' ')
}
