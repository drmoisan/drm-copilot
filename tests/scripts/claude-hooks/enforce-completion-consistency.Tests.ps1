#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected FolderExistsCheck stubs mirror the production scriptblock signature param($p) for testing')]
param()

Describe 'enforce-completion-consistency.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-completion-consistency.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointFileContent' -Surface 'Codex'

        # Builds a Write-shaped PreToolUse envelope for a checkpoint payload.
        function ConvertTo-CheckpointToolInput {
            param(
                [hashtable] $Payload,
                [string] $FilePath = 'artifacts/orchestration/orchestrator-state.json'
            )
            $content = $Payload | ConvertTo-Json -Compress -Depth 8
            return (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = $FilePath; content = $content }
                } | ConvertTo-Json -Compress -Depth 8)
        }
    }

    Context 'tool input parsing' {
        It 'allows when file_path is missing from a well-formed tool_input' {
            (Invoke-CompletionConsistencyDecision -ToolInputRaw '{"tool_name":"Write","tool_input":{"content":"{}"}}').hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when content itself is not valid JSON (defers to downstream tools)' {
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = '{broken' }
                } | ConvertTo-Json -Compress -Depth 8)
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'path matching (non-checkpoint path is allowed)' {
        It 'allows a file_path other than the checkpoint' {
            $json = ConvertTo-CheckpointToolInput -FilePath 'some/other.json' -Payload @{ next_step = 'complete' }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Edit tool calls (no full content)' {
        It 'denies an Edit-style call with old_string/new_string as checkpoint-empty when the injected reader returns an empty string' {
            $json = '{"tool_name":"Edit","tool_input":{"file_path":"artifacts/orchestration/orchestrator-state.json","old_string":"a","new_string":"b"}}'
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader { param($Path) '' }).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'checkpoint not asserting completion is allowed' {
        It 'allows a checkpoint whose next_step is not complete and has no completion markers' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step       = 'S5_atomic_execution'
                completed_steps = @('S0_startup_checks', 'S4_atomic_planning')
                step8_status    = 'in_progress'
                step9_status    = 'pending'
                step10_status   = 'pending'
            }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'completion asserted with full evidence is allowed' {
        It 'allows when issue-num, feature-folder, and a success ci_gate with head_sha are present' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '207'
                'feature-folder' = 'docs/features/active/2026-06-19-harden-small-path-completion-gate-207'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true }).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'accepts variables.issue-num and variables.feature-folder fallbacks' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                completed_steps = @('S12_complete')
                variables       = @{ 'issue-num' = '207'; 'feature-folder' = 'docs/features/active/feature-207' }
                ci_gate         = @{ conclusion = 'success'; head_sha = 'abc123' }
            }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true }).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Route-driven pr_gate enforcement (Gap 4)' {
        BeforeEach {
            # Inject a routing matrix and a folder-exists seam so the route-driven
            # pr_gate decision is deterministic and filesystem-independent.
            $script:matrixWithPrGate = {
                [pscustomobject]@{
                    routes = [pscustomobject]@{
                        large     = [pscustomobject]@{ requires_pr_gate = $true }
                        small     = [pscustomobject]@{ }
                        custom_pr = [pscustomobject]@{ requires_pr_gate = $true }
                    }
                }
            }
            $script:folderTrue = { param($p) $true }
        }

        It 'requires pr_gate and blocks when a requires_pr_gate route omits PR evidence' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '300'
                'feature-folder' = 'docs/features/active/feature-300'
                path_selected    = 'large'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }

            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $script:folderTrue -RoutingMatrixReader $script:matrixWithPrGate

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'pr_gate'
        }

        It 'does NOT require pr_gate for the small route (no requires_pr_gate)' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '301'
                'feature-folder' = 'docs/features/active/feature-301'
                path_selected    = 'small'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }

            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $script:folderTrue -RoutingMatrixReader $script:matrixWithPrGate).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'enforces the gate for a non-232 route with requires_pr_gate true (route-driven, not issue-driven)' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '999'
                'feature-folder' = 'docs/features/active/feature-999'
                route_id         = 'custom_pr'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }

            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $script:folderTrue -RoutingMatrixReader $script:matrixWithPrGate

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'pr_gate'
        }

        It 'blocks when a requires_pr_gate route has stale ci_gate.head_sha versus pr_gate.head_sha' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '300'
                'feature-folder' = 'docs/features/active/feature-300'
                path_selected    = 'large'
                pr_gate          = @{
                    pr_number   = 300
                    pr_url      = 'https://github.com/drmoisan/drm-copilot/pull/300'
                    head_branch = 'feature/feature-300'
                    head_sha    = 'current-head'
                }
                ci_gate          = @{ conclusion = 'success'; head_sha = 'stale-head' }
            }

            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $script:folderTrue -RoutingMatrixReader $script:matrixWithPrGate

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'ci_gate.head_sha'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'pr_gate.head_sha'
        }

        It 'allows when a requires_pr_gate route supplies complete matching PR and CI evidence' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '300'
                'feature-folder' = 'docs/features/active/feature-300'
                path_selected    = 'large'
                pr_gate          = @{
                    pr_number   = 300
                    pr_url      = 'https://github.com/drmoisan/drm-copilot/pull/300'
                    head_branch = 'feature/feature-300'
                    head_sha    = 'current-head'
                }
                ci_gate          = @{ conclusion = 'success'; head_sha = 'current-head' }
            }

            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $script:folderTrue -RoutingMatrixReader $script:matrixWithPrGate).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Test-RouteRequiresPrGate unit behavior' {
        It 'returns true for a route whose requires_pr_gate is true' {
            $reader = { [pscustomobject]@{ routes = [pscustomobject]@{ large = [pscustomobject]@{ requires_pr_gate = $true } } } }
            Test-RouteRequiresPrGate -Payload ([pscustomobject]@{ path_selected = 'large' }) -RoutingMatrixReader $reader | Should -BeTrue
        }

        It 'returns false for a route without requires_pr_gate' {
            $reader = { [pscustomobject]@{ routes = [pscustomobject]@{ small = [pscustomobject]@{ } } } }
            Test-RouteRequiresPrGate -Payload ([pscustomobject]@{ path_selected = 'small' }) -RoutingMatrixReader $reader | Should -BeFalse
        }

        It 'returns false for an unknown route' {
            $reader = { [pscustomobject]@{ routes = [pscustomobject]@{ small = [pscustomobject]@{ } } } }
            Test-RouteRequiresPrGate -Payload ([pscustomobject]@{ path_selected = 'fabricated' }) -RoutingMatrixReader $reader | Should -BeFalse
        }

        It 'returns false when the payload selects no route' {
            $reader = { [pscustomobject]@{ routes = [pscustomobject]@{ large = [pscustomobject]@{ requires_pr_gate = $true } } } }
            Test-RouteRequiresPrGate -Payload ([pscustomobject]@{ }) -RoutingMatrixReader $reader | Should -BeFalse
        }
    }

    Context 'completion asserted with missing ci_gate is blocked' {
        It 'blocks and references ci_gate when ci_gate is absent' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '207'
                'feature-folder' = 'docs/f'
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'ci_gate'
        }
    }

    Context 'completion asserted with success ci_gate but empty issue-num is blocked' {
        It 'blocks and references issue-num' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                completed_steps  = @('S12_complete')
                'issue-num'      = ''
                'feature-folder' = 'docs/f'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123' }
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'issue-num'
        }
    }

    Context 'completion asserted with empty feature-folder is blocked' {
        It 'blocks and references feature-folder' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                step8_status     = 'completed'
                'issue-num'      = '207'
                'feature-folder' = ''
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123' }
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'feature-folder'
        }
    }

    Context 'completion asserted with ci_gate.conclusion != success is blocked' {
        It 'blocks and references ci_gate conclusion' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '207'
                'feature-folder' = 'docs/f'
                ci_gate          = @{ conclusion = 'failure'; head_sha = 'abc123' }
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'conclusion'
        }
    }

    Context 'Sentinel issue-num and feature-folder rejection (Gap 2)' {
        BeforeEach {
            # Inject a folder-exists seam so the feature-folder validity check is
            # deterministic and does not depend on filesystem state.
            $script:folderExistsTrue = { param($p) $true }
        }

        It 'blocks issue-num sentinel "<sentinel>"' -ForEach @(
            @{ sentinel = 'n/a' }
            @{ sentinel = 'none' }
            @{ sentinel = 'tbd' }
            @{ sentinel = '  ' }
            @{ sentinel = '' }
        ) {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = $sentinel
                'feature-folder' = 'docs/features/active/my-feature-233'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $script:folderExistsTrue
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'issue-num'
        }

        It 'allows a digits-only issue-num with a valid existing feature-folder' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '123'
                'feature-folder' = 'docs/features/active/my-feature-233'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $script:folderExistsTrue).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'blocks a feature-folder sentinel "n/a"' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '253'
                'feature-folder' = 'n/a'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $script:folderExistsTrue
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'feature-folder'
        }

        It 'allows a valid docs/features/active/... feature-folder that exists' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '233'
                'feature-folder' = 'docs/features/active/my-feature-233'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $script:folderExistsTrue).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'blocks a valid-shaped feature-folder when the injected existence check returns false' {
            $folderExistsFalse = { param($p) $false }
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '233'
                'feature-folder' = 'docs/features/active/my-feature-233'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck $folderExistsFalse
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'feature-folder'
        }
    }

    Context 'Edit-tool read-then-validate (Gap 3)' {
        It 'blocks an Edit whose patched checkpoint asserts completion without evidence' {
            # Arrange - on-disk checkpoint does not assert completion; the Edit
            # patch flips next_step to complete with no evidence fields.
            $onDisk = '{"objective":"x","next_step":"S5_atomic_execution"}'
            $reader = { param($Path) $onDisk }
            $json = @{
                tool_name  = 'Edit'
                tool_input = @{
                    file_path  = 'artifacts/orchestration/orchestrator-state.json'
                    old_string = '"next_step":"S5_atomic_execution"'
                    new_string = '"next_step":"complete"'
                }
            } | ConvertTo-Json -Compress -Depth 8

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
        }

        It 'allows an Edit whose patched checkpoint does not assert completion' {
            $onDisk = '{"objective":"x","next_step":"S5_atomic_execution"}'
            $reader = { param($Path) $onDisk }
            $json = @{
                tool_name  = 'Edit'
                tool_input = @{
                    file_path  = 'artifacts/orchestration/orchestrator-state.json'
                    old_string = '"next_step":"S5_atomic_execution"'
                    new_string = '"next_step":"S6_review"'
                }
            } | ConvertTo-Json -Compress -Depth 8

            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies an Edit when the on-disk checkpoint file does not exist' {
            $reader = { param($Path) $null }
            $json = @{
                tool_name  = 'Edit'
                tool_input = @{
                    file_path  = 'artifacts/orchestration/orchestrator-state.json'
                    old_string = 'a'
                    new_string = '"next_step":"complete"'
                }
            } | ConvertTo-Json -Compress -Depth 8

            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies an Edit when old_string is not found in the on-disk content' {
            $onDisk = '{"objective":"x","next_step":"S5_atomic_execution"}'
            $reader = { param($Path) $onDisk }
            $json = @{
                tool_name  = 'Edit'
                tool_input = @{
                    file_path  = 'artifacts/orchestration/orchestrator-state.json'
                    old_string = 'this-substring-is-absent'
                    new_string = '"next_step":"complete"'
                }
            } | ConvertTo-Json -Compress -Depth 8

            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows an Edit on a non-checkpoint path' {
            $reader = { param($Path) '{"next_step":"complete"}' }
            $json = @{
                tool_name  = 'Edit'
                tool_input = @{
                    file_path  = 'some/other/file.json'
                    old_string = 'a'
                    new_string = '"next_step":"complete"'
                }
            } | ConvertTo-Json -Compress -Depth 8

            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json -CheckpointReader $reader).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Completion-helper unit behavior (Gap 2 helpers)' {
        It 'Test-IsValidIssueNum returns true for digits-only' {
            Test-IsValidIssueNum -Value '253' | Should -BeTrue
        }

        It 'Test-IsValidIssueNum returns false for sentinel/non-digit "<value>"' -ForEach @(
            @{ value = 'n/a' }
            @{ value = 'none' }
            @{ value = 'TBD' }
            @{ value = '12a' }
            @{ value = '' }
            @{ value = '   ' }
        ) {
            Test-IsValidIssueNum -Value $value | Should -BeFalse
        }

        It 'Test-IsValidFeatureFolder returns false for the bare active prefix' {
            Test-IsValidFeatureFolder -Value 'docs/features/active/' -FolderExistsCheck { param($p) $true } | Should -BeFalse
        }

        It 'Test-IsValidFeatureFolder returns false for a folder outside docs/features/active/' {
            Test-IsValidFeatureFolder -Value 'docs/other/thing' -FolderExistsCheck { param($p) $true } | Should -BeFalse
        }

        It 'Test-IsValidFeatureFolder returns true for an existing .dev/active folder (issue #1035)' {
            $probed = [System.Collections.Generic.List[string]]::new()
            Test-IsValidFeatureFolder -Value '.dev/active/my-feature-233' -FolderExistsCheck { param($p) $probed.Add($p); $true }.GetNewClosure() | Should -BeTrue
            $probed | Should -Be @('.dev/active/my-feature-233')
        }

        It 'Test-IsValidFeatureFolder returns false for the bare .dev/active prefix (issue #1035)' {
            Test-IsValidFeatureFolder -Value '.dev/active/' -FolderExistsCheck { param($p) $true } | Should -BeFalse
        }

        It 'Test-IsValidFeatureFolder returns true for a valid existing folder' {
            Test-IsValidFeatureFolder -Value 'docs/features/active/my-feature-233' -FolderExistsCheck { param($p) $true } | Should -BeTrue
        }
    }

    Context 'JSON-parse seam is mockable' {
        It 'allows when the mocked content parser throws (invalid content JSON path)' {
            Mock -CommandName ConvertFrom-CheckpointJson -MockWith { throw 'simulated parse failure' }
            $json = ConvertTo-CheckpointToolInput -Payload @{ next_step = 'complete' }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke -CommandName ConvertFrom-CheckpointJson -Times 1
        }
    }

    Context 'issue #663 epic checkpoint pinning (D3)' {
        # Decision D3: gate 5 has no production change. These rows record current behavior.
        It 'issue #663 does not intercept a completion-asserting Write to epic-orchestrator-state.json' {
            # Arrange: completion is asserted and ci_gate is absent, which the per-feature
            # checkpoint would deny; the epic checkpoint path is not the gated path.
            $json = ConvertTo-CheckpointToolInput -FilePath 'artifacts/orchestration/epic-orchestrator-state.json' -Payload @{
                next_step        = 'complete'
                'issue-num'      = '663'
                'feature-folder' = 'docs/features/epics/sample-epic'
            }

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'issue #663 still denies a per-feature checkpoint whose feature-folder is under docs/features/epics/' {
            # Arrange: full CI evidence, but the feature folder is outside docs/features/active/.
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '663'
                'feature-folder' = 'docs/features/epics/sample-epic'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true }

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED*'
        }
    }

    Context 'child CI opt-out (issue #1233)' {
        BeforeAll {
            $script:optOutHead = '3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f'
            $script:optOutPrGateMatrix = {
                [pscustomobject]@{ routes = [pscustomobject]@{ large = [pscustomobject]@{ requires_pr_gate = $true } } }
            }
            $script:preChangeReason = "COMPLETION_CONSISTENCY_BLOCKED: the checkpoint asserts completion but is missing required completion evidence: ci_gate (object with conclusion == `"success`" and non-empty head_sha). A completion-asserting checkpoint must include a non-empty issue-num, a non-empty feature-folder, and a ci_gate object with conclusion == 'success' and a non-empty head_sha; routes whose requires_pr_gate is true must also include pr_gate evidence with a matching head_sha. Supply the missing evidence or remove the completion assertion."

            # Builds an opted-out completion payload; Gate replaces local_qc_gate, and RemoveGate drops it.
            function ConvertTo-OptOutCompletionPayload {
                param([hashtable] $Gate, [switch] $RemoveGate)

                $payload = @{
                    next_step        = 'complete'
                    'issue-num'      = '1233'
                    'feature-folder' = 'docs/features/active/feature-1233'
                    path_selected    = 'large'
                    epic_mode        = $true
                    child_ci         = 'integration_only'
                    pr_gate          = @{ pr_number = '42'; pr_url = 'https://github.com/o/r/pull/42'; head_branch = 'feature/x'; head_sha = 'ffffffffffffffffffffffffffffffffffffffff' }
                    local_qc_gate    = @{ conclusion = 'success'; head_sha = $script:optOutHead; evidence_path = 'docs/features/active/feature-1233/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md'; verified_at = '2026-11-24T05:00:00Z' }
                }
                if ($Gate) { $payload['local_qc_gate'] = $Gate }
                if ($RemoveGate) { $payload.Remove('local_qc_gate') }
                return $payload
            }
        }

        It 'allows DONE with a valid local_qc_gate, no ci_gate, and a pr_gate head that differs from the local head' {
            # Arrange
            $json = ConvertTo-CheckpointToolInput -Payload (ConvertTo-OptOutCompletionPayload)

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true } -RoutingMatrixReader $script:optOutPrGateMatrix

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because ([string]$decision.hookSpecificOutput.permissionDecisionReason)
        }

        It 'denies DONE naming <Missing> for <Label>' -ForEach @(
            @{ Label = 'an absent local_qc_gate'; Gate = $null; Remove = $true; Missing = 'local_qc_gate (object with' }
            @{ Label = 'a failure conclusion'; Gate = @{ conclusion = 'failure'; head_sha = 'h'; evidence_path = 'p' }; Remove = $false; Missing = 'local_qc_gate.conclusion == "success"' }
            @{ Label = 'an empty head_sha'; Gate = @{ conclusion = 'success'; head_sha = ''; evidence_path = 'p' }; Remove = $false; Missing = 'local_qc_gate.head_sha' }
            @{ Label = 'an absent evidence_path'; Gate = @{ conclusion = 'success'; head_sha = 'h' }; Remove = $false; Missing = 'local_qc_gate.evidence_path' }
        ) {
            # Arrange
            $json = ConvertTo-CheckpointToolInput -Payload (ConvertTo-OptOutCompletionPayload -Gate $Gate -RemoveGate:$Remove)

            # Act
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true } -RoutingMatrixReader $script:optOutPrGateMatrix

            # Assert
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.Contains($Missing) | Should -BeTrue -Because $reason
        }

        It 'names the local_qc_gate alternative in the opt-out deny reason' {
            # Arrange
            $json = ConvertTo-CheckpointToolInput -Payload (ConvertTo-OptOutCompletionPayload -RemoveGate)

            # Act
            $reason = [string](Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true } -RoutingMatrixReader $script:optOutPrGateMatrix).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason | Should -BeLike 'COMPLETION_CONSISTENCY_BLOCKED:*local_qc_gate object with conclusion*in place of a ci_gate object*'
        }

        It 'keeps the pre-change deny reason byte-unchanged for a keyless checkpoint' {
            # Arrange
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '1233'
                'feature-folder' = 'docs/features/active/feature-1233'
                path_selected    = 'small'
            }

            # Act
            $reason = [string](Invoke-CompletionConsistencyDecision -ToolInputRaw $json -FolderExistsCheck { param($p) $true } -RoutingMatrixReader $script:optOutPrGateMatrix).hookSpecificOutput.permissionDecisionReason

            # Assert
            $reason | Should -BeExactly $script:preChangeReason
        }
    }
}
