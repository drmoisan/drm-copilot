#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit tests for .claude/hooks/bash-command-shape-guidance.ps1 (issue #1165).

.DESCRIPTION
    Covers Get-CdChainedCommandIntent (walk leg, wrapper-led raw leg, tool behind a wrapper,
    each tool, multi-step, empty and null input) and every branch of
    Get-CdChainedRewriteGuidance, plus a parse check that the helper dot-sources no file.

    Determinism: pure string functions over literal fixtures. The parse check reads the helper
    source through the PowerShell parser only. No disk write, no temporary file, no child
    process, and no live executable.
#>

Set-StrictMode -Version Latest

Describe 'bash-command-shape-guidance.ps1 (issue #1165)' {
    BeforeAll {
        $hooksRoot = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks'
        . (Join-Path -Path $hooksRoot -ChildPath 'hook-command-scanner.ps1')
        $script:HelperPath = (Resolve-Path -LiteralPath (Join-Path -Path $hooksRoot -ChildPath 'bash-command-shape-guidance.ps1')).Path
        . $script:HelperPath
        $script:ContextTokens = @('agent-isolated worktree', 'sibling worktree', '.claude/rules/bash-command-shape.md', 'Command-Text Restrictions')
    }

    Context 'Get-CdChainedCommandIntent' {
        It 'reports no tools and no multi-step for a plain read' {
            $intent = Get-CdChainedCommandIntent -Command 'cd /x && cat f' -ReadOp 'cat'
            $intent.Tools.Count | Should -Be 0
            $intent.IsMultiStep | Should -BeFalse
            $intent.CdTarget | Should -BeExactly '/x'
            $intent.ReadOp | Should -BeExactly 'cat'
        }

        It 'reports git for a git chain that ends in a read' {
            $intent = Get-CdChainedCommandIntent -Command 'cd /repo/wt && git status --short && git log --oneline -3 && cat f' -ReadOp 'cat'
            ($intent.Tools -join ',') | Should -BeExactly 'git'
            $intent.IsMultiStep | Should -BeFalse
            $intent.CdTarget | Should -BeExactly '/repo/wt'
        }

        It 'reports poetry behind the env wrapper' {
            $intent = Get-CdChainedCommandIntent -Command 'cd /repo/wt && env -u VIRTUAL_ENV poetry install --no-interaction 2>&1 | tail -n 20' -ReadOp 'tail'
            ($intent.Tools -join ',') | Should -BeExactly 'poetry'
            $intent.IsMultiStep | Should -BeFalse
        }

        It 'reports npm for an npm chain' {
            $intent = Get-CdChainedCommandIntent -Command 'cd /repo/wt && npm test | tail -n 5' -ReadOp 'tail'
            ($intent.Tools -join ',') | Should -BeExactly 'npm'
        }

        It 'reports npx for an npx chain' {
            $intent = Get-CdChainedCommandIntent -Command 'cd /repo/wt && npx jest | tail -n 5' -ReadOp 'tail'
            ($intent.Tools -join ',') | Should -BeExactly 'npx'
        }

        It 'reports multi-step for a chain holding git and poetry, in order and without duplicates' {
            $intent = Get-CdChainedCommandIntent -Command 'cd /repo/wt && git status && poetry install && git log | tail -n 5' -ReadOp 'tail'
            ($intent.Tools -join ',') | Should -BeExactly 'git,poetry'
            $intent.IsMultiStep | Should -BeTrue
        }

        It 'reads CdTarget and tools from a wrapper-led raw segment' {
            $intent = Get-CdChainedCommandIntent -Command 'bash -c "cd /x && git log | head"' -ReadOp 'head'
            $intent.CdTarget | Should -BeExactly '/x'
            ($intent.Tools -join ',') | Should -BeExactly 'git'
        }

        It 'reads a tool mentioned in a raw segment after a walk-leg cd' {
            $intent = Get-CdChainedCommandIntent -Command 'cd /repo/wt && bash -c "npm ci" && cat f' -ReadOp 'cat'
            ($intent.Tools -join ',') | Should -BeExactly 'npm'
        }

        It 'ignores tools that occur before the cd and raw segments without a nested cd' {
            $intent = Get-CdChainedCommandIntent -Command 'git fetch && env A=1 npm ci && cd /repo/wt && cat f' -ReadOp 'cat'
            $intent.Tools.Count | Should -Be 0
            $intent.CdTarget | Should -BeExactly '/repo/wt'
        }

        It 'does not count a path component or a hyphenated word as a tool' {
            $intent = Get-CdChainedCommandIntent -Command 'bash -c "cd /x && /usr/bin/git log && npm-run x | head"' -ReadOp 'head'
            $intent.Tools.Count | Should -Be 0
        }

        It 'returns a defined intent for empty input' {
            $intent = Get-CdChainedCommandIntent -Command '' -ReadOp ''
            $intent.Tools.Count | Should -Be 0
            $intent.CdTarget | Should -BeNullOrEmpty
            $intent.IsMultiStep | Should -BeFalse
        }

        It 'returns a defined intent for null input' {
            { Get-CdChainedCommandIntent -Command $null -ReadOp $null } | Should -Not -Throw
            $intent = Get-CdChainedCommandIntent -Command $null -ReadOp $null
            $intent.Tools.Count | Should -Be 0
            $intent.CdTarget | Should -BeNullOrEmpty
            $intent.IsMultiStep | Should -BeFalse
        }
    }

    Context 'Get-CdChainedRewriteGuidance' {
        It 'gives the read guidance and no tool form when no tool follows the cd' {
            $text = Get-CdChainedRewriteGuidance -Intent (Get-CdChainedCommandIntent -Command 'cd /x && cat f' -ReadOp 'cat')
            $text.Contains('Read or Grep tool', [System.StringComparison]::Ordinal) | Should -BeTrue
            $text.Contains('against the absolute path', [System.StringComparison]::Ordinal) | Should -BeTrue
            $text.Contains('run cat against', [System.StringComparison]::Ordinal) | Should -BeTrue
            foreach ($form in @('git -C', 'poetry -C', 'npm --prefix', 'sh <SCRATCH>/')) {
                $text.Contains($form, [System.StringComparison]::Ordinal) | Should -BeFalse -Because "the plain-read guidance names no $form form"
            }
        }

        It 'gives the git form with the cd target' {
            $text = Get-CdChainedRewriteGuidance -Intent ([pscustomobject]@{ ReadOp = 'cat'; CdTarget = '/repo/wt'; Tools = @('git'); IsMultiStep = $false })
            $text.Contains('git -C <abs>', [System.StringComparison]::Ordinal) | Should -BeTrue
            $text.Contains("'/repo/wt'", [System.StringComparison]::Ordinal) | Should -BeTrue
            $text.Contains('sh <SCRATCH>/', [System.StringComparison]::Ordinal) | Should -BeFalse
        }

        It 'gives the poetry form with env -u VIRTUAL_ENV and --directory' {
            $text = Get-CdChainedRewriteGuidance -Intent ([pscustomobject]@{ ReadOp = 'tail'; CdTarget = '/repo/wt'; Tools = @('poetry'); IsMultiStep = $false })
            foreach ($token in @('env -u VIRTUAL_ENV', 'poetry -C <abs>', '--directory')) {
                $text.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the poetry guidance names $token"
            }
        }

        It 'gives the npm form' {
            $text = Get-CdChainedRewriteGuidance -Intent ([pscustomobject]@{ ReadOp = 'tail'; CdTarget = '/repo/wt'; Tools = @('npm'); IsMultiStep = $false })
            $text.Contains('npm --prefix <abs>', [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'gives the npx package-script form and the sh route' {
            $text = Get-CdChainedRewriteGuidance -Intent ([pscustomobject]@{ ReadOp = 'tail'; CdTarget = '/repo/wt'; Tools = @('npx'); IsMultiStep = $false })
            $text.Contains('npm --prefix <abs> run <script>', [System.StringComparison]::Ordinal) | Should -BeTrue
            $text.Contains('sh <SCRATCH>/<file>.sh', [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'gives the sh route and each tool form for a multi-step chain' {
            $text = Get-CdChainedRewriteGuidance -Intent ([pscustomobject]@{ ReadOp = 'tail'; CdTarget = '/repo/wt'; Tools = @('git', 'poetry'); IsMultiStep = $true })
            foreach ($token in @('sh <SCRATCH>/<file>.sh', 'git -C <abs>', 'poetry -C <abs>', "'/repo/wt'")) {
                $text.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the multi-step guidance names $token"
            }
        }

        It 'falls back to generic wording for a null intent' {
            $text = Get-CdChainedRewriteGuidance -Intent $null
            $text.Contains('run the read command against the absolute path', [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'falls back to generic directory wording when the cd target is unknown' {
            $text = Get-CdChainedRewriteGuidance -Intent ([pscustomobject]@{ ReadOp = $null; CdTarget = $null; Tools = @('npm'); IsMultiStep = $false })
            $text.Contains('absolute path of the directory', [System.StringComparison]::Ordinal) | Should -BeTrue
            $text.Contains('into the read command', [System.StringComparison]::Ordinal) | Should -BeTrue
        }

        It 'ends every intent with the context sentence, which names no tool form' {
            $intents = @(
                [pscustomobject]@{ ReadOp = 'cat'; CdTarget = '/x'; Tools = @(); IsMultiStep = $false }
                [pscustomobject]@{ ReadOp = 'cat'; CdTarget = '/x'; Tools = @('git'); IsMultiStep = $false }
                [pscustomobject]@{ ReadOp = 'cat'; CdTarget = '/x'; Tools = @('npx', 'npm'); IsMultiStep = $true }
            )
            foreach ($intent in $intents) {
                $text = Get-CdChainedRewriteGuidance -Intent $intent
                $lastSentenceStart = $text.IndexOf('In an agent-isolated worktree', [System.StringComparison]::Ordinal)
                $lastSentenceStart | Should -BeGreaterThan 0
                $contextSentence = $text.Substring($lastSentenceStart)
                foreach ($token in $script:ContextTokens) {
                    $contextSentence.Contains($token, [System.StringComparison]::Ordinal) | Should -BeTrue -Because "the context sentence names $token"
                }
                foreach ($form in @('git -C', 'poetry -C', 'npm --prefix', 'sh <SCRATCH>/')) {
                    $contextSentence.Contains($form, [System.StringComparison]::Ordinal) | Should -BeFalse -Because "the context sentence names no $form form"
                }
            }
        }
    }

    Context 'helper file shape' {
        It 'the helper dot-sources no file' {
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HelperPath, [ref]$tokens, [ref]$parseErrors)
            @($parseErrors).Count | Should -Be 0
            $dotSources = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot }, $true))
            $dotSources.Count | Should -Be 0
            $functionNames = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object { $_.Name })
            $functionNames | Should -Contain 'Get-CdChainedCommandIntent'
            $functionNames | Should -Contain 'Get-CdChainedRewriteGuidance'
        }
    }
}
