#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-orchestrator-output.ps1 SubagentStop hook.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected FileExistsCheck stubs mirror the production scriptblock signature param($Path) for testing')]
param()

BeforeAll {
    # Dot-source the hook so the test file can exercise the helper functions
    # without executing the script entrypoint.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'
    . $hookPath
}

Describe 'validate-orchestrator-output.ps1' {
    Context 'payload validation' {
        It 'blocks when CLAUDE_HOOK_INPUT is empty' {
            # Arrange
            $raw = ''

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'blocks when CLAUDE_HOOK_INPUT contains malformed JSON' {
            # Arrange
            $raw = '{ this is not valid json'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'failed to parse CLAUDE_HOOK_INPUT as JSON'
        }

        It 'blocks when the output field is empty' {
            # Arrange
            $raw = '{"output":""}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }

        It 'blocks when the JSON payload omits the output field entirely' {
            # Arrange — valid JSON but no "output" property
            $raw = '{"sessionId":"abc"}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }
    }

    Context 'checkpoint file presence' {
        It 'blocks when the checkpoint file does not exist' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith { @{ Exists = $false; Content = $null } }
            $raw = '{"output":"All steps complete."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'checkpoint file'
            $result.Message | Should -Match 'does not exist'
        }

        It 'blocks when the checkpoint file content is empty' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith { @{ Exists = $true; Content = '   ' } }
            $raw = '{"output":"Done."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'is empty'
        }
    }

    Context 'checkpoint structure validation' {
        It 'blocks when the checkpoint file is not valid JSON' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith { @{ Exists = $true; Content = '{ broken json' } }
            $raw = '{"output":"Done."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'is not valid JSON'
        }

        It 'blocks when checkpoint is missing required fields' {
            # Arrange — only objective present, others missing
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{ Exists = $true; Content = '{"objective":"work"}' }
            }
            $raw = '{"output":"Done."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'missing required field'
            $result.Message | Should -Match 'completed_steps'
            $result.Message | Should -Match 'next_step'
            $result.Message | Should -Match 'last_updated'
        }

        It 'blocks when checkpoint has empty objective' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"","completed_steps":[],"next_step":"x","last_updated":"2026-05-04T00-00"}'
                }
            }
            $raw = '{"output":"Done."}'

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "empty 'objective'"
        }

        It 'allows termination when all required fields are present and objective is set' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"deliver feature X","completed_steps":["step1"],"next_step":"step2","last_updated":"2026-05-04T00-00"}'
                }
            }
            $raw = '{"output":"Final summary: orchestration complete."}'
            # Inject a clean routing seam so no real Python subprocess runs.
            $routingStub = { param($Path) [pscustomobject]@{ ExitCode = 0; Output = '' } }

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }

    Context 'routing-contract validation (Gap 1)' {
        BeforeEach {
            # A structurally valid checkpoint that passes the presence checks so
            # the routing-contract seam is the deciding factor.
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"deliver feature X","completed_steps":["step1"],"next_step":"complete","last_updated":"2026-05-04T00-00"}'
                }
            }
        }

        It 'blocks DONE with ROUTING_CONTRACT_BLOCKED when the validator reports errors' {
            # Arrange — fabricated-route checkpoint: the injected seam reports the
            # validator error the Python validator would emit for an unknown route.
            $raw = '{"output":"Final summary."}'
            $routingStub = {
                param($Path)
                [pscustomobject]@{
                    ExitCode = 1
                    Output   = 'Checkpoint selected route is not a routing-matrix route: direct_powershell_engineer_remediation.'
                }
            }

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match '^ROUTING_CONTRACT_BLOCKED:'
            $result.Message | Should -Match 'direct_powershell_engineer_remediation'
        }

        It 'allows DONE when the routing validator returns a clean result' {
            # Arrange — seam reports a clean validator run (exit 0, no output).
            $raw = '{"output":"Final summary."}'
            $routingStub = { param($Path) [pscustomobject]@{ ExitCode = 0; Output = '' } }

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }

        It 'allows DONE when the validator exits 0 and prints its success line (issue #413)' {
            # Arrange — the live validator path: exit 0 with the success line on stdout,
            # folded into Output by the default invoker's 2>&1 capture. This must ALLOW.
            $raw = '{"output":"Final summary."}'
            $routingStub = {
                param($Path, $Type)
                [pscustomobject]@{
                    ExitCode = 0
                    Output   = 'orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json'
                }
            }

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }

        It 'is mockable without invoking Python (the injected scriptblock is used)' {
            # Arrange — a tracking seam that records it was called; if the hook
            # invoked Python instead, the tracker would not flip.
            $raw = '{"output":"Final summary."}'
            $script:seamInvoked = $false
            $routingStub = {
                param($Path)
                $script:seamInvoked = $true
                [pscustomobject]@{ ExitCode = 0; Output = '' }
            }

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            # Assert
            $script:seamInvoked | Should -BeTrue
            $result.Ok | Should -BeTrue
        }

        It 'blocks a fabricated-route checkpoint (pass-after for the P3-T1 fail-before)' {
            # Arrange — the silent-deviation scenario: a structurally valid
            # checkpoint selecting a fabricated route is now blocked.
            $raw = '{"output":"Final summary."}'
            $routingStub = {
                param($Path)
                [pscustomobject]@{
                    ExitCode = 1
                    Output   = 'Checkpoint selected route is not a routing-matrix route: direct_powershell_engineer_remediation.'
                }
            }

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'ROUTING_CONTRACT_BLOCKED'
        }
    }

    Context 'Invoke-RoutingContractValidation' {
        It 'reports HasErrors when the seam returns a non-zero exit code' {
            # Arrange
            $stub = { param($Path) [pscustomobject]@{ ExitCode = 1; Output = '' } }

            # Act
            $result = Invoke-RoutingContractValidation -CheckpointPath 'x.json' -Invoker $stub

            # Assert
            $result.HasErrors | Should -BeTrue
        }

        It 'reports HasErrors when the seam returns exit code 2 (argparse misuse / crash path stays fail-closed)' {
            # Arrange
            $stub = { param($Path, $Type) [pscustomobject]@{ ExitCode = 2; Output = 'usage: validate_orchestration_artifacts ...' } }

            # Act
            $result = Invoke-RoutingContractValidation -CheckpointPath 'x.json' -Invoker $stub

            # Assert
            $result.HasErrors | Should -BeTrue
        }

        It 'reports no errors when the seam returns exit 0 with the validator success line (issue #413)' {
            # Arrange — the authoritative validator prints this line to stdout and exits 0;
            # the 2>&1 capture folds it into Output, so exit 0 with text is the success shape.
            $stub = {
                param($Path, $Type)
                [pscustomobject]@{
                    ExitCode = 0
                    Output   = 'orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json'
                }
            }

            # Act
            $result = Invoke-RoutingContractValidation -CheckpointPath 'x.json' -Invoker $stub

            # Assert
            $result.HasErrors | Should -BeFalse
        }

        It 'reports no errors when the seam returns exit 0 and empty output' {
            # Arrange
            $stub = { param($Path) [pscustomobject]@{ ExitCode = 0; Output = '' } }

            # Act
            $result = Invoke-RoutingContractValidation -CheckpointPath 'x.json' -Invoker $stub

            # Assert
            $result.HasErrors | Should -BeFalse
            $result.ErrorText | Should -BeNullOrEmpty
        }

        It 'defaults ArtifactType to orchestrator-state when not supplied (default-preserves-existing-behavior)' {
            # Arrange — capture the ArtifactType the seam receives so the default
            # invocation string is provably unchanged for existing callers.
            $script:capturedType = $null
            $stub = {
                param($Path, $Type)
                $script:capturedType = $Type
                [pscustomobject]@{ ExitCode = 0; Output = '' }
            }

            # Act
            Invoke-RoutingContractValidation -CheckpointPath 'x.json' -Invoker $stub | Out-Null

            # Assert
            $script:capturedType | Should -Be 'orchestrator-state'
        }

        It 'threads a custom ArtifactType into the seam when supplied' {
            # Arrange
            $script:capturedType = $null
            $stub = {
                param($Path, $Type)
                $script:capturedType = $Type
                [pscustomobject]@{ ExitCode = 0; Output = '' }
            }

            # Act
            Invoke-RoutingContractValidation -CheckpointPath 'epic.json' -ArtifactType 'epic-orchestrator-state' -Invoker $stub | Out-Null

            # Assert
            $script:capturedType | Should -Be 'epic-orchestrator-state'
        }
    }

    Context '-CheckpointPath / -ArtifactType parameterization (Invoke-OrchestratorOutputValidation)' {
        It 'threads a custom CheckpointPath and ArtifactType into the routing seam' {
            # Arrange — a clean checkpoint so the routing seam is the deciding factor.
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"deliver feature X","completed_steps":["step1"],"next_step":"complete","last_updated":"2026-05-04T00-00"}'
                }
            }
            $raw = '{"output":"Final summary."}'
            $script:capturedPath = $null
            $script:capturedType = $null
            $routingStub = {
                param($Path, $Type)
                $script:capturedPath = $Path
                $script:capturedType = $Type
                [pscustomobject]@{ ExitCode = 0; Output = '' }
            }

            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -CheckpointPath 'artifacts/orchestration/epic-orchestrator-state.json' -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $routingStub

            # Assert
            $result.Ok | Should -BeTrue
            $script:capturedPath | Should -Be 'artifacts/orchestration/epic-orchestrator-state.json'
            $script:capturedType | Should -Be 'epic-orchestrator-state'
        }

        It 'defaults CheckpointPath and ArtifactType to the per-feature checkpoint (default-preserves-existing-behavior)' {
            # Arrange
            Mock -CommandName Get-CheckpointFileContent -MockWith {
                @{
                    Exists  = $true
                    Content = '{"objective":"deliver feature X","completed_steps":["step1"],"next_step":"complete","last_updated":"2026-05-04T00-00"}'
                }
            }
            $raw = '{"output":"Final summary."}'
            $script:capturedPath = $null
            $script:capturedType = $null
            $routingStub = {
                param($Path, $Type)
                $script:capturedPath = $Path
                $script:capturedType = $Type
                [pscustomobject]@{ ExitCode = 0; Output = '' }
            }

            # Act — no -CheckpointPath / -ArtifactType supplied.
            $result = Invoke-OrchestratorOutputValidation -RawPayload $raw -RoutingInvoker $routingStub

            # Assert
            $result.Ok | Should -BeTrue
            $script:capturedPath | Should -Be 'artifacts/orchestration/orchestrator-state.json'
            $script:capturedType | Should -Be 'orchestrator-state'
        }
    }

    Context 'Get-CheckpointFileContent' {
        It 'reports Exists=$false for a path that does not exist' {
            # Arrange
            $missing = Join-Path $PSScriptRoot 'this-checkpoint-definitely-does-not-exist.json'

            # Act
            $result = Get-CheckpointFileContent -Path $missing

            # Assert
            $result.Exists | Should -BeFalse
            $result.Content | Should -BeNullOrEmpty
        }

        It 'reads content from a real file on disk (uses the test file as fixture)' {
            # Arrange — read this very test file; it is guaranteed to exist
            $self = $PSCommandPath

            # Act
            $result = Get-CheckpointFileContent -Path $self

            # Assert — the test file contains a marker for coverage verification
            $result.Exists | Should -BeTrue
            $result.Content | Should -Match 'orchestrator-fixture-marker-for-coverage'
        }
    }
    # orchestrator-fixture-marker-for-coverage

    # Test-HumanInteractionShape tests moved to
    # validate-orchestrator-output.human-interaction.Tests.ps1 to keep this
    # file under the 500-line cap.

    Context 'portable-path routing (no interpreter subprocess)' {
        BeforeAll {
            # Pre-import the portable completion module so its function is a resolvable
            # command that tests can mock to detect whether the portable branch runs.
            $portableModule = (Resolve-Path "$PSScriptRoot/../../../.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1").Path
            Import-Module $portableModule -Force
        }

        It 'routes the default orchestrator-state dispatch to the portable completion seam' {
            # The default routing invoker has exactly one path for the standard
            # checkpoint type: the portable completion validation. No capability probe
            # decides between branches any more.
            Mock -CommandName Test-OrchestratorStateCompletionReadiness -MockWith { @{ ExitCode = 0; Output = '' } }

            $result = Invoke-RoutingContractValidation -CheckpointPath 'artifacts/orchestration/orchestrator-state.nonexistent-fixture.json'

            $result.HasErrors | Should -BeFalse
            Should -Invoke -CommandName Test-OrchestratorStateCompletionReadiness -Times 1 -Exactly
        }

        It 'invokes no python, python3, py, or poetry command anywhere in the default invoker' {
            # Negative-invocation AST assertion (issue #475): the inverse of the former
            # source-text assertion that pinned the interpreter invocation string. Each
            # CommandAst is classified by its resolved command name, so an interpreter
            # name in a comment or string neither satisfies nor defeats this assertion.
            $functionAst = ${function:Invoke-RoutingContractValidation}.Ast
            $commandAsts = @($functionAst.FindAll(
                    { param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))

            $bannedNames = @('python', 'python3', 'py', 'poetry')
            $invokedNames = @(
                $commandAsts |
                    ForEach-Object { $_.GetCommandName() } |
                        Where-Object { $_ } |
                            ForEach-Object { $_.ToLowerInvariant() }
            )
            $violations = @($invokedNames | Where-Object { $bannedNames -contains $_ })

            $violations | Should -BeNullOrEmpty -Because (
                'the default invoker must name no interpreter on any code path; found: ' + ($violations -join ', '))
        }
    }
}
