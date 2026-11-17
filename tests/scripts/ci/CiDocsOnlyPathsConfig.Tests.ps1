Set-StrictMode -Version Latest

# Contract suite for the committed docs-only allowlist config/ci-docs-only-paths.json (issue #962, AC-15).
#
# The file is read as text and parsed with ConvertFrom-Json in BeforeAll; the first Describe does not import
# the change-scope module, so its rows pin the committed file itself. The second Describe (issue #1035)
# parses the same file through ConvertFrom-CiDocsOnlyPathConfig and classifies .dev paths with
# Test-CiDocsOnlyPath. A missing or malformed file fails the BeforeAll
# (-ErrorAction Stop), so no row can pass against an absent config. No process, temporary file, or network
# call is made.

Describe 'config/ci-docs-only-paths.json docs-only allowlist' {
    BeforeAll {
        $configPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../config/ci-docs-only-paths.json'
        $configText = Get-Content -Raw -LiteralPath $configPath -ErrorAction Stop
        $script:Config = $configText | ConvertFrom-Json -ErrorAction Stop
        $script:IncludePrefixes = [string[]]@($script:Config.include_prefixes)
        $script:ExcludePrefixes = [string[]]@($script:Config.exclude_prefixes)
        $script:Extensions = [string[]]@($script:Config.extensions)
    }

    It 'parses the committed allowlist with version 1 (AC-15)' {
        # Arrange / Act: the config was parsed in BeforeAll.
        $version = $script:Config.version

        # Assert
        $version | Should -Be 1 -Because 'version 1 is the only allowlist schema the change-scope decision accepts'
    }

    It 'starts every include prefix with docs/ or .dev/ (AC-15, #1035)' {
        # Arrange / Act: collect any include prefix outside both development-docs roots (ordinal comparison).
        $outside = @($script:IncludePrefixes | Where-Object { -not ($_.StartsWith('docs/', [StringComparison]::Ordinal) -or $_.StartsWith('.dev/', [StringComparison]::Ordinal)) })

        # Assert
        $outside.Count | Should -Be 0 -Because "every include prefix must stay under docs/ or .dev/; found: $($outside -join ', ')"
    }

    It 'does not let any include prefix cover <Path> (AC-15)' -ForEach @(
        @{ Path = 'docs/features/templates/' }
        @{ Path = 'docs/engineering/' }
        @{ Path = 'docs/discovery/' }
        @{ Path = '.dev/templates/' }
        @{ Path = '.dev/engineering/' }
        @{ Path = '.dev/discovery/' }
    ) {
        # Arrange / Act: a prefix covers the path when either one starts with the other.
        $covering = @($script:IncludePrefixes | Where-Object { $Path.StartsWith($_, [StringComparison]::Ordinal) -or $_.StartsWith($Path, [StringComparison]::Ordinal) })

        # Assert
        $covering.Count | Should -Be 0 -Because "$Path must not be allowlisted; covering prefixes: $($covering -join ', ')"
    }

    It 'lists <Prefix> as an exclude prefix (AC-15)' -ForEach @(
        @{ Prefix = 'docs/features/templates/' }
        @{ Prefix = 'docs/features/potential/template.md' }
        @{ Prefix = '.dev/potential/template.md' }
    ) {
        # Arrange / Act
        $listed = $script:ExcludePrefixes -ccontains $Prefix

        # Assert
        $listed | Should -BeTrue -Because "$Prefix must be excluded from the docs-only allowlist"
    }

    It 'does not configure the code extension <Extension> (AC-15)' -ForEach @(
        @{ Extension = '.py' }
        @{ Extension = '.ps1' }
        @{ Extension = '.psm1' }
        @{ Extension = '.psd1' }
        @{ Extension = '.sh' }
        @{ Extension = '.bats' }
        @{ Extension = '.ts' }
        @{ Extension = '.tsx' }
        @{ Extension = '.js' }
        @{ Extension = '.mjs' }
        @{ Extension = '.cjs' }
        @{ Extension = '.cs' }
        @{ Extension = '.yml' }
        @{ Extension = '.yaml' }
        @{ Extension = '.toml' }
    ) {
        # Arrange / Act: -contains compares case-insensitively, so an upper-case spelling is also caught.
        $configured = $script:Extensions -contains $Extension

        # Assert
        $configured | Should -BeFalse -Because "$Extension is a code extension and must never be docs-only"
    }

    It 'configures exactly the D3 include prefixes and extensions (AC-15)' {
        # Arrange: sort both lists ordinally so the comparison does not depend on file order or culture.
        $include = [string[]]@($script:IncludePrefixes)
        [Array]::Sort($include, [StringComparer]::Ordinal)
        $extensions = [string[]]@($script:Extensions)
        [Array]::Sort($extensions, [StringComparer]::Ordinal)

        # Act
        $includeText = $include -join ','
        $extensionText = $extensions -join ','

        # Assert
        $includeText | Should -BeExactly '.dev/active/,.dev/archive/,.dev/completed/,.dev/epics/,.dev/parallel/,.dev/potential/,.dev/research/,docs/features/active/,docs/features/archive/,docs/features/completed/,docs/features/epics/,docs/features/parallel/,docs/features/potential/,docs/research/' -Because 'the include prefixes are fixed by spec decision D3 of issue #962 as extended by spec decision D5 of issue #973 and by the .dev forms of issue #1035'
        $extensionText | Should -BeExactly '.json,.log,.md,.txt,.xml' -Because 'the extensions are fixed by spec decision D3'
    }

    It 'lists <Prefix> as an include prefix (#973)' -ForEach @(
        @{ Prefix = 'docs/features/archive/' }
        @{ Prefix = 'docs/features/parallel/' }
        @{ Prefix = 'docs/features/epics/' }
        @{ Prefix = '.dev/active/' }
        @{ Prefix = '.dev/archive/' }
        @{ Prefix = '.dev/completed/' }
        @{ Prefix = '.dev/epics/' }
        @{ Prefix = '.dev/parallel/' }
        @{ Prefix = '.dev/potential/' }
        @{ Prefix = '.dev/research/' }
    ) {
        # Arrange / Act: ordinal membership, so a different spelling or case does not count.
        $listed = $script:IncludePrefixes -ccontains $Prefix

        # Assert
        $listed | Should -BeTrue -Because "$Prefix holds feature, archive, parallel-run, epic, potential or research documents that are docs-only (issues #973, #1035)"
    }
}

Describe 'config/ci-docs-only-paths.json classification of .dev paths (#1035)' {
    BeforeAll {
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/ci/CiChangeScope.psm1') -Force -ErrorAction Stop
        $configPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../config/ci-docs-only-paths.json'
        $script:ParsedConfig = ConvertFrom-CiDocsOnlyPathConfig -Json (Get-Content -Raw -LiteralPath $configPath -ErrorAction Stop)
    }

    AfterAll {
        Remove-Module -Name CiChangeScope -ErrorAction SilentlyContinue
    }

    It 'classifies <Path> as docs-only=<Expected>' -ForEach @(
        @{ Path = '.dev/active/x/spec.md'; Expected = $true }
        @{ Path = '.dev/templates/x.md'; Expected = $false }
        @{ Path = '.dev/potential/template.md'; Expected = $false }
        @{ Path = '.dev/engineering/x.md'; Expected = $false }
        @{ Path = '.dev/discovery/x.md'; Expected = $false }
    ) {
        # Arrange: the committed config was parsed by the change-scope module in BeforeAll.
        $config = $script:ParsedConfig

        # Act
        $docsOnly = Test-CiDocsOnlyPath -Path $Path -Config $config

        # Assert
        $docsOnly | Should -Be $Expected -Because "$Path docs-only classification under the committed allowlist must be $Expected"
    }
}
