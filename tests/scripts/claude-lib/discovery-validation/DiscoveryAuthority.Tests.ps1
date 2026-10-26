#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity and fail-closed tests for `.claude/lib/discovery-validation/DiscoveryAuthority.psm1` (issue #980).
.DESCRIPTION
    Replays the shared cross-runtime vectors (tests/fixtures/discovery_authority/
    authority-vectors.json and tests/fixtures/discovery_host/tool-authorizations.json)
    so the PowerShell location, activation-record and canonical-JSON rules agree byte
    for byte with the Python runtime and the TypeScript gateway. Every document under
    test is an in-memory string; the only files read are the committed fixtures. No
    temporary file, process, network or clock is used.
#>

BeforeDiscovery {
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $vectorsPath = Join-Path $repoRoot 'tests/fixtures/discovery_authority/authority-vectors.json'
    $vectors = Get-Content -LiteralPath $vectorsPath -Raw | ConvertFrom-Json -Depth 8
    $hostPath = Join-Path $repoRoot 'tests/fixtures/discovery_host/tool-authorizations.json'
    $hostVectors = Get-Content -LiteralPath $hostPath -Raw | ConvertFrom-Json -Depth 8
    # Hashtable rows let Pester bind $_ for every data-driven It below.
    $script:LocationCases = @($vectors.locations | ForEach-Object { @{ Row = $_ } })
    $script:InvalidLocationCases = @($vectors.invalid_locations | ForEach-Object { @{ Row = $_ } })
    $script:RecordCases = @($vectors.records | ForEach-Object { @{ Row = $_ } })
    $script:InvalidRecordCases = @($vectors.invalid_records | ForEach-Object { @{ Row = $_ } })
    $script:DigestCases = @($hostVectors.digest_vectors | ForEach-Object { @{ Row = $_ } })
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    # The authority module nests its own import of the encoding module; importing
    # the encoding module afterwards makes the shared digest functions visible here.
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/discovery-validation/DiscoveryEncoding.psm1') -Force
    $script:WorkspaceSha256 = '77f077989d4b47c3249dcb4b1f5d5c59fa91f1045e244879660ef1ef212a19b6'

    function Resolve-VectorLocation {
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param([Parameter(Mandatory = $true)]$Row)

        return Resolve-DiscoveryAuthorityLocation -WorkspaceRoot $Row.workspace_root -Platform $Row.platform `
            -UserHome $Row.user_home -LocalAppData $Row.local_app_data -XdgStateHome $Row.xdg_state_home
    }

    $script:ExampleLocation = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot 'C:/Users/Example/Repos/Workspace' `
        -Platform 'windows' -UserHome 'C:/Users/Example' -LocalAppData 'C:/Users/Example/AppData/Local'
}

Describe 'Resolve-DiscoveryAuthorityLocation parity' {
    It 'resolves <Row.platform> <Row.workspace_root> to the shared digest and directory' -ForEach $script:LocationCases {
        # Act
        $location = Resolve-VectorLocation -Row $Row

        # Assert: the three runtimes agree on identity, digest and directory.
        $location.Workspace | Should -Be $Row.workspace
        $location.WorkspaceSha256 | Should -Be $Row.workspace_sha256
        $location.Directory | Should -Be $Row.directory
        $location.Platform | Should -Be $Row.platform
    }

    It 'rejects <Row.platform> <Row.workspace_root> with state <Row.xdg_state_home> before any I/O' -ForEach $script:InvalidLocationCases {
        # Act / Assert: relative roots, parent references, authority inside the
        # workspace and a missing Windows state root are typed failures.
        { Resolve-VectorLocation -Row $Row } | Should -Throw -ExpectedMessage 'AUTHORITY_*'
    }

    It 'requires LocalApplicationData on Windows' {
        { Resolve-DiscoveryAuthorityLocation -WorkspaceRoot 'C:/w' -Platform 'windows' -UserHome 'C:/Users/x' } |
            Should -Throw -ExpectedMessage 'AUTHORITY_STATE_ROOT_MISSING*'
    }

    It 'hashes the lowercase native Windows spelling and preserves POSIX case' {
        $windows = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot 'C:\Users\Example\Repos\Workspace' -Platform 'windows' `
            -UserHome 'C:/Users/Example' -LocalAppData 'C:/Users/Example/AppData/Local'
        $windows.WorkspaceSha256 | Should -Be (Get-DiscoverySha256Hex -Text 'c:\users\example\repos\workspace')
        $linux = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot '/Home/Example/Repo/' -Platform 'linux' -UserHome '/home/example'
        $linux.WorkspaceSha256 | Should -Be (Get-DiscoverySha256Hex -Text '/Home/Example/Repo')
        $linux.Directory | Should -Be "/home/example/.local/state/drm-copilot/discovery/workspaces/$($linux.WorkspaceSha256)"
    }
}

Describe 'Partitions and protected paths' {
    It 'derives digest partitions for sessions and invocations' {
        $session = Get-DiscoverySessionDirectory -Location $script:ExampleLocation -SessionId 'sess:2026-10-22:abc'
        $session | Should -Be "$($script:ExampleLocation.Directory)/sessions/$(Get-DiscoverySha256Hex -Text 'sess:2026-10-22:abc')"
        $invocation = Get-DiscoveryInvocationDirectory -Location $script:ExampleLocation -SessionId 'sess:2026-10-22:abc' -InvocationId 'inv.001'
        $invocation | Should -Be "$session/invocations/$(Get-DiscoverySha256Hex -Text 'inv.001')"
        Get-DiscoveryActivationRecordPath -Location $script:ExampleLocation | Should -Be "$($script:ExampleLocation.Directory)/activation.json"
    }

    It 'rejects partition identifiers that are not correlation ids' {
        { Get-DiscoveryPartitionName -CorrelationId '' } | Should -Throw -ExpectedMessage 'AUTHORITY_PARTITION_INVALID*'
        { Get-DiscoveryPartitionName -CorrelationId '../x' } | Should -Throw -ExpectedMessage 'AUTHORITY_PARTITION_INVALID*'
        { Get-DiscoveryPartitionName -CorrelationId ('a' * 257) } | Should -Throw -ExpectedMessage 'AUTHORITY_PARTITION_INVALID*'
    }

    It 'accepts only paths inside the protected directory and outside the workspace' {
        $directory = $script:ExampleLocation.Directory
        Test-DiscoveryProtectedPath -Location $script:ExampleLocation -Candidate "$directory/sessions/x/receipt.json" | Should -BeTrue
        Test-DiscoveryProtectedPath -Location $script:ExampleLocation -Candidate ($directory.ToUpperInvariant() + '/activation.json') | Should -BeTrue
        Test-DiscoveryProtectedPath -Location $script:ExampleLocation -Candidate 'C:/Users/Example/Repos/Workspace/artifacts/receipt.json' | Should -BeFalse
        Test-DiscoveryProtectedPath -Location $script:ExampleLocation -Candidate 'C:/Users/Example/AppData/Local/drm-copilot/discovery/other.json' | Should -BeFalse
        { Test-DiscoveryProtectedPath -Location $script:ExampleLocation -Candidate 'relative/path' } | Should -Throw -ExpectedMessage 'AUTHORITY_PATH_NOT_CANONICAL*'
    }
}

Describe 'Activation record parity' {
    It 'decodes <Row.name> to the shared record and digest' -ForEach $script:RecordCases {
        # Act
        $record = ConvertFrom-DiscoveryActivationRecord -Text $Row.encoded -WorkspaceSha256 $script:WorkspaceSha256

        # Assert: every member and the encoded digest match the generated vector.
        foreach ($name in @('action', 'locator_sha256', 'previous_sha256', 'profile_path', 'profile_sha256', 'schema_version', 'workspace_sha256')) {
            $record.$name | Should -Be $Row.record.$name -Because "$name must round-trip"
        }
        $record.generation | Should -Be ([int64]$Row.record.generation)
        Get-DiscoverySha256Hex -Text $Row.encoded | Should -Be $Row.encoded_sha256
    }

    It 'rejects <Row.name> with <Row.code>' -ForEach $script:InvalidRecordCases {
        { ConvertFrom-DiscoveryActivationRecord -Text $Row.text -WorkspaceSha256 $script:WorkspaceSha256 } |
            Should -Throw -ExpectedMessage "$($Row.code)*"
    }

    It 'classifies missing, invalid, inactive and active activation state through the read seam' {
        # Arrange: run-time rows are re-read here because discovery-time data is not in scope.
        $records = (Get-Content -LiteralPath (Join-Path $script:RepoRoot 'tests/fixtures/discovery_authority/authority-vectors.json') -Raw | ConvertFrom-Json -Depth 8).records
        $activate = ($records | Where-Object { $_.name -eq 'generation-1-activate' }).encoded
        $tombstone = ($records | Where-Object { $_.name -eq 'generation-4-tombstone' }).encoded
        $activate | Should -Not -BeNullOrEmpty
        $states = foreach ($text in @($null, '{', $tombstone, $activate)) {
            Read-DiscoveryActivationState -Location $script:ExampleLocation -ReadText { param($Path) [void]$Path; $text }.GetNewClosure()
        }
        @($states | ForEach-Object { $_.Status }) | Should -Be @('missing', 'invalid', 'inactive', 'active')
        $states[1].Reason | Should -BeLike 'ACTIVATION_INVALID*'
        $states[3].Record.generation | Should -Be 1
        $states[3].Path | Should -Be (Get-DiscoveryActivationRecordPath -Location $script:ExampleLocation)
    }
}

Describe 'Canonical JSON parity' {
    It 'reproduces the <Row.name> input digest from canonical JSON' -ForEach $script:DigestCases {
        # Arrange: the digest covers {inputs, operation, tool} exactly as the runtime hashes it.
        $payload = [ordered]@{ inputs = $Row.inputs; operation = $Row.operation; tool = $Row.tool }

        # Act / Assert
        Get-DiscoverySha256Hex -Text (ConvertTo-DiscoveryCanonicalJson -Value $payload) | Should -Be $Row.input_sha256
    }

    It 'sorts keys ordinally, keeps non-ASCII literal and escapes controls' {
        $text = ConvertTo-DiscoveryCanonicalJson -Value @{ b = @(1, $true, $null); a = "tab`tnew`nquote`"\`u{00e9}"; Z = 'upper' }
        $text | Should -Be "{`"Z`":`"upper`",`"a`":`"tab\tnew\nquote\`"\\`u{00e9}`",`"b`":[1,true,null]}`n"
    }

    It 'refuses fractional numbers and non-JSON values' {
        { ConvertTo-DiscoveryCanonicalJson -Value @{ a = 1.5 } } | Should -Throw -ExpectedMessage 'AUTHORIZATION_INPUT_INVALID*'
        { ConvertTo-DiscoveryCanonicalJson -Value @{ a = [datetime]::UnixEpoch } } | Should -Throw -ExpectedMessage 'AUTHORIZATION_INPUT_INVALID*'
        ConvertTo-DiscoveryCanonicalJson -Value @{ a = [double]3 } | Should -Be "{`"a`":3}`n"
    }
}

Describe 'Relative path and host environment helpers' {
    It 'accepts workspace-relative paths and rejects roots, traversal and reserved devices' {
        Test-DiscoveryRelativePath -Path "docs/`u{00e9}quipe/Discovery Profile.yaml" | Should -BeTrue
        Test-DiscoveryRelativePath -Path '/abs/path.yaml' | Should -BeFalse
        Test-DiscoveryRelativePath -Path 'docs/../x.yaml' | Should -BeFalse
        Test-DiscoveryRelativePath -Path 'docs/CON.txt' | Should -BeFalse
        Test-DiscoveryRelativePath -Path 'C:/x.yaml' | Should -BeFalse
        Test-DiscoveryRelativePath -Path '' | Should -BeFalse
    }

    It 'returns the injected host environment without reading the machine' {
        $environment = Get-DiscoveryTrustedHostEnvironment -Platform 'linux' -UserHome '/home/x' -LocalAppData '' -XdgStateHome '/state'
        $environment.Platform | Should -Be 'linux'
        $environment.UserHome | Should -Be '/home/x'
        $environment.XdgStateHome | Should -Be '/state'
        (Get-DiscoveryTrustedHostEnvironment).Platform | Should -BeIn @('windows', 'macos', 'linux')
    }

    It 'applies the host defaults when the state roots are omitted or empty (issue #980 installed smoke)' {
        # An omitted [string] parameter arrives as an empty string; the Windows state root must
        # still resolve to the known folder, otherwise every real hook run fails closed with
        # AUTHORITY_STATE_ROOT_MISSING while the injected unit tests keep passing.
        $omitted = Get-DiscoveryTrustedHostEnvironment
        $empty = Get-DiscoveryTrustedHostEnvironment -LocalAppData '' -XdgStateHome ''
        $omitted.UserHome | Should -Not -BeNullOrEmpty
        if ($IsWindows) {
            $omitted.LocalAppData | Should -Be ([System.Environment]::GetFolderPath('LocalApplicationData'))
            $empty.LocalAppData | Should -Be $omitted.LocalAppData
            $omitted.LocalAppData | Should -Not -BeNullOrEmpty
        }
        $empty.XdgStateHome | Should -Be ([string]$env:XDG_STATE_HOME)
    }
}
