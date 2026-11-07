<#
.SYNOPSIS
    Forwards to the canonical epic progress report script,
    .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1.

.DESCRIPTION
    Every argument is passed through unchanged to the canonical script of the
    /epic-progress-report skill, which holds the parameters, the help, and the logic; this
    file declares no parameters, so it cannot drift from the canonical parameter surface.
    Run 'Get-Help' on the canonical script for the parameters. To load the functions for a
    test or a probe, dot-source the canonical file, not this forwarder.

.NOTES
    Exit status (issue #1093): a parameter-validation or other terminating failure of the
    canonical script exits 1; an explicit non-zero exit code of the canonical script is
    propagated; after a successful run the exit code is 0, and a native exit code left over
    from git, gh, or cswap is ignored.
#>

$ErrorActionPreference = 'Stop'
$global:LASTEXITCODE = 0
& (Join-Path -Path $PSScriptRoot -ChildPath '../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1') @args
if ($?) { exit 0 }
exit $(if ($LASTEXITCODE) { $LASTEXITCODE } else { 1 })
