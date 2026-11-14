<#
.SYNOPSIS
    The generate-reference command of the documentation reference generator: page composition
    and the guarded page writes.

.DESCRIPTION
    Get-DocsReferenceGeneration (pure) composes the page plan, the block renderer, the block
    merge and the front matter into one in-memory change per planned page, including its dry-run
    diff from Format-DocsReferenceDiff. The diff, the result object and the report lines live in
    DocsReferenceReport.psm1 (the file-size contingency of the issue #1024 spec).

    Invoke-DocsGenerateReferenceCommand runs the stages of the command: compose the schema set,
    load the profile and the snapshot, resolve the output directory, read the existing pages,
    compute every change and, with -Write, write the changed pages in ordinal path order,
    stopping at the first conflict. Every read and write goes through the command context, whose
    members are invoked only through private helpers with [scriptblock] parameters. The command
    function writes no output and never exits; a read failure other than absence propagates to
    the entry boundary.

.NOTES
    Issue #1024. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsProfile.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferencePlan.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceRender.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceMarkers.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceFrontMatter.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReferenceReport.psm1') -ErrorAction Stop

function Get-DocsReferenceTextLine {
    <#
    .SYNOPSIS
        Splits LF-normalized text into lines without the empty line after a final LF (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $normalized = $(if ($Text.StartsWith([char]0xFEFF)) { $Text.Substring(1) } else { $Text }).Replace("`r`n", "`n")
    if ($normalized.Length -eq 0) { return , [string[]]@() }
    if ($normalized.EndsWith("`n")) { $normalized = $normalized.Substring(0, $normalized.Length - 1) }
    return , [string[]] $normalized.Split("`n")
}

function Get-DocsReferencePageChange {
    <#
    .SYNOPSIS
        Computes the change of one planned page; returns @{ Page; Finding } (private helper).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $PagePlan,
        [AllowNull()] [System.Collections.IDictionary] $Existing,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $AudienceId,
        [Parameter(Mandatory = $true)] [string] $CapturedAt
    )

    $path = [string] $PagePlan['Path']
    $isNew = $null -eq $Existing
    $findings = [System.Collections.Generic.List[object]]::new()
    $findings.AddRange([object[]] @($PagePlan['Finding']))
    [string[]] $before = @()
    [string[]] $body = @('# ' + [string] $PagePlan['Title'])
    $existingValue = $null
    $hasFrontMatter = $false
    $offset = 0
    $frontMatterOk = $true
    if (-not $isNew) {
        $converted = ConvertFrom-DocsReferencePageText -Text ([string] $Existing['Text']) -PagePath $path -ComposedSchemaSet $ComposedSchemaSet -AudienceId $AudienceId
        $findings.AddRange([object[]] @($converted.Finding))
        $frontMatterOk = @($converted.Finding).Count -eq 0
        $existingValue = $converted.Value
        $hasFrontMatter = [bool] $converted.HasFrontMatter
        $offset = [int] $converted.BodyLineOffset
        $before = Get-DocsReferenceTextLine -Text ([string] $Existing['Text'])
        $body = [string[]] @($converted.BodyLine)
        if ($body.Count -gt 0 -and $body[$body.Count - 1].Length -eq 0) { $body = [string[]] @($body | Select-Object -First ($body.Count - 1)) }
    }
    [object[]] $element = @($PagePlan['Element'])
    $desired = @(foreach ($item in $element) { @{ ElementId = [string] $item['element_id']; Line = (Get-DocsReferenceBlockLine -Element $item) } })
    $merge = Merge-DocsReferenceBlock -Line $body -Desired $desired -PagePath $path -LineOffset $offset
    $findings.AddRange([object[]] @($merge.Finding))
    $resolved = $null
    if ($frontMatterOk) {
        [string[]] $surfaceRef = @($desired | ForEach-Object { [string] $_.ElementId })
        $resolved = Resolve-DocsReferenceFrontMatterValue -Existing $existingValue -PagePlan $PagePlan -SurfaceRef $surfaceRef -CapturedAt $CapturedAt -IsNewPage $isNew
        $findings.AddRange([object[]] @($resolved.Finding))
    }
    $sha256Before = if ($isNew) { $null } else { [string] $Existing['Sha256'] }
    if (Test-DocsFindingHasError -Finding $findings.ToArray()) {
        [object[]] $kept = @($findings | Where-Object { [string] $_['code'] -cne 'REFERENCE_BLOCK_REMOVED' })
        $page = [ordered]@{ Path = $path; Action = 'blocked'; Added = [string[]]@(); Updated = [string[]]@(); Unchanged = [string[]]@(); Removed = [string[]]@(); Text = $null; Sha256Before = $sha256Before; Sha256After = $null; Diff = $null }
        return @{ Page = $page; Finding = $kept }
    }
    $frontMatterText = ConvertTo-DocsReferenceFrontMatterText -Value $resolved.Value
    [string[]] $frontMatterLine = $frontMatterText.Substring(0, $frontMatterText.Length - 1).Split("`n")
    [string[]] $merged = @($merge.Line)
    $separator = if (($isNew -or -not $hasFrontMatter) -and $merged.Count -gt 0) { 1 } else { 0 }
    $after = [System.Collections.Generic.List[string]]::new()
    $after.AddRange($frontMatterLine)
    if ($separator -eq 1) { $after.Add('') }
    $after.AddRange($merged)
    $text = ($after.ToArray() -join "`n") + "`n"
    $edits = [System.Collections.Generic.List[object]]::new()
    if ($isNew) {
        $edits.Add([ordered]@{ BeforeStart = 0; BeforeCount = 0; AfterStart = 0; AfterCount = $after.Count })
    } else {
        $beforeHead = if ($hasFrontMatter) { $offset } else { 0 }
        $afterHead = $frontMatterLine.Count + $separator
        $oldHead = @($before | Select-Object -First $beforeHead) -join "`n"
        $newHead = @($after.GetRange(0, $afterHead)) -join "`n"
        if ($beforeHead -ne $afterHead -or $oldHead -cne $newHead) { $edits.Add([ordered]@{ BeforeStart = 0; BeforeCount = $beforeHead; AfterStart = 0; AfterCount = $afterHead }) }
        foreach ($edit in @($merge.Edit)) {
            $edits.Add([ordered]@{ BeforeStart = $edit.BeforeStart + $beforeHead; BeforeCount = $edit.BeforeCount; AfterStart = $edit.AfterStart + $afterHead; AfterCount = $edit.AfterCount })
        }
    }
    $sha256After = Get-DocsSha256Hex -Text $text
    $action = if ($isNew) { 'create' } elseif ($sha256After -ceq $sha256Before) { 'none' } else { 'update' }
    $diff = $null
    if ($action -cne 'none') { $diff = Format-DocsReferenceDiff -PagePath $path -BeforeLine $before -AfterLine $after.ToArray() -Edit $edits.ToArray() -IsNewPage:$isNew }
    $page = [ordered]@{ Path = $path; Action = $action; Added = [string[]] $merge.Added; Updated = [string[]] $merge.Updated; Unchanged = [string[]] $merge.Unchanged; Removed = [string[]] $merge.Removed; Text = $text; Sha256Before = $sha256Before; Sha256After = $sha256After; Diff = $diff }
    return @{ Page = $page; Finding = $findings.ToArray() }
}

function Get-DocsReferenceGeneration {
    <#
    .SYNOPSIS
        Computes every planned page change in memory; returns @{ Page; Unrendered; Finding }.
    .DESCRIPTION
        ExistingPage maps each candidate page path to $null (absent) or @{ Text; Sha256 }, Sha256
        being Get-DocsTextSha256Hex of the page bytes (line endings normalized, issue #1173), so an
        existing CRLF page equal in LF form to the computed text gives action none. Each page record, ordinal by Path, carries Path,
        Action (create, update, none or blocked), the ordinal-sorted Added, Updated, Unchanged and
        Removed identifier lists, the computed Text, Sha256Before, Sha256After and the dry-run Diff
        ($null for none and blocked). A page-scoped error finding blocks only its page. Existing
        front matter is validated with ComposedSchemaSet and the profile audiences[].id values.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Profile,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Snapshot,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Element,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ExistingPage,
        [Parameter(Mandatory = $true)] [string] $OutputDirectory,
        [Parameter(Mandatory = $true)] [AllowNull()] [string] $ProfilePath,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $ComposedSchemaSet
    )

    [string[]] $existingPath = @(foreach ($key in @($ExistingPage.Keys)) { if ($null -ne $ExistingPage[$key]) { [string] $key } })
    $plan = Get-DocsReferencePagePlan -Profile $Profile -Element $Element -OutputDirectory $OutputDirectory -ExistingPagePath $existingPath -ProfilePath $ProfilePath
    [string[]] $audienceId = @(foreach ($audience in @($Profile['audiences'])) { if ($null -ne $audience) { [string] $audience['id'] } })
    $pages = [System.Collections.Generic.List[object]]::new()
    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($pagePlan in @($plan.Page)) {
        $path = [string] $pagePlan['Path']
        $existing = if ($ExistingPage.Contains($path)) { $ExistingPage[$path] } else { $null }
        $change = Get-DocsReferencePageChange -PagePlan $pagePlan -Existing $existing -ComposedSchemaSet $ComposedSchemaSet -AudienceId $audienceId -CapturedAt ([string] $Snapshot['captured_at'])
        $pages.Add($change.Page)
        $findings.AddRange([object[]] @($change.Finding))
    }
    [object[]] $ordered = @()
    if ($findings.Count -gt 0) { $ordered = Get-DocsOrderedFinding -Finding $findings.ToArray() }
    return @{ Page = [object[]] $pages.ToArray(); Unrendered = [int] $plan.Unrendered; Finding = $ordered }
}

function Invoke-DocsReferenceContextMember {
    <#
    .SYNOPSIS
        Invokes one command-context member with positional arguments (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [scriptblock] $Member,
        [AllowEmptyCollection()] [object[]] $ArgumentList = @()
    )

    return & $Member @ArgumentList
}

function Invoke-DocsReferencePageWrite {
    <#
    .SYNOPSIS
        Performs one guarded page write; returns @{ Status; Message } (private helper).
    .DESCRIPTION
        create: TestFile immediately before writing; an existing target is a conflict, otherwise
        WriteText with mode create. update: ReadBytes immediately before writing; a
        Get-DocsTextSha256Hex digest other than Sha256Before is a conflict, otherwise WriteText with mode overwrite. Status is
        created, updated, conflict, or failed when WriteText throws (Message holds the error).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Change,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadBytes,
        [Parameter(Mandatory = $true)] [scriptblock] $TestFile,
        [Parameter(Mandatory = $true)] [scriptblock] $WriteText
    )

    $path = [string] $Change['Path']
    if ([string] $Change['Action'] -ceq 'create') {
        if ([bool] (& $TestFile $path)) { return @{ Status = 'conflict'; Message = "the page $path was created by another writer after planning." } }
        $mode = 'create'
        $status = 'created'
    } else {
        $bytes = [byte[]] (& $ReadBytes $path)
        if ((Get-DocsTextSha256Hex -Bytes $bytes) -cne [string] $Change['Sha256Before']) { return @{ Status = 'conflict'; Message = "the page $path changed after planning." } }
        $mode = 'overwrite'
        $status = 'updated'
    }
    try {
        [void](& $WriteText $path ([string] $Change['Text']) $mode)
    } catch {
        return @{ Status = 'failed'; Message = $_.Exception.Message }
    }
    return @{ Status = $status; Message = $null }
}

function New-DocsReferenceCommandFinding {
    <#
    .SYNOPSIS
        Builds one error finding of the command function with the fixed next action of its code (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Message,
        [AllowNull()] [string] $ArtifactPath,
        [AllowEmptyString()] [string] $Pointer = '',
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedPath
    )

    $nextAction = switch -CaseSensitive ($Code) {
        'DOCS_CLI_ARGUMENTS' { 'Run Invoke-DocsCommand.ps1 -Help for the generate-reference options.' }
        'DOCS_PROFILE_MISSING' { 'Run Invoke-DocsCommand.ps1 -Command init -Write, or pass -Profile with an existing profile.' }
        'REFERENCE_SNAPSHOT_MISSING' { 'Produce the surface inventory snapshot, or pass -Snapshot with an existing snapshot.' }
        'REFERENCE_REPOSITORY_MISMATCH' { 'Regenerate the snapshot for the repository of the docs profile.' }
        'REFERENCE_WRITE_CONFLICT' { 'Review the concurrent change to the page and run the command again.' }
        default { 'Correct the reported write failure and run the command again; pages written earlier are kept.' }
    }
    return New-DocsFinding -Code $Code -Severity 'error' -Message $Message -NextAction $nextAction -ArtifactPath $ArtifactPath -Pointer $Pointer -RelatedPath $RelatedPath
}

function New-DocsReferenceCommandResult {
    <#
    .SYNOPSIS
        Returns the generate-reference command result with its report lines (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [int] $ExitCode,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Finding,
        [AllowNull()] [System.Collections.IDictionary] $Result
    )

    [string[]] $line = @()
    if ($null -ne $Result) { $line = Get-DocsReferenceReportLine -Result $Result }
    return New-DocsCommandResult -Command 'generate-reference' -ExitCode $ExitCode -Finding $Finding -Result $Result -Line $line
}

function Invoke-DocsGenerateReferenceCommand {
    <#
    .SYNOPSIS
        Generates or plans the reference pages; returns a New-DocsCommandResult object.
    .DESCRIPTION
        Options: Profile, Snapshot, OutputDirectory (value) and Write (switch). Exit 2 for an
        option that is not a repository-relative path or an OutputDirectory ending in '/'; exit 3
        with one finding for an uncomposable schema set or a WriteText exception
        (REFERENCE_WRITE_FAILED); exit 1 for DOCS_PROFILE_MISSING, REFERENCE_SNAPSHOT_MISSING, any
        error finding of loading or planning (nothing is written) and a write conflict; else 0.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Argument,
        [Parameter(Mandatory = $true)] [object] $Context
    )

    $profilePath = if ($Argument.Contains('Profile')) { [string] $Argument['Profile'] } else { Get-DocsDefaultProfilePath }
    $snapshotOption = if ($Argument.Contains('Snapshot')) { [string] $Argument['Snapshot'] } else { $null }
    $outputOption = if ($Argument.Contains('OutputDirectory')) { [string] $Argument['OutputDirectory'] } else { $null }
    $mode = if ($Argument.Contains('Write') -and [bool] $Argument['Write']) { 'write' } else { 'dry-run' }
    $usage = $null
    if (-not (Test-DocsRelativePath -Path $profilePath)) { $usage = "Profile '$profilePath' is not a repository-relative path." }
    elseif ($null -ne $snapshotOption -and -not (Test-DocsRelativePath -Path $snapshotOption)) { $usage = "Snapshot '$snapshotOption' is not a repository-relative path." }
    elseif ($null -ne $outputOption -and ($outputOption.EndsWith('/') -or -not (Test-DocsRelativePath -Path $outputOption))) { $usage = "OutputDirectory '$outputOption' is not a repository-relative path without a trailing '/'." }
    if ($null -ne $usage) { return New-DocsReferenceCommandResult -ExitCode 2 -Finding @(New-DocsReferenceCommandFinding -Code 'DOCS_CLI_ARGUMENTS' -Message $usage) }

    $schemaPath = [ordered]@{}
    foreach ($name in (Get-DocsSchemaName)) { $schemaPath[$name] = ".claude/lib/docs/schemas/v1/$name.schema.json" }
    $composed = Get-DocsComposedSchemaSet -SchemaSet (Read-DocsSchemaSet -SchemaPath $schemaPath -ReadText $Context.ReadText)
    if (@($composed.Findings).Count -gt 0) { return New-DocsReferenceCommandResult -ExitCode 3 -Finding @(@($composed.Findings)[0]) }
    $schemas = $composed.Schemas

    if (-not [bool] (Invoke-DocsReferenceContextMember -Member $Context.TestFile -ArgumentList @($profilePath))) {
        return New-DocsReferenceCommandResult -ExitCode 1 -Finding @(New-DocsReferenceCommandFinding -Code 'DOCS_PROFILE_MISSING' -Message "The profile $profilePath does not exist." -ArtifactPath $profilePath)
    }
    $loaded = ConvertFrom-DocsProfileText -Text ([string] (Invoke-DocsReferenceContextMember -Member $Context.ReadText -ArgumentList @($profilePath))) -ArtifactPath $profilePath -ComposedSchemaSet $schemas
    if (-not $loaded.Ok -or $null -eq $loaded.Profile) { return New-DocsReferenceCommandResult -ExitCode 1 -Finding @($loaded.Findings) }
    $docsProfile = $loaded.Profile
    $findings = [System.Collections.Generic.List[object]]::new()
    $findings.AddRange([object[]] @($loaded.Findings))
    $empty = @{ Page = [object[]]@(); Unrendered = 0 }

    $snapshotPath = if ($null -ne $snapshotOption) { $snapshotOption } else { [string] $docsProfile['artifact_paths']['inventory_snapshot'] }
    if (-not [bool] (Invoke-DocsReferenceContextMember -Member $Context.TestFile -ArgumentList @($snapshotPath))) {
        $findings.Add((New-DocsReferenceCommandFinding -Code 'REFERENCE_SNAPSHOT_MISSING' -Message "The snapshot $snapshotPath does not exist." -ArtifactPath $snapshotPath))
        return New-DocsReferenceCommandResult -ExitCode 1 -Finding $findings.ToArray() -Result (ConvertTo-DocsReferenceResult -Generation $empty -Mode $mode)
    }
    $snapshot = ConvertFrom-DocsReferenceSnapshotText -Text ([string] (Invoke-DocsReferenceContextMember -Member $Context.ReadText -ArgumentList @($snapshotPath))) -ArtifactPath $snapshotPath -ComposedSchemaSet $schemas
    $findings.AddRange([object[]] @($snapshot.Finding))
    if ($null -ne $snapshot.Snapshot -and [string] $snapshot.Snapshot['repository'] -cne [string] $docsProfile['repository']['id']) {
        $findings.Add((New-DocsReferenceCommandFinding -Code 'REFERENCE_REPOSITORY_MISMATCH' -Message "The snapshot repository '$($snapshot.Snapshot['repository'])' differs from the profile repository.id '$($docsProfile['repository']['id'])'." -ArtifactPath $snapshotPath -Pointer '/repository'))
    }
    if (Test-DocsFindingHasError -Finding $findings.ToArray()) { return New-DocsReferenceCommandResult -ExitCode 1 -Finding $findings.ToArray() -Result (ConvertTo-DocsReferenceResult -Generation $empty -Mode $mode) }

    [object[]] $element = @($snapshot.Element)
    $unrendered = @{ Page = [object[]]@(); Unrendered = @($element | Where-Object { [string] $_['kind'] -ceq 'architecture-component' }).Count }
    $directory = Resolve-DocsReferenceOutputDirectory -Profile $docsProfile -ProfilePath $profilePath -OutputDirectory $outputOption
    $findings.AddRange([object[]] @($directory.Finding))
    if ($null -eq $directory.OutputDirectory) { return New-DocsReferenceCommandResult -ExitCode 1 -Finding $findings.ToArray() -Result (ConvertTo-DocsReferenceResult -Generation $unrendered -Mode $mode) }

    $existing = [ordered]@{}
    foreach ($path in (Get-DocsReferenceCandidatePagePath -OutputDirectory $directory.OutputDirectory)) {
        $existing[$path] = $null
        if (-not [bool] (Invoke-DocsReferenceContextMember -Member $Context.TestFile -ArgumentList @($path))) { continue }
        $text = [string] (Invoke-DocsReferenceContextMember -Member $Context.ReadText -ArgumentList @($path))
        $bytes = [byte[]] (Invoke-DocsReferenceContextMember -Member $Context.ReadBytes -ArgumentList @($path))
        $existing[$path] = @{ Text = $text; Sha256 = (Get-DocsTextSha256Hex -Bytes $bytes) }
    }
    $generation = Get-DocsReferenceGeneration -Profile $docsProfile -Snapshot $snapshot.Snapshot -Element $element -ExistingPage $existing -OutputDirectory $directory.OutputDirectory -ProfilePath $profilePath -ComposedSchemaSet $schemas
    $findings.AddRange([object[]] @($generation.Finding))
    $hasError = Test-DocsFindingHasError -Finding $findings.ToArray()
    if ($mode -ceq 'dry-run' -or $hasError) {
        $exitCode = if ($hasError) { 1 } else { 0 }
        return New-DocsReferenceCommandResult -ExitCode $exitCode -Finding $findings.ToArray() -Result (ConvertTo-DocsReferenceResult -Generation $generation -Mode $mode -OutputDirectory $directory.OutputDirectory)
    }

    $status = [ordered]@{}
    $written = 0
    foreach ($change in @($generation.Page)) {
        $path = [string] $change['Path']
        if ([string] $change['Action'] -ceq 'none') { $status[$path] = 'skipped'; continue }
        $outcome = Invoke-DocsReferencePageWrite -Change $change -ReadBytes $Context.ReadBytes -TestFile $Context.TestFile -WriteText $Context.WriteText
        if ($outcome.Status -ceq 'failed') {
            $failure = New-DocsReferenceCommandFinding -Code 'REFERENCE_WRITE_FAILED' -Message "Writing $path failed after $written page(s) were written: $($outcome.Message)" -ArtifactPath $path -RelatedPath @($path)
            return New-DocsReferenceCommandResult -ExitCode 3 -Finding @($failure)
        }
        $status[$path] = $outcome.Status
        if ($outcome.Status -ceq 'conflict') {
            $findings.Add((New-DocsReferenceCommandFinding -Code 'REFERENCE_WRITE_CONFLICT' -Message "Writing stopped: $($outcome.Message)" -ArtifactPath $path))
            return New-DocsReferenceCommandResult -ExitCode 1 -Finding $findings.ToArray() -Result (ConvertTo-DocsReferenceResult -Generation $generation -Mode $mode -WriteStatus $status -OutputDirectory $directory.OutputDirectory)
        }
        $written++
    }
    return New-DocsReferenceCommandResult -ExitCode 0 -Finding $findings.ToArray() -Result (ConvertTo-DocsReferenceResult -Generation $generation -Mode $mode -WriteStatus $status -OutputDirectory $directory.OutputDirectory)
}

Export-ModuleMember -Function `
    Get-DocsReferenceGeneration, `
    Invoke-DocsGenerateReferenceCommand
