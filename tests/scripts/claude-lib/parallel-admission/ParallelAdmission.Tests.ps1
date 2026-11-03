<#
.SYNOPSIS
    Unit tests for the pure admission functions of ParallelAdmission.psm1 (issue #1047).

.DESCRIPTION
    Covers .claude/lib/parallel-admission/ParallelAdmission.psm1. Every function
    under test is pure, so inputs are built in memory: no file is created, no
    process is started, and no clock is read.
#>

BeforeAll {
    # Resolve the repository root four levels up: parallel-admission -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:ModulePath = Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/parallel-admission/ParallelAdmission.psm1'
    Import-Module -Name $script:ModulePath -Force -ErrorAction Stop

    # In-memory branch tree for stage inference: one feature folder with every
    # artifact satisfied, plus the template placeholder and task lines.
    $script:Folder = 'docs/features/active/sample-feature-1101'
    $script:Placeholder = @('Brief summary of the behavior and scope.', 'Describe how the feature should behave end-to-end.')
    $script:TemplateTask = @('- [ ] [P1-T1] <Atomic task with strong verb>', '- [ ] [P1-T2] <Atomic task>')
    $script:ResearchPath = "$($script:Folder)/research/research.2026-11-01T10-00.md"
    $script:SpecPath = "$($script:Folder)/spec.md"
    $script:PlanPath = "$($script:Folder)/plan.2026-11-02T09-00.md"
    $script:PreflightPath = "$($script:Folder)/evidence/other/preflight-fixes.2026-11-02T10-00.md"

    # Build the inference arguments; each test removes or replaces what it needs.
    function Get-StageInput {
        param([string[]] $Omit = @(), [hashtable] $Text = @{}, [hashtable] $Time = @{})
        $tree = @($script:ResearchPath, $script:SpecPath, $script:PlanPath, $script:PreflightPath, 'docs/features/active/other-feature/spec.md') | Where-Object { $Omit -notcontains $_ }
        $fileText = @{
            $script:ResearchPath  = "# Research`nFindings."
            $script:SpecPath      = "# Spec`n`n## Overview`n`nThe helper admits prepared items."
            $script:PlanPath      = "# Plan`n`n- [ ] [P0-T1] Read the policies.`n- [ ] [P1-T1] Create the module."
            $script:PreflightPath = "Timestamp: 2026-11-02T10-00`nPREFLIGHT: ALL CLEAR"
        }
        foreach ($key in $Text.Keys) { $fileText[$key] = $Text[$key] }
        $commitTime = @{ $script:PlanPath = [long]1000; $script:PreflightPath = [long]1100 }
        foreach ($key in $Time.Keys) { $commitTime[$key] = $Time[$key] }
        return @{ TreePath = [string[]]@($tree); FileText = $fileText; CommitTime = $commitTime; SpecPlaceholderLine = $script:Placeholder; PlanTemplateTaskLine = $script:TemplateTask; FeatureFolder = $script:Folder }
    }
}

AfterAll {
    Remove-Module -Name ParallelAdmission -Force -ErrorAction SilentlyContinue
}

Describe 'Test-ParallelAdmissionRunOpen' {
    It 'rejects a closed manifest mode' {
        # Arrange: the manifest is closed while the checkpoint still records open.
        $checkpoint = @{ mode = 'open'; mutations = @() }

        # Act
        $result = Test-ParallelAdmissionRunOpen -ManifestMode 'closed' -Checkpoint $checkpoint

        # Assert: any closed side closes the run.
        $result.Open | Should -BeFalse
        $result.Detail | Should -Match 'closed'
    }

    It 'rejects a closed checkpoint mode' {
        $result = Test-ParallelAdmissionRunOpen -ManifestMode 'closed' -Checkpoint @{ mode = 'closed'; mutations = @() }

        $result.Open | Should -BeFalse
        $result.Detail | Should -Be 'manifest and checkpoint mode are closed'
    }

    It 'rejects an open run that records a close mutation' {
        $checkpoint = @{ mode = 'open'; mutations = @(@{ op = 'add'; item_key = 1 }, @{ op = 'close'; item_key = $null }) }

        $result = Test-ParallelAdmissionRunOpen -ManifestMode 'open' -Checkpoint $checkpoint

        $result.Open | Should -BeFalse
        $result.Detail | Should -Be 'a close mutation is recorded'
    }

    It 'rejects a manifest mode that disagrees with the checkpoint mode' {
        $result = Test-ParallelAdmissionRunOpen -ManifestMode 'open' -Checkpoint @{ mode = 'closed' }

        $result.Open | Should -BeFalse
        $result.Detail | Should -Be "manifest mode 'open' disagrees with checkpoint mode 'closed'"
    }

    It 'fails closed when the checkpoint mode is missing' {
        $result = Test-ParallelAdmissionRunOpen -ManifestMode 'open' -Checkpoint @{ mutations = @() }

        $result.Open | Should -BeFalse
        $result.Detail | Should -Be 'checkpoint mode is missing or unreadable'
    }

    It 'fails closed when the manifest mode is blank' {
        $result = Test-ParallelAdmissionRunOpen -ManifestMode '' -Checkpoint @{ mode = 'open' }

        $result.Open | Should -BeFalse
        $result.Detail | Should -Match 'manifest mode is missing or unreadable'
    }

    It 'fails closed when the checkpoint is not an object' {
        $result = Test-ParallelAdmissionRunOpen -ManifestMode 'open' -Checkpoint $null

        $result.Open | Should -BeFalse
        $result.Detail | Should -Be 'checkpoint is missing or is not a JSON object'
    }

    It 'accepts an open run with no close mutation' {
        $checkpoint = @{ mode = 'open'; mutations = @(@{ op = 'add'; item_key = 7 }) }

        $result = Test-ParallelAdmissionRunOpen -ManifestMode 'open' -Checkpoint $checkpoint

        $result.Open | Should -BeTrue
        $result.ManifestMode | Should -Be 'open'
        $result.CheckpointMode | Should -Be 'open'
    }
}

Describe 'Get-ParallelAdmissionInferredStage' {
    It 'infers none when the folder has no research file' {
        $arguments = Get-StageInput -Omit @($script:ResearchPath)

        $result = Get-ParallelAdmissionInferredStage @arguments

        $result.stage | Should -Be 'none'
        $result.research_path | Should -BeNullOrEmpty
    }

    It 'infers research when research exists and spec.md is absent' {
        $arguments = Get-StageInput -Omit @($script:SpecPath)

        $result = Get-ParallelAdmissionInferredStage @arguments

        $result.stage | Should -Be 'research'
        $result.research_path | Should -Be $script:ResearchPath
        $result.spec_path | Should -BeNullOrEmpty
    }

    It 'infers spec when research and spec exist and no plan exists' {
        $arguments = Get-StageInput -Omit @($script:PlanPath)

        $result = Get-ParallelAdmissionInferredStage @arguments

        $result.stage | Should -Be 'spec'
        $result.spec_path | Should -Be $script:SpecPath
        $result.plan_path | Should -BeNullOrEmpty
    }

    It 'infers plan when no preflight evidence exists' {
        $arguments = Get-StageInput -Omit @($script:PreflightPath)

        $result = Get-ParallelAdmissionInferredStage @arguments

        $result.stage | Should -Be 'plan'
        $result.plan_path | Should -Be $script:PlanPath
    }

    It 'infers cleared from preflight evidence committed after the plan' {
        $arguments = Get-StageInput

        $result = Get-ParallelAdmissionInferredStage @arguments

        $result.stage | Should -Be 'cleared'
        $result.research_path | Should -Be $script:ResearchPath
        $result.spec_path | Should -Be $script:SpecPath
        $result.plan_path | Should -Be $script:PlanPath
    }

    It 'infers cleared when the preflight evidence shares the plan commit time' {
        $arguments = Get-StageInput -Time @{ $script:PreflightPath = [long]1000 }

        (Get-ParallelAdmissionInferredStage @arguments).stage | Should -Be 'cleared'
    }

    It 'does not count an empty research file' {
        $arguments = Get-StageInput -Text @{ $script:ResearchPath = "  `n" }

        (Get-ParallelAdmissionInferredStage @arguments).stage | Should -Be 'none'
    }

    It 'caps at research when spec.md still carries a template placeholder line' {
        $arguments = Get-StageInput -Text @{ $script:SpecPath = "# Spec`n`n## Overview`n`nBrief summary of the behavior and scope.`n" }

        (Get-ParallelAdmissionInferredStage @arguments).stage | Should -Be 'research'
    }

    It 'caps at spec when the plan carries only template task lines' {
        $arguments = Get-StageInput -Text @{ $script:PlanPath = "# Plan`n- [ ] [P1-T1] <Atomic task with strong verb>`n- [ ] [P1-T2] <Atomic task>" }

        (Get-ParallelAdmissionInferredStage @arguments).stage | Should -Be 'spec'
    }

    It 'selects the lexicographically greatest plan file' {
        # Arrange: an older plan sorts first and a newer plan sorts last.
        $older = "$($script:Folder)/plan.2026-10-30T08-00.md"
        $arguments = Get-StageInput -Omit @($script:PreflightPath)
        $arguments.TreePath = [string[]]@($older) + $arguments.TreePath
        $arguments.FileText[$older] = '- [ ] [P1-T1] Old task.'

        $result = Get-ParallelAdmissionInferredStage @arguments

        $result.plan_path | Should -Be $script:PlanPath
    }

    It 'caps at plan when the preflight evidence is older than the plan' {
        $arguments = Get-StageInput -Time @{ $script:PreflightPath = [long]900 }

        (Get-ParallelAdmissionInferredStage @arguments).stage | Should -Be 'plan'
    }

    It 'caps at plan when the preflight evidence does not record ALL CLEAR' {
        $arguments = Get-StageInput -Text @{ $script:PreflightPath = 'PREFLIGHT: REVISIONS REQUIRED' }

        (Get-ParallelAdmissionInferredStage @arguments).stage | Should -Be 'plan'
    }

    It 'caps at plan when the plan commit time is unknown' {
        $arguments = Get-StageInput
        $arguments.CommitTime = @{ $script:PreflightPath = [long]1100 }

        (Get-ParallelAdmissionInferredStage @arguments).stage | Should -Be 'plan'
    }

    It 'throws when the feature folder is blank' {
        { Get-ParallelAdmissionInferredStage -FeatureFolder ' ' } | Should -Throw '*requires -FeatureFolder*'
    }
}

Describe 'Preparation receipt selection and stage resolution' {
    It 'selects the lexicographically greatest receipt among three names' {
        $other = "$($script:Folder)/evidence/other"
        $paths = @("$other/preparation-receipt.2026-11-01T09-00.json", "$other/preparation-receipt.2026-11-03T08-15.json", "$other/preparation-receipt.2026-11-02T23-59.json", "$other/preflight-fixes.2026-11-04T00-00.md")

        $selected = Select-ParallelAdmissionReceipt -ReceiptPath $paths

        $selected | Should -Be "$other/preparation-receipt.2026-11-03T08-15.json"
    }

    It 'returns null when no path is a preparation receipt' {
        Select-ParallelAdmissionReceipt -ReceiptPath @('a/b/notes.json', '') | Should -BeNullOrEmpty
    }

    It 'uses the inferred stage when no receipt exists' {
        $result = Resolve-ParallelAdmissionStage -Receipt $null -InferredStage 'spec' -CurrentPlanHash ''

        $result.stage | Should -Be 'spec'
        $result.source | Should -Be 'inference'
    }

    It 'keeps the receipt stage when its plan hash matches the current blob hash' {
        $receipt = @{ stage = 'cleared'; plan_hash = 'abc123'; base_commit = 'def456' }

        $result = Resolve-ParallelAdmissionStage -Receipt $receipt -InferredStage 'plan' -CurrentPlanHash 'abc123'

        $result.stage | Should -Be 'cleared'
        $result.source | Should -Be 'receipt'
        $result.downgraded | Should -BeFalse
    }

    It 'downgrades a cleared receipt to plan when its plan hash differs from the current blob hash' {
        $receipt = @{ stage = 'cleared'; plan_hash = 'abc123' }

        $result = Resolve-ParallelAdmissionStage -Receipt $receipt -InferredStage 'cleared' -CurrentPlanHash 'fff999'

        $result.stage | Should -Be 'plan'
        $result.downgraded | Should -BeTrue
    }

    It 'keeps a receipt stage below plan whatever the hash' {
        $result = Resolve-ParallelAdmissionStage -Receipt @{ stage = 'research'; plan_hash = $null } -InferredStage 'none' -CurrentPlanHash ''

        $result.stage | Should -Be 'research'
    }

    It 'throws on a receipt stage outside the stage set' {
        { Resolve-ParallelAdmissionStage -Receipt @{ stage = 'prepared' } -InferredStage 'none' -CurrentPlanHash '' } | Should -Throw '*is not one of*'
    }

    It 'throws on an inferred stage outside the stage set' {
        { Resolve-ParallelAdmissionStage -Receipt $null -InferredStage 'done' -CurrentPlanHash '' } | Should -Throw '*is not one of*'
    }
}

Describe 'Cited paths and the staleness verdict' {
    BeforeAll {
        $script:StalePlanText = @"
### Phase 1 — Work

- [ ] [P1-T1] Edit ``.claude/hooks/sample-hook.ps1`` and add ``tests/scripts/claude-hooks/sample-hook.Tests.ps1``.
- [ ] [P1-T2] Write ``$($script:Folder)/evidence/other/notes.md``.
"@
        $script:Cited = [string[]]@('.claude/hooks/sample-hook.ps1', 'scripts/powershell/**', 'tests/scripts/claude-hooks/sample-hook.Tests.ps1')
    }

    It 'extracts plan and declared paths and drops the feature folder' {
        $cited = Get-ParallelAdmissionCitedPath -PlanText $script:StalePlanText -DeclaredPath @('scripts/powershell/**', "$($script:Folder)/**") -FeatureFolder $script:Folder

        $cited | Should -Be $script:Cited
    }

    It 'throws when the cited-path feature folder is blank' {
        { Get-ParallelAdmissionCitedPath -PlanText '' -FeatureFolder '' } | Should -Throw '*requires -FeatureFolder*'
    }

    It 'returns fresh when no changed path overlaps a cited path' {
        $result = Get-ParallelAdmissionStaleness -CitedPath $script:Cited -ChangedPath @('README.md', 'scripts/dev_tools/x.py') -PresentAtBase $script:Cited -PresentAtMain $script:Cited -BaseIsAncestor $true -FeatureFolder $script:Folder

        $result.verdict | Should -Be 'fresh'
        $result.changed_cited_paths.Count | Should -Be 0
        $result.removed_cited_paths.Count | Should -Be 0
    }

    It 'returns stale when a changed path matches a cited glob' {
        $result = Get-ParallelAdmissionStaleness -CitedPath $script:Cited -ChangedPath @('scripts/powershell/PoshQC/PoshQC.psm1') -PresentAtBase $script:Cited -PresentAtMain $script:Cited -FeatureFolder $script:Folder

        $result.verdict | Should -Be 'stale'
        $result.changed_cited_paths | Should -Be @('scripts/powershell/PoshQC/PoshQC.psm1')
    }

    It 'returns stale when a changed path equals a cited path' {
        $result = Get-ParallelAdmissionStaleness -CitedPath $script:Cited -ChangedPath @('.claude/hooks/sample-hook.ps1') -PresentAtBase $script:Cited -PresentAtMain $script:Cited -FeatureFolder $script:Folder

        $result.verdict | Should -Be 'stale'
        $result.changed_cited_paths | Should -Be @('.claude/hooks/sample-hook.ps1')
    }

    It 'returns premise_falsified when a cited path present at the base is absent on main' {
        $atMain = [string[]]@('tests/scripts/claude-hooks/sample-hook.Tests.ps1')
        $result = Get-ParallelAdmissionStaleness -CitedPath $script:Cited -ChangedPath @('.claude/hooks/sample-hook.ps1') -PresentAtBase $script:Cited -PresentAtMain $atMain -FeatureFolder $script:Folder

        $result.verdict | Should -Be 'premise_falsified'
        $result.removed_cited_paths | Should -Be @('.claude/hooks/sample-hook.ps1')
    }

    It 'returns stale when the base commit is not an ancestor of main' {
        $result = Get-ParallelAdmissionStaleness -CitedPath $script:Cited -ChangedPath @() -PresentAtBase $script:Cited -PresentAtMain $script:Cited -BaseIsAncestor $false -FeatureFolder $script:Folder

        $result.verdict | Should -Be 'stale'
    }

    It 'ignores a change inside the item feature folder' {
        $result = Get-ParallelAdmissionStaleness -CitedPath @('docs/**') -ChangedPath @("$($script:Folder)/spec.md") -FeatureFolder $script:Folder

        $result.verdict | Should -Be 'fresh'
    }

    It 'does not count a path the plan creates as removed' {
        # Arrange: the test file is absent at the base (the plan creates it) and absent on main.
        $atBase = [string[]]@('.claude/hooks/sample-hook.ps1')
        $result = Get-ParallelAdmissionStaleness -CitedPath $script:Cited -ChangedPath @() -PresentAtBase $atBase -PresentAtMain $atBase -FeatureFolder $script:Folder

        $result.verdict | Should -Be 'fresh'
        $result.removed_cited_paths.Count | Should -Be 0
    }
}

Describe 'Resolve-ParallelAdmissionBand' {
    It 'takes the caller band first' {
        $band = Resolve-ParallelAdmissionBand -CallerBand 'C3' -PlannerBand 'C1'

        $band.value | Should -Be 'C3'
        $band.source | Should -Be 'caller'
    }

    It 'takes the planner checkpoint band when no caller band is given' {
        $band = Resolve-ParallelAdmissionBand -CallerBand '' -PlannerBand 'C2'

        $band.value | Should -Be 'C2'
        $band.source | Should -Be 'planner_checkpoint'
    }

    It 'requires an assessment when neither band is given' {
        $band = Resolve-ParallelAdmissionBand -CallerBand $null -PlannerBand $null

        $band.value | Should -BeNullOrEmpty
        $band.source | Should -Be 'assessment'
    }

    It 'throws on a caller band outside C1 to C4' {
        { Resolve-ParallelAdmissionBand -CallerBand 'C5' -PlannerBand 'C1' } | Should -Throw '*is not one of C1, C2, C3, C4*'
    }

    It 'throws on a planner band outside C1 to C4' {
        { Resolve-ParallelAdmissionBand -CallerBand '' -PlannerBand 'c2' } | Should -Throw '*from planner_checkpoint*'
    }
}

Describe 'Get-ParallelAdmissionDecision' {
    It 'maps <Stage> with verdict <Verdict> to <Action> at <Resume>' -ForEach @(
        @{ Stage = 'cleared'; Verdict = 'fresh'; Cleared = $true; Resume = $null; Action = 'admit_prepared' }
        @{ Stage = 'cleared'; Verdict = 'stale'; Cleared = $true; Resume = 'preflight'; Action = 'resume_preparation' }
        @{ Stage = 'cleared'; Verdict = 'premise_falsified'; Cleared = $true; Resume = 'plan'; Action = 'resume_preparation' }
        @{ Stage = 'plan'; Verdict = 'stale'; Cleared = $false; Resume = 'preflight'; Action = 'resume_preparation' }
        @{ Stage = 'plan'; Verdict = 'fresh'; Cleared = $false; Resume = 'preflight'; Action = 'resume_preparation' }
        @{ Stage = 'plan'; Verdict = 'premise_falsified'; Cleared = $false; Resume = 'plan'; Action = 'resume_preparation' }
        @{ Stage = 'spec'; Verdict = $null; Cleared = $false; Resume = 'plan'; Action = 'resume_preparation' }
        @{ Stage = 'research'; Verdict = $null; Cleared = $false; Resume = 'spec'; Action = 'resume_preparation' }
        @{ Stage = 'none'; Verdict = $null; Cleared = $false; Resume = 'research'; Action = 'full_preparation' }
    ) {
        $decision = Get-ParallelAdmissionDecision -Stage $Stage -Verdict $Verdict -PreflightCleared $Cleared

        $decision.next_action | Should -Be $Action
        $decision.resume_stage | Should -Be $Resume
    }

    It 'resumes a cleared stage without a cleared preflight at preflight even when fresh' {
        $decision = Get-ParallelAdmissionDecision -Stage 'cleared' -Verdict 'fresh' -PreflightCleared $false

        $decision.next_action | Should -Be 'resume_preparation'
        $decision.resume_stage | Should -Be 'preflight'
    }

    It 'throws on a stage outside the stage set' {
        { Get-ParallelAdmissionDecision -Stage 'prepared' -Verdict 'fresh' -PreflightCleared $true } | Should -Throw '*is not one of*'
    }

    It 'throws when a plan-stage verdict is missing' {
        { Get-ParallelAdmissionDecision -Stage 'plan' -Verdict '' -PreflightCleared $false } | Should -Throw '*Staleness verdict*'
    }
}
