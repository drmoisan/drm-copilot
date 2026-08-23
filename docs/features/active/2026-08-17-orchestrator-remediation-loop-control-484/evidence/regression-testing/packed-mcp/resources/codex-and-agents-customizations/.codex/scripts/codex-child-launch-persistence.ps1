# Surface-neutral atomic persistence and terminal-status mechanics for Codex child launches.

function Write-CodexChildJsonCreateNewCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)] $Value,
        [scriptblock] $EnsureDirectory = {
            param([string] $DirectoryPath)
            [System.IO.Directory]::CreateDirectory($DirectoryPath) | Out-Null
        },
        [scriptblock] $OpenFile = {
            param([string] $FilePath)
            [System.IO.File]::Open(
                $FilePath,
                [System.IO.FileMode]::CreateNew,
                [System.IO.FileAccess]::Write,
                [System.IO.FileShare]::None
            )
        }
    )
    & $EnsureDirectory (Split-Path $Path -Parent)
    $stream = & $OpenFile $Path
    try {
        $writer = [System.IO.StreamWriter]::new(
            $stream,
            [System.Text.UTF8Encoding]::new($false)
        )
        try {
            $writer.Write(($Value | ConvertTo-Json -Depth 32))
            $writer.Flush()
            if ($stream -is [System.IO.FileStream]) {
                $stream.Flush($true)
            } else {
                $stream.Flush()
            }
        } finally {
            $writer.Dispose()
        }
    } finally {
        $stream.Dispose()
    }
}

function Write-CodexChildJsonAtomicCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)] $Value,
        [scriptblock] $CreateNew = {
            param([string] $FilePath, $FileValue)
            Write-CodexChildJsonCreateNewCore -Path $FilePath -Value $FileValue
        },
        [scriptblock] $MoveFile = {
            param([string] $Source, [string] $Destination)
            [System.IO.File]::Move($Source, $Destination, $true)
        },
        [scriptblock] $DeleteFile = {
            param([string] $FilePath)
            [System.IO.File]::Delete($FilePath)
        },
        [scriptblock] $PathExists = {
            param([string] $FilePath)
            Test-Path -LiteralPath $FilePath -PathType Leaf
        }
    )
    [System.IO.Directory]::CreateDirectory((Split-Path $Path -Parent)) | Out-Null
    $temporaryPath = "$Path.tmp.$([guid]::NewGuid().ToString('N'))"
    try {
        & $CreateNew $temporaryPath $Value
        & $MoveFile $temporaryPath $Path
    } finally {
        if (& $PathExists $temporaryPath) {
            & $DeleteFile $temporaryPath
        }
    }
}

function Enter-CodexChildScheduleLockCore {
    [OutputType([System.IO.Stream])]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $ScheduleKind,
        [Parameter(Mandatory)][string] $ErrorPrefix,
        [scriptblock] $OpenLock = {
            param([string] $LockPath)
            [System.IO.File]::Open(
                $LockPath,
                [System.IO.FileMode]::OpenOrCreate,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::None
            )
        }
    )
    try {
        $stream = & $OpenLock $Path
    } catch {
        throw "$ErrorPrefix semantic $ScheduleKind lock is already held: $Path"
    }
    $writer = $null
    try {
        $stream.SetLength(0)
        $writer = [System.IO.StreamWriter]::new(
            $stream,
            [System.Text.UTF8Encoding]::new($false),
            1024,
            $true
        )
        $writer.Write("pid=$PID`nacquired_at=$([datetimeoffset]::UtcNow.ToString('o'))")
        $writer.Flush()
        if ($stream -is [System.IO.FileStream]) {
            $stream.Flush($true)
        } else {
            $stream.Flush()
        }
        $writer.Dispose()
        $writer = $null
        return $stream
    } catch {
        if ($null -ne $writer) {
            $writer.Dispose()
        }
        $stream.Dispose()
        throw "$ErrorPrefix semantic $ScheduleKind lock initialization failed: $Path $_"
    }
}

function Assert-CodexChildAuthorityOutsideRepositoryCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $AuthorityPath,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][string] $ErrorPrefix,
        [scriptblock] $ResolveExistingAncestor = {
            param([string] $Candidate)
            $current = [System.IO.Path]::GetFullPath($Candidate)
            while (-not (Test-Path -LiteralPath $current -PathType Container)) {
                $parent = Split-Path $current -Parent
                if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $current) {
                    throw 'no existing authority ancestor.'
                }
                $current = $parent
            }
            $item = Get-Item -LiteralPath $current -Force
            if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                return $item.ResolveLinkTarget($true).FullName
            }
            return $item.FullName
        },
        [Parameter(Mandatory)][scriptblock] $IsInsideGit
    )
    $comparison = if ($IsWindows) {
        [System.StringComparison]::OrdinalIgnoreCase
    } else {
        [System.StringComparison]::Ordinal
    }
    $authority = [System.IO.Path]::GetFullPath($AuthorityPath)
    $repository = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if ($authority.Equals($repository, $comparison) -or
        $authority.StartsWith(
            $repository + [System.IO.Path]::DirectorySeparatorChar,
            $comparison
        )) {
        throw "$ErrorPrefix isolated CODEX_HOME authority is inside RepositoryRoot."
    }
    $ancestor = & $ResolveExistingAncestor $authority
    if (& $IsInsideGit $ancestor) {
        throw "$ErrorPrefix isolated CODEX_HOME authority resolves inside a Git repository."
    }
}

function Set-CodexChildReceiptStateCore {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)] $Receipt,
        [Parameter(Mandatory)][ValidateSet('launching', 'active', 'completed', 'failed')][string] $State,
        [AllowEmptyString()][string] $SessionId = '',
        [Nullable[int]] $ExitCode = $null,
        [AllowEmptyString()][string] $FailureReason = '',
        [Parameter(Mandatory)][string] $ErrorPrefix,
        [Parameter(Mandatory)][scriptblock] $WriteReceipt,
        [datetimeoffset] $Now = [datetimeoffset]::UtcNow
    )
    if (-not $PSCmdlet.ShouldProcess(
            [string]$Receipt.receipt_path,
            "Set child receipt state to '$State'"
        )) {
        return
    }
    $timestamp = $Now.ToString('o')
    $Receipt.state = $State
    if ($State -eq 'launching') {
        $Receipt.resume_started_at = $timestamp
        $Receipt.expires_at = $Now.AddDays(7).ToString('o')
    } elseif ($State -eq 'active') {
        if ([string]::IsNullOrWhiteSpace($SessionId)) {
            throw "$ErrorPrefix active receipt requires a session id."
        }
        $Receipt.codex_session_id = $SessionId
        $Receipt.session_bound_at = $timestamp
    } elseif ($State -eq 'completed') {
        $Receipt.exit_code = 0
        $Receipt.completed_at = $timestamp
    } else {
        $Receipt.exit_code = if ($null -eq $ExitCode) { -1 } else { [int]$ExitCode }
        $Receipt.failure_reason = $FailureReason
        $Receipt.failed_at = $timestamp
    }
    & $WriteReceipt ([string]$Receipt.receipt_path) $Receipt
}

function Get-CodexChildTerminalStatusEntryCore {
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)] $Child,
        [Parameter(Mandatory)][string] $ReceiptPath,
        [Parameter(Mandatory)][string] $ResumeScriptPath
    )
    $quotedWrapper = "'" + $ResumeScriptPath.Replace("'", "''") + "'"
    $quotedReceipt = "'" + $ReceiptPath.Replace("'", "''") + "'"
    $status = [ordered]@{
        state              = if ($Child.Process.ExitCode -eq 0) { 'completed' } else { 'failed' }
        pid = $Child.Process.Id; exit_code = $Child.Process.ExitCode
        codex_session_id = $Child.SessionId; receipt_path = $ReceiptPath
        resume_script_path = $ResumeScriptPath
        resume_command     = "& $quotedWrapper -ReceiptPath $quotedReceipt"
        stdout_path        = "$($Child.BasePath).stdout.jsonl"
        stderr_path        = "$($Child.BasePath).stderr.log"
    }
    if ($Child.Process.ExitCode -eq 0) {
        $status.completed_at = [string]$Child.Receipt.completed_at
    } else {
        $status.failed_at = [string]$Child.Receipt.failed_at
    }
    return $status
}

function Write-CodexChildScheduleStatusCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter(Mandatory)][string] $ScheduleKind,
        [Parameter(Mandatory)][string] $ScheduleId,
        [Parameter(Mandatory)][string] $State,
        [Parameter(Mandatory)] $Statuses,
        [AllowEmptyString()][string] $Failure = '',
        [Parameter(Mandatory)][scriptblock] $WriteStatus
    )
    $value = [ordered]@{
        schema_version = 2; supervisor_pid = $PID
        state = $State; failure = $Failure; launches = $Statuses
        updated_at = [datetimeoffset]::UtcNow.ToString('o')
    }
    $value["${ScheduleKind}_id"] = $ScheduleId
    & $WriteStatus $Path $value
}
