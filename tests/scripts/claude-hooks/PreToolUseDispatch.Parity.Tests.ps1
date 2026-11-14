#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Process-level parity of the PreToolUse dispatcher against one process per hook (issue #1159).

.DESCRIPTION
    Every set is derived at discovery time from .claude/settings.json, .codex/config.toml and the
    two registries .claude/hooks/pretooluse-dispatch.json and .codex/hooks/pretooluse-dispatch.json,
    so no hook list, hook name set or per-tool count is frozen here.

    The registration rows assert one PreToolUse registration per runtime (the dispatcher), a
    dispatcher matcher that admits every tool name a registry group admits, the Codex timeout
    equal to the registry timeout sum, existing hook files, the settings shape of every group and
    the shipped isolation value.

    For each envelope of PreToolUseDispatch.ParityCorpus.Claude.ps1 and
    PreToolUseDispatch.ParityCorpus.Codex.ps1 the suite runs (i) every hook the registry selects
    for the tool name as its own 'pwsh -NoProfile -File' process and (ii) the dispatcher once with
    -PerHookTrace, and compares per-hook exit code, decision, reason and additionalContext, the
    combined decision with its ordered deny reasons and deny code tokens, and the ordered
    additionalContext. A registry hook without an allow and a deny envelope is reported by name as
    a skipped 'has parity envelopes for <hook leaf>' row. The module-load row counts the modules
    each dispatched hook loaded from the trace.

    Processes are started with redirected streams read asynchronously; no test writes a file, sets
    a variable outside its own scope or changes the location.
#>

BeforeDiscovery {
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path

    function Test-ParityMatcher {
        # Mirrors the matcher rule of each runtime: Claude exact names or an unanchored regex;
        # Codex a regex, with apply_patch also admitted by a matcher that admits Edit or Write.
        param([string] $Runtime, [AllowEmptyString()] [string] $Matcher, [string] $ToolName)
        if ([string]::IsNullOrEmpty($Matcher) -or $Matcher -eq '*') { return $true }
        if ($Runtime -eq 'claude' -and $Matcher -cmatch '^[A-Za-z0-9_\-, |]+$') {
            return (@($Matcher -split '[|,]' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) -ccontains $ToolName)
        }
        if ([regex]::IsMatch($ToolName, $Matcher)) { return $true }
        return ($Runtime -eq 'codex' -and $ToolName -ceq 'apply_patch' -and ([regex]::IsMatch('Edit', $Matcher) -or [regex]::IsMatch('Write', $Matcher)))
    }

    $script:EnvelopeRows = [System.Collections.Generic.List[hashtable]]::new()
    $script:CoverageRows = [System.Collections.Generic.List[hashtable]]::new()
    $script:ModuleRows = [System.Collections.Generic.List[hashtable]]::new()
    foreach ($runtime in 'claude', 'codex') {
        $registryPath = Join-Path $repoRoot ".$runtime/hooks/pretooluse-dispatch.json"
        $groups = @((Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json).hooks.PreToolUse)
        $corpus = & (Join-Path $PSScriptRoot "PreToolUseDispatch.ParityCorpus.$((Get-Culture).TextInfo.ToTitleCase($runtime)).ps1")
        $leaves = [System.Collections.Generic.List[string]]::new()
        foreach ($group in $groups) { foreach ($hook in @($group.hooks)) { $leaf = [regex]::Match([string]$hook.command, "\.$runtime/hooks/(?<leaf>[A-Za-z0-9.-]+\.ps1)").Groups['leaf'].Value; if (-not $leaves.Contains($leaf)) { $leaves.Add($leaf) } } }

        # One row per envelope: the payload text and the registry hooks selected for its tool name.
        $allowed = @{}; $denied = @{}; $widest = $null
        foreach ($envelope in @($corpus.Envelopes)) {
            $selected = [System.Collections.Generic.List[string]]::new()
            foreach ($group in $groups) {
                if (-not (Test-ParityMatcher -Runtime $runtime -Matcher ([string]$group.matcher) -ToolName $envelope.ToolName)) { continue }
                foreach ($hook in @($group.hooks)) { $selected.Add([regex]::Match([string]$hook.command, "\.$runtime/hooks/(?<leaf>[A-Za-z0-9.-]+\.ps1)").Groups['leaf'].Value) }
            }
            $payload = [ordered]@{ session_id = 'pretooluse-dispatch-parity'; hook_event_name = 'PreToolUse'; cwd = $repoRoot; tool_name = $envelope.ToolName }
            if ($null -ne $envelope.ToolInput) { $payload['tool_input'] = $envelope.ToolInput }
            $row = @{ Runtime = $runtime; Key = $envelope.Key; ToolName = $envelope.ToolName; PayloadText = ($payload | ConvertTo-Json -Compress -Depth 20); Environment = $envelope.Environment; Selected = $selected.ToArray(); Deny = @($envelope.Deny) }
            $script:EnvelopeRows.Add($row)
            foreach ($leaf in $selected) {
                if ($envelope.Kind -eq 'allow' -and @($envelope.Except) -notcontains $leaf) { $allowed[$leaf] = $true }
            }
            foreach ($leaf in @($envelope.Deny)) { $denied[$leaf] = $true }
            if ($envelope.Kind -eq 'allow' -and ($null -eq $widest -or $selected.Count -gt $widest.Selected.Count)) { $widest = $row }
        }
        foreach ($leaf in $leaves) {
            $reason = if ($corpus.NoEnvelope.ContainsKey($leaf)) { $corpus.NoEnvelope[$leaf] } else { 'no allow and deny envelope pair and no recorded reason in the parity corpus' }
            $script:CoverageRows.Add(@{ Runtime = $runtime; Leaf = $leaf; HasAllow = [bool]$allowed[$leaf]; HasDeny = [bool]$denied[$leaf]; Reason = $reason })
        }
        $script:ModuleRows.Add(@{ Runtime = $runtime; Key = $widest.Key; PayloadText = $widest.PayloadText; Environment = $widest.Environment })
    }
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:PwshPath = (Get-Command pwsh -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $script:Rank = @{ deny = 4; defer = 3; ask = 2; allow = 1 }

    function Invoke-ParityProcess {
        # Starts pwsh -NoProfile -File <script> with the payload on stdin; both output streams are read asynchronously.
        param([string] $ScriptPath, [string[]] $Argument = @(), [string] $PayloadText, [hashtable] $Environment)
        $startInfo = [System.Diagnostics.ProcessStartInfo]::new($script:PwshPath)
        foreach ($item in @('-NoProfile', '-File', $ScriptPath) + $Argument) { $startInfo.ArgumentList.Add($item) }
        $startInfo.WorkingDirectory = $script:RepoRoot
        $startInfo.RedirectStandardInput = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.UseShellExecute = $false
        if ($null -ne $Environment) { foreach ($name in $Environment.Keys) { $startInfo.Environment[$name] = [string]$Environment[$name] } }
        $process = [System.Diagnostics.Process]::Start($startInfo)
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $process.StandardInput.Write($PayloadText)
        $process.StandardInput.Close()
        return [pscustomobject]@{ Process = $process; Stdout = $stdout; Stderr = $stderr }
    }

    function Complete-ParityProcess {
        # Waits for one started process (bounded) and returns its exit code and output text.
        param([pscustomobject] $Handle)
        try {
            if (-not $Handle.Process.WaitForExit(300000)) { $Handle.Process.Kill($true); throw 'a parity process did not exit within 300 seconds' }
            $Handle.Process.WaitForExit()
            return [pscustomobject]@{ ExitCode = $Handle.Process.ExitCode; Stdout = $Handle.Stdout.Result; Stderr = $Handle.Stderr.Result }
        } finally {
            $Handle.Process.Dispose()
        }
    }

    function ConvertTo-ParityDecision {
        # Test-side normalizer of one hook result: exit 2 = deny with the stderr (or JSON) reason; exit 0 with
        # JSON = its permissionDecision; anything else = no decision.
        param([int] $ExitCode, [AllowEmptyString()] [string] $Stdout, [AllowEmptyString()] [string] $Stderr)
        $result = [pscustomobject]@{ Decision = ''; Reason = ''; Context = '' }
        $text = ([string]$Stdout).Trim()
        $parsed = $null
        if ($text) { try { $parsed = $text | ConvertFrom-Json -ErrorAction Stop } catch { $parsed = $null } }
        $specific = if ($parsed -is [pscustomobject] -and $parsed.PSObject.Properties['hookSpecificOutput']) { $parsed.hookSpecificOutput } else { $null }
        $jsonReason = if ($null -ne $specific -and $specific.PSObject.Properties['permissionDecisionReason']) { [string]$specific.permissionDecisionReason } elseif ($parsed -is [pscustomobject] -and $parsed.PSObject.Properties['reason']) { [string]$parsed.reason } else { '' }
        if ($ExitCode -eq 2) {
            $result.Decision = 'deny'
            $result.Reason = if (([string]$Stderr).Trim()) { ([string]$Stderr).Trim() } else { $jsonReason }
            return $result
        }
        if ($ExitCode -ne 0 -or $parsed -isnot [pscustomobject]) { return $result }
        if ($null -ne $specific -and $specific.PSObject.Properties['additionalContext']) { $result.Context = [string]$specific.additionalContext }
        $decision = if ($null -ne $specific -and $specific.PSObject.Properties['permissionDecision']) { [string]$specific.permissionDecision } else { '' }
        if (-not $decision -and $parsed.PSObject.Properties['decision']) { $decision = switch ([string]$parsed.decision) { 'block' { 'deny' } 'approve' { 'allow' } default { '' } } }
        if ($script:Rank.ContainsKey($decision)) { $result.Decision = $decision; $result.Reason = $jsonReason }
        return $result
    }

    function Invoke-ParityDispatcher {
        # Runs the runtime's dispatcher once with -PerHookTrace; returns the stdout text and the parsed trace records.
        param([string] $Runtime, [string] $PayloadText, [hashtable] $Environment)
        $handle = Invoke-ParityProcess -ScriptPath (Join-Path $script:RepoRoot ".$Runtime/hooks/invoke-pretooluse-dispatch.ps1") -Argument @('-PerHookTrace') -PayloadText $PayloadText -Environment $Environment
        $done = Complete-ParityProcess -Handle $handle
        $trace = @(([string]$done.Stderr) -split "`r?`n" | Where-Object { $_.TrimStart().StartsWith('{') } | ForEach-Object { $_ | ConvertFrom-Json })
        return [pscustomobject]@{ ExitCode = $done.ExitCode; Stdout = [string]$done.Stdout; Trace = $trace }
    }
}

Describe 'PreToolUse dispatcher registration shape (issue #1159)' {
    BeforeAll {
        $script:Settings = Get-Content -LiteralPath (Join-Path $script:RepoRoot '.claude/settings.json') -Raw | ConvertFrom-Json
        $script:ConfigLines = @(Get-Content -LiteralPath (Join-Path $script:RepoRoot '.codex/config.toml'))
        $script:Registries = @{
            claude = Get-Content -LiteralPath (Join-Path $script:RepoRoot '.claude/hooks/pretooluse-dispatch.json') -Raw | ConvertFrom-Json
            codex  = Get-Content -LiteralPath (Join-Path $script:RepoRoot '.codex/hooks/pretooluse-dispatch.json') -Raw | ConvertFrom-Json
        }
        $sectionLines = [System.Collections.Generic.List[string]]::new()
        $inSection = $false
        foreach ($line in $script:ConfigLines) {
            if ($line -match '^\[\[hooks\.(?<table>[A-Za-z.]+)\]\]$') { $inSection = $Matches['table'] -like 'PreToolUse*' }
            if ($inSection) { $sectionLines.Add($line) }
        }
        $script:CodexSection = $sectionLines.ToArray()

        function Get-ParityGroupToolName {
            # Expands a registry group matcher into concrete tool names ('.*' becomes a sample suffix).
            param([string] $Matcher)
            $body = $Matcher -replace '^\^\(?', '' -replace '\)?\$$', ''
            return @($body -split '\|' | ForEach-Object { $_.Trim().Replace('.*', 'sample') } | Where-Object { $_ })
        }
    }

    It 'registers exactly one PreToolUse entry, the dispatcher, in .claude/settings.json' {
        $entries = @($script:Settings.hooks.PreToolUse)
        $entries.Count | Should -Be 1
        @($entries[0].hooks).Count | Should -Be 1
        [string]$entries[0].hooks[0].command | Should -BeLike '*.claude/hooks/invoke-pretooluse-dispatch.ps1*'
    }

    It 'registers exactly one PreToolUse table, the dispatcher, in .codex/config.toml' {
        @($script:CodexSection | Where-Object { $_ -match '^\[\[hooks\.PreToolUse\]\]$' }).Count | Should -Be 1
        $commands = @($script:CodexSection | Where-Object { $_ -match '^command\s*=' })
        $commands.Count | Should -Be 1
        $commands[0] | Should -BeLike '*.codex/hooks/invoke-pretooluse-dispatch.ps1*'
    }

    It 'admits every Claude registry tool name with the dispatcher matcher' {
        $matcher = [string]@($script:Settings.hooks.PreToolUse)[0].matcher
        $names = @($script:Registries.claude.hooks.PreToolUse | ForEach-Object { Get-ParityGroupToolName -Matcher ([string]$_.matcher) } | Sort-Object -Unique)
        $names.Count | Should -BeGreaterThan 0
        foreach ($name in $names) { [regex]::IsMatch($name, $matcher) | Should -BeTrue -Because "the dispatcher matcher must admit $name" }
    }

    It 'admits every Codex registry tool name with the dispatcher matcher' {
        $line = @($script:CodexSection | Where-Object { $_ -match '^matcher\s*=' })[0]
        $matcher = [regex]::Match($line, '^matcher\s*=\s*"(?<m>.+)"\s*$').Groups['m'].Value
        $names = @($script:Registries.codex.hooks.PreToolUse | ForEach-Object { Get-ParityGroupToolName -Matcher ([string]$_.matcher) } | Sort-Object -Unique)
        $names.Count | Should -BeGreaterThan 0
        foreach ($name in $names) { [regex]::IsMatch($name, $matcher) | Should -BeTrue -Because "the dispatcher matcher must admit $name" }
    }

    It 'sets the Codex dispatcher timeout to the registry timeout sum' {
        $sum = 0
        foreach ($group in @($script:Registries.codex.hooks.PreToolUse)) { foreach ($hook in @($group.hooks)) { $sum += [int]$hook.timeout } }
        $timeouts = @($script:CodexSection | Where-Object { $_ -match '^timeout\s*=' } | ForEach-Object { [int]($_ -replace '^timeout\s*=\s*', '') })
        $timeouts | Should -Be @($sum)
    }

    It 'resolves every <Runtime> registry hook to an existing file in the settings shape' -ForEach @(@{ Runtime = 'claude' }, @{ Runtime = 'codex' }) {
        $groups = @($script:Registries[$Runtime].hooks.PreToolUse)
        $groups.Count | Should -BeGreaterThan 0
        foreach ($group in $groups) {
            $group.matcher | Should -BeOfType [string]
            @($group.hooks).Count | Should -BeGreaterThan 0
            foreach ($hook in @($group.hooks)) {
                $hook.type | Should -Be 'command'
                $leaf = [regex]::Match([string]$hook.command, "\.$Runtime/hooks/(?<leaf>[A-Za-z0-9.-]+\.ps1)").Groups['leaf'].Value
                $leaf | Should -Not -BeNullOrEmpty -Because "$($hook.command) must name a $Runtime hook script"
                Test-Path -LiteralPath (Join-Path $script:RepoRoot ".$Runtime/hooks/$leaf") -PathType Leaf | Should -BeTrue -Because "$leaf is registered"
            }
        }
    }

    It 'ships both registries with isolation set to in-process' {
        $script:Registries.claude.isolation | Should -Be 'in-process'
        $script:Registries.codex.isolation | Should -Be 'in-process'
    }
}

Describe 'PreToolUse dispatcher per-hook parity (issue #1159)' {
    It '<Runtime> envelope <Key> yields the same per-hook and combined decisions in both modes' -ForEach $script:EnvelopeRows {
        # Act: every selected hook as its own process, concurrently, and the dispatcher once with the per-hook trace.
        $handles = @(foreach ($leaf in $Selected) { Invoke-ParityProcess -ScriptPath (Join-Path $script:RepoRoot ".$Runtime/hooks/$leaf") -PayloadText $PayloadText -Environment $Environment })
        $dispatcher = Invoke-ParityDispatcher -Runtime $Runtime -PayloadText $PayloadText -Environment $Environment
        $perHook = @(foreach ($handle in $handles) { $done = Complete-ParityProcess -Handle $handle; ConvertTo-ParityDecision -ExitCode $done.ExitCode -Stdout $done.Stdout -Stderr $done.Stderr | Add-Member -NotePropertyName ExitCode -NotePropertyValue $done.ExitCode -PassThru })

        # Assert: one trace record per selected hook, in registry order, matching the per-process result.
        $dispatcher.ExitCode | Should -Be 0
        @($dispatcher.Trace | ForEach-Object { Split-Path -Path ([string]$_.hook) -Leaf }) | Should -Be @($Selected)
        $mismatches = [System.Collections.Generic.List[string]]::new()
        for ($index = 0; $index -lt $Selected.Count; $index++) {
            $expected = $perHook[$index]; $actual = $dispatcher.Trace[$index]
            foreach ($pair in @(@('exit code', [string]$expected.ExitCode, [string]$actual.exitCode), @('decision', $expected.Decision, [string]$actual.decision), @('reason', $expected.Reason, ([string]$actual.reason).Trim()), @('additionalContext', $expected.Context, [string]$actual.additionalContext))) {
                if ($pair[1] -cne $pair[2]) { $mismatches.Add(("{0} {1}: per-process [{2}] dispatcher [{3}]" -f $Selected[$index], $pair[0], $pair[1], $pair[2])) }
            }
        }
        $mismatches -join "`n" | Should -BeNullOrEmpty

        # Assert: the combined decision equals the combination of the per-process results.
        $strongest = ''
        foreach ($item in $perHook) { if ($item.Decision -and (-not $strongest -or $script:Rank[$item.Decision] -gt $script:Rank[$strongest])) { $strongest = $item.Decision } }
        $reasons = @($perHook | Where-Object { $_.Decision -eq $strongest -and $_.Reason } | ForEach-Object { $_.Reason })
        $contexts = @($perHook | Where-Object { $_.Context } | ForEach-Object { $_.Context })
        $combinedText = $dispatcher.Stdout.Trim()
        if (-not $strongest -and $contexts.Count -eq 0) {
            $combinedText | Should -BeNullOrEmpty
        } else {
            $combined = ($combinedText | ConvertFrom-Json).hookSpecificOutput
            [string]$combined.permissionDecision | Should -Be $strongest
            [string]$combined.permissionDecisionReason | Should -Be ($reasons -join "`n")
            @([regex]::Matches([string]$combined.permissionDecisionReason, '[A-Z][A-Z_]+_(?:BLOCKED|REQUIRED)') | ForEach-Object Value) | Should -Be @([regex]::Matches(($reasons -join "`n"), '[A-Z][A-Z_]+_(?:BLOCKED|REQUIRED)') | ForEach-Object Value)
            [string]$combined.additionalContext | Should -Be ($contexts -join "`n")
        }

        # Assert: every hook the corpus names as denied by this envelope denies it.
        foreach ($leaf in $Deny) { $perHook[[array]::IndexOf($Selected, $leaf)].Decision | Should -Be 'deny' -Because "$Runtime envelope $Key is the deny envelope of $leaf" }
    }

    Context '<Runtime> registry envelopes' -ForEach @(@{ Runtime = 'claude' }, @{ Runtime = 'codex' }) {
        $runtimeName = $Runtime
        It 'has parity envelopes for <Leaf>' -ForEach @($script:CoverageRows | Where-Object { $_.Runtime -eq $runtimeName }) {
            if (-not ($HasAllow -and $HasDeny)) { Set-ItResult -Skipped -Because $Reason; return }
            $HasAllow | Should -BeTrue
            $HasDeny | Should -BeTrue
        }
    }
}

Describe 'PreToolUse dispatcher module loading (issue #1159)' {
    It 'loads each stateless shared module once per call' -ForEach $script:ModuleRows {
        # Arrange: modules a registry note keeps re-loading (stateful) are excluded by leaf name.
        $notes = @((Get-Content -LiteralPath (Join-Path $script:RepoRoot ".$Runtime/hooks/pretooluse-dispatch.json") -Raw | ConvertFrom-Json).notes) -join "`n"
        $kept = @([regex]::Matches($notes, '[A-Za-z0-9.-]+\.psm1') | ForEach-Object Value)

        # Act
        $dispatcher = Invoke-ParityDispatcher -Runtime $Runtime -PayloadText $PayloadText -Environment $Environment

        # Assert: no stateless module path is loaded by more than one dispatched hook in the call.
        $dispatcher.Trace.Count | Should -BeGreaterThan 1 -Because "the $Runtime envelope $Key must dispatch several hooks"
        $loads = @($dispatcher.Trace | ForEach-Object { @($_.modulesLoaded) } | Where-Object { $_ -and $kept -notcontains (Split-Path -Path $_ -Leaf) })
        $repeated = @($loads | Group-Object | Where-Object Count -GT 1 | ForEach-Object { '{0} x{1}' -f $_.Name, $_.Count })
        $repeated -join "`n" | Should -BeNullOrEmpty
    }
}
