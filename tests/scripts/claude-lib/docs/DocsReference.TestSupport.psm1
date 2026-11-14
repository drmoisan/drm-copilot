<#
.SYNOPSIS
    Test support for the reference-generator suites: seeded input generators, an in-memory
    command context, the committed schema texts, a composed schema set, a test-local CommonMark
    code-span decoder and a test-local unified-hunk applier.

.DESCRIPTION
    Every generator draws from a caller-supplied [System.Random], so a property test that builds
    [System.Random]::new($Seed) reproduces its inputs from the seed alone. Generators return
    strings, arrays and ordered dictionaries; none keeps module-scope state.

    New-DocsReferenceMemoryContext returns a command context whose ReadText, ReadBytes, TestFile
    and ListFile members read an ordinal path-to-text map, whose WriteText member records
    @{ RelativePath; Text; Mode } in a write log and updates the map, and whose UtcNow and
    InvokeProcess members throw, so a test proves that the code under test reads no clock and
    starts no process. ReadText and WriteText can be made to throw for chosen paths, and a
    caller-supplied BeforeCall hook can change the map between calls.

    Get-DocsReferenceSchemaTextMap reads the committed runtime schema files (read-only); it is
    the only member that reads a file. No member creates a file, starts a process or waits on a
    timer.

.NOTES
    Issue #1024. Test support only; never shipped.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsSchema.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsSurface.psm1') -ErrorAction Stop

function Get-DocsReferenceRandomItem {
    <#
    .SYNOPSIS
        Returns one item drawn uniformly from Item (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [System.Random] $Random,
        [Parameter(Mandatory = $true)] [object[]] $Item
    )

    return $Item[$Random.Next(0, $Item.Count)]
}

function Get-DocsReferenceRandomText {
    <#
    .SYNOPSIS
        Returns a drawn text built from fragments that stress the renderer.
    .DESCRIPTION
        Fragments include backtick runs, \p{Cc} characters (tab, U+0001, U+007F, U+0085), U+2028,
        U+2029, angle brackets, a marker-like comment and the instructional prefixes 'how to ' and
        'Step 1'. With ForIdentity the text satisfies the 1020 identity-text grammar (no C0
        control character, no leading or trailing whitespace, not blank), so it can serve as an
        element declaration or name.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [System.Random] $Random,
        [ValidateRange(0, 64)] [int] $MinFragment = 1,
        [ValidateRange(1, 64)] [int] $MaxFragment = 8,
        [switch] $ForIdentity
    )

    $fragment = @(
        'a', 'Zeta', 'x9', '0', ' ', '  ', '-', '_', '/', '.', '#', '*', '|', '=', '{id}', [string][char]0x00E9,
        '`', '``', '```', '<', '>', '<b>', '<!-- docs:generated:start id=x -->',
        [string][char]9, [string][char]1, [string][char]0x7F, [string][char]0x85, [string][char]0x2028, [string][char]0x2029
    )
    $prefix = @('', '', '', 'how to ', 'How To ', 'Step 1 ', 'step 12', '<', '`', ' ')
    $builder = [System.Text.StringBuilder]::new()
    [void]$builder.Append([string] (Get-DocsReferenceRandomItem -Random $Random -Item $prefix))
    $count = $Random.Next($MinFragment, $MaxFragment + 1)
    for ($index = 0; $index -lt $count; $index++) {
        [void]$builder.Append([string] (Get-DocsReferenceRandomItem -Random $Random -Item $fragment))
    }
    $text = $builder.ToString()
    if (-not $ForIdentity) { return $text }
    $clean = ([regex]::Replace($text, '[\x00-\x1f]', '')).Trim()
    if ($clean.Length -eq 0) { return 'item' }
    return $clean
}

function Get-DocsReferenceRandomPath {
    <#
    .SYNOPSIS
        Returns a drawn repository-relative POSIX path that passes Test-DocsRelativePath (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Random] $Random)

    $segment = @('src', 'lib', 'app', 'cli', 'config', 'api', 'pkg_a', 'mod-b', 'v1', 'x.y', 'tick`name', 'with space')
    $leaf = @('main.py', 'routes.ts', 'settings.toml', 'Program.cs', 'index.js', 'tool.ps1')
    $depth = $Random.Next(0, 3)
    $parts = [System.Collections.Generic.List[string]]::new()
    for ($index = 0; $index -lt $depth; $index++) { $parts.Add([string] (Get-DocsReferenceRandomItem -Random $Random -Item $segment)) }
    $parts.Add([string] (Get-DocsReferenceRandomItem -Random $Random -Item $leaf))
    return ($parts.ToArray() -join '/')
}

function New-DocsReferenceRandomElement {
    <#
    .SYNOPSIS
        Returns one valid snapshot element of a drawn or given kind, built with New-DocsSurfaceElement.
    .DESCRIPTION
        Kind defaults to a drawn rendered kind (cli-command, cli-option, http-route, config-key,
        public-symbol); architecture-component may be requested explicitly. A cli-option uses
        ParentId when given, otherwise the identifier of a cli-command that is not part of any
        drawn set (an option without a parent in the snapshot). Declarations and names are drawn
        identity texts; http-route declarations have the form '<METHOD> <template>'. Properties
        are zero to three identifier-named scalar values (string, long, boolean or null).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test generator that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Random] $Random,
        [AllowNull()] [string] $Kind,
        [AllowNull()] [string] $ParentId,
        [AllowNull()] [string] $Declaration
    )

    $rendered = @('cli-command', 'cli-option', 'http-route', 'config-key', 'public-symbol')
    $elementKind = if ([string]::IsNullOrEmpty($Kind)) { [string] (Get-DocsReferenceRandomItem -Random $Random -Item $rendered) } else { $Kind }
    $path = Get-DocsReferenceRandomPath -Random $Random
    $text = if ([string]::IsNullOrEmpty($Declaration)) { Get-DocsReferenceRandomText -Random $Random -ForIdentity } else { $Declaration }
    if ($elementKind -ceq 'http-route' -and [string]::IsNullOrEmpty($Declaration)) {
        $method = [string] (Get-DocsReferenceRandomItem -Random $Random -Item @('GET', 'POST', 'PUT', 'DELETE'))
        $text = "$method /" + ([regex]::Replace($text, '\s', '-'))
    }
    $parent = $null
    if ($elementKind -ceq 'cli-option') {
        $parent = if ([string]::IsNullOrEmpty($ParentId)) { Get-DocsElementId -Kind 'cli-command' -Path 'absent/parent.py' -Declaration ('absent ' + $Random.Next(0, 1000000)) } else { $ParentId }
    }
    $lineCount = $Random.Next(1, 6)
    $sourceLines = [System.Collections.Generic.List[string]]::new()
    for ($index = 0; $index -lt $lineCount; $index++) { $sourceLines.Add('line ' + $index + ' ' + $Random.Next(0, 1000)) }
    $start = $Random.Next(1, $lineCount + 1)
    $end = $Random.Next($start, $lineCount + 1)
    $range = if ($elementKind -ceq 'architecture-component') { $null } else { [int[]]@($start, $end) }
    $property = [ordered]@{}
    $names = @('default', 'type', 'required', 'env-var', 'alias', 'since.v1')
    $propertyCount = $Random.Next(0, 4)
    for ($index = 0; $index -lt $propertyCount; $index++) {
        $propertyName = [string] (Get-DocsReferenceRandomItem -Random $Random -Item $names)
        $choice = $Random.Next(0, 4)
        $propertyValue = switch ($choice) {
            0 { Get-DocsReferenceRandomText -Random $Random }
            1 { [long] $Random.Next(-1000, 1000) }
            2 { ($Random.Next(0, 2) -eq 1) }
            default { $null }
        }
        $property[$propertyName] = $propertyValue
    }
    $analysisMethod = [string] (Get-DocsReferenceRandomItem -Random $Random -Item @('scanner', 'native'))
    return New-DocsSurfaceElement -Kind $elementKind -Path $path -Declaration $text -Name (Get-DocsReferenceRandomText -Random $Random -ForIdentity) -AnalyzerId 'test-analyzer' -AnalysisMethod $analysisMethod -SourceText ($sourceLines.ToArray() -join "`n") -ParentId $parent -LineRange $range -Property $property
}

function New-DocsReferenceRandomProse {
    <#
    .SYNOPSIS
        Returns drawn author prose lines: paragraphs, headings, blank lines and closed fenced blocks.
    .DESCRIPTION
        Fenced blocks (backtick or tilde, three or more characters) may contain marker-like lines,
        which a fence-aware parser must not read as markers. Outside fences no line starts, after
        trimming, with '<!-- docs:generated:'. Every fence is closed.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test generator that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Random] $Random,
        [ValidateRange(0, 32)] [int] $MaxPart = 4
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $partCount = $Random.Next(1, $MaxPart + 1)
    for ($part = 0; $part -lt $partCount; $part++) {
        switch ($Random.Next(0, 4)) {
            0 { $lines.Add('Author paragraph ' + $Random.Next(0, 1000) + ' with `code` and text.') }
            1 { $lines.Add('## Author heading ' + $Random.Next(0, 1000)) }
            2 { $lines.Add('') }
            default {
                $character = [string] (Get-DocsReferenceRandomItem -Random $Random -Item @('`', '~'))
                $fence = $character * $Random.Next(3, 6)
                $lines.Add($fence + 'text')
                $lines.Add('<!-- docs:generated:start id=cli-command-' + ('0' * 64) + ' -->')
                $lines.Add('<!-- docs:generated:end id=broken -->')
                $lines.Add($fence)
            }
        }
    }
    return , $lines.ToArray()
}

function New-DocsReferenceRandomProfile {
    <#
    .SYNOPSIS
        Returns a drawn docs profile that is schema-valid and semantically valid.
    .DESCRIPTION
        One to three audiences are drawn; root audience_ids are drawn from audiences[].id. The
        profile has the documentation root 'docs', optionally a nested root at OutputDirectory with
        its own audiences, page owners covering the output directory, all four Diataxis modes, the
        five required front-matter fields, and the single non-glob reference directory entry at
        OutputDirectory among drawn non-covering entries.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test generator that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [System.Random] $Random,
        [string] $OutputDirectory = 'docs/reference',
        [string] $RepositoryId = 'example-repo'
    )

    $pool = @('maintainers', 'end-users', 'operators', 'a1', 'dev-x')
    $audienceIds = [System.Collections.Generic.List[string]]::new()
    foreach ($id in (Get-DocsReferenceShuffled -Random $Random -Item $pool)) {
        if ($audienceIds.Count -eq 0 -or ($audienceIds.Count -lt 3 -and $Random.Next(0, 2) -eq 1)) { $audienceIds.Add([string] $id) }
    }
    $audiences = @($audienceIds | ForEach-Object { [ordered]@{ id = $_; description = "Audience $_." } })
    $rootAudience = @($audienceIds | Where-Object { $Random.Next(0, 2) -eq 1 })
    if ($rootAudience.Count -eq 0) { $rootAudience = @($audienceIds[0]) }
    $roots = [System.Collections.Generic.List[object]]::new()
    $roots.Add([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = [string[]] $rootAudience })
    if ($OutputDirectory -cne 'docs' -and $Random.Next(0, 2) -eq 1) {
        $roots.Add([ordered]@{ id = 'reference-root'; path = $OutputDirectory; audience_ids = [string[]]@($audienceIds[$audienceIds.Count - 1]) })
    }
    $otherModes = @(
        [ordered]@{ path_or_glob = 'docs/guides/**'; mode = 'how-to' }
        [ordered]@{ path_or_glob = 'docs/tutorials'; mode = 'tutorial' }
        [ordered]@{ path_or_glob = 'docs/concepts/*.md'; mode = 'explanation' }
    )
    $directoryModes = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in (Get-DocsReferenceShuffled -Random $Random -Item $otherModes)) {
        if ($Random.Next(0, 2) -eq 1) { $directoryModes.Add($entry) }
    }
    $directoryModes.Insert($Random.Next(0, $directoryModes.Count + 1), [ordered]@{ path_or_glob = $OutputDirectory; mode = 'reference' })
    return [ordered]@{
        '$schema'           = 'urn:drm-copilot:docs:1.0.0:docs-profile'
        schema_version      = '1.0.0'
        artifact_kind       = 'docs-profile'
        id                  = "$RepositoryId.docs-profile"
        extensions          = [ordered]@{}
        repository          = [ordered]@{ id = $RepositoryId }
        audiences           = [object[]] $audiences
        documentation_roots = [object[]] $roots.ToArray()
        surface_selection   = [ordered]@{ element_kinds = [string[]] (Get-DocsElementKind); source_roots = [string[]]@('src'); exclusions = [object[]]@() }
        page_owners         = [object[]]@([ordered]@{ path_or_glob = "$OutputDirectory/**"; owner = 'docs-team' }, [ordered]@{ path_or_glob = 'docs'; owner = 'maintainer-team' })
        diataxis_policy     = [ordered]@{
            modes                 = [string[]] (Get-DocsReferenceShuffled -Random $Random -Item @('tutorial', 'how-to', 'reference', 'explanation'))
            required_front_matter = [string[]]@('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs')
            directory_modes       = [object[]] $directoryModes.ToArray()
        }
        completion_gates    = [ordered]@{
            docs_complete       = [ordered]@{ required_dispositions_complete = $true; allow_deferred = $true; max_stale_pages = [long] 0; required_parity_dimensions = [string[]]@('exists') }
            integration_pr_gate = [ordered]@{ enabled = $false }
        }
        artifact_paths      = [ordered]@{
            inventory_snapshot = 'docs/documentation-estate/surface-inventory-snapshot.json'
            coverage_ledger    = 'docs/documentation-estate/docs-coverage-ledger.json'
            parity_matrix      = 'docs/documentation-estate/docs-parity-matrix.json'
            evidence_pins      = 'docs/documentation-estate/docs-evidence-pins.json'
            validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json'
        }
    }
}

function New-DocsReferenceFixedProfile {
    <#
    .SYNOPSIS
        Returns a fixed, schema-valid and semantically valid docs profile for example tests.
    .DESCRIPTION
        Audiences 'end-users' and 'maintainers'; the documentation root 'docs' with audience
        'maintainers'; page owners 'docs-team' for '<OutputDirectory>/**' and 'maintainer-team' for
        'docs'; all four Diataxis modes; directory modes 'docs/guides' (how-to) and OutputDirectory
        (reference). DirectoryMode and Mode replace the directory_modes and modes lists.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $OutputDirectory = 'docs/reference',
        [string] $RepositoryId = 'example-repo',
        [AllowNull()] [object[]] $DirectoryMode,
        [AllowNull()] [string[]] $Mode
    )

    $profileValue = New-DocsReferenceRandomProfile -Random ([System.Random]::new(1)) -OutputDirectory $OutputDirectory -RepositoryId $RepositoryId
    $profileValue['audiences'] = [object[]]@([ordered]@{ id = 'end-users'; description = 'Audience end-users.' }, [ordered]@{ id = 'maintainers'; description = 'Audience maintainers.' })
    $profileValue['documentation_roots'] = [object[]]@([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = [string[]]@('maintainers') })
    $modes = if ($null -eq $DirectoryMode) { [object[]]@([ordered]@{ path_or_glob = 'docs/guides'; mode = 'how-to' }, [ordered]@{ path_or_glob = $OutputDirectory; mode = 'reference' }) } else { $DirectoryMode }
    $profileValue['diataxis_policy']['directory_modes'] = [object[]] $modes
    $profileValue['diataxis_policy']['modes'] = if ($null -eq $Mode) { [string[]]@('tutorial', 'how-to', 'reference', 'explanation') } else { $Mode }
    return $profileValue
}

function New-DocsReferenceFixedElement {
    <#
    .SYNOPSIS
        Returns one valid snapshot element with fixed name, analyzer and line range for example tests.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [string] $Declaration,
        [string] $Path = 'src/tool.py',
        [AllowNull()] [string] $ParentId,
        [string] $AnalysisMethod = 'scanner',
        [string] $SourceText = "line one`n"
    )

    $range = if ($Kind -ceq 'architecture-component') { $null } else { [int[]]@(1, 1) }
    return New-DocsSurfaceElement -Kind $Kind -Path $Path -Declaration $Declaration -Name 'name' -AnalyzerId 'test-analyzer' -AnalysisMethod $AnalysisMethod -SourceText $SourceText -ParentId $ParentId -LineRange $range -Property ([ordered]@{})
}

function ConvertTo-DocsReferenceSnapshotText {
    <#
    .SYNOPSIS
        Serializes a schema-valid surface inventory snapshot that holds the given element records.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Element,
        [string] $Repository = 'example-repo',
        [string] $CapturedAt = '2026-01-02T03:04:05Z'
    )

    $snapshot = [ordered]@{
        '$schema'      = 'urn:drm-copilot:docs:1.0.0:surface-inventory-snapshot'
        schema_version = '1.0.0'
        artifact_kind  = 'surface-inventory-snapshot'
        id             = "$Repository.snapshot"
        extensions     = [ordered]@{}
        repository     = $Repository
        revision       = $null
        profile_sha256 = 'a' * 64
        analyzers      = [object[]]@([ordered]@{ id = 'test-analyzer'; version = '1'; analysis_method = 'scanner' })
        inputs         = [object[]]@()
        elements       = [object[]] $Element
        diagnostics    = [object[]]@()
        captured_at    = $CapturedAt
    }
    return ConvertTo-DocsJsonText -Value $snapshot
}

function New-DocsReferenceFileMap {
    <#
    .SYNOPSIS
        Returns an ordinal path-to-text map for an in-memory repository holding the generator inputs.
    .DESCRIPTION
        The map holds every runtime schema text (SchemaTextMap, default Get-DocsReferenceSchemaTextMap),
        the profile at docs/documentation-estate/docs-profile.json (omitted when ProfileValue is
        $null; ProfileText replaces the serialized profile), the snapshot of Element at
        docs/documentation-estate/surface-inventory-snapshot.json (omitted when Element is $null;
        SnapshotText replaces it), and every entry of Page.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Repository paths are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [System.Collections.IDictionary] $ProfileValue,
        [AllowNull()] [string] $ProfileText,
        [AllowNull()] [object[]] $Element,
        [AllowNull()] [string] $SnapshotText,
        [AllowNull()] [System.Collections.IDictionary] $Page,
        [AllowNull()] [System.Collections.IDictionary] $SchemaTextMap
    )

    $files = [hashtable]::new([System.StringComparer]::Ordinal)
    $schemaText = if ($null -eq $SchemaTextMap) { Get-DocsReferenceSchemaTextMap } else { $SchemaTextMap }
    foreach ($key in @($schemaText.Keys)) { $files[[string] $key] = [string] $schemaText[$key] }
    if (-not [string]::IsNullOrEmpty($ProfileText)) { $files['docs/documentation-estate/docs-profile.json'] = $ProfileText }
    elseif ($null -ne $ProfileValue) { $files['docs/documentation-estate/docs-profile.json'] = ConvertTo-DocsJsonText -Value $ProfileValue -Indented }
    if (-not [string]::IsNullOrEmpty($SnapshotText)) { $files['docs/documentation-estate/surface-inventory-snapshot.json'] = $SnapshotText }
    elseif ($null -ne $Element) { $files['docs/documentation-estate/surface-inventory-snapshot.json'] = ConvertTo-DocsReferenceSnapshotText -Element $Element }
    if ($null -ne $Page) { foreach ($key in @($Page.Keys)) { $files[[string] $key] = [string] $Page[$key] } }
    return $files
}

function Get-DocsReferenceShuffled {
    <#
    .SYNOPSIS
        Returns a Fisher-Yates permutation of Item drawn from Random; the input is not mutated.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Random] $Random,
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Item
    )

    $copy = [object[]]::new($Item.Count)
    [Array]::Copy($Item, $copy, $Item.Count)
    for ($index = $copy.Count - 1; $index -gt 0; $index--) {
        $other = $Random.Next(0, $index + 1)
        $held = $copy[$index]
        $copy[$index] = $copy[$other]
        $copy[$other] = $held
    }
    return , $copy
}

function New-DocsReferenceMemoryContext {
    <#
    .SYNOPSIS
        Returns @{ Context; Files; WriteLog; CallLog } for one in-memory command context.
    .DESCRIPTION
        File maps repository-relative paths to text. ReadText and ReadBytes of an absent path throw
        an item-not-found error, as the real members do; ReadBytes returns the UTF-8 bytes of the
        stored text, so a text that begins with U+FEFF yields a byte order mark. WriteText appends
        @{ RelativePath; Text; Mode } to WriteLog and stores the text; mode 'create' on an existing
        path throws. UtcNow and InvokeProcess always throw. ReadTextFailurePath and
        WriteTextFailurePath name paths whose ReadText or WriteText call throws an I/O error.
        BeforeCall, when given, runs before every member call with the member name, the path and
        the file map, so a test can change a page between planning and writing. CallLog records
        '<member> <path>' for every call.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Repository paths are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [System.Collections.IDictionary] $File,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $ReadTextFailurePath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $WriteTextFailurePath,
        [AllowNull()] [scriptblock] $BeforeCall
    )

    $files = [hashtable]::new([System.StringComparer]::Ordinal)
    if ($null -ne $File) {
        foreach ($key in $File.Keys) { $files[[string] $key] = if ($null -eq $File[$key]) { '' } else { [string] $File[$key] } }
    }
    $writeLog = [System.Collections.Generic.List[object]]::new()
    $callLog = [System.Collections.Generic.List[string]]::new()
    $readFailure = [string[]]@(if ($null -ne $ReadTextFailurePath) { $ReadTextFailurePath })
    $writeFailure = [string[]]@(if ($null -ne $WriteTextFailurePath) { $WriteTextFailurePath })
    $hook = if ($null -eq $BeforeCall) { {} } else { $BeforeCall }

    $readText = {
        param($RelativePath)
        $path = [string] $RelativePath
        $callLog.Add("ReadText $path")
        & $hook 'ReadText' $path $files
        if ($readFailure -ccontains $path) { throw [System.IO.IOException]::new("Injected read failure for '$path'.") }
        if (-not $files.ContainsKey($path)) { throw [System.Management.Automation.ItemNotFoundException]::new("Cannot find path '$path' because it does not exist.") }
        return [string] $files[$path]
    }.GetNewClosure()
    $readBytes = {
        param($RelativePath)
        $path = [string] $RelativePath
        $callLog.Add("ReadBytes $path")
        & $hook 'ReadBytes' $path $files
        if (-not $files.ContainsKey($path)) { throw [System.Management.Automation.ItemNotFoundException]::new("Cannot find path '$path' because it does not exist.") }
        return , [System.Text.UTF8Encoding]::new($false).GetBytes([string] $files[$path])
    }.GetNewClosure()
    $testFile = {
        param($RelativePath)
        $path = [string] $RelativePath
        $callLog.Add("TestFile $path")
        & $hook 'TestFile' $path $files
        return $files.ContainsKey($path)
    }.GetNewClosure()
    $listFile = {
        param($RelativeRoot)
        $prefix = ([string] $RelativeRoot).TrimEnd('/') + '/'
        $callLog.Add("ListFile $RelativeRoot")
        & $hook 'ListFile' ([string] $RelativeRoot) $files
        [string[]] $matched = @($files.Keys | Where-Object { ([string] $_).StartsWith($prefix, [System.StringComparison]::Ordinal) })
        [Array]::Sort($matched, [System.StringComparer]::Ordinal)
        return , $matched
    }.GetNewClosure()
    $writeText = {
        param($RelativePath, $Text, $Mode)
        $path = [string] $RelativePath
        $callLog.Add("WriteText $path")
        & $hook 'WriteText' $path $files
        if ($writeFailure -ccontains $path) { throw [System.IO.IOException]::new("Injected write failure for '$path'.") }
        if ([string] $Mode -ceq 'create' -and $files.ContainsKey($path)) { throw [System.IO.IOException]::new("The file '$path' already exists.") }
        $value = if ($null -eq $Text) { '' } else { [string] $Text }
        $writeLog.Add([pscustomobject]@{ RelativePath = $path; Text = $value; Mode = [string] $Mode })
        $files[$path] = $value
    }.GetNewClosure()
    $utcNow = { throw 'The in-memory context forbids reading the clock (UtcNow).' }
    $invokeProcess = { throw 'The in-memory context forbids starting a process (InvokeProcess).' }

    $context = [pscustomobject]@{
        RepositoryRoot = 'in-memory-repository'
        ReadText       = $readText
        ReadBytes      = $readBytes
        TestFile       = $testFile
        ListFile       = $listFile
        WriteText      = $writeText
        UtcNow         = $utcNow
        InvokeProcess  = $invokeProcess
    }
    return @{ Context = $context; Files = $files; WriteLog = $writeLog; CallLog = $callLog }
}

function Get-DocsReferenceSchemaTextMap {
    <#
    .SYNOPSIS
        Returns an ordered map of repository-relative runtime schema path to committed text.
    .DESCRIPTION
        One entry per name of Get-DocsSchemaName, keyed by '.claude/lib/docs/schemas/v1/<name>.schema.json',
        the paths Read-DocsSchemaSet reads. The files are read once per call and never written.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    $root = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $map = [ordered]@{}
    foreach ($name in (Get-DocsSchemaName)) {
        $relative = ".claude/lib/docs/schemas/v1/$name.schema.json"
        $map[$relative] = Get-Content -LiteralPath (Join-Path -Path $root -ChildPath $relative) -Raw
    }
    return $map
}

function New-DocsReferenceComposedSchemaSet {
    <#
    .SYNOPSIS
        Returns COMPOSED-SET: the Schemas map of Get-DocsComposedSchemaSet over the given schema texts.
    .DESCRIPTION
        SchemaTextMap defaults to Get-DocsReferenceSchemaTextMap. The set is read through
        Read-DocsSchemaSet with repository-relative paths and an in-memory reader. 1020 composes
        page-metadata itself (GATE-B does not hold), so no 1021 transformation is applied. A
        composition finding throws.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test fixture factory that builds in-memory objects only.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()] [System.Collections.IDictionary] $SchemaTextMap)

    $map = if ($null -eq $SchemaTextMap) { Get-DocsReferenceSchemaTextMap } else { $SchemaTextMap }
    $schemaPath = [ordered]@{}
    foreach ($name in (Get-DocsSchemaName)) { $schemaPath[$name] = ".claude/lib/docs/schemas/v1/$name.schema.json" }
    $reader = { param($Path) [string] $map[[string] $Path] }.GetNewClosure()
    $composed = Get-DocsComposedSchemaSet -SchemaSet (Read-DocsSchemaSet -SchemaPath $schemaPath -ReadText $reader)
    if (@($composed.Findings).Count -gt 0) { throw "The schema set does not compose: $($composed.Findings[0]['code'])" }
    return $composed.Schemas
}

function ConvertFrom-DocsReferenceCodeSpanText {
    <#
    .SYNOPSIS
        Test-local CommonMark code-span decoder: returns the content of one code span, else throws.
    .DESCRIPTION
        The text must start with a backtick run of length n and end with a backtick run of exactly
        length n, with no backtick run of length n inside. When the content both begins and ends
        with a space and is not only spaces, one space is removed from each end (CommonMark 6.1).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text)

    $open = [regex]::Match($Text, '^`+')
    if (-not $open.Success) { throw "Not a code span: '$Text'" }
    $length = $open.Length
    $close = [regex]::Match($Text, '`+$')
    if ($close.Length -ne $length -or $Text.Length -lt 2 * $length + 1) { throw "Unbalanced code span: '$Text'" }
    $content = $Text.Substring($length, $Text.Length - 2 * $length)
    foreach ($run in [regex]::Matches($content, '`+')) {
        if ($run.Length -eq $length) { throw "Code span closes early: '$Text'" }
    }
    if ($content.Length -ge 2 -and $content.StartsWith(' ') -and $content.EndsWith(' ') -and $content.Trim(' ').Length -gt 0) {
        $content = $content.Substring(1, $content.Length - 2)
    }
    return $content
}

function Get-DocsReferencePatchedLine {
    <#
    .SYNOPSIS
        Test-local unified-hunk applier: returns the after lines produced by applying DiffText to BeforeLine.
    .DESCRIPTION
        DiffText is LF-terminated unified-diff text: a '--- ' and a '+++ ' header line, then hunks
        '@@ -a[,b] +c[,d] @@' followed by ' ', '-' and '+' lines. A count of 0 means the hunk sits
        after line a. Context and removed lines must equal the before lines, otherwise the applier
        throws. An empty DiffText returns BeforeLine unchanged.
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $BeforeLine,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $DiffText
    )

    $result = [System.Collections.Generic.List[string]]::new()
    if ($DiffText.Length -eq 0) { return , [string[]] $BeforeLine }
    if (-not $DiffText.EndsWith("`n")) { throw 'The diff text is not LF-terminated.' }
    $lines = $DiffText.Substring(0, $DiffText.Length - 1).Split("`n")
    if ($lines.Count -lt 2 -or -not $lines[0].StartsWith('--- ') -or -not $lines[1].StartsWith('+++ ')) { throw 'The diff text has no file header.' }
    $next = 0
    $index = 2
    while ($index -lt $lines.Count) {
        $header = [regex]::Match($lines[$index], '^@@ -(?<a>[0-9]+)(?:,(?<b>[0-9]+))? \+(?<c>[0-9]+)(?:,(?<d>[0-9]+))? @@$')
        if (-not $header.Success) { throw "Expected a hunk header: '$($lines[$index])'" }
        $start = [int] $header.Groups['a'].Value
        $count = if ($header.Groups['b'].Success) { [int] $header.Groups['b'].Value } else { 1 }
        $position = if ($count -eq 0) { $start } else { $start - 1 }
        if ($position -lt $next) { throw 'Hunks overlap or are out of order.' }
        while ($next -lt $position) { $result.Add($BeforeLine[$next]); $next++ }
        $index++
        while ($index -lt $lines.Count -and -not $lines[$index].StartsWith('@@ ')) {
            $line = $lines[$index]
            $body = $line.Substring(1)
            switch ($line.Substring(0, 1)) {
                ' ' { if ($BeforeLine[$next] -cne $body) { throw "Context mismatch at before line $($next + 1)." }; $result.Add($body); $next++ }
                '-' { if ($BeforeLine[$next] -cne $body) { throw "Removal mismatch at before line $($next + 1)." }; $next++ }
                '+' { $result.Add($body) }
                default { throw "Unexpected hunk line: '$line'" }
            }
            $index++
        }
    }
    while ($next -lt $BeforeLine.Count) { $result.Add($BeforeLine[$next]); $next++ }
    return , $result.ToArray()
}

Export-ModuleMember -Function `
    Get-DocsReferenceRandomText, `
    New-DocsReferenceRandomElement, `
    New-DocsReferenceRandomProse, `
    New-DocsReferenceRandomProfile, `
    New-DocsReferenceFixedProfile, `
    New-DocsReferenceFixedElement, `
    ConvertTo-DocsReferenceSnapshotText, `
    New-DocsReferenceFileMap, `
    Get-DocsReferenceShuffled, `
    New-DocsReferenceMemoryContext, `
    Get-DocsReferenceSchemaTextMap, `
    New-DocsReferenceComposedSchemaSet, `
    ConvertFrom-DocsReferenceCodeSpanText, `
    Get-DocsReferencePatchedLine
