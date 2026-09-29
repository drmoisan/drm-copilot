<#
.SYNOPSIS
    Unit tests for the pure parallel drift-detection module.

.DESCRIPTION
    Covers .claude/lib/parallel-drift/ParallelDrift.psm1 (issue #763), the
    PowerShell port of the checkpoint readers in
    scripts/dev_tools/_parallel_drift_cli_io.py, the detection and recomputation
    functions of scripts/dev_tools/parallel_drift_detection.py and
    scripts/dev_tools/_parallel_drift_scheduling.py, and evaluate_drift. Every
    checkpoint and truth table is an inline, ordinal (case-sensitive) hashtable;
    no file other than the module under test is read, no temporary file is
    created, and no external process is started.
#>

BeforeAll {
    # Resolve the module four levels up: parallel-drift -> claude-lib -> scripts
    # -> tests -> repo root, then into .claude/lib/parallel-drift.
    $script:ModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/parallel-drift/ParallelDrift.psm1").Path
    Import-Module $script:ModulePath -Force -ErrorAction Stop

    # Build an ordinal (case-sensitive) hashtable from alternating keys and values.
    function New-OrdinalTable {
        param([object[]] $Pair)
        $table = [hashtable]::new([System.StringComparer]::Ordinal)
        for ($index = 0; $index -lt $Pair.Count; $index += 2) { $table[[string]$Pair[$index]] = $Pair[$index + 1] }
        return $table
    }

    # The C1 base truth table: one shared surface and two module globs.
    function New-TestConfig {
        $modules = New-OrdinalTable -Pair @('python-dev-tools', @('scripts/dev_tools/**'), 'mcp-server', @('packages/mcp-server/**'))
        return New-OrdinalTable -Pair @('shared_surfaces', @('.claude/settings.json'), 'shared_surface_globs', @(), 'modules', $modules)
    }

    # A declared radius over the given paths, in the six-key invariant-9 shape.
    function New-TestRadius {
        param([string[]] $Path, [string] $ComputedAt = '2026-08-08T09-00')
        return New-OrdinalTable -Pair @('paths', @($Path), 'modules', @(), 'shared_surfaces', @(), 'contracts', @(),
            'source', 'declared', 'computed_at', $ComputedAt)
    }

    # One in-flight item record; the radius may be replaced by any value.
    function New-TestItem {
        param([long] $ItemKey, [object] $Radius, [string] $State = 'in_flight')
        return New-OrdinalTable -Pair @('issue_num', $ItemKey, 'state', $State, 'blast_radius', $Radius)
    }

    # A checkpoint holding the given items and edges.
    function New-TestState {
        param([object[]] $Item, [object[]] $Edge = @())
        return New-OrdinalTable -Pair @('items', $Item, 'conflict_edges', $Edge)
    }

    $script:Config = New-TestConfig
    $script:Drifter = New-TestItem -ItemKey 446 -Radius (New-TestRadius -Path @('scripts/dev_tools/**'))
}

Describe 'ParallelDrift.psm1' {
    It 'imports the blast-radius library and defines none of its functions' {
        # Arrange
        $text = Get-Content -LiteralPath $script:ModulePath -Raw
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:ModulePath, [ref] $null, [ref] $null)
        $defined = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
                ForEach-Object { $_.Name })
        $library = @('Test-PathSubsumed', 'Get-BlastRadiusFromObservedPaths', 'Test-BlastRadiusConflict',
            'Get-BlastRadiusPairDecision', 'ConvertTo-NormalizedBlastRadius', 'Get-OrdinalSortedEntry')

        # Assert
        $text.Contains('../blast-radius/BlastRadius.psm1') | Should -BeTrue
        @($defined | Where-Object { $library -contains $_ }) | Should -BeNullOrEmpty
    }

    It 'calls the subsumption, observed-radius, conflict, and pair-decision functions' {
        # Arrange
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:ModulePath, [ref] $null, [ref] $null)
        $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) |
                ForEach-Object { $_.GetCommandName() })
        $references = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] }, $true) |
                ForEach-Object { $_.VariablePath.UserPath })

        # Assert
        $commands | Should -Contain 'Test-PathSubsumed'
        $commands | Should -Contain 'Get-BlastRadiusFromObservedPaths'
        $commands | Should -Contain 'Get-BlastRadiusPairDecision'
        $references | Should -Contain 'function:Test-BlastRadiusConflict'
    }

    It 'Get-ParallelDriftCheckpointItem rejects a non-list items collection' {
        $state = New-OrdinalTable -Pair @('items', (New-OrdinalTable -Pair @('446', @{})), 'conflict_edges', @())

        { Get-ParallelDriftCheckpointItem -State $state } | Should -Throw '*items must be a list*'
    }

    It 'Get-ParallelDriftCheckpointItem rejects a non-object items entry' {
        $state = New-TestState -Item @(5)

        { Get-ParallelDriftCheckpointItem -State $state } | Should -Throw '*items`[`] entries must be objects*'
    }

    It 'Get-ParallelDriftCheckpointItem returns every object entry in order' {
        $items = Get-ParallelDriftCheckpointItem -State (New-TestState -Item @($script:Drifter))

        $items.Count | Should -Be 1
        $items[0]['issue_num'] | Should -Be 446
    }

    It 'Get-ParallelDriftCheckpointEdge rejects a non-list conflict_edges collection' {
        $state = New-OrdinalTable -Pair @('items', @(), 'conflict_edges', 'none')

        { Get-ParallelDriftCheckpointEdge -State $state } | Should -Throw '*conflict_edges must be a list*'
    }

    It 'Get-ParallelDriftCheckpointEdge omits a non-object edge' {
        $edge = New-OrdinalTable -Pair @('a', [long]445, 'b', [long]446)

        $edges = Get-ParallelDriftCheckpointEdge -State (New-TestState -Item @() -Edge @('445-446', $edge))

        $edges.Count | Should -Be 1
        $edges[0]['a'] | Should -Be 445
    }

    It 'Get-ParallelDriftItemRecord rejects an item key absent from the checkpoint' {
        { Get-ParallelDriftItemRecord -Item @($script:Drifter) -ItemKey 999 } |
            Should -Throw '*records no items`[`] entry with issue_num 999*'
    }

    It 'Get-ParallelDriftDeclaredPath rejects a non-object blast_radius' {
        { Get-ParallelDriftDeclaredPath -Item (New-TestItem -ItemKey 446 -Radius 1) } |
            Should -Throw '*blast_radius must be an object*'
    }

    It 'Get-ParallelDriftDeclaredPath rejects a non-list paths value' {
        $radius = New-OrdinalTable -Pair @('paths', 'src/app.py')

        { Get-ParallelDriftDeclaredPath -Item (New-TestItem -ItemKey 446 -Radius $radius) } |
            Should -Throw '*blast_radius.paths must be a list*'
    }

    It 'Get-ParallelDriftEscapedPath returns an empty array when every path is subsumed' {
        # Act
        $escaped = Get-ParallelDriftEscapedPath -ChangedPath @('scripts/dev_tools/a.py') -DeclaredPath @('scripts/dev_tools/**')

        # Assert
        , $escaped | Should -BeOfType [string[]]
        $escaped.Count | Should -Be 0
    }

    It 'Get-ParallelDriftEscapedPath returns the paths no declared entry covers' {
        $escaped = Get-ParallelDriftEscapedPath -ChangedPath @('src/b.py', 'docs', 'src/a.py', 'docs/x.md') -DeclaredPath @('docs')

        $escaped | Should -Be @('src/a.py', 'src/b.py')
    }

    It 'Get-ParallelDriftEvent carries exactly the six drift-event keys' {
        # Act
        $driftEvent = Get-ParallelDriftEvent -ItemKey 446 -DeclaredPath @('scripts/**') -ObservedPath @('src/app.py') `
            -EscapedPath @('src/app.py') -At '2026-08-08T10-00' -Action 'raised_blocking_finding'

        # Assert
        @($driftEvent.Keys) | Should -Be @('item_key', 'declared', 'observed', 'escaped_paths', 'at', 'action')
        $driftEvent['escaped_paths'] | Should -Be @('src/app.py')
    }

    It 'Get-ParallelDriftEvent rejects an empty escaped-path list' {
        { Get-ParallelDriftEvent -ItemKey 446 -DeclaredPath @() -ObservedPath @() -EscapedPath @() -At 'x' -Action 'raised_blocking_finding' } |
            Should -Throw '*escaped_paths must not be empty*'
    }

    It 'Get-ParallelDriftExistingEdgePair canonicalizes a reversed edge' {
        $edge = New-OrdinalTable -Pair @('a', [long]446, 'b', [long]445)

        $pairs = Get-ParallelDriftExistingEdgePair -Edge @($edge)

        $pairs.Count | Should -Be 1
        $pairs[0] | Should -Be @(445, 446)
    }

    It 'Get-ParallelDriftExistingEdgePair omits an edge with identical endpoints' {
        $same = New-OrdinalTable -Pair @('a', [long]445, 'b', [long]445)
        $unreadable = New-OrdinalTable -Pair @('a', 'x', 'b', [long]445)

        $pairs = Get-ParallelDriftExistingEdgePair -Edge @($same, $unreadable)

        $pairs.Count | Should -Be 0
    }

    It 'Get-ParallelDriftItemBand returns null for an unreadable band' {
        # Arrange
        $banded = New-TestItem -ItemKey 445 -Radius $null
        $banded['complexity_band'] = 'C2'
        $unreadable = New-TestItem -ItemKey 447 -Radius $null
        $unreadable['complexity_band'] = 'C9'

        # Act / Assert
        Get-ParallelDriftItemBand -Item @($banded, $unreadable) -ItemKey 447 | Should -BeNullOrEmpty
        Get-ParallelDriftItemBand -Item @($banded, $unreadable) -ItemKey 999 | Should -BeNullOrEmpty
        Get-ParallelDriftItemBand -Item @($banded, $unreadable) -ItemKey 445 | Should -BeExactly 'C2'
    }

    It 'Test-ParallelDriftObservedPairEdge fails closed for a non-object peer radius' {
        $observed = Get-ParallelDriftObservedRadius -ObservedPath @('docs/notes.md') -Config $script:Config -ComputedAt '2026-08-08T10-05'

        Test-ParallelDriftObservedPairEdge -ObservedRadius $observed -PeerRadius 'not-a-radius' -Config $script:Config | Should -BeTrue
    }

    It 'Test-ParallelDriftObservedPairEdge fails closed for an unparseable peer radius' {
        $observed = Get-ParallelDriftObservedRadius -ObservedPath @('docs/notes.md') -Config $script:Config -ComputedAt '2026-08-08T10-05'
        $peer = New-OrdinalTable -Pair @('paths', @('src/app.py'))

        Test-ParallelDriftObservedPairEdge -ObservedRadius $observed -PeerRadius $peer -Config $script:Config | Should -BeTrue
    }

    It 'Test-ParallelDriftObservedPairEdge reports no edge for a disjoint peer radius' {
        $observed = Get-ParallelDriftObservedRadius -ObservedPath @('docs/notes.md') -Config $script:Config -ComputedAt '2026-08-08T10-05'

        Test-ParallelDriftObservedPairEdge -ObservedRadius $observed -PeerRadius (New-TestRadius -Path @('src/app.py')) -Config $script:Config |
            Should -BeFalse
    }

    It 'Get-ParallelDriftNewConflictPair skips a peer that is not in flight' {
        $peer = New-TestItem -ItemKey 445 -Radius (New-TestRadius -Path @('src/app.py')) -State 'withdrawn'

        $pairs = Get-ParallelDriftNewConflictPair -Item @($script:Drifter, $peer) -DriftingItemKey 446 -ObservedPath @('src/app.py') `
            -Edge @() -Config $script:Config -ComputedAt '2026-08-08T10-05'

        $pairs.Count | Should -Be 0
    }

    It 'Get-ParallelDriftNewConflictPair skips a pair already recorded as an edge' {
        $peer = New-TestItem -ItemKey 445 -Radius (New-TestRadius -Path @('src/app.py'))
        $edge = New-OrdinalTable -Pair @('a', [long]445, 'b', [long]446)

        $pairs = Get-ParallelDriftNewConflictPair -Item @($script:Drifter, $peer) -DriftingItemKey 446 -ObservedPath @('src/app.py') `
            -Edge @($edge) -Config $script:Config -ComputedAt '2026-08-08T10-05'

        $pairs.Count | Should -Be 0
    }

    It 'Get-ParallelDriftNewConflictPair returns canonical pairs in ascending order' {
        $low = New-TestItem -ItemKey 445 -Radius (New-TestRadius -Path @('src/app.py'))
        $high = New-TestItem -ItemKey 447 -Radius (New-TestRadius -Path @('src/app.py'))

        $pairs = Get-ParallelDriftNewConflictPair -Item @($script:Drifter, $high, $low) -DriftingItemKey 446 -ObservedPath @('src/app.py') `
            -Edge @() -Config $script:Config -ComputedAt '2026-08-08T10-05'

        $pairs.Count | Should -Be 2
        $pairs[0] | Should -Be @(445, 446)
        $pairs[1] | Should -Be @(446, 447)
    }

    It 'Get-ParallelDriftResult returns no_escape with null drift_event and observed_radius' {
        # Act
        $result = Get-ParallelDriftResult -State (New-TestState -Item @($script:Drifter)) -Config $script:Config -ItemKey 446 `
            -ChangedPath @('scripts/dev_tools/a.py') -At '2026-08-08T10-00' -ComputedAt '2026-08-08T10-05'

        # Assert
        $result['result'] | Should -BeExactly 'no_escape'
        $result['drift_event'] | Should -BeNullOrEmpty
        $result['observed_radius'] | Should -BeNullOrEmpty
        $result['escaped_paths'].Count | Should -Be 0
        @($result.Keys).Count | Should -Be 9
    }

    It 'Get-ParallelDriftResult returns no_new_conflict with a raised_blocking_finding event' {
        $peer = New-TestItem -ItemKey 445 -Radius (New-TestRadius -Path @('src/other.py'))

        $result = Get-ParallelDriftResult -State (New-TestState -Item @($script:Drifter, $peer)) -Config $script:Config -ItemKey 446 `
            -ChangedPath @('docs/notes.md') -At '2026-08-08T10-00' -ComputedAt '2026-08-08T10-05'

        $result['result'] | Should -BeExactly 'no_new_conflict'
        $result['drift_event']['action'] | Should -BeExactly 'raised_blocking_finding'
        $result['observed_radius']['source'] | Should -BeExactly 'observed'
        $result['halted_item_keys'].Count | Should -Be 0
    }

    It 'Get-ParallelDriftResult returns halt_required with a halted_later_started_item event' {
        $peer = New-TestItem -ItemKey 445 -Radius (New-TestRadius -Path @('src/app.py'))

        $result = Get-ParallelDriftResult -State (New-TestState -Item @($script:Drifter, $peer)) -Config $script:Config -ItemKey 446 `
            -ChangedPath @('src/app.py') -At '2026-08-08T10-00' -ComputedAt '2026-08-08T10-05'

        $result['result'] | Should -BeExactly 'halt_required'
        $result['drift_event']['action'] | Should -BeExactly 'halted_later_started_item'
        $result['halted_item_keys'] | Should -Be @(445)
        $result['newly_conflicting_pairs'][0] | Should -Be @(445, 446)
    }
}
