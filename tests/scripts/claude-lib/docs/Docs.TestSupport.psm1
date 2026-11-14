<#
.SYNOPSIS
    Test support for the documentation library suites: an in-memory command context and readers
    for the committed runtime schemas and examples.

.DESCRIPTION
    New-DocsTestContext returns a new in-memory command context on every call, with the same
    member set as the real context of Invoke-DocsCommand.ps1 (RepositoryRoot, ReadText, ReadBytes,
    TestFile, ListFile, WriteText, UtcNow, InvokeProcess, ResolveRevision, ReadRevisionText). Files
    live in an ordinal hashtable of repository-relative path to text; writes are recorded in a
    write log and applied to that map; the clock returns a fixed value; the InvokeProcess fake
    starts nothing, records each call in a call log and returns a caller-configured result; the
    revision members read caller-supplied in-memory maps. Nothing is cached at module scope.

    Get-DocsTestSchemaText and Get-DocsTestExampleText read the committed text of
    .claude/lib/docs/schemas/v1/*.schema.json and examples/docs/v1/*.example.json once per call.

.NOTES
    Issue #1020. Test support only; never shipped.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-DocsTestRepositoryRoot {
    <#
    .SYNOPSIS
        Returns the repository root resolved from this module's location.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
}

function Get-DocsTestFileTextMap {
    <#
    .SYNOPSIS
        Reads the committed files matching a suffix in one directory into a name-to-text map
        (private helper).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $RelativeDirectory,
        [Parameter(Mandatory = $true)] [string] $Suffix
    )

    $directory = Join-Path -Path (Get-DocsTestRepositoryRoot) -ChildPath $RelativeDirectory
    $map = [ordered]@{}
    $files = @(Get-ChildItem -LiteralPath $directory -File | Where-Object { $_.Name.EndsWith($Suffix, [System.StringComparison]::Ordinal) })
    [string[]] $names = @($files | ForEach-Object { $_.Name })
    [Array]::Sort($names, [System.StringComparer]::Ordinal)
    foreach ($name in $names) {
        $map[$name.Substring(0, $name.Length - $Suffix.Length)] = Get-Content -LiteralPath (Join-Path -Path $directory -ChildPath $name) -Raw
    }
    return $map
}

function Get-DocsTestSchemaText {
    <#
    .SYNOPSIS
        Returns the committed runtime schema texts as an ordered map of schema name to text.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return Get-DocsTestFileTextMap -RelativeDirectory '.claude/lib/docs/schemas/v1' -Suffix '.schema.json'
}

function Get-DocsTestExampleText {
    <#
    .SYNOPSIS
        Returns the committed example texts as an ordered map of example name to text.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return Get-DocsTestFileTextMap -RelativeDirectory 'examples/docs/v1' -Suffix '.example.json'
}

function New-DocsTestRevisionPairMember {
    <#
    .SYNOPSIS
        Returns @{ TestAncestor; ListChangedPath } in-memory members backed by maps keyed by the
        revision pair '<first>..<second>' (private helper, issue #1169).
    .DESCRIPTION
        TestAncestor returns the mapped value as a boolean; ListChangedPath returns the mapped
        paths as one string array (an empty array for an empty entry). An unmapped pair returns
        $null from either member. No process starts.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory closures only.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Revision pairs are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [System.Collections.IDictionary] $AncestorMap,
        [AllowNull()] [System.Collections.IDictionary] $ChangedPathMap
    )

    $ancestors = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($null -ne $AncestorMap) { foreach ($key in $AncestorMap.Keys) { $ancestors[[string] $key] = [bool] $AncestorMap[$key] } }
    $changes = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($null -ne $ChangedPathMap) { foreach ($key in $ChangedPathMap.Keys) { $changes[[string] $key] = [string[]] @($ChangedPathMap[$key]) } }
    $testAncestor = {
        param($Ancestor, $Descendant)
        $key = "$Ancestor..$Descendant"
        if ($ancestors.ContainsKey($key)) { return $ancestors[$key] }
        return $null
    }.GetNewClosure()
    $listChangedPath = {
        param($FromRevision, $ToRevision)
        $key = "$FromRevision..$ToRevision"
        if ($changes.ContainsKey($key)) { return , ([string[]] $changes[$key].Clone()) }
        return $null
    }.GetNewClosure()
    return @{ TestAncestor = $testAncestor; ListChangedPath = $listChangedPath }
}

function New-DocsTestContext {
    <#
    .SYNOPSIS
        Returns @{ Context; Files; WriteLog; ProcessCallLog; Revisions } for one in-memory command context.
    .DESCRIPTION
        The context carries the thirteen members of New-DocsCommandContext in its order:
        RepositoryRoot, ReadText, ReadBytes, TestFile, ListFile, WriteText, UtcNow, InvokeProcess,
        ReadStdin, ResolveRevision, ReadRevisionText, TestAncestor, ListChangedPath. ReadStdin
        returns Stdin (issue #1173), or the empty string when Stdin is not given.
        File is a map of repository-relative path to text; a $null or empty text is an empty file,
        for which ReadText returns the empty string. ReadText of an absent path throws an
        item-not-found error, as the real member does. WriteText with Mode 'create' on an existing
        path throws. ProcessResult configures the InvokeProcess fake (default exit code 0, empty
        streams, TimedOut false). RevisionMap maps a ref to a full revision: ResolveRevision returns
        the mapped revision, or $null for an unmapped ref. RevisionFile maps a full revision to a
        map of repository-relative path to text: ReadRevisionText returns the mapped text, or $null
        when the revision or the path is absent. AncestorMap and ChangedPathMap (issue #1169) are
        keyed by the revision pair '<first>..<second>': TestAncestor returns the mapped boolean and
        ListChangedPath the mapped path array, and each returns $null for an unmapped pair. No member
        starts a process. Revisions is the ordinal revision table that ResolveRevision reads, so a
        scenario can move HEAD between steps.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Repository paths are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [System.Collections.IDictionary] $File,
        [datetime] $UtcNow = [datetime]::new(2026, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc),
        [AllowNull()] [System.Collections.IDictionary] $ProcessResult,
        [string] $RepositoryRoot = 'in-memory-repository',
        [AllowNull()] [System.Collections.IDictionary] $RevisionMap,
        [AllowNull()] [System.Collections.IDictionary] $RevisionFile,
        [AllowNull()] [System.Collections.IDictionary] $AncestorMap,
        [AllowNull()] [System.Collections.IDictionary] $ChangedPathMap,
        [AllowNull()] [string] $Stdin
    )

    $files = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($null -ne $File) {
        foreach ($key in $File.Keys) { $files[[string] $key] = if ($null -eq $File[$key]) { '' } else { [string] $File[$key] } }
    }
    $writeLog = [System.Collections.Generic.List[object]]::new()
    $processCallLog = [System.Collections.Generic.List[object]]::new()
    $result = @{ ExitCode = 0; Stdout = ''; Stderr = ''; TimedOut = $false }
    if ($null -ne $ProcessResult) {
        foreach ($key in $ProcessResult.Keys) { $result[[string] $key] = $ProcessResult[$key] }
    }
    $clock = $UtcNow
    $revisions = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($null -ne $RevisionMap) {
        foreach ($key in $RevisionMap.Keys) { $revisions[[string] $key] = [string] $RevisionMap[$key] }
    }
    $revisionFiles = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($null -ne $RevisionFile) {
        foreach ($revisionKey in $RevisionFile.Keys) {
            $pathMap = [hashtable]::new([System.StringComparer]::Ordinal)
            foreach ($pathKey in $RevisionFile[$revisionKey].Keys) { $pathMap[[string] $pathKey] = [string] $RevisionFile[$revisionKey][$pathKey] }
            $revisionFiles[[string] $revisionKey] = $pathMap
        }
    }

    $readText = {
        param($RelativePath)
        if (-not $files.ContainsKey([string] $RelativePath)) {
            throw [System.Management.Automation.ItemNotFoundException]::new("Cannot find path '$RelativePath' because it does not exist.")
        }
        return [string] $files[[string] $RelativePath]
    }.GetNewClosure()
    $readBytes = {
        param($RelativePath)
        if (-not $files.ContainsKey([string] $RelativePath)) {
            throw [System.Management.Automation.ItemNotFoundException]::new("Cannot find path '$RelativePath' because it does not exist.")
        }
        return , [System.Text.UTF8Encoding]::new($false).GetBytes([string] $files[[string] $RelativePath])
    }.GetNewClosure()
    $testFile = {
        param($RelativePath)
        return $files.ContainsKey([string] $RelativePath)
    }.GetNewClosure()
    $listFile = {
        param($RelativeRoot)
        $prefix = ([string] $RelativeRoot).TrimEnd('/') + '/'
        [string[]] $matched = @($files.Keys | Where-Object { ([string] $_).StartsWith($prefix, [System.StringComparison]::Ordinal) })
        [Array]::Sort($matched, [System.StringComparer]::Ordinal)
        return , $matched
    }.GetNewClosure()
    $writeText = {
        param($RelativePath, $Text, $Mode)
        $path = [string] $RelativePath
        if ($Mode -ceq 'create' -and $files.ContainsKey($path)) { throw "The file '$path' already exists." }
        $value = if ($null -eq $Text) { '' } else { [string] $Text }
        $writeLog.Add([pscustomobject]@{ RelativePath = $path; Text = $value; Mode = [string] $Mode })
        $files[$path] = $value
    }.GetNewClosure()
    $utcNowMember = {
        return $clock
    }.GetNewClosure()
    $invokeProcess = {
        param($FilePath, $ArgumentList, $StdinText, $TimeoutSeconds)
        $processCallLog.Add([pscustomobject]@{ FilePath = $FilePath; ArgumentList = $ArgumentList; StdinText = $StdinText; TimeoutSeconds = $TimeoutSeconds })
        return @{ ExitCode = $result['ExitCode']; Stdout = $result['Stdout']; Stderr = $result['Stderr']; TimedOut = $result['TimedOut'] }
    }.GetNewClosure()
    $stdinText = if ($null -eq $Stdin) { '' } else { $Stdin }
    $readStdin = { return $stdinText }.GetNewClosure()
    $resolveRevision = {
        param($Ref)
        $key = [string] $Ref
        if ($revisions.ContainsKey($key)) { return $revisions[$key] }
        return $null
    }.GetNewClosure()
    $readRevisionText = {
        param($Revision, $RelativePath)
        $revisionKey = [string] $Revision
        $pathKey = [string] $RelativePath
        if ($revisionFiles.ContainsKey($revisionKey) -and $revisionFiles[$revisionKey].ContainsKey($pathKey)) { return $revisionFiles[$revisionKey][$pathKey] }
        return $null
    }.GetNewClosure()
    $pairMaps = New-DocsTestRevisionPairMember -AncestorMap $AncestorMap -ChangedPathMap $ChangedPathMap

    $context = [pscustomobject]@{
        RepositoryRoot   = $RepositoryRoot
        ReadText         = $readText
        ReadBytes        = $readBytes
        TestFile         = $testFile
        ListFile         = $listFile
        WriteText        = $writeText
        UtcNow           = $utcNowMember
        InvokeProcess    = $invokeProcess
        ReadStdin        = $readStdin
        ResolveRevision  = $resolveRevision
        ReadRevisionText = $readRevisionText
        TestAncestor     = $pairMaps.TestAncestor
        ListChangedPath  = $pairMaps.ListChangedPath
    }
    return @{ Context = $context; Files = $files; WriteLog = $writeLog; ProcessCallLog = $processCallLog; Revisions = $revisions }
}

Export-ModuleMember -Function `
    Get-DocsTestRepositoryRoot, `
    Get-DocsTestSchemaText, `
    Get-DocsTestExampleText, `
    New-DocsTestContext
