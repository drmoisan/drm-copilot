#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Trigger-scoping regression cases for the Claude preimplementation gate (issue #545).

.DESCRIPTION
    Issue #545 changes WHAT TEXT the five byte-unchanged trigger patterns are
    evaluated against, and adds a structural relocation classifier. This file
    pins both directions of the resulting behaviour change plus the wrapper deny
    pins that keep the change fail-closed.

    Case groups, all driven against an explicitly NOT-ready checkpoint so that any
    allow decision must come from classification rather than from readiness:

      1. Over-match allow cases (5). Text that merely MENTIONS a governed token in
         a non-wrapper segment. The shell never executes a governed command on
         these lines, so they must allow. They deny today.
      2. Under-match deny cases (6). Genuine governed commands whose subcommand is
         separated from the command name, or whose command name is preceded by a
         subshell or substitution opener. They allow by non-match today, which is
         the latent bypass.
      3. The non-classifying stop case (1). `git log --grep add` must NOT classify,
         because an arbitrary later token must not be treated as the subcommand.
         This case passes today and must keep passing.
      4. Wrapper deny pins (7). The forms issue #539 D8 cited as the fail-open
         risk. Every one must deny AFTER the change. Not all of them deny today:
         the three whose command name is preceded by a quote or a parenthesis
         (`bash -c`, `sh -c`, and live substitution) fail the `(^|\s)` boundary of
         the current pattern and are already ungated. They are written as deny
         assertions because the D3 fail-closed table states deny as the post-fix
         decision for all seven rows; the fail-before artifact records which of
         them passed and which failed against the unfixed hook.

    The normative contract is the D2 behaviour contract and the D3 fail-closed
    table in
    docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md.

    Determinism: every decision is driven through the pure seam
    `Invoke-OrchestrationPreimplementationGateDecision` with a literal checkpoint
    string. No disk I/O, no child process, no live executable, and no temporary
    file.
#>

Describe 'enforce-orchestration-preimplementation-gate.ps1 trigger scoping (issue #545)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest

        function ConvertTo-TriggerScopingCommandPayload {
            <#
                Builds the Bash PreToolUse envelope the Claude gate reads. The command
                text is carried verbatim so a fixture can exercise quoting, chaining,
                heredocs, and redirection exactly as the shell would present them.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return (@{
                    tool_name  = 'Bash'
                    tool_input = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function ConvertTo-TriggerScopingNotReadyCheckpointRaw {
            <#
                An explicitly NOT-ready checkpoint: route id empty and lifecycle
                readiness false, so Test-OrchestrationReady returns false and any
                allow decision must come from classification alone.
            #>
            param()

            return @{
                'issue-num'      = ''
                'feature-folder' = ''
                route_id         = ''
                lifecycle_ready  = $false
            } | ConvertTo-Json -Compress
        }

        function Get-TriggerScopingDecisionForCommand {
            <#
                Single act step for every case in this file.
            #>
            param([Parameter(Mandatory)][AllowEmptyString()] [string] $Command)

            return Invoke-OrchestrationPreimplementationGateDecision `
                -ToolInputRaw (ConvertTo-TriggerScopingCommandPayload -Command $Command) `
                -CheckpointRaw (ConvertTo-TriggerScopingNotReadyCheckpointRaw)
        }
    }

    Context 'over-match allow cases - a mention is not an invocation' {
        It 'allows a quoted mention of the staging invocation inside an echo argument' {
            # A quoted string in a non-wrapper segment is an argument, so a governed
            # token inside it is data. Nothing on this line stages anything.
            $command = 'echo "run git add scripts/powershell/Sample.ps1 after the checkpoint is ready"'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a quoted mention in a non-wrapper segment is data, not execution'
        }

        It 'allows a heredoc body that quotes the staging invocation in prose' {
            # The primary reported friction: writing a document that necessarily
            # quotes the token it describes. The heredoc feeds a file, not a shell.
            $command = @'
cat <<'NOTE' > docs/features/active/sample/notes.md
Run git add docs/features/active/sample/spec.md once the scaffold lands.
NOTE
'@

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a non-wrapper heredoc body is consumed as data and never executes'
        }

        It 'allows a heredoc whose JSON body names a governed tool as a receipt value' {
            # The checkpoint-bootstrap case: the schema requires these values, so
            # the write and the gate are jointly unsatisfiable while the body is
            # scanned as command text.
            $command = @'
cat > artifacts/orchestration/orchestrator-state.json <<'JSON'
{
  "route_id": "large",
  "qa_gates": ["pytest", "black", "ruff"]
}
JSON
'@

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a JSON value naming a tool is a receipt value, not an invocation'
        }

        It 'allows prose containing the English word black' {
            # Pattern 2 carries bare tool names, so it matches an ordinary English
            # word. No formatter runs on this line.
            $command = 'echo "the background is black and the text is white" >> docs/features/active/sample/notes.md'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'a bare tool name inside a quoted span is an English word here, not a command'
        }

        It 'allows a cross-segment line whose npm segment and lint mention are in different segments' {
            # Pattern 3 uses `.*`, which bridges segment boundaries, so a line
            # containing npm anywhere and lint anywhere later classifies today.
            # Per-segment evaluation ends the bridge. No governed command executes.
            $command = 'npm --version && echo lint'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'per-segment evaluation ends the cross-segment bridge and nothing governed executes'
        }
    }

    Context 'under-match deny cases - the latent bypass' {
        It 'denies a relocating git add carrying a directory global option' {
            # The canonical latent bypass recorded in issue.md. The -C option
            # breaks adjacency, so the trigger never matches and the line passes
            # ungated today. Issue #539 D4 row 14 records relocating spellings as
            # NEVER EXEMPT, so the correct outcome is a deny.
            $command = 'git -C ../other-worktree add .'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs -C and finds add as the subcommand'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a relocating git commit carrying a git-dir global option' {
            $command = 'git --git-dir=../other/.git commit -m wip'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs --git-dir and finds commit as the subcommand'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies a relocating git add carrying a work-tree global option' {
            $command = 'git --work-tree=../other add .'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier absorbs --work-tree and finds add as the subcommand'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies an unmodeled dash-leading token between git and its subcommand' {
            # Fail-closed rule: an unmodeled dash-leading token classifies, because
            # over-classification only forces a checkpoint check while
            # under-classification is a bypass.
            $command = 'git --future-unmodeled-option add .'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'an unmodeled dash-leading token classifies fail-closed'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies the subshell spelling of a staging command' {
            # The character preceding git is an opening parenthesis rather than
            # whitespace, so the (^|\s) boundary is not satisfied and the line
            # passes by non-match today. Treating the opener as a segment
            # delimiter closes it.
            $command = '(git add .)'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a subshell opener is a segment delimiter, so git leads its own segment'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'denies the command-substitution spelling of a staging command' {
            $command = '$(git add .)'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a substitution opener is a segment delimiter, so git leads its own segment'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }

    Context 'the non-classifying stop case' {
        It 'does not classify git log --grep add as a staging command' {
            # A non-dash token that is not the expected subcommand terminates the
            # scan. Without that rule an arbitrary later token would classify.
            # This case passes today and must keep passing.
            $command = 'git log --grep add'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'allow' -Because 'the scan stops at log, so add is never read as the subcommand'
        }
    }

    Context 'wrapper deny pins - the issue #539 D8 fail-open risk, pinned by test' {
        It 'wrapper deny pin 1: denies a staging command relocated through xargs' {
            $command = 'echo scripts/powershell/Sample.ps1 | xargs git add'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the xargs segment is wrapper-led and scans raw'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 2: denies a staging command nested inside a bash -c argument' {
            $command = "bash -c 'git add .'"

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a wrapper argument is a nested command line and stays visible'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 3: denies a staging command nested inside an sh -c argument' {
            $command = 'sh -c "git add ."'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a wrapper argument is a nested command line and stays visible'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 4: denies a staging command behind the env transparent wrapper' {
            $command = 'env git add .'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'the structural classifier skips transparent wrappers'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper' {
            # This is the same assertion as AT-6 and as the existing pin at
            # enforce-orchestration-preimplementation-gate.Tests.ps1 line 140. It is
            # repeated here so a fail-open regression is visible in this file too.
            $command = 'pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'pwsh is a member of the wrapper carve-out set'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 6: denies a heredoc body piped into bash' {
            # The one deliberate direction reversal against masking: this heredoc
            # body IS executed, because bash is in the wrapper carve-out set, so
            # the segment scans raw and the body stays visible.
            $command = @'
bash <<'EOF'
git add .
EOF
'@

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a heredoc feeding a wrapper is executed, unlike one feeding a file'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }

        It 'wrapper deny pin 7: denies a live substitution inside a double-quoted span' {
            # Text whose execution content cannot be resolved statically keeps
            # today's whole-text behaviour, so this segment scans raw.
            $command = 'echo "$(git add .)"'

            $decision = Get-TriggerScopingDecisionForCommand -Command $command

            $decision.hookSpecificOutput.permissionDecision |
                Should -Be 'deny' -Because 'a live substitution inside double quotes forces a raw scan'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
        }
    }
}
