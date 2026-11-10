<#
.SYNOPSIS
    Hook process-cost measurement functions for issue #1159.

.DESCRIPTION
    Measures what one PreToolUse tool call costs in hook processes, for Claude Code
    (.claude/settings.json) and Codex (.codex/config.toml). The scenario set is four
    representative payloads per runtime: a Bash call, a write-class call to a docs path
    (Write for Claude, apply_patch for Codex), an Agent spawn call, and one mcp__ call.

    Get-HookCostScenario derives, for each scenario, the hook commands whose group matcher
    admits the tool name. With -Source Registration it reads the PreToolUse groups of the
    registration files; with -Source Dispatcher it reads the single dispatcher registration and
    records the member hooks the runtime's registry (pretooluse-dispatch.json) would run.
    Measure-HookCostSample runs a scenario through an injected process starter; the summary and
    report functions are pure. No function here starts a process, reads the clock, or touches the
    file system: every such effect is a [scriptblock] seam supplied by the caller
    (scripts/dev-tools/Measure-HookProcessCost.ps1 supplies the real ones).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ClaudeHookPattern = '\.claude/hooks/[A-Za-z0-9_.-]+\.ps1'
$script:CodexHookPattern = '\.codex/hooks/[A-Za-z0-9_.-]+\.ps1'
$script:DispatcherLeaf = 'invoke-pretooluse-dispatch.ps1'
$script:RootToken = '{{REPOSITORY_ROOT}}'

function Test-HookCostMatcher {
    <#
    .SYNOPSIS
        Returns $true when a PreToolUse group matcher admits a tool name.
    .DESCRIPTION
        Claude: an empty matcher or '*' admits every tool; a matcher made only of letters, digits,
        '_', '-', space, ',' and '|' is an exact name or exact list; any other matcher is an
        unanchored regular expression. Codex: the matcher is a regular expression as written, and
        apply_patch is also admitted when the matcher admits Edit or Write.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)] [ValidateSet('claude', 'codex')] [string] $Runtime,
        [AllowEmptyString()] [AllowNull()] [string] $Matcher,
        [Parameter(Mandatory)] [string] $ToolName
    )

    if ([string]::IsNullOrEmpty($Matcher) -or $Matcher -eq '*') { return $true }
    if ($Runtime -eq 'claude') {
        if ($Matcher -cmatch '^[A-Za-z0-9_\-, |]+$') {
            $names = @($Matcher -split '[|,]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            return ($names -ccontains $ToolName)
        }
        return [regex]::IsMatch($ToolName, $Matcher)
    }
    if ([regex]::IsMatch($ToolName, $Matcher)) { return $true }
    if ($ToolName -ceq 'apply_patch') { return ([regex]::IsMatch('Edit', $Matcher) -or [regex]::IsMatch('Write', $Matcher)) }
    return $false
}

function ConvertFrom-HookCostCodexConfig {
    <#
    .SYNOPSIS
        Parses the [[hooks.PreToolUse]] tables of a Codex config.toml text into groups.
    .DESCRIPTION
        Returns one object per table, in file order, with Matcher and Hooks; each hook carries
        Type, Command, CommandWindows and Timeout (an int, or $null). Only the line shapes the
        repository's config uses are read: single-line 'key = value' pairs with a basic or
        literal TOML string, or an integer.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $Text)

    $groups = [System.Collections.Generic.List[object]]::new()
    $group = $null; $hook = $null; $section = ''
    foreach ($line in ($Text -split "`r?`n")) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\[\[hooks\.PreToolUse\]\]$') {
            $section = 'group'; $hook = $null
            $group = [pscustomobject]@{ Matcher = $null; Hooks = [System.Collections.Generic.List[object]]::new() }
            $groups.Add($group); continue
        }
        if ($trimmed -match '^\[\[hooks\.PreToolUse\.hooks\]\]$') {
            if ($null -eq $group) { continue }
            $section = 'hook'
            $hook = [pscustomobject]@{ Type = $null; Command = $null; CommandWindows = $null; Timeout = $null }
            $group.Hooks.Add($hook); continue
        }
        if ($trimmed.StartsWith('[')) { $section = ''; $group = $null; $hook = $null; continue }
        if ($section -eq '' -or $trimmed -notmatch '^(?<key>[A-Za-z_]+)\s*=\s*(?<value>.+)$') { continue }
        $key = $Matches['key']; $raw = $Matches['value'].Trim()
        $value = if ($raw -match '^"(?<v>(?:[^"\\]|\\.)*)"$') { $Matches['v'] -replace '\\(.)', '$1' }
        elseif ($raw -match "^'(?<v>[^']*)'$") { $Matches['v'] }
        elseif ($raw -match '^\d+$') { [int]$raw }
        else { $raw }
        if ($section -eq 'group' -and $key -eq 'matcher') { $group.Matcher = [string]$value }
        elseif ($section -eq 'hook') {
            switch ($key) {
                'type' { $hook.Type = [string]$value }
                'command' { $hook.Command = [string]$value }
                'command_windows' { $hook.CommandWindows = [string]$value }
                'timeout' { $hook.Timeout = $value }
            }
        }
    }
    foreach ($item in $groups) { $item }
}

function ConvertFrom-HookCostJsonGroup {
    # Normalizes the PreToolUse groups of a settings.json or registry JSON document.
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] [AllowEmptyString()] [string] $Text, [switch] $Registry)

    $document = $Text | ConvertFrom-Json
    if (@($document.PSObject.Properties | ForEach-Object Name) -notcontains 'hooks') { return }
    $hooksNode = $document.hooks
    if ($null -eq $hooksNode -or @($hooksNode.PSObject.Properties | ForEach-Object Name) -notcontains 'PreToolUse') { return }
    foreach ($group in @($hooksNode.PreToolUse)) {
        $matcher = if (@($group.PSObject.Properties | ForEach-Object Name) -contains 'matcher') { [string]$group.matcher } else { '' }
        $hooks = foreach ($hook in @($group.hooks)) {
            $names = @($hook.PSObject.Properties | ForEach-Object Name)
            [pscustomobject]@{
                Type           = [string]$hook.type
                Command        = [string]$hook.command
                CommandWindows = $(if ($names -contains 'command_windows') { [string]$hook.command_windows } else { $null })
                Timeout        = $(if ($names -contains 'timeout') { $hook.timeout } else { $null })
            }
        }
        [pscustomobject]@{ Matcher = $matcher; Hooks = @($hooks) }
    }
}

function Get-HookCostScenarioPayload {
    # The four representative payload templates per runtime; the root token is replaced at run time.
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] [ValidateSet('claude', 'codex')] [string] $Runtime)

    $patch = "*** Begin Patch`n*** Update File: docs/hook-cost-probe.md`n@@`n-old`n+new`n*** End Patch`n"
    $writeName = if ($Runtime -eq 'claude') { 'Write' } else { 'apply_patch' }
    $writeInput = if ($Runtime -eq 'claude') { [ordered]@{ file_path = 'docs/hook-cost-probe.md'; content = "probe`n" } } else { [ordered]@{ command = $patch } }
    $definitions = @(
        @{ Scenario = 'bash'; ToolName = 'Bash'; ToolInput = [ordered]@{ command = 'git status --short' } },
        @{ Scenario = 'write'; ToolName = $writeName; ToolInput = $writeInput },
        @{ Scenario = 'agent'; ToolName = 'Agent'; ToolInput = [ordered]@{ subagent_type = 'task-researcher'; description = 'hook cost probe'; prompt = 'hook cost probe' } },
        @{ Scenario = 'mcp'; ToolName = 'mcp__drm-copilot__run_discovery_repo_inventory'; ToolInput = [ordered]@{} }
    )
    foreach ($definition in $definitions) {
        $payload = [ordered]@{
            session_id      = 'hook-process-cost'
            hook_event_name = 'PreToolUse'
            cwd             = $script:RootToken
            tool_name       = $definition.ToolName
            tool_input      = $definition.ToolInput
        }
        [pscustomobject]@{ Scenario = $definition.Scenario; ToolName = $definition.ToolName; PayloadTemplate = ($payload | ConvertTo-Json -Compress -Depth 8) }
    }
}

function Get-HookCostHookPath {
    # Returns the root-relative hook script paths named by one hook command, in order.
    param([Parameter(Mandatory)] [ValidateSet('claude', 'codex')] [string] $Runtime, [AllowEmptyString()] [string] $Command)
    $pattern = if ($Runtime -eq 'claude') { $script:ClaudeHookPattern } else { $script:CodexHookPattern }
    foreach ($m in [regex]::Matches($Command, $pattern)) { $m.Value }
}

function Get-HookCostScenario {
    <#
    .SYNOPSIS
        Derives the measurement scenarios of both runtimes from registration (and registry) text.
    .DESCRIPTION
        Returns one object per runtime and scenario with Runtime, Scenario, ToolName,
        PayloadTemplate, Hooks (root-relative hook paths in registration order), ProcessCount,
        MemberHooks and Source. With -Source Registration, Hooks are the commands of every
        PreToolUse group whose matcher admits the tool name and MemberHooks equals Hooks. With
        -Source Dispatcher, every selected command must invoke invoke-pretooluse-dispatch.ps1
        (the function throws otherwise), and MemberHooks are the registry hooks the dispatcher
        would run for the tool name.
    .PARAMETER ReadText
        Reader seam: a repository-relative path in, the file text (or $null) out.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [ValidateSet('Registration', 'Dispatcher')] [string] $Source,
        [Parameter(Mandatory)] [scriptblock] $ReadText
    )

    $sources = @(
        @{ Runtime = 'claude'; Registration = '.claude/settings.json'; Registry = '.claude/hooks/pretooluse-dispatch.json' },
        @{ Runtime = 'codex'; Registration = '.codex/config.toml'; Registry = '.codex/hooks/pretooluse-dispatch.json' }
    )
    foreach ($entry in $sources) {
        $runtime = $entry.Runtime
        $text = & $ReadText $entry.Registration
        if ($null -eq $text) { throw "Registration file not readable: $($entry.Registration)" }
        $groups = @(if ($runtime -eq 'claude') { ConvertFrom-HookCostJsonGroup -Text $text } else { ConvertFrom-HookCostCodexConfig -Text $text })
        $registryGroups = @()
        if ($Source -eq 'Dispatcher') {
            $registryText = & $ReadText $entry.Registry
            if ($null -eq $registryText) { throw "Registry file not readable: $($entry.Registry)" }
            $registryGroups = @(ConvertFrom-HookCostJsonGroup -Text $registryText -Registry)
        }
        foreach ($payload in @(Get-HookCostScenarioPayload -Runtime $runtime)) {
            $hooks = [System.Collections.Generic.List[string]]::new()
            foreach ($group in $groups) {
                if (-not (Test-HookCostMatcher -Runtime $runtime -Matcher $group.Matcher -ToolName $payload.ToolName)) { continue }
                foreach ($hook in @($group.Hooks)) { foreach ($path in @(Get-HookCostHookPath -Runtime $runtime -Command $hook.Command)) { $hooks.Add($path) } }
            }
            $members = [System.Collections.Generic.List[string]]::new()
            if ($Source -eq 'Dispatcher') {
                foreach ($path in $hooks) {
                    if (($path -split '/')[-1] -ne $script:DispatcherLeaf) { throw "Dispatcher source expects only $($script:DispatcherLeaf) registrations; found $path for $runtime $($payload.ToolName)." }
                }
                foreach ($group in $registryGroups) {
                    if (-not (Test-HookCostMatcher -Runtime $runtime -Matcher $group.Matcher -ToolName $payload.ToolName)) { continue }
                    foreach ($hook in @($group.Hooks)) { foreach ($path in @(Get-HookCostHookPath -Runtime $runtime -Command $hook.Command)) { $members.Add($path) } }
                }
            }
            else { foreach ($path in $hooks) { $members.Add($path) } }
            [pscustomobject]@{
                Runtime         = $runtime
                Scenario        = $payload.Scenario
                ToolName        = $payload.ToolName
                PayloadTemplate = $payload.PayloadTemplate
                Hooks           = [string[]]$hooks.ToArray()
                ProcessCount    = $hooks.Count
                MemberHooks     = [string[]]$members.ToArray()
                Source          = $Source
            }
        }
    }
}

function Measure-HookCostSample {
    <#
    .SYNOPSIS
        Runs one scenario a number of times through the injected process starter.
    .DESCRIPTION
        StartHookProcess receives the scenario and returns an object with ProcessCount,
        CpuSeconds, StartTicks, EndTicks (TimeSpan ticks) and ExitCode (the highest hook exit
        code). GetTimestamp returns the sample time recorded on each sample. Returns one sample
        object per iteration with Runtime, Scenario, Iteration, ProcessCount, CpuSeconds,
        WallSeconds, ExitCode and SampledAt.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [pscustomobject] $Scenario,
        [Parameter(Mandatory)] [ValidateRange(1, 1000)] [int] $Iterations,
        [Parameter(Mandatory)] [scriptblock] $StartHookProcess,
        [Parameter(Mandatory)] [scriptblock] $GetTimestamp
    )

    for ($i = 1; $i -le $Iterations; $i++) {
        $result = & $StartHookProcess $Scenario
        if ($null -eq $result) { throw "The process starter returned no result for $($Scenario.Runtime) $($Scenario.Scenario)." }
        $wall = ([double]$result.EndTicks - [double]$result.StartTicks) / [double][TimeSpan]::TicksPerSecond
        [pscustomobject]@{
            Runtime      = $Scenario.Runtime
            Scenario     = $Scenario.Scenario
            Iteration    = $i
            ProcessCount = [int]$result.ProcessCount
            CpuSeconds   = [double]$result.CpuSeconds
            WallSeconds  = $wall
            ExitCode     = [int]$result.ExitCode
            SampledAt    = [string](& $GetTimestamp)
        }
    }
}

function Get-HookCostStatistic {
    # Median, mean and max of a non-empty list of numbers.
    param([Parameter(Mandatory)] [double[]] $Values)
    $sorted = [double[]]($Values | Sort-Object)
    $count = $sorted.Count
    $median = if ($count % 2 -eq 1) { $sorted[($count - 1) / 2] } else { ($sorted[$count / 2 - 1] + $sorted[$count / 2]) / 2 }
    $sum = 0.0; foreach ($v in $sorted) { $sum += $v }
    [pscustomobject]@{ Median = $median; Mean = $sum / $count; Max = $sorted[$count - 1] }
}

function Get-HookCostSummary {
    <#
    .SYNOPSIS
        Summarizes samples per runtime and scenario: process count, CPU and wall statistics.
    .DESCRIPTION
        Groups are emitted in first-seen order. ProcessCount is the per-call count when every
        sample agrees and the maximum otherwise (ProcessCountStable records which). MaxExitCode is
        the highest hook exit code seen.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Samples)

    $order = [System.Collections.Generic.List[string]]::new()
    $byKey = @{}
    foreach ($sample in $Samples) {
        $key = "$($sample.Runtime)|$($sample.Scenario)"
        if (-not $byKey.ContainsKey($key)) { $byKey[$key] = [System.Collections.Generic.List[object]]::new(); $order.Add($key) }
        $byKey[$key].Add($sample)
    }
    foreach ($key in $order) {
        $group = $byKey[$key]
        $counts = @($group | ForEach-Object { [int]$_.ProcessCount } | Sort-Object -Unique)
        [pscustomobject]@{
            Runtime            = $group[0].Runtime
            Scenario           = $group[0].Scenario
            Samples            = $group.Count
            ProcessCount       = ($counts | Measure-Object -Maximum).Maximum
            ProcessCountStable = ($counts.Count -eq 1)
            Cpu                = Get-HookCostStatistic -Values @($group | ForEach-Object { [double]$_.CpuSeconds })
            Wall               = Get-HookCostStatistic -Values @($group | ForEach-Object { [double]$_.WallSeconds })
            MaxExitCode        = ($group | ForEach-Object { [int]$_.ExitCode } | Measure-Object -Maximum).Maximum
        }
    }
}

function Format-HookCostReport {
    <#
    .SYNOPSIS
        Renders the cost report as Markdown lines.
    .DESCRIPTION
        The report carries the Timestamp:, Command:, EXIT_CODE: and Output Summary: lines, one
        table row per runtime and scenario (process count, CPU seconds and wall seconds as
        median/mean/max), the per-scenario hook list, the payload templates, and the statement
        that grandchild processes are excluded. It contains no host path: payloads carry the
        repository-root token.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [ValidateSet('Registration', 'Dispatcher')] [string] $Source,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Summary,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Scenarios,
        [Parameter(Mandatory)] [string] $Timestamp,
        [Parameter(Mandatory)] [string] $Command,
        [Parameter(Mandatory)] [int] $ExitCode,
        [Parameter(Mandatory)] [int] $Iterations
    )

    $fmt = { param($s) '{0:0.000}/{1:0.000}/{2:0.000}' -f $s.Median, $s.Mean, $s.Max }
    $counts = @($Summary | ForEach-Object { "$($_.Runtime) $($_.Scenario)=$($_.ProcessCount)" }) -join ', '
    "# Hook process cost report (-Source $Source)"
    ''
    "Timestamp: $Timestamp"
    "Command: $Command"
    "EXIT_CODE: $ExitCode"
    "Output Summary: $Iterations iteration(s) per scenario; hook processes per call: $counts. CPU and wall seconds are reported as median/mean/max. Grandchild processes (git, gh) started by hooks are excluded from the process count and CPU seconds."
    ''
    'Grandchild processes (git, gh) started by hook scripts are excluded: the process count and CPU seconds cover only the hook processes the runtime starts.'
    ''
    '| Runtime | Scenario | Tool name | Processes per call | CPU seconds (median/mean/max) | Wall seconds (median/mean/max) | Max hook exit code |'
    '|---|---|---|---|---|---|---|'
    foreach ($row in $Summary) {
        $scenario = @($Scenarios | Where-Object { $_.Runtime -eq $row.Runtime -and $_.Scenario -eq $row.Scenario }) | Select-Object -First 1
        $tool = if ($null -ne $scenario) { $scenario.ToolName } else { '' }
        $stable = if ($row.ProcessCountStable) { '' } else { ' (varied)' }
        "| $($row.Runtime) | $($row.Scenario) | ``$tool`` | $($row.ProcessCount)$stable | $(& $fmt $row.Cpu) | $(& $fmt $row.Wall) | $($row.MaxExitCode) |"
    }
    ''
    '## Hooks per scenario'
    ''
    foreach ($scenario in $Scenarios) {
        $members = if ($Source -eq 'Dispatcher') { " (dispatched members: $(@($scenario.MemberHooks).Count))" } else { '' }
        "- $($scenario.Runtime) $($scenario.Scenario): $(@($scenario.Hooks) -join ', ')$members"
    }
    ''
    "## Payload templates ($($script:RootToken) is replaced by the repository root at run time)"
    ''
    foreach ($scenario in $Scenarios) { "- $($scenario.Runtime) $($scenario.Scenario): ``$($scenario.PayloadTemplate)``" }
}

function Resolve-HookCostPayload {
    # Replaces the repository-root token in a payload template with a JSON-escaped root path.
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)] [string] $PayloadTemplate, [Parameter(Mandatory)] [string] $RepositoryRoot)
    $escaped = ($RepositoryRoot -replace '\\', '/') -replace '"', '\"'
    return $PayloadTemplate.Replace($script:RootToken, $escaped)
}

Export-ModuleMember -Function Get-HookCostScenario, Measure-HookCostSample, Get-HookCostSummary, Format-HookCostReport, Resolve-HookCostPayload, Test-HookCostMatcher, ConvertFrom-HookCostCodexConfig
