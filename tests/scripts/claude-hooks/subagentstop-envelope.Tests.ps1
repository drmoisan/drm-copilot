#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit tests for the SubagentStop envelope helper .claude/hooks/subagentstop-envelope.ps1 (issue #897).

.DESCRIPTION
    Dot-sources the helper and verifies the Authoritative Helper Contract recorded in
    docs/features/archive/subagentstop-envelope-core-897/spec.md (at
    docs/features/active/subagentstop-envelope-core-897/ until the archive move): the three-function
    surface, the source constraints (no environment read, no import or dot-source, no success, host, information
    or warning write), every input-to-result row, the seven-property result shape, the derived
    fields, BOM and CRLF handling, the stdin default, the anomaly-reason map, and
    Exit-SubagentStopBlock through the call-operator route over a checked-in fixture script.
    Every test input is an inline string; no test creates a file or starts a process.
#>
Set-StrictMode -Version Latest

Describe 'subagentstop-envelope helper' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..')).Path
        $script:HelperPath = Join-Path $script:RepoRoot '.claude/hooks/subagentstop-envelope.ps1'
        $script:FixturePath = Join-Path $script:RepoRoot 'tests/fixtures/claude-hooks/Invoke-SubagentStopBlock.Fixture.ps1'
        $script:ExpectedProperties = @('IsValid', 'Anomaly', 'Envelope', 'AssistantText', 'StopHookActive', 'AgentType', 'HookEventName')
        $script:AnomalyCodes = @('EmptyPayload', 'UnparseableJson', 'NonObjectEnvelope', 'MissingAssistantMessage', 'NullAssistantMessage', 'NonStringAssistantMessage')
        . $script:HelperPath
    }

    It 'defines Read-SubagentStopEnvelope, Get-SubagentStopEnvelopeAnomalyReason and Exit-SubagentStopBlock' {
        (Get-Command -Name Read-SubagentStopEnvelope -CommandType Function -ErrorAction SilentlyContinue) | Should -Not -BeNullOrEmpty
        (Get-Command -Name Get-SubagentStopEnvelopeAnomalyReason -CommandType Function -ErrorAction SilentlyContinue) | Should -Not -BeNullOrEmpty
        (Get-Command -Name Exit-SubagentStopBlock -CommandType Function -ErrorAction SilentlyContinue) | Should -Not -BeNullOrEmpty
    }

    Context 'source constraints' {
        BeforeAll {
            $tokens = $null
            $parseErrors = $null
            $script:HelperAst = [System.Management.Automation.Language.Parser]::ParseFile($script:HelperPath, [ref] $tokens, [ref] $parseErrors)
            $script:HelperParseErrors = @($parseErrors)

            function Get-HelperCommandAst {
                # Every CommandAst in the helper (nested script blocks included) whose literal name is in Names.
                param([string[]] $Names)
                $commands = @($script:HelperAst.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
                $matching = foreach ($command in $commands) {
                    if ($command.GetCommandName() -in $Names) { $command }
                }
                return @($matching)
            }
        }

        It 'reads no environment variable' {
            $script:HelperParseErrors.Count | Should -Be 0
            $envVariables = @($script:HelperAst.FindAll({ param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.VariablePath.DriveName -eq 'env' }, $true))
            $envVariables.Count | Should -Be 0
            $envCalls = @($script:HelperAst.FindAll({ param($node) $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and $node.Member.Extent.Text -eq 'GetEnvironmentVariable' }, $true))
            $envCalls.Count | Should -Be 0
            $envDriveReads = @(Get-HelperCommandAst -Names @('Get-ChildItem', 'Get-Item', 'gci', 'ls', 'dir', 'gi') | Where-Object { @($_.CommandElements | Select-Object -Skip 1 | Where-Object { $_.Extent.Text.StartsWith('env:', [System.StringComparison]::OrdinalIgnoreCase) }).Count -gt 0 })
            $envDriveReads.Count | Should -Be 0
        }

        It 'imports and dot-sources nothing' {
            (Get-HelperCommandAst -Names @('Import-Module', 'ipmo')).Count | Should -Be 0
            $usingModules = @($script:HelperAst.FindAll({ param($node) $node -is [System.Management.Automation.Language.UsingStatementAst] -and $node.UsingStatementKind -eq [System.Management.Automation.Language.UsingStatementKind]::Module }, $true))
            $usingModules.Count | Should -Be 0
            $dotSourced = @($script:HelperAst.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot }, $true))
            $dotSourced.Count | Should -Be 0
        }

        It 'writes nothing to the success, host, information or warning streams' {
            (Get-HelperCommandAst -Names @('Write-Output', 'echo', 'write', 'Write-Host', 'Write-Warning', 'Write-Information')).Count | Should -Be 0
        }
    }

    Context 'input-to-result rows' {
        # One row per line of the contract's input-to-result table. EnvelopeIsNull is $true only when the root is not a JSON object.
        $rows = @(
            @{ Name = 'valid envelope'; InputText = '{"hook_event_name":"SubagentStop","agent_type":"atomic-planner","stop_hook_active":true,"last_assistant_message":"plan-path: x"}'; IsValid = $true; Anomaly = $null; EnvelopeIsNull = $false; AssistantText = 'plan-path: x' },
            @{ Name = 'ISO-date string message'; InputText = '{"last_assistant_message":"2026-10-11T12:00:00Z"}'; IsValid = $true; Anomaly = $null; EnvelopeIsNull = $false; AssistantText = '2026-10-11T12:00:00Z' },
            @{ Name = 'empty string message'; InputText = '{"last_assistant_message":""}'; IsValid = $true; Anomaly = $null; EnvelopeIsNull = $false; AssistantText = '' },
            @{ Name = 'null input'; InputText = $null; IsValid = $false; Anomaly = 'EmptyPayload'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'empty string input'; InputText = ''; IsValid = $false; Anomaly = 'EmptyPayload'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'whitespace-only input'; InputText = "  `t`r`n  "; IsValid = $false; Anomaly = 'EmptyPayload'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'BOM-only input'; InputText = "$([char]0xFEFF)"; IsValid = $false; Anomaly = 'EmptyPayload'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'non-JSON text'; InputText = 'not json {'; IsValid = $false; Anomaly = 'UnparseableJson'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'case-duplicate keys'; InputText = '{"a":1,"A":2}'; IsValid = $false; Anomaly = 'UnparseableJson'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'empty array'; InputText = '[]'; IsValid = $false; Anomaly = 'NonObjectEnvelope'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'single-element array'; InputText = '[{"last_assistant_message":"x"}]'; IsValid = $false; Anomaly = 'NonObjectEnvelope'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'multi-element array'; InputText = '[1,2]'; IsValid = $false; Anomaly = 'NonObjectEnvelope'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'number root'; InputText = '42'; IsValid = $false; Anomaly = 'NonObjectEnvelope'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'string root'; InputText = '"text"'; IsValid = $false; Anomaly = 'NonObjectEnvelope'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'boolean root'; InputText = 'true'; IsValid = $false; Anomaly = 'NonObjectEnvelope'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'JSON null root'; InputText = 'null'; IsValid = $false; Anomaly = 'NonObjectEnvelope'; EnvelopeIsNull = $true; AssistantText = '' },
            @{ Name = 'object without last_assistant_message'; InputText = '{"agent_type":"x"}'; IsValid = $false; Anomaly = 'MissingAssistantMessage'; EnvelopeIsNull = $false; AssistantText = '' },
            @{ Name = 'null last_assistant_message'; InputText = '{"last_assistant_message":null}'; IsValid = $false; Anomaly = 'NullAssistantMessage'; EnvelopeIsNull = $false; AssistantText = '' },
            @{ Name = 'number last_assistant_message'; InputText = '{"last_assistant_message":5}'; IsValid = $false; Anomaly = 'NonStringAssistantMessage'; EnvelopeIsNull = $false; AssistantText = '' },
            @{ Name = 'boolean last_assistant_message'; InputText = '{"last_assistant_message":true}'; IsValid = $false; Anomaly = 'NonStringAssistantMessage'; EnvelopeIsNull = $false; AssistantText = '' },
            @{ Name = 'object last_assistant_message'; InputText = '{"last_assistant_message":{"a":1}}'; IsValid = $false; Anomaly = 'NonStringAssistantMessage'; EnvelopeIsNull = $false; AssistantText = '' },
            @{ Name = 'array last_assistant_message'; InputText = '{"last_assistant_message":["a"]}'; IsValid = $false; Anomaly = 'NonStringAssistantMessage'; EnvelopeIsNull = $false; AssistantText = '' }
        )

        It 'classifies <Name> with the expected IsValid, Anomaly, Envelope and AssistantText' -TestCases $rows {
            $results = @(Read-SubagentStopEnvelope -InputText $InputText)
            $results[0].IsValid | Should -Be $IsValid
            if ($null -eq $Anomaly) { $results[0].Anomaly | Should -BeNullOrEmpty } else { $results[0].Anomaly | Should -BeExactly $Anomaly }
            if ($EnvelopeIsNull) { $results[0].Envelope | Should -BeNullOrEmpty } else { $results[0].Envelope | Should -Not -BeNullOrEmpty }
            $results[0].AssistantText | Should -BeExactly $AssistantText
        }

        It 'returns the root fields of a valid envelope' {
            $result = Read-SubagentStopEnvelope -InputText '{"hook_event_name":"SubagentStop","agent_type":"atomic-planner","stop_hook_active":true,"last_assistant_message":"plan-path: x"}'
            $result.IsValid | Should -BeTrue
            $result.Anomaly | Should -BeNullOrEmpty
            $result.Envelope | Should -Not -BeNullOrEmpty
            $result.AssistantText | Should -BeExactly 'plan-path: x'
            $result.StopHookActive | Should -BeTrue
            $result.AgentType | Should -BeExactly 'atomic-planner'
            $result.HookEventName | Should -BeExactly 'SubagentStop'
        }

        It 'keeps an ISO-8601 date-form message as the exact string' {
            $result = Read-SubagentStopEnvelope -InputText '{"last_assistant_message":"2026-10-11T12:00:00Z"}'
            $result.IsValid | Should -BeTrue
            $result.Anomaly | Should -BeNullOrEmpty
            $result.Envelope | Should -Not -BeNullOrEmpty
            $result.AssistantText | Should -BeOfType [string]
            $result.AssistantText | Should -BeExactly '2026-10-11T12:00:00Z'
        }

        It 'emits exactly one object with exactly the seven contract properties for <Name>' -TestCases $rows {
            $results = @(Read-SubagentStopEnvelope -InputText $InputText)
            $results.Count | Should -Be 1
            @($results[0].PSObject.Properties.Name) | Should -Be $script:ExpectedProperties
        }
    }

    Context 'derived fields' {
        $stopHookRows = @(
            @{ Name = 'boolean true'; InputText = '{"stop_hook_active":true,"last_assistant_message":"m"}'; Expected = $true },
            @{ Name = 'boolean false'; InputText = '{"stop_hook_active":false,"last_assistant_message":"m"}'; Expected = $false },
            @{ Name = 'absent'; InputText = '{"last_assistant_message":"m"}'; Expected = $false },
            @{ Name = 'string "true"'; InputText = '{"stop_hook_active":"true","last_assistant_message":"m"}'; Expected = $false }
        )
        $nameRows = @(
            @{ Field = 'AgentType'; Name = 'present as a string'; InputText = '{"agent_type":"atomic-planner","last_assistant_message":"m"}'; Expected = 'atomic-planner' },
            @{ Field = 'AgentType'; Name = 'absent'; InputText = '{"last_assistant_message":"m"}'; Expected = '' },
            @{ Field = 'AgentType'; Name = 'the non-string 5'; InputText = '{"agent_type":5,"last_assistant_message":"m"}'; Expected = '' },
            @{ Field = 'HookEventName'; Name = 'present as a string'; InputText = '{"hook_event_name":"SubagentStop","last_assistant_message":"m"}'; Expected = 'SubagentStop' },
            @{ Field = 'HookEventName'; Name = 'absent'; InputText = '{"last_assistant_message":"m"}'; Expected = '' },
            @{ Field = 'HookEventName'; Name = 'the non-string 5'; InputText = '{"hook_event_name":5,"last_assistant_message":"m"}'; Expected = '' }
        )

        It 'sets StopHookActive from a stop_hook_active value that is <Name>' -TestCases $stopHookRows {
            $result = Read-SubagentStopEnvelope -InputText $InputText
            $result.StopHookActive | Should -BeOfType [bool]
            $result.StopHookActive | Should -Be $Expected
        }

        It 'sets <Field> when the root field is <Name>' -TestCases $nameRows {
            $result = Read-SubagentStopEnvelope -InputText $InputText
            $result.$Field | Should -BeOfType [string]
            $result.$Field | Should -BeExactly $Expected
        }
    }

    Context 'BOM and CRLF input' {
        It 'accepts a BOM-prefixed valid envelope' {
            $result = Read-SubagentStopEnvelope -InputText ("$([char]0xFEFF)" + '{"last_assistant_message":"bom"}')
            $result.IsValid | Should -BeTrue
            $result.AssistantText | Should -BeExactly 'bom'
        }

        It 'accepts a CRLF-formatted valid envelope' {
            $result = Read-SubagentStopEnvelope -InputText "{`r`n  ""last_assistant_message"": ""crlf""`r`n}"
            $result.IsValid | Should -BeTrue
            $result.AssistantText | Should -BeExactly 'crlf'
        }
    }

    Context 'stdin default' {
        It 'reads the envelope from stdin when InputText is not bound' {
            $savedIn = [Console]::In
            try {
                [Console]::SetIn([System.IO.StringReader]::new('{"last_assistant_message":"stdin"}'))
                $result = Read-SubagentStopEnvelope
            }
            finally {
                [Console]::SetIn($savedIn)
            }
            $result.IsValid | Should -BeTrue
            $result.AssistantText | Should -BeExactly 'stdin'
        }

        It 'treats a stdin read failure as EmptyPayload' {
            $savedIn = [Console]::In
            $reader = [System.IO.StringReader]::new('x')
            $reader.Dispose()
            try {
                [Console]::SetIn($reader)
                $result = Read-SubagentStopEnvelope
            }
            finally {
                [Console]::SetIn($savedIn)
            }
            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -BeExactly 'EmptyPayload'
        }

        It 'prefers a bound empty InputText over non-empty stdin' {
            $savedIn = [Console]::In
            try {
                [Console]::SetIn([System.IO.StringReader]::new('{"last_assistant_message":"stdin"}'))
                $result = Read-SubagentStopEnvelope -InputText ''
            }
            finally {
                [Console]::SetIn($savedIn)
            }
            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -BeExactly 'EmptyPayload'
        }
    }

    Context 'anomaly reasons' {
        $codeRows = @(
            @{ Code = 'EmptyPayload' },
            @{ Code = 'UnparseableJson' },
            @{ Code = 'NonObjectEnvelope' },
            @{ Code = 'MissingAssistantMessage' },
            @{ Code = 'NullAssistantMessage' },
            @{ Code = 'NonStringAssistantMessage' }
        )
        $invalidRows = @(
            @{ Name = 'an unknown code'; Code = 'NotACode' },
            @{ Name = 'null'; Code = $null },
            @{ Name = 'an empty string'; Code = '' },
            @{ Name = 'a case variant'; Code = 'emptypayload' }
        )

        It 'returns a non-empty clause for <Code>' -TestCases $codeRows {
            $clause = Get-SubagentStopEnvelopeAnomalyReason -Anomaly $Code
            $clause | Should -BeOfType [string]
            $clause | Should -Not -BeNullOrEmpty
        }

        It 'returns six pairwise distinct clauses' {
            @($script:AnomalyCodes | ForEach-Object { Get-SubagentStopEnvelopeAnomalyReason -Anomaly $_ } | Select-Object -Unique).Count | Should -Be 6
        }

        It 'throws ArgumentException for <Name>' -TestCases $invalidRows {
            { Get-SubagentStopEnvelopeAnomalyReason -Anomaly $Code } | Should -Throw -ExceptionType ([System.ArgumentException])
        }
    }

    Context 'Exit-SubagentStopBlock' {
        It 'blocks through the & route with stderr and exit code 2' {
            $savedError = [Console]::Error
            $writer = [System.IO.StringWriter]::new()
            try {
                [Console]::SetError($writer)
                $global:LASTEXITCODE = 0
                $output = @(& $script:FixturePath -Message 'SUBAGENTSTOP_TEST_BLOCK: missing plan-path token')
                $code = $LASTEXITCODE
            }
            finally {
                [Console]::SetError($savedError)
                $global:LASTEXITCODE = 0
            }
            $code | Should -Be 2
            $writer.ToString() | Should -BeExactly ('SUBAGENTSTOP_TEST_BLOCK: missing plan-path token' + [Environment]::NewLine)
            $output.Count | Should -Be 0
        }

        It 'rejects an empty or null Message at parameter binding without exiting' {
            { Exit-SubagentStopBlock -Message '' } | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException])
            { Exit-SubagentStopBlock -Message $null } | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException])
        }
    }
}
