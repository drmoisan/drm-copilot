#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'validate-discovery-artifact-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-discovery-artifact-gate.ps1").Path
        . $script:UnderTest

        # Builds a SubagentStop envelope JSON string whose last_assistant_message
        # carries a subagent's last assistant message.
        function ConvertTo-DiscoveryEnvelopeJson {
            param(
                [AllowEmptyString()] [string] $AssistantMessage
            )
            return ([ordered]@{ session_id = 'e3-905'; hook_event_name = 'SubagentStop'; stop_hook_active = $false; last_assistant_message = $AssistantMessage } | ConvertTo-Json -Compress -Depth 8)
        }

        # A required-artifact reader stub that reports the domain-profile
        # declaration as present, so the validator seam is invoked.
        $script:PresentReader = { @{ Present = $true; Declaration = @{ types = @('coverage-ledger') } } }
    }

    Context 'recognized, conforming referenced artifact' {
        It 'returns Ok = $true and invokes the validator exactly once' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            $result = Invoke-DiscoveryArtifactGateValidation -InputText $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $true
            $result.Message | Should -BeNullOrEmpty
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly
        }
    }

    Context 'recognized, non-conforming referenced artifact' {
        It 'returns Ok = $false with the validator text embedded verbatim' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }

            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            $result = Invoke-DiscoveryArtifactGateValidation -InputText $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $false
            $result.Message | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
            $result.Message | Should -Match ([regex]::Escape('schema violation: missing field x'))
        }
    }

    Context 'no recognized artifact reference' {
        It 'returns Ok = $true without invoking the validator' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage 'Completed the assigned task with no artifact writes.'
            $result = Invoke-DiscoveryArtifactGateValidation -InputText $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $true
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
    }

    Context 'fail-open when the domain profile is absent' {
        It 'returns Ok = $true without invoking the validator when the seam reports absent' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            # No -RequiredArtifactReader override: exercises the default seam,
            # which reports the domain profile absent (Present = $false).
            $result = Invoke-DiscoveryArtifactGateValidation -InputText $json

            $result.Ok | Should -Be $true
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
    }

    Context 'invalid envelope' {
        It 'returns Ok = $false with a payload anomaly message for empty input text' {
            $result = Invoke-DiscoveryArtifactGateValidation -InputText ''

            $result.Ok | Should -Be $false
            $result.Message | Should -Match 'DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly'
        }

        It 'returns Ok = $false with a payload anomaly message for malformed input text' {
            $result = Invoke-DiscoveryArtifactGateValidation -InputText '{not-json'

            $result.Ok | Should -Be $false
            $result.Message | Should -Match 'DISCOVERY_ARTIFACT_GATE_BLOCKED: payload anomaly'
        }
    }

    Context 'validator-not-found-style failure' {
        It 'returns Ok = $false identically to any other non-conforming result' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'ModuleNotFoundError: No module named scripts.dev_tools.validate_discovery_artifacts' } }

            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            $result = Invoke-DiscoveryArtifactGateValidation -InputText $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $false
        }
    }

    Context 'domain neutrality' {
        It 'contains no TaskMaster/TMW/Outlook/VSTO token in its own source text' {
            $sourceText = Get-Content -LiteralPath $script:UnderTest -Raw
            $sourceText | Should -Not -Match 'TaskMaster|TMW|Outlook|VSTO'
        }
    }

    Context 'empty assistant message' {
        It 'returns Ok = $true without invoking the validator when last_assistant_message is an empty string' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $result = Invoke-DiscoveryArtifactGateValidation -InputText (ConvertTo-DiscoveryEnvelopeJson -AssistantMessage '') -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $true
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

    Context 'defect D-2 avoidance: a passing validation must yield an Ok result' {
        It 'returns Ok = $true when the validator reports success with EMPTY output' {
            # This is the shape the portable module now returns on success. The gate
            # blocks on a non-zero exit code OR on non-empty output, so success must be
            # silent for a passing validation to be accepted.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            $result = Invoke-DiscoveryArtifactGateValidation -InputText $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $true
            $result.Message | Should -BeNullOrEmpty
        }

        It 'returns Ok = $false when the validator reports success but emits a success line' {
            # The defect itself. The previous Python CLI printed
            # "<type> validation passed: <path>" on success, and the wrapper captured
            # stdout, so a PASSING validation blocked the gate. This pins that the
            # block-on-non-empty-output logic is unchanged and that the fix is the
            # module's empty-output success contract, not a relaxed gate.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = 'coverage-ledger validation passed: discovery/coverage-ledger/coverage-ledger.json' } }

            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            $result = Invoke-DiscoveryArtifactGateValidation -InputText $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $false
            $result.Message | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
        }

        It 'returns Ok = $true when the validator reports success with whitespace-only output' {
            # The gate treats whitespace-only output as empty.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = "   " } }

            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            $result = Invoke-DiscoveryArtifactGateValidation -InputText $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $true
        }
    }

    Context 'script entrypoint (stdin envelope, issue #905)' {
        BeforeAll {
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
            $script:FailingArtifactText = 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'

            . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')

            function Invoke-DiscoveryStdinEntry {
                # Drives the hook through the & route with stdin and stderr redirected; both are restored in finally.
                param([AllowEmptyString()] [string] $Stdin)
                $ErrorActionPreference = 'Continue'
                $priorIn = [System.Console]::In
                $priorError = [System.Console]::Error
                $errorWriter = [System.IO.StringWriter]::new()
                $thrown = $null
                $exitCode = $null
                try {
                    [System.Console]::SetIn([System.IO.StringReader]::new($Stdin))
                    [System.Console]::SetError($errorWriter)
                    $global:LASTEXITCODE = 0
                    try { $null = & $script:UnderTest 2>&1 } catch { $thrown = $_ }
                    $exitCode = $LASTEXITCODE
                }
                finally {
                    [System.Console]::SetIn($priorIn)
                    [System.Console]::SetError($priorError)
                }
                return [pscustomobject]@{ ExitCode = $exitCode; Stderr = $errorWriter.ToString(); Thrown = $thrown }
            }
        }

        It 'exits 2 with a DISCOVERY_ARTIFACT_GATE_BLOCKED reason on stderr when last_assistant_message references a failing artifact' -Tag 'E3-Entry' {
            # Arrange: a present declaration and a validator that rejects the referenced artifact.
            Mock Get-RequiredDiscoveryArtifactDeclaration { @{ Present = $true; Declaration = @{ types = @('coverage-ledger') } } }
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }
            # Act
            $result = Invoke-DiscoveryStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -AssistantMessage $script:FailingArtifactText)
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
        }

        It 'exits 0 when last_assistant_message references a conforming artifact' -Tag 'E3-Entry' {
            # Arrange: a present declaration and a validator that accepts the referenced artifact.
            Mock Get-RequiredDiscoveryArtifactDeclaration { @{ Present = $true; Declaration = @{ types = @('coverage-ledger') } } }
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }
            # Act
            $result = Invoke-DiscoveryStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -AssistantMessage $script:FailingArtifactText)
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 0
            $result.Stderr | Should -BeNullOrEmpty
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly
        }

        It 'exits 0 when last_assistant_message carries no discovery artifact reference' -Tag 'E3-Entry' {
            # Arrange: a message without any discovery/<type> token.
            $stdin = ConvertTo-SubagentStopEnvelopeJson -AssistantMessage 'Completed the assigned task with no artifact writes.'
            # Act
            $result = Invoke-DiscoveryStdinEntry -Stdin $stdin
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 0
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'exits 0 when last_assistant_message is an empty string' -Tag 'E3-Entry' {
            # Arrange: a valid envelope with a blank assistant message.
            $stdin = ConvertTo-SubagentStopEnvelopeJson -AssistantMessage ''
            # Act
            $result = Invoke-DiscoveryStdinEntry -Stdin $stdin
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 0
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'exits 0 when the required-artifact declaration is absent' -Tag 'E3-Entry' {
            # Arrange: the default reader reports the declaration absent; the validator must not run.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }
            # Act
            $result = Invoke-DiscoveryStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -AssistantMessage $script:FailingArtifactText)
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 0
            $result.Stderr | Should -BeNullOrEmpty
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }

        It 'blocks with a payload anomaly when the artifact reference is supplied only in an output field or through CLAUDE_HOOK_INPUT' -Tag 'E3-Entry' {
            # Arrange: the reference appears only in an output key and in the environment variable.
            Mock Get-RequiredDiscoveryArtifactDeclaration { @{ Present = $true; Declaration = @{ types = @('coverage-ledger') } } }
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }
            $priorInput = $env:CLAUDE_HOOK_INPUT
            try {
                $env:CLAUDE_HOOK_INPUT = '{"output":"' + $script:FailingArtifactText + '"}'
                # Act
                $result = Invoke-DiscoveryStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -OmitAssistantMessage -OutputField $script:FailingArtifactText)
            }
            finally { $env:CLAUDE_HOOK_INPUT = $priorInput }
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'payload anomaly'
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }

        It 'exits 2 with a payload anomaly reason for empty stdin' -Tag 'E3-Entry' {
            # Arrange and act: no stdin content.
            $result = Invoke-DiscoveryStdinEntry -Stdin ''
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
            $result.Stderr | Should -Match 'payload anomaly'
        }

        It 'exits 2 with a payload anomaly reason for malformed stdin' -Tag 'E3-Entry' {
            # Arrange and act: stdin that is not JSON.
            $result = Invoke-DiscoveryStdinEntry -Stdin '{not-json'
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
            $result.Stderr | Should -Match 'payload anomaly'
        }

        It 'exits 2 with a payload anomaly reason when last_assistant_message is absent' -Tag 'E3-Entry' {
            # Arrange and act: an envelope without last_assistant_message.
            $result = Invoke-DiscoveryStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -OmitAssistantMessage)
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
            $result.Stderr | Should -Match 'payload anomaly'
        }

        It 'keeps validating when stop_hook_active is true' -Tag 'E3-Entry' {
            # Arrange: a re-entry envelope that still references a failing artifact.
            Mock Get-RequiredDiscoveryArtifactDeclaration { @{ Present = $true; Declaration = @{ types = @('coverage-ledger') } } }
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }
            # Act
            $result = Invoke-DiscoveryStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -AssistantMessage $script:FailingArtifactText -StopHookActive)
            # Assert
            $result.Thrown | Should -BeNullOrEmpty
            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'DISCOVERY_ARTIFACT_GATE_BLOCKED:'
        }

        It 'exits 2 in a separate process when stdin is not a JSON envelope' -Tag 'E3-Entry' {
            # Arrange
            $stdinText = '{not-json'
            # Act
            $global:LASTEXITCODE = 0
            $null = $stdinText | & $script:PwshExe -NoProfile -File $script:UnderTest 2>&1
            # Assert
            $LASTEXITCODE | Should -Be 2
        }
    }

    Context 'Find-DiscoveryArtifactReference rule R4 (issue #905)' {
        It 'R4 skips a token that is empty after trimming' {
            # Arrange: two double-quote characters form one token that is empty after trimming.
            $text = 'Wrote "" and discovery/coverage-ledger/coverage-ledger.json'
            $thrown = $null
            $references = $null
            # Act
            try { $references = @(Find-DiscoveryArtifactReference -OutputText $text -ErrorAction Stop) } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $references | Should -HaveCount 1
            $references[0] | Should -BeExactly 'discovery/coverage-ledger/coverage-ledger.json'
        }

        It 'R4 returns no reference for a lone backtick token' {
            # Arrange: the only punctuation token is a lone backtick, which is empty after trimming; no discovery path is present.
            $text = 'Wrote ` and finished the task'
            $thrown = $null
            $references = $null
            # Act
            try { $references = @(Find-DiscoveryArtifactReference -OutputText $text -ErrorAction Stop) } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $references | Should -HaveCount 0
        }

        It 'R4 returns no reference for an empty-after-trim token' {
            # Arrange: two double-quote characters form one token that is empty after trimming; no discovery path is present.
            $text = 'Wrote "" and finished the task'
            $thrown = $null
            $references = $null
            # Act
            try { $references = @(Find-DiscoveryArtifactReference -OutputText $text -ErrorAction Stop) } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $references | Should -HaveCount 0
        }

        It 'R4 skips a lone backtick token and returns the following discovery reference' {
            # Arrange: a lone backtick token precedes a discovery reference.
            $text = 'Wrote ` and discovery/coverage-ledger/coverage-ledger.json'
            $thrown = $null
            $references = $null
            # Act
            try { $references = @(Find-DiscoveryArtifactReference -OutputText $text -ErrorAction Stop) } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $references | Should -HaveCount 1
            $references[0] | Should -BeExactly 'discovery/coverage-ledger/coverage-ledger.json'
        }

        It 'R4 skips the trim-only token <Name> and returns the discovery reference' -ForEach @(
            @{ Name = '()'; Token = '()' }
            @{ Name = '[]'; Token = '[]' }
            @{ Name = ''''''; Token = '''''' }
            @{ Name = ','; Token = ',' }
            @{ Name = ';'; Token = ';' }
        ) {
            # Arrange: the trim-only token precedes a discovery reference.
            $text = 'Wrote ' + $Token + ' and discovery/coverage-ledger/coverage-ledger.json'
            $thrown = $null
            $references = $null
            # Act
            try { $references = @(Find-DiscoveryArtifactReference -OutputText $text -ErrorAction Stop) } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $references | Should -HaveCount 1
            $references[0] | Should -BeExactly 'discovery/coverage-ledger/coverage-ledger.json'
        }

        It 'R4 gate allows a message containing only a lone backtick without invoking the validator' {
            # Arrange: a present declaration and a failing validator mock, so any dispatch would block.
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }
            $json = ConvertTo-DiscoveryEnvelopeJson -AssistantMessage '`'
            $thrown = $null
            $result = $null
            # Act
            try { $result = Invoke-DiscoveryArtifactGateValidation -InputText $json -RequiredArtifactReader $script:PresentReader -ErrorAction Stop } catch { $thrown = $_ }
            # Assert
            $thrown | Should -BeNullOrEmpty
            $result.Ok | Should -Be $true
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
    }
}
