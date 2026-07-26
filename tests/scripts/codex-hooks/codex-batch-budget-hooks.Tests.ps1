#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Unit coverage for the two Codex per-batch budget PreToolUse hooks
    .codex/hooks/enforce-python-batch-budget.ps1 and
    .codex/hooks/enforce-powershell-batch-budget.ps1 (issue #415 remediation cycle 1, R1).

    The two hooks are structurally identical apart from their language-specific path
    patterns and function-name prefix, so the cases are written once and applied to
    both through a Context-level -ForEach, dispatching by function name.

    Every filesystem seam is injected with an in-memory fake, so no case creates,
    reads, or mutates any on-disk .codex/state batch-budget file. No temporary file
    is created. Entrypoint cases redirect stdin with
    [System.Console]::SetIn([System.IO.StringReader]::new(...)) and restore the
    original readers in finally; they are restricted to payloads that cannot reach
    the state-writing path, so running the suite never mutates repository state.
#>

Describe 'Codex per-batch budget PreToolUse hooks' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'

        . (Join-Path $script:HookRoot 'enforce-python-batch-budget.ps1')
        . (Join-Path $script:HookRoot 'enforce-powershell-batch-budget.ps1')

        function ConvertTo-CodexBudgetPayload {
            param(
                [Parameter(Mandatory)][string] $ToolName,
                [Parameter(Mandatory)][hashtable] $ToolInput,
                [Parameter()][AllowEmptyString()][AllowNull()][string] $SessionId = 'budget-coverage'
            )

            return [ordered]@{
                session_id      = $SessionId
                hook_event_name = 'PreToolUse'
                tool_name       = $ToolName
                tool_input      = $ToolInput
            } | ConvertTo-Json -Compress -Depth 30
        }

        function Invoke-CodexBudgetEntrypoint {
            param(
                [Parameter(Mandatory)][string] $HookPath,
                [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw
            )

            $originalIn = [System.Console]::In
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetError($errorWriter)
                $stdout = & $HookPath
                return [pscustomobject]@{
                    ExitCode = $LASTEXITCODE
                    Stdout   = ($stdout -join "`n")
                    Stderr   = $errorWriter.ToString()
                }
            } finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetError($originalError)
            }
        }
    }

    Context 'the <Language> batch-budget hook' -ForEach @(
        @{
            Language = 'Python'
            HookFile = 'enforce-python-batch-budget.ps1'
            HookName = 'enforce-python-batch-budget'
            ProdPath = 'scripts/dev_tools/tool.py'
            TestPath = 'tests/test_a.py'
            AltProd  = 'scripts/dev_tools/other.py'
            OtherExt = 'docs/notes.md'
        }
        @{
            Language = 'PowerShell'
            HookFile = 'enforce-powershell-batch-budget.ps1'
            HookName = 'enforce-powershell-batch-budget'
            ProdPath = 'scripts/dev-tools/tool.ps1'
            TestPath = 'tests/scripts/a.Tests.ps1'
            AltProd  = 'scripts/dev-tools/other.psm1'
            OtherExt = 'docs/notes.md'
        }
    ) {
        BeforeAll {
            $script:HookPath = Join-Path $script:HookRoot $HookFile
            $script:NewState = "Get-${Language}BatchBudgetState"
            $script:ConvertState = "ConvertTo-${Language}BatchBudgetState"
            $script:BlockDecision = "Get-${Language}BatchBudgetBlockDecision"
            $script:DecisionFn = "Invoke-${Language}BatchBudgetDecision"
            $script:HookFn = "Invoke-${Language}BatchBudgetHook"
            $script:NoopSeams = @{
                EnsureDirectory = { param([string] $Path) if ($Path) { } }
                ReadState       = { param([string] $Path) if ($Path) { '{}' } }
                WriteState      = { param([string] $Path, [System.Collections.IDictionary] $State) if ($Path -and $State) { } }
            }
        }

        It 'creates a fresh state carrying the supplied caps and empty file lists' {
            $state = & $script:NewState -ProdCap 3 -TestCap 3

            $state.prodCap | Should -Be 3
            $state.testCap | Should -Be 3
            @($state.prodFiles).Count | Should -Be 0
            @($state.testFiles).Count | Should -Be 0
        }

        It 'overlays a persisted state onto the default caps and lists' {
            $loaded = '{"prodCap":5,"testCap":4,"prodFiles":["a.x"],"testFiles":["b.x"]}' | ConvertFrom-Json

            $state = & $script:ConvertState -InputObject $loaded -ProdCap 3 -TestCap 3

            $state.prodCap | Should -Be 5
            $state.testCap | Should -Be 4
            @($state.prodFiles) | Should -Contain 'a.x'
            @($state.testFiles) | Should -Contain 'b.x'
        }

        It 'keeps the default caps when the persisted state supplies none' {
            $loaded = '{}' | ConvertFrom-Json

            $state = & $script:ConvertState -InputObject $loaded -ProdCap 3 -TestCap 3

            $state.prodCap | Should -Be 3
            @($state.testFiles).Count | Should -Be 0
        }

        It 'builds a deny decision without state when no state is supplied' {
            $decision = & $script:BlockDecision -Reason 'cap reached'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Be 'cap reached'
            $decision.Contains('state') | Should -BeFalse
        }

        It 'attaches the state to a deny decision when state is supplied' {
            $state = & $script:NewState -ProdCap 3 -TestCap 3

            $decision = & $script:BlockDecision -Reason 'cap reached' -State $state

            $decision.state.prodCap | Should -Be 3
        }

        It 'allows a path outside the language surface without recording state' {
            $state = & $script:NewState -ProdCap 3 -TestCap 3

            $decision = & $script:DecisionFn -FilePath $OtherExt -State $state -StateFile 'state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decision.shouldWriteState | Should -BeFalse
        }

        It 'allows an already-counted file without consuming another slot' {
            $state = & $script:NewState -ProdCap 3 -TestCap 3
            $state.prodFiles = @($ProdPath)

            $decision = & $script:DecisionFn -FilePath $ProdPath -State $state -StateFile 'state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decision.shouldWriteState | Should -BeFalse
        }

        It 'denies a new production file once the production cap is full' {
            $state = & $script:NewState -ProdCap 1 -TestCap 3
            $state.prodFiles = @($AltProd)

            $decision = & $script:DecisionFn -FilePath $ProdPath -State $state -StateFile 'state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'production file cap is 1'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'state.json'
        }

        It 'denies a new test file once the test cap is full' {
            $state = & $script:NewState -ProdCap 3 -TestCap 0

            $decision = & $script:DecisionFn -FilePath $TestPath -State $state -StateFile 'state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'test file cap is 0'
        }

        It 'consumes a test slot for a new test file' {
            $state = & $script:NewState -ProdCap 3 -TestCap 3

            $decision = & $script:DecisionFn -FilePath $TestPath -State $state -StateFile 'state.json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $decision.shouldWriteState | Should -BeTrue
            @($decision.state.testFiles) | Should -Contain $TestPath
        }

        It 'consumes a production slot for a new production file' {
            $state = & $script:NewState -ProdCap 3 -TestCap 3

            $decision = & $script:DecisionFn -FilePath $ProdPath -State $state -StateFile 'state.json'

            $decision.shouldWriteState | Should -BeTrue
            @($decision.state.prodFiles) | Should -Contain $ProdPath
        }

        It 'allows when the mapped tool_input is empty' {
            $decision = & $script:HookFn -ToolInputRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies when the mapped tool_input is malformed JSON' {
            $decision = & $script:HookFn -ToolInputRaw 'not json'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'malformed JSON'
        }

        It 'allows when the mapped tool_input carries no file_path' {
            $decision = & $script:HookFn -ToolInputRaw '{"content":"x"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a mapped path outside the language surface' {
            $raw = @{ file_path = $OtherExt } | ConvertTo-Json -Compress

            $decision = & $script:HookFn -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'probes the state directory through the default path-existence seam' {
            # Arrange: only the mutating seams are faked, so the production default
            # Test-Path seam runs; it is read-only and creates nothing.
            $raw = @{ file_path = $ProdPath } | ConvertTo-Json -Compress

            $decision = & $script:HookFn -ToolInputRaw $raw -SessionId 'probe' @script:NoopSeams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'creates the state directory and records a new file when no state exists' {
            $raw = @{ file_path = $ProdPath } | ConvertTo-Json -Compress
            $script:EnsuredPath = ''
            $script:WrittenState = $null
            $script:WrittenStatePath = ''
            $seams = @{
                TestPathExists  = { param([string] $Path) if ($Path) { $false } }
                EnsureDirectory = { param([string] $Path) $script:EnsuredPath = $Path }
                ReadState       = { param([string] $Path) if ($Path) { '{}' } }
                WriteState      = {
                    param([string] $Path, [System.Collections.IDictionary] $State)
                    $script:WrittenStatePath = $Path
                    $script:WrittenState = $State
                }
            }

            $decision = & $script:HookFn -ToolInputRaw $raw -SessionId 'fresh' -Root $script:RepoRoot @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:EnsuredPath | Should -Match '\.codex[\\/]state$'
            $script:WrittenStatePath | Should -Match 'batch-budget\.fresh\.json$'
            @($script:WrittenState.prodFiles) | Should -Contain $ProdPath
        }

        It 'loads an existing state file and honours its recorded cap' {
            $raw = @{ file_path = $ProdPath } | ConvertTo-Json -Compress
            $persisted = @{ prodCap = 1; testCap = 3; prodFiles = @($AltProd); testFiles = @() } | ConvertTo-Json -Compress
            $seams = @{
                TestPathExists  = { param([string] $Path) if ($Path) { $true } }
                EnsureDirectory = { param([string] $Path) if ($Path) { } }
                ReadState       = { param([string] $Path) if ($Path) { $persisted } }
                WriteState      = { param([string] $Path, [System.Collections.IDictionary] $State) if ($Path -and $State) { } }
            }

            $decision = & $script:HookFn -ToolInputRaw $raw -SessionId 'loaded' -Root $script:RepoRoot @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'production file cap is 1'
        }

        It 'ignores an unreadable state file and starts from the default caps' {
            $raw = @{ file_path = $ProdPath } | ConvertTo-Json -Compress
            $seams = @{
                TestPathExists  = { param([string] $Path) if ($Path) { $true } }
                EnsureDirectory = { param([string] $Path) if ($Path) { } }
                ReadState       = { param([string] $Path) throw "unreadable $Path" }
                WriteState      = { param([string] $Path, [System.Collections.IDictionary] $State) if ($Path -and $State) { } }
            }

            $decision = & $script:HookFn -ToolInputRaw $raw -SessionId 'unreadable' -Root $script:RepoRoot @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'still allows when the state file cannot be written' {
            $raw = @{ file_path = $ProdPath } | ConvertTo-Json -Compress
            $seams = @{
                TestPathExists  = { param([string] $Path) if ($Path) { $false } }
                EnsureDirectory = { param([string] $Path) if ($Path) { } }
                ReadState       = { param([string] $Path) if ($Path) { '{}' } }
                WriteState      = { param([string] $Path, [System.Collections.IDictionary] $State) throw "unwritable $Path for $($State.Count) keys" }
            }

            $decision = & $script:HookFn -ToolInputRaw $raw -SessionId 'unwritable' -Root $script:RepoRoot @seams

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows through its own entrypoint when the payload maps to no file edit' {
            $payload = ConvertTo-CodexBudgetPayload -ToolName 'Read' -ToolInput @{ file_path = $ProdPath }

            $result = Invoke-CodexBudgetEntrypoint -HookPath $script:HookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'allows through its own entrypoint for a mapped path outside the language surface' {
            $payload = ConvertTo-CodexBudgetPayload -ToolName 'Write' -ToolInput @{ file_path = $OtherExt; content = 'body' }

            $result = Invoke-CodexBudgetEntrypoint -HookPath $script:HookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'fails closed with exit 2 when its entrypoint receives empty stdin' {
            $result = Invoke-CodexBudgetEntrypoint -HookPath $script:HookPath -PayloadRaw ''

            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match "$HookName hook input is empty"
        }

        It 'fails closed with exit 2 when its entrypoint receives no session_id' {
            $payload = ConvertTo-CodexBudgetPayload -ToolName 'Write' -ToolInput @{ file_path = $OtherExt } -SessionId ''

            $result = Invoke-CodexBudgetEntrypoint -HookPath $script:HookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match "$HookName hook input is missing session_id"
        }
    }
}
