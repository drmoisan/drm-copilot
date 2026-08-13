# Surface-neutral sealed-input and external-process mechanics for Codex child launches.

function Get-CodexChildSessionIdCore {
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $JsonLines,
        [Parameter(Mandatory)][string] $ErrorPrefix
    )
    foreach ($line in $JsonLines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }
        try {
            $codexEvent = $line | ConvertFrom-Json -Depth 16 -ErrorAction Stop
        } catch {
            throw "$ErrorPrefix codex --json emitted malformed JSON: $_"
        }
        foreach ($candidate in @(
                $codexEvent.thread_id, $codexEvent.session_id, $codexEvent.thread.id,
                $codexEvent.payload.thread_id, $codexEvent.payload.session_id
            )) {
            if (-not [string]::IsNullOrWhiteSpace([string]$candidate)) {
                return [string]$candidate
            }
        }
    }
    return ''
}

function Get-CodexChildSealedJsonFileCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $ErrorPrefix,
        [switch] $HoldOpen,
        [scriptblock] $OpenFile = {
            param([string] $FilePath)
            [System.IO.File]::Open(
                $FilePath,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read,
                [System.IO.FileShare]::Read
            )
        }
    )
    $stream = & $OpenFile $Path
    try {
        $memory = [System.IO.MemoryStream]::new()
        try {
            $stream.CopyTo($memory)
            $bytes = $memory.ToArray()
        } finally {
            $memory.Dispose()
        }
        $offset = if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and
            $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            3
        } else {
            0
        }
        try {
            $raw = [System.Text.UTF8Encoding]::new(
                $false,
                $true
            ).GetString($bytes, $offset, $bytes.Length - $offset)
        } catch {
            throw "$ErrorPrefix $Name is not valid UTF-8."
        }
        $value = ConvertFrom-CodexChildLaunchJsonCore -Raw $raw -Name $Name
        $sha256 = [Convert]::ToHexString(
            [System.Security.Cryptography.SHA256]::HashData($bytes)
        ).ToLowerInvariant()
        if (-not $HoldOpen) {
            $stream.Dispose()
            $stream = $null
        }
        return [pscustomobject]@{ Value = $value; Sha256 = $sha256; Stream = $stream }
    } catch {
        $stream.Dispose()
        throw ([string]$_.Exception.Message).Replace(
            'CODEX_CHILD_LAUNCH_BLOCKED:',
            $ErrorPrefix
        )
    }
}

function Get-CodexChildProcessStartInfoCore {
    [CmdletBinding()]
    [OutputType([System.Diagnostics.ProcessStartInfo])]
    param(
        [Parameter(Mandatory)] $Entry,
        [Parameter(Mandatory)] $AgentProfile,
        [Parameter(Mandatory)] $Receipt,
        [Parameter(Mandatory)][string] $LastMessagePath,
        [Parameter(Mandatory)][string] $RuntimePermissions,
        [Parameter(Mandatory)][string] $EnvironmentPrefix,
        [Parameter(Mandatory)][string] $PermissionOverride,
        [Parameter(Mandatory)][string] $ProjectsOverride,
        [Parameter(Mandatory)][string[]] $ShellOverrides
    )
    $codexCommandPath = [string]$Receipt.codex_command_path
    $isPowerShellShim = $codexCommandPath.EndsWith(
        '.ps1',
        [System.StringComparison]::OrdinalIgnoreCase
    )
    $commandPath = if ($isPowerShellShim) { 'pwsh' } else { $codexCommandPath }
    $info = [System.Diagnostics.ProcessStartInfo]::new($commandPath)
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $info.RedirectStandardInput = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.WorkingDirectory = [string]$Entry.worktree_path
    if ($isPowerShellShim) {
        foreach ($argument in @('-NoProfile', '-File', $codexCommandPath)) {
            $info.ArgumentList.Add($argument)
        }
    }
    foreach ($argument in @(
            'exec', '--ignore-user-config', '-C', [string]$Entry.worktree_path,
            '-c', $ProjectsOverride, '-c', $PermissionOverride,
            '-c', $ShellOverrides[0], '-c', $ShellOverrides[1],
            '-m', [string]$AgentProfile.model,
            '-c', "model_reasoning_effort=$($AgentProfile.model_reasoning_effort)",
            '-c', "default_permissions=`"$RuntimePermissions`"", '-c', 'approval_policy="never"',
            '-c', ('developer_instructions=' + (
                    [string]$AgentProfile.developer_instructions | ConvertTo-Json -Compress
                )),
            '-c', "skills.config=$($AgentProfile.skills_config)", '--strict-config',
            '--dangerously-bypass-hook-trust', '--json', '-o', $LastMessagePath, '-'
        )) {
        $info.ArgumentList.Add($argument)
    }
    if ($IsWindows) {
        $info.ArgumentList.Insert(1, 'windows.sandbox="elevated"')
        $info.ArgumentList.Insert(1, '-c')
    }
    $environment = [ordered]@{
        "${EnvironmentPrefix}_LAUNCH_ID"         = [string]$Receipt.launch_id
        "${EnvironmentPrefix}_LAUNCH_RECEIPT"    = [string]$Receipt.receipt_path
        "${EnvironmentPrefix}_LAUNCH_SPEC"       = [string]$Receipt.spec_path
        "${EnvironmentPrefix}_EXPECTED_WORKTREE" = [string]$Receipt.worktree_path
        "${EnvironmentPrefix}_DELEGATION_ID"     = [string]$Receipt.delegation_id
        "${EnvironmentPrefix}_EXECUTION_CONTEXT" = [string]$Receipt.execution_context
        "${EnvironmentPrefix}_AGENT"             = [string]$Receipt.deployment_agent
        "${EnvironmentPrefix}_MODEL"             = [string]$Receipt.model
        "${EnvironmentPrefix}_REASONING_EFFORT"  = [string]$Receipt.model_reasoning_effort
        "${EnvironmentPrefix}_PROFILE_SHA256"    = [string]$Receipt.profile_sha256
    }
    foreach ($item in $environment.GetEnumerator()) {
        $info.Environment[$item.Key] = $item.Value
    }
    $info.Environment['CODEX_HOME'] = [string]$Receipt.codex_home_path
    return $info
}

function Start-CodexChildProcessCore {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)] $Entry,
        [Parameter(Mandatory)] $Receipt,
        [Parameter(Mandatory)][string] $ArtifactRoot,
        [Parameter(Mandatory)][System.Diagnostics.ProcessStartInfo] $StartInfo,
        [Parameter(Mandatory)][string] $SurfaceLabel,
        [Parameter(Mandatory)][string] $ErrorPrefix,
        [Parameter(Mandatory)][scriptblock] $SetReceiptState,
        [Parameter()][scriptblock] $ProcessFactory = {
            [System.Diagnostics.Process]::new()
        }
    )
    $base = Join-Path $ArtifactRoot ([string]$Entry.launch_id)
    if (-not $PSCmdlet.ShouldProcess(
            [string]$Entry.worktree_path,
            "Start Codex $SurfaceLabel child $($Entry.launch_id)"
        )) {
        return $null
    }
    $process = & $ProcessFactory
    $process.StartInfo = $StartInfo
    $started = $false
    try {
        if (-not $process.Start()) {
            throw "failed to start $($Entry.launch_id)."
        }
        $started = $true
        $errorTask = $process.StandardError.ReadToEndAsync()
        $process.StandardInput.Write([string]$Entry.prompt)
        $process.StandardInput.Close()
        $prefixLines = [System.Collections.Generic.List[string]]::new()
        $sessionId = ''
        $deadline = [datetimeoffset]::UtcNow.AddSeconds(30)
        while ([string]::IsNullOrWhiteSpace($sessionId) -and $prefixLines.Count -lt 16) {
            $remaining = [Math]::Max(
                1,
                [int]($deadline - [datetimeoffset]::UtcNow).TotalMilliseconds
            )
            $readTask = $process.StandardOutput.ReadLineAsync()
            if (-not $readTask.Wait($remaining)) {
                throw 'session id timeout.'
            }
            if ($null -eq $readTask.Result) {
                break
            }
            $prefixLines.Add($readTask.Result)
            $sessionId = Get-CodexChildSessionIdCore -JsonLines @($readTask.Result) `
                -ErrorPrefix $ErrorPrefix
        }
        if ([string]::IsNullOrWhiteSpace($sessionId)) {
            throw 'no usable Codex session id was emitted.'
        }
        & $SetReceiptState $Receipt active $sessionId $null ''
        return [pscustomobject]@{
            Entry = $Entry; Process = $process; ErrorTask = $errorTask; SessionId = $sessionId
            OutputTask = $process.StandardOutput.ReadToEndAsync(); ExitTask = $process.WaitForExitAsync()
            OutputPrefix = [string]::Join([Environment]::NewLine, $prefixLines) + [Environment]::NewLine
            BasePath = $base; StartedAt = [datetimeoffset]::UtcNow.ToString('o'); Receipt = $Receipt
        }
    } catch {
        if ($started -and -not $process.HasExited) {
            $process.Kill($true)
        }
        & $SetReceiptState $Receipt failed '' $null ([string]$_)
        throw "$ErrorPrefix $($Entry.launch_id) failed during startup: $_"
    }
}

function Complete-CodexChildProcessCore {
    [CmdletBinding()]
    param([Parameter(Mandatory)] $Child)
    $Child.Process.WaitForExit()
    return [pscustomobject]@{
        exit_code = [int]$Child.Process.ExitCode
        output    = [string]$Child.OutputPrefix + [string]$Child.OutputTask.Result
        error     = [string]$Child.ErrorTask.Result
    }
}

function Get-CodexChildAvailableLaunchCount {
    [OutputType([int])]
    param(
        [Parameter(Mandatory)][ValidateRange(1, 8)][int] $Maximum,
        [Parameter(Mandatory)][ValidateRange(0, 8)][int] $RunningCount,
        [Parameter(Mandatory)][ValidateRange(0, [int]::MaxValue)][int] $QueuedCount
    )
    return [Math]::Min([Math]::Max(0, $Maximum - $RunningCount), $QueuedCount)
}
