Set-StrictMode -Version Latest

# Contract suite for the committed docs-only allowlist config/ci-docs-only-paths.json (issue #962, AC-15).
#
# The file is read as text and parsed with ConvertFrom-Json in BeforeAll; the change-scope module is not
# imported, so these rows pin the committed file itself. A missing or malformed file fails the BeforeAll
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

    It 'starts every include prefix with docs/ (AC-15)' {
        # Arrange / Act: collect any include prefix that does not start with docs/ (ordinal comparison).
        $outside = @($script:IncludePrefixes | Where-Object { -not $_.StartsWith('docs/', [StringComparison]::Ordinal) })

        # Assert
        $outside.Count | Should -Be 0 -Because "every include prefix must stay under docs/; found: $($outside -join ', ')"
    }

    It 'does not let any include prefix cover <Path> (AC-15)' -ForEach @(
        @{ Path = 'docs/features/templates/' }
        @{ Path = 'docs/engineering/' }
        @{ Path = 'docs/discovery/' }
    ) {
        # Arrange / Act: a prefix covers the path when either one starts with the other.
        $covering = @($script:IncludePrefixes | Where-Object { $Path.StartsWith($_, [StringComparison]::Ordinal) -or $_.StartsWith($Path, [StringComparison]::Ordinal) })

        # Assert
        $covering.Count | Should -Be 0 -Because "$Path must not be allowlisted; covering prefixes: $($covering -join ', ')"
    }

    It 'lists <Prefix> as an exclude prefix (AC-15)' -ForEach @(
        @{ Prefix = 'docs/features/templates/' }
        @{ Prefix = 'docs/features/potential/template.md' }
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
        $includeText | Should -BeExactly 'docs/features/active/,docs/features/completed/,docs/features/potential/,docs/research/' -Because 'the include prefixes are fixed by spec decision D3'
        $extensionText | Should -BeExactly '.json,.log,.md,.txt,.xml' -Because 'the extensions are fixed by spec decision D3'
    }
}
