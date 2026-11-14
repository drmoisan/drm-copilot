<#
.SYNOPSIS
    JSON reading and writing for the parallel admission helper (issue #1047).

.DESCRIPTION
    Holds the pure JSON functions of .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1.
    JSON is read with System.Text.Json, which keeps timestamp strings and the
    integer and boolean distinction (the Invoke-ParallelDriftDetection.ps1
    precedent): object keys stay case-sensitive, integers become Int64, and an
    array root is not unrolled. JSON is written with ordinally sorted keys at
    every depth and LF line endings, so the output is identical on every host.
    Every function is pure: no filesystem, subprocess, network, or clock access.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:AdmissionIntegerTypeName = @('System.Int16', 'System.Int32', 'System.Int64', 'System.Byte', 'System.SByte', 'System.UInt16', 'System.UInt32', 'System.UInt64')

function ConvertFrom-ParallelAdmissionJsonElement {
    <#
    .SYNOPSIS
        Convert one System.Text.Json element: objects to ordinal hashtables, arrays to object arrays, integers to Int64.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'JSON object keys are case-sensitive; the @{} literal is case-insensitive, so an ordinal-comparer hashtable is required (issue #763 precedent).')]
    [CmdletBinding()]
    [OutputType([hashtable], [System.Object[]], [string], [long], [double], [bool])]
    param([System.Text.Json.JsonElement] $Element)

    switch ($Element.ValueKind) {
        ([System.Text.Json.JsonValueKind]::Object) {
            $table = [hashtable]::new([System.StringComparer]::Ordinal)
            foreach ($property in $Element.EnumerateObject()) {
                $table[$property.Name] = ConvertFrom-ParallelAdmissionJsonElement -Element $property.Value
            }
            return $table
        }
        ([System.Text.Json.JsonValueKind]::Array) {
            $list = [System.Collections.Generic.List[object]]::new()
            foreach ($member in $Element.EnumerateArray()) { $list.Add((ConvertFrom-ParallelAdmissionJsonElement -Element $member)) }
            return , $list.ToArray()
        }
        ([System.Text.Json.JsonValueKind]::String) { return $Element.GetString() }
        ([System.Text.Json.JsonValueKind]::Number) {
            $integral = [long]0
            if ($Element.TryGetInt64([ref] $integral)) { return $integral }
            return $Element.GetDouble()
        }
        ([System.Text.Json.JsonValueKind]::True) { return $true }
        ([System.Text.Json.JsonValueKind]::False) { return $false }
        default { return $null }
    }
}

function ConvertFrom-ParallelAdmissionJson {
    <#
    .SYNOPSIS
        Parse JSON text with System.Text.Json into PowerShell values; an array root is not unrolled.
    #>
    [CmdletBinding()]
    [OutputType([hashtable], [System.Object[]], [object])]
    param([string] $Text)

    $document = [System.Text.Json.JsonDocument]::Parse($Text)
    try {
        $value = ConvertFrom-ParallelAdmissionJsonElement -Element $document.RootElement
    } finally {
        $document.Dispose()
    }
    if ($value -is [array]) { return , $value }
    return $value
}

function Write-ParallelAdmissionJsonValue {
    <#
    .SYNOPSIS
        Write one value to a JSON writer, sorting object keys ordinally at every depth.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param([System.Text.Json.Utf8JsonWriter] $Writer, [AllowNull()][object] $Value)

    # Strings and dictionaries are tested before IEnumerable, which both also implement.
    if ($null -eq $Value) { $Writer.WriteNullValue(); return }
    if ($Value -is [bool]) { $Writer.WriteBooleanValue($Value); return }
    if ($Value -is [string]) { $Writer.WriteStringValue($Value); return }
    if ($script:AdmissionIntegerTypeName -contains $Value.GetType().FullName) { $Writer.WriteNumberValue([long]$Value); return }
    if ($Value -is [double] -or $Value -is [single] -or $Value -is [decimal]) { $Writer.WriteNumberValue([double]$Value); return }
    if ($Value -is [System.Collections.IDictionary] -or $Value -is [System.Management.Automation.PSCustomObject]) {
        $pairs = [System.Collections.Generic.SortedDictionary[string, object]]::new([System.StringComparer]::Ordinal)
        if ($Value -is [System.Collections.IDictionary]) {
            foreach ($key in $Value.Keys) { $pairs[[string]$key] = $Value[$key] }
        } else {
            foreach ($property in $Value.PSObject.Properties) { $pairs[$property.Name] = $property.Value }
        }
        $Writer.WriteStartObject()
        foreach ($pair in $pairs.GetEnumerator()) {
            $Writer.WritePropertyName($pair.Key)
            Write-ParallelAdmissionJsonValue -Writer $Writer -Value $pair.Value
        }
        $Writer.WriteEndObject()
        return
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $Writer.WriteStartArray()
        foreach ($member in $Value) { Write-ParallelAdmissionJsonValue -Writer $Writer -Value $member }
        $Writer.WriteEndArray()
        return
    }
    throw "ConvertTo-ParallelAdmissionJson cannot serialize a value of type $($Value.GetType().FullName)."
}

function ConvertTo-ParallelAdmissionJson {
    <#
    .SYNOPSIS
        Serialize a value to indented JSON with ordinally sorted keys and LF line endings.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()][object] $Value)

    $stream = [System.IO.MemoryStream]::new()
    $options = [System.Text.Json.JsonWriterOptions]@{ Indented = $true; Encoder = [System.Text.Encodings.Web.JavaScriptEncoder]::UnsafeRelaxedJsonEscaping }
    $writer = [System.Text.Json.Utf8JsonWriter]::new($stream, $options)
    try {
        Write-ParallelAdmissionJsonValue -Writer $writer -Value $Value
        $writer.Flush()
        # The writer's indentation follows the platform newline; LF keeps the output identical on every host.
        return [System.Text.Encoding]::UTF8.GetString($stream.ToArray()).Replace("`r`n", "`n")
    } finally {
        $writer.Dispose()
        $stream.Dispose()
    }
}

Export-ModuleMember -Function `
    ConvertFrom-ParallelAdmissionJsonElement, `
    ConvertFrom-ParallelAdmissionJson, `
    Write-ParallelAdmissionJsonValue, `
    ConvertTo-ParallelAdmissionJson
