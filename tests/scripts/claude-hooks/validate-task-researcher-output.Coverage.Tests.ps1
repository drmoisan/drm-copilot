#Requires -Version 7.0
<#
.SYNOPSIS
    Entry-point and rule tests for .claude/hooks/validate-task-researcher-output.ps1 (issue #905).

.DESCRIPTION
    Drives the hook through the & route with a SubagentStop envelope on stdin and stderr captured,
    both restored in finally, and covers the R1 research filename rule. Filesystem presence and
    reads are supplied by Test-Path and Get-Content mocks filtered on the exact literal path. No
    test creates, renames, moves, or deletes a file.
#>

Describe 'validate-task-researcher-output entry point (stdin envelope, issue #905)' {
    BeforeAll {
        $script:HookRelativePath = '.claude/hooks/validate-task-researcher-output.ps1'
        $script:StdinHook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../../$script:HookRelativePath"))
        $script:ResearchPath = 'docs/research/2026-10-11T12-05-synthetic-research.md'
        $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
            (Get-Process -Id $PID).Path
        } else {
            (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
        }

        . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')

        function Invoke-TaskResearcherOutputStdinEntry {
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
                try { $null = & $script:StdinHook 2>&1 } catch { $thrown = $_ }
                $exitCode = $LASTEXITCODE
            }
            finally {
                [System.Console]::SetIn($priorIn)
                [System.Console]::SetError($priorError)
            }
            return [pscustomobject]@{ ExitCode = $exitCode; Stderr = $errorWriter.ToString(); Thrown = $thrown }
        }
    }

    It 'exits 2 with a stderr reason when last_assistant_message lacks a research-path' -Tag 'E3-Entry' {
        # Arrange
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage 'Done. Findings recorded.'
        # Act
        $result = Invoke-TaskResearcherOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'does not advertise a research-path'
    }

    It 'exits 0 when last_assistant_message carries a valid research-path' -Tag 'E3-Entry' {
        # Arrange: the synthetic research file is reported present with a plain body.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'docs/research/2026-10-11T12-05-synthetic-research.md' }
        Mock Get-Content { '# Synthetic research' } -ParameterFilter { $LiteralPath -eq 'docs/research/2026-10-11T12-05-synthetic-research.md' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage "research-path: $script:ResearchPath"
        # Act
        $result = Invoke-TaskResearcherOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'blocks when research-path is supplied only in an output field or through CLAUDE_HOOK_INPUT' -Tag 'E3-Entry' {
        # Arrange: the research path appears only in an output key and in the environment variable.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'docs/research/2026-10-11T12-05-synthetic-research.md' }
        Mock Get-Content { '# Synthetic research' } -ParameterFilter { $LiteralPath -eq 'docs/research/2026-10-11T12-05-synthetic-research.md' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage 'Done. Findings recorded.' -OutputField "research-path: $script:ResearchPath"
        $priorInput = $env:CLAUDE_HOOK_INPUT
        try {
            $env:CLAUDE_HOOK_INPUT = (@{ output = "research-path: $script:ResearchPath" } | ConvertTo-Json -Compress)
            # Act
            $result = Invoke-TaskResearcherOutputStdinEntry -Stdin $stdin
        }
        finally { $env:CLAUDE_HOOK_INPUT = $priorInput }
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'does not advertise a research-path'
    }

    It 'exits 2 with the existing empty-output reason when last_assistant_message is an empty string' -Tag 'E3-Entry' {
        # Arrange
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage ''
        # Act
        $result = Invoke-TaskResearcherOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'agent output is empty'
    }

    It 'exits 2 with a payload anomaly reason for empty stdin' -Tag 'E3-Entry' {
        # Arrange and act: no stdin content.
        $result = Invoke-TaskResearcherOutputStdinEntry -Stdin ''
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'task-researcher hook:'
        $result.Stderr | Should -Match 'payload anomaly'
    }

    It 'exits 2 with a payload anomaly reason for malformed stdin' -Tag 'E3-Entry' {
        # Arrange and act: stdin that is not JSON.
        $result = Invoke-TaskResearcherOutputStdinEntry -Stdin '{not-json'
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'task-researcher hook:'
        $result.Stderr | Should -Match 'payload anomaly'
    }

    It 'exits 2 with a payload anomaly reason when last_assistant_message is absent' -Tag 'E3-Entry' {
        # Arrange and act: an envelope without last_assistant_message.
        $result = Invoke-TaskResearcherOutputStdinEntry -Stdin (ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -OmitAssistantMessage)
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'task-researcher hook:'
        $result.Stderr | Should -Match 'payload anomaly'
    }

    It 'keeps validating when stop_hook_active is true' -Tag 'E3-Entry' {
        # Arrange: a re-entry envelope that still carries no research-path.
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage 'Done. Findings recorded.' -StopHookActive
        # Act
        $result = Invoke-TaskResearcherOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
    }

    It 'exits 2 with a stderr reason when the research-path file cannot be read' -Tag 'E3-Entry' {
        # Arrange: the research path is present but its read fails.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'docs/research/2026-10-11T12-05-synthetic-research.md' }
        Mock Get-Content { throw 'simulated read failure' } -ParameterFilter { $LiteralPath -eq 'docs/research/2026-10-11T12-05-synthetic-research.md' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage "research-path: $script:ResearchPath"
        # Act
        $result = Invoke-TaskResearcherOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr | Should -Match 'failed to read research-path'
    }

    It 'exits 2 with the validate-task-researcher-output: prefix when subagentstop-envelope.ps1 fails to load' -Tag 'E3-Entry' {
        # Arrange: only the helper dot-source fails; the dependency guard loads normally.
        Mock Join-Path { throw 'simulated load failure: subagentstop-envelope.ps1' } -ParameterFilter { $ChildPath -eq 'subagentstop-envelope.ps1' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage "research-path: $script:ResearchPath"
        # Act
        try { $result = Invoke-TaskResearcherOutputStdinEntry -Stdin $stdin }
        finally {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('validate-task-researcher-output:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr | Should -Match ([regex]::Escape('subagentstop-envelope.ps1'))
    }

    It 'has no S1, S2, S3 or S6 guard-shape finding' -Tag 'E3-Entry' {
        # Arrange: the shared guard-shape helpers, dot-sourced without modification.
        . (Join-Path $PSScriptRoot '../claude-runtime/HookDependencyGraph.Helpers.ps1')
        . (Join-Path $PSScriptRoot '../claude-runtime/HookGuardShape.Helpers.ps1')
        $scriptText = Get-Content -LiteralPath $script:StdinHook -Raw
        # Act
        $findings = @(Get-HookGuardShapeFinding -ScriptText $scriptText -HookPath $script:HookRelativePath -HookEvent SubagentStop)
        # Assert
        $findings | Should -BeNullOrEmpty -Because ($findings -join '; ')
    }

    It 'exits 2 in a separate process when the stdin envelope lacks a research-path' -Tag 'E3-Entry' {
        # Arrange
        $stdinText = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage 'Done. Findings recorded.'
        # Act
        $global:LASTEXITCODE = 0
        $null = $stdinText | & $script:PwshExe -NoProfile -File $script:StdinHook 2>&1
        # Assert
        $LASTEXITCODE | Should -Be 2
    }

    It 'exits 0 when the research-path uses the research.yyyy-MM-ddTHH-mm.md form' -Tag 'E3-Entry' {
        # Arrange: the timestamped research.<stamp>.md form, reported present with a plain body.
        Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq 'docs/research/research.2026-10-11T12-05.md' }
        Mock Get-Content { '# Synthetic research' } -ParameterFilter { $LiteralPath -eq 'docs/research/research.2026-10-11T12-05.md' }
        $stdin = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage 'research-path: docs/research/research.2026-10-11T12-05.md'
        # Act
        $result = Invoke-TaskResearcherOutputStdinEntry -Stdin $stdin
        # Assert
        $result.Thrown | Should -BeNullOrEmpty
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }
}

Describe 'Test-IsValidResearchFileName rule R1 (issue #905)' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-task-researcher-output.ps1')
    }

    It 'R1 accepts <Name>' -ForEach @(
        @{ Name = '2026-10-11T10-26-subagentstop-envelope-artifact-gates-addendum-research.md'; Path = 'docs/research/2026-10-11T10-26-subagentstop-envelope-artifact-gates-addendum-research.md' }
        @{ Name = '2026-10-11-short-name-research.md'; Path = 'docs/research/2026-10-11-short-name-research.md' }
        @{ Name = '20261011-short-name-research.md'; Path = 'docs/research/20261011-short-name-research.md' }
        @{ Name = '2026-10-11T1026-short-name-research.md'; Path = 'docs/research/2026-10-11T1026-short-name-research.md' }
        @{ Name = '2026-10-11T10-26-short-name.research.md'; Path = 'docs/research/2026-10-11T10-26-short-name.research.md' }
        @{ Name = '2026-10-11-short-name.research.md'; Path = 'docs/research/2026-10-11-short-name.research.md' }
        @{ Name = '20261011-short-name.research.md'; Path = 'docs/research/20261011-short-name.research.md' }
        @{ Name = '2026-10-11T1026-short-name.research.md'; Path = 'docs/research/2026-10-11T1026-short-name.research.md' }
        @{ Name = 'research.2026-10-11T10-26.md'; Path = 'docs/research/research.2026-10-11T10-26.md' }
        @{ Name = 'research.2026-10-11.md'; Path = 'docs/research/research.2026-10-11.md' }
        @{ Name = 'research-addendum.2026-10-11T10-26.md'; Path = 'docs/research/research-addendum.2026-10-11T10-26.md' }
        @{ Name = 'research-addendum.2026-10-11.md'; Path = 'docs/research/research-addendum.2026-10-11.md' }
        @{ Name = 'backslash path 2026-10-11T10-26-short-name-research.md'; Path = 'docs\research\2026-10-11T10-26-short-name-research.md' }
    ) {
        # Act
        $result = Test-IsValidResearchFileName -Path $Path
        # Assert
        $result | Should -BeTrue -Because "R1 must accept $Path"
    }

    It 'R1 rejects <Name> (<Category>)' -ForEach @(
        @{ Name = 'foo.md'; Category = 'no date stamp' }
        @{ Name = 'bad-name.md'; Category = 'no date stamp' }
        @{ Name = 'research-input.md'; Category = 'no date stamp' }
        @{ Name = 'research-findings.md'; Category = 'no date stamp' }
        @{ Name = 'orchestration-mechanics.research.md'; Category = 'no date stamp' }
        @{ Name = 'claude-ecosystem.md'; Category = 'no date stamp' }
        @{ Name = 'hook-surface-inventory.2026-06-27.md'; Category = 'stamp only as a suffix' }
        @{ Name = 'parallel-planner-surface.2026-08-07T12-30.md'; Category = 'stamp only as a suffix' }
        @{ Name = '2026-07-22-npm-audit-fix-strategy.md'; Category = 'leading stamp without research ending' }
        @{ Name = '2026-10-09T05-40-root-prettier-fixture-exclusion.md'; Category = 'leading stamp without research ending' }
        @{ Name = '2026-10-11T10-26-research.md'; Category = 'empty short name' }
        @{ Name = '2026-10-11T10-26--short-name-research.md'; Category = 'short name starts with a hyphen' }
        @{ Name = '2026-10-11T10-26-short_name-research.md'; Category = 'underscore in short name' }
        @{ Name = '2026-10-11T10-26-short name-research.md'; Category = 'space in short name' }
        @{ Name = '2026-10-11T10-26-short.name-research.md'; Category = 'extra dot in short name' }
        @{ Name = '2026-10-11T10-26-short-name-research.MD'; Category = 'upper-case extension' }
        @{ Name = '2026-10-11T10-26-short-name-research.markdown'; Category = 'other extension' }
        @{ Name = '2026-10-11T10-26-short-name-research.txt'; Category = 'other extension' }
        @{ Name = '2026-10-11T12:05-short-name-research.md'; Category = 'stamp in another shape' }
        @{ Name = '2026-1-11-short-name-research.md'; Category = 'stamp in another shape' }
        @{ Name = 'research.2026-10-11T1205.md'; Category = 'compact time after research.' }
        @{ Name = 'research.2026-10-11T10-26-short-name.md'; Category = 'stamp after research. with a short name' }
    ) {
        # Arrange
        $path = 'docs/research/' + $Name
        # Act
        $result = Test-IsValidResearchFileName -Path $path
        # Assert
        $result | Should -BeFalse -Because "R1 must reject $path ($Category)"
    }
}

Describe 'Test-NumericDerivationEvidence rule R3 (issue #905)' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-task-researcher-output.ps1')
        # The thirteen lines Get-CompleteNumericDerivationEvidence (validate-task-researcher-output.Tests.ps1) returns with its defaults.
        $script:R3EvidenceText = @(
            '- Numeric spec.md acceptance criterion: 2 reflection call sites'
            '## Numeric Derivation Evidence'
            '- Complete Family: GetMethod, GetField'
            '- Exhaustive Search Scope: entire repository source tree'
            '- Inclusion Rules: variable arguments only'
            '- Exclusion Rules: generated calls'
            '- Primary Search Strategy or Query Expression: rg ''(GetMethod|GetField)\\('' entire repository'
            '- Primary Member Set: A, B'
            '- Primary Count: 2'
            '- Cross-check Search Strategy or Query Expression: AST traversal of GetMethod and GetField across entire repository'
            '- Cross-check Member Set: A, B'
            '- Cross-check Count: 2'
            '- Member-set Comparison: normalized sets match'
        ) -join "`n"
    }

    It 'R3 accepts the exhaustive scope <Name>' -ForEach @(
        @{ Name = 'entire worktree'; Value = 'entire worktree.' }
        @{ Name = 'whole worktree with all directories'; Value = 'the whole worktree, all directories.' }
        @{ Name = 'entire repository accepted before R3'; Value = 'entire repository' }
        @{ Name = 'complete source tree'; Value = 'the complete source tree' }
        @{ Name = 'whole repo'; Value = 'the whole repo' }
        @{ Name = 'upper-case entire worktree'; Value = 'ENTIRE WORKTREE' }
        @{ Name = 'entire worktree root'; Value = 'entire worktree root.' }
        @{ Name = 'whole repository excluding docs'; Value = 'the whole repository excluding `docs/`' }
        # NB-2 characterization (issue #929): breadth documented in E3 spec Risk 5a; a whole-worktree value that lists a narrower covered set is accepted.
        @{ Name = 'NB-2 whole worktree restricted to code'; Value = 'the whole worktree with ripgrep, restricted to code by excluding `docs/`; covers `.claude/hooks`, `.claude/lib`, `.codex/hooks`, and both bundle roots.' }
        # NB-2 characterization (issue #929): breadth documented in E3 spec Risk 5a; an entire-repository value with an exclusion is accepted.
        @{ Name = 'NB-2 entire repository excluding docs'; Value = 'entire repository excluding docs/**' }
    ) {
        # Arrange
        $content = $script:R3EvidenceText.Replace('- Exhaustive Search Scope: entire repository source tree', '- Exhaustive Search Scope: ' + $Value)
        # Act
        $result = Test-NumericDerivationEvidence -Content $content
        # Assert
        $result.Ok | Should -BeTrue -Because "$($result.Message)"
    }

    It 'R3 rejects the exhaustive scope <Name>' -ForEach @(
        @{ Name = 'the hooks folder'; Value = 'the hooks folder' }
        @{ Name = 'noun without a quantifier'; Value = 'those four files on the current worktree.' }
        @{ Name = 'quantifier without a noun'; Value = 'the whole file, lines 1-335.' }
        @{ Name = 'path-shaped value'; Value = '`.claude/hooks/`' }
        @{ Name = 'all inside allocated'; Value = 'the allocated repository subset' }
        @{ Name = 'tree inside subtree'; Value = 'the entire subtree' }
        @{ Name = 'worktree inside worktrees'; Value = 'the whole worktrees folder' }
    ) {
        # Arrange
        $content = $script:R3EvidenceText.Replace('- Exhaustive Search Scope: entire repository source tree', '- Exhaustive Search Scope: ' + $Value)
        # Act
        $result = Test-NumericDerivationEvidence -Content $content
        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -Be 'task-researcher hook: numeric derivation evidence does not declare an exhaustive repository search scope.'
    }
}

Describe 'Invoke-TaskResearcherOutputValidation dependency decision in process (issue #929)' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-task-researcher-output.ps1')
        . (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')
    }

    It 'returns the guard ExitCode and Reason object in process when a dependency failure is recorded (S6 by design)' {
        # Arrange: a failure recorded after the hook loaded; the leading dependency-decision statement returns the guard object unchanged (rule S6).
        $inputText = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage 'Done. Findings recorded.'
        try {
            Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1'
            # Act
            $result = Invoke-TaskResearcherOutputValidation -InputText $inputText
        }
        finally {
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
        }
        # Assert
        $result.ExitCode | Should -Be 2 -Because $result.Reason
        $result.Reason.StartsWith('validate-task-researcher-output:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
        $result.Reason.Contains('subagentstop-envelope.ps1') | Should -BeTrue -Because $result.Reason
    }
}
