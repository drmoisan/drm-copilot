#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-parallel-drift-gate.ps1 PreToolUse hook (Layer 1 deterrent).
.DESCRIPTION
    Both read boundaries are mocked -- the checkpoint-read seam
    (Get-ParallelDriftGateCheckpointContent) and the finding-presence seam
    (Test-ParallelDriftFindingPresent) -- so no test writes a temporary file. Three binding
    tests keep the hook tied to the artifacts it consumes rather than to hardcoded copies: the
    marker-binding test reads .claude/skills/parallel-orchestrate/SKILL.md at run time, the
    registration test reads .claude/settings.json at run time, and the cross-runtime seam test
    runs the PowerShell and Python drift derivations over one shared checkpoint-state table.
#>

Describe 'enforce-parallel-drift-gate.ps1' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = (Resolve-Path "$script:RepoRoot/.claude/hooks/enforce-parallel-drift-gate.ps1").Path
        . $script:UnderTest

        $script:AlphaFolder = '2026-08-07-parallel-alpha-501'
        $script:AlphaPrompt = "Parallel mode: true. parallel_slug: demo. cohort_index: 0. docs/features/active/$script:AlphaFolder/spec.md"

        function Get-ToolInputJson {
            param([string] $Subagent = 'feature-review', [string] $Prompt = '')
            return (@{ subagent_type = $Subagent; prompt = $Prompt } | ConvertTo-Json -Compress)
        }

        function Get-CheckpointJson {
            param(
                [string] $Source = 'declared',
                [string] $ComputedAt = '2026-01-01T00-00',
                [string] $EventAt = '2026-01-02T00-00',
                [switch] $NoDriftEvents
            )
            $item = '{"issue_num":501,"feature_folder":"' + $script:AlphaFolder + '","state":"in_flight",' +
            '"worktree_path":"C:/worktrees/alpha","blast_radius":{"paths":["scripts/declared/"],"modules":[],' +
            '"shared_surfaces":[],"contracts":[],"source":"' + $Source + '","computed_at":"' + $ComputedAt + '"}}'
            $events = '[{"item_key":501,"declared":["scripts/declared/"],"observed":["scripts/other/escape.py"],' +
            '"escaped_paths":["scripts/other/escape.py"],"at":"' + $EventAt + '","action":"raised_blocking_finding"}]'
            if ($NoDriftEvents) { $events = '[]' }
            return '{"items":[' + $item + '],"drift_events":' + $events + '}'
        }
    }

    Context 'allow paths that never engage the gate' {
        It 'allows when CLAUDE_TOOL_INPUT is empty' {
            (Invoke-ParallelDriftGateDecision -ToolInputRaw '').hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non-feature-review subagent_type even under the marker' {
            $payload = Get-ToolInputJson -Subagent 'atomic-planner' -Prompt $script:AlphaPrompt
            (Invoke-ParallelDriftGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a feature-review delegation whose prompt lacks the parallel-mode marker' {
            $payload = Get-ToolInputJson -Prompt "docs/features/active/$script:AlphaFolder/spec.md"
            (Invoke-ParallelDriftGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a feature-review delegation whose prompt is absent' {
            $payload = '{"subagent_type":"feature-review"}'
            (Invoke-ParallelDriftGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws on malformed JSON so the hook exits 1' {
            { Invoke-ParallelDriftGateDecision -ToolInputRaw '{not-json' } | Should -Throw
        }
    }

    Context 'allow when the resolved item carries no unresolved drift' {
        It 'allows when the item has no drift event at all' {
            Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith { Get-CheckpointJson -NoDriftEvents }
            $payload = Get-ToolInputJson -Prompt $script:AlphaPrompt
            (Invoke-ParallelDriftGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when the latest drift event is resolved by a later observed radius' {
            Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith {
                Get-CheckpointJson -Source 'observed' -ComputedAt '2026-01-03T00-00' -EventAt '2026-01-02T00-00'
            }
            $payload = Get-ToolInputJson -Prompt $script:AlphaPrompt
            (Invoke-ParallelDriftGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an unresolved item once its synthetic finding file is recorded as written' {
            Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith { Get-CheckpointJson }
            Mock -CommandName Test-ParallelDriftFindingPresent -MockWith { $true }
            $payload = Get-ToolInputJson -Prompt $script:AlphaPrompt
            (Invoke-ParallelDriftGateDecision -ToolInputRaw $payload).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Test-ParallelDriftFindingPresent -Times 1 -Exactly
        }
    }

    Context 'deny PARALLEL_DRIFT_GATE_BLOCKED' {
        It 'denies when the latest drift event is unresolved and no finding has been written' {
            Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith { Get-CheckpointJson }
            Mock -CommandName Test-ParallelDriftFindingPresent -MockWith { $false }
            $payload = Get-ToolInputJson -Prompt $script:AlphaPrompt
            $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_DRIFT_GATE_BLOCKED'
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        }

        It 'denies (fail closed) when the checkpoint is missing' {
            Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith { $null }
            $payload = Get-ToolInputJson -Prompt $script:AlphaPrompt
            $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'missing or unreadable'
        }

        It 'denies (fail closed) when the checkpoint content is malformed JSON' {
            Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith { '{ broken json' }
            $payload = Get-ToolInputJson -Prompt $script:AlphaPrompt
            $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_DRIFT_GATE_BLOCKED'
        }

        It 'denies (fail closed) when the prompt names no feature folder' {
            $payload = Get-ToolInputJson -Prompt 'Parallel mode: true. cohort_index: 0. no path token here'
            $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'must reference the target item feature folder'
        }

        It 'denies (fail closed) when no items[] record resolves to the prompt folder' {
            Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":777,"feature_folder":"2026-08-07-other-777"}],"drift_events":[]}'
            }
            $payload = Get-ToolInputJson -Prompt $script:AlphaPrompt
            $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no parallel checkpoint items\[\] record'
        }

        It 'denies (fail closed) when the resolved item has an unreadable issue_num' {
            Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":"501","feature_folder":"' + $script:AlphaFolder + '"}],"drift_events":[]}'
            }
            $payload = Get-ToolInputJson -Prompt $script:AlphaPrompt
            $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies (fail closed) when the drift event log is malformed and no finding exists' {
            Mock -CommandName Get-ParallelDriftGateCheckpointContent -MockWith {
                '{"items":[{"issue_num":501,"feature_folder":"' + $script:AlphaFolder + '"}],' +
                '"drift_events":[{"item_key":501,"at":"","escaped_paths":["a/b.py"]}]}'
            }
            Mock -CommandName Test-ParallelDriftFindingPresent -MockWith { $false }
            $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw (Get-ToolInputJson -Prompt $script:AlphaPrompt)
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'marker binding to the parallel-orchestrate skill' {
        It 'asserts the hook marker constant is a substring of the marker line in SKILL.md' {
            # Arrange: read F5's kickoff section at run time so an edit to its marker text fails here.
            $skillPath = (Resolve-Path "$script:RepoRoot/.claude/skills/parallel-orchestrate/SKILL.md").Path
            $lines = [System.IO.File]::ReadAllLines($skillPath)
            $start = -1
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i].Trim() -ceq '## Parallel-Mode Kickoff Parameter') { $start = $i; break }
            }
            $start | Should -BeGreaterThan -1 -Because 'the kickoff-parameter section must exist in SKILL.md'

            # Act: take the section's marker line, the only line naming parallel_checkpoint_path.
            $markerLine = $null
            for ($i = $start + 1; $i -lt $lines.Count; $i++) {
                if ($lines[$i].StartsWith('## ', [System.StringComparison]::Ordinal)) { break }
                if ($lines[$i].Contains('parallel_checkpoint_path', [System.StringComparison]::Ordinal)) {
                    $markerLine = $lines[$i]
                    break
                }
            }

            # Assert: the constant the hook matches on is carried verbatim by that line.
            $markerLine | Should -Not -BeNullOrEmpty -Because 'the kickoff section must carry the marker line'
            $script:ParallelModeMarker | Should -Not -BeNullOrEmpty
            $markerLine.Contains($script:ParallelModeMarker, [System.StringComparison]::Ordinal) |
                Should -BeTrue -Because "SKILL.md must carry the hook constant '$script:ParallelModeMarker' verbatim"
        }
    }

    Context 'registration binding to .claude/settings.json' {
        It 'asserts the registered hook path resolves to an existing file' {
            # Arrange: read the live settings file so a registration typo fails here.
            $settingsPath = (Resolve-Path "$script:RepoRoot/.claude/settings.json").Path
            $settings = [System.IO.File]::ReadAllText($settingsPath) | ConvertFrom-Json
            $agentGroup = @($settings.hooks.PreToolUse | Where-Object { $_.matcher -ceq 'Agent' })
            $agentGroup.Count | Should -Be 1

            # Act: isolate the registration entries naming this hook file.
            $entries = @($agentGroup[0].hooks | Where-Object {
                    ([string]$_.command).Contains('enforce-parallel-drift-gate.ps1', [System.StringComparison]::Ordinal)
                })

            # Assert: exactly one entry, and the path it names exists on disk.
            $entries.Count | Should -Be 1 -Because 'the registration is append-only and single'
            $registered = ([string]$entries[0].command) -replace '^.*-File\s+', ''
            Test-Path -LiteralPath (Join-Path $script:RepoRoot $registered) -PathType Leaf |
                Should -BeTrue -Because "the registered path '$registered' must exist"
        }
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

        It 'records the narrowing as strictly conservative on the widened-radius row' {
            # Arrange, act: the one row where Python resolves via the glob disjunct the hook omits.
            $row = @($script:ParityRows) | Where-Object { $_.Widened } | Select-Object -First 1
            $actual = Get-ParallelDriftGateUnresolvedState -Checkpoint ($row.Json | ConvertFrom-Json)

            # Assert: the hook reports unresolved, the deny-side (fail-closed) direction.
            $actual.Malformed | Should -BeFalse
            @($actual.UnresolvedItemKeys) | Should -Contain 501
        }
    }

    Context 'Find-ParallelDriftGateFeatureFolderFromPrompt helper' {
        It 'returns $null for an empty prompt' {
            Find-ParallelDriftGateFeatureFolderFromPrompt -Prompt '' | Should -BeNullOrEmpty
        }

        It 'returns $null when no path token is present' {
            Find-ParallelDriftGateFeatureFolderFromPrompt -Prompt 'no path token here' | Should -BeNullOrEmpty
        }

        It 'resolves a .md-suffixed match to its parent directory basename' {
            Find-ParallelDriftGateFeatureFolderFromPrompt -Prompt 'see docs/features/active/alpha-501/spec.md now' |
                Should -Be 'alpha-501'
        }

        It 'accepts a backslash-separated token and returns the longest match' {
            Find-ParallelDriftGateFeatureFolderFromPrompt -Prompt 'docs\features\active\alpha-501\ and docs/features/active/b' |
                Should -Be 'alpha-501'
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

        It 'Find-ParallelDriftGateItemRecord returns $null for <Label>' -ForEach @(
            @{ Label = 'a $null checkpoint'; Json = $null; Folder = 'alpha-501' }
            @{ Label = 'a blank target folder'; Json = '{"items":[]}'; Folder = '' }
            @{ Label = 'an absent items key'; Json = '{}'; Folder = 'alpha-501' }
            @{ Label = 'a null item and a non-string feature_folder'; Json = '{"items":[null,{"feature_folder":7}]}'; Folder = 'alpha-501' }
            @{ Label = 'a case-mismatched basename'; Json = '{"items":[{"feature_folder":"ALPHA-501"}]}'; Folder = 'alpha-501' }
        ) {
            $checkpoint = if ($null -eq $Json) { $null } else { $Json | ConvertFrom-Json }
            Find-ParallelDriftGateItemRecord -Checkpoint $checkpoint -FeatureFolder $Folder | Should -BeNullOrEmpty
        }

        It 'Find-ParallelDriftGateItemRecord matches a feature_folder recorded as a full path' {
            $checkpoint = '{"items":[{"issue_num":501,"feature_folder":"docs\\features\\active\\alpha-501\\"}]}' | ConvertFrom-Json
            (Find-ParallelDriftGateItemRecord -Checkpoint $checkpoint -FeatureFolder 'alpha-501').issue_num | Should -Be 501
        }
    }

    Context 'read seams' {
        It 'Get-ParallelDriftGateCheckpointContent returns $null when the checkpoint file is absent' {
            Mock -CommandName Test-Path -MockWith { $false } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Get-ParallelDriftGateCheckpointContent | Should -BeNullOrEmpty
        }

        It 'Get-ParallelDriftGateCheckpointContent reads content when the checkpoint file exists' {
            Mock -CommandName Test-Path -MockWith { $true } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Mock -CommandName Get-Content -MockWith { '{"items":[]}' } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Get-ParallelDriftGateCheckpointContent | Should -Be '{"items":[]}'
        }

        It 'Test-ParallelDriftFindingPresent reports absence for <Label>' -ForEach @(
            @{ Label = 'a null worktree path'; Worktree = ''; Folder = 'alpha-501' }
            @{ Label = 'a blank feature folder'; Worktree = 'C:/worktrees/alpha'; Folder = '' }
        ) {
            Test-ParallelDriftFindingPresent -WorktreePath $Worktree -FeatureFolder $Folder | Should -BeFalse
        }

        It 'Test-ParallelDriftFindingPresent reports absence when the feature folder does not exist' {
            Mock -CommandName Test-Path -MockWith { $false }
            Test-ParallelDriftFindingPresent -WorktreePath 'C:/worktrees/alpha' -FeatureFolder 'alpha-501' | Should -BeFalse
        }

        It 'Test-ParallelDriftFindingPresent reports absence when no remediation-inputs file is present' {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-ChildItem -MockWith { @([pscustomobject]@{ Name = 'spec.md' }, [pscustomobject]@{ Name = 'remediation-inputs.2026-01-01T00-00.txt' }) }
            Test-ParallelDriftFindingPresent -WorktreePath 'C:/worktrees/alpha' -FeatureFolder 'alpha-501' | Should -BeFalse
        }

        It 'Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file' {
            Mock -CommandName Test-Path -MockWith { $true }
            Mock -CommandName Get-ChildItem -MockWith { @([pscustomobject]@{ Name = 'plan.md' }, [pscustomobject]@{ Name = 'remediation-inputs.2026-08-08T21-19.md' }) }
            Test-ParallelDriftFindingPresent -WorktreePath 'C:/worktrees/alpha' -FeatureFolder 'alpha-501' | Should -BeTrue
        }
    }

    Context 'script entrypoint (end-to-end)' {
        BeforeAll {
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
        }

        It 'allows when CLAUDE_TOOL_INPUT is empty (exit 0, allow)' {
            $previous = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = ''
                $out = & $script:PwshExe -NoProfile -File $script:UnderTest
                $LASTEXITCODE | Should -Be 0
                ($out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $previous
            }
        }

        It 'exits 1 on malformed JSON' {
            $previous = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{not-json'
                $null = & $script:PwshExe -NoProfile -File $script:UnderTest 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_TOOL_INPUT = $previous
            }
        }
    }
}
