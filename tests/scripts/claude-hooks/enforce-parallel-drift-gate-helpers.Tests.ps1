#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-parallel-drift-gate-helpers.ps1 shape-and-derivation helpers.
.DESCRIPTION
    Covers the eight helpers the Layer 1 parallel drift gate dot-sources from its sibling module:
    the four shape predicates, the two index builders, the resolution disjunct, and the
    unresolved-state derivation. The decision-path tests for the parent hook live in
    enforce-parallel-drift-gate.Tests.ps1; this suite dot-sources only the helpers module, so it
    exercises the helpers without loading the hook.

    The cross-runtime seam test runs the PowerShell and Python drift derivations over one shared
    checkpoint-state table, so a divergence between the two implementations fails here rather
    than surviving at 100% per-side coverage. The rows tagged Canonical carry a non-conforming
    timestamp on one side of the disjunct (b) comparison and pin the canonical-timestamp contract
    in both runtimes at once.
#>

Describe 'enforce-parallel-drift-gate-helpers.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = (Resolve-Path "$script:RepoRoot/.claude/hooks/enforce-parallel-drift-gate-helpers.ps1").Path
        . $script:UnderTest
    }

    Context 'cross-runtime binding of the unresolved-drift derivation' {
        BeforeAll {
            $script:PythonExe = @(@(Get-Command python -CommandType Application -ErrorAction SilentlyContinue) +
                @(Get-Command py -CommandType Application -ErrorAction SilentlyContinue))[0].Source

            $script:PyHarness = @'
import json, sys

from scripts.dev_tools._parallel_drift_shape import ParallelDriftInputError
from scripts.dev_tools.parallel_drift_detection import unresolved_drift_item_keys


def verdict(state):
    try:
        keys = unresolved_drift_item_keys(
            state.get("drift_events", []), state.get("items", [])
        )
    except ParallelDriftInputError:
        return {"malformed": True, "unresolved": []}
    return {"malformed": False, "unresolved": list(keys)}


print(json.dumps([verdict(state) for state in json.load(sys.stdin)]))
'@

            # One shared table of checkpoint states. Widened marks the row where the PowerShell
            # narrowing (disjunct (b) only) is expected to be strictly more conservative than
            # Python's derivation; every other row must agree exactly.
            $script:ParityRows = @(
                @{ Name = 'no drift_events key'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"declared","computed_at":"2026-01-01T00-00"}}]}' }
                @{ Name = 'empty drift_events list'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"declared","computed_at":"2026-01-01T00-00"}}],"drift_events":[]}' }
                @{ Name = 'unresolved against a declared radius'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"declared","computed_at":"2026-01-01T00-00"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'resolved by a later observed radius'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"observed","computed_at":"2026-01-03T00-00"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'observed radius older than the event'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"observed","computed_at":"2026-01-01T00-00"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'declared radius newer than the event'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"declared","computed_at":"2026-01-09T00-00"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'observed radius without computed_at'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"observed"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'item without a blast_radius'; Widened = $false; Json = '{"items":[{"issue_num":501}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'drift event with no matching item'; Widened = $false; Json = '{"items":[],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'one item unresolved beside one resolved item'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"declared","computed_at":"2026-01-01T00-00"}},{"issue_num":502,"blast_radius":{"paths":["s/c/"],"source":"observed","computed_at":"2026-01-05T00-00"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]},{"item_key":502,"at":"2026-01-02T00-00","escaped_paths":["s/d/y.py"]}]}' }
                @{ Name = 'latest of two events decides, not the earliest'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"observed","computed_at":"2026-01-03T00-00"}}],"drift_events":[{"item_key":501,"at":"2026-01-01T00-00","escaped_paths":["s/b/x.py"]},{"item_key":501,"at":"2026-01-04T00-00","escaped_paths":["s/b/z.py"]}]}' }
                @{ Name = 'an earlier event does not mask a resolved latest event'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"observed","computed_at":"2026-01-05T00-00"}}],"drift_events":[{"item_key":501,"at":"2026-01-04T00-00","escaped_paths":["s/b/z.py"]},{"item_key":501,"at":"2026-01-01T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'malformed: blank at'; Widened = $false; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"declared","computed_at":"2026-01-01T00-00"}}],"drift_events":[{"item_key":501,"at":"","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'malformed: empty escaped_paths'; Widened = $false; Json = '{"items":[{"issue_num":501}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":[]}]}' }
                @{ Name = 'malformed: escaped_paths is not a list'; Widened = $false; Json = '{"items":[{"issue_num":501}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":"s/b/x.py"}]}' }
                @{ Name = 'malformed: item_key is not a positive integer'; Widened = $false; Json = '{"items":[{"issue_num":501}],"drift_events":[{"item_key":0,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'radius widened to cover the escape (PowerShell narrowing)'; Widened = $true; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/b/x.py"],"source":"declared","computed_at":"2026-01-01T00-00"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                # The four canonical-timestamp rows (issue #446 remediation cycle 1, finding
                # F8-N4). Each carries a non-conforming timestamp on one side of the disjunct (b)
                # comparison, and each must be UNRESOLVED in both runtimes. The first three would
                # be resolved by an ungated ordinal comparison, because ':' (0x3A) exceeds '-'
                # (0x2D) and a truncated value stops before the differing position: they are the
                # fail-open rows the contract closes. The fourth is unresolved by shape alone.
                #
                # The colon-bearing rows use the minute-precision form 2026-01-02T00:00 rather
                # than a full ISO-8601 instant, because ConvertFrom-Json coerces a full instant
                # such as 2026-01-02T00:00:00Z into a [datetime] and the value would then never
                # reach the string comparison these rows exist to pin. The minute-precision form
                # stays a string in both runtimes and is the ordinally inverting case: it names
                # the same instant as the hyphen-bearing value yet sorts above it.
                @{ Name = 'colon-bearing computed_at against a hyphen-bearing at'; Widened = $false; Canonical = $true; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"observed","computed_at":"2026-01-02T00:00"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'colon-bearing at against a hyphen-bearing computed_at'; Widened = $false; Canonical = $true; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"observed","computed_at":"2026-01-03T00-00"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00:00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'truncated computed_at'; Widened = $false; Canonical = $true; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"observed","computed_at":"2026-01-03T00"}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
                @{ Name = 'non-string computed_at'; Widened = $false; Canonical = $true; Json = '{"items":[{"issue_num":501,"blast_radius":{"paths":["s/a/"],"source":"observed","computed_at":20260103}}],"drift_events":[{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["s/b/x.py"]}]}' }
            )
        }

        It 'binds the PowerShell unresolved-drift decision to the Python unresolved_drift_item_keys derivation' {
            # Arrange: run the Python derivation over the same table the PowerShell code sees.
            $script:PythonExe | Should -Not -BeNullOrEmpty -Because 'the cross-runtime binding needs a Python interpreter'
            $tableJson = '[' + ((@($script:ParityRows) | ForEach-Object { $_.Json }) -join ',') + ']'
            $previousPythonPath = $env:PYTHONPATH
            try {
                $env:PYTHONPATH = $script:RepoRoot
                $raw = ($tableJson | & $script:PythonExe -c $script:PyHarness) -join ''
                $pythonExit = $LASTEXITCODE
            } finally {
                $env:PYTHONPATH = $previousPythonPath
            }
            $pythonExit | Should -Be 0 -Because "the harness must run cleanly; output was: $raw"
            $pythonVerdicts = @($raw | ConvertFrom-Json)
            $pythonVerdicts.Count | Should -Be @($script:ParityRows).Count

            # Act: evaluate every row with the hook's own derivation and collect disagreements.
            $divergences = [System.Collections.Generic.List[string]]::new()
            for ($index = 0; $index -lt @($script:ParityRows).Count; $index++) {
                $row = @($script:ParityRows)[$index]
                $expected = $pythonVerdicts[$index]
                $actual = Get-ParallelDriftGateUnresolvedState -Checkpoint ($row.Json | ConvertFrom-Json)
                $pythonKeys = @($expected.unresolved)
                $powerShellKeys = @($actual.UnresolvedItemKeys)

                if ([bool]$actual.Malformed -ne [bool]$expected.malformed) {
                    $divergences.Add("$($row.Name): malformed PowerShell=$($actual.Malformed) Python=$($expected.malformed)")
                }
                # Fail-closed direction, asserted on every row: PowerShell must never allow an
                # item key Python reports as unresolved.
                foreach ($key in $pythonKeys) {
                    if ($powerShellKeys -notcontains [long]$key) {
                        $divergences.Add("$($row.Name): PowerShell dropped Python-unresolved key $key")
                    }
                }
                # Exact agreement, asserted on every row outside the documented narrowing.
                if (-not $row.Widened -and (($powerShellKeys -join ',') -ne ($pythonKeys -join ','))) {
                    $divergences.Add("$($row.Name): keys PowerShell=[$($powerShellKeys -join ',')] Python=[$($pythonKeys -join ',')]")
                }
            }

            # Assert: no runtime disagreed on any row.
            ($divergences -join ' | ') | Should -BeNullOrEmpty
        }

        It 'reports unresolved on every non-conforming-timestamp row of the shared table' {
            # Arrange: the four rows the canonical-timestamp contract added. Their verdict is
            # asserted directly, not only as agreement with Python, so a regression that made
            # both runtimes fail open together would still fail here.
            $canonicalRows = @(@($script:ParityRows) | Where-Object { $_.Canonical })
            $canonicalRows.Count | Should -Be 4 -Because 'the contract added exactly four rows'

            # Act, assert: each row must leave item 501 unresolved and report no malformed log.
            foreach ($row in $canonicalRows) {
                $actual = Get-ParallelDriftGateUnresolvedState -Checkpoint ($row.Json | ConvertFrom-Json)
                $actual.Malformed | Should -BeFalse -Because "$($row.Name) is well-formed, only non-canonical"
                @($actual.UnresolvedItemKeys) | Should -Contain 501 -Because "$($row.Name) must not resolve"
            }
        }

        It 'records the narrowing as strictly conservative on the widened-radius row' {
            # Arrange, act: the one row where Python resolves via the glob disjunct the hook omits.
            $row = @($script:ParityRows) | Where-Object { $_.Widened } | Select-Object -First 1
            $actual = Get-ParallelDriftGateUnresolvedState -Checkpoint ($row.Json | ConvertFrom-Json)

            # Assert: the hook reports unresolved, the deny-side (fail-closed) direction.
            $actual.Malformed | Should -BeFalse
            @($actual.UnresolvedItemKeys) | Should -Contain 501
        }
    }

    Context 'shape predicates mirroring the F3-owned Python helpers' {
        It 'Test-ParallelDriftGateItemKey rejects <Label>' -ForEach @(
            @{ Label = 'a boolean'; Value = $true }
            @{ Label = 'a string'; Value = '501' }
            @{ Label = 'zero'; Value = 0 }
            @{ Label = 'a negative integer'; Value = -1 }
            @{ Label = 'null'; Value = $null }
        ) {
            Test-ParallelDriftGateItemKey -Value $Value | Should -BeFalse
        }

        It 'Test-ParallelDriftGateItemKey accepts a positive integer' {
            Test-ParallelDriftGateItemKey -Value 501 | Should -BeTrue
        }

        It 'Test-ParallelDriftGateText rejects <Label>' -ForEach @(
            @{ Label = 'null'; Value = $null }
            @{ Label = 'an empty string'; Value = '' }
            @{ Label = 'whitespace'; Value = '   ' }
            @{ Label = 'an integer'; Value = 5 }
        ) {
            Test-ParallelDriftGateText -Value $Value | Should -BeFalse
        }

        It 'Test-ParallelDriftGateText accepts a non-blank string' {
            Test-ParallelDriftGateText -Value '2026-01-02T00-00' | Should -BeTrue
        }

        It 'Test-ParallelDriftGateEventRecord rejects a $null record' {
            Test-ParallelDriftGateEventRecord -Record $null | Should -BeFalse
        }

        It 'Test-ParallelDriftGateEventRecord rejects an escaped_paths entry that is blank' {
            $record = '{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["a/b.py","  "]}' | ConvertFrom-Json
            Test-ParallelDriftGateEventRecord -Record $record | Should -BeFalse
        }

        It 'Test-ParallelDriftGateEventRecord accepts a well-formed record' {
            $record = '{"item_key":501,"at":"2026-01-02T00-00","escaped_paths":["a/b.py"]}' | ConvertFrom-Json
            Test-ParallelDriftGateEventRecord -Record $record | Should -BeTrue
        }
    }

    Context 'derivation helpers' {
        It 'Get-ParallelDriftGateLatestEventMap reports malformed for a $null checkpoint' {
            (Get-ParallelDriftGateLatestEventMap -Checkpoint $null).Malformed | Should -BeTrue
        }

        It 'Get-ParallelDriftGateLatestEventMap reports malformed for a non-list drift_events' {
            $checkpoint = '{"drift_events":"none"}' | ConvertFrom-Json
            (Get-ParallelDriftGateLatestEventMap -Checkpoint $checkpoint).Malformed | Should -BeTrue
        }

        It 'Get-ParallelDriftGateItemRadiusMap returns an empty index for a $null checkpoint' {
            (Get-ParallelDriftGateItemRadiusMap -Checkpoint $null).Count | Should -Be 0
        }

        It 'Get-ParallelDriftGateItemRadiusMap skips a null item, a bad key, and a non-object radius' {
            $checkpoint = '{"items":[null,{"issue_num":"x","blast_radius":{}},{"issue_num":7,"blast_radius":"nope"},{"issue_num":9,"blast_radius":{"paths":[]}}]}' |
                ConvertFrom-Json
            $radii = Get-ParallelDriftGateItemRadiusMap -Checkpoint $checkpoint
            $radii.Count | Should -Be 1
            $radii.ContainsKey([long]9) | Should -BeTrue
        }

        It 'Test-ParallelDriftGateEventResolved rejects a source that differs only in case' {
            $radius = '{"source":"Observed","computed_at":"2026-01-09T00-00"}' | ConvertFrom-Json
            Test-ParallelDriftGateEventResolved -Radius $radius -At '2026-01-02T00-00' | Should -BeFalse
        }

        It 'Test-ParallelDriftGateEventResolved rejects a $null radius' {
            Test-ParallelDriftGateEventResolved -Radius $null -At '2026-01-02T00-00' | Should -BeFalse
        }

        It 'Test-ParallelDriftGateEventResolved rejects a computed_at equal to the event at' {
            $radius = '{"source":"observed","computed_at":"2026-01-02T00-00"}' | ConvertFrom-Json
            Test-ParallelDriftGateEventResolved -Radius $radius -At '2026-01-02T00-00' | Should -BeFalse
        }

        It 'Get-ParallelDriftGateUnresolvedState surfaces LatestAt for the latest event of each item' {
            # Arrange: two items, one carrying two events so the latest must win, not the first.
            $checkpoint = '{"items":[{"issue_num":501},{"issue_num":502}],"drift_events":[{"item_key":501,"at":"2026-01-01T00-00","escaped_paths":["s/b/x.py"]},{"item_key":501,"at":"2026-01-04T00-00","escaped_paths":["s/b/z.py"]},{"item_key":502,"at":"2026-01-02T00-00","escaped_paths":["s/d/y.py"]}]}' |
                ConvertFrom-Json

            # Act.
            $state = Get-ParallelDriftGateUnresolvedState -Checkpoint $checkpoint

            # Assert: LatestAt carries the greatest at per item key, beside the existing members.
            $state.Malformed | Should -BeFalse
            @($state.UnresolvedItemKeys) | Should -Be @([long]501, [long]502)
            [string]$state.LatestAt[[long]501] | Should -Be '2026-01-04T00-00'
            [string]$state.LatestAt[[long]502] | Should -Be '2026-01-02T00-00'
        }

        It 'Get-ParallelDriftGateUnresolvedState returns an empty LatestAt when the log is malformed' {
            # A malformed log yields no trustworthy timestamp, so the map must be empty rather
            # than partially populated from the records read before the malformed one.
            $checkpoint = '{"items":[{"issue_num":501}],"drift_events":[{"item_key":501,"at":"2026-01-01T00-00","escaped_paths":["s/b/x.py"]},{"item_key":0,"at":"2026-01-04T00-00","escaped_paths":["s/b/z.py"]}]}' |
                ConvertFrom-Json
            $state = Get-ParallelDriftGateUnresolvedState -Checkpoint $checkpoint
            $state.Malformed | Should -BeTrue
            $state.LatestAt.Count | Should -Be 0
        }
    }
}
