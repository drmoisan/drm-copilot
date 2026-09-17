#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-resolution matrix for the prd-feature gate (issue #672).
.DESCRIPTION
    Placement decision. These cases live in a third companion suite rather than in
    either existing suite because both are close enough to the 500-line cap in
    .claude/rules/general-code-change.md to leave no room for the matrix plus its
    regression guards: enforce-prd-feature-before-planner.Tests.ps1 measured 431
    content lines and enforce-prd-feature-before-planner.FolderResolution.Tests.ps1
    measured 419 before the Phase 1 BeforeAll amendment, and 436 and 424 after it.
    The same convention is used by
    tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1.

    Determinism statement. No case in this suite creates a temporary file or a
    temporary directory, no case changes the process working directory, and no
    absolute path here is derived from the runtime environment, the current
    directory, the script file location, or a source-control query. Every absolute
    path is a bare string literal declared below. The current directory is modelled
    as data: it is carried on the SessionRoot member of an injected target result,
    never read from the process. Rows that need more than one modelled directory
    are bound with -ForEach over a discovery-time array, because a value assigned
    inside an It body is not visible from Pester's discovery phase.
#>

# --- Synthetic worktree roots ----------------------------------------------------
# Bare string literals. Neither root exists on disk, and no assertion here depends
# on whether it does: every filesystem seam is mocked and keyed on the fully
# composed path.
$CoordinatingSessionRoot = '/synthetic-worktrees/coordinating-session'
$ItemWorktreeRoot = '/synthetic-worktrees/item-worktree'

# The feature folder every row resolves to, and a second folder used only to build
# a two-candidate tie.
$TargetFeatureFolder = 'docs/features/active/2026-09-13-synthetic-target-672'
$OtherFeatureFolder = 'docs/features/active/2026-09-13-synthetic-other-999'

# The two modelled current directories for the absolute-path row. One row models a
# coordinating session running in a different worktree from the target; the other
# models the item's own worktree, where the resolved root and the session root
# coincide and no prefix is applied.
$AbsolutePathCases = @(
    @{
        Case        = 'coordinating session cwd, target in another worktree'
        ModelledCwd = '/synthetic-worktrees/coordinating-session'
        TargetRoot  = '/synthetic-worktrees/item-worktree'
        Status      = 'OtherWorktree'
        ProbeFolder = '/synthetic-worktrees/item-worktree/docs/features/active/2026-09-13-synthetic-target-672'
    }
    @{
        Case        = 'item worktree cwd, target is the session root'
        ModelledCwd = '/synthetic-worktrees/item-worktree'
        TargetRoot  = '/synthetic-worktrees/item-worktree'
        Status      = 'SessionRoot'
        ProbeFolder = 'docs/features/active/2026-09-13-synthetic-target-672'
    }
)

# The four work modes, each exercised against the same resolved target root. The
# document lists below are the fully composed paths the gate must probe, so a row
# cannot pass on a probe that answers true for a path the gate never composed.
$WorkModeCases = @(
    @{
        Case           = 'full-feature requires spec.md and user-story.md'
        Marker         = 'full-feature'
        Present        = @(
            '/synthetic-worktrees/item-worktree/docs/features/active/2026-09-13-synthetic-target-672/spec.md',
            '/synthetic-worktrees/item-worktree/docs/features/active/2026-09-13-synthetic-target-672/user-story.md'
        )
        ExpectedProbes = 2
    }
    @{
        Case           = 'full-bug requires spec.md alone'
        Marker         = 'full-bug'
        Present        = @('/synthetic-worktrees/item-worktree/docs/features/active/2026-09-13-synthetic-target-672/spec.md')
        ExpectedProbes = 1
    }
    @{
        Case           = 'minor-audit requires neither'
        Marker         = 'minor-audit'
        Present        = @()
        ExpectedProbes = 0
    }
    @{
        Case           = 'the legacy full marker normalises to full-feature'
        Marker         = 'full'
        Present        = @(
            '/synthetic-worktrees/item-worktree/docs/features/active/2026-09-13-synthetic-target-672/spec.md',
            '/synthetic-worktrees/item-worktree/docs/features/active/2026-09-13-synthetic-target-672/user-story.md'
        )
        ExpectedProbes = 2
    }
)

Describe 'enforce-prd-feature-before-planner.ps1 target resolution' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
        $script:Helpers = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1").Path
        . $script:UnderTest
        . $script:Helpers

        # The modelled target results below are built with F1's own constructor, so the
        # injected shape is the shipped one rather than a local imitation. Both modules
        # are imported here explicitly for the same reason the two hook files are
        # dot-sourced explicitly: a later change to the hook's own import line cannot
        # then redirect these assertions.
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeResolution.psm1").Path -Force
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1").Path -Force

        # Run-time copies of the discovery-time literals above. Both are bare string
        # literals here as well; neither is derived from the environment.
        $script:CoordinatingSessionRoot = '/synthetic-worktrees/coordinating-session'
        $script:ItemWorktreeRoot = '/synthetic-worktrees/item-worktree'
        $script:TargetFeatureFolder = 'docs/features/active/2026-09-13-synthetic-target-672'
        $script:OtherFeatureFolder = 'docs/features/active/2026-09-13-synthetic-other-999'
        $script:ComposedTargetFolder = '/synthetic-worktrees/item-worktree/docs/features/active/2026-09-13-synthetic-target-672'
        $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode

        function New-PlannerPayload {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory payload factory in a test file; it changes no system state.')]
            param([string] $Prompt)

            return (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = $Prompt }
                } | ConvertTo-Json -Depth 6 -Compress)
        }

        function New-ModelledTarget {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory over the shipped issue #669 constructor; it changes no system state.')]
            param(
                [string] $Status,
                [string] $SessionRoot,
                [string] $WorktreeRoot,
                [string] $SignalValue
            )

            if ($Status -eq 'Ambiguous') {
                return (New-WorktreeResolutionTargetResult -Status 'Ambiguous' -SessionRoot $SessionRoot `
                        -Signal 'FeatureFolderPath' -SignalValue $SignalValue -Candidate @() `
                        -Detail 'modelled ambiguity: the call names more than one worktree')
            }

            return (New-WorktreeResolutionTargetResult -Status $Status -SessionRoot $SessionRoot `
                    -WorktreeRoot $WorktreeRoot -Signal 'FeatureFolderPath' -SignalValue $SignalValue `
                    -Candidate @($WorktreeRoot) -Detail "modelled target '$WorktreeRoot'")
        }
    }

    Context 'cross-file mock resolution smoke' {
        It 'observes a test-scope mock across the dot-source boundary' {
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/2026-01-01-checkpoint-only-000' }

            $prompt = 'Plan the work in docs/features/active/2026-09-13-smoke-1 now.'
            Find-PrdFeatureFolderFromPrompt -Prompt $prompt |
                Should -Be 'docs/features/active/2026-09-13-smoke-1'

            Should -Invoke -CommandName Get-PrdFeatureCheckpointFolder -Times 0 -Exactly
        }
    }

    Context 'call-target derivation seam' {
        # Direct cases for the two parent-side functions the decision path calls. The
        # derivation itself is mocked, so no case here reads the filesystem.

        It 'treats a call with no derived target as resolving at the session root' {
            Test-PrdFeatureSessionRootTarget -Target $null | Should -BeTrue
        }

        It 'treats a NoTarget and a SessionRoot result as resolving at the session root' {
            Test-PrdFeatureSessionRootTarget -Target ([pscustomobject]@{ Status = 'NoTarget' }) | Should -BeTrue
            Test-PrdFeatureSessionRootTarget -Target ([pscustomobject]@{ Status = 'SessionRoot' }) | Should -BeTrue
        }

        It 'treats another worktree as not the session root' {
            Test-PrdFeatureSessionRootTarget -Target ([pscustomobject]@{ Status = 'OtherWorktree' }) | Should -BeFalse
        }

        It 'derives nothing from a call whose text is empty' {
            Mock -CommandName Resolve-WorktreeCallTarget -MockWith { [pscustomobject]@{ Status = 'NoTarget' } }

            Get-PrdFeatureCallTarget -Envelope $null -ToolInput ([pscustomobject]@{ subagent_type = 'atomic-planner' }) |
                Should -BeNullOrEmpty
            Should -Invoke -CommandName Resolve-WorktreeCallTarget -Times 0 -Exactly
        }

        It 'derives nothing from a call that cites no absolutely-placed token' {
            Mock -CommandName Resolve-WorktreeCallTarget -MockWith { [pscustomobject]@{ Status = 'NoTarget' } }

            $toolInput = [pscustomobject]@{ prompt = "Plan $($script:TargetFeatureFolder) now."; description = 'plan it' }

            Get-PrdFeatureCallTarget -Envelope $null -ToolInput $toolInput | Should -BeNullOrEmpty
            Should -Invoke -CommandName Resolve-WorktreeCallTarget -Times 0 -Exactly
        }

        It 'supplies the session root from the envelope cwd when the runtime sets one' {
            Mock -CommandName Resolve-WorktreeCallTarget -MockWith {
                [pscustomobject]@{ Status = 'OtherWorktree'; SuppliedSessionRoot = $SessionRoot; SuppliedText = $Text }
            }

            $toolInput = [pscustomobject]@{ prompt = "Plan $($script:ComposedTargetFolder) now." }
            $envelope = [pscustomobject]@{ cwd = $script:CoordinatingSessionRoot; tool_name = 'Agent' }

            $result = Get-PrdFeatureCallTarget -Envelope $envelope -ToolInput $toolInput
            $result.SuppliedSessionRoot | Should -Be $script:CoordinatingSessionRoot
            $result.SuppliedText | Should -BeLike "*$($script:ComposedTargetFolder)*"
            Should -Invoke -CommandName Resolve-WorktreeCallTarget -Times 1 -Exactly
        }

        It 'omits the session root when the envelope carries no cwd field' {
            Mock -CommandName Resolve-WorktreeCallTarget -MockWith {
                [pscustomobject]@{ Status = 'OtherWorktree'; SuppliedSessionRoot = $SessionRoot }
            }

            $toolInput = [pscustomobject]@{ description = "Plan $($script:ComposedTargetFolder) now." }
            $envelope = [pscustomobject]@{ tool_name = 'Agent' }

            $result = Get-PrdFeatureCallTarget -Envelope $envelope -ToolInput $toolInput
            $result.SuppliedSessionRoot | Should -BeNullOrEmpty
            Should -Invoke -CommandName Resolve-WorktreeCallTarget -Times 1 -Exactly
        }
    }

    Context 'target resolution matrix' {
        It 'allows when the target root holds the required document' {
            # State A with a differing root: the document exists only under the target
            # worktree, and the session root is a different worktree.
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
                if ($FeatureFolder -eq $script:ComposedTargetFolder) { "- Work Mode: full-bug`n" } else { $null }
            }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                $Path -eq "$($script:ComposedTargetFolder)/spec.md"
            }

            $target = New-ModelledTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot `
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue $script:ComposedTargetFolder
            $payload = New-PlannerPayload -Prompt "Plan $($script:ComposedTargetFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when the modelled cwd is the item worktree' {
            # State B: no injected target and no derivation input, so composition emits
            # the bare repo-relative spelling. The modelled session root is the item
            # worktree itself, so the resolved root and the session root coincide and no
            # prefix is applied. This row is a retained regression guard: it passes
            # against the current hook as well as the fixed one.
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
                if ($FeatureFolder -eq $script:TargetFeatureFolder) { "- Work Mode: full-bug`n" } else { $null }
            }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                $Path -eq "$($script:TargetFeatureFolder)/spec.md"
            }

            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an absolute path to the target feature folder' -ForEach $AbsolutePathCases {
            # Two rows, one per modelled cwd. The required document is present under the
            # containing worktree on both rows; only the composed probe path differs.
            $probeFolder = $ProbeFolder
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
                if ($FeatureFolder -eq $probeFolder) { "- Work Mode: full-bug`n" } else { $null }
            }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                $Path -eq "$probeFolder/spec.md"
            }

            $target = New-ModelledTarget -Status $Status -SessionRoot $ModelledCwd `
                -WorktreeRoot $TargetRoot -SignalValue "$TargetRoot/$($script:TargetFeatureFolder)"
            $payload = New-PlannerPayload -Prompt "Plan $TargetRoot/$($script:TargetFeatureFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies with the missing-document reason when the document is absent under the target root' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
                if ($FeatureFolder -eq $script:ComposedTargetFolder) { "- Work Mode: full-bug`n" } else { $null }
            }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                $Path -eq "$($script:ComposedTargetFolder)/never-required.md"
            }

            $target = New-ModelledTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot `
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue $script:ComposedTargetFolder
            $payload = New-PlannerPayload -Prompt "Plan $($script:ComposedTargetFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'PRD_FEATURE_BLOCKED:*'
            $reason | Should -BeLike "*resolved feature folder '$($script:ComposedTargetFolder)' is missing: spec.md*"
            $reason | Should -BeLike '*work mode: full-bug*'
            $reason | Should -BeLike '*invoke the prd-feature subagent*'
        }

        It 'denies with the ambiguity code when the target cannot be resolved' {
            $target = New-ModelledTarget -Status 'Ambiguous' -SessionRoot $script:CoordinatingSessionRoot `
                -SignalValue $script:TargetFeatureFolder
            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'PRD_FEATURE_BLOCKED:*'
            $reason | Should -BeLike "*$($script:AmbiguityCode)*"
        }

        It 'emits an ambiguity code distinct from the missing-document and marker reasons' {
            $target = New-ModelledTarget -Status 'Ambiguous' -SessionRoot $script:CoordinatingSessionRoot `
                -SignalValue $script:TargetFeatureFolder
            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) now."

            $reason = (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target).hookSpecificOutput.permissionDecisionReason

            # Distinct from the missing-document reason and from the indeterminate
            # work-mode reason, and present exactly once as a single literal.
            $reason | Should -Not -BeLike '*is missing:*'
            $reason | Should -Not -BeLike '*work mode could not be determined*'
            $script:AmbiguityCode | Should -Not -Be 'is missing'
            ([regex]::Matches($reason, [regex]::Escape($script:AmbiguityCode))).Count | Should -Be 1
        }

        It 'runs no existence probe on the ambiguity branch' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq 'never-matched' }

            $target = New-ModelledTarget -Status 'Ambiguous' -SessionRoot $script:CoordinatingSessionRoot `
                -SignalValue $script:TargetFeatureFolder
            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) now."

            $null = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target

            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly
        }

        It 'denies rather than validating against a sibling session checkpoint' {
            # A prompt naming no feature folder, issued from a session whose checkpoint
            # describes a different item, with the call's own target in another
            # worktree. The sibling item's checkpoint is the only state present, and it
            # must not be allowed to stand in for the call's own target.
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $script:OtherFeatureFolder }
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:OtherFeatureFolder)/spec.md" }

            $target = New-ModelledTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot `
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue "$($script:ItemWorktreeRoot)/some/file.ps1"
            $payload = New-PlannerPayload -Prompt 'Continue planning the work already in flight.'

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*$($script:AmbiguityCode)*"
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -BeLike "*$($script:OtherFeatureFolder)*"
            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly
        }

        It 'denies rather than selecting the earliest candidate on an unresolved tie' {
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:TargetFeatureFolder)/spec.md" }

            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) and cross-reference $($script:OtherFeatureFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*$($script:AmbiguityCode)*"
        }

        It 'probes once on a full-bug allow row' {
            # The positive half of the zero-invocation guard: an implementation that
            # returns allow without probing fails this row.
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
                if ($FeatureFolder -eq $script:ComposedTargetFolder) { "- Work Mode: full-bug`n" } else { $null }
            }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                $Path -eq "$($script:ComposedTargetFolder)/spec.md"
            }

            $target = New-ModelledTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot `
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue $script:ComposedTargetFolder
            $payload = New-PlannerPayload -Prompt "Plan $($script:ComposedTargetFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 1 -Exactly
        }

        It 'probes twice on a full-feature allow row' {
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
                if ($FeatureFolder -eq $script:ComposedTargetFolder) { "- Work Mode: full-feature`n" } else { $null }
            }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                $Path -in @(
                    "$($script:ComposedTargetFolder)/spec.md",
                    "$($script:ComposedTargetFolder)/user-story.md"
                )
            }

            $target = New-ModelledTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot `
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue $script:ComposedTargetFolder
            $payload = New-PlannerPayload -Prompt "Plan $($script:ComposedTargetFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 2 -Exactly
        }

        It 'resolves the required document set for each work mode' -ForEach $WorkModeCases {
            # Every row is exercised against the same resolved target root and differs
            # only in the marker the target folder carries and the documents present
            # under it.
            $marker = $Marker
            $present = $Present
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith {
                if ($FeatureFolder -eq $script:ComposedTargetFolder) { "- Work Mode: $marker`n" } else { $null }
            }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                $Path -in $present
            }

            $target = New-ModelledTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot `
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue $script:ComposedTargetFolder
            $payload = New-PlannerPayload -Prompt "Plan $($script:ComposedTargetFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times $ExpectedProbes -Exactly
        }

        It 'denies with the ambiguity reason when the folder is absent from the target root' {
            # State A with a differing root, and the resolved folder does not exist under
            # that root: the gate must not fall back to the marker-is-broken reason, which
            # would describe a folder probed at the wrong root.
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq 'never-matched' }

            $target = New-ModelledTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot `
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue $script:ComposedTargetFolder
            $payload = New-PlannerPayload -Prompt "Plan $($script:ComposedTargetFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike "*$($script:AmbiguityCode)*"
            $reason | Should -Not -BeLike '*work mode could not be determined*'
        }
    }
}
