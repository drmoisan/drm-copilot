#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Call-target resolution cases for the prd-feature gate.
.DESCRIPTION
    Contexts 'cross-file mock resolution smoke' and 'call-target resolution seam' moved
    here unchanged from enforce-prd-feature-before-planner.TargetResolution.Tests.ps1
    (issue #935, I-3), which had reached the 500-line limit.

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
Describe 'enforce-prd-feature-before-planner.ps1 target resolution' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
        $script:Helpers = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex'
        . $script:Helpers

        # The modelled target results below are built with F1's own constructor, so the
        # injected shape is the shipped one rather than a local imitation. Both modules
        # are imported here explicitly for the same reason the two hook files are
        # dot-sourced explicitly: a later change to the hook's own import line cannot
        # then redirect these assertions.
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeResolution.psm1").Path -Force
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1").Path -Force
        $script:TargetFeatureFolder = 'docs/features/active/2026-09-13-synthetic-target-672'
    }
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }

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
                param([string] $SessionRoot)
                $script:CapturedSessionRoot = $SessionRoot
                return ([pscustomobject]@{ Status = 'NoTarget' })
            }

            $null = Get-PrdFeatureCallTarget -ToolInput ([pscustomobject]@{ prompt = 'Plan the work.' })

            $script:CapturedSessionRoot | Should -Not -BeNullOrEmpty
            [System.IO.Path]::IsPathRooted($script:CapturedSessionRoot) | Should -BeTrue
        }
    }
}
