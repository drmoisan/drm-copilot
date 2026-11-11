#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tests for the enforce-test-execution-policy PreToolUse hook (issue #1158, spec ## Hook, D19, D20,
    D25, D27, D33).

.DESCRIPTION
    The hook is dot-sourced, so its entry point does not run. Every case calls
    Invoke-TestExecutionPolicyDecision with an in-memory payload and injected seams for the
    configuration text, the lock probe, the holder record, the process start time, and the script
    file length and text; no case reads a lock, a holder record, or a script file.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    . (Join-Path $script:RepoRoot '.claude/hooks/enforce-test-execution-policy.ps1')
    $script:RepoConfigText = Get-Content -LiteralPath (Join-Path $script:RepoRoot 'config/test-execution-policy.json') -Raw
    $script:Holder = '{"pid":4242,"processStartUtc":"2026-01-01T00:00:00.0000000Z","suite":"pester","commandLine":[],"worktreeRoot":"/other","acquiredAtUtc":"2026-01-01T00:00:00.0000000Z","policyVersion":1}'
    $script:Launcher = 'sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh'

    function Invoke-HookCase {
        param(
            [AllowEmptyString()][string] $Command = '',
            [string] $Tool = 'Bash',
            [AllowNull()][object] $Config = $null,
            [switch] $Busy,
            [hashtable] $Script = @{},
            [hashtable] $Length = @{},
            [switch] $ThrowOnRead
        )

        $state = @{ Reads = [System.Collections.Generic.List[string]]::new(); Probes = 0 }
        $configValue = $Config
        $busyValue = [bool]$Busy
        $scriptValue = $Script
        $lengthValue = $Length
        $throwValue = [bool]$ThrowOnRead
        $holderValue = $script:Holder
        $payload = [ordered]@{ tool_name = $Tool; tool_input = [ordered]@{ command = $Command }; cwd = '/repo/wt' } | ConvertTo-Json -Compress
        $decision = Invoke-TestExecutionPolicyDecision -ToolInputRaw $payload `
            -ReadConfigText { $configValue }.GetNewClosure() `
            -ProbeLock { $state.Probes++; if ($busyValue) { 'Busy' } else { 'Free' } }.GetNewClosure() `
            -ReadHolderText { $holderValue }.GetNewClosure() `
            -GetProcessStartUtc { param([int] $Id) [void] $Id; [datetime]::new(2026, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc) } `
            -GetScriptFileLength {
            param([string] $Path)
            $key = $Path.Replace('\', '/')
            if ($lengthValue.ContainsKey($key)) { return $lengthValue[$key] }
            if ($scriptValue.ContainsKey($key)) { return $scriptValue[$key].Length }
            return $null
        }.GetNewClosure() `
            -ReadScriptText {
            param([string] $Path)
            $key = $Path.Replace('\', '/')
            $state.Reads.Add($key)
            if ($throwValue) { throw [System.IO.IOException]::new('unreadable') }
            $scriptValue[$key]
        }.GetNewClosure()
        $reason = $null
        if ($null -ne $decision) { $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
        return [pscustomobject]@{ Reason = $reason; Reads = $state.Reads; Probes = $state.Probes }
    }

    function ConvertTo-EncodedPayload {
        param([string] $Text)
        return [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Text))
    }
}

Describe 'enforce-test-execution-policy direct runners (issue #1158)' {
    It 'denies the preflight form <Command> naming suite <Suite>' -ForEach @(
        @{ Command = 'env -u VIRTUAL_ENV poetry run pytest -n auto'; Suite = 'pytest' }
        @{ Command = 'FOO=1 pytest'; Suite = 'pytest' }
        @{ Command = 'timeout 600 npx jest'; Suite = 'jest' }
        @{ Command = "env -u VIRTUAL_ENV bash -c 'pytest'"; Suite = 'pytest' }
        @{ Command = 'find tests -exec pytest {} +'; Suite = 'pytest' }
    ) {
        # Act
        $result = Invoke-HookCase -Command $Command

        # Assert
        $result.Reason | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED: test suites run only through the test-execution launcher*'
        $result.Reason | Should -BeLike "*test-execution policy*$script:Launcher $Suite*"
    }

    It 'denies the <Group> form <Command>' -ForEach @(
        @{ Group = 'prefix'; Command = 'nice -n 10 pytest' }
        @{ Group = 'launch command'; Command = 'uv run pytest' }
        @{ Group = 'wrapper'; Command = "sh -c 'pytest'" }
        @{ Group = 'chained'; Command = 'cd tests && pytest' }
        @{ Group = 'quoted'; Command = '"pytest" -q' }
        @{ Group = 'unmodeled'; Command = 'timeout --unknown 5 pytest' }
    ) {
        # Act / Assert
        (Invoke-HookCase -Command $Command).Reason | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED:*'
    }

    It 'allows <Command>' -ForEach @(
        @{ Command = 'echo pytest' }
        @{ Command = 'command -v pytest' }
        @{ Command = 'pytest --version' }
        @{ Command = 'npm run build' }
        @{ Command = 'npm run testing' }
        @{ Command = 'npm ci' }
        @{ Command = '' }
        @{ Command = '   ' }
    ) {
        # Act
        $result = Invoke-HookCase -Command $Command

        # Assert
        $result.Reason | Should -BeNullOrEmpty
        $result.Probes | Should -Be 0
    }

    It 'denies runner <Runner> <Shape> naming <Expected>' -ForEach @(
        foreach ($row in @(
                @{ Runner = 'pytest -q'; Expected = 'run-test-suite.sh pytest' }
                @{ Runner = 'py.test'; Expected = 'run-test-suite.sh pytest' }
                @{ Runner = 'jest'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'python -m pytest'; Expected = 'run-test-suite.sh pytest' }
                @{ Runner = 'node run-jest.cjs'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'npm test'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'npm t'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'npm run test'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'npm run test:unit'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'npm run test:unit:coverage'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'npm run-script test:unit'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'npm --prefix extensions/drm-copilot test'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'npm --prefix extensions/drm-copilot run test:coverage'; Expected = 'run-test-suite.sh jest' }
                @{ Runner = 'Invoke-Pester'; Expected = 'run-test-suite.sh pester' }
                @{ Runner = 'Invoke-PoshQCTest'; Expected = 'run-test-suite.sh pester' }
                @{ Runner = 'Invoke-PoshQCParallelTest'; Expected = 'run-test-suite.sh pester' }
                @{ Runner = 'Invoke-PoshQCSuite'; Expected = 'run-test-suite.sh pester' }
                @{ Runner = 'dotnet test'; Expected = 'run-test-suite.sh dotnet-test' }
                @{ Runner = 'bats tests/shell'; Expected = 'one of the suites pytest, pester, jest, dotnet-test' }
            )) {
            foreach ($shape in @('direct', 'sh -c', 'pwsh -Command', 'pwsh -EncodedCommand')) {
                @{ Runner = $row.Runner; Expected = $row.Expected; Shape = $shape }
            }
        }
    ) {
        # Arrange
        $command = switch ($Shape) {
            'direct' { $Runner }
            'sh -c' { "sh -c '$Runner'" }
            'pwsh -Command' { "pwsh -NoProfile -Command '$Runner'" }
            default { "pwsh -NoProfile -EncodedCommand $(ConvertTo-EncodedPayload -Text $Runner)" }
        }

        # Act
        $result = Invoke-HookCase -Command $command

        # Assert
        $result.Reason | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED: test suites run only through the test-execution launcher*'
        $result.Reason | Should -BeLike "*$Expected*"
    }

    It 'denies a runner reached through <Name>' -ForEach @(
        @{ Name = 'bash -c'; Command = "bash -c 'pytest'" }
        @{ Name = 'eval'; Command = 'eval pytest' }
        @{ Name = 'xargs'; Command = 'echo x | xargs pytest' }
        @{ Name = 'a substitution'; Command = 'echo "$(pytest)"' }
    ) {
        # Act / Assert
        (Invoke-HookCase -Command $Command).Reason | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED: test suites run only*'
    }

    It 'denies a direct Invoke-PesterSuite.ps1 run as the pester runner without reading the script' {
        # Act
        $result = Invoke-HookCase -Command 'pwsh -NoProfile -NonInteractive -File .claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1 -ExcludeTag Integration'

        # Assert
        $result.Reason | Should -BeLike '*test suites run only through the test-execution launcher*run-test-suite.sh pester*'
        $result.Reads.Count | Should -Be 0
    }

    It 'names the lock holder when the probe reports busy' {
        # Act
        $result = Invoke-HookCase -Command 'pytest -q' -Busy

        # Assert
        $result.Reason | Should -BeLike '*held by suite pester (pid 4242*'
    }

    It 'denies node run-jest.cjs as a direct runner without reading it' {
        # Act
        $result = Invoke-HookCase -Command 'node run-jest.cjs'

        # Assert
        $result.Reason | Should -BeLike '*test suites run only*run-test-suite.sh jest*'
        $result.Reads.Count | Should -Be 0
    }
}

Describe 'enforce-test-execution-policy launcher (issue #1158)' {
    It 'allows <Command>, also while the lock is busy' -ForEach @(
        @{ Command = 'sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest' }
        @{ Command = 'sh .agents/skills/test-execution-policy/scripts/run-test-suite.sh jest' }
        @{ Command = 'pwsh -NoProfile -File .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 pester' }
        @{ Command = 'pwsh -NoProfile -File .agents/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 pytest -v' }
        @{ Command = 'env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -k smoke' }
        @{ Command = 'sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -k pytest' }
    ) {
        # Act / Assert
        (Invoke-HookCase -Command $Command).Reason | Should -BeNullOrEmpty
        (Invoke-HookCase -Command $Command -Busy).Reason | Should -BeNullOrEmpty
    }

    It 'denies a launcher call that selects <Name>' -ForEach @(
        @{ Name = 'an integration path'; Command = "sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/a_integration.py"; Expected = '*local integration lane is CI-only evidence*' }
        @{ Name = 'a lane marker'; Command = "sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -m golden"; Expected = '*local golden lane is CI-only evidence*' }
        @{ Name = 'a lane tag'; Command = "sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -Tag Integration"; Expected = '*local integration lane is CI-only evidence*' }
        @{ Name = 'a worker token'; Command = "sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest --runInBand"; Expected = '*worker-reduction token*' }
    ) {
        # Act / Assert
        (Invoke-HookCase -Command $Command).Reason | Should -BeLike $Expected
    }

    It 'allows a launcher call with an integration path when localLanes.exclude is empty' {
        # Act / Assert
        (Invoke-HookCase -Command "$script:Launcher pytest tests/a_integration.py" -Config '{"version":1,"localLanes":{"exclude":[]}}').Reason | Should -BeNullOrEmpty
    }
}

Describe 'enforce-test-execution-policy hidden wrappers (issue #1158)' {
    It 'denies a <Name> wrapper whose text runs a suite' -ForEach @(
        @{ Name = 'sh'; Command = 'sh SCRATCH/w.sh'; Key = '/repo/wt/SCRATCH/w.sh'; Text = 'pytest -q' }
        @{ Name = 'bash'; Command = 'bash SCRATCH/w.sh'; Key = '/repo/wt/SCRATCH/w.sh'; Text = 'npx jest' }
        @{ Name = 'zsh'; Command = 'zsh SCRATCH/w.sh'; Key = '/repo/wt/SCRATCH/w.sh'; Text = 'pytest' }
        @{ Name = 'dash'; Command = 'dash SCRATCH/w.sh'; Key = '/repo/wt/SCRATCH/w.sh'; Text = 'pytest' }
        @{ Name = 'ksh'; Command = 'ksh SCRATCH/w.sh'; Key = '/repo/wt/SCRATCH/w.sh'; Text = 'pytest' }
        @{ Name = 'pwsh -File'; Command = 'pwsh -File SCRATCH/w.ps1'; Key = '/repo/wt/SCRATCH/w.ps1'; Text = 'Invoke-Pester -Path tests' }
        @{ Name = 'powershell -File'; Command = 'powershell -File SCRATCH/w.ps1'; Key = '/repo/wt/SCRATCH/w.ps1'; Text = 'Invoke-PoshQCParallelTest -Root .' }
        @{ Name = 'pwsh -File Invoke-PesterSuite call'; Command = 'pwsh -File SCRATCH/issue-1158-wrapper.ps1'; Key = '/repo/wt/SCRATCH/issue-1158-wrapper.ps1'; Text = '& .agents/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1' }
        @{ Name = 'python'; Command = 'python SCRATCH/w.py'; Key = '/repo/wt/SCRATCH/w.py'; Text = "import pytest`npytest.main([])" }
        @{ Name = 'python3'; Command = 'python3 SCRATCH/w.py'; Key = '/repo/wt/SCRATCH/w.py'; Text = 'run(["pytest"])' }
        @{ Name = 'poetry run python'; Command = 'poetry run python SCRATCH/w.py'; Key = '/repo/wt/SCRATCH/w.py'; Text = 'pytest.main([])' }
        @{ Name = 'node .cjs'; Command = 'node SCRATCH/w.cjs'; Key = '/repo/wt/SCRATCH/w.cjs'; Text = "require('./run-jest.cjs');" }
        @{ Name = 'node .mjs'; Command = 'node SCRATCH/w.mjs'; Key = '/repo/wt/SCRATCH/w.mjs'; Text = "spawn('pytest', []);" }
        @{ Name = 'SCRATCH run-test-suite.sh'; Command = 'sh SCRATCH/run-test-suite.sh pytest'; Key = '/repo/wt/SCRATCH/run-test-suite.sh'; Text = 'poetry run pytest "$@"' }
        @{ Name = 'prefixed sh'; Command = 'env -u VIRTUAL_ENV sh SCRATCH/issue-1158-wrapper.sh'; Key = '/repo/wt/SCRATCH/issue-1158-wrapper.sh'; Text = 'pytest' }
    ) {
        # Act
        $result = Invoke-HookCase -Command $Command -Script @{ $Key = $Text }

        # Assert
        $result.Reason | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED: hidden wrapper suite launch*test-execution policy*run-test-suite.sh*'
        $result.Reads | Should -Contain $Key
    }

    It 'allows a <Name>' -ForEach @(
        @{ Name = '.js operand with no runner word'; Command = 'node SCRATCH/w.js'; Key = '/repo/wt/SCRATCH/w.js'; Text = "console.log('ok');" }
        @{ Name = 'sh wrapper whose only launch is the launcher'; Command = 'sh SCRATCH/w.sh'; Key = '/repo/wt/SCRATCH/w.sh'; Text = 'env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest' }
        @{ Name = 'analyzer-only script'; Command = 'pwsh -File SCRATCH/w.ps1'; Key = '/repo/wt/SCRATCH/w.ps1'; Text = 'Invoke-ScriptAnalyzer -Path scripts' }
        @{ Name = 'leak-scan script'; Command = 'pwsh -File SCRATCH/w.ps1'; Key = '/repo/wt/SCRATCH/w.ps1'; Text = 'Invoke-PoshQCLeakScan -Root .' }
        @{ Name = 'format script'; Command = 'pwsh -File SCRATCH/w.ps1'; Key = '/repo/wt/SCRATCH/w.ps1'; Text = 'Invoke-PoshQCFormat -Path .' }
        @{ Name = 'missing script'; Command = 'sh SCRATCH/absent.sh'; Key = '/repo/wt/SCRATCH/other.sh'; Text = 'pytest' }
    ) {
        # Act / Assert
        (Invoke-HookCase -Command $Command -Script @{ $Key = $Text }).Reason | Should -BeNullOrEmpty
    }

    It 'allows an unreadable script' {
        # Act / Assert
        (Invoke-HookCase -Command 'sh SCRATCH/w.sh' -Script @{ '/repo/wt/SCRATCH/w.sh' = 'pytest' } -ThrowOnRead).Reason | Should -BeNullOrEmpty
    }

    It 'resolves a relative operand against the payload cwd' {
        # Act
        $result = Invoke-HookCase -Command 'sh tools/w.sh' -Script @{ '/repo/wt/tools/w.sh' = 'pytest' }

        # Assert
        ($result.Reads -join ',') | Should -BeExactly '/repo/wt/tools/w.sh'
    }

    It 'reads and denies a script of 262144 bytes and allows one of 262145 bytes unread' {
        # Arrange
        $key = '/repo/wt/SCRATCH/w.sh'

        # Act
        $atLimit = Invoke-HookCase -Command 'sh SCRATCH/w.sh' -Script @{ $key = 'pytest' } -Length @{ $key = 262144 }
        $overLimit = Invoke-HookCase -Command 'sh SCRATCH/w.sh' -Script @{ $key = 'pytest' } -Length @{ $key = 262145 }

        # Assert
        $atLimit.Reason | Should -BeLike '*hidden wrapper suite launch*'
        $overLimit.Reason | Should -BeNullOrEmpty
        $overLimit.Reads.Count | Should -Be 0
    }
}

Describe 'enforce-test-execution-policy MCP tools (issue #1158)' {
    It 'denies <Tool> naming the holder when the lock is busy and allows it when free' -ForEach @(
        @{ Tool = 'mcp__drm-copilot__run_poshqc_test' }
        @{ Tool = 'mcp__drm-copilot__run_poshqc_suite' }
    ) {
        # Act
        $busy = Invoke-HookCase -Tool $Tool -Busy
        $free = Invoke-HookCase -Tool $Tool
        $disabled = Invoke-HookCase -Tool $Tool -Busy -Config '{"version":1,"machineLock":{"enabled":false}}'

        # Assert
        $busy.Reason | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED:*test-execution policy*held by suite pester (pid 4242*run-test-suite.sh pester*'
        $free.Reason | Should -BeNullOrEmpty
        $disabled.Reason | Should -BeNullOrEmpty
    }

    It 'allows mcp__drm-copilot__run_poshqc_analyze while the lock is busy' {
        # Act
        $result = Invoke-HookCase -Tool 'mcp__drm-copilot__run_poshqc_analyze' -Busy

        # Assert
        $result.Reason | Should -BeNullOrEmpty
        $result.Probes | Should -Be 0
    }
}

Describe 'enforce-test-execution-policy knobs and configuration (issue #1158)' {
    It 'denies <Command> naming the configuration file and field when the configuration is invalid' -ForEach @(
        @{ Command = 'pytest -q' }
        @{ Command = 'sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest' }
    ) {
        # Act / Assert
        (Invoke-HookCase -Command $Command -Config '{"version":2}').Reason | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED:*config/test-execution-policy.json*version*'
    }

    It 'allows a non-test command when the configuration is invalid' {
        # Act / Assert
        (Invoke-HookCase -Command 'git status' -Config '{"version":2}').Reason | Should -BeNullOrEmpty
    }

    It 'allows a direct runner and an unread wrapper when requireLauncher is false' {
        # Arrange
        $config = '{"version":1,"requireLauncher":false}'

        # Act
        $direct = Invoke-HookCase -Command 'pytest -q' -Config $config
        $wrapper = Invoke-HookCase -Command 'sh SCRATCH/w.sh' -Config $config -Script @{ '/repo/wt/SCRATCH/w.sh' = 'pytest' }
        $lane = Invoke-HookCase -Command 'pytest tests/a_integration.py' -Config $config

        # Assert
        $direct.Reason | Should -BeNullOrEmpty
        $wrapper.Reason | Should -BeNullOrEmpty
        $wrapper.Reads.Count | Should -Be 0
        $lane.Reason | Should -BeLike '*local integration lane is CI-only evidence*'
    }

    It 'reads the repository configuration for the bats suite name' {
        # Act / Assert
        (Invoke-HookCase -Command 'bats tests/shell' -Config $script:RepoConfigText).Reason | Should -BeLike '*run-test-suite.sh bats*'
    }
}

Describe 'enforce-test-execution-policy seam override and edge flows (issue #1158)' {
    It 'denies the launcher seam override in <Name>' -ForEach @(
        @{ Name = 'a pwsh -c payload'; Command = "pwsh -c '`$TestSuiteLauncherSeams=@{}; & .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 pytest'"; Script = @{} }
        @{ Name = 'a pwsh -EncodedCommand payload'; Command = 'ENCODED'; Script = @{} }
        @{ Name = 'a wrapper file'; Command = 'pwsh -File SCRATCH/issue-1158-wrapper.ps1'; Script = @{ '/repo/wt/SCRATCH/issue-1158-wrapper.ps1' = '$PesterSuiteSeams = @{}; & ./Invoke-PesterSuite.ps1' } }
    ) {
        # Arrange
        $command = $Command
        if ($command -eq 'ENCODED') { $command = "pwsh -EncodedCommand $(ConvertTo-EncodedPayload -Text '$TestSuiteLauncherSeams=@{}; & .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 pytest')" }

        # Act / Assert
        (Invoke-HookCase -Command $command -Script $Script).Reason | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED: launcher seam override*'
    }

    It 'allows a malformed payload' {
        # Act / Assert
        Invoke-TestExecutionPolicyDecision -ToolInputRaw '{not json' -ReadConfigText { $null } | Should -BeNullOrEmpty
    }

    It 'denies an undecodable PowerShell payload only when its visible text holds a runner word' {
        # Act
        $withRunner = Invoke-HookCase -Command 'pwsh -EncodedCommand @@@ pytest'
        $withoutRunner = Invoke-HookCase -Command 'pwsh -EncodedCommand @@@'

        # Assert
        $withRunner.Reason | Should -BeLike 'TEST_EXECUTION_POLICY_BLOCKED:*'
        $withoutRunner.Reason | Should -BeNullOrEmpty
    }

    It 'denies through the dependency guard when <Name> failed to load' -ForEach @(
        @{ Name = 'hook-command-invocation.ps1' }
        @{ Name = 'test-execution-command-form.ps1' }
    ) {
        # Arrange
        Add-HookDependencyFailure -Name $Name
        try {
            # Act
            $result = Invoke-HookCase -Command 'echo ok'
        } finally {
            $script:HookDependencyFailures.Clear()
        }

        # Assert
        $result.Reason | Should -BeLike "TEST_EXECUTION_POLICY_BLOCKED: the dependency '$Name' failed to load*"
    }
}
