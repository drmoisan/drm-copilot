#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Cross-runtime sentinel consumption contract for the capability probe (issue #980).
.DESCRIPTION
    Replays tests/fixtures/discovery_host/sentinel-consumption.json: the two host
    observations the PowerShell gate records for the capability sentinel agent are
    rebuilt from the fixture envelopes through the gate's own builder and compared key
    by key with the fixture records, and the probe's evidence derivation is fed the
    records exactly as the gate wrote them beside the exact `.consumed` latch the
    TypeScript consumer leaves behind. Every document is an in-memory string; the only
    file read is the committed fixture. No temporary file, process, network or clock.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    Import-Module (Join-Path $lib 'DiscoveryCapability.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryObservation.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryToolRouting.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryPayload.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force

    $script:TimestampFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

    function ConvertTo-FixtureValue {
        # ConvertFrom-Json turns ISO strings into DateTime values and objects into PSCustomObjects; the gate's records
        # carry the schema's Z-suffixed strings in ordered tables, so the parsed fixture is normalized back to that shape.
        param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)
        if ($Value -is [datetime]) { return $Value.ToUniversalTime().ToString($script:TimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture) }
        if ($Value -is [System.Management.Automation.PSCustomObject]) {
            $table = [ordered]@{}
            foreach ($property in $Value.PSObject.Properties) { $table[$property.Name] = ConvertTo-FixtureValue -Value $property.Value }
            return $table
        }
        if ($Value -is [array]) { return , @($Value | ForEach-Object { ConvertTo-FixtureValue -Value $_ }) }
        return $Value
    }

    $script:Fixture = ConvertTo-FixtureValue -Value (Get-Content -LiteralPath (Join-Path $script:RepoRoot 'tests/fixtures/discovery_host/sentinel-consumption.json') -Raw | ConvertFrom-Json -Depth 12)
    $script:Location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot $script:Fixture.workspace.workspace_root -Platform 'windows' -UserHome 'C:/Users/Example' -LocalAppData 'C:/Users/Example/AppData/Local'
    $script:Styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal

    function ConvertTo-FixtureInstant {
        param([string]$Value)
        return [datetime]::ParseExact($Value, $script:TimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture, $script:Styles)
    }

    function Get-FixtureRecordFromEnvelope {
        # Rebuilds one observation exactly as the gate does: normalize, attribute, route, then build with the fixture constants.
        param([System.Collections.Specialized.OrderedDictionary]$Envelope)
        $json = $Envelope | ConvertTo-Json -Compress -Depth 8
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName $script:Fixture.host -Text $json
        $principal = Get-DiscoveryTrustedPrincipal -Normalized $normalized
        $tool = Resolve-DiscoveryToolName -ToolName $normalized.ToolName
        $isSentinelTool = ($tool.Family -eq 'mcp-discovery' -and $tool.Name -ceq 'discovery_capability_sentinel')
        $digest = $(if ($isSentinelTool) { Get-DiscoveryInputDigest -Tool 'discovery_capability_sentinel' -Operation 'sentinel' -Inputs $normalized.ToolInput } else { $null })
        return ConvertTo-DiscoveryHostObservationRecord -Normalized $normalized -Principal $principal -ToolName ([string]$normalized.ToolName) `
            -Decision $(if ($isSentinelTool) { 'allow' } else { 'deny' }) -Code $(if ($isSentinelTool) { 'SENTINEL' } else { 'SHELL' }) `
            -HandlerSha256 $script:Fixture.handler_sha256 -Now (ConvertTo-FixtureInstant $script:Fixture.gate_now) -Nonce $script:Fixture.nonce `
            -SentinelInputSha256 $digest -TtlSeconds ([int]$script:Fixture.ttl_seconds)
    }

    function Get-FixtureStore {
        # In-memory store holding both fixture records verbatim and, unless omitted, the consumer latch text at the latch path.
        param([switch]$NoLatch)
        $files = @{}
        foreach ($name in @('tool', 'shell')) {
            $files["$($script:Location.Directory)/$($script:Fixture.relative_paths.$name)"] = (($script:Fixture.records.$name | ConvertTo-Json -Depth 8) + "`n")
        }
        if (-not $NoLatch) { $files["$($script:Location.Directory)/$($script:Fixture.latch.relative_path)"] = [string]$script:Fixture.latch.text }
        $store = @{ Files = $files }
        $store['ReadText'] = { param([string]$Path) if ($store.Files.ContainsKey($Path)) { return $store.Files[$Path] } return $null }.GetNewClosure()
        $store['ListEntries'] = {
            param([string]$Directory)
            $prefix = $Directory.TrimEnd('/') + '/'
            return @($store.Files.Keys | Where-Object { $_.StartsWith($prefix) } | ForEach-Object { $_.Substring($prefix.Length).Split('/')[0] } | Sort-Object -Unique)
        }.GetNewClosure()
        return $store
    }

    function Get-FixtureEvidence {
        param([hashtable]$Store)
        $observations = Get-DiscoverySessionObservation -Location $script:Location -SessionId $script:Fixture.session_id -Store $Store
        return Get-DiscoveryObservationEvidence -Observations $observations -ToolHandlerSha256 $script:Fixture.handler_sha256 -Now (ConvertTo-FixtureInstant $script:Fixture.consumer_now) -TtlSeconds 3600
    }
}

Describe 'sentinel consumption contract' {
    It 'builds the fixture records from the fixture envelopes' {
        foreach ($name in @('tool', 'shell')) {
            $expected = $script:Fixture.records.$name
            $record = Get-FixtureRecordFromEnvelope -Envelope $script:Fixture.envelopes.$name
            @($record.Keys) | Should -Be @($expected.Keys) -Because "the $name record keys and their order are the gate's"
            foreach ($key in $record.Keys) { $record[$key] | Should -Be $expected[$key] -Because "$name record member $key" }
            "$(Get-DiscoveryObservationDirectory -Location $script:Location -SessionId $script:Fixture.session_id)/$($record['observation_ref']).json" |
                Should -Be "$($script:Location.Directory)/$($script:Fixture.relative_paths.$name)"
        }
    }

    It 'proves attribution from the fixture records beside the consumer latch' {
        $evidence = Get-FixtureEvidence -Store (Get-FixtureStore)
        $evidence.TrustedAttribution | Should -BeTrue -Because (@($evidence.Deficiencies | ForEach-Object { $_.Message }) -join '; ')
        $evidence.ForbiddenDenied | Should -BeTrue
        $evidence.SentinelRef | Should -Be $script:Fixture.records.tool.observation_ref
        $evidence.ShellRef | Should -Be $script:Fixture.records.shell.observation_ref
        @($evidence.Deficiencies).Count | Should -Be 0
    }

    It 'reports the pair without the latch as not consumed' {
        $evidence = Get-FixtureEvidence -Store (Get-FixtureStore -NoLatch)
        $evidence.TrustedAttribution | Should -BeFalse
        @($evidence.Deficiencies | ForEach-Object { $_.Message }) -join ' | ' | Should -BeLike '*was not consumed*'
    }
}
