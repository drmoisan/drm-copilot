Set-StrictMode -Version Latest

# Workflow-invariant suite for .github/workflows/_shell-coverage.yml (issue #824).
#
# Location note: the Pester runner discovers tests under 'scripts', 'tests/powershell', and
# 'tests/scripts' (scripts/powershell/PoshQC/settings/pester.runsettings.psd1), so this file
# lives beside PoshQcWorkflow.Tests.ps1.
#
# The workflow is read from disk as text and split into step blocks: a step begins at a line
# of six spaces, '- name:', and the step name, and runs to the line before the next step
# start. No YAML parser module is imported, and no external process, temporary file, or
# network call is made.

Describe '_shell-coverage.yml workflow invariants' -Tag 'Issue824' {
    BeforeAll {
        $repoRoot = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../..')).Path
        $workflowLines = @(Get-Content -LiteralPath (Join-Path -Path $repoRoot -ChildPath '.github/workflows/_shell-coverage.yml'))
        $script:SetupLines = @(Get-Content -LiteralPath (Join-Path -Path $repoRoot -ChildPath '.codex/codex-web-setup.sh'))

        $script:StepNames = [System.Collections.Generic.List[string]]::new()
        $stepLines = @{}
        $current = $null
        foreach ($line in $workflowLines) {
            if ($line -match '^ {6}- name:[ \t]*(?<Name>.+?)[ \t]*$') {
                $current = [System.Collections.Generic.List[string]]::new()
                $script:StepNames.Add($Matches['Name'])
                $stepLines[$Matches['Name']] = $current
                continue
            }
            if ($null -ne $current) {
                $current.Add($line)
            }
        }

        $script:StepText = @{}
        foreach ($name in $script:StepNames) {
            $script:StepText[$name] = ($stepLines[$name] -join "`n")
        }
        $script:MeasureStep = 'Measure .codex/codex-web-setup.sh coverage with kcov (issue 824)'
        $script:GateStep = 'Gate .codex/codex-web-setup.sh changed-function coverage (issue 824)'
        $script:UploadStep = 'Upload .codex/codex-web-setup.sh coverage artifacts (issue 824)'
    }

    It 'W824-1 keeps the existing steps in order and adds the three issue 824 steps' {
        # Arrange
        $expected = @(
            'Check out repository',
            'Install shell tooling (shellcheck, shfmt, bats)',
            'Cache kcov build',
            'Build kcov from source',
            'Install kcov from cache',
            'Run shell-qc check (shfmt diff + shellcheck)',
            'Run shell-qc test with coverage',
            'Upload shell coverage artifacts',
            $script:MeasureStep,
            $script:UploadStep,
            $script:GateStep
        )

        # Act
        $actual = $script:StepNames -join '|'

        # Assert
        $actual | Should -BeExactly ($expected -join '|') -Because 'the dedicated measurement follows the existing coverage upload and leaves the existing steps in place'
    }

    It 'W824-2 leaves the full shell-qc coverage run and its artifact upload unchanged' {
        # Act
        $testStep = $script:StepText['Run shell-qc test with coverage']
        $upload = $script:StepText['Upload shell coverage artifacts']

        # Assert
        $testStep | Should -Match '(?m)^ {8}run: bash scripts/bash/shell-qc\.sh test --coverage[ \t]*$'
        $upload | Should -Match '(?m)^ {10}name: shell-coverage[ \t]*$'
        $upload | Should -Match '(?m)^ {10}path: artifacts/pester/kcov/\*\*[ \t]*$'
        $upload | Should -Match '(?m)^ {10}if-no-files-found: error[ \t]*$'
    }

    It 'W824-3 runs only the setup bats file under kcov with the include pattern restricted to the setup script' {
        # Act
        $step = $script:StepText[$script:MeasureStep]

        # Assert
        $step | Should -Match '(?m)^ {8}shell: bash[ \t]*$'
        $step | Should -Match ([regex]::Escape('"--include-pattern=${GITHUB_WORKSPACE}/.codex/codex-web-setup.sh"'))
        @([regex]::Matches($step, 'include-pattern=')).Count | Should -Be 1
        $step | Should -Match ([regex]::Escape('tests/shell/test_codex_web_setup_codex_copy.bats'))
        $step | Should -Match ([regex]::Escape('out_dir="artifacts/pester/kcov-codex-web-setup"'))
        $step | Should -Match ([regex]::Escape('BASE_SHA: ${{ github.event.pull_request.base.sha }}'))
        $step | Should -Not -Match 'exclude-pattern'
        $step | Should -Not -Match 'shell-qc\.sh'
    }

    It 'W824-4 gates the measurement with the dot-sourced coverage gate at 85 percent' {
        # Act
        $step = $script:StepText[$script:GateStep]

        # Assert
        $step | Should -Match '(?m)^ {8}shell: pwsh[ \t]*$'
        $step | Should -Match ([regex]::Escape('. ./scripts/dev-tools/KcovFunctionCoverageGate.ps1'))
        $step | Should -Match ([regex]::Escape("-CoberturaPath 'artifacts/pester/kcov-codex-web-setup/merged/kcov-merged/cov.xml'"))
        $step | Should -Match ([regex]::Escape("-SourcePath '.codex/codex-web-setup.sh'"))
        $step | Should -Match ([regex]::Escape('-Threshold 85'))
        $step | Should -Match ([regex]::Escape('exit $report.ExitCode'))
    }

    It 'W824-5 names exactly the six changed functions, each defined once in the setup script' {
        # Arrange
        $expected = @('resolve_repo_root', 'select_solution_file', 'list_root_solution_files', 'restore_packages_if_needed', 'verify_windows_visual_studio_task_capability', 'write_repo_notes')

        # Act
        $list = [regex]::Match($script:StepText[$script:GateStep], '-Function @\((?<List>[^)]*)\)')
        $names = @([regex]::Matches($list.Groups['List'].Value, "'(?<Name>[a-z_]+)'") | ForEach-Object { $_.Groups['Name'].Value })

        # Assert
        $list.Success | Should -BeTrue
        ($names -join ',') | Should -BeExactly ($expected -join ',')
        foreach ($name in $names) {
            @($script:SetupLines | Where-Object { $_ -ceq "$name() {" }).Count | Should -Be 1 -Because "$name must be defined exactly once in .codex/codex-web-setup.sh"
        }
    }

    It 'W824-6 uploads the dedicated measurement under its own artifact name' {
        # Act
        $step = $script:StepText[$script:UploadStep]

        # Assert
        $step | Should -Match '(?m)^ {8}uses: actions/upload-artifact@v7[ \t]*$'
        $step | Should -Match '(?m)^ {10}name: shell-coverage-codex-web-setup[ \t]*$'
        $step | Should -Match '(?m)^ {10}path: artifacts/pester/kcov-codex-web-setup/\*\*[ \t]*$'
        $step | Should -Match '(?m)^ {10}if-no-files-found: error[ \t]*$'
    }
}
