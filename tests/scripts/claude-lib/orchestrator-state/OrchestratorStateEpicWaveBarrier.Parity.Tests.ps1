#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Parity lane for the Layer 2 wave-barrier port against the shared fixture corpus (issue #840).

.DESCRIPTION
    Runs every case of every tests/fixtures/epic_wave_barrier/*.json file through
    Get-OrchestratorStateEpicWaveBarrierError and compares the result with the case's
    expected_barrier_errors, which the Python lanes verify against the authority
    validate_epic_orchestrator_state_text. Each document is built from the file's envelope
    plus the case's features with System.Text.Json.Nodes.JsonNode, so the lane introduces
    no DateTime coercion and no key-case folding.

    Declared divergence classes, where the port deliberately differs from the Python
    authority. Each is pinned by a row below:
      D1  Non-integer numeric reference tokens (for example 901.0). Python compares them by
          value and renders 901.0; the port fails closed with EPIC_WAVE_BARRIER_UNEVALUABLE:.
      D2  Astral-plane string ordering. Python orders timestamps by code point; the port
          orders by UTF-16 code unit, as the TypeScript port does.
      D3  Unhashable issue_num (an array or object). Python raises TypeError; the port fails
          closed with EPIC_WAVE_BARRIER_UNEVALUABLE:.
      D4  Non-standard JSON literals (NaN, Infinity). Python json accepts them; System.Text.Json
          rejects them, and the port fails closed.
      D5  Nesting depth beyond the System.Text.Json default of 64. Python json accepts it; the
          port fails closed.

    The fixture files are opened read-only. No row creates, writes, or deletes a file,
    reads a clock, starts a process, or touches the network.
#>

BeforeDiscovery {
    # Enumerate the committed corpus files by name, read-only, so a new file joins the lane.
    $fixtureRoot = (Resolve-Path "$PSScriptRoot/../../../fixtures/epic_wave_barrier").Path
    $script:FixtureFiles = @(
        Get-ChildItem -LiteralPath $fixtureRoot -Filter '*.json' -File |
            Sort-Object -Property Name |
                ForEach-Object { @{ FileName = $_.Name; FilePath = $_.FullName } }
    )
}

BeforeAll {
    Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1").Path -Force

    $script:UnevaluablePattern = 'EPIC_WAVE_BARRIER_UNEVALUABLE:*'

    # Compose an epic checkpoint text whose features array holds the given JSON object texts.
    function ConvertTo-ParityCheckpointText {
        param([string[]] $Feature)
        return '{"route_id":"epic","features":[' + ($Feature -join ',') + ']}'
    }
}

Describe 'OrchestratorStateEpicWaveBarrier parity with the shared corpus' {
    It 'P <FileName> runs every case' -ForEach $script:FixtureFiles {
        # Arrange: parse the corpus file and read its envelope and case list.
        $document = [System.Text.Json.JsonDocument]::Parse([System.IO.File]::ReadAllText($FilePath), [System.Text.Json.JsonDocumentOptions]::new())
        $nodeOptions = [System.Text.Json.Nodes.JsonNodeOptions]::new()
        $parseOptions = [System.Text.Json.JsonDocumentOptions]::new()
        $executed = 0
        $mismatches = [System.Collections.Generic.List[string]]::new()
        try {
            $root = $document.RootElement
            $envelopeRaw = $root.GetProperty('envelope').GetRawText()
            $cases = $root.GetProperty('cases')
            $caseCount = $cases.GetArrayLength()

            # Act: run each case as envelope plus features, recording any case whose output differs.
            foreach ($case in $cases.EnumerateArray()) {
                $name = $case.GetProperty('name').GetString()
                $node = [System.Text.Json.Nodes.JsonNode]::Parse($envelopeRaw, $nodeOptions, $parseOptions)
                $node['features'] = [System.Text.Json.Nodes.JsonNode]::Parse($case.GetProperty('features').GetRawText(), $nodeOptions, $parseOptions)
                $expectedLines = foreach ($line in $case.GetProperty('expected_barrier_errors').EnumerateArray()) { $line.GetString() }
                $expected = @($expectedLines) -join "`n"
                try {
                    $actualLines = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $node.ToJsonString($null)
                    $actual = @($actualLines) -join "`n"
                    if ($actual -cne $expected) { $mismatches.Add("${name}: [$actual] != [$expected]") }
                }
                catch {
                    $mismatches.Add("${name}: threw $($_.Exception.Message)")
                }
                $executed++
            }
        }
        finally {
            $document.Dispose()
        }

        # Assert
        $caseCount | Should -BeGreaterThan 0 -Because "$FileName must carry at least one case"
        $executed | Should -Be $caseCount -Because "every case of $FileName must run"
        $mismatches | Should -BeNullOrEmpty -Because ($mismatches -join '; ')
    }

    It 'D1 fails closed on a non-integer numeric depends_on reference' {
        # Arrange: Python resolves 901.0 to issue_num 901 and reports a status line rendering 901.0.
        $text = ConvertTo-ParityCheckpointText -Feature @(
            '{"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"}',
            '{"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [901.0], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}')

        # Act / Assert
        { Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text } | Should -Throw -ExpectedMessage $script:UnevaluablePattern
    }

    It 'D2 orders astral-plane timestamps by UTF-16 code unit' {
        # Arrange: U+FF21 sorts after the surrogate pair of U+1F600 by code unit and before it by
        # code point, so the port reports the timing line that the Python authority does not.
        # Both characters are built at run time so this file stays ASCII.
        $fullWidthA = [string][char]0xFF21
        $grinningFace = [char]::ConvertFromUtf32(0x1F600)
        $text = ConvertTo-ParityCheckpointText -Feature @(
            ('{"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "' + $fullWidthA + '"}'),
            ('{"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "' + $grinningFace + '"}'))

        # Act
        $result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text

        # Assert
        (@($result) -join "`n") | Should -BeExactly 'EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 worktree_created_at precedes dependency 2026-10-08-alpha-901 merge_confirmed_at'
    }

    It 'D3 fails closed on an array issue_num' {
        # Arrange: Python raises TypeError when it indexes an unhashable issue_num.
        $text = ConvertTo-ParityCheckpointText -Feature @(
            '{"feature_folder": "2026-10-08-alpha-901", "issue_num": [901], "depends_on": [], "merge_status": "pr_open"}')

        # Act / Assert
        { Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text } | Should -Throw -ExpectedMessage $script:UnevaluablePattern
    }

    It 'D4 fails closed on a NaN literal' {
        # Arrange
        $text = ConvertTo-ParityCheckpointText -Feature @(
            '{"feature_folder": "2026-10-08-alpha-901", "depends_on": [], "merge_status": "merged", "merge_confirmed_at": NaN}')

        # Act / Assert
        { Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text } | Should -Throw -ExpectedMessage $script:UnevaluablePattern
    }

    It 'D5 fails closed on nesting deeper than the parser default' {
        # Arrange: a value nested in 70 arrays.
        $deep = ('[' * 70) + (']' * 70)
        $text = ConvertTo-ParityCheckpointText -Feature @(
            ('{"feature_folder": "2026-10-08-alpha-901", "depends_on": [], "merge_status": "merged", "notes": ' + $deep + '}'))

        # Act / Assert
        { Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text } | Should -Throw -ExpectedMessage $script:UnevaluablePattern
    }
}
