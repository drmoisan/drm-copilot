#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Tests for DevelopmentDocsRoot.psm1 (issue #1035).

.DESCRIPTION
    Resolution rules are titled by spec ID (R-1 to R-8), parser and formatter cases by
    F-1 to F-6 and N-1 to N-5. The resolver reads only through injected script blocks
    with in-memory content; no file is created and the real routing file is never read.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../..')).Path
    Import-Module -Name (Join-Path $script:RepoRoot '.claude/lib/development-docs/DevelopmentDocsRoot.psm1') -Force -ErrorAction Stop

    $script:ConfigPath = '/ws/config/orchestration-routing.json'

    # Build a reader over an in-memory file map; a value of $null for a path means unreadable.
    $script:NewReader = {
        param([hashtable] $Files, [string[]] $Unreadable = @())
        $map = $Files
        $bad = $Unreadable
        return {
            param([string] $Path)
            if ($bad -contains $Path) { throw "EACCES: $Path" }
            if ($map.ContainsKey($Path)) { return $map[$Path] }
            return $null
        }.GetNewClosure()
    }

    # Build a directory probe that records every probed path.
    $script:Probes = [System.Collections.Generic.List[string]]::new()
    $script:NewDirectoryProbe = {
        param([string[]] $Directories = @())
        $dirs = $Directories
        $log = $script:Probes
        return {
            param([string] $Path)
            $log.Add($Path)
            return ($dirs -contains $Path)
        }.GetNewClosure()
    }

    $script:RoutingWith = {
        param([object] $Value)
        return (ConvertTo-Json -InputObject ([ordered]@{ version = 1; development_docs_root = $Value }) -Compress)
    }
}

Describe 'Resolve-DevelopmentDocsRoot' {
    BeforeEach { $script:Probes.Clear() }

    It 'R-1 resolves docs/features when the routing file is absent' {
        # Arrange
        $read = & $script:NewReader @{}
        # Act
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe)
        # Assert
        $result.Succeeded | Should -BeTrue
        $result.Root | Should -Be 'docs/features'
        $script:Probes.Count | Should -Be 0
    }

    It 'R-1 resolves docs/features when the routing file is unreadable' {
        $read = & $script:NewReader @{} @($script:ConfigPath)
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe)
        $result.Succeeded | Should -BeTrue
        $result.Root | Should -Be 'docs/features'
    }

    It 'R-2 resolves docs/features when the key is absent and never probes .dev' {
        $read = & $script:NewReader @{ $script:ConfigPath = '{"version":1}' }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe @('/ws/.dev'))
        $result.Root | Should -Be 'docs/features'
        $script:Probes.Count | Should -Be 0
    }

    It 'R-2 compares the key ordinally' {
        $read = & $script:NewReader @{ $script:ConfigPath = '{"Development_Docs_Root":".dev"}' }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe @('/ws/.dev'))
        $result.Root | Should -Be 'docs/features'
    }

    It 'R-3 fails with a reason naming the file, key and value for malformed JSON' {
        $read = & $script:NewReader @{ $script:ConfigPath = '{ not json' }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe)
        $result.Succeeded | Should -BeFalse
        $result.Root | Should -BeNullOrEmpty
        $result.Reason | Should -Match 'config/orchestration-routing\.json is not valid JSON, so development_docs_root cannot be read \(value: unparseable;'
    }

    It 'R-3 fails with a reason naming the file, key and value for a non-object document' {
        $read = & $script:NewReader @{ $script:ConfigPath = '[1]' }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe)
        $result.Succeeded | Should -BeFalse
        $result.Reason | Should -Be 'config/orchestration-routing.json is not a JSON object, so development_docs_root cannot be read (value: [1]).'
    }

    It 'R-4 fails with a reason naming the file, key and value for <Label>' -ForEach @(
        @{ Label = 'other string'; Json = '"docs/other"' }
        @{ Label = 'blank'; Json = '"  "' }
        @{ Label = 'non-string'; Json = '7' }
        @{ Label = 'backslash'; Json = '"docs\\features"' }
        @{ Label = 'leading slash'; Json = '"/docs/features"' }
        @{ Label = 'dot-dot segment'; Json = '"../.dev"' }
        @{ Label = 'null'; Json = 'null' }
    ) {
        # Arrange
        $read = & $script:NewReader @{ $script:ConfigPath = "{`"development_docs_root`":$Json}" }
        # Act
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe)
        # Assert
        $result.Succeeded | Should -BeFalse
        $result.Root | Should -BeNullOrEmpty
        $result.Reason | Should -Be "config/orchestration-routing.json development_docs_root value $Json is not one of: docs/features, .dev."
    }

    It 'R-5 resolves docs/features for value docs/features whether or not .dev exists' {
        $read = & $script:NewReader @{ $script:ConfigPath = (& $script:RoutingWith 'docs/features') }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe @('/ws/.dev'))
        $result.Root | Should -Be 'docs/features'
        $script:Probes.Count | Should -Be 0
    }

    It 'R-6 resolves .dev for value .dev when .dev exists' {
        $read = & $script:NewReader @{ $script:ConfigPath = (& $script:RoutingWith '.dev') }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe @('/ws/.dev'))
        $result.Root | Should -Be '.dev'
    }

    It 'R-7 falls back to docs/features for value .dev when only docs/features exists' {
        $read = & $script:NewReader @{ $script:ConfigPath = (& $script:RoutingWith '.dev') }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe @('/ws/docs/features'))
        $result.Root | Should -Be 'docs/features'
    }

    It 'R-8 resolves .dev for value .dev when neither directory exists' {
        $read = & $script:NewReader @{ $script:ConfigPath = (& $script:RoutingWith '.dev') }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '/ws' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe)
        $result.Root | Should -Be '.dev'
        @($script:Probes) | Should -Be @('/ws/.dev', '/ws/docs/features')
    }

    It 'joins a backslash workspace root with forward slashes' {
        $read = & $script:NewReader @{ 'C:/ws/config/orchestration-routing.json' = (& $script:RoutingWith '.dev') }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot 'C:\ws\' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe @('C:/ws/.dev'))
        $result.Root | Should -Be '.dev'
    }

    It 'reads the config at an empty workspace root as a relative path' {
        $read = & $script:NewReader @{ 'config/orchestration-routing.json' = (& $script:RoutingWith '.dev') }
        $result = Resolve-DevelopmentDocsRoot -WorkspaceRoot '' -ReadText $read -TestDirectory (& $script:NewDirectoryProbe @('.dev'))
        $result.Root | Should -Be '.dev'
    }
}

Describe 'Get-DevelopmentDocsPath' {
    BeforeDiscovery {
        $script:AreaRows = @(
            @{ Area = 'active'; Docs = 'docs/features/active'; Dev = '.dev/active' }
            @{ Area = 'completed'; Docs = 'docs/features/completed'; Dev = '.dev/completed' }
            @{ Area = 'archive'; Docs = 'docs/features/archive'; Dev = '.dev/archive' }
            @{ Area = 'potential'; Docs = 'docs/features/potential'; Dev = '.dev/potential' }
            @{ Area = 'potential/promoted'; Docs = 'docs/features/potential/promoted'; Dev = '.dev/potential/promoted' }
            @{ Area = 'epics'; Docs = 'docs/features/epics'; Dev = '.dev/epics' }
            @{ Area = 'parallel'; Docs = 'docs/features/parallel'; Dev = '.dev/parallel' }
            @{ Area = 'templates'; Docs = 'docs/features/templates'; Dev = '.dev/templates' }
            @{ Area = 'backlog'; Docs = 'docs/features/backlog.md'; Dev = '.dev/backlog.md' }
            @{ Area = 'research'; Docs = 'docs/research'; Dev = '.dev/research' }
            @{ Area = 'discovery-templates'; Docs = 'docs/discovery/templates'; Dev = '.dev/discovery/templates' }
            @{ Area = 'engineering'; Docs = 'docs/engineering'; Dev = '.dev/engineering' }
        )
    }

    It 'maps area <Area> under both roots' -ForEach $script:AreaRows {
        Get-DevelopmentDocsPath -Root 'docs/features' -Area $Area | Should -Be $Docs
        Get-DevelopmentDocsPath -Root '.dev' -Area $Area | Should -Be $Dev
    }

    It 'returns both root forms of area <Area> as prefixes' -ForEach $script:AreaRows {
        $suffix = if ($Area -eq 'backlog') { '' } else { '/' }
        $prefix = @(Get-DevelopmentDocsKnownRootPrefix -Area $Area)
        $prefix | Should -Be @("$Docs$suffix", "$Dev$suffix")
    }

    It 'pattern -Area <Area> matches both roots and both separators' -ForEach $script:AreaRows {
        # Arrange
        $pattern = Get-DevelopmentDocsKnownRootPattern -Area $Area
        $tail = if ($Area -eq 'backlog') { '' } else { '/x' }
        # Act / Assert: both area-map paths, with either separator.
        foreach ($path in @("$Docs$tail", "$Dev$tail")) {
            $path | Should -Match $pattern
            ($path -replace '/', '\') | Should -Match $pattern
        }
        # Assert: the path of a different area that is not nested under this one is rejected.
        foreach ($row in $script:AreaRows) {
            $other = $row.Area
            $nested = ($other -eq $Area) -or $other.StartsWith("$Area/") -or $Area.StartsWith("$other/")
            if (-not $nested) {
                "$($row.Docs)/x" | Should -Not -Match $pattern
                "$($row.Dev)/x" | Should -Not -Match $pattern
            }
        }
    }

    It 'unknown area raises the area-map error' {
        { Get-DevelopmentDocsPath -Root '.dev' -Area 'nope' } | Should -Throw 'Unknown development docs area: nope'
        { Get-DevelopmentDocsKnownRootPrefix -Area 'nope' } | Should -Throw 'Unknown development docs area: nope'
    }

    It 'unknown root raises an explicit error' {
        { Get-DevelopmentDocsPath -Root 'docs' -Area 'active' } | Should -Throw 'Unknown development docs root: docs'
    }

    It 'pattern -Area rejects an unknown area' {
        { Get-DevelopmentDocsKnownRootPattern -Area 'nope' } | Should -Throw 'Unknown development docs area: nope'
    }

    It 'pattern without -Area matches the root alternation' {
        $pattern = Get-DevelopmentDocsKnownRootPattern
        foreach ($path in @('docs/features/x', 'docs\features\x', '.dev/x', '.dev\x')) {
            $path | Should -Match $pattern
        }
        'docs/research/x' | Should -Not -Match $pattern
    }

    It 'returns the known roots in order' {
        $roots = Get-DevelopmentDocsKnownRoot
        $roots | Should -Be @('docs/features', '.dev')
        $roots.Count | Should -Be 2
    }
}

Describe 'ConvertFrom-FeatureFolderName' {
    It '<Id> parses <Name>' -ForEach @(
        @{ Id = 'F-1'; Name = '2026-10-30-foo-bar-1016'; Format = 'date-first'; Date = '2026-10-30'; Feature = 'foo-bar'; Issue = 1016 }
        @{ Id = 'F-2'; Name = '2026-10-30-foo-bar'; Format = 'date-first'; Date = '2026-10-30'; Feature = 'foo-bar'; Issue = $null }
        @{ Id = 'F-3'; Name = '1016-foo-bar'; Format = 'issue-first'; Date = $null; Feature = 'foo-bar'; Issue = 1016 }
        @{ Id = 'F-4'; Name = '0042-foo-bar'; Format = 'issue-first'; Date = $null; Feature = 'foo-bar'; Issue = 42 }
        @{ Id = 'F-5'; Name = 'subagentstop-envelope-core-897'; Format = 'other'; Date = $null; Feature = 'subagentstop-envelope-core'; Issue = 897 }
        @{ Id = 'F-6'; Name = 'notes-feature'; Format = 'other'; Date = $null; Feature = 'notes-feature'; Issue = $null }
        @{ Id = 'zero issue'; Name = '0000-foo'; Format = 'other'; Date = $null; Feature = '0000-foo'; Issue = $null }
    ) {
        $parsed = ConvertFrom-FeatureFolderName -Name $Name
        $parsed.Format | Should -Be $Format
        $parsed.Date | Should -Be $Date
        $parsed.Feature | Should -Be $Feature
        $parsed.IssueNumber | Should -Be $Issue
    }
}

Describe 'ConvertTo-FeatureFolderName' {
    It 'N-1 formats a four-digit issue' {
        ConvertTo-FeatureFolderName -IssueNumber 1016 -Feature 'move-development-docs' | Should -Be '1016-move-development-docs'
    }

    It 'N-2 pads a small issue to four digits' {
        ConvertTo-FeatureFolderName -IssueNumber 42 -Feature 'notes' | Should -Be '0042-notes'
    }

    It 'N-3 rejects a <Label> issue number' -ForEach @(
        @{ Label = 'zero'; Issue = 0 }
        @{ Label = 'negative'; Issue = -3 }
        @{ Label = 'non-integer'; Issue = 4.5 }
    ) {
        { ConvertTo-FeatureFolderName -IssueNumber $Issue -Feature 'notes' } | Should -Throw '*must be a positive integer*'
    }

    It 'N-4 rejects an issue above 9999' {
        { ConvertTo-FeatureFolderName -IssueNumber 10000 -Feature 'notes' } | Should -Throw '*must be at most 9999*'
    }

    It 'N-5 rejects a feature that is <Label>' -ForEach @(
        @{ Label = 'empty'; Feature = '' }
        @{ Label = 'pattern failure'; Feature = 'Bad Name' }
        @{ Label = 'partial date prefix'; Feature = '10-30-foo' }
        @{ Label = 'date only'; Feature = '2026-10-30-' }
    ) {
        { ConvertTo-FeatureFolderName -IssueNumber 7 -Feature $Feature } | Should -Throw '*Feature folder feature name is invalid*'
    }

    It 'removes the date-first prefix and a trailing issue' {
        ConvertTo-FeatureFolderName -IssueNumber 1016 -Feature '2026-10-30-foo-1016' | Should -Be '1016-foo'
    }

    It 'keeps a trailing number that is not the issue' {
        ConvertTo-FeatureFolderName -IssueNumber 5 -Feature 'foo-12' | Should -Be '0005-foo-12'
    }
}
