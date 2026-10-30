#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Freshness tests for `.claude/lib/discovery-validation/DiscoveryManifest.psm1` (issue #980).
.DESCRIPTION
    Proves strict manifest decoding and the drift classification (edited, deleted,
    appeared, renamed, evidence-replaced, profile-changed) over an in-memory byte
    store injected through the ReadBytes seam. No file, process, network or clock is
    touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryManifest.psm1') -Force

    $script:Workspace = 'C:/Users/Example/Repos/Workspace'
    $script:ProfilePath = 'docs/migration/discovery/domain-profile.yaml'

    function Get-Utf8ByteArray {
        [CmdletBinding()]
        [OutputType([byte[]])]
        param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

        return [System.Text.Encoding]::UTF8.GetBytes($Text)
    }

    function Get-ByteStore {
        [CmdletBinding()]
        [OutputType([hashtable])]
        param()

        # Workspace-relative path to bytes; the seam resolves absolute paths back to it.
        return @{
            $script:ProfilePath          = Get-Utf8ByteArray 'schema_version: 2.0.0'
            'docs/scope.yaml'            = Get-Utf8ByteArray 'scope: all'
            'evidence/run-001.json'      = Get-Utf8ByteArray '{"run":1}'
            'src/Orders/OrderService.cs' = Get-Utf8ByteArray 'class OrderService {}'
        }
    }

    function Get-ReadBytesSeam {
        [CmdletBinding()]
        [OutputType([scriptblock])]
        param([Parameter(Mandatory = $true)][hashtable]$Store)

        $snapshot = $Store
        $workspace = $script:Workspace
        return {
            param([string]$Path)
            $relative = $Path.Substring($workspace.Length + 1)
            if ($snapshot.ContainsKey($relative)) { return , $snapshot[$relative] }
            return $null
        }.GetNewClosure()
    }

    function Get-ManifestFromStore {
        [CmdletBinding()]
        [OutputType([System.Collections.Specialized.OrderedDictionary])]
        param(
            [Parameter(Mandatory = $true)][hashtable]$Store,
            [Parameter(Mandatory = $false)][string[]]$MissingPaths = @('docs/absent.yaml')
        )

        $categories = @{
            $script:ProfilePath = 'profile'; 'docs/scope.yaml' = 'scope'
            'evidence/run-001.json' = 'evidence'; 'src/Orders/OrderService.cs' = 'source'
        }
        $entries = @(foreach ($path in ($Store.Keys | Sort-Object)) {
                [ordered]@{ category = $categories[$path]; path = $path; sha256 = (Get-DiscoverySha256Hex -Text ([System.Text.Encoding]::UTF8.GetString($Store[$path]))); size = [int64]$Store[$path].Length }
            })
        $manifest = [ordered]@{
            entries             = $entries
            missing_paths       = @($MissingPaths)
            source_repositories = @([ordered]@{ id = 'legacy-crm'; revision = ('a' * 40) })
            target_repositories = @()
        }
        $manifest['sha256'] = Get-DiscoveryInputManifestDigest -Manifest $manifest
        return $manifest
    }

    function Get-DriftKindList {
        [CmdletBinding()]
        [OutputType([object[]])]
        param([Parameter(Mandatory = $true)][pscustomobject]$Result)

        return @($Result.Drift | ForEach-Object { "$($_.kind):$($_.path)" })
    }

    Import-Module (Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryEncoding.psm1') -Force
}

Describe 'ConvertFrom-DiscoveryInputManifest' {
    It 'accepts a well-formed manifest parsed from JSON and preserves its members' {
        # Arrange: round-trip through JSON so PSCustomObject input is exercised.
        $manifest = Get-ManifestFromStore -Store (Get-ByteStore)
        $parsed = ($manifest | ConvertTo-Json -Depth 6) | ConvertFrom-Json -Depth 6

        # Act
        $decoded = ConvertFrom-DiscoveryInputManifest -Value $parsed

        # Assert
        @($decoded.entries).Count | Should -Be 4
        $decoded.missing_paths | Should -Be @('docs/absent.yaml')
        $decoded.source_repositories[0].id | Should -Be 'legacy-crm'
        $decoded.sha256 | Should -Be $manifest['sha256']
        Get-DiscoveryInputManifestDigest -Manifest $decoded | Should -Be $manifest['sha256']
    }

    It 'rejects <Name>' -ForEach @(
        @{ Name = 'an extra manifest key'; Mutate = { param($m) $m['extra'] = 1 }; Detail = 'manifest keys' }
        @{ Name = 'a malformed digest'; Mutate = { param($m) $m['sha256'] = 'ABC' }; Detail = 'manifest fields' }
        @{ Name = 'an unknown category'; Mutate = { param($m) $m['entries'][0]['category'] = 'mystery' }; Detail = 'entry fields' }
        @{ Name = 'a negative size'; Mutate = { param($m) $m['entries'][0]['size'] = -1 }; Detail = 'entry fields' }
        @{ Name = 'an absolute entry path'; Mutate = { param($m) $m['entries'][0]['path'] = '/etc/passwd' }; Detail = 'entry path' }
        @{ Name = 'a duplicate entry path'; Mutate = { param($m) $m['entries'] = @($m['entries'][0], $m['entries'][0]) }; Detail = 'duplicate entry paths' }
        @{ Name = 'a missing path that is also an entry'; Mutate = { param($m) $m['missing_paths'] = @($m['entries'][0]['path']) }; Detail = 'missing path also listed as an entry' }
        @{ Name = 'a repository with a bad revision'; Mutate = { param($m) $m['source_repositories'] = @([ordered]@{ id = 'legacy-crm'; revision = 'main' }) }; Detail = 'repository reference' }
        @{ Name = 'a string where an array is expected'; Mutate = { param($m) $m['missing_paths'] = 'docs/x.yaml' }; Detail = 'manifest fields' }
    ) {
        $manifest = Get-ManifestFromStore -Store (Get-ByteStore)
        & $Mutate $manifest
        { ConvertFrom-DiscoveryInputManifest -Value $manifest } | Should -Throw -ExpectedMessage "INPUT_MANIFEST_INVALID: Input manifest is malformed: $Detail"
    }
}

Describe 'Compare-DiscoveryInputManifest' {
    It 'reports no drift and reproduces the digest when every input is unchanged' {
        $store = Get-ByteStore
        $manifest = Get-ManifestFromStore -Store $store
        $profileSha = ($manifest['entries'] | Where-Object { $_['path'] -eq $script:ProfilePath })['sha256']

        $result = Compare-DiscoveryInputManifest -Manifest $manifest -WorkspaceRoot $script:Workspace -ProfilePath $script:ProfilePath -ProfileSha256 $profileSha -ReadBytes (Get-ReadBytesSeam -Store $store)

        $result.Drift | Should -BeNullOrEmpty
        $result.Manifest['sha256'] | Should -Be $manifest['sha256']
        Assert-DiscoveryInputsFresh -Manifest $manifest -WorkspaceRoot $script:Workspace -ProfilePath $script:ProfilePath -ProfileSha256 $profileSha -ReadBytes (Get-ReadBytesSeam -Store $store) | Should -Not -BeNullOrEmpty
    }

    It 'classifies edited, evidence-replaced, deleted, appeared and renamed inputs' {
        $store = Get-ByteStore
        $manifest = Get-ManifestFromStore -Store $store -MissingPaths @('docs/absent.yaml', 'src/Orders/Renamed.cs')
        $profileSha = ($manifest['entries'] | Where-Object { $_['path'] -eq $script:ProfilePath })['sha256']
        # Mutate the workspace after the manifest was taken.
        $store['docs/scope.yaml'] = Get-Utf8ByteArray 'scope: changed'
        $store['evidence/run-001.json'] = Get-Utf8ByteArray '{"run":2}'
        $store['src/Orders/Renamed.cs'] = $store['src/Orders/OrderService.cs']
        $store.Remove('src/Orders/OrderService.cs')
        $store['docs/absent.yaml'] = Get-Utf8ByteArray 'new: true'

        $result = Compare-DiscoveryInputManifest -Manifest $manifest -WorkspaceRoot $script:Workspace -ProfilePath $script:ProfilePath -ProfileSha256 $profileSha -ReadBytes (Get-ReadBytesSeam -Store $store)

        Get-DriftKindList -Result $result | Should -Be @(
            'edited:docs/scope.yaml',
            'evidence-replaced:evidence/run-001.json',
            'deleted:src/Orders/OrderService.cs',
            'appeared:docs/absent.yaml',
            'renamed:src/Orders/Renamed.cs'
        )
        ($result.Drift | Where-Object { $_.kind -eq 'renamed' }).detail | Should -Be 'moved from src/Orders/OrderService.cs'
        $result.Manifest['missing_paths'] | Should -BeNullOrEmpty
        $result.Manifest['sha256'] | Should -Not -Be $manifest['sha256']
    }

    It 'names a profile that was not read or whose digest differs from the activation' {
        $store = Get-ByteStore
        $manifest = Get-ManifestFromStore -Store $store
        $seam = Get-ReadBytesSeam -Store $store

        $differs = Compare-DiscoveryInputManifest -Manifest $manifest -WorkspaceRoot $script:Workspace -ProfilePath $script:ProfilePath -ProfileSha256 ('f' * 64) -ReadBytes $seam
        $absent = Compare-DiscoveryInputManifest -Manifest $manifest -WorkspaceRoot $script:Workspace -ProfilePath 'docs/other-profile.yaml' -ProfileSha256 ('f' * 64) -ReadBytes $seam

        Get-DriftKindList -Result $differs | Should -Be @("profile-changed:$($script:ProfilePath)")
        $differs.Drift[0].detail | Should -BeLike 'profile digest * differs from activation ffff*'
        $absent.Drift[0].detail | Should -Be 'profile was not among the inputs read'
    }

    It 'fails closed with INPUT_DRIFT naming every moved input' {
        $store = Get-ByteStore
        $manifest = Get-ManifestFromStore -Store $store
        $profileSha = ($manifest['entries'] | Where-Object { $_['path'] -eq $script:ProfilePath })['sha256']
        $store.Remove('docs/scope.yaml')

        { Assert-DiscoveryInputsFresh -Manifest $manifest -WorkspaceRoot $script:Workspace -ProfilePath $script:ProfilePath -ProfileSha256 $profileSha -ReadBytes (Get-ReadBytesSeam -Store $store) } |
            Should -Throw -ExpectedMessage 'INPUT_DRIFT: Inputs changed after the runtime result: deleted:docs/scope.yaml'
    }

    It 'joins workspace-relative paths with forward slashes regardless of trailing separators' {
        Get-DiscoveryWorkspacePath -WorkspaceRoot 'C:\repo\' -RelativePath 'docs/x.yaml' | Should -Be 'C:\repo/docs/x.yaml'
        Get-DiscoveryWorkspacePath -WorkspaceRoot '/repo' -RelativePath 'docs/x.yaml' | Should -Be '/repo/docs/x.yaml'
    }
}
