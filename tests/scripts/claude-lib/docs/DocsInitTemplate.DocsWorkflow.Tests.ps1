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
    rules: every run step uses PowerShell 7, the documentation commands run through
    Invoke-DocsCommand.ps1, values reach steps through env:, every uses: reference is pinned to a
    commit, and the lint steps of issue #1219 (lint scope, markdownlint-cli2, the checksum-verified
    Vale install and the Vale run) follow the documentation steps. The lint-scope step body is run
    in memory with Get-Content and Add-Content mocked. Template sources are read read-only from the
    committed files; the commands under test write only to the in-memory context.
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

    function Get-TestStepBlock {
        # Returns the text of each step list item of the template, in order.
        $blocks = [regex]::Split(($script:TemplateText -replace "`r`n", "`n"), '(?m)^      - ')
        return @($blocks | Select-Object -Skip 1)
    }

    function Get-TestRunStepBlock {
        # Returns the text of each step list item of the template that carries a run: key.
        return @(Get-TestStepBlock | Where-Object { $_ -match '(?m)^\s*run:' })
    }

    function Get-TestBlockLine {
        # Returns the lines of one step block with trailing blank lines removed.
        param([string] $Block)
        $lines = [System.Collections.Generic.List[string]]::new()
        foreach ($line in ($Block -split "`n")) { $lines.Add($line) }
        while ($lines.Count -gt 0 -and [string]::IsNullOrWhiteSpace($lines[$lines.Count - 1])) { $lines.RemoveAt($lines.Count - 1) }
        return , $lines.ToArray()
    }

    function Get-TestRunBody {
        # Returns the lines of a run: | body of one step block with the common indentation removed.
        param([string] $Block)
        $lines = Get-TestBlockLine -Block $Block
        $start = [array]::FindIndex([string[]] $lines, [Predicate[string]] { param($line) $line -match '^\s*run: \|\s*$' })
        $body = @($lines | Select-Object -Skip ($start + 1))
        $indent = @($body | Where-Object { $_.Trim().Length -gt 0 } | ForEach-Object { $_.Length - $_.TrimStart().Length } | Measure-Object -Minimum).Minimum
        return , [string[]] @($body | ForEach-Object { if ($_.Length -ge $indent) { $_.Substring($indent) } else { $_.TrimStart() } })
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
        $steps.Count | Should -Be 7
        foreach ($step in $steps) { $step | Should -Match '(?m)^\s*shell: pwsh\s*$' }
    }

    It 'invokes Invoke-DocsCommand.ps1 with PowerShell 7 in every run step' {
        # Arrange: the four documentation-command steps are the run steps that carry -Command.
        $steps = @(Get-TestRunStepBlock | Where-Object { $_ -match '-Command ' })

        # Assert
        $steps.Count | Should -Be 4
        foreach ($step in $steps) { $step | Should -Match '(?m)^\s*run: pwsh -NoProfile -File \.claude/lib/docs/Invoke-DocsCommand\.ps1 -Command ' }
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
            # Act: the run body is every line from the run: key to the end of the step.
            $lines = Get-TestBlockLine -Block $step
            $runIndex = @(for ($index = 0; $index -lt $lines.Count; $index++) { if ($lines[$index] -match '^\s*run:') { $index } })
            $body = @($lines | Select-Object -Skip $runIndex[0])

            # Assert
            $runIndex.Count | Should -Be 1
            foreach ($line in $body) { $line | Should -Not -Match '\$\{\{' }
            @($body | Select-Object -Skip 1 | Where-Object { $_ -match '^ {8}[A-Za-z-]+:' }).Count | Should -Be 0 -Because 'run: is the last key of the step'
        }
    }

    It 'checks out the head revision with fetch-depth 0 and requests read-only contents permission' {
        $script:TemplateText | Should -Match '(?m)^\s*uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7\.0\.1\s*$'
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

    It 'runs markdownlint-cli2 with the estate configuration and the scope globs' {
        # Arrange
        $step = @(Get-TestStepBlock | Where-Object { $_ -match 'markdownlint-cli2-action' })

        # Assert
        $step.Count | Should -Be 1
        $step[0] | Should -Match '(?m)^\s*uses: DavidAnson/markdownlint-cli2-action@696eb3f2509270d7b882d2aa68347bc676e7af34 # v25\.0\.0\s*$'
        $step[0] | Should -Match '(?m)^\s*config: docs/documentation-estate/\.markdownlint\.json\s*$'
        $step[0] | Should -Match '(?m)^\s*globs: \$\{\{ steps\.docs-lint-scope\.outputs\.globs \}\}\s*$'
    }

    It 'resolves the lint scope from documentation_roots into globs and roots' {
        # Arrange
        $step = @(Get-TestStepBlock | Where-Object { $_ -match '(?m)^\s*id: docs-lint-scope\s*$' })

        # Act
        $body = Get-TestRunBody -Block $step[0]
        $text = $body -join "`n"

        # Assert
        $step.Count | Should -Be 1
        $step[0] | Should -Match '(?m)^\s*shell: pwsh\s*$'
        @($body | Where-Object { $_.Contains("Get-Content -Raw -LiteralPath 'docs/documentation-estate/docs-profile.json'") }).Count | Should -Be 1
        $text | Should -Match 'ConvertFrom-Json -AsHashtable'
        $text | Should -Match "documentation_roots'\]"
        $text | Should -Match 'DOCS_LINT_SCOPE_EMPTY'
        @($body | Where-Object { $_.Contains('Add-Content -LiteralPath $env:GITHUB_OUTPUT -Value ') }).Count | Should -Be 1
        $text | Should -Match 'globs<<DOCS_LINT_SCOPE_EOF'
        $text | Should -Match 'roots<<DOCS_LINT_SCOPE_EOF'
        $text | Should -Not -Match 'Set-Content|Out-File|>>'
        $text | Should -Not -Match '(?m)\bexit\b'
    }

    It 'writes one root/**/*.md glob and one root per documentation root, and throws DOCS_LINT_SCOPE_EMPTY for zero roots' {
        # Arrange: the committed step body runs in this process with its two I/O commands mocked.
        $step = @(Get-TestStepBlock | Where-Object { $_ -match '(?m)^\s*id: docs-lint-scope\s*$' })
        $body = [scriptblock]::Create(((Get-TestRunBody -Block $step[0]) -join "`n"))
        $script:LintScopeRecord = [System.Collections.Generic.List[string]]::new()
        $script:LintScopeProfile = '{"documentation_roots":[{"id":"docs","path":"docs"},{"id":"user","path":"guides/user"}]}'
        Mock Get-Content -ParameterFilter { $LiteralPath -eq 'docs/documentation-estate/docs-profile.json' } -MockWith { $script:LintScopeProfile }
        Mock Add-Content -MockWith { foreach ($item in @($Value)) { $script:LintScopeRecord.Add([string] $item) } }
        $priorOutput = $env:GITHUB_OUTPUT
        try {
            $env:GITHUB_OUTPUT = 'github-output-token'

            # Act
            & $body
            $twoRoots = $script:LintScopeRecord.ToArray()
            $script:LintScopeRecord.Clear()
            $script:LintScopeProfile = '{"documentation_roots":[]}'
            $thrown = $null
            try { & $body } catch { $thrown = $_.Exception.Message }
        } finally {
            $env:GITHUB_OUTPUT = $priorOutput
        }

        # Assert
        $twoRoots | Should -Be @('globs<<DOCS_LINT_SCOPE_EOF', 'docs/**/*.md', 'guides/user/**/*.md', 'DOCS_LINT_SCOPE_EOF', 'roots<<DOCS_LINT_SCOPE_EOF', 'docs', 'guides/user', 'DOCS_LINT_SCOPE_EOF')
        $thrown | Should -Match 'DOCS_LINT_SCOPE_EMPTY'
        $script:LintScopeRecord.Count | Should -Be 0
        Should -Invoke Add-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -ceq 'github-output-token' }
        Should -Invoke Add-Content -Times 1 -Exactly
    }

    It 'installs Vale 3.25.1 and throws VALE_SHA256_MISMATCH before tar' {
        # Arrange
        $step = @(Get-TestStepBlock | Where-Object { $_ -match '(?m)^\s*VALE_SHA256:' })

        # Act
        $lines = Get-TestBlockLine -Block $step[0]
        $indexOf = { param([scriptblock] $Test) @(for ($index = 0; $index -lt $lines.Count; $index++) { if (& $Test $lines[$index]) { $index } }) }
        $hash = & $indexOf { param($line) $line.Contains('Get-FileHash -Algorithm SHA256') }
        $throw = & $indexOf { param($line) $line.Contains('throw') -and $line.Contains('VALE_SHA256_MISMATCH') }
        $compare = & $indexOf { param($line) $line.Contains('-cne $env:VALE_SHA256') }
        $tar = & $indexOf { param($line) ($line.Trim() -split '\s+')[0] -ceq 'tar' }
        $anyTar = & $indexOf { param($line) $line.Trim() -match '(?:^|[;|&(]\s*)tar\s+-' }
        $version = & $indexOf { param($line) $line.Contains('"$env:RUNNER_TEMP/vale/vale"') -and $line.Contains('--version') }

        # Assert
        $step.Count | Should -Be 1
        $step[0] | Should -Match '(?m)^\s*VALE_VERSION: "3\.25\.1"\s*$'
        $step[0] | Should -Match '(?m)^\s*VALE_SHA256: "4bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182"\s*$'
        $step[0].Contains('https://github.com/vale-cli/vale/releases/download/v3.25.1/') | Should -BeTrue
        $hash.Count | Should -Be 1
        $lines[$hash[0]].Contains('.Hash.ToLowerInvariant()') | Should -BeTrue
        $throw.Count | Should -Be 1
        @($compare | Where-Object { $_ -le $throw[0] }).Count | Should -BeGreaterThan 0
        $tar.Count | Should -Be 1
        $anyTar[0] | Should -BeGreaterThan $throw[0] -Because 'the checksum throw precedes the first tar call'
        $tar[0] | Should -BeGreaterThan $throw[0]
        ($lines[$tar[0]].Trim() -split '\s+')[-1] | Should -BeExactly 'vale'
        $lines[$tar[0]] | Should -Match '\$env:RUNNER_TEMP/vale'
        $version.Count | Should -Be 1
        $version[0] | Should -BeGreaterThan $tar[0]
    }

    It 'runs Vale with the estate configuration and exits with its exit code' {
        # Arrange
        $step = @(Get-TestStepBlock | Where-Object { $_.Contains('--config docs/documentation-estate/.vale.ini') })

        # Act
        $lines = Get-TestBlockLine -Block $step[0]
        $call = @($lines | Where-Object { $_.Contains('$env:RUNNER_TEMP/vale/vale') })
        $assign = @($lines | Where-Object { $_.Contains('$valeRoots =') -and $_.Contains('$env:DOCS_LINT_ROOTS -split') -and $_.Contains('IsNullOrWhiteSpace') })

        # Assert
        $step.Count | Should -Be 1
        $step[0] | Should -Match '(?m)^\s*DOCS_LINT_ROOTS: \$\{\{ steps\.docs-lint-scope\.outputs\.roots \}\}\s*$'
        $call.Count | Should -Be 1
        $call[0].Contains('--config docs/documentation-estate/.vale.ini') | Should -BeTrue
        $call[0].Contains('--output line') | Should -BeTrue
        $call[0].TrimEnd().EndsWith('@valeRoots', [System.StringComparison]::Ordinal) | Should -BeTrue
        $assign.Count | Should -Be 1
        $step[0].IndexOf('foreach', [System.StringComparison]::OrdinalIgnoreCase) | Should -Be -1
        $lines[-1].Trim() | Should -BeExactly 'exit $LASTEXITCODE'
    }

    It 'states PowerShell 7, the pinned markdownlint-cli2 action and the checksum-verified Vale binary in the header comment' {
        # Arrange
        $lines = @($script:TemplateText -split "`r?`n")
        $nameIndex = [array]::FindIndex([string[]] $lines, [Predicate[string]] { param($line) $line.StartsWith('name:', [System.StringComparison]::Ordinal) })
        $header = @($lines | Select-Object -First $nameIndex)

        # Assert
        $nameIndex | Should -BeGreaterThan 0
        foreach ($line in $header) { $line | Should -Match '^#' }
        $text = $header -join ' '
        foreach ($token in 'PowerShell 7', 'markdownlint-cli2', 'pinned', 'checksum-verified', 'Vale') { $text.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the header states '$token'" }
        $text.Contains('only runtime', [System.StringComparison]::Ordinal) | Should -BeFalse
    }

    It 'pins every uses: reference to a commit SHA with a version comment' {
        # Arrange
        $uses = @($script:TemplateText -split "`r?`n" | Where-Object { $_ -match '^\s*(?:- )?uses:' })
        $pattern = '^\s*(?:- )?uses: (?<ref>[^@\s]+)@(?<sha>[0-9a-f]{40}) # v\d+\.\d+\.\d+\s*$'

        # Act
        $pinned = @{}
        foreach ($line in $uses) { $match = [regex]::Match($line, $pattern); if ($match.Success) { $pinned[$match.Groups['ref'].Value] = $match.Groups['sha'].Value } }

        # Assert
        $uses.Count | Should -Be 3
        foreach ($line in $uses) { $line | Should -Match $pattern }
        $pinned['actions/checkout'] | Should -BeExactly '3d3c42e5aac5ba805825da76410c181273ba90b1'
        $pinned['actions/upload-artifact'] | Should -BeExactly 'cf430e030ddbb5b0abf93d22962f4752f3646cd9'
        $pinned['DavidAnson/markdownlint-cli2-action'] | Should -BeExactly '696eb3f2509270d7b882d2aa68347bc676e7af34'
    }

    It 'grants only contents: read at the workflow and job levels' {
        # Arrange
        $lines = @($script:TemplateText -split "`r?`n")

        # Act: each permissions: key with the more-indented lines that follow it.
        $blocks = foreach ($index in @(for ($at = 0; $at -lt $lines.Count; $at++) { if ($lines[$at] -match '^\s*permissions:\s*$') { $at } })) {
            $indent = $lines[$index].Length - $lines[$index].TrimStart().Length
            $children = [System.Collections.Generic.List[string]]::new()
            for ($at = $index + 1; $at -lt $lines.Count -and ($lines[$at].Length - $lines[$at].TrimStart().Length) -gt $indent -and $lines[$at].Trim().Length -gt 0; $at++) { $children.Add($lines[$at].Trim()) }
            , @{ Indent = $indent; Children = $children.ToArray() }
        }

        # Assert
        @($blocks).Count | Should -Be 2
        @($blocks | ForEach-Object { $_.Indent }) | Should -Be @(0, 4)
        foreach ($block in $blocks) { $block.Children | Should -Be @('contents: read') }
        $script:TemplateText | Should -Not -Match '(?m)^[ \t]*permissions:[ \t]*\S' -Because 'no permissions: key carries an inline value such as write-all'
    }

    It 'orders the lint steps after the documentation steps under !cancelled() and uploads under always()' {
        # Arrange
        $steps = @(Get-TestStepBlock)
        $find = { param([scriptblock] $Test) @(for ($index = 0; $index -lt $steps.Count; $index++) { if (& $Test $steps[$index]) { $index } }) }

        # Act
        $documentation = & $find { param($step) $step -match '-Command ' }
        $scope = & $find { param($step) $step -match '(?m)^\s*id: docs-lint-scope\s*$' }
        $markdown = & $find { param($step) $step -match 'markdownlint-cli2-action' }
        $install = & $find { param($step) $step -match '(?m)^\s*VALE_SHA256:' }
        $vale = & $find { param($step) $step.Contains('--config docs/documentation-estate/.vale.ini') }
        $upload = & $find { param($step) $step -match 'actions/upload-artifact@' }

        # Assert
        $documentation.Count | Should -Be 4
        foreach ($set in @($scope, $markdown, $install, $vale, $upload)) { @($set).Count | Should -Be 1 }
        @(($documentation | Measure-Object -Maximum).Maximum, $scope[0], $markdown[0], $install[0], $vale[0], $upload[0]) | Should -Be @(4, 5, 6, 7, 8, 9)
        foreach ($index in @($scope[0], $markdown[0], $install[0], $vale[0])) { $steps[$index] | Should -Match '(?m)^\s*if: \$\{\{ !cancelled\(\) \}\}\s*$' }
        $steps[$upload[0]] | Should -Match '(?m)^\s*if: \$\{\{ always\(\) \}\}\s*$'
        $upload[0] | Should -Be ($steps.Count - 1)
    }
}
