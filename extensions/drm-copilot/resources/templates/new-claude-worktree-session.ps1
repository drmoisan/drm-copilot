<#
.SYNOPSIS
    Creates a git worktree and launches a Claude CLI session inside it as a background process.

.DESCRIPTION
    Creates a new git worktree under a per-repository grouping directory and branches it
    off the current HEAD, then starts the Claude CLI non-blocking via Start-Process.
    The worktree is created at the nested path
    <WorktreeParentPath>/<repoName>-wt/<yyyy-MM-ddTHH-mm>, where <repoName>-wt is a single
    grouping directory that holds every timestamped worktree for the repository. The
    grouping directory is created (idempotently) before 'git worktree add' runs.
    Writes WorktreePath, ProcessId, and LogFile to stdout before returning to the caller.

.PARAMETER Objective
    Prompt text passed to the Claude CLI as its primary argument.

.PARAMETER WorktreeParentPath
    Parent directory for the new worktree. Defaults to the parent of the repo root. The
    grouping directory <repoName>-wt is created beneath this path.

.PARAMETER BranchName
    Explicit branch name for the new worktree. When omitted, defaults to the flat name
    <repoName>-wt-<yyyy-MM-ddTHH-mm>. The branch name is never nested with a slash even
    though the on-disk worktree path is nested.
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
    return $now.ToString('yyyy-MM-ddTHH-mm')
}

function Get-WorktreeGroupDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $WorktreeParentPath,

        [Parameter(Mandatory = $true)]
        [string] $RepoName
    )

    return "$WorktreeParentPath/$RepoName-wt"
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

    $groupDirectory = Get-WorktreeGroupDirectory -WorktreeParentPath $WorktreeParentPath -RepoName $RepoName
    return "$groupDirectory/$Timestamp"
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

function New-WorktreeParentDirectory {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $GroupDirectory,

        [scriptblock] $NewDirectory = { param([string] $Path) New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    )

    # -Force makes creation idempotent (a no-op when the directory already exists) and
    # creates any missing leading directories. The filesystem action is isolated behind
    # the injectable $NewDirectory seam so it can be mocked without touching disk.
    if ($PSCmdlet.ShouldProcess($GroupDirectory, 'Create worktree grouping directory')) {
        & $NewDirectory $GroupDirectory
    }
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

# When dot-sourced (for example by the Pester test suite, to resolve the functions
# above for coverage attribution), define the functions but do not execute the
# top-level script body. Direct invocation leaves $MyInvocation.InvocationName as the
# script name (not '.'), so the body runs unchanged and production behavior is preserved.
if ($MyInvocation.InvocationName -eq '.') {
    return
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

# Ensure the <repoName>-wt grouping directory exists before 'git worktree add' runs.
# Creation is idempotent, so re-running for an existing group directory is a no-op.
$groupDirectory = Get-WorktreeGroupDirectory -WorktreeParentPath $WorktreeParentPath -RepoName $repoName
New-WorktreeParentDirectory -GroupDirectory $groupDirectory

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
