#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    PowerShell lane of the issue #1162 cross-epic dependency parity corpus.

.DESCRIPTION
    Reads tests/fixtures/epic_cross_dependency/cross-dependency-cases.json and, for every
    epic-orchestrator-state case validated without require_complete, builds the checkpoint
    (envelope, features, and extra keys), calls Get-OrchestratorStateEpicCrossDependencyError,
    and compares its lines, in order, with the case's expected EPIC_CROSS_DEPENDENCY_VIOLATION
    strings. The Python and TypeScript lanes assert the same file, so the three runtimes
    are pinned to one set of strings. The corpus is read-only; no file is created.
#>

BeforeDiscovery {
    $corpusPath = Join-Path $PSScriptRoot '../../../fixtures/epic_cross_dependency/cross-dependency-cases.json'
    $corpus = Get-Content -Raw -LiteralPath $corpusPath | ConvertFrom-Json -AsHashtable
    $script:ParityCases = @(foreach ($case in $corpus.cases) {
            if ($case.checkpoint_types -notcontains 'epic-orchestrator-state' -or $case.require_complete) { continue }
            $checkpoint = [ordered]@{}
            foreach ($key in $corpus.envelopes['epic-orchestrator-state'].Keys) { $checkpoint[$key] = $corpus.envelopes['epic-orchestrator-state'][$key] }
            $checkpoint['features'] = $case.features
            foreach ($key in $case.extra.Keys) { $checkpoint[$key] = $case.extra[$key] }
            @{
                Name     = $case.name
                Text     = ($checkpoint | ConvertTo-Json -Depth 20 -Compress)
                Expected = [string[]] @($case.expected | Where-Object { $_ -like 'EPIC_CROSS_DEPENDENCY_VIOLATION: *' })
            }
        })
}

BeforeAll {
    Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1").Path -Force -ErrorAction Stop
}

AfterAll {
    Remove-Module -Name OrchestratorStateEpicCrossDependency -Force -ErrorAction SilentlyContinue
}

Describe 'Cross-epic corpus parity (PowerShell lane)' {
    It 'the corpus holds violation cases for this lane' {
        $corpusPath = Join-Path $PSScriptRoot '../../../fixtures/epic_cross_dependency/cross-dependency-cases.json'
        $expected = @((Get-Content -Raw -LiteralPath $corpusPath | ConvertFrom-Json).cases.expected | Where-Object { $_ -like 'EPIC_CROSS_DEPENDENCY_VIOLATION: *' })

        $expected.Count | Should -BeGreaterOrEqual 4
    }

    It 'matches the corpus for <Name>' -ForEach $script:ParityCases {
        $actual = Get-OrchestratorStateEpicCrossDependencyError -CheckpointText $Text

        ($actual -join '|') | Should -BeExactly ($Expected -join '|')
    }
}
