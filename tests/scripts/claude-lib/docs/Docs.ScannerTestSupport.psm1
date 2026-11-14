<#
.SYNOPSIS
    Test support for the TypeScript and .NET scanner suites: in-memory captured-input builders,
    an extension-result manifest builder, canonical output text and a seeded shuffle.

.DESCRIPTION
    Every builder works in memory: text is encoded to UTF-8 in code (with an optional CRLF
    conversion and byte-order mark), wrapped by 1020's New-DocsCapturedInput, and returned. No
    file is read or written, no Pester temporary drive is used, no process is started and nothing is cached at
    module scope. New-DocsTestExtensionManifest builds a valid discovery extension-result manifest,
    its inventory-snapshot result document and the referenced source input as captured inputs,
    with manifest_sha256 computed by ConvertTo-DocsCanonicalJson and Get-DocsSha256Hex.

.NOTES
    Issue #1033. Test support only; never shipped.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs/DocsAnalyzerRegistry.psm1') -ErrorAction Stop

function New-DocsTestCapturedInput {
    <#
    .SYNOPSIS
        Returns a captured input for in-memory text, with optional CRLF line endings and a BOM.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test support module; it changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Text,
        [ValidateSet('LF', 'CRLF')] [string] $LineEnding = 'LF',
        [switch] $Bom,
        [int] $MaxBytes = 1048576
    )

    $normalized = $Text.Replace("`r`n", "`n")
    if ($LineEnding -ceq 'CRLF') { $normalized = $normalized.Replace("`n", "`r`n") }
    [byte[]] $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($normalized)
    if ($Bom) { $bytes = [byte[]](@([byte] 0xEF, [byte] 0xBB, [byte] 0xBF) + $bytes) }
    return New-DocsCapturedInput -Path $Path -Bytes $bytes -MaxBytes $MaxBytes
}

function New-DocsTestOversizeInput {
    <#
    .SYNOPSIS
        Returns a captured input of 1048577 bytes against the 1048576-byte bound (text $null).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test support module; it changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    [byte[]] $bytes = [byte[]]::new(1048577)
    for ($index = 0; $index -lt $bytes.Length; $index++) { $bytes[$index] = 0x61 }
    return New-DocsCapturedInput -Path $Path -Bytes $bytes -MaxBytes 1048576
}

function New-DocsTestUndecodableInput {
    <#
    .SYNOPSIS
        Returns a captured input whose bytes are not valid UTF-8 (text $null).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test support module; it changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory = $true)] [string] $Path)

    return New-DocsCapturedInput -Path $Path -Bytes ([byte[]](0x61, 0xC3, 0x28, 0x62))
}

function New-DocsTestFinding {
    <#
    .SYNOPSIS
        Returns one inventory-snapshot finding record for the extension manifest builder.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test support module; it changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $FindingId,
        [Parameter(Mandatory = $true)] [string] $Kind,
        [Parameter(Mandatory = $true)] [string] $RepositoryId,
        [Parameter(Mandatory = $true)] [string] $Revision,
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [string] $Sha256,
        [Parameter(Mandatory = $true)] [string] $AdapterId,
        [Parameter(Mandatory = $true)] [string] $AdapterVersion,
        [AllowNull()] [string] $Symbol,
        [AllowNull()] [int[]] $LineRange,
        [string] $Classification = 'detected',
        [string] $Confidence = 'high',
        [AllowNull()] [System.Collections.IDictionary] $Property,
        [AllowNull()] [System.Collections.IDictionary] $Extension
    )

    $source = [ordered]@{ repository = $RepositoryId; revision = $Revision; path = $Path; sha256 = $Sha256 }
    if (-not [string]::IsNullOrEmpty($Symbol)) { $source['symbol'] = $Symbol }
    if ($null -ne $LineRange) { $source['line_range'] = [ordered]@{ start = [long] $LineRange[0]; end = [long] $LineRange[1] } }
    $properties = [System.Collections.Generic.List[object]]::new()
    if ($null -ne $Property) {
        foreach ($name in @($Property.Keys)) { $properties.Add([ordered]@{ name = [string] $name; value = $Property[$name] }) }
    }
    $extensions = [ordered]@{}
    if ($null -ne $Extension) { foreach ($name in @($Extension.Keys)) { $extensions[[string] $name] = $Extension[$name] } }
    return [ordered]@{
        finding_id     = $FindingId
        component_id   = 'component-' + $FindingId
        kind           = $Kind
        source         = $source
        analyzer       = [ordered]@{ id = $AdapterId; version = $AdapterVersion }
        classification = $Classification
        confidence     = $Confidence
        properties     = $properties.ToArray()
        extensions     = $extensions
    }
}

function New-DocsTestExtensionManifest {
    <#
    .SYNOPSIS
        Returns @{ CapturedInput; ManifestPath; ManifestText; Manifest; ResultPath; ResultText;
        ResultDocument; SourcePath; SourceText; SourceInput; RepositoryId; Revision; AdapterId;
        AdapterVersion } for one valid extension-result manifest built in memory.
    .DESCRIPTION
        Finding builds the result document's findings from the source input (default: one
        public-symbol finding with a symbol and a line range). MutateResult runs on the result
        document before it is serialized; MutateManifest runs on the manifest before
        manifest_sha256 is computed; MutateManifestAfterDigest runs after the digest is computed,
        so a digest mismatch can be produced. ManifestExtension seeds the manifest's extensions
        map (for example the docs.analysis-method key). SourceLineEnding (LF or CRLF) sets the line
        endings of the captured source and result inputs. Every digest the manifest and the result
        document declare is the raw-byte raw_sha256 of the captured input (issue #1173), as discovery
        extension manifests declare raw-byte digests.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory fixture factory in a test support module; it changes no system state.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string] $SourcePath = 'src/other/service.rb',
        [string] $SourceText = "module Service`n  def self.handle(request)`n    request`n  end`nend`n",
        [string] $ManifestPath = 'discovery/extensions/ruby-adapter.manifest.json',
        [string] $ResultPath = 'discovery/extensions/ruby-adapter.inventory.json',
        [string] $RepositoryId = 'example-repo',
        [string] $Revision = ('a' * 40),
        [string] $AdapterId = 'ruby-adapter',
        [string] $AdapterVersion = '1.2.3',
        [string] $ManifestId = 'ruby-adapter-run',
        [string] $ResultId = 'ruby-adapter-inventory',
        [AllowNull()] [scriptblock] $Finding,
        [AllowNull()] [scriptblock] $MutateResult,
        [AllowNull()] [scriptblock] $MutateManifest,
        [AllowNull()] [scriptblock] $MutateManifestAfterDigest,
        [AllowNull()] [System.Collections.IDictionary] $ManifestExtension,
        [ValidateSet('LF', 'CRLF')] [string] $SourceLineEnding = 'LF'
    )

    $sourceInput = New-DocsTestCapturedInput -Path $SourcePath -Text $SourceText -LineEnding $SourceLineEnding
    # The array wrapper sits outside the if-expression so that a single finding stays a JSON array.
    [object[]] $findings = @(if ($null -eq $Finding) {
            New-DocsTestFinding -FindingId 'finding-handle' -Kind 'public-symbol' -RepositoryId $RepositoryId -Revision $Revision -Path $SourcePath -Sha256 $sourceInput['raw_sha256'] -AdapterId $AdapterId -AdapterVersion $AdapterVersion -Symbol 'Service.handle' -LineRange @(2, 2) -Property ([ordered]@{ name = 'handle' })
        } else {
            & $Finding $sourceInput
        })
    $result = [ordered]@{
        '$schema'                 = 'urn:drm-copilot:discovery:2.0.0:inventory-snapshot'
        schema_version            = '2.0.0'
        artifact_kind             = 'inventory-snapshot'
        id                        = $ResultId
        repository                = $RepositoryId
        revision                  = $Revision
        tool                      = [ordered]@{ id = $AdapterId; version = $AdapterVersion }
        analyzers                 = @([ordered]@{ id = $AdapterId; version = $AdapterVersion })
        scan_configuration_sha256 = ('b' * 64)
        files                     = @([ordered]@{ path = $SourcePath; status = 'captured'; sha256 = $sourceInput['raw_sha256']; size = [long] $sourceInput['size']; rationale = $null; diagnostic_ids = @() })
        components                = @()
        findings                  = $findings
        relationships             = @()
        diagnostics               = @()
        exclusions                = @()
        capture                   = [ordered]@{}
        extensions                = [ordered]@{}
    }
    if ($null -ne $MutateResult) { & $MutateResult $result }
    $resultText = ConvertTo-DocsJsonText -Value $result -Indented
    $resultInput = New-DocsTestCapturedInput -Path $ResultPath -Text $resultText -LineEnding $SourceLineEnding

    $extensions = [ordered]@{}
    if ($null -ne $ManifestExtension) { foreach ($name in @($ManifestExtension.Keys)) { $extensions[[string] $name] = $ManifestExtension[$name] } }
    $manifest = [ordered]@{
        '$schema'             = 'urn:drm-copilot:discovery:2.0.0:extension-result-manifest'
        schema_version        = '2.0.0'
        artifact_kind         = 'extension-result-manifest'
        id                    = $ManifestId
        adapter               = [ordered]@{ id = $AdapterId; version = $AdapterVersion }
        repository            = [ordered]@{ id = $RepositoryId; revision = $Revision }
        input_manifest_sha256 = ('c' * 64)
        source_inputs         = @([ordered]@{ path = $SourcePath; sha256 = $sourceInput['raw_sha256']; size = [long] $sourceInput['size'] })
        result_files          = @([ordered]@{ artifact_kind = 'inventory-snapshot'; id = $ResultId; schema_version = '2.0.0'; path = $ResultPath; sha256 = $resultInput['raw_sha256']; size = [long] $resultInput['size'] })
        manifest_sha256       = $null
        generated_at          = '2026-01-01T00:00:00Z'
        generated_by          = [ordered]@{ kind = 'tool'; id = $AdapterId }
        diagnostics           = @()
        extensions            = $extensions
    }
    if ($null -ne $MutateManifest) { & $MutateManifest $manifest }
    $withoutDigest = [ordered]@{}
    foreach ($key in $manifest.Keys) { if ([string] $key -cne 'manifest_sha256') { $withoutDigest[[string] $key] = $manifest[$key] } }
    $manifest['manifest_sha256'] = Get-DocsSha256Hex -Text (ConvertTo-DocsCanonicalJson -Value $withoutDigest)
    if ($null -ne $MutateManifestAfterDigest) { & $MutateManifestAfterDigest $manifest }
    $manifestText = ConvertTo-DocsJsonText -Value $manifest -Indented
    $manifestInput = New-DocsTestCapturedInput -Path $ManifestPath -Text $manifestText

    return @{
        CapturedInput  = @($sourceInput, $resultInput, $manifestInput)
        ManifestPath   = $ManifestPath
        ManifestText   = $manifestText
        Manifest       = $manifest
        ResultPath     = $ResultPath
        ResultText     = $resultText
        ResultDocument = $result
        SourcePath     = $SourcePath
        SourceText     = $SourceText
        SourceInput    = $sourceInput
        RepositoryId   = $RepositoryId
        Revision       = $Revision
        AdapterId      = $AdapterId
        AdapterVersion = $AdapterVersion
    }
}

function ConvertTo-DocsTestOutputText {
    <#
    .SYNOPSIS
        Returns the canonical JSON of @{ Elements; Diagnostics } of an analyzer output.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Output)

    $elements = @(if ($Output.Contains('Elements')) { $Output['Elements'] })
    $diagnostics = @(if ($Output.Contains('Diagnostics')) { $Output['Diagnostics'] })
    return ConvertTo-DocsCanonicalJson -Value ([ordered]@{ Elements = $elements; Diagnostics = $diagnostics })
}

function Get-DocsTestShuffled {
    <#
    .SYNOPSIS
        Returns a copy of Item shuffled by a seeded System.Random (Fisher-Yates).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyCollection()] [object[]] $Item,
        [Parameter(Mandatory = $true)] [int] $Seed
    )

    [object[]] $copy = @($Item)
    $random = [System.Random]::new($Seed)
    for ($index = $copy.Length - 1; $index -gt 0; $index--) {
        $swap = $random.Next($index + 1)
        $held = $copy[$index]
        $copy[$index] = $copy[$swap]
        $copy[$swap] = $held
    }
    return , $copy
}

Export-ModuleMember -Function `
    New-DocsTestCapturedInput, `
    New-DocsTestOversizeInput, `
    New-DocsTestUndecodableInput, `
    New-DocsTestFinding, `
    New-DocsTestExtensionManifest, `
    ConvertTo-DocsTestOutputText, `
    Get-DocsTestShuffled
