# Provides surface-neutral authoritative reconciliation for resumable Codex child launches.

function Get-CodexChildResumePropertyCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Record,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RecordName
    )

    if ($null -eq $Record) {
        throw "$RecordName is missing."
    }

    $property = $Record.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) {
        throw "$RecordName is missing required property '$Name'."
    }

    return $property.Value
}

function Assert-CodexChildResumeTextCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Record,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RecordName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Expected
    )

    $actual = Get-CodexChildResumePropertyCore -Record $Record -Name $Name -RecordName $RecordName
    if ($actual -isnot [string] -or [string]::IsNullOrWhiteSpace($actual)) {
        throw "$RecordName property '$Name' must be a non-empty string."
    }
    if ($actual -cne $Expected) {
        throw "$RecordName property '$Name' does not match the launch identity."
    }
}

function Assert-CodexChildResumeIntegerCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Record,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RecordName,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Expected
    )

    $actual = Get-CodexChildResumePropertyCore -Record $Record -Name $Name -RecordName $RecordName
    if ($actual -isnot [int] -and $actual -isnot [long]) {
        throw "$RecordName property '$Name' must be an integer."
    }
    if ([long]$actual -ne $Expected) {
        throw "$RecordName property '$Name' does not match the live process."
    }
}

function Assert-CodexChildResumeLaunchIdentityCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Expected,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Receipt
    )

    $fields = [ordered]@{
        spec_sha256                = 'launch specification hash'
        checkpoint_sha256          = 'checkpoint hash'
        trusted_repository_root    = 'repository'
        branch_name                = 'branch'
        worktree_path              = 'worktree'
        deployment_agent           = 'agent'
        model                      = 'model'
        model_reasoning_effort     = 'reasoning'
        authority_receipt_path     = 'authority receipt path'
        delegation_receipt_path    = 'delegation receipt path'
        topology_receipt_path      = 'topology receipt path'
        model_routing_receipt_path = 'model-routing receipt path'
        permissions                = 'permission'
        child_status_path          = 'child-status path'
    }

    foreach ($field in $fields.Keys) {
        $expectedValue = Get-CodexChildResumePropertyCore `
            -Record $Expected `
            -Name $field `
            -RecordName 'expected launch identity'
        if ($expectedValue -isnot [string] -or [string]::IsNullOrWhiteSpace($expectedValue)) {
            throw "Expected $($fields[$field]) must be a non-empty string."
        }
        Assert-CodexChildResumeTextCore `
            -Record $Receipt `
            -Name $field `
            -RecordName 'launch receipt' `
            -Expected $expectedValue
    }
}

function Assert-CodexChildResumeProcessCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Receipt,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$LiveProcess
    )

    $receiptProcessId = Get-CodexChildResumePropertyCore `
        -Record $Receipt `
        -Name 'process_id' `
        -RecordName 'launch receipt'
    if ($receiptProcessId -isnot [int] -and $receiptProcessId -isnot [long]) {
        throw "Launch receipt property 'process_id' must be an integer."
    }
    if ([long]$receiptProcessId -lt 1) {
        throw "Launch receipt property 'process_id' must be positive."
    }

    Assert-CodexChildResumeIntegerCore `
        -Record $LiveProcess `
        -Name 'process_id' `
        -RecordName 'live process' `
        -Expected ([int]$receiptProcessId)

    $receiptStartedAt = Get-CodexChildResumePropertyCore `
        -Record $Receipt `
        -Name 'process_started_at_utc' `
        -RecordName 'launch receipt'
    if ($receiptStartedAt -isnot [string] -or [string]::IsNullOrWhiteSpace($receiptStartedAt)) {
        throw "Launch receipt property 'process_started_at_utc' must be a non-empty string."
    }
    $parsedStartedAt = [datetimeoffset]::MinValue
    if (-not [datetimeoffset]::TryParse(
            $receiptStartedAt,
            [Globalization.CultureInfo]::InvariantCulture,
            [Globalization.DateTimeStyles]::RoundtripKind,
            [ref]$parsedStartedAt
        )) {
        throw "Launch receipt property 'process_started_at_utc' must be an ISO-8601 timestamp."
    }

    Assert-CodexChildResumeTextCore `
        -Record $LiveProcess `
        -Name 'process_started_at_utc' `
        -RecordName 'live process' `
        -Expected $parsedStartedAt.ToUniversalTime().ToString('o')
}

function Assert-CodexChildResumeStatusCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Expected,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Receipt,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$ChildStatus
    )

    foreach ($field in @('launch_hash', 'repository', 'head_branch', 'worktree_path', 'agent')) {
        $expectedValue = Get-CodexChildResumePropertyCore `
            -Record $Expected `
            -Name $field `
            -RecordName 'expected launch identity'
        Assert-CodexChildResumeTextCore `
            -Record $ChildStatus `
            -Name $field `
            -RecordName 'child status' `
            -Expected $expectedValue
    }

    $receiptProcessId = Get-CodexChildResumePropertyCore `
        -Record $Receipt `
        -Name 'process_id' `
        -RecordName 'launch receipt'
    Assert-CodexChildResumeIntegerCore `
        -Record $ChildStatus `
        -Name 'process_id' `
        -RecordName 'child status' `
        -Expected ([int]$receiptProcessId)

    $state = Get-CodexChildResumePropertyCore `
        -Record $ChildStatus `
        -Name 'state' `
        -RecordName 'child status'
    if ($state -isnot [string] -or $state -notin @('running', 'completed', 'failed')) {
        throw "Child status property 'state' must be running, completed, or failed."
    }
}

function Get-CodexChildResumeSpecErrorListCore {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Receipt,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Spec
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $entry = @($Spec.launches | Where-Object {
            [string]$_.launch_id -ceq [string]$Receipt.launch_id
        })
    if ($entry.Count -ne 1) {
        return [string[]]@('sealed launch specification must contain the receipt launch_id exactly once.')
    }

    $entry = $entry[0]
    foreach ($name in @(
            'delegation_id', 'feature_folder', 'deployment_agent', 'model',
            'model_reasoning_effort', 'permissions', 'execution_context',
            'worktree_path', 'branch_name'
        )) {
        if ([string]$entry.$name -cne [string]$Receipt.$name) {
            $errors.Add("sealed launch specification $name differs from the receipt.")
        }
    }
    if (-not (Test-CodexChildIssueEqual -Left $entry.issue_num -Right $Receipt.issue_num)) {
        $errors.Add('sealed launch specification issue_num differs from the receipt.')
    }
    if ((Get-CodexChildSha256 -Value ([string]$entry.prompt)) -cne [string]$Receipt.prompt_sha256) {
        $errors.Add('sealed launch specification prompt hash differs from the receipt.')
    }
    return $errors.ToArray()
}

function Get-CodexChildResumeStatusEntryCore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Status,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LaunchId
    )

    if ([int]$Status.schema_version -ne 2) {
        throw 'child status must use schema_version 2.'
    }
    $launches = Get-CodexChildResumePropertyCore `
        -Record $Status `
        -Name 'launches' `
        -RecordName 'child status'
    $property = $launches.PSObject.Properties[$LaunchId]
    if ($null -eq $property -or $null -eq $property.Value) {
        throw 'child status lacks the launch receipt launch_id.'
    }
    return $property.Value
}

function Get-CodexChildResumeLiveStatusCore {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Receipt,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$ChildStatus,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ReceiptPath,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [scriptblock]$GetLiveProcess
    )

    $state = Get-CodexChildResumePropertyCore `
        -Record $ChildStatus `
        -Name 'state' `
        -RecordName 'child status entry'
    if ($state -isnot [string] -or $state -cnotin @('running', 'completed', 'failed')) {
        throw "child status entry state must be running, completed, or failed."
    }

    Assert-CodexChildResumeTextCore `
        -Record $ChildStatus `
        -Name 'receipt_path' `
        -RecordName 'child status entry' `
        -Expected $ReceiptPath
    Assert-CodexChildResumeTextCore `
        -Record $ChildStatus `
        -Name 'codex_session_id' `
        -RecordName 'child status entry' `
        -Expected ([string]$Receipt.codex_session_id)

    $pidValue = Get-CodexChildResumePropertyCore `
        -Record $ChildStatus `
        -Name 'pid' `
        -RecordName 'child status entry'
    if (($pidValue -isnot [int] -and $pidValue -isnot [long]) -or [long]$pidValue -lt 1) {
        throw "child status entry pid must be a positive integer."
    }

    $liveProcess = & $GetLiveProcess ([int]$pidValue)
    if ($null -eq $liveProcess) {
        return [pscustomobject][ordered]@{
            should_relaunch      = $true
            authoritative_source = 'live-process-absent'
            cached_status_state  = [string]$state
            process_id           = [int]$pidValue
        }
    }

    $liveId = Get-CodexChildResumePropertyCore `
        -Record $liveProcess `
        -Name 'Id' `
        -RecordName 'live process'
    if (($liveId -isnot [int] -and $liveId -isnot [long]) -or [long]$liveId -ne [long]$pidValue) {
        throw 'live process identity differs from the child status pid.'
    }
    $hasExited = Get-CodexChildResumePropertyCore `
        -Record $liveProcess `
        -Name 'HasExited' `
        -RecordName 'live process'
    if ($hasExited -isnot [bool]) {
        throw 'live process HasExited must be a Boolean.'
    }
    if (-not $hasExited) {
        throw 'live child process is still running; relaunch is prohibited.'
    }

    return [pscustomobject][ordered]@{
        should_relaunch      = $true
        authoritative_source = 'live-process-exited'
        cached_status_state  = [string]$state
        process_id           = [int]$pidValue
    }
}

function Get-CodexChildResumeReconciliationCore {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()]
        [ValidateNotNull()]
        [object]$Expected,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Receipt,

        [AllowNull()]
        [ValidateNotNull()]
        [object]$LiveProcess,

        [AllowNull()]
        [ValidateNotNull()]
        [object]$ChildStatus,

        [AllowNull()]
        [object]$Spec,

        [AllowNull()]
        [object]$Status,

        [AllowEmptyString()]
        [string]$ReceiptPath = '',

        [AllowNull()]
        [scriptblock]$GetLiveProcess
    )

    if ($null -ne $Spec) {
        $errors = [System.Collections.Generic.List[string]]::new()
        foreach ($errorMessage in @(Get-CodexChildResumeSpecErrorListCore -Receipt $Receipt -Spec $Spec)) {
            $errors.Add($errorMessage)
        }
        if ($null -eq $Status) {
            $errors.Add('child status data is missing or corrupt.')
        } elseif ([string]::IsNullOrWhiteSpace($ReceiptPath) -or $null -eq $GetLiveProcess) {
            $errors.Add('child status reconciliation requires receipt path and live process query evidence.')
        } else {
            try {
                $childStatus = Get-CodexChildResumeStatusEntryCore `
                    -Status $Status `
                    -LaunchId ([string]$Receipt.launch_id)
                $null = Get-CodexChildResumeLiveStatusCore `
                    -Receipt $Receipt `
                    -ChildStatus $childStatus `
                    -ReceiptPath $ReceiptPath `
                    -GetLiveProcess $GetLiveProcess
            } catch {
                $errors.Add([string]$_.Exception.Message)
            }
        }
        return $errors.ToArray()
    }
    if ($null -eq $Expected -or $null -eq $LiveProcess -or $null -eq $ChildStatus) {
        throw 'resume reconciliation requires expected identity, live process, and child status evidence.'
    }

    Assert-CodexChildResumeLaunchIdentityCore -Expected $Expected -Receipt $Receipt
    Assert-CodexChildResumeProcessCore -Receipt $Receipt -LiveProcess $LiveProcess
    Assert-CodexChildResumeStatusCore `
        -Expected $Expected `
        -Receipt $Receipt `
        -ChildStatus $ChildStatus

    $state = [string]$ChildStatus.state
    return [pscustomobject][ordered]@{
        state                  = $state
        process_id             = [int]$LiveProcess.process_id
        process_started_at_utc = [string]$LiveProcess.process_started_at_utc
        should_relaunch        = $false
        authoritative_source   = 'live-process-and-child-status'
    }
}
