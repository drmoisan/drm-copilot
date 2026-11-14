#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Neutrality test: no configured consumer identifier appears in the docs framework files.

.DESCRIPTION
    Consumer identifiers are configured only as lowercase hex SHA-256 digests of their lowercase
    forms, never as text. Find-DocsIdentifierDigest lowercases each file, enumerates maximal
    [a-z0-9]+ runs and maximal [a-z0-9]+(?:[-_.][a-z0-9]+)+ compounds, hashes each candidate
    with Get-DocsSha256Hex and returns the (path, digest) pairs that match a configured digest.
    One test runs per file under .claude/lib/docs/, schemas/docs/ and examples/docs/, each read
    once into memory. A positive control proves the helper detects a synthetic identifier.
#>

BeforeDiscovery {
    $repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:NeutralityFiles = @(foreach ($folder in '.claude/lib/docs', 'schemas/docs', 'examples/docs') {
            Get-ChildItem -LiteralPath (Join-Path -Path $repositoryRoot -ChildPath $folder) -File -Recurse |
                ForEach-Object { [System.IO.Path]::GetRelativePath($repositoryRoot, $_.FullName).Replace('\', '/') }
            }) | Sort-Object
    }

    BeforeAll {
        $script:RepositoryRootPath = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
        Import-Module -Name (Join-Path -Path $script:RepositoryRootPath -ChildPath '.claude/lib/docs/DocsJson.psm1') -Force -ErrorAction Stop

        # Lowercase hex SHA-256 digests of the lowercase consumer identifier forms (spec
        # ## Implementation Strategy); the identifier text is never recorded.
        $script:ConsumerIdentifierSha256 = @(
            'bbddb9f7a8340215503f6089cb5364689432a9cfb261cd7683c4fe2f20760f6b'
            '59f0db478528b4c446cfaf3d5b8a358dc500a6d97b29a215ee8c216a2f7174e2'
        )

        function Find-DocsIdentifierDigest {
            # Pure: returns one (path, digest) pair per configured digest found in a file text.
            param(
                [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $FileText,
                [Parameter(Mandatory = $true)] [string[]] $Digest
            )
            $wanted = [System.Collections.Generic.HashSet[string]]::new([string[]] $Digest, [System.StringComparer]::Ordinal)
            $found = [System.Collections.Generic.List[object]]::new()
            foreach ($path in @($FileText.Keys | Sort-Object)) {
                $text = ([string] $FileText[$path]).ToLowerInvariant()
                $candidates = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
                foreach ($pattern in '[a-z0-9]+', '[a-z0-9]+(?:[-_.][a-z0-9]+)+') {
                    foreach ($match in [regex]::Matches($text, $pattern)) { [void]$candidates.Add($match.Value) }
                }
                foreach ($candidate in $candidates) {
                    $hash = Get-DocsSha256Hex -Text $candidate
                    if ($wanted.Contains($hash)) { $found.Add([pscustomobject]@{ Path = [string] $path; Digest = $hash }) }
                }
            }
            , $found.ToArray()
        }

        $script:FileText = @{}
        foreach ($folder in '.claude/lib/docs', 'schemas/docs', 'examples/docs') {
            foreach ($file in Get-ChildItem -LiteralPath (Join-Path -Path $script:RepositoryRootPath -ChildPath $folder) -File -Recurse) {
                $relative = [System.IO.Path]::GetRelativePath($script:RepositoryRootPath, $file.FullName).Replace('\', '/')
                $script:FileText[$relative] = [System.IO.File]::ReadAllText($file.FullName)
            }
        }
    }

    AfterAll {
        Remove-Module -Name DocsJson, DiscoveryEncoding -Force -ErrorAction SilentlyContinue
    }

    Describe 'Consumer identifier digests' {
        It 'holds a non-empty list of lowercase hex SHA-256 digests' {
            $script:ConsumerIdentifierSha256.Count | Should -BeGreaterThan 0
            foreach ($digest in $script:ConsumerIdentifierSha256) { $digest | Should -Match '^[0-9a-f]{64}$' }
        }

        It 'detects a synthetic identifier injected into an in-memory file map (positive control)' {
            # Arrange
            $synthetic = 'zqxsyntheticconsumer'
            $digest = Get-DocsSha256Hex -Text $synthetic
            $compoundDigest = Get-DocsSha256Hex -Text "$synthetic-tool"
            $map = @{ 'a/clean.txt' = 'nothing to see'; 'a/dirty.txt' = "Prefix ZQXSyntheticConsumer-tool suffix" }

            # Act
            $found = Find-DocsIdentifierDigest -FileText $map -Digest @($digest, $compoundDigest)

            # Assert
            $found.Count | Should -Be 2
            @($found | ForEach-Object { $_.Path } | Select-Object -Unique) | Should -Be @('a/dirty.txt')
        }
    }

    Describe 'Docs framework files' {
        It 'reads a non-empty file set from the three scanned folders' {
            $script:FileText.Count | Should -BeGreaterThan 0
            @($script:FileText.Keys | Where-Object { $_ -like 'schemas/docs/*' }).Count | Should -BeGreaterThan 0
        }

        It 'contains no configured consumer identifier in <_>' -ForEach $script:NeutralityFiles {
            # Act
            $found = Find-DocsIdentifierDigest -FileText @{ $_ = $script:FileText[$_] } -Digest $script:ConsumerIdentifierSha256

            # Assert
            $found.Count | Should -Be 0
        }
    }
