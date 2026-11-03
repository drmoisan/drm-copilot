<#
.SYNOPSIS
    Local integration scenarios for the parallel admission helper (issue #1047).

.DESCRIPTION
    Drives the functions of .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1
    end to end over the committed fixtures under tests/fixtures/parallel_admission:
    seeding a run from prepared items, adding a half-prepared item, and adding to
    a closed run. Item branches are in-memory trees behind a mocked
    Invoke-ParallelAdmissionGit, and the committed fixtures are read as text and
    served through a mocked Read-ParallelAdmissionJsonText. No file is written, no
    git process is started, and no network or GitHub call is made.
#>

BeforeAll {
    # Resolve the repository root four levels up: parallel-admission -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:EntryScriptPath = (Resolve-Path (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1')).Path
    . $script:EntryScriptPath

    # Committed fixtures, read once as text.
    $script:FixtureRoot = Join-Path -Path $script:RepoRoot -ChildPath 'tests/fixtures/parallel_admission'
    $script:Fixture = @{}
    foreach ($name in @('seed-parallel.md', 'seed-planner-state.json', 'seed-orchestrator-state.json', 'seed-scheduling-record.json', 'closed-orchestrator-state.json')) {
        $script:Fixture[$name] = (Get-Content -LiteralPath (Join-Path -Path $script:FixtureRoot -ChildPath $name) -Raw).Replace("`r`n", "`n")
    }
    $script:Planner = ConvertFrom-ParallelAdmissionJson -Text $script:Fixture['seed-planner-state.json']

    # Serve a fixture by the file name at the end of the requested path.
    function Get-FixtureText {
        param([string] $Path)
        $name = $Path.Substring($Path.Replace('\', '/').LastIndexOf('/') + 1)
        if (-not $script:Fixture.ContainsKey($name)) { throw "No fixture named $name." }
        return $script:Fixture[$name]
    }

    # Build the git responses of one item branch: a prepared feature folder by
    # default, or only the listed stages. Unknown keys answer exit 1 (absent).
    function Get-BranchGitResponse {
        param([hashtable] $Item, [string[]] $Stage = @('research', 'spec', 'plan', 'cleared'))
        $branch = "origin/$($Item.branch_name)"
        $folder = $Item.feature_folder
        $plan = $Item.plan_path
        $preflight = "$folder/evidence/other/preflight-fixes.2026-11-02T12-00.md"
        $files = [ordered]@{}
        if ($Stage -contains 'research') { $files[$Item.research_path] = "# Research`nFindings for $folder." }
        if ($Stage -contains 'spec') { $files["$folder/spec.md"] = "# Spec`n`n## Overview`n`nThe item edits one script." }
        if ($Stage -contains 'plan') { $files[$plan] = "# Plan`n`n- [ ] [P1-T1] Edit ``$($Item.blast_radius.paths[0])``." }
        if ($Stage -contains 'cleared') { $files[$preflight] = 'PREFLIGHT: ALL CLEAR' }
        $response = @{}
        $response['fetch --quiet origin'] = @()
        $response["ls-tree -r --name-only $branch -- $folder"] = @($files.Keys)
        $response['show origin/main:docs/features/templates/feature/spec.md'] = @('# <feature-name> - Spec', '', 'Brief summary of the behavior and scope.')
        $response['show origin/main:docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md'] = @('- [ ] [P1-T1] <Atomic task with strong verb>')
        foreach ($path in $files.Keys) { $response["show ${branch}:$path"] = @($files[$path] -split "`n") }
        $response["log -1 --format=%ct $branch -- $plan"] = @('1000')
        $response["log -1 --format=%ct $branch -- $preflight"] = @('1200')
        $response["rev-parse ${branch}:$plan"] = @($Item.plan_hash)
        $response["merge-base origin/main $branch"] = @($Item.base_commit)
        $response["merge-base --is-ancestor $($Item.base_commit) origin/main"] = @()
        $response["diff --name-only --no-renames $($Item.base_commit) origin/main"] = @('README.md', 'scripts/other/unrelated.ps1')
        $response["cat-file -e $($Item.base_commit):$($Item.blast_radius.paths[0])"] = @()
        $response["cat-file -e origin/main:$($Item.blast_radius.paths[0])"] = @()
        return $response
    }

    # Parse an emitted JSON document for assertions.
    function ConvertFrom-EmittedJson {
        param([string] $Text)
        return [System.Text.Json.JsonDocument]::Parse($Text).RootElement
    }
}

AfterAll {
    Remove-Module -Name ParallelAdmission, ParallelAdmissionPrecedence -Force -ErrorAction SilentlyContinue
}

Describe 'Seed from prepared items' {
    BeforeEach {
        $script:GitResponse = @{}
        Mock Invoke-ParallelAdmissionGit {
            param([string[]] $GitArgs)
            $key = $GitArgs -join ' '
            if ($script:GitResponse.ContainsKey($key)) { return [pscustomobject]@{ ExitCode = 0; Output = [string[]]@($script:GitResponse[$key]) } }
            return [pscustomobject]@{ ExitCode = 1; Output = [string[]]@() }
        }
        Mock Read-ParallelAdmissionJsonText { param([string] $Path) return Get-FixtureText -Path $Path }
    }

    It 'assesses item <Key> as cleared and fresh with admit_prepared' -ForEach @(@{ Key = 1101; Index = 0 }, @{ Key = 1102; Index = 1 }) {
        $item = $script:Planner['items'][$Index]
        $script:GitResponse = Get-BranchGitResponse -Item $item

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'assess' -Branch "origin/$($item.branch_name)" -FeatureFolder $item.feature_folder -PlannerCheckpointPath 'artifacts/orchestration/seed-planner-state.json'

        $outcome.ExitCode | Should -Be 0
        $json = ConvertFrom-EmittedJson $outcome.Stdout
        $json.GetProperty('preparation_status').GetString() | Should -Be 'cleared'
        $json.GetProperty('staleness').GetProperty('verdict').GetString() | Should -Be 'fresh'
        $json.GetProperty('next_action').GetString() | Should -Be 'admit_prepared'
        $json.GetProperty('plan_hash').GetString() | Should -Be $item.plan_hash
        $json.GetProperty('base_commit').GetString() | Should -Be $item.base_commit
        $json.GetProperty('band').GetProperty('value').GetString() | Should -Be 'C2'
        $json.GetProperty('band').GetProperty('source').GetString() | Should -Be 'planner_checkpoint'
    }

    It 'orders the cohorts into the fixture cohort table' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'order-cohorts' -Cohorts '[[1101, 1102]]' -Precedence '1101:1102'

        $outcome.ExitCode | Should -Be 0
        $actual = @((ConvertFrom-EmittedJson $outcome.Stdout).GetProperty('cohorts').EnumerateArray() | ForEach-Object { @($_.EnumerateArray() | ForEach-Object { $_.GetInt64() }) -join ',' })
        $expected = @($script:Planner['cohorts'] | ForEach-Object { @($_['item_keys']) -join ',' })
        $actual | Should -Be $expected
    }

    It 'accepts the seeded orchestrator cohort table' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-cohorts' -CheckpointPath 'tests/fixtures/parallel_admission/seed-orchestrator-state.json'

        $outcome.ExitCode | Should -Be 0
    }

    It 'rejects a swapped cohort table with precedence_violated' {
        $script:Fixture['swapped-orchestrator-state.json'] = $script:Fixture['seed-orchestrator-state.json'].Replace('"item_keys": [1101]', '"item_keys": [9999]').Replace('"item_keys": [1102]', '"item_keys": [1101]').Replace('"item_keys": [9999]', '"item_keys": [1102]')

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-cohorts' -CheckpointPath 'swapped-orchestrator-state.json'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'PARALLEL_ADMISSION_REJECTED: precedence_violated: *'
    }

    It 'builds the committed scheduling record' {
        $recordInput = [ordered]@{ edges = $script:Planner['conflict_edges']; tolerated_overlaps = $script:Planner['tolerated_overlaps']; precedence = $script:Planner['precedence']; items = $script:Planner['items'] }

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'record' -RunFolder 'docs/features/parallel/admission-seed' -Entry (ConvertTo-ParallelAdmissionJson -Value $recordInput)

        $outcome.ExitCode | Should -Be 0
        $outcome.Stdout | Should -BeExactly $script:Fixture['seed-scheduling-record.json'].TrimEnd("`n")
        Should -Invoke Invoke-ParallelAdmissionGit -Times 0 -Exactly
    }

    It 'reuses recorded edges read by ref from the plan branch for a matching plan hash' {
        $script:GitResponse['show origin/parallel/admission-seed-plan:docs/features/parallel/admission-seed/parallel-scheduling.json'] = @($script:Fixture['seed-scheduling-record.json'] -split "`n")

        $reuse = Get-ParallelAdmissionRecordedEdge -Slug 'admission-seed' -IssueNum 1102 -CurrentPlanHash $script:Planner['items'][1]['plan_hash']

        $reuse.action | Should -Be 'reuse'
        $reuse.reason | Should -Be 'plan_hash_matches'
    }

    It 'recomputes recorded edges when the plan hash changed' {
        $script:GitResponse['show origin/parallel/admission-seed-plan:docs/features/parallel/admission-seed/parallel-scheduling.json'] = @($script:Fixture['seed-scheduling-record.json'] -split "`n")

        $reuse = Get-ParallelAdmissionRecordedEdge -Slug 'admission-seed' -IssueNum 1102 -CurrentPlanHash 'ffffffffffffffffffffffffffffffffffffffff'

        $reuse.action | Should -Be 'recompute'
    }
}

Describe 'Add a half-prepared item' {
    BeforeEach {
        $item = @{
            branch_name    = 'feature/admission-half-1103'
            feature_folder = 'docs/features/active/admission-half-1103'
            research_path  = 'docs/features/active/admission-half-1103/research/research.2026-11-02T08-00.md'
            plan_path      = 'docs/features/active/admission-half-1103/plan.2026-11-03T09-00.md'
            plan_hash      = 'd3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3'
            base_commit    = 'b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0'
            blast_radius   = @{ paths = @('scripts/sample/gamma.ps1') }
        }
        $script:GitResponse = Get-BranchGitResponse -Item $item -Stage @('research', 'spec')
        Mock Invoke-ParallelAdmissionGit {
            param([string[]] $GitArgs)
            $key = $GitArgs -join ' '
            if ($script:GitResponse.ContainsKey($key)) { return [pscustomobject]@{ ExitCode = 0; Output = [string[]]@($script:GitResponse[$key]) } }
            return [pscustomobject]@{ ExitCode = 1; Output = [string[]]@() }
        }
        Mock Read-ParallelAdmissionJsonText { param([string] $Path) return Get-FixtureText -Path $Path }
    }

    It 'reports stage spec and resumes preparation at plan' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'assess' -Branch 'origin/feature/admission-half-1103' -FeatureFolder 'docs/features/active/admission-half-1103' -Band 'C2'

        $outcome.ExitCode | Should -Be 0
        $json = ConvertFrom-EmittedJson $outcome.Stdout
        $json.GetProperty('preparation_status').GetString() | Should -Be 'spec'
        $json.GetProperty('resume_stage').GetString() | Should -Be 'plan'
        $json.GetProperty('next_action').GetString() | Should -Be 'resume_preparation'
        $json.GetProperty('research_path').GetString() | Should -Be 'docs/features/active/admission-half-1103/research/research.2026-11-02T08-00.md'
        $json.GetProperty('spec_path').GetString() | Should -Be 'docs/features/active/admission-half-1103/spec.md'
        $json.GetProperty('band').GetProperty('source').GetString() | Should -Be 'caller'
    }
}

Describe 'Add to a closed run' {
    BeforeEach {
        Mock Invoke-ParallelAdmissionGit { throw 'guard-run runs no git command' }
        Mock Read-ParallelAdmissionJsonText { param([string] $Path) return Get-FixtureText -Path $Path }
    }

    It 'rejects the addition with run_closed' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'guard-run' -CheckpointPath 'tests/fixtures/parallel_admission/closed-orchestrator-state.json' -ManifestMode 'closed'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stdout | Should -BeNullOrEmpty
        $outcome.Stderr | Should -BeLike 'PARALLEL_ADMISSION_REJECTED: run_closed: *'
        $outcome.Stderr | Should -Not -Match 'PARALLEL_MUTATION_REJECTED'
    }

    It 'admits the addition to the open seeded run' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'guard-run' -CheckpointPath 'tests/fixtures/parallel_admission/seed-orchestrator-state.json' -ManifestMode 'open'

        $outcome.ExitCode | Should -Be 0
    }
}
