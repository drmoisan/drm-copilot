#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'validate-discovery-artifact-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-discovery-artifact-gate.ps1").Path
        . $script:UnderTest

        # Builds a CLAUDE_HOOK_INPUT JSON string carrying a subagent's final
        # output text.
        function ConvertTo-DiscoveryHookInput {
            param(
                [string] $OutputText
            )
            return (@{ output = $OutputText } | ConvertTo-Json -Compress -Depth 8)
        }

        # A required-artifact reader stub that reports the domain-profile
        # declaration as present, so the validator seam is invoked.
        $script:PresentReader = { @{ Present = $true; Declaration = @{ types = @('coverage-ledger') } } }
    }

    Context 'recognized, conforming referenced artifact' {
        It 'returns Ok = $true and invokes the validator exactly once' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryHookInput -OutputText 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            $result = Invoke-DiscoveryArtifactGateValidation -RawPayload $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $true
            $result.Message | Should -BeNullOrEmpty
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly
        }
    }

    Context 'recognized, non-conforming referenced artifact' {
        It 'returns Ok = $false with the validator text embedded verbatim' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'schema violation: missing field x' } }

            $json = ConvertTo-DiscoveryHookInput -OutputText 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            $result = Invoke-DiscoveryArtifactGateValidation -RawPayload $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $false
            $result.Message | Should -BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'
            $result.Message | Should -Match ([regex]::Escape('schema violation: missing field x'))
        }
    }

    Context 'no recognized artifact reference' {
        It 'returns Ok = $true without invoking the validator' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryHookInput -OutputText 'Completed the assigned task with no artifact writes.'
            $result = Invoke-DiscoveryArtifactGateValidation -RawPayload $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $true
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
    }

    Context 'fail-open when the domain profile is absent' {
        It 'returns Ok = $true without invoking the validator when the seam reports absent' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $json = ConvertTo-DiscoveryHookInput -OutputText 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            # No -RequiredArtifactReader override: exercises the default seam,
            # which reports the domain profile absent (Present = $false).
            $result = Invoke-DiscoveryArtifactGateValidation -RawPayload $json

            $result.Ok | Should -Be $true
            Should -Invoke Invoke-DiscoveryValidatorExe -Times 0 -Exactly
        }
    }

    Context 'empty or absent CLAUDE_HOOK_INPUT' {
        It 'returns Ok = $false with the documented empty-input message for an empty string' {
            $result = Invoke-DiscoveryArtifactGateValidation -RawPayload ''

            $result.Ok | Should -Be $false
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'returns Ok = $false with the documented empty-input message for $null' {
            $result = Invoke-DiscoveryArtifactGateValidation -RawPayload $null

            $result.Ok | Should -Be $false
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }
    }

    Context 'malformed CLAUDE_HOOK_INPUT JSON' {
        It 'returns Ok = $false with a non-empty message describing the parse failure' {
            $result = Invoke-DiscoveryArtifactGateValidation -RawPayload '{not-json'

            $result.Ok | Should -Be $false
            $result.Message | Should -Not -BeNullOrEmpty
        }
    }

    Context 'validator-not-found-style failure' {
        It 'returns Ok = $false identically to any other non-conforming result' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 1; Output = 'ModuleNotFoundError: No module named scripts.dev_tools.validate_discovery_artifacts' } }

            $json = ConvertTo-DiscoveryHookInput -OutputText 'Wrote discovery/coverage-ledger/coverage-ledger.json successfully.'
            $result = Invoke-DiscoveryArtifactGateValidation -RawPayload $json -RequiredArtifactReader $script:PresentReader

            $result.Ok | Should -Be $false
        }
    }

    Context 'domain neutrality' {
        It 'contains no TaskMaster/TMW/Outlook/VSTO token in its own source text' {
            $sourceText = Get-Content -LiteralPath $script:UnderTest -Raw
            $sourceText | Should -Not -Match 'TaskMaster|TMW|Outlook|VSTO'
        }
    }

    Context 'payload with no output field' {
        It 'returns Ok = $true without invoking the validator when the payload carries no output property' {
            Mock Invoke-DiscoveryValidatorExe { @{ ExitCode = 0; Output = '' } }

            $result = Invoke-DiscoveryArtifactGateValidation -RawPayload '{"other":"value"}' -RequiredArtifactReader $script:PresentReader

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

    Context 'script entrypoint (end-to-end)' {
        BeforeAll {
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
        }

        It 'exits 0 when the subagent output references no discovery artifact' {
            $prev = $env:CLAUDE_HOOK_INPUT
            try {
                $env:CLAUDE_HOOK_INPUT = '{"output":"Completed the assigned task with no artifact writes."}'
                $null = & $script:PwshExe -NoProfile -File $script:UnderTest 2>&1
                $LASTEXITCODE | Should -Be 0
            } finally {
                $env:CLAUDE_HOOK_INPUT = $prev
            }
        }

        It 'exits 1 with a Write-Error when CLAUDE_HOOK_INPUT is empty' {
            $prev = $env:CLAUDE_HOOK_INPUT
            try {
                $env:CLAUDE_HOOK_INPUT = ''
                $null = & $script:PwshExe -NoProfile -File $script:UnderTest 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_HOOK_INPUT = $prev
            }
        }
    }
}
