Set-StrictMode -Version Latest

# MCP server configuration surface (issue #1028). Renders, from scripts/harness-generation/sources/mcp-servers.json,
# the whole of .mcp.json and only the [mcp_servers.*] region of .codex/config.toml (an anchored line scan; TOML is
# never parsed), plus the bundle copy of each target. Targets come from the parity-matrix entries of kind
# mcp-server, disposition generated, owner_child 3. The Codex package pin is read from the version source the
# source names (packages/mcp-server/package.json), so no version is stored in the source (OQ-4).

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'HarnessGeneration.psm1')

function Get-HarnessMcpSourcePath {
    <#
    .SYNOPSIS
        Returns the repository-relative path of the MCP server source.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()
    return 'scripts/harness-generation/sources/mcp-servers.json'
}

function ConvertTo-HarnessQuotedString {
    <#
    .SYNOPSIS
        Returns a value as a double-quoted, escaped string literal (valid JSON and TOML basic string).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string] $Value)
    return (ConvertTo-Json -InputObject $Value -Compress)
}

function Read-HarnessMcpSource {
    <#
    .SYNOPSIS
        Reads and validates the MCP server source; a malformed source throws naming the source path.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context)
    $sourcePath = Get-HarnessMcpSourcePath
    $text = & $Context.ReadFile $sourcePath
    if ($null -eq $text) { throw "Malformed source '$sourcePath': the file does not exist." }
    $source = $text | ConvertFrom-Json
    if ($null -eq $source -or @($source.PSObject.Properties | ForEach-Object { $_.Name }) -notcontains 'servers') { throw "Malformed source '${sourcePath}': missing 'servers'." }
    $servers = @($source.servers)
    foreach ($server in $servers) {
        $names = @($server.PSObject.Properties | ForEach-Object { $_.Name })
        foreach ($field in @('name', 'command', 'package', 'args')) {
            if ($names -notcontains $field -or $null -eq $server.$field -or ($field -ne 'args' -and [string]::IsNullOrEmpty([string]$server.$field))) {
                throw "Malformed source '${sourcePath}': a server is missing '$field'."
            }
        }
    }
    return $servers
}

function Format-HarnessMcpArgumentList {
    <#
    .SYNOPSIS
        Formats an argument list on one line: ["a", "b"].
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]] $Arguments)
    return '[' + ((@($Arguments) | ForEach-Object { ConvertTo-HarnessQuotedString -Value $_ }) -join ', ') + ']'
}

function Get-HarnessMcpArgument {
    <#
    .SYNOPSIS
        Returns the shared arguments followed by the package, pinned as package@version when a version is given.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory = $true)] $Server, [string] $Version = '')
    $package = [string]$Server.package
    if ($Version -ne '') { $package = "$package@$Version" }
    return [string[]]@(@($Server.args | ForEach-Object { [string]$_ }) + $package)
}

function Format-HarnessClaudeMcpJson {
    <#
    .SYNOPSIS
        Renders .mcp.json for the given servers (two-space indentation, one-line args, trailing newline).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Servers)
    $builder = [System.Text.StringBuilder]::new()
    $null = $builder.Append("{`n  `"mcpServers`": {`n")
    for ($index = 0; $index -lt $Servers.Count; $index++) {
        $server = $Servers[$index]
        $separator = if ($index -lt $Servers.Count - 1) { ',' } else { '' }
        $null = $builder.Append("    $(ConvertTo-HarnessQuotedString -Value $server.name): {`n")
        $null = $builder.Append("      `"command`": $(ConvertTo-HarnessQuotedString -Value $server.command),`n")
        $null = $builder.Append("      `"args`": $(Format-HarnessMcpArgumentList -Arguments (Get-HarnessMcpArgument -Server $server))`n")
        $null = $builder.Append("    }$separator`n")
    }
    $null = $builder.Append("  }`n}`n")
    return $builder.ToString()
}

function Format-HarnessCodexMcpRegion {
    <#
    .SYNOPSIS
        Renders the [mcp_servers.*] region of .codex/config.toml for the given servers, each block ending in a blank line.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]] $Servers,
        [Parameter(Mandatory = $true)][string] $Version
    )
    $builder = [System.Text.StringBuilder]::new()
    foreach ($server in $Servers) {
        $codex = $server.codex
        $keys = @($codex.PSObject.Properties | ForEach-Object { $_.Name })
        $pinned = if ($keys -contains 'pin_version' -and [bool]$codex.pin_version) { $Version } else { '' }
        $null = $builder.Append("[mcp_servers.$($server.name)]`n")
        $null = $builder.Append("command = $(ConvertTo-HarnessQuotedString -Value $server.command)`n")
        $null = $builder.Append("args = $(Format-HarnessMcpArgumentList -Arguments (Get-HarnessMcpArgument -Server $server -Version $pinned))`n")
        if ($keys -contains 'required') { $null = $builder.Append("required = $(([string][bool]$codex.required).ToLowerInvariant())`n") }
        if ($keys -contains 'enabled_tools') {
            $null = $builder.Append("enabled_tools = [`n")
            foreach ($tool in @($codex.enabled_tools)) { $null = $builder.Append("    $(ConvertTo-HarnessQuotedString -Value ([string]$tool)),`n") }
            $null = $builder.Append("]`n")
        }
        if ($keys -contains 'default_tools_approval_mode') { $null = $builder.Append("default_tools_approval_mode = $(ConvertTo-HarnessQuotedString -Value ([string]$codex.default_tools_approval_mode))`n") }
        $null = $builder.Append("`n")
        if ($keys -contains 'tool_approval_modes') {
            foreach ($table in @($codex.tool_approval_modes)) {
                $null = $builder.Append("[mcp_servers.$($server.name).tools.$($table.tool)]`n")
                $null = $builder.Append("approval_mode = $(ConvertTo-HarnessQuotedString -Value ([string]$table.approval_mode))`n`n")
            }
        }
    }
    return $builder.ToString()
}

function Merge-HarnessCodexMcpRegion {
    <#
    .SYNOPSIS
        Replaces the [mcp_servers.*] region of a config.toml text and leaves every other byte unchanged.
    .DESCRIPTION
        The region runs from the first line that starts with '[mcp_servers.' up to the next line that starts with
        '[' but not with '[mcp_servers.', or to the end of the text.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Text,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Region,
        [Parameter(Mandatory = $true)][string] $TargetPath
    )
    $lines = @($Text -split '(?<=\n)')
    $start = -1
    for ($index = 0; $index -lt $lines.Count; $index++) { if ($lines[$index].StartsWith('[mcp_servers.')) { $start = $index; break } }
    if ($start -lt 0) { throw "Target '$TargetPath' has no [mcp_servers.*] region." }
    $end = $lines.Count
    for ($index = $start + 1; $index -lt $lines.Count; $index++) {
        if ($lines[$index].StartsWith('[') -and -not $lines[$index].StartsWith('[mcp_servers.')) { $end = $index; break }
    }
    $prefix = -join @($lines | Select-Object -First $start)
    $suffix = -join @($lines | Select-Object -Skip $end)
    return $prefix + $Region + $suffix
}

function Get-HarnessMcpPinnedVersion {
    <#
    .SYNOPSIS
        Reads the package version that the Codex pin uses from the version source the server names.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context, [Parameter(Mandatory = $true)] $Server)
    $codex = $Server.codex
    if (@($codex.PSObject.Properties | ForEach-Object { $_.Name }) -notcontains 'version_source') { throw "Malformed source '$(Get-HarnessMcpSourcePath)': server '$($Server.name)' pins a version but has no 'version_source'." }
    $text = & $Context.ReadFile ([string]$codex.version_source)
    if ($null -eq $text) { throw "Version source '$($codex.version_source)' does not exist." }
    $package = $text | ConvertFrom-Json
    $version = if ($null -ne $package -and $null -ne $package.PSObject.Properties['version']) { [string]$package.version } else { '' }
    if ($version -eq '') { throw "Version source '$($codex.version_source)' has no 'version'." }
    return $version
}

function Get-HarnessMcpFileMap {
    <#
    .SYNOPSIS
        Returns the MCP surface result: the rendered .mcp.json and config.toml targets and their bundle copies.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory = $true)][pscustomobject] $Context)
    $servers = Read-HarnessMcpSource -Context $Context
    $matrix = Import-HarnessGenerationMatrix -Context $Context
    $selected = Get-HarnessMatrixSelection -Matrix $matrix -Kind 'mcp-server' -Disposition 'generated' -OwnerChild 3
    $files = [ordered]@{}
    foreach ($ecosystem in @('claude', 'codex')) {
        $entries = @($selected | Where-Object { [string]$_.ecosystem -ceq $ecosystem })
        if ($entries.Count -eq 0) { continue }
        $names = @($entries | ForEach-Object { [string]$_.name })
        foreach ($name in $names) {
            if (@($servers | Where-Object { [string]$_.name -ceq $name }).Count -ne 1) { throw "Malformed source '$(Get-HarnessMcpSourcePath)': no single server named '$name'." }
        }
        $chosen = @($servers | Where-Object { $names -ccontains [string]$_.name })
        foreach ($server in $chosen) {
            if (@($server.PSObject.Properties | ForEach-Object { $_.Name }) -notcontains $ecosystem) { throw "Malformed source '$(Get-HarnessMcpSourcePath)': server '$($server.name)' has no '$ecosystem' block." }
        }
        $targets = @($entries | ForEach-Object { @($_.target_paths) } | Select-Object -Unique)
        foreach ($target in $targets) {
            $paths = @([string]$target, (Get-HarnessBundlePath -Path ([string]$target))) | Where-Object { $_ }
            if ($ecosystem -eq 'claude') {
                $text = Format-HarnessClaudeMcpJson -Servers $chosen
                foreach ($path in $paths) { $files[$path] = $text }
                continue
            }
            $version = ''
            foreach ($server in $chosen) {
                if (@($server.codex.PSObject.Properties | ForEach-Object { $_.Name }) -contains 'pin_version' -and [bool]$server.codex.pin_version) { $version = Get-HarnessMcpPinnedVersion -Context $Context -Server $server }
            }
            $region = Format-HarnessCodexMcpRegion -Servers $chosen -Version $version
            foreach ($path in $paths) {
                $current = & $Context.ReadFile $path
                if ($null -eq $current) { throw "Target '$path' does not exist; the MCP generator owns only its [mcp_servers.*] region." }
                $files[$path] = Merge-HarnessCodexMcpRegion -Text ([string]$current) -Region $region -TargetPath $path
            }
        }
    }
    return [pscustomobject]@{ Files = $files; ManagedFolders = [string[]]@(); Findings = [object[]]@() }
}

Export-ModuleMember -Function @(
    'Get-HarnessMcpSourcePath', 'ConvertTo-HarnessQuotedString', 'Read-HarnessMcpSource', 'Format-HarnessMcpArgumentList',
    'Get-HarnessMcpArgument', 'Format-HarnessClaudeMcpJson', 'Format-HarnessCodexMcpRegion', 'Merge-HarnessCodexMcpRegion',
    'Get-HarnessMcpPinnedVersion', 'Get-HarnessMcpFileMap'
)
