#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-discovery-artifact-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-discovery-artifact-gate.ps1").Path
        . $script:UnderTest

        # Builds a Write-style CLAUDE_TOOL_INPUT JSON string for a discovery
        # artifact write.
        function ConvertTo-DiscoveryToolInput {
            param(
                [string] $FilePath,
                [string] $Content = '{}'
            )
            return (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = $FilePath; content = $Content }
                } | ConvertTo-Json -Compress -Depth 8)
        }

        # A required-artifact reader stub that reports the domain-profile
        # declaration as present, so the validator seam is invoked.
        $script:PresentReader = { @{ Present = $true; Declaration = @{ types = @('coverage-ledger') } } }
    }

    Context 'recognized, conforming artifact' {
        It 'allows the write and invokes the validator exactly once' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryToolInput -FilePath 'discovery/coverage-ledger/coverage-ledger.json'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json -RequiredArtifactReader $script:PresentReader

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly
        }
    }

    Context 'recognized, non-conforming artifact' {
        It 'denies the write with the validator text embedded verbatim' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }

            $json = ConvertTo-DiscoveryToolInput -FilePath 'discovery/coverage-ledger/coverage-ledger.json'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json -RequiredArtifactReader $script:PresentReader

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match ([regex]::Escape('schema violation: missing field x'))
        }
    }

    Context 'unrecognized artifact path' {
        It 'allows without invoking the validator when file_path does not resolve to a discovery-artifact type' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryToolInput -FilePath 'src/unrelated/module.ps1'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json -RequiredArtifactReader $script:PresentReader

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }

        It 'Get-DiscoveryArtifactType returns $null for an unrecognized path' {
            Get-DiscoveryArtifactType -Path 'src/unrelated/module.ps1' | Should -BeNullOrEmpty
        }
    }

    Context 'fail-open when the domain profile is absent' {
        It 'allows without invoking the validator when the required-artifact-declaration seam reports absent' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryToolInput -FilePath 'discovery/coverage-ledger/coverage-ledger.json'
            # No -RequiredArtifactReader override: exercises the default seam,
            # which reports the domain profile absent (Present = $false).
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
    }

    Context 'envelope anomalies fail closed' {
        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw '{not-json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies an empty payload without invoking the validator' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'DISCOVERY_ARTIFACT_GATE_BLOCKED'
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }

        It 'denies an absent payload without invoking the validator' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $null

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $flat = '{"file_path":"discovery/coverage-ledger/coverage-ledger.json","content":"{}"}'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $flat

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
    }

    Context 'validator-not-found-style failure' {
        It 'denies identically to any other non-conforming result (not silently allowed)' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'ModuleNotFoundError: No module named scripts.dev_tools.validate_discovery_artifacts' } }

            $json = ConvertTo-DiscoveryToolInput -FilePath 'discovery/coverage-ledger/coverage-ledger.json'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json -RequiredArtifactReader $script:PresentReader

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'Edit tool calls (no full content)' {
        It 'allows unconditionally without invoking the validator' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = '{"tool_name":"Edit","tool_input":{"file_path":"discovery/coverage-ledger/coverage-ledger.json","old_string":"a","new_string":"b"}}'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json -RequiredArtifactReader $script:PresentReader

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
    }

    Context 'domain neutrality' {
        It 'contains no TaskMaster/TMW/Outlook/VSTO token in its own source text' {
            $sourceText = Get-Content -LiteralPath $script:UnderTest -Raw
            $sourceText | Should -Not -Match 'TaskMaster|TMW|Outlook|VSTO'
        }
    }

    Context 'missing file_path' {
        It 'allows without invoking the validator when content is present but file_path is absent' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = '{"tool_name":"Write","tool_input":{"content":"{}"}}'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json -RequiredArtifactReader $script:PresentReader

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
    }

    Context 'Get-RequiredDiscoveryArtifactDeclaration seam' {
        It 'reports Present = $true with the declaration when the profile reader returns a value' {
            $reader = { @{ types = @('coverage-ledger') } }

            $result = Get-RequiredDiscoveryArtifactDeclaration -ProfileReader $reader

            $result.Present | Should -Be $true
            $result.Declaration | Should -Not -BeNullOrEmpty
        }
    }

    Context 'script entrypoint transport' {
        It 'reads the payload through the shared reader' {
            $hookText = Get-Content -LiteralPath $script:UnderTest -Raw

            $hookText | Should -BeLike '*HookPayload.psm1*'
            $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }

        It 'denies an unparseable envelope rather than exiting 1' {
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw '{not-json'

            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'defect D-2 avoidance: a passing validation must yield an allow verdict' {
        It 'allows the write when the validator reports success with EMPTY output' {
            # This is the shape the portable module now returns on success. The gate
            # denies on a non-zero exit code OR on non-empty output, so success must be
            # silent for a passing validation to be allowed.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryToolInput -FilePath 'discovery/coverage-ledger/coverage-ledger.json'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json -RequiredArtifactReader $script:PresentReader

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeNullOrEmpty
        }

        It 'denies when the validator reports success but emits a success line' {
            # The defect itself. The previous Python CLI printed
            # "<type> validation passed: <path>" on success, and the wrapper captured
            # stdout, so a PASSING validation produced a DENY. This pins that the
            # deny-on-non-empty-output logic is unchanged and that the fix is the
            # module's empty-output success contract, not a relaxed gate.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = 'coverage-ledger validation passed: discovery/coverage-ledger/coverage-ledger.json' } }

            $json = ConvertTo-DiscoveryToolInput -FilePath 'discovery/coverage-ledger/coverage-ledger.json'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json -RequiredArtifactReader $script:PresentReader

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
        }

        It 'allows the write when the validator reports success with whitespace-only output' {
            # The gate treats whitespace-only output as empty.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = "   " } }

            $json = ConvertTo-DiscoveryToolInput -FilePath 'discovery/coverage-ledger/coverage-ledger.json'
            $decision = Invoke-DiscoveryArtifactGateDecision -ToolInputRaw $json -RequiredArtifactReader $script:PresentReader

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
