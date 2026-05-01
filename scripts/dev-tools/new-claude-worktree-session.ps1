<#
.SYNOPSIS
    Creates a git worktree and launches a Claude CLI session inside it as a background process.

.DESCRIPTION
    Creates a new git worktree at a timestamped path derived from the destination
    repository's basename, branches it off the current HEAD, and starts the Claude CLI
    non-blocking via Start-Process.
    Writes WorktreePath, ProcessId, and LogFile to stdout before returning to the caller.

.PARAMETER Objective
    Prompt text passed to the Claude CLI as its primary argument.

.PARAMETER WorktreeParentPath
    Parent directory for the new worktree. Defaults to the parent of the repo root.

.PARAMETER BranchName
    Explicit branch name for the new worktree. When omitted, defaults to
    <repoName>-wt-<timestamp>.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $Objective,

    [string] $WorktreeParentPath,

    [string] $BranchName
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

function Get-WorktreeTimestamp {
    [CmdletBinding()]
    param(
        [scriptblock] $GetDateTime = { [datetime]::Now }
    )

    $now = & $GetDateTime
    return $now.ToString('yyyy-MM-dd-HH-mm')
}

function Build-WorktreePath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $WorktreeParentPath,

        [Parameter(Mandatory = $true)]
        [string] $Timestamp,

        [Parameter(Mandatory = $true)]
        [string] $RepoName
    )

    return "$WorktreeParentPath/$RepoName-wt-$Timestamp"
}

function Build-BranchName {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Timestamp,

        [Parameter(Mandatory = $true)]
        [string] $RepoName,

        [string] $BranchName
    )

    if ($BranchName) {
        return $BranchName
    }

    return "$RepoName-wt-$Timestamp"
}

function Test-PreconditionsMet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $WorktreePath,

        [scriptblock] $GetCommand = { param([string] $Name) Get-Command $Name -ErrorAction SilentlyContinue },

        [scriptblock] $TestPath = { param([string] $Path) Test-Path $Path }
    )

    $gitCmd = & $GetCommand 'git'
    if (-not $gitCmd) {
        throw "git is not available on PATH. Install git and ensure it is in your PATH before retrying."
    }

    $claudeCmd = & $GetCommand 'claude'
    if (-not $claudeCmd) {
        throw "claude is not available on PATH. Install the Claude CLI and ensure it is in your PATH before retrying."
    }

    $pathExists = & $TestPath $WorktreePath
    if ($pathExists) {
        throw "Target worktree path already exists: $WorktreePath. Remove the existing directory before retrying."
    }
}

function Invoke-GitWorktreeAdd {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $WorktreePath,

        [Parameter(Mandatory = $true)]
        [string] $BranchName,

        [scriptblock] $InvokeGit = { param([string[]] $GitArgs) & git @GitArgs }
    )

    & $InvokeGit @('worktree', 'add', $WorktreePath, '-b', $BranchName)
}

function Start-ClaudeBackground {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $WorktreePath,

        [string] $Objective,

        [scriptblock] $InvokeStartProcess = {
            param([hashtable] $StartArgs)
            Start-Process @StartArgs -PassThru
        }
    )

    $stdoutLog = "$WorktreePath/claude-session.stdout.log"
    $stderrLog = "$WorktreePath/claude-session.stderr.log"

    $claudeArgs = @('--dangerously-skip-permissions')
    if ($Objective) {
        $claudeArgs += $Objective
    }

    # On Windows, the claude CLI is installed by npm as a .cmd shim. Setting
    # RedirectStandardOutput/Error forces UseShellExecute = $false, under which
    # .NET calls Win32 CreateProcess directly. CreateProcess cannot launch
    # non-PE files (.cmd/.bat/.ps1) and returns ERROR_BAD_EXE_FORMAT (193).
    # Route through cmd.exe (a real Win32 binary) so it resolves the .cmd shim.
    $isWindowsHost = $IsWindows -or ($env:OS -eq 'Windows_NT')
    if ($isWindowsHost) {
        $comSpec = $env:ComSpec
        if (-not $comSpec) {
            $comSpec = 'cmd.exe'
        }
        $filePath = $comSpec
        $argumentList = @('/d', '/s', '/c', 'claude') + $claudeArgs
    } else {
        $filePath = 'claude'
        $argumentList = $claudeArgs
    }

    $startArgs = @{
        FilePath               = $filePath
        ArgumentList           = $argumentList
        WorkingDirectory       = $WorktreePath
        RedirectStandardOutput = $stdoutLog
        RedirectStandardError  = $stderrLog
    }

    return & $InvokeStartProcess $startArgs
}

function Write-LaunchResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $WorktreePath,

        [Parameter(Mandatory = $true)]
        [string] $ProcessId,

        [Parameter(Mandatory = $true)]
        [string] $StdoutLog,

        [Parameter(Mandatory = $true)]
        [string] $StderrLog
    )

    Write-Output "WorktreePath: $WorktreePath"
    Write-Output "ProcessId: $ProcessId"
    Write-Output "StdoutLog: $StdoutLog"
    Write-Output "StderrLog: $StderrLog"
}

# ---------------------------------------------------------------------------
# Script body
# ---------------------------------------------------------------------------

# Resolve default WorktreeParentPath when not supplied
$repoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if (-not $WorktreeParentPath) {
    $WorktreeParentPath = Split-Path -Parent $repoRoot
}
$repoName = Split-Path -Leaf $repoRoot

$timestamp = Get-WorktreeTimestamp
$worktreePath = Build-WorktreePath -WorktreeParentPath $WorktreeParentPath -Timestamp $timestamp -RepoName $repoName
$resolvedBranch = Build-BranchName -Timestamp $timestamp -RepoName $repoName -BranchName $BranchName

try {
    Test-PreconditionsMet -WorktreePath $worktreePath
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}

if ($PSCmdlet.ShouldProcess($worktreePath, 'git worktree add')) {
    Invoke-GitWorktreeAdd -WorktreePath $worktreePath -BranchName $resolvedBranch
}

$process = $null
if ($PSCmdlet.ShouldProcess($worktreePath, 'Start-Process claude')) {
    $process = Start-ClaudeBackground -WorktreePath $worktreePath -Objective $Objective
}

$processId = if ($process) { $process.Id.ToString() } else { '0' }
$stdoutLog = "$worktreePath/claude-session.stdout.log"
$stderrLog = "$worktreePath/claude-session.stderr.log"

Write-LaunchResult -WorktreePath $worktreePath -ProcessId $processId -StdoutLog $stdoutLog -StderrLog $stderrLog

