# Pester tests for .claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1 (issue #1153).
# The Logic hub is dot-sourced, which dot-sources the Schedule file; every function under test is
# pure, so each test supplies fixed in-memory input and asserts the returned data. Durations are in
# seconds (3600 per hour), and golden values are derived by hand in the comments.

BeforeAll {
    $script:scriptFolder = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/skills/epic-progress-report/scripts'
    . (Join-Path -Path $script:scriptFolder -ChildPath 'Get-EpicProgressReport.Logic.ps1')

    function Get-TestFeature {
        # One kickoff feature for the graph builder.
        param([string] $Issue, [int] $Wave, [string] $Folder = '', [bool] $Merged = $false)
        [pscustomobject]@{ Issue = $Issue; Wave = $Wave; Folder = $Folder; Merged = $Merged }
    }

    function Get-TestRow {
        # One checkpoint or manifest row; omit -DependsOn to leave out the depends_on key.
        param([object] $Issue, [string] $Folder = '', [object[]] $DependsOn, [switch] $NoKey)
        $row = [ordered]@{ issue_num = $Issue; feature_folder = $Folder }
        if (-not $NoKey) { $row['depends_on'] = [object[]] @($DependsOn) }
        [pscustomobject] $row
    }

    function ConvertTo-TestEdgeText {
        # The dependencies as 'issue:dep,dep' entries in ascending issue order, joined by '; '.
        param([hashtable] $DependsOn)
        (@($DependsOn.Keys | Sort-Object { [int] $_ } | ForEach-Object { "$($_):$(@($DependsOn[$_]) -join ',')" }) -join '; ')
    }

    # Three features in two waves with folder names, used by the source rules.
    $script:three = @(
        Get-TestFeature -Issue '101' -Wave 1 -Folder 'f-a'
        Get-TestFeature -Issue '102' -Wave 1 -Folder 'f-b'
        Get-TestFeature -Issue '103' -Wave 2 -Folder 'f-c'
    )
    # Five features in waves 1, 2, and 3 for the waves-edge case.
    $script:five = @(
        Get-TestFeature -Issue '101' -Wave 1
        Get-TestFeature -Issue '102' -Wave 1
        Get-TestFeature -Issue '103' -Wave 2
        Get-TestFeature -Issue '104' -Wave 2
        Get-TestFeature -Issue '105' -Wave 3
    )
    $script:fiveWaveEdges = '101:; 102:; 103:101,102; 104:101,102; 105:103,104'
}

Describe 'Resolve-EpicProgressParallelCap (AC-31)' {
    It 'uses a checkpoint value of <Value>' -ForEach @(@{ Value = 1 }, @{ Value = 8 }) {
        $cap = Resolve-EpicProgressParallelCap -CheckpointValue ([long] $Value) -ConfigValue 3

        $cap.Cap | Should -Be $Value
        $cap.Source | Should -Be 'checkpoint'
    }

    It 'falls back to the config value for checkpoint value <Label>' -ForEach @(
        @{ Label = '0'; Value = 0 }
        @{ Label = '9'; Value = 9 }
        @{ Label = '2.5'; Value = 2.5 }
        @{ Label = 'text 4'; Value = '4' }
        @{ Label = 'missing'; Value = $null }
    ) {
        $cap = Resolve-EpicProgressParallelCap -CheckpointValue $Value -ConfigValue 3

        $cap.Cap | Should -Be 3
        $cap.Source | Should -Be 'config'
    }

    It 'uses the built-in 4 when the config value is <Label>' -ForEach @(
        @{ Label = 'missing'; Value = $null }
        @{ Label = 'invalid'; Value = 0 }
        @{ Label = 'text'; Value = 'four' }
    ) {
        $cap = Resolve-EpicProgressParallelCap -CheckpointValue $null -ConfigValue $Value

        $cap.Cap | Should -Be 4
        $cap.Source | Should -Be 'built-in'
    }
}

Describe 'Get-EpicProgressDependencyGraph sources (AC-32, E5)' {
    It 'uses a checkpoint key over a manifest list for the same feature' {
        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @(101)) -ManifestRow @(Get-TestRow -Issue 103 -DependsOn @(102))

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:; 103:101'
        $graph.Source | Should -Be 'checkpoint'
        $graph.Message | Should -BeNullOrEmpty
    }

    It 'reports checkpoint+manifest when the keys come from both sources' {
        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @(101)) -ManifestRow @(Get-TestRow -Issue 102 -DependsOn @(101))

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:101; 103:101'
        $graph.Source | Should -Be 'checkpoint+manifest'
    }

    It 'uses a manifest key present for one feature only, not the waves' {
        # Waves would give 103 the edges 101 and 102; the manifest gives 103 only 102.
        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -NoKey) -ManifestRow @(Get-TestRow -Issue 103 -DependsOn @(102))

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:; 103:102'
        $graph.Source | Should -Be 'manifest'
    }

    It 'gives no edge for an explicit empty list and the waves for a missing key everywhere' {
        $empty = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @())
        $missing = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -NoKey) -ManifestRow @(Get-TestRow -Issue 102 -NoKey)

        ConvertTo-TestEdgeText -DependsOn $empty.DependsOn | Should -Be '101:; 102:; 103:'
        $empty.Source | Should -Be 'checkpoint'
        ConvertTo-TestEdgeText -DependsOn $missing.DependsOn | Should -Be '101:; 102:; 103:101,102'
        $missing.Source | Should -Be 'waves'
    }

    It 'resolves a reference by issue number and by feature-folder hint' {
        # 103 names 101 by number; 102 names f-a through a lifecycle path; a row matched by folder names 'f-b'.
        $rows = @(
            Get-TestRow -Issue 103 -DependsOn @(101)
            Get-TestRow -Issue 102 -DependsOn @('docs/features/active/f-a')
            Get-TestRow -Issue $null -Folder 'completed/f-a' -DependsOn @()
        )

        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow $rows

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:101; 103:101'
        $graph.Message | Should -BeNullOrEmpty
    }

    It 'reports an unresolved reference that matches neither an issue nor a folder' {
        $graph = Get-EpicProgressDependencyGraph -Feature $script:three -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @('f-zzz'))

        $graph.Message | Should -BeLike "unresolved dependency reference: #103 depends on 'f-zzz'*"
    }

    It 'gives no edge for a reference to a merged feature' {
        $features = @(
            Get-TestFeature -Issue '101' -Wave 1 -Folder 'f-a' -Merged $true
            Get-TestFeature -Issue '103' -Wave 2 -Folder 'f-c'
        )

        $graph = Get-EpicProgressDependencyGraph -Feature $features -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @(101))

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 103:'
        $graph.Source | Should -Be 'checkpoint'
    }
}

Describe 'Get-EpicProgressDependencyGraph waves fallback (E5)' {
    It 'links each feature to every feature of the next lower wave only' {
        $graph = Get-EpicProgressDependencyGraph -Feature $script:five

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be $script:fiveWaveEdges
        $graph.Source | Should -Be 'waves'
        $graph.Message | Should -BeNullOrEmpty
    }

    It 'links to the nearest lower wave when a wave number is skipped' {
        # Waves 1 and 3 only: each wave-3 feature depends on every wave-1 feature.
        $features = @(
            Get-TestFeature -Issue '101' -Wave 1
            Get-TestFeature -Issue '102' -Wave 1
            Get-TestFeature -Issue '105' -Wave 3
            Get-TestFeature -Issue '106' -Wave 3
        )

        $graph = Get-EpicProgressDependencyGraph -Feature $features

        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be '101:; 102:; 105:101,102; 106:101,102'
    }
}

Describe 'Get-EpicProgressDependencyGraph invalid graphs (AC-33)' {
    It 'reports a <Kind> with a distinct message and falls back to the waves' -ForEach @(
        @{ Kind = 'self-loop'; Rows = @(@{ Issue = 103; DependsOn = @(103) }); Expected = 'dependency self-loop: #103 depends on itself*' }
        @{ Kind = 'unresolved reference'; Rows = @(@{ Issue = 103; DependsOn = @('f-zzz') }); Expected = "unresolved dependency reference: #103 depends on 'f-zzz'*" }
        @{ Kind = 'cycle'; Rows = @(@{ Issue = 101; DependsOn = @(103) }, @{ Issue = 103; DependsOn = @(101) }); Expected = 'dependency cycle: #101 -> #103 -> #101*' }
    ) {
        $rows = @($Rows | ForEach-Object { Get-TestRow -Issue $_.Issue -DependsOn $_.DependsOn })

        { $script:graphResult = Get-EpicProgressDependencyGraph -Feature $script:five -CheckpointRow $rows } | Should -Not -Throw
        $graph = $script:graphResult

        $graph.Message | Should -BeLike $Expected
        $graph.Message | Should -BeLike '*the schedule falls back to waves'
        $graph.Source | Should -Be 'waves'
        ConvertTo-TestEdgeText -DependsOn $graph.DependsOn | Should -Be $script:fiveWaveEdges
    }

    It 'gives three different messages for the three defects' {
        $messages = @(
            (Get-EpicProgressDependencyGraph -Feature $script:five -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @(103))).Message
            (Get-EpicProgressDependencyGraph -Feature $script:five -CheckpointRow @(Get-TestRow -Issue 103 -DependsOn @('f-zzz'))).Message
            (Get-EpicProgressDependencyGraph -Feature $script:five -CheckpointRow @(Get-TestRow -Issue 101 -DependsOn @(103); Get-TestRow -Issue 103 -DependsOn @(101))).Message
        )

        @($messages | Sort-Object -Unique).Count | Should -Be 3
    }
}

Describe 'Velocity and Schedule purity (AC-50, E6, E14)' {
    It 'calls no I/O seam and reads no clock in the Velocity and Schedule files' {
        $forbidden = @('Get-EpicProgressUtcNow', 'Read-EpicProgressFile', 'Test-EpicProgressPath', 'Write-EpicProgressState', 'Invoke-GitExe', 'Invoke-GhExe', 'Invoke-CswapExe', 'Get-Date', 'Import-Module')
        foreach ($name in @('Get-EpicProgressReport.Velocity.ps1', 'Get-EpicProgressReport.Schedule.ps1')) {
            $path = Join-Path -Path $script:scriptFolder -ChildPath $name
            $tokens = $null
            $parseErrors = $null

            $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref] $tokens, [ref] $parseErrors)
            $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))

            $parseErrors.Count | Should -Be 0 -Because "$name must parse"
            $commands.Count | Should -BeGreaterThan 0 -Because "$name must hold commands to check"
            foreach ($command in $commands) {
                $forbidden | Should -Not -Contain $command.GetCommandName() -Because "$name must stay host-neutral"
                if ($command.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot) {
                    $command.Extent.Text | Should -BeLike '*$PSScriptRoot*' -Because "$name may dot-source only its own folder"
                }
            }
            $ast.UsingStatements.Count | Should -Be 0 -Because "$name must not use a module"
        }
    }
}
