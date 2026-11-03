#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Text assertions for the cleanup-merged-worktrees skill and the execution-environment brief (issue #1026).

.DESCRIPTION
    Reads the committed .claude/skills/cleanup-merged-worktrees/SKILL.md and
    .claude/skills/execution-environment/SKILL.md, isolates the sections under test by heading
    and step number, and compares whitespace-normalized text, so a reflow of the prose does not
    change any result. No row writes a file, starts a process, or reads gitignored state.
#>

BeforeAll {
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path

    # Return the text from a heading line to the next heading of the same or a higher level.
    function Get-SkillSectionText {
        param([Parameter(Mandatory)] [string] $Text, [Parameter(Mandatory)] [string] $Heading)
        $lines = @($Text -split "`r?`n")
        $start = [array]::IndexOf($lines, $Heading)
        if ($start -lt 0) { throw "heading '$Heading' not found" }
        $level = ($Heading -split ' ')[0]
        $end = $lines.Count
        for ($index = $start + 1; $index -lt $lines.Count; $index++) {
            if ($lines[$index] -match '^(#+) ' -and $Matches[1].Length -le $level.Length) { $end = $index; break }
        }
        return (($lines[$start..($end - 1)]) -join "`n")
    }

    # Return one numbered step of a section, from its marker to the next step marker.
    function Get-SkillStepText {
        param([Parameter(Mandatory)] [string] $Section, [Parameter(Mandatory)] [int] $Step)
        $match = [regex]::Match($Section, "(?ms)^$Step\. \*\*.*?(?=^$($Step + 1)\. \*\*|\z)")
        if (-not $match.Success) { throw "step $Step not found" }
        return $match.Value
    }

    function ConvertTo-NormalizedText {
        param([Parameter(Mandatory)] [AllowEmptyString()] [string] $Text)
        return ($Text -replace '\s+', ' ').Trim()
    }

    $skill = Get-Content -Raw -LiteralPath (Join-Path $repoRoot '.claude/skills/cleanup-merged-worktrees/SKILL.md')
    $workflow = Get-SkillSectionText -Text $skill -Heading '## End-to-End Workflow'
    $script:Step3 = ConvertTo-NormalizedText -Text (Get-SkillStepText -Section $workflow -Step 3)
    $script:Step4 = ConvertTo-NormalizedText -Text (Get-SkillStepText -Section $workflow -Step 4)
    $script:Manifest = ConvertTo-NormalizedText -Text (Get-SkillSectionText -Text $skill -Heading '## Sanctioned Removal Manifest')
    $brief = Get-Content -Raw -LiteralPath (Join-Path $repoRoot '.claude/skills/execution-environment/SKILL.md')
    $script:HookContext = ConvertTo-NormalizedText -Text (Get-SkillSectionText -Text $brief -Heading '## Hook Execution Context')
}

Describe 'cleanup-merged-worktrees skill text (issue #1026)' {
    Context 'End-to-End Workflow step 3' {
        It 'names the cleanup context and the session-root manifest location' {
            $script:Step3 | Should -Match ([regex]::Escape('**Cleanup context.**'))
            $script:Step3 | Should -Match ([regex]::Escape('the sanctioned-removal manifest at the session root (`artifacts/orchestration/cleanup-worktrees-manifest.json`'))
            $script:Step3 | Should -Match ([regex]::Escape('identified by its branch `documentationandmemories`'))
        }

        It 'names git -C staging of allowlisted paths and the commit with git commit -F' {
            $script:Step3 | Should -Match ([regex]::Escape('`git -C <consolidation root> add -- <path>` with paths under `docs/` or `.claude/agent-memory/` only'))
            $script:Step3 | Should -Match ([regex]::Escape('`git -C <consolidation root> commit -F <message file>` with no pathspec'))
        }
    }

    Context 'End-to-End Workflow step 4' {
        It 'names collect_pr_context with workspace_root set to the consolidation worktree' {
            $script:Step4 | Should -Match ([regex]::Escape('`mcp__drm-copilot__collect_pr_context` using base branch `main` and `workspace_root` set to the consolidation worktree'))
        }

        It 'names the explicit head and base of the consolidation pull request' {
            $script:Step4 | Should -Match ([regex]::Escape('`--head documentationandmemories --base main`'))
        }

        It 'states that the hooks perform the cleanup readiness check' {
            $script:Step4 | Should -Match ([regex]::Escape('the hooks perform the cleanup readiness check instead'))
            $script:Step4 | Should -Match ([regex]::Escape('only while a fresh, valid manifest exists at the session root'))
        }

        It 'names the non-isolated delegation with the absolute body path and the consolidation branch label' {
            $script:Step4 | Should -Match ([regex]::Escape('The delegation is non-isolated and passes the absolute body path'))
            $script:Step4 | Should -Match ([regex]::Escape('exactly one `branch: documentationandmemories` label'))
        }

        It 'states that the push precedes gh pr create and that the pushed branch must equal the consolidation worktree HEAD' {
            $script:Step4 | Should -Match ([regex]::Escape('The push precedes `gh pr create`'))
            $script:Step4 | Should -Match ([regex]::Escape('`refs/remotes/origin/documentationandmemories` to resolve to the same commit as the consolidation worktree `HEAD`'))
        }

        It 'no longer requires --require-pr-creation-ready for consolidation pull requests' {
            $script:Step4 | Should -Not -Match ([regex]::Escape('--require-pr-creation-ready'))
            $script:Step4 | Should -Not -Match ([regex]::Escape('pr_author_preflight'))
        }
    }

    Context 'Sanctioned Removal Manifest' {
        It 'states the session-root location of the manifest' {
            $script:Manifest | Should -Match ([regex]::Escape('The manifest lives at the session root: the main checkout where this skill runs.'))
        }

        It 'states that an Edit of the manifest is not supported without a checkpoint' {
            $script:Manifest | Should -Match ([regex]::Escape('An Edit of the manifest is not supported without a checkpoint'))
        }
    }

    Context 'execution-environment brief' {
        It 'states the cleanup legs and the scratch rule in Hook Execution Context' {
            $script:HookContext | Should -Match ([regex]::Escape('hook-cleanup-context.ps1'))
            $script:HookContext | Should -Match ([regex]::Escape('Get-OrchestrationGateTemporaryRoot'))
            $script:HookContext | Should -Match ([regex]::Escape('`gh pr create --head documentationandmemories --base main`'))
        }

        It 'states the published-head condition and the consolidation sub-code in Hook Execution Context' {
            $script:HookContext | Should -Match ([regex]::Escape('the pushed `refs/remotes/origin/documentationandmemories` resolves to the same commit as the consolidation worktree `HEAD`'))
            $script:HookContext | Should -Match ([regex]::Escape('appends a cleanup sub-code (`Cleanup leg not applied`)'))
        }
    }
}
