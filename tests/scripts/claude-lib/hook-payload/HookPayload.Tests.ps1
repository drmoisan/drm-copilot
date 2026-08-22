#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the shared PreToolUse hook payload reader (issue #501).
.DESCRIPTION
    Covers transport precedence and fallback order, strict nested tool_input
    extraction, and envelope-anomaly classification. Every stdin interaction runs
    through the module's two injectable scriptblock seams, so no test touches a .NET
    static, spawns a child process, reads a file, or can block on a console read.
#>

BeforeAll {
    # Resolve the module four levels up (hook-payload -> claude-lib -> scripts ->
    # tests -> repo root). Resolve-Path normalizes separators so Pester coverage
    # breakpoints bind to the path the run settings name.
    $script:HookPayloadModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/hook-payload/HookPayload.psm1").Path
    Import-Module $script:HookPayloadModulePath -Force

    $script:NestedBashEnvelope = '{"session_id":"s1","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"},"tool_use_id":"t1"}'
    $script:FlatRootPayload = '{"command":"gh pr merge 999 --merge"}'
}

Describe 'Read-ClaudeHookRawPayload transport' {
    Context 'precedence when several sources carry text' {
        It 'prefers the stdin payload over both environment fallbacks' {
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { 'STDIN-PAYLOAD' } `
                -TestStandardInputRedirected { $true } `
                -HookInputFallback 'HOOK-INPUT-PAYLOAD' `
                -ToolInputFallback 'TOOL-INPUT-PAYLOAD'

            $raw | Should -Be 'STDIN-PAYLOAD'
        }

        It 'prefers the CLAUDE_HOOK_INPUT fallback over the CLAUDE_TOOL_INPUT fallback' {
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { '' } `
                -TestStandardInputRedirected { $true } `
                -HookInputFallback 'HOOK-INPUT-PAYLOAD' `
                -ToolInputFallback 'TOOL-INPUT-PAYLOAD'

            $raw | Should -Be 'HOOK-INPUT-PAYLOAD'
        }
    }

    Context 'fallback order when stdin is whitespace-only' {
        It 'falls back to CLAUDE_HOOK_INPUT when stdin is whitespace-only' {
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { "   `n`t  " } `
                -TestStandardInputRedirected { $true } `
                -HookInputFallback 'HOOK-INPUT-PAYLOAD' `
                -ToolInputFallback 'TOOL-INPUT-PAYLOAD'

            $raw | Should -Be 'HOOK-INPUT-PAYLOAD'
        }

        It 'falls back to CLAUDE_TOOL_INPUT when stdin and CLAUDE_HOOK_INPUT are both whitespace-only' {
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { "   `n`t  " } `
                -TestStandardInputRedirected { $true } `
                -HookInputFallback '    ' `
                -ToolInputFallback 'TOOL-INPUT-PAYLOAD'

            $raw | Should -Be 'TOOL-INPUT-PAYLOAD'
        }

        It 'returns an empty string when every transport is empty' {
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { '' } `
                -TestStandardInputRedirected { $true } `
                -HookInputFallback '' `
                -ToolInputFallback ''

            $raw | Should -Be ''
        }
    }

    Context 'a throwing stdin read' {
        It 'falls back to CLAUDE_HOOK_INPUT rather than propagating the exception' {
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { throw 'stdin is not available in this host' } `
                -TestStandardInputRedirected { $true } `
                -HookInputFallback 'HOOK-INPUT-PAYLOAD' `
                -ToolInputFallback 'TOOL-INPUT-PAYLOAD'

            $raw | Should -Be 'HOOK-INPUT-PAYLOAD'
        }

        It 'does not throw when both the redirect probe and the read seam throw' {
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { throw 'read failed' } `
                -TestStandardInputRedirected { throw 'probe failed' } `
                -HookInputFallback 'HOOK-INPUT-PAYLOAD' `
                -ToolInputFallback 'TOOL-INPUT-PAYLOAD'

            $raw | Should -Be 'HOOK-INPUT-PAYLOAD'
        }
    }

    Context 'redirect-guard polarity' {
        It 'uses the stdin seam value when the redirect probe reports redirected input' {
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { 'STDIN-PAYLOAD' } `
                -TestStandardInputRedirected { $true } `
                -HookInputFallback 'HOOK-INPUT-PAYLOAD' `
                -ToolInputFallback 'TOOL-INPUT-PAYLOAD'

            $raw | Should -Be 'STDIN-PAYLOAD'
        }

        It 'skips the stdin read entirely when the redirect probe reports a non-redirected console' {
            # The stdin seam returns a distinct non-empty value, so the outcome
            # discriminates the source. This test fails on an absent guard (the seam
            # value would win) and on an inverted guard (the seam value would win).
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { 'STDIN-PAYLOAD' } `
                -TestStandardInputRedirected { $false } `
                -HookInputFallback 'HOOK-INPUT-PAYLOAD' `
                -ToolInputFallback 'TOOL-INPUT-PAYLOAD'

            $raw | Should -Be 'HOOK-INPUT-PAYLOAD'
        }

        It 'defaults the two stdin seams to the console redirect probe and the console reader' {
            # Tripwire: the default redirect seam must remain the console redirect
            # probe, so a non-redirected manual invocation cannot block on a console
            # read, and the default read seam must remain the bare console reader.
            $parameters = (Get-Command Read-ClaudeHookRawPayload).ScriptBlock.Ast.Body.ParamBlock.Parameters
            $defaults = @{}
            foreach ($parameter in $parameters) {
                $defaults[$parameter.Name.VariablePath.UserPath] = $parameter.DefaultValue.Extent.Text
            }

            $defaults['TestStandardInputRedirected'] | Should -BeLike '*IsInputRedirected*'
            $defaults['ReadStandardInput'] | Should -BeLike '*ReadToEnd*'
        }
    }

    Context 'environment-variable defaults' {
        It 'binds the CLAUDE_HOOK_INPUT environment variable as the first fallback default' {
            $savedHook = $env:CLAUDE_HOOK_INPUT
            $savedTool = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_HOOK_INPUT = 'ENV-HOOK-INPUT'
                $env:CLAUDE_TOOL_INPUT = 'ENV-TOOL-INPUT'

                $raw = Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true }

                $raw | Should -Be 'ENV-HOOK-INPUT'
            } finally {
                $env:CLAUDE_HOOK_INPUT = $savedHook
                $env:CLAUDE_TOOL_INPUT = $savedTool
            }
        }

        It 'binds the CLAUDE_TOOL_INPUT environment variable as the second fallback default' {
            $savedHook = $env:CLAUDE_HOOK_INPUT
            $savedTool = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_HOOK_INPUT = ''
                $env:CLAUDE_TOOL_INPUT = 'ENV-TOOL-INPUT'

                $raw = Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true }

                $raw | Should -Be 'ENV-TOOL-INPUT'
            } finally {
                $env:CLAUDE_HOOK_INPUT = $savedHook
                $env:CLAUDE_TOOL_INPUT = $savedTool
            }
        }
    }
}

Describe 'ConvertFrom-ClaudeHookEnvelope' {
    Context 'well-formed payloads' {
        It 'parses the documented nested envelope and reports it valid' {
            $result = ConvertFrom-ClaudeHookEnvelope -Raw $script:NestedBashEnvelope

            $result.IsValid | Should -BeTrue
            $result.Anomaly | Should -BeNullOrEmpty
            $result.Value.tool_name | Should -Be 'Bash'
        }

        It 'parses stdin text carrying Windows CRLF line endings' {
            $crlf = "{`r`n  `"tool_name`": `"Bash`",`r`n  `"tool_input`": { `"command`": `"echo hi`" }`r`n}`r`n"
            $result = ConvertFrom-ClaudeHookEnvelope -Raw $crlf

            $result.IsValid | Should -BeTrue
            $result.Value.tool_input.command | Should -Be 'echo hi'
        }

        It 'parses stdin text carrying a leading byte-order mark' {
            $bom = [string][char]0xFEFF + $script:NestedBashEnvelope
            $result = ConvertFrom-ClaudeHookEnvelope -Raw $bom

            $result.IsValid | Should -BeTrue
            $result.Value.tool_name | Should -Be 'Bash'
        }
    }

    Context 'anomalous payloads' {
        It 'classifies an empty payload as EmptyPayload' {
            $result = ConvertFrom-ClaudeHookEnvelope -Raw ''

            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'EmptyPayload'
            $result.Value | Should -BeNullOrEmpty
        }

        It 'classifies a whitespace-only payload as EmptyPayload' {
            $result = ConvertFrom-ClaudeHookEnvelope -Raw "  `n `t "

            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'EmptyPayload'
        }

        It 'classifies unparseable text as UnparseableJson' {
            $result = ConvertFrom-ClaudeHookEnvelope -Raw '{"tool_input": '

            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'UnparseableJson'
        }

        It 'never returns a silent null value for malformed input' {
            $result = ConvertFrom-ClaudeHookEnvelope -Raw 'this is not json at all'

            $result | Should -Not -BeNullOrEmpty
            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'UnparseableJson'
        }
    }
}

Describe 'Get-ClaudeHookToolInput strict nested extraction' {
    Context 'well-formed envelopes' {
        It 'extracts the nested tool_input object' {
            $envelope = (ConvertFrom-ClaudeHookEnvelope -Raw $script:NestedBashEnvelope).Value
            $result = Get-ClaudeHookToolInput -Envelope $envelope

            $result.IsValid | Should -BeTrue
            $result.Anomaly | Should -BeNullOrEmpty
            $result.Value.command | Should -Be 'gh pr merge 999 --merge'
        }
    }

    Context 'envelope-level anomalies' {
        It 'classifies the legacy flat root shape as MissingToolInput' {
            $envelope = (ConvertFrom-ClaudeHookEnvelope -Raw $script:FlatRootPayload).Value
            $result = Get-ClaudeHookToolInput -Envelope $envelope

            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'MissingToolInput'
        }

        It 'classifies a null tool_input as NullToolInput' {
            $envelope = (ConvertFrom-ClaudeHookEnvelope -Raw '{"tool_name":"Bash","tool_input":null}').Value
            $result = Get-ClaudeHookToolInput -Envelope $envelope

            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'NullToolInput'
        }

        It 'classifies a string tool_input as NonObjectToolInput' {
            $envelope = (ConvertFrom-ClaudeHookEnvelope -Raw '{"tool_input":"gh pr merge"}').Value
            $result = Get-ClaudeHookToolInput -Envelope $envelope

            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'NonObjectToolInput'
        }

        It 'classifies an array tool_input as NonObjectToolInput' {
            $envelope = (ConvertFrom-ClaudeHookEnvelope -Raw '{"tool_input":[1,2,3]}').Value
            $result = Get-ClaudeHookToolInput -Envelope $envelope

            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'NonObjectToolInput'
        }

        It 'classifies a numeric tool_input as NonObjectToolInput' {
            $envelope = (ConvertFrom-ClaudeHookEnvelope -Raw '{"tool_input":42}').Value
            $result = Get-ClaudeHookToolInput -Envelope $envelope

            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'NonObjectToolInput'
        }

        It 'classifies a null envelope as MissingToolInput' {
            $result = Get-ClaudeHookToolInput -Envelope $null

            $result.IsValid | Should -BeFalse
            $result.Anomaly | Should -Be 'MissingToolInput'
        }
    }
}

Describe 'Resolve-ClaudeHookToolInput end-to-end extraction' {
    Context 'nested property extraction per matcher family' {
        It 'extracts command from a Bash-matcher envelope' {
            $resolved = Resolve-ClaudeHookToolInput -Raw $script:NestedBashEnvelope

            $resolved.IsValid | Should -BeTrue
            (Get-ClaudeHookToolInputString -ToolInput $resolved.Value -Name 'command') |
                Should -Be 'gh pr merge 999 --merge'
        }

        It 'extracts file_path from a Write-matcher envelope' {
            $raw = '{"tool_name":"Write","tool_input":{"file_path":"docs/features/active/x/plan.md","content":"body"}}'
            $resolved = Resolve-ClaudeHookToolInput -Raw $raw

            $resolved.IsValid | Should -BeTrue
            (Get-ClaudeHookToolInputString -ToolInput $resolved.Value -Name 'file_path') |
                Should -Be 'docs/features/active/x/plan.md'
            (Get-ClaudeHookToolInputString -ToolInput $resolved.Value -Name 'content') |
                Should -Be 'body'
        }

        It 'extracts subagent_type from an Agent-matcher envelope' {
            $raw = '{"tool_name":"Agent","tool_input":{"subagent_type":"atomic-planner","prompt":"plan it"}}'
            $resolved = Resolve-ClaudeHookToolInput -Raw $raw

            $resolved.IsValid | Should -BeTrue
            (Get-ClaudeHookToolInputString -ToolInput $resolved.Value -Name 'subagent_type') |
                Should -Be 'atomic-planner'
        }

        It 'exposes the envelope root so a caller can read agent_type alongside tool_input' {
            $raw = '{"tool_name":"Agent","agent_type":"epic-orchestrator","agent_id":"a1","tool_input":{"subagent_type":"atomic-executor"}}'
            $resolved = Resolve-ClaudeHookToolInput -Raw $raw

            $resolved.IsValid | Should -BeTrue
            (Get-ClaudeHookEnvelopeValue -Envelope $resolved.Envelope -Name 'agent_type') |
                Should -Be 'epic-orchestrator'
            (Get-ClaudeHookToolInputString -ToolInput $resolved.Value -Name 'subagent_type') |
                Should -Be 'atomic-executor'
        }
    }

    Context 'property-level tolerance inside a well-formed tool_input' {
        It 'returns an empty string for a property absent from a well-formed tool_input' {
            $resolved = Resolve-ClaudeHookToolInput -Raw $script:NestedBashEnvelope

            $resolved.IsValid | Should -BeTrue
            (Get-ClaudeHookToolInputString -ToolInput $resolved.Value -Name 'file_path') | Should -Be ''
        }

        It 'tolerates an Edit-shaped tool_input carrying new_string and old_string but no content' {
            $raw = '{"tool_name":"Edit","tool_input":{"file_path":"tests/scripts/x.Tests.ps1","old_string":"before","new_string":"after"}}'
            $resolved = Resolve-ClaudeHookToolInput -Raw $raw

            $resolved.IsValid | Should -BeTrue
            (Get-ClaudeHookToolInputString -ToolInput $resolved.Value -Name 'content') | Should -Be ''
            (Get-ClaudeHookToolInputString -ToolInput $resolved.Value -Name 'new_string') | Should -Be 'after'
            (Get-ClaudeHookToolInputString -ToolInput $resolved.Value -Name 'old_string') | Should -Be 'before'
        }
    }

    Context 'anomaly propagation' {
        It 'propagates the EmptyPayload anomaly and reports no envelope' {
            $resolved = Resolve-ClaudeHookToolInput -Raw ''

            $resolved.IsValid | Should -BeFalse
            $resolved.Anomaly | Should -Be 'EmptyPayload'
            $resolved.Envelope | Should -BeNullOrEmpty
        }

        It 'propagates the UnparseableJson anomaly and reports no envelope' {
            $resolved = Resolve-ClaudeHookToolInput -Raw '{oops'

            $resolved.IsValid | Should -BeFalse
            $resolved.Anomaly | Should -Be 'UnparseableJson'
            $resolved.Envelope | Should -BeNullOrEmpty
        }

        It 'propagates MissingToolInput for the legacy flat root shape and still exposes the envelope' {
            $resolved = Resolve-ClaudeHookToolInput -Raw $script:FlatRootPayload

            $resolved.IsValid | Should -BeFalse
            $resolved.Anomaly | Should -Be 'MissingToolInput'
            $resolved.Envelope | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Anomaly reason mapping' {
    It 'enumerates exactly the five anomaly codes' {
        $codes = Get-ClaudeHookPayloadAnomalyCode

        $codes.Count | Should -Be 5
        $codes | Should -Contain 'EmptyPayload'
        $codes | Should -Contain 'UnparseableJson'
        $codes | Should -Contain 'MissingToolInput'
        $codes | Should -Contain 'NullToolInput'
        $codes | Should -Contain 'NonObjectToolInput'
    }

    It 'returns a distinct non-empty reason clause for every anomaly code' {
        $reasons = @(Get-ClaudeHookPayloadAnomalyCode | ForEach-Object { Get-ClaudeHookPayloadAnomalyReason -Anomaly $_ })

        $reasons.Count | Should -Be 5
        @($reasons | Select-Object -Unique).Count | Should -Be 5
        foreach ($reason in $reasons) {
            $reason | Should -Not -BeNullOrEmpty
        }
    }

    It 'names the flat root shape in the MissingToolInput reason' {
        Get-ClaudeHookPayloadAnomalyReason -Anomaly 'MissingToolInput' | Should -BeLike '*no tool_input key*'
    }

    It 'returns an unclassified clause for an empty anomaly code' {
        Get-ClaudeHookPayloadAnomalyReason -Anomaly '' | Should -BeLike '*unclassified*'
    }

    It 'returns an unrecognized clause naming an unknown anomaly code' {
        Get-ClaudeHookPayloadAnomalyReason -Anomaly 'SomethingElse' | Should -BeLike '*SomethingElse*'
    }
}

Describe 'Shape helper predicates' {
    Context 'Test-ClaudeHookEnvelopeHasKey' {
        It 'reports true for a present key on a parsed object' {
            $envelope = (ConvertFrom-ClaudeHookEnvelope -Raw '{"tool_input":{}}').Value
            Test-ClaudeHookEnvelopeHasKey -Envelope $envelope -Name 'tool_input' | Should -BeTrue
        }

        It 'reports false for an absent key on a parsed object' {
            $envelope = (ConvertFrom-ClaudeHookEnvelope -Raw '{"tool_input":{}}').Value
            Test-ClaudeHookEnvelopeHasKey -Envelope $envelope -Name 'agent_type' | Should -BeFalse
        }

        It 'reports true for a present key on a hashtable' {
            Test-ClaudeHookEnvelopeHasKey -Envelope @{ tool_input = @{} } -Name 'tool_input' | Should -BeTrue
        }

        It 'reports false for a null envelope' {
            Test-ClaudeHookEnvelopeHasKey -Envelope $null -Name 'tool_input' | Should -BeFalse
        }

        It 'reports false for a scalar envelope' {
            Test-ClaudeHookEnvelopeHasKey -Envelope 7 -Name 'tool_input' | Should -BeFalse
        }
    }

    Context 'Test-ClaudeHookObjectValue' {
        It 'accepts a parsed JSON object' {
            $value = (ConvertFrom-ClaudeHookEnvelope -Raw '{"a":1}').Value
            Test-ClaudeHookObjectValue -Value $value | Should -BeTrue
        }

        It 'accepts a hashtable' {
            Test-ClaudeHookObjectValue -Value @{ a = 1 } | Should -BeTrue
        }

        It 'rejects a null value' {
            Test-ClaudeHookObjectValue -Value $null | Should -BeFalse
        }

        It 'rejects a string value' {
            Test-ClaudeHookObjectValue -Value 'text' | Should -BeFalse
        }

        It 'rejects a boolean value' {
            Test-ClaudeHookObjectValue -Value $true | Should -BeFalse
        }

        It 'rejects an array value' {
            Test-ClaudeHookObjectValue -Value @(1, 2) | Should -BeFalse
        }
    }

    Context 'Get-ClaudeHookEnvelopeValue' {
        It 'returns null for an absent key rather than throwing under StrictMode' {
            $envelope = (ConvertFrom-ClaudeHookEnvelope -Raw '{"a":1}').Value
            Get-ClaudeHookEnvelopeValue -Envelope $envelope -Name 'missing' | Should -BeNullOrEmpty
        }

        It 'reads a value out of a hashtable envelope' {
            Get-ClaudeHookEnvelopeValue -Envelope @{ a = 'x' } -Name 'a' | Should -Be 'x'
        }
    }
}
