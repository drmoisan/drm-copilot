function Test-IsVSCodeInsidersSession {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [scriptblock] $GetEnvironmentVariable = { param([string]$Name) [Environment]::GetEnvironmentVariable($Name) }
    )

    $termProgramVersion = & $GetEnvironmentVariable 'TERM_PROGRAM_VERSION'
    $askPassMain = & $GetEnvironmentVariable 'VSCODE_GIT_ASKPASS_MAIN'
    $termProgram = & $GetEnvironmentVariable 'TERM_PROGRAM'

    if ($termProgramVersion -and ($termProgramVersion -imatch 'insider')) {
        return $true
    }

    if ($askPassMain -and ($askPassMain -imatch 'insider')) {
        return $true
    }

    if ($termProgram -and ($termProgram -imatch 'insider')) {
        return $true
    }

    return $false
}

function Resolve-VSCodeCliCommand {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowEmptyString()]
        [string] $PreferredCommand,
        [switch] $PreferInsiders,
        [scriptblock] $GetCommand = { param([string]$Name) Get-Command $Name -ErrorAction SilentlyContinue },
        [scriptblock] $GetEnvironmentVariable = { param([string]$Name) [Environment]::GetEnvironmentVariable($Name) }
    )

    if (-not [string]::IsNullOrWhiteSpace($PreferredCommand)) {
        $preferredCommandResult = & $GetCommand $PreferredCommand
        if ($preferredCommandResult) {
            return $PreferredCommand
        }

        throw "VS Code CLI command '$PreferredCommand' was explicitly requested but was not found on PATH."
    }

    $preferInsidersCommand = $PreferInsiders.IsPresent -or (Test-IsVSCodeInsidersSession -GetEnvironmentVariable $GetEnvironmentVariable)
    $candidateCommands = if ($preferInsidersCommand) {
        @('code-insiders', 'code')
    }
    else {
        @('code', 'code-insiders')
    }

    foreach ($candidate in $candidateCommands) {
        $resolvedCommand = & $GetCommand $candidate
        if ($resolvedCommand) {
            return $candidate
        }
    }

    return $null
}
