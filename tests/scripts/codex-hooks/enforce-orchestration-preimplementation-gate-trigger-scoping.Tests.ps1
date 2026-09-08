#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for the Codex preimplementation gate (issue #545).

.DESCRIPTION
    The Codex-side sibling of
    tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1.
    The scenario set is identical; the idiom differs.

    Codex decision-entry idiom: the Codex copy of
    `Invoke-OrchestrationPreimplementationGateDecision` accepts the MAPPED tool_input
    JSON directly (for example `{"command":"..."}`), not the outer PreToolUse envelope
    the Claude copy consumes.

    This file is NEW rather than an extension of
    `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, which is at 494
    of its 500 permitted lines and can absorb only the single-line
    `$script:SharedModuleNames` append.

    Case groups, all driven against an explicitly NOT-ready checkpoint:

      1. Over-match allow cases (5).
      2. Under-match deny cases (6).
      3. The non-classifying stop case (1).
      4. Wrapper deny pins (7).
      5. apply_patch marker-leg assertions (4), unique to this side.

    Group 5 exists because the Codex copy carries two `apply_patch` marker legs that
    the Claude copy does not: `Test-ImplementationCommand` scans for
    `*** Add|Update|Delete File:` and `*** Move to:` markers BEFORE it reaches the
    pattern loop. Those legs sit upstream of every change issue #545 makes, so they
    must be unaffected. Asserting them here is what makes "unaffected" a measured
    claim rather than an assumption.

    The normative contract is the D2 behaviour contract and the D3 fail-closed table
    in
    docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md.

    Determinism: every decision is driven through the pure seam with a literal
    checkpoint string. No disk I/O, no child process, no live executable, and no
    temporary file.
#>

Describe 'Codex enforce-orchestration-preimplementation-gate trigger scoping (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
        . $script:UnderTest

        function ConvertTo-CodexTriggerScopingToolInput {
            <#
                Builds the MAPPED tool_input JSON the Codex decision seam consumes.
                The command text is carried verbatim so a fixture can exercise
                quoting, chaining, heredocs, and redirection exactly as the shell
                would present them.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{ command = $Command } | ConvertTo-Json -Compress -Depth 5)
        }

        function ConvertTo-CodexTriggerScopingNotReadyCheckpointRaw {
            <#
                An explicitly NOT-ready checkpoint, so any allow decision must come
                from classification alone.
            #>
            param()

            return @{
                'issue-num'      = ''
                'feature-folder' = ''
                route_id         = ''
                lifecycle_ready  = $false
            } | ConvertTo-Json -Compress
        }

        function Get-CodexTriggerScopingDecisionForCommand {
            <#
                Single act step for every decision case in this file.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-CodexTriggerScopingToolInput -Command $Command) `
                -CheckpointRaw (ConvertTo-CodexTriggerScopingNotReadyCheckpointRaw)
        }
    }

    Context 'over-match allow cases - a mention is not an invocation' {
        It 'allows a quoted mention of the staging invocation inside an echo argument' {
            $command = 'echo "run git add scripts/powershell/Sample.ps1 after the checkpoint is ready"'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a quoted mention in a non-wrapper segment is data, not execution'
        }

        It 'allows a heredoc body that quotes the staging invocation in prose' {
            $command = @'
cat <<'NOTE' > docs/features/active/sample/notes.md
Run git add docs/features/active/sample/spec.md once the scaffold lands.
NOTE
'@

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a non-wrapper heredoc body is consumed as data and never executes'
        }

        It 'allows a heredoc whose JSON body names a governed tool as a receipt value' {
            $command = @'
cat > artifacts/orchestration/orchestrator-state.json <<'JSON'
{
  "route_id": "large",
  "qa_gates": ["pytest", "black", "ruff"]
}
JSON
'@

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a JSON value naming a tool is a receipt value, not an invocation'
        }

        It 'allows prose containing the English word black' {
            $command = 'echo "the background is black and the text is white" >> docs/features/active/sample/notes.md'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a bare tool name inside a quoted span is an English word here, not a command'
        }

        It 'allows a cross-segment line whose npm segment and lint mention are in different segments' {
            $command = 'npm --version && echo lint'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'per-segment evaluation ends the cross-segment bridge and nothing governed executes'
        }
    }

    Context 'under-match deny cases - the latent bypass' {
        It 'denies a relocating git add carrying a directory global option' {
            $command = 'git -C ../other-worktree add .'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs -C and finds add as the subcommand'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a relocating git commit carrying a git-dir global option' {
            $command = 'git --git-dir=../other/.git commit -m wip'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs --git-dir and finds commit as the subcommand'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a relocating git add carrying a work-tree global option' {
            $command = 'git --work-tree=../other add .'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs --work-tree and finds add as the subcommand'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies an unmodeled dash-leading token between git and its subcommand' {
            $command = 'git --future-unmodeled-option add .'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'an unmodeled dash-leading token classifies fail-closed'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies the subshell spelling of a staging command' {
            $command = '(git add .)'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a subshell opener is a segment delimiter, so git leads its own segment'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies the command-substitution spelling of a staging command' {
            $command = '$(git add .)'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a substitution opener is a segment delimiter, so git leads its own segment'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'the non-classifying stop case' {
        It 'does not classify git log --grep add as a staging command' {
            $command = 'git log --grep add'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'the scan stops at log, so add is never read as the subcommand'
        }
    }

    Context 'wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test' {
        It 'wrapper deny pin 1: denies a staging command relocated through xargs' {
            $command = 'echo scripts/powershell/Sample.ps1 | xargs git add'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the xargs segment is wrapper-led and scans raw'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 2: denies a staging command nested inside a bash -c argument' {
            $command = "bash -c 'git add .'"

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a wrapper argument is a nested command line and stays visible'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 3: denies a staging command nested inside an sh -c argument' {
            $command = 'sh -c "git add ."'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a wrapper argument is a nested command line and stays visible'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 4: denies a staging command behind the env transparent wrapper' {
            $command = 'env git add .'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier skips transparent wrappers'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper' {
            $command = 'pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/codex-hooks"'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'pwsh is a member of the wrapper carve-out set'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 6: denies a heredoc body piped into bash' {
            $command = @'
bash <<'EOF'
git add .
EOF
'@

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a heredoc feeding a wrapper is executed, unlike one feeding a file'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 7: denies a live substitution inside a double-quoted span' {
            $command = 'echo "$(git add .)"'

            $decision = Get-CodexTriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a live substitution inside double quotes forces a raw scan'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'apply_patch marker legs are unaffected (Codex-only)' {
        It 'still classifies an apply_patch add of a production script' {
            # The marker legs sit upstream of the pattern loop and are untouched by
            # issue #545. This case classifies through the marker leg, not through
            # any trigger pattern.
            $command = @'
*** Begin Patch
*** Add File: scripts/powershell/Sample.ps1
+Write-Output 'sample'
*** End Patch
'@

            Test-ImplementationCommand -Command $command |
                Should -BeTrue -Because 'an apply_patch add of a production path is an implementation command'
        }

        It 'still declines to classify an apply_patch add of feature documentation' {
            $command = @'
*** Begin Patch
*** Add File: docs/features/active/sample/spec.md
+# Spec
*** End Patch
'@

            Test-ImplementationCommand -Command $command |
                Should -BeFalse -Because 'a documentation path is not an implementation path'
        }

        It 'still classifies an apply_patch rename onto a production script' {
            $command = @'
*** Begin Patch
*** Update File: docs/notes.md
*** Move to: scripts/powershell/Sample.ps1
*** End Patch
'@

            Test-ImplementationCommand -Command $command |
                Should -BeTrue -Because 'a Move to marker naming a production path classifies'
        }

        It 'still declines to classify an apply_patch update of feature documentation' {
            $command = @'
*** Begin Patch
*** Update File: docs/features/active/sample/spec.md
+more text
*** End Patch
'@

            Test-ImplementationCommand -Command $command |
                Should -BeFalse -Because 'a documentation path is not an implementation path'
        }
    }
}
