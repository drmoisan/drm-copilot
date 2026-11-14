#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Tests for the pure command-form helper of the test-execution policy hook (issue #1158,
    spec D19, D20, D25, D27, D33).

.DESCRIPTION
    Every case runs against both byte-identical copies, .claude/hooks and .codex/hooks, with
    hook-command-invocation.ps1 dot-sourced from the same folder. All inputs are in-memory
    strings; the only file read is the committed config/test-execution-policy.json.
#>

BeforeDiscovery {
    $script:Copies = @(
        @{ Folder = '.claude/hooks' }
        @{ Folder = '.codex/hooks' }
    )
}

Describe 'test-execution-command-form (<Folder>)' -ForEach $script:Copies {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot "$Folder/hook-command-invocation.ps1")
        . (Join-Path $repoRoot "$Folder/test-execution-policy.ps1")
        . (Join-Path $repoRoot "$Folder/test-execution-command-form.ps1")
        $script:RepoConfigText = Get-Content -LiteralPath (Join-Path $repoRoot 'config/test-execution-policy.json') -Raw

        function Get-TestRunner {
            param([string] $CommandText)
            foreach ($entry in @(Get-TestExecutionCommandRecord -CommandText $CommandText)) {
                if ($null -ne (Get-TestExecutionLauncherMatch -Form $entry.Form)) { continue }
                $runner = Get-TestExecutionRunnerMatch -Form $entry.Form -CommandText $CommandText
                if ($runner) { return $runner }
            }
            return ''
        }

        function Get-TestLauncher {
            param([string] $CommandText)
            foreach ($entry in @(Get-TestExecutionCommandRecord -CommandText $CommandText)) {
                $match = Get-TestExecutionLauncherMatch -Form $entry.Form
                if ($null -ne $match) { return $match }
            }
            return $null
        }
    }

    Context 'direct runner forms' {
        It 'reports runner <Runner> for <Command>' -ForEach @(
            @{ Command = 'pytest -q'; Runner = 'pytest' }
            @{ Command = 'PYTEST -q'; Runner = 'pytest'; Form = 'upper-case command word' }
            @{ Command = '"pytest" -q'; Runner = 'pytest' }
            @{ Command = "'poetry' run 'pytest'"; Runner = 'pytest' }
            @{ Command = "p'y'test"; Runner = 'pytest' }
            @{ Command = '.venv/bin/pytest'; Runner = 'pytest' }
            @{ Command = '.venv/Scripts/pytest.exe'; Runner = 'pytest' }
            @{ Command = 'py.test'; Runner = 'pytest' }
            @{ Command = 'FOO=1 pytest'; Runner = 'pytest' }
            @{ Command = 'FOO=1 BAR=2 poetry run pytest'; Runner = 'pytest' }
            @{ Command = 'env -u VIRTUAL_ENV poetry run pytest -n auto'; Runner = 'pytest' }
            @{ Command = 'env --unset=VIRTUAL_ENV pytest'; Runner = 'pytest' }
            @{ Command = 'env -i PATH=/usr/bin pytest'; Runner = 'pytest' }
            @{ Command = 'env -C tests pytest'; Runner = 'pytest' }
            @{ Command = 'env -- pytest'; Runner = 'pytest' }
            @{ Command = "env -S 'pytest -q'"; Runner = 'pytest' }
            @{ Command = 'timeout 600 npx jest'; Runner = 'jest' }
            @{ Command = 'timeout -s KILL -k 5 600 pytest'; Runner = 'pytest' }
            @{ Command = 'timeout --signal=TERM 600 pytest'; Runner = 'pytest' }
            @{ Command = 'time pytest'; Runner = 'pytest' }
            @{ Command = 'time -p pytest'; Runner = 'pytest' }
            @{ Command = '/usr/bin/time -v -o out.txt pytest'; Runner = 'pytest' }
            @{ Command = 'command pytest'; Runner = 'pytest' }
            @{ Command = 'command -p pytest'; Runner = 'pytest' }
            @{ Command = 'nohup pytest'; Runner = 'pytest' }
            @{ Command = 'exec pytest'; Runner = 'pytest' }
            @{ Command = 'nice -n 10 pytest'; Runner = 'pytest' }
            @{ Command = 'stdbuf -oL pytest'; Runner = 'pytest' }
            @{ Command = 'sudo -E pytest'; Runner = 'pytest' }
            @{ Command = 'env -u VIRTUAL_ENV timeout 600 poetry run pytest'; Runner = 'pytest' }
            @{ Command = 'poetry -C . run pytest'; Runner = 'pytest' }
            @{ Command = 'poetry --directory=. run pytest'; Runner = 'pytest' }
            @{ Command = 'poetry run python -m pytest'; Runner = 'pytest' }
            @{ Command = 'python -m pytest'; Runner = 'pytest' }
            @{ Command = 'python3 -X dev -m pytest'; Runner = 'pytest' }
            @{ Command = 'py -m pytest'; Runner = 'pytest' }
            @{ Command = 'coverage run -m pytest'; Runner = 'pytest' }
            @{ Command = 'python -m coverage run -m pytest'; Runner = 'pytest' }
            @{ Command = "python -c 'import pytest; pytest.main()'"; Runner = 'pytest' }
            @{ Command = 'uv run pytest'; Runner = 'pytest' }
            @{ Command = 'uv run --with pytest-xdist pytest'; Runner = 'pytest' }
            @{ Command = 'uvx pytest'; Runner = 'pytest' }
            @{ Command = 'pipx run pytest'; Runner = 'pytest' }
            @{ Command = 'jest'; Runner = 'jest' }
            @{ Command = 'node_modules/.bin/jest'; Runner = 'jest' }
            @{ Command = 'npx jest'; Runner = 'jest' }
            @{ Command = 'npx --yes jest'; Runner = 'jest' }
            @{ Command = 'npx -p jest jest'; Runner = 'jest' }
            @{ Command = "npx -c 'jest --ci'"; Runner = 'jest' }
            @{ Command = 'npm exec -- jest'; Runner = 'jest' }
            @{ Command = 'npm x jest'; Runner = 'jest' }
            @{ Command = 'node run-jest.cjs'; Runner = 'jest' }
            @{ Command = 'node node_modules/jest/bin/jest.js'; Runner = 'jest' }
            @{ Command = "node -e `"require('child_process').execSync('npx jest')`""; Runner = 'jest' }
            @{ Command = 'npm test'; Runner = 'jest' }
            @{ Command = 'npm t'; Runner = 'jest' }
            @{ Command = 'npm run test'; Runner = 'jest' }
            @{ Command = 'npm run test:unit'; Runner = 'jest' }
            @{ Command = 'npm run test:unit:coverage'; Runner = 'jest' }
            @{ Command = 'npm run-script test:unit'; Runner = 'jest' }
            @{ Command = 'npm --prefix extensions/drm-copilot test'; Runner = 'jest' }
            @{ Command = 'npm --prefix extensions/drm-copilot run test:coverage'; Runner = 'jest' }
            @{ Command = 'npm --prefix=extensions/drm-copilot run test:coverage'; Runner = 'jest' }
            @{ Command = 'npm run -s test:unit'; Runner = 'jest' }
            @{ Command = 'npm -w extensions/drm-copilot test'; Runner = 'jest' }
            @{ Command = 'bats tests/shell'; Runner = 'bats' }
            @{ Command = 'scripts/bash/shell-qc.sh test'; Runner = 'bats' }
            @{ Command = 'sh scripts/bash/shell-qc.sh test'; Runner = 'bats' }
            @{ Command = 'dotnet test'; Runner = 'mstest' }
            @{ Command = "pwsh -c 'Invoke-Pester'"; Runner = 'pester' }
            @{ Command = "pwsh -Command 'Pester\Invoke-Pester'"; Runner = 'pester' }
            @{ Command = "pwsh -c '& Invoke-pester'"; Runner = 'pester' }
            @{ Command = "pwsh -c 'Invoke-PoshQCParallelTest'"; Runner = 'pester' }
            @{ Command = 'pwsh -NoProfile -NonInteractive -File .claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1'; Runner = 'pester' }
            @{ Command = "pwsh -c '& ./Invoke-PesterSuite.ps1'"; Runner = 'pester' }
            @{ Command = "sh -c 'pytest'"; Runner = 'pytest' }
            @{ Command = "bash -lc 'poetry run pytest'"; Runner = 'pytest' }
            @{ Command = "env -u VIRTUAL_ENV bash -c 'pytest'"; Runner = 'pytest' }
            @{ Command = "timeout 600 sh -c 'npx jest'"; Runner = 'jest' }
            @{ Command = "find tests -name '*.py' -exec pytest {} +"; Runner = 'pytest' }
            @{ Command = 'xargs pytest'; Runner = 'pytest' }
            @{ Command = 'eval pytest'; Runner = 'pytest' }
            @{ Command = 'R=pytest; $R -q'; Runner = 'pytest' }
        ) {
            # Act
            $actual = Get-TestRunner -CommandText $Command

            # Assert
            $actual | Should -BeExactly $Runner -Because "command: $Command"
        }
    }

    Context 'chained commands' {
        It 'finds runner <Runner> in <Command>' -ForEach @(
            @{ Command = 'cd tests && pytest'; Runner = 'pytest' }
            @{ Command = 'echo ok; pytest'; Runner = 'pytest' }
            @{ Command = 'pytest | tee SCRATCH/out.txt'; Runner = 'pytest' }
            @{ Command = 'ls || npx jest'; Runner = 'jest' }
            @{ Command = 'true & pytest'; Runner = 'pytest' }
            @{ Command = "echo ok`npytest"; Runner = 'pytest' }
            @{ Command = '(pytest)'; Runner = 'pytest'; Single = $true }
            @{ Command = '{ pytest; }'; Runner = 'pytest'; Single = $true }
            @{ Command = 'echo "$(pytest)"'; Runner = 'pytest' }
        ) {
            # Act
            $entries = @(Get-TestExecutionCommandRecord -CommandText $Command)
            $runners = @($entries | ForEach-Object { Get-TestExecutionRunnerMatch -Form $_.Form -CommandText $Command })

            # Assert
            @($runners | Where-Object { $_ -ceq $Runner }).Count | Should -BeGreaterThan 0
            if (-not $Single) {
                # The other command of the chain runs no suite.
                @($runners | Where-Object { -not $_ }).Count | Should -BeGreaterThan 0
            }
        }
    }

    Context 'unmodeled options' {
        It 'flags <Command> as unmodeled and reports runner <Runner>' -ForEach @(
            @{ Command = 'timeout --unknown 5 pytest'; Runner = 'pytest' }
            @{ Command = 'env --bogus pytest'; Runner = 'pytest' }
        ) {
            # Act
            $entry = @(Get-TestExecutionCommandRecord -CommandText $Command)[0]

            # Assert
            $entry.Form.Unmodeled | Should -BeTrue
            Get-TestExecutionRunnerMatch -Form $entry.Form | Should -BeExactly $Runner
        }
    }

    Context 'allowed commands' {
        It 'reports no runner for <Command>' -ForEach @(
            @{ Command = 'echo pytest' }
            @{ Command = 'grep -n pytest file.txt' }
            @{ Command = "git commit -m 'fix pytest'" }
            @{ Command = 'rg Invoke-Pester' }
            @{ Command = 'cat pytest.ini' }
            @{ Command = 'command -v pytest' }
            @{ Command = 'command -V jest' }
            @{ Command = 'pytest --version' }
            @{ Command = 'npx jest --help' }
            @{ Command = 'env -u VIRTUAL_ENV poetry run black .' }
            @{ Command = 'poetry run pyright' }
            @{ Command = 'npx prettier --check .' }
            @{ Command = 'npm run build' }
            @{ Command = 'npm run testing' }
            @{ Command = 'npm run typecheck:test' }
            @{ Command = 'npm ci' }
            @{ Command = 'npm run lint' }
            @{ Command = 'shell-qc.sh check' }
            @{ Command = 'dotnet build' }
            @{ Command = 'timeout --unknown 5 ls' }
            @{ Command = '$EDITOR notes.md' }
            @{ Command = 'sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -k pytest' }
        ) {
            # Act / Assert
            Get-TestRunner -CommandText $Command | Should -BeExactly '' -Because "command: $Command"
        }

        It 'marks command -v as a lookup' {
            # Act
            $entry = @(Get-TestExecutionCommandRecord -CommandText 'command -v pytest')[0]

            # Assert
            $entry.Form.Lookup | Should -BeTrue
        }
    }

    Context 'sanctioned launcher' {
        It 'matches <Command> with suite <Suite> and extras <Extras>' -ForEach @(
            @{ Command = 'sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -k pytest'; Suite = 'pytest'; Extras = '-k pytest' }
            @{ Command = 'bash .agents/skills/test-execution-policy/scripts/run-test-suite.sh jest'; Suite = 'jest'; Extras = '' }
            @{ Command = 'env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -k smoke'; Suite = 'pytest'; Extras = '-k smoke' }
            @{ Command = 'timeout 900 sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester'; Suite = 'pester'; Extras = '' }
            @{ Command = 'pwsh -NoProfile -NonInteractive -File .claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 pester'; Suite = 'pester'; Extras = '' }
            @{ Command = 'cd x && sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh bats'; Suite = 'bats'; Extras = '' }
        ) {
            # Act
            $match = Get-TestLauncher -CommandText $Command

            # Assert
            $match | Should -Not -BeNullOrEmpty
            $match.Suite | Should -BeExactly $Suite
            ($match.Extras -join ' ') | Should -BeExactly $Extras
        }

        It 'does not match a run-test-suite.sh script-file operand outside the skill folders' {
            # Act / Assert
            Get-TestLauncher -CommandText 'sh SCRATCH/run-test-suite.sh pytest' | Should -BeNullOrEmpty
        }
    }

    Context 'D20 suite lookup' {
        It 'returns no suite for bats without a configured bats suite' {
            # Arrange
            $policy = Get-TestExecutionPolicy -ReadText { $null }

            # Act / Assert
            Get-TestExecutionRunnerSuite -Runner 'bats' -Policy $policy | Should -BeExactly ''
        }

        It 'returns bats for bats with the repository configuration' {
            # Arrange
            $policy = Get-TestExecutionPolicy -ReadText { $script:RepoConfigText }

            # Act / Assert
            Get-TestExecutionRunnerSuite -Runner 'bats' -Policy $policy | Should -BeExactly 'bats'
        }

        It 'maps <Command> to suite <Suite>' -ForEach @(
            @{ Command = 'npm run test:unit'; Suite = 'jest' }
            @{ Command = 'dotnet test'; Suite = 'dotnet-test' }
            @{ Command = 'pytest -q'; Suite = 'pytest' }
            @{ Command = "pwsh -c 'Invoke-Pester'"; Suite = 'pester' }
        ) {
            # Arrange
            $policy = Get-TestExecutionPolicy -ReadText { $script:RepoConfigText }

            # Act
            $runner = Get-TestRunner -CommandText $Command

            # Assert
            Get-TestExecutionRunnerSuite -Runner $runner -Policy $policy | Should -BeExactly $Suite
        }
    }

    Context 'hidden-wrapper text' {
        It 'matches <Language> text <Name> as <Runner>' -ForEach @(
            @{ Language = 'Shell'; Name = 'pytest'; Text = "#!/bin/sh`npytest -q"; Runner = 'pytest' }
            @{ Language = 'Shell'; Name = 'prefixed pytest'; Text = 'env -u VIRTUAL_ENV poetry run pytest'; Runner = 'pytest' }
            @{ Language = 'PowerShell'; Name = 'Invoke-Pester'; Text = "Import-Module Pester`nInvoke-Pester -Path tests"; Runner = 'pester' }
            @{ Language = 'PowerShell'; Name = 'Invoke-PesterSuite call'; Text = '& .claude/skills/test-execution-policy/scripts/Invoke-PesterSuite.ps1'; Runner = 'pester' }
            @{ Language = 'Python'; Name = 'pytest.main'; Text = "import pytest`npytest.main(['-q'])"; Runner = 'pytest' }
            @{ Language = 'Python'; Name = 'quoted argv'; Text = "import sys`nrun([`"pytest`", `"-q`"])"; Runner = 'pytest' }
            @{ Language = 'JavaScript'; Name = 'run-jest.cjs (.cjs)'; Text = "require('./run-jest.cjs');"; Runner = 'jest' }
            @{ Language = 'JavaScript'; Name = 'quoted pytest (.mjs)'; Text = "spawn('pytest', ['-q']);"; Runner = 'pytest' }
            @{ Language = 'JavaScript'; Name = 'runCLI (.js)'; Text = 'await runCLI(argv, projects);'; Runner = 'jest' }
        ) {
            # Act / Assert
            Get-TestExecutionHiddenWrapperMatch -Language $Language -Text $Text | Should -BeExactly $Runner
        }

        It 'does not match <Language> text <Name>' -ForEach @(
            @{ Language = 'Shell'; Name = 'echo'; Text = 'echo pytest' }
            @{ Language = 'Shell'; Name = 'sole sanctioned launcher'; Text = 'sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest' }
            @{ Language = 'PowerShell'; Name = 'Write-Host string'; Text = "Write-Host 'Invoke-Pester'" }
            @{ Language = 'PowerShell'; Name = 'analyzer only'; Text = 'Invoke-ScriptAnalyzer -Path scripts -Settings pssa.settings.psd1' }
            @{ Language = 'PowerShell'; Name = 'leak scan'; Text = 'Invoke-PoshQCLeakScan -Root .' }
            @{ Language = 'PowerShell'; Name = 'format'; Text = 'Invoke-PoshQCFormat -Path .' }
            @{ Language = 'Python'; Name = 'comment mention'; Text = "# runs pytest later`nprint('hello')" }
            @{ Language = 'JavaScript'; Name = 'no runner word (.js)'; Text = "console.log('hello');" }
        ) {
            # Act / Assert
            Get-TestExecutionHiddenWrapperMatch -Language $Language -Text $Text | Should -BeExactly ''
        }
    }

    Context 'script-file operands' {
        It 'reads <Command> as language <Language>' -ForEach @(
            @{ Command = 'sh SCRATCH/issue-1158-wrapper.sh'; Language = 'Shell' }
            @{ Command = 'env -u VIRTUAL_ENV sh SCRATCH/issue-1158-wrapper.sh'; Language = 'Shell' }
            @{ Command = 'pwsh -File SCRATCH/issue-1158-wrapper.ps1'; Language = 'PowerShell' }
            @{ Command = 'poetry run python SCRATCH/issue-1158-wrapper.py'; Language = 'Python' }
            @{ Command = 'node SCRATCH/issue-1158-wrapper.mjs'; Language = 'JavaScript' }
        ) {
            # Act
            $entry = @(Get-TestExecutionCommandRecord -CommandText $Command)[0]

            # Assert
            (Get-TestExecutionScriptOperand -Form $entry.Form).Language | Should -BeExactly $Language
        }

        It 'reads no script file for <Command>' -ForEach @(
            @{ Command = "sh -c 'echo hi'" }
            @{ Command = 'node run-jest.cjs' }
            @{ Command = 'python -m pytest' }
            @{ Command = 'echo hi' }
        ) {
            # Act
            $entry = @(Get-TestExecutionCommandRecord -CommandText $Command)[0]

            # Assert
            Get-TestExecutionScriptOperand -Form $entry.Form | Should -BeNullOrEmpty
        }
    }

    Context 'launcher seam override (D33)' {
        It 'matches <Text>' -ForEach @(
            @{ Text = '$TestSuiteLauncherSeams = @{}; & ./Invoke-TestSuite.ps1 pytest' }
            @{ Text = '$pestersuiteseams=@{}' }
            @{ Text = 'Set-Variable TestSuiteLauncherSeams 1' }
        ) {
            # Act / Assert
            Get-TestExecutionSeamOverrideMatch -Text $Text | Should -BeTrue
        }

        It 'does not match <Text>' -ForEach @(
            @{ Text = 'TestSuiteLauncher' }
            @{ Text = 'PesterSuite' }
        ) {
            # Act / Assert
            Get-TestExecutionSeamOverrideMatch -Text $Text | Should -BeFalse
        }
    }
}
