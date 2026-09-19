#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Target-resolution matrix for the prd-feature gate (issue #672).
.DESCRIPTION
    Placement decision. These cases live in a third companion suite rather than in
    either existing suite because both are close enough to the 500-line cap in
    .claude/rules/general-code-change.md to leave no room for the matrix plus its
    regression guards: both sibling suites sit within sixty lines of the cap, and their
    measured line counts are recorded in this feature's evidence ledger under the stem
    remediation-file-size-ledger. The same convention is used by
    tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1.

    Determinism statement. No case in this suite creates a temporary file or directory,
    no case changes the process working directory, and no absolute path here is derived
    from the runtime environment, the current directory, the script file location, or a
    source-control query. Every absolute path is a bare string literal declared below.
    The current directory is modelled as data, carried on the SessionRoot member of an
    injected target result and never read from the process. Rows needing more than one
    modelled directory bind with -ForEach over a discovery-time array, because a value
    assigned inside an It body is invisible to Pester's discovery phase. Issue #673
    leaves every one of those properties in place: the mocked seam is now the identity
    resolver, but it is still mocked.
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
        $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode

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
                        -Signal 'Branch' -SignalValue $SignalValue -Candidate @() `
                        -Detail 'modelled ambiguity: the call names more than one worktree')
            }

            return (New-WorktreeResolutionTargetResult -Status $Status -SessionRoot $SessionRoot `
                    -WorktreeRoot $WorktreeRoot -Signal 'Branch' -SignalValue $SignalValue `
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

    Context 'call-target resolution seam' {
        # Direct cases for the parent-side function the decision path calls; the
        # resolution is mocked, so no case here reads the filesystem.


        It 'resolves no target from a call whose text is empty' {
            Mock -CommandName Resolve-PrdFeatureWorktreeTarget -MockWith { [pscustomobject]@{ Status = 'NoTarget' } }

            Get-PrdFeatureCallTarget -ToolInput ([pscustomobject]@{ subagent_type = 'atomic-planner' }) |
                Should -BeNullOrEmpty
            Should -Invoke -CommandName Resolve-PrdFeatureWorktreeTarget -Times 0 -Exactly
        }

        It 'hands the assembled prompt and description text to the identity resolver' {
            Mock -CommandName Resolve-PrdFeatureWorktreeTarget -MockWith { [pscustomobject]@{ Status = 'NoTarget'; SuppliedText = $Text } }

            $toolInput = [pscustomobject]@{ prompt = "Plan $($script:TargetFeatureFolder) now."; description = 'plan it' }

            $result = Get-PrdFeatureCallTarget -ToolInput $toolInput
            $result.Status | Should -Be 'NoTarget'
            $result.SuppliedText | Should -BeLike "*$($script:TargetFeatureFolder)*"
            Should -Invoke -CommandName Resolve-PrdFeatureWorktreeTarget -Times 1 -Exactly
        }

        It 'hands a branch label to the identity resolver' {
            Mock -CommandName Resolve-PrdFeatureWorktreeTarget -MockWith { [pscustomobject]@{ Status = 'OtherWorktree'; SuppliedText = $Text } }

            $toolInput = [pscustomobject]@{ prompt = "Plan $($script:TargetFeatureFolder) now."; description = 'branch: feature/2026-09-13-x-672' }

            $result = Get-PrdFeatureCallTarget -ToolInput $toolInput
            $result.SuppliedText | Should -BeLike "*$($script:TargetFeatureFolder)*"
            $result.SuppliedText | Should -BeLike '*branch: feature/2026-09-13-x-672*'
            Should -Invoke -CommandName Resolve-PrdFeatureWorktreeTarget -Times 1 -Exactly
        }

        It 'supplies the process location as the session root and reads no envelope cwd' {
            # Neither assertion reads a location: mocking the seam to capture a
            # -SessionRoot would capture nothing, because the seam supplies it, and
            # comparing against a live read would derive a path from the current directory.
            # Structural: the resolver takes a SessionRoot, the assembler has no Envelope.
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:UnderTest, [ref] $null, [ref] $null)
            $calls = @($ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                        $args[0].GetCommandName() -eq 'Resolve-WorktreeItemTarget' }, $true))
            $calls.Count | Should -BeGreaterThan 0
            foreach ($call in $calls) {
                @($call.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst] -and
                        $_.ParameterName -eq 'SessionRoot' }).Count | Should -BeGreaterThan 0
            }
            $assembler = @($ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                        $args[0].Name -eq 'Get-PrdFeatureCallTarget' }, $true))[0]
            @($assembler.Body.ParamBlock.Parameters |
                    Where-Object { $_.Name.VariablePath.UserPath -eq 'Envelope' }) | Should -BeNullOrEmpty

            # Behavioural: the captured value is a rooted path. The mock has no -ModuleName
            # because the intercepted call sits in the dot-sourced seam; a module-scoped
            # mock would miss it and the real resolver would enumerate live worktrees.
            $script:CapturedSessionRoot = $null
            Mock -CommandName Resolve-WorktreeItemTarget -MockWith {
                param([string] $Text, [string] $SessionRoot)
                $script:CapturedSessionRoot = $SessionRoot
                return ([pscustomobject]@{ Status = 'NoTarget' })
            }

            $null = Get-PrdFeatureCallTarget -ToolInput ([pscustomobject]@{ prompt = 'Plan the work.' })

            $script:CapturedSessionRoot | Should -Not -BeNullOrEmpty
            [System.IO.Path]::IsPathRooted($script:CapturedSessionRoot) | Should -BeTrue
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
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue 'f5-fixture-own'
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
            Mock -CommandName Resolve-PrdFeatureWorktreeTarget -MockWith { New-WorktreeResolutionTargetResult -Status 'SessionRoot' -SessionRoot $script:ItemWorktreeRoot -WorktreeRoot $script:ItemWorktreeRoot -Signal 'Branch' -SignalValue 'f5-fixture-own' -Candidate @($script:ItemWorktreeRoot) -Detail 'modelled session-root target' }
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

        It 'allows a repo-relative citation placed in the item worktree' {
            Mock -CommandName Resolve-PrdFeatureWorktreeTarget -MockWith { New-WorktreeResolutionTargetResult -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot -WorktreeRoot $script:ItemWorktreeRoot -Signal 'Branch' -SignalValue 'f5-fixture-own' -Candidate @($script:ItemWorktreeRoot) -Detail 'modelled placement by identity' }
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { if ($FeatureFolder -eq $script:ComposedTargetFolder) { "- Work Mode: full-bug`n" } else { $null } }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:ComposedTargetFolder)/spec.md" }

            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 1 -Exactly
        }

        It 'denies with the no-target code when the identity places in no live worktree' {
            # No identity is the no-target state, not an ambiguity: nothing to choose between.
            Mock -CommandName Resolve-PrdFeatureWorktreeTarget -MockWith { New-WorktreeResolutionTargetResult -Status 'NoTarget' -SessionRoot $script:CoordinatingSessionRoot -Detail 'modelled identity placing in no live worktree' }
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { $null }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq 'never-matched' }

            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike "*$($script:NoTargetCode)*"
            $reason | Should -Not -BeLike '*work mode could not be determined*'
            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly
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
                -WorktreeRoot $TargetRoot -SignalValue 'f5-fixture-own'
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
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue 'f5-fixture-own'
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
                -SignalValue 'f5-fixture-own'
            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason = $decision.hookSpecificOutput.permissionDecisionReason
            $reason | Should -BeLike 'PRD_FEATURE_BLOCKED:*'
            $reason | Should -BeLike "*$($script:AmbiguityCode)*"
        }

        It 'emits an ambiguity code distinct from the missing-document and marker reasons' {
            $target = New-ModelledTarget -Status 'Ambiguous' -SessionRoot $script:CoordinatingSessionRoot `
                -SignalValue 'f5-fixture-own'
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
                -SignalValue 'f5-fixture-own'
            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) now."

            $null = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target

            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 0 -Exactly
        }

        It 'reads the checkpoint of the resolved worktree rather than the session root''s' {
            # A prompt naming no feature folder, with the target in another worktree. The
            # captured checkpoint path is asserted, not just the verdict. Before this
            # migration the same call denied rather than consulting any checkpoint.
            $script:CapturedCheckpointPath = $null
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith {
                param([string] $CheckpointPath)
                $script:CapturedCheckpointPath = $CheckpointPath
                return $script:TargetFeatureFolder
            }
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:ComposedTargetFolder)/spec.md" }

            $target = New-ModelledTarget -Status 'OtherWorktree' -SessionRoot $script:CoordinatingSessionRoot `
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue 'f5-fixture-own'
            $payload = New-PlannerPayload -Prompt 'Continue planning the work already in flight.'

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload -ResolvedTarget $target
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            $script:CapturedCheckpointPath | Should -BeLike "$($script:ItemWorktreeRoot)/*"
            Should -Invoke -CommandName Get-PrdFeatureFileExistence -Times 1 -Exactly
        }

        It 'denies rather than selecting the earliest candidate on an unresolved tie' {
            # The injected status must be resolved, not NoTarget: an unresolved identity
            # denies before the candidate scan, which would make the tie branch unreachable.
            Mock -CommandName Resolve-PrdFeatureWorktreeTarget -MockWith { New-WorktreeResolutionTargetResult -Status 'SessionRoot' -SessionRoot '/synthetic-worktrees/session-root' -WorktreeRoot '/synthetic-worktrees/session-root' -Signal 'Branch' -SignalValue 'f5-fixture-own' -Candidate @('/synthetic-worktrees/session-root') -Detail 'modelled resolved target for the tie row' }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            Mock -CommandName Get-PrdFeatureIssueContent -MockWith { "- Work Mode: full-bug`n" }
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $Path -eq "$($script:TargetFeatureFolder)/spec.md" }

            $payload = New-PlannerPayload -Prompt "Plan $($script:TargetFeatureFolder) and cross-reference $($script:OtherFeatureFolder) now."

            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*$($script:AmbiguityCode)*"
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*cites 2 feature folders*'
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
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue 'f5-fixture-own'
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
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue 'f5-fixture-own'
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
                -WorktreeRoot $script:ItemWorktreeRoot -SignalValue 'f5-fixture-own'
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
