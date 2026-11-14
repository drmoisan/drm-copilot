# Pester tests for the scripts/dev-tools/Get-EpicProgressReport.ps1 forwarder (issue #1093).
# In-process cases invoke the real forwarder while Join-Path is mocked, for the canonical child
# path only, to return the committed stub target under tests/fixtures/dev-tools, so the exit
# handling runs without git, gh, cswap, or a file write. Child-process cases run the real
# forwarder and the real canonical entry with arguments that fail parameter validation before
# any git call or file write. $global:LASTEXITCODE is saved and restored around every case.

BeforeAll {
    $script:forwarderPath = Join-Path -Path $PSScriptRoot -ChildPath '../../../scripts/dev-tools/Get-EpicProgressReport.ps1'
    $script:canonicalChildPath = '../../.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1'
    $script:fixturePath = Join-Path -Path $PSScriptRoot -ChildPath '../../fixtures/dev-tools/Get-EpicProgressReport.ForwarderTarget.Fixture.ps1'
    $script:currentExecutable = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName

    function ConvertTo-TestPlainText {
        # Joins captured output and error records into one line without ANSI color sequences or
        # the '|' margin of the wrapped error view, so a wrapped phrase reads as one phrase.
        param([object[]] $Record)
        $joined = (@($Record | ForEach-Object { "$_" }) -join ' ') -replace '\x1b\[[0-9;]*m', ''
        ($joined -replace '\s+\|\s+', ' ') -replace '\s+', ' '
    }
}

Describe 'Get-EpicProgressReport.ps1 forwarder structure' {
    It 'targets an existing canonical entry' {
        $forwarderFolder = Split-Path -Path $script:forwarderPath -Parent
        $target = Join-Path -Path $forwarderFolder -ChildPath $script:canonicalChildPath

        Test-Path -LiteralPath $target -PathType Leaf | Should -BeTrue
        (Get-Content -LiteralPath $script:forwarderPath -Raw).Contains($script:canonicalChildPath) | Should -BeTrue
    }

    It 'holds no param block and the settled statement sequence' {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $script:forwarderPath).ProviderPath, [ref] $tokens, [ref] $parseErrors)

        $statements = @($ast.EndBlock.Statements | ForEach-Object { $_.Extent.Text })

        $parseErrors.Count | Should -Be 0
        $ast.ParamBlock | Should -BeNullOrEmpty
        @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)).Count | Should -Be 0
        $statements.Count | Should -Be 5
        $statements[0] | Should -Be "`$ErrorActionPreference = 'Stop'"
        $statements[1] | Should -Be '$global:LASTEXITCODE = 0'
        $statements[2] | Should -Be "& (Join-Path -Path `$PSScriptRoot -ChildPath '$($script:canonicalChildPath)') @args"
        $statements[3] | Should -Be 'if ($?) { exit 0 }'
        $statements[4] | Should -Be 'exit $(if ($LASTEXITCODE) { $LASTEXITCODE } else { 1 })'
    }
}

Describe 'Get-EpicProgressReport.ps1 forwarder exit handling (in process)' {
    BeforeEach {
        $script:savedExitCode = $global:LASTEXITCODE
        # The filter and the mock body run while the forwarder script is the current script
        # scope, so they read the test values by plain (dynamically scoped) names, not $script:.
        Mock Join-Path { return $fixturePath } -ParameterFilter { $ChildPath -eq $canonicalChildPath }
    }

    AfterEach {
        $global:LASTEXITCODE = $script:savedExitCode
    }

    It 'exits 0 after a normal target run' {
        $global:LASTEXITCODE = 5

        $output = @(& $script:forwarderPath -Behavior Normal -Count 2)

        $LASTEXITCODE | Should -Be 0
        $output | Should -Be @('forwarder fixture: Normal 2')
        Should -Invoke Join-Path -Times 1 -Exactly -ParameterFilter { $ChildPath -eq $script:canonicalChildPath }
    }

    It 'exits 0 when the target leaves a failed native exit code' {
        $output = @(& $script:forwarderPath -Behavior LeftoverNative)

        $LASTEXITCODE | Should -Be 0
        $output | Should -Be @('forwarder fixture: LeftoverNative 1')
    }

    It 'propagates an explicit target exit code' {
        $null = & $script:forwarderPath -Behavior Exit3

        $LASTEXITCODE | Should -Be 3
    }

    It 'raises a target parameter-validation error in process' {
        { & $script:forwarderPath -Behavior Normal -Count 0 } | Should -Throw -ExpectedMessage "*'Count'*"
    }
}

Describe 'Get-EpicProgressReport.ps1 forwarder exit status (child process)' {
    BeforeEach {
        $script:savedExitCode = $global:LASTEXITCODE
    }

    AfterEach {
        $global:LASTEXITCODE = $script:savedExitCode
    }

    It 'exits 1 with the canonical ValidateRange error for -SampleCap 0' {
        $record = @(& $script:currentExecutable -NoProfile -File $script:forwarderPath -EpicFolder example-epic -SampleCap 0 2>&1)
        $exitCode = $LASTEXITCODE

        $text = ConvertTo-TestPlainText -Record $record

        $exitCode | Should -Be 1
        $text | Should -BeLike "*'SampleCap'*"
        $text | Should -BeLike '*minimum allowed range*'
    }

    It 'exits 1 with the canonical ValidateSet error for -Mode Bogus' {
        $record = @(& $script:currentExecutable -NoProfile -File $script:forwarderPath -EpicFolder example-epic -Mode Bogus 2>&1)
        $exitCode = $LASTEXITCODE

        $text = ConvertTo-TestPlainText -Record $record

        $exitCode | Should -Be 1
        $text | Should -BeLike "*'Mode'*"
        $text | Should -BeLike '*does not belong to the set*'
    }
}
