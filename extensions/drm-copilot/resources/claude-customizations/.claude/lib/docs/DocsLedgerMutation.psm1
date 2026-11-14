<#
.SYNOPSIS
    The single write boundary of the documentation library: write plans over artifact documents
    and their digest-checked commit through injected scriptblocks.

.DESCRIPTION
    Get-DocsArtifactWritePlan turns documents into plans sorted by path, each with the SHA-256 of
    the UTF-8 text and the status planned, or skipped when the digest equals the digest read at
    load time. Invoke-DocsArtifactWrite commits plans in ascending path order: it creates an
    absent document only after TestFile returns false and overwrites an existing document only
    when the re-read digest (Get-DocsTextSha256Hex, line endings normalized, issue #1173) equals
    BeforeSha256; a present-when-absent document or a digest
    mismatch is a conflict that stops the sequence, and a throwing WriteText is reported as a
    failed plan with its status unchanged. Earlier writes are not rolled back. With -DryRun no
    scriptblock is invoked. This is the only function of the library that invokes a write
    scriptblock; every file access goes through the -ReadBytes, -TestFile and -WriteText
    parameters. Path comparisons are ordinal; inputs are never mutated.

.NOTES
    Issue #1023. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

function Get-DocsMutationMember {
    <#
    .SYNOPSIS
        Returns a table member, or $null when the key is absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Table,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Table -is [System.Collections.IDictionary] -and $Table.Contains($Name)) { return $Table[$Name] }
    return $null
}

function Copy-DocsArtifactWritePlan {
    <#
    .SYNOPSIS
        Returns a copy of one plan with Status replaced (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Plan,
        [AllowNull()] [string] $Status
    )

    $copy = [ordered]@{}
    foreach ($key in @($Plan.Keys)) { $copy[[string] $key] = $Plan[$key] }
    if (-not [string]::IsNullOrEmpty($Status)) { $copy['Status'] = $Status }
    return $copy
}

function Get-DocsArtifactWritePlan {
    <#
    .SYNOPSIS
        Returns write plans sorted by path for documents @{ Path; ArtifactKind; ArtifactId; Text; BeforeSha256 }.
    .DESCRIPTION
        Each plan is @{ Path; ArtifactKind; ArtifactId; Text; BeforeSha256; Sha256; Status } where
        Sha256 is the SHA-256 of the UTF-8 bytes of Text and Status is skipped when Sha256 equals
        BeforeSha256 (ordinal), otherwise planned. BeforeSha256 is $null for a document absent at
        load time. Two documents with one path are rejected.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $Document)

    $keyed = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($item in @($Document)) {
        if ($item -isnot [System.Collections.IDictionary]) { continue }
        $path = [string] (Get-DocsMutationMember -Table $item -Name 'Path')
        if (-not (Test-DocsRelativePath -Path $path)) { throw "DOCS_MUTATION_INPUT_INVALID: Path '$path' is not a repository-relative path." }
        if ($keyed.ContainsKey($path)) { throw "DOCS_MUTATION_INPUT_INVALID: the path '$path' is planned more than once." }
        $text = [string] (Get-DocsMutationMember -Table $item -Name 'Text')
        $before = Get-DocsMutationMember -Table $item -Name 'BeforeSha256'
        $beforeText = if ([string]::IsNullOrEmpty($before)) { $null } else { [string] $before }
        $sha256 = Get-DocsSha256Hex -Text $text
        $keyed[$path] = [ordered]@{
            Path         = $path
            ArtifactKind = [string] (Get-DocsMutationMember -Table $item -Name 'ArtifactKind')
            ArtifactId   = [string] (Get-DocsMutationMember -Table $item -Name 'ArtifactId')
            Text         = $text
            BeforeSha256 = $beforeText
            Sha256       = $sha256
            Status       = $(if ($sha256 -ceq $beforeText) { 'skipped' } else { 'planned' })
        }
    }
    return , [object[]]@($keyed.Values)
}

function Invoke-DocsArtifactWrite {
    <#
    .SYNOPSIS
        Commits write plans in ascending path order through the injected scriptblocks; returns @{ Write; Failed; WrittenPath }.
    .DESCRIPTION
        With -DryRun no scriptblock is invoked and every plan keeps its status. Otherwise a
        skipped plan is left alone; a plan whose BeforeSha256 is $null is created after TestFile
        returns false (status created), and a plan with a BeforeSha256 is overwritten after the
        re-read digest equals it (status updated); the re-read digest is Get-DocsTextSha256Hex, so a
        CRLF form of the read text is not a conflict. A present-when-absent document or a digest
        mismatch gives status conflict and stops the sequence; a throwing WriteText stops the
        sequence with the status unchanged. Failed is $null or the failing plan copy with a
        Message member. Earlier writes are not rolled back; WrittenPath lists them in order.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [AllowEmptyCollection()] [object[]] $Plan,
        [Parameter(Mandatory = $true)] [scriptblock] $ReadBytes,
        [Parameter(Mandatory = $true)] [scriptblock] $TestFile,
        [Parameter(Mandatory = $true)] [scriptblock] $WriteText,
        [switch] $DryRun
    )

    $ordered = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
    foreach ($item in @($Plan)) {
        if ($item -is [System.Collections.IDictionary]) { $ordered[[string] (Get-DocsMutationMember -Table $item -Name 'Path')] = $item }
    }
    $written = [System.Collections.Generic.List[string]]::new()
    $results = [System.Collections.Generic.List[object]]::new()
    $failed = $null
    foreach ($item in $ordered.Values) {
        $status = [string] (Get-DocsMutationMember -Table $item -Name 'Status')
        if ($DryRun -or $null -ne $failed -or $status -ceq 'skipped') { $results.Add((Copy-DocsArtifactWritePlan -Plan $item)); continue }
        $path = [string] $item['Path']
        $before = Get-DocsMutationMember -Table $item -Name 'BeforeSha256'
        $mode = 'overwrite'
        $message = $null
        if ([string]::IsNullOrEmpty($before)) {
            if ([bool] (& $TestFile $path)) { $message = "The document $path exists but was absent when it was read." }
            $mode = 'create'
        } else {
            $current = Get-DocsTextSha256Hex -Bytes ([byte[]] (& $ReadBytes $path))
            if ($current -cne [string] $before) { $message = "The document $path changed after it was read (digest $current, expected $before)." }
        }
        if ($null -ne $message) {
            $failed = Copy-DocsArtifactWritePlan -Plan $item -Status 'conflict'
            $failed['Message'] = $message
            $results.Add((Copy-DocsArtifactWritePlan -Plan $item -Status 'conflict'))
            continue
        }
        try {
            [void] (& $WriteText $path ([string] $item['Text']) $mode)
        } catch {
            $failed = Copy-DocsArtifactWritePlan -Plan $item
            $failed['Message'] = "The write of $path failed: $($_.Exception.Message)"
            $results.Add((Copy-DocsArtifactWritePlan -Plan $item))
            continue
        }
        $written.Add($path)
        $results.Add((Copy-DocsArtifactWritePlan -Plan $item -Status $(if ($mode -ceq 'create') { 'created' } else { 'updated' })))
    }
    return @{ Write = $results.ToArray(); Failed = $failed; WrittenPath = [string[]] $written.ToArray() }
}

Export-ModuleMember -Function `
    Get-DocsArtifactWritePlan, `
    Invoke-DocsArtifactWrite
