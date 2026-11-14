#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the issue 1034 docs workflow row of Get-DocsInitTemplate and the committed
    consumer workflow template .claude/lib/docs/templates/_docs-quality.yml.

.DESCRIPTION
    Covers the init template row under the 1034 docs workflow anchor, init planning and writing
    of .github/workflows/_docs-quality.yml through the in-memory command context of
    Docs.TestSupport.psm1 (dry run, create, existing destination), and the template content
    rules: PowerShell 7 is the only runtime, the documentation commands run through
    Invoke-DocsCommand.ps1, the revision reaches steps through env:, and the checkout carries
    full history. Template sources are read read-only from the committed files; the commands
    under test write only to the in-memory context.
#>

BeforeAll {
    $script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $script:LibraryRoot = Join-Path -Path $script:RepositoryRoot -ChildPath '.claude/lib'
    Import-Module -Name (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfileCommands.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Docs.TestSupport.psm1') -Force -ErrorAction Stop

    $script:TemplateSource = '.claude/lib/docs/templates/_docs-quality.yml'
    $script:TemplateDestination = '.github/workflows/_docs-quality.yml'
    $script:TemplateText = [System.IO.File]::ReadAllText((Join-Path -Path $script:RepositoryRoot -ChildPath $script:TemplateSource))

    # The committed text of every init template source, so -Write tests can supply them in memory.
    $script:SourceFiles = @{}
    $rows = Get-DocsInitTemplate
    foreach ($row in $rows) { $script:SourceFiles[[string] $row.Source] = [System.IO.File]::ReadAllText((Join-Path -Path $script:RepositoryRoot -ChildPath $row.Source)) }
    # Issue #1173 B6: init exits 0 only when the starter source root lists a file.
    $script:SourceFiles['src/app.py'] = "value = 1`n"

    function Get-TestRunStepBlock {
        # Returns the text of each step list item of the template that carries a run: key.
        $blocks = [regex]::Split($script:TemplateText, '(?m)^      - ')
        return @($blocks | Select-Object -Skip 1 | Where-Object { $_ -match '(?m)^\s*run:' })
    }
}

AfterAll {
    Remove-Module -Name DocsProfileCommands, DocsProfile, DocsAnalyzerRegistry, DocsSurface, DocsSchema, DocsSchemaWalk, DocsFinding, DocsJson, DiscoveryEncoding, Docs.TestSupport -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsInitTemplate docs workflow row' {
    It 'returns exactly one row mapping the template source to .github/workflows/_docs-quality.yml' {
        # Act
        $rows = Get-DocsInitTemplate
        $match = @($rows | Where-Object { $_.Source -ceq $script:TemplateSource })

        # Assert
        $match.Count | Should -Be 1
        $match[0].Destination | Should -BeExactly $script:TemplateDestination
    }

    It 'places the row directly under the 1034 docs workflow anchor' {
        # Arrange
        $lines = @(Get-Content -LiteralPath (Join-Path -Path $script:LibraryRoot -ChildPath 'docs/DocsProfileCommands.psm1'))
        $trimmed = [string[]] @($lines | ForEach-Object { $_.Trim() })

        # Act
        $anchor = [array]::IndexOf($trimmed, '# --- 1034: docs workflow ---')

        # Assert
        $anchor | Should -BeGreaterThan -1
        $trimmed[$anchor + 1] | Should -BeExactly "[pscustomobject]@{ Source = '.claude/lib/docs/templates/_docs-quality.yml'; Destination = '.github/workflows/_docs-quality.yml' }"
    }
}

Describe 'init with the docs workflow template' {
    It 'lists the workflow destination in planned_writes and writes nothing without -Write' {
        # Arrange
        $test = New-DocsTestContext -File $script:SourceFiles

        # Act
        $result = Invoke-DocsInitCommand -Argument @{} -Context $test.Context
        $entry = @($result.Result.planned_writes | Where-Object { $_.path -ceq $script:TemplateDestination })

        # Assert
        $result.ExitCode | Should -Be 0
        $entry.Count | Should -Be 1
        $entry[0].action | Should -BeExactly 'create'
        $test.WriteLog.Count | Should -Be 0
    }

    It 'writes the committed template text to the workflow destination under -Write' {
        # Arrange
        $test = New-DocsTestContext -File $script:SourceFiles

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ Write = $true } -Context $test.Context
        $write = @($test.WriteLog | Where-Object { $_.RelativePath -ceq $script:TemplateDestination })

        # Assert
        $result.ExitCode | Should -Be 0
        $write.Count | Should -Be 1
        $write[0].Mode | Should -BeExactly 'create'
        $write[0].Text | Should -BeExactly $script:TemplateText
    }

    It 'exits 1 with DOCS_INIT_TARGET_EXISTS naming the workflow destination when it exists and -Force is absent' {
        # Arrange
        $files = @{}
        foreach ($key in $script:SourceFiles.Keys) { $files[$key] = $script:SourceFiles[$key] }
        $files[$script:TemplateDestination] = 'name: existing'
        $test = New-DocsTestContext -File $files

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ Write = $true } -Context $test.Context
        $entry = @($result.Result.planned_writes | Where-Object { $_.path -ceq $script:TemplateDestination })

        # Assert
        $result.ExitCode | Should -Be 1
        @($result.Findings).Count | Should -Be 1
        $result.Findings[0].code | Should -BeExactly 'DOCS_INIT_TARGET_EXISTS'
        $result.Findings[0].artifact_path | Should -BeExactly $script:TemplateDestination
        $entry[0].action | Should -BeExactly 'exists'
        $test.WriteLog.Count | Should -Be 0
    }

    It 'emits the ci-workflow line after the action lines and the ci_workflow field in <Mode> mode (issue #1173 B13)' -ForEach @(
        @{ Mode = 'dry-run'; Write = $false }
        @{ Mode = 'write'; Write = $true }
    ) {
        # Arrange
        $test = New-DocsTestContext -File $script:SourceFiles

        # Act
        $result = Invoke-DocsInitCommand -Argument @{ Write = $Write } -Context $test.Context
        [string[]] $lines = @($result.Line)

        # Assert
        $result.ExitCode | Should -Be 0
        $result.Result['ci_workflow'] | Should -BeExactly $script:TemplateDestination
        $lines[-1] | Should -BeExactly "ci-workflow $script:TemplateDestination"
        @($lines | Where-Object { $_ -ceq "create $script:TemplateDestination" }).Count | Should -Be 1 -Because 'the ordinary action line stays'
        @($lines | Where-Object { $_.StartsWith('ci-workflow ', [System.StringComparison]::Ordinal) }).Count | Should -Be 1
        $lines.Count | Should -Be (@($result.Result.planned_writes).Count + 1)
    }

    It 'sets ci_workflow to null and emits no ci-workflow line when no template row targets .github/workflows/ (issue #1173 B13)' {
        # Arrange
        $row = [pscustomobject]@{ Source = '.claude/lib/docs/templates/page-check/vale.ini'; Destination = 'docs/documentation-estate/.vale.ini' }
        $test = New-DocsTestContext -File $script:SourceFiles

        # Act
        $result = Invoke-DocsInitCommand -Argument @{} -Context $test.Context -TemplateRow @($row)

        # Assert
        $result.ExitCode | Should -Be 0
        $result.Result.Contains('ci_workflow') | Should -BeTrue
        $result.Result['ci_workflow'] | Should -BeNullOrEmpty
        @($result.Line | Where-Object { ([string] $_).StartsWith('ci-workflow ', [System.StringComparison]::Ordinal) }).Count | Should -Be 0
    }
}

Describe 'docs workflow template content' {
    It 'sets shell: pwsh on every run step' {
        # Act
        $steps = Get-TestRunStepBlock

        # Assert
        $steps.Count | Should -Be 4
        foreach ($step in $steps) { $step | Should -Match '(?m)^\s*shell: pwsh\s*$' }
    }

    It 'invokes Invoke-DocsCommand.ps1 with PowerShell 7 in every run step' {
        foreach ($step in (Get-TestRunStepBlock)) { $step | Should -Match '(?m)^\s*run: pwsh -NoProfile -File \.claude/lib/docs/Invoke-DocsCommand\.ps1 -Command ' }
    }

    It 'runs inventory, check and validate in docs-complete mode with the revision and the receipt switch' {
        $script:TemplateText | Should -Match 'Invoke-DocsCommand\.ps1 -Command inventory '
        $script:TemplateText | Should -Match 'Invoke-DocsCommand\.ps1 -Command check -Json'
        $script:TemplateText | Should -Match 'Invoke-DocsCommand\.ps1 -Command validate -Mode docs-complete -Revision "\$env:DOCS_REVISION" -WriteReceipt'
    }

    It 'runs surface-delta only when the base-ref input is supplied' {
        # Arrange
        $step = @(Get-TestRunStepBlock | Where-Object { $_ -match '-Command surface-delta' })

        # Assert
        $step.Count | Should -Be 1
        $step[0] | Should -Match "(?m)^\s*if: \$\{\{ inputs\.base-ref != '' \}\}\s*$"
        $step[0] | Should -Match '-Base "\$env:DOCS_BASE_REF"'
    }

    It 'passes the revision through env: and uses no inline expression inside run:' {
        # Assert
        $script:TemplateText | Should -Match '(?m)^\s*DOCS_REVISION: \$\{\{ github\.event\.pull_request\.head\.sha \|\| github\.sha \}\}\s*$'
        foreach ($step in (Get-TestRunStepBlock)) {
            $runLine = @($step -split "`n" | Where-Object { $_ -match '^\s*run:' })
            $runLine.Count | Should -Be 1
            $runLine[0] | Should -Not -Match '\$\{\{'
        }
    }

    It 'checks out the head revision with fetch-depth 0 and requests read-only contents permission' {
        $script:TemplateText | Should -Match '(?m)^\s*uses: actions/checkout@v7\s*$'
        $script:TemplateText | Should -Match '(?m)^\s*fetch-depth: 0\s*$'
        $script:TemplateText | Should -Match '(?m)^\s*ref: \$\{\{ github\.event\.pull_request\.head\.sha \|\| github\.sha \}\}\s*$'
        $script:TemplateText | Should -Match '(?m)^\s*runs-on: ubuntu-latest\s*$'
        $script:TemplateText | Should -Match '(?m)^\s*contents: read\s*$'
        $script:TemplateText | Should -Match '(?m)^\s*workflow_call:\s*$'
        $script:TemplateText | Should -Match '(?m)^\s*workflow_dispatch:\s*$'
    }

    It 'contains no <_> token' -ForEach @('setup-python', 'setup-node', 'python', 'npm', 'node') {
        $script:TemplateText.IndexOf($_, [System.StringComparison]::OrdinalIgnoreCase) | Should -Be -1
    }

    It 'contains no linter step' {
        $script:TemplateText.IndexOf('lint', [System.StringComparison]::OrdinalIgnoreCase) | Should -Be -1
    }
}
