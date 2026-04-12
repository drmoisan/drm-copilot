Timestamp: 2026-03-13T21-30

File: scripts/dev-tools/new-potential-entry.ps1
CopyItemTargetCount: 1
DirectoryGuardCount: 0
StartProcessCount: 1
ReuseWindowCount: 0
Invoke-VSCodeOpen Signature:
function Invoke-VSCodeOpen {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Files,
        [scriptblock] $GetCommand = { param([string]$Name) Get-Command $Name -ErrorAction SilentlyContinue },
        [scriptblock] $StartProcess = { param([string]$FilePath, $ArgumentList) Start-Process $FilePath -ArgumentList $ArgumentList }
    )

File: extensions/drm-copilot/resources/templates/new-potential-entry.ps1
CopyItemTargetCount: 1
DirectoryGuardCount: 0
StartProcessCount: 1
ReuseWindowCount: 0
Invoke-VSCodeOpen Signature:
function Invoke-VSCodeOpen {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Files,
        [scriptblock] $GetCommand = { param([string]$Name) Get-Command $Name -ErrorAction SilentlyContinue },
        [scriptblock] $StartProcess = { param([string]$FilePath, $ArgumentList) Start-Process $FilePath -ArgumentList $ArgumentList }
    )
