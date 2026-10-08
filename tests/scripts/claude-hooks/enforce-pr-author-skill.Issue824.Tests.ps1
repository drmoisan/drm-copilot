#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    pr-author skill gate decisions over the issue #824 corpus (T-PRA, rows PA-01 to PA-22).

.DESCRIPTION
    Drives Invoke-PrAuthorSkillDecision and Get-PrAuthorBypassReason in
    .claude/hooks/enforce-pr-author-skill.ps1. Commands that only mention gh pr create are
    allowed; the --body-file value is read structurally and normalized before the canonical
    path test; inline-body and no-body creates stay denied.

    PA-20 is the negative control: it reinstates substring presence through a mock of
    Test-CommandLineWordPresent and shows that the R-733-GREP G1 command would then deny.

    Determinism: the context artifact, the worktree target, the orchestrator-state preflight,
    the receipt, and the body-file root arrive only through mocked seams. No temporary file,
    no child process, and no live executable.
#>

BeforeDiscovery {
    $script:NonCanonicalRows = @(
        @{ Id = 'PA-11'; Command = 'gh pr create --head bug/x-5 --body-file docs/pr_body_5.md' }
        @{ Id = 'PA-12'; Command = 'gh pr create --head bug/x-5 --body-file artifacts/pr_body_x.md' }
        @{ Id = 'PA-13'; Command = 'gh pr create --head bug/x-5 --body-file /elsewhere/artifacts/pr_body_5.md' }
        @{ Id = 'PA-14'; Command = 'echo --body-file artifacts/pr_body_5.md; gh pr create --head bug/x-5 --body-file notes/pr.md' }
        @{ Id = 'PA-15'; Command = 'gh pr create --head bug/x-5 --body-file ../artifacts/pr_body_5.md' }
    )
    $script:ReceiptRows = @(
        @{ Id = 'PA-06'; Command = 'gh pr create --head bug/x-5 --body-file "artifacts/pr_body_5.md"' }
        @{ Id = 'PA-07'; Command = 'gh pr create --head bug/x-5 --body-file=artifacts/pr_body_5.md' }
        @{ Id = 'PA-08'; Command = 'gh pr create --head bug/x-5 --body-file /session/artifacts/pr_body_5.md' }
        @{ Id = 'PA-09'; Command = 'gh pr create --head bug/x-5 --body-file ./artifacts/pr_body_5.md' }
        @{ Id = 'PA-10'; Command = 'gh pr create --head bug/x-5 --body-file artifacts\pr_body_5.md' }
    )
    $script:SkillBlockedRows = @(
        @{ Id = 'PA-16'; Command = 'gh pr create --head bug/x-5' }
        @{ Id = 'PA-17'; Command = 'gh pr create --head bug/x-5 --body x' }
        @{ Id = 'PA-18'; Command = 'gh pr edit 5 --body x' }
        @{ Id = 'PA-19'; Command = 'bash -c "gh pr create --body x"' }
    )
    $script:GrepRows = @(
        @{ Id = 'PA-02'; Name = 'G1'; Command = 'pwsh -NoProfile -Command ''Select-String -Path x.md -Pattern "high priority" | ForEach-Object { "create" }''' }
        @{ Id = 'PA-03'; Name = 'G2'; Command = 'echo "$(sed -n ''1,20p'' notes.md | grep -n ''through the process that created it'')"' }
        @{ Id = 'PA-04'; Name = 'G3'; Command = 'echo "$(grep -n ''gh pr create'' notes.md)"' }
    )
}

Describe 'enforce-pr-author-skill issue #824 decisions' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.claude/hooks/enforce-pr-author-skill.ps1')
        $script:R733714 = @(
            'git commit -m "$(cat <<''EOF'''
            'fix(hooks): route the matcher through the process that created the payload'
            'The change runs through every segment.'
            'EOF'
            ')"'
        ) -join "`n"
        $script:G1 = 'pwsh -NoProfile -Command ''Select-String -Path x.md -Pattern "high priority" | ForEach-Object { "create" }'''

        function Invoke-PrAuthorRow {
            <# Run the skill gate decision for one command and return the decision. #>
            param([Parameter(Mandatory)][string] $Command)
            $envelope = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5
            return Invoke-PrAuthorSkillDecision -ToolInputRaw $envelope
        }
    }

    Context 'commands that mention gh pr create without invoking it' {
        BeforeEach {
            Mock Get-PrContextArtifactExistence { $true }
        }

        It 'PA-01 allows R-733-714' -Tag 'Issue824', 'R-733-714' {
            (Invoke-PrAuthorRow -Command $script:R733714).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It '<Id> allows the R-733-GREP <Name> command' -Tag 'Issue824', 'R-733-GREP' -ForEach $script:GrepRows {
            (Invoke-PrAuthorRow -Command $Command).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'PA-05 allows the fixture AC-18 Select-String command' -Tag 'Issue824' {
            $command = 'pwsh -NoProfile -Command ''Select-String -Path README.md -Pattern "high priority" | ForEach-Object { "create" }'''
            (Invoke-PrAuthorRow -Command $command).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'body-file normalization and receipt verification' {
        BeforeEach {
            Mock Get-PrContextArtifactExistence { $true }
            Mock Resolve-PrAuthorWorktreeTarget {
                [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = (Get-Location).Path; ReasonCode = $null; Detail = 'session root' }
            }
            Mock Invoke-OrchestratorStatePreflight { @{ HasErrors = $false; ErrorText = '' } }
            Mock Get-PrAuthorReceiptContent { $null }
            Mock Get-PrAuthorBodyFileRoot { '/session' }
        }

        It '<Id> reaches receipt verification for <Command>' -Tag 'Issue824', 'R-733-715' -ForEach $script:ReceiptRows {
            $decision = Invoke-PrAuthorRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_AUTHOR_RECEIPT_MISSING:*'
        }

        It '<Id> denies the non-canonical body file in <Command>' -Tag 'Issue824' -ForEach $script:NonCanonicalRows {
            $decision = Invoke-PrAuthorRow -Command $Command
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL:*'
        }

        It 'PA-22 reads the body flags of an unmodeled-option create from its raw text' -Tag 'Issue824' {
            Mock Get-PrContextArtifactExistence { $false }

            $withBodyFile = Invoke-PrAuthorRow -Command 'gh --unmodeled pr create --body-file artifacts/pr_body_5.md'
            $withoutBody = Invoke-PrAuthorRow -Command 'gh --unmodeled pr create'

            $withBodyFile.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_CONTEXT_MISSING:*'
            $withoutBody.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_AUTHOR_SKILL_BLOCKED:*'
        }

        It 'PA-24 treats a create with no readable body-file value as non-canonical' -Tag 'Issue824' {
            $command = 'gh pr create --head bug/x-5'

            $value = Get-PrAuthorBodyFileValue -CommandText $command
            $reason = Test-PrAuthorReceiptVerification -CommandText $command -CheckpointPath 'unused-checkpoint-path'

            $value | Should -BeNullOrEmpty
            $reason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL:*'
        }
    }

    Context 'inline-body and no-body pull requests' {
        It '<Id> denies <Command> with PR_AUTHOR_SKILL_BLOCKED' -Tag 'Issue824' -ForEach $script:SkillBlockedRows {
            Get-PrAuthorBypassReason -CommandText $Command -ContextExists $true | Should -BeLike 'PR_AUTHOR_SKILL_BLOCKED:*'
        }

        It 'PA-23 reads an inline body from the raw text of an unmodeled-option create' -Tag 'Issue824' {
            $reason = Get-PrAuthorBypassReason -CommandText 'gh --unmodeled pr create --body x' -ContextExists $true

            $reason | Should -BeLike 'PR_AUTHOR_SKILL_BLOCKED:*'
            $reason | Should -Match 'must use .--body-file. with a file' -Because 'the raw-text fallback classifies --body as an inline body'
        }

        It 'PA-20 denies the G1 command when substring presence is reinstated' -Tag 'Issue824', 'NegativeControl' {
            $delivered = Get-PrAuthorBypassReason -CommandText $script:G1 -ContextExists $true
            Mock Test-CommandLineWordPresent { $RawText.IndexOf($Word, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 }

            $mocked = Get-PrAuthorBypassReason -CommandText $script:G1 -ContextExists $true

            $delivered | Should -BeNullOrEmpty
            $mocked | Should -BeLike 'PR_AUTHOR_SKILL_BLOCKED:*' -Because 'substring presence finds gh inside high and pr inside priority'
        }
    }

    Context 'body-file root seam' {
        It 'PA-21 returns the current location as the body-file root' -Tag 'Issue824' {
            Get-PrAuthorBodyFileRoot | Should -Be (Get-Location).Path
        }
    }
}
