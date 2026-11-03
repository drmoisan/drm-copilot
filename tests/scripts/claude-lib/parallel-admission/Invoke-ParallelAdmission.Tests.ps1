<#
.SYNOPSIS
    Behavioral tests for the parallel admission entry script (issue #1047).

.DESCRIPTION
    Covers .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1. The script
    is dot-sourced, so its guarded entry-point body does not run and
    Invoke-ParallelAdmissionCli is called in-process. The seams
    Invoke-ParallelAdmissionGit, Read-ParallelAdmissionJsonText, and
    Get-ParallelAdmissionUtcNow are defined in this test scope by the dot-source
    and are mocked at that scope: no git process is started, no file is read or
    created, and no clock is read.
#>

BeforeAll {
    # Resolve the repository root four levels up: parallel-admission -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:EntryScriptPath = (Resolve-Path (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1')).Path

    # The guarded entry-point body does not run under dot-sourcing.
    . $script:EntryScriptPath

    $script:UsagePrefix = 'parallel admission usage error: '

    # In-memory git responses for assess, keyed by the joined git arguments. An
    # unknown key answers exit 1 with no output, which is how cat-file reports an
    # absent path.
    $script:AssessBranch = 'origin/feature/sample-1101'
    $script:AssessFolder = 'docs/features/active/sample-1101'
    $script:AssessPlan = "$($script:AssessFolder)/plan.2026-11-02T09-00.md"
    $script:AssessReceipt = "$($script:AssessFolder)/evidence/other/preparation-receipt.2026-11-02T11-00.json"
    function Get-AssessGitResponse {
        param([string[]] $Omit = @(), [string[]] $Changed = @('README.md'), [string[]] $AbsentOnMain = @(), [string] $Receipt = '')
        $branch = $script:AssessBranch
        $main = 'origin/main'
        $files = [ordered]@{
            "$($script:AssessFolder)/research/research.2026-11-01T10-00.md"              = "# Research`nFindings."
            "$($script:AssessFolder)/spec.md"                                            = "# Spec`n`n## Overview`n`nThe helper admits prepared items."
            $script:AssessPlan                                                           = "# Plan`n`n- [ ] [P1-T1] Edit ``.claude/hooks/sample-hook.ps1``."
            "$($script:AssessFolder)/evidence/other/preflight-fixes.2026-11-02T10-00.md" = 'PREFLIGHT: ALL CLEAR'
        }
        if ($Receipt) { $files[$script:AssessReceipt] = $Receipt }
        $response = @{}
        $response['fetch --quiet origin'] = @()
        $response["ls-tree -r --name-only $branch -- $($script:AssessFolder)"] = @($files.Keys | Where-Object { $Omit -notcontains $_ })
        $response["show ${main}:docs/features/templates/feature/spec.md"] = @('# <feature-name> - Spec', '', 'Brief summary of the behavior and scope.')
        $response["show ${main}:docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md"] = @('# Plan', '- [ ] [P1-T1] <Atomic task with strong verb>')
        foreach ($path in $files.Keys) { $response["show ${branch}:$path"] = @($files[$path] -split "`n") }
        $response["log -1 --format=%ct $branch -- $($script:AssessPlan)"] = @('1000')
        $response["log -1 --format=%ct $branch -- $($script:AssessFolder)/evidence/other/preflight-fixes.2026-11-02T10-00.md"] = @('1100')
        $response["rev-parse ${branch}:$($script:AssessPlan)"] = @('abc123')
        $response["merge-base $main $branch"] = @('base000')
        foreach ($base in @('base000', 'receipt999')) {
            $response["merge-base --is-ancestor $base $main"] = @()
            $response["diff --name-only --no-renames $base $main"] = $Changed
            $response["cat-file -e ${base}:.claude/hooks/sample-hook.ps1"] = @()
        }
        if ($AbsentOnMain -notcontains '.claude/hooks/sample-hook.ps1') { $response["cat-file -e ${main}:.claude/hooks/sample-hook.ps1"] = @() }
        return $response
    }

    # Parse an emitted JSON document for assertions.
    function ConvertFrom-EmittedJson {
        param([string] $Text)
        return [System.Text.Json.JsonDocument]::Parse($Text).RootElement
    }
}

AfterAll {
    Remove-Module -Name ParallelAdmission, ParallelAdmissionPrecedence, ParallelAdmissionJson -Force -ErrorAction SilentlyContinue
}

Describe 'Parameter surface' {
    It 'declares no Mandatory parameter' {
        # Arrange: every Parameter attribute in the script and in every function it defines.
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:EntryScriptPath, [ref] $null, [ref] $null)
        $parameterAttribute = @($ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.AttributeAst] -and $node.TypeName.Name -eq 'Parameter'
                }, $true))

        # Act
        $mandatory = @($parameterAttribute | Where-Object { @($_.NamedArguments | Where-Object { $_.ArgumentName -eq 'Mandatory' }).Count -gt 0 })

        # Assert: a Mandatory parameter would prompt under pwsh -File instead of exiting 2.
        $parameterAttribute.Count | Should -BeGreaterThan 0
        $mandatory | Should -BeNullOrEmpty
    }

    It 'binds the first positional argument to Subcommand and the rest to Remaining' {
        $command = Get-Command -Name $script:EntryScriptPath

        $command.Parameters['Subcommand'].ParameterSets.Values.Position | Should -Be 0
        $command.Parameters['Remaining'].ParameterSets.Values.ValueFromRemainingArguments | Should -BeTrue
        foreach ($name in @('CheckpointPath', 'ManifestMode', 'Branch', 'FeatureFolder', 'Band', 'Cohorts', 'Entry', 'Slug', 'IssueNum', 'PlanHash', 'Ref')) {
            $command.Parameters[$name].ParameterSets.Values.Position | Should -Be ([int]::MinValue)
        }
    }

    It 'defines the three seams' {
        foreach ($name in @('Invoke-ParallelAdmissionGit', 'Read-ParallelAdmissionJsonText', 'Get-ParallelAdmissionUtcNow')) {
            Get-Command -Name $name -CommandType Function | Should -Not -BeNullOrEmpty
        }
    }

    It 'documents the fetch side effect of assess' {
        # Arrange: the comment-based help of the script and of the git seam, whitespace collapsed.
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:EntryScriptPath, [ref] $null, [ref] $null)
        $description = ($ast.GetHelpContent().Description -replace '\s+', ' ')
        $seam = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Invoke-ParallelAdmissionGit' }, $true)
        $synopsis = ($seam.GetHelpContent().Synopsis -replace '\s+', ' ')

        # Assert
        $description | Should -BeLike '*git fetch --quiet origin*'
        $description | Should -BeLike '*network access*'
        $description | Should -Not -BeLike '*no git write is made*'
        $synopsis | Should -Not -BeNullOrEmpty
        $synopsis | Should -Not -BeLike '*read-only*'
    }

    It 'contains no observed_resolution token' {
        (Get-Content -LiteralPath $script:EntryScriptPath -Raw).Contains('observed_resolution') | Should -BeFalse
    }
}

Describe 'Invoke-ParallelAdmissionGitChecked' {
    It 'returns the output lines when git exits 0' {
        Mock Invoke-ParallelAdmissionGit { [pscustomobject]@{ ExitCode = 0; Output = [string[]]@('a', 'b'); Stderr = [string[]]@() } }

        $lines = Invoke-ParallelAdmissionGitChecked -GitArgs @('show', 'HEAD:x')

        $lines | Should -Be @('a', 'b')
    }

    It 'throws with the first non-blank stderr line when <Case>' -ForEach @(
        @{ Case = 'one stderr line is present'; Stderr = @("fatal: bad revision 'nope'") }
        @{ Case = 'several stderr lines are present'; Stderr = @('', '  ', "  fatal: bad revision 'nope'  ", 'hint: second line') }
    ) {
        $script:CheckedStderr = [string[]]$Stderr
        Mock Invoke-ParallelAdmissionGit { [pscustomobject]@{ ExitCode = 128; Output = [string[]]@(); Stderr = $script:CheckedStderr } }

        { Invoke-ParallelAdmissionGitChecked -GitArgs @('show', 'nope:x') } | Should -Throw -ExpectedMessage "git show nope:x exited 128: fatal: bad revision 'nope'"
    }

    It 'throws the exit-code message when <Case>' -ForEach @(
        @{ Case = 'Stderr is empty'; Result = [pscustomobject]@{ ExitCode = 128; Output = [string[]]@(); Stderr = [string[]]@() } }
        @{ Case = 'the result has no Stderr property'; Result = [pscustomobject]@{ ExitCode = 128; Output = [string[]]@() } }
    ) {
        $script:CheckedResult = $Result
        Mock Invoke-ParallelAdmissionGit { $script:CheckedResult }

        { Invoke-ParallelAdmissionGitChecked -GitArgs @('show', 'nope:x') } | Should -Throw -ExpectedMessage 'git show nope:x exited 128.'
    }
}

Describe 'Usage errors' {
    BeforeEach {
        Mock Invoke-ParallelAdmissionGit { throw 'git must not run on a usage error' }
        Mock Read-ParallelAdmissionJsonText { throw 'no file may be read on a usage error' }
    }

    It 'exits 2 when the subcommand is missing' {
        $outcome = Invoke-ParallelAdmissionCli

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -BeLike "$($script:UsagePrefix)a subcommand is required*"
        $outcome.Stdout | Should -BeNullOrEmpty
    }

    It 'exits 2 on an unknown subcommand' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'admit'

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -Be "$($script:UsagePrefix)unknown subcommand 'admit'."
    }

    It 'exits 2 when <Subcommand> lacks -<Missing>' -ForEach @(
        @{ Subcommand = 'guard-run'; Missing = 'ManifestMode'; Arguments = @{ CheckpointPath = 'state.json' } }
        @{ Subcommand = 'assess'; Missing = 'FeatureFolder'; Arguments = @{ Branch = 'origin/feature/x' } }
        @{ Subcommand = 'order-cohorts'; Missing = 'Cohorts'; Arguments = @{ Edges = '1:2' } }
        @{ Subcommand = 'test-cohorts'; Missing = 'CheckpointPath'; Arguments = @{} }
        @{ Subcommand = 'record'; Missing = 'Entry'; Arguments = @{ RunFolder = 'docs/features/parallel/s' } }
        @{ Subcommand = 'reuse-edges'; Missing = 'Slug'; Arguments = @{ IssueNum = '1102'; PlanHash = 'c2c2' } }
        @{ Subcommand = 'reuse-edges'; Missing = 'IssueNum'; Arguments = @{ Slug = 'admission-seed'; PlanHash = 'c2c2' } }
        @{ Subcommand = 'reuse-edges'; Missing = 'PlanHash'; Arguments = @{ Slug = 'admission-seed'; IssueNum = '1102' } }
    ) {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand $Subcommand @Arguments

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -Be "$($script:UsagePrefix)$Subcommand requires -$Missing."
    }

    It 'exits 2 on <Subcommand> <Name> <Value>' -ForEach @(
        @{ Subcommand = 'reuse-edges'; Name = '-IssueNum'; Value = '0'; Arguments = @{ Slug = 'admission-seed'; IssueNum = '0'; PlanHash = 'c2c2' }; Message = "-IssueNum must be a positive integer; got '0'." }
        @{ Subcommand = 'reuse-edges'; Name = '-IssueNum'; Value = 'x1'; Arguments = @{ Slug = 'admission-seed'; IssueNum = 'x1'; PlanHash = 'c2c2' }; Message = "-IssueNum must be a positive integer; got 'x1'." }
        @{ Subcommand = 'reuse-edges'; Name = '-Slug'; Value = 'a/b'; Arguments = @{ Slug = 'a/b'; IssueNum = '1102'; PlanHash = 'c2c2' }; Message = "-Slug must be a run slug without '/' or whitespace; got 'a/b'." }
        @{ Subcommand = 'assess'; Name = '-Branch'; Value = '--upload-pack=x'; Arguments = @{ Branch = '--upload-pack=x'; FeatureFolder = 'docs/features/active/x' }; Message = "-Branch must not begin with '-'; got '--upload-pack=x'." }
        @{ Subcommand = 'assess'; Name = '-Main'; Value = '--output=x'; Arguments = @{ Branch = 'origin/feature/x'; FeatureFolder = 'docs/features/active/x'; Main = '--output=x' }; Message = "-Main must not begin with '-'; got '--output=x'." }
        @{ Subcommand = 'reuse-edges'; Name = '-Ref'; Value = '-p'; Arguments = @{ Slug = 'admission-seed'; IssueNum = '1102'; PlanHash = 'c2c2'; Ref = '-p' }; Message = "-Ref must not begin with '-'; got '-p'." }
    ) {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand $Subcommand @Arguments

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -BeExactly "$($script:UsagePrefix)$Message"
    }

    It 'exits 2 on a band outside C1 to C4' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'assess' -Branch 'origin/feature/x' -FeatureFolder 'docs/features/active/x' -Band 'C5'

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -Be "$($script:UsagePrefix)-Band must be one of C1, C2, C3, C4; got 'C5'."
    }

    It 'exits 2 on a floor that is not a non-negative integer' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'order-cohorts' -Cohorts '[[1]]' -Floor '-1'

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -BeLike "$($script:UsagePrefix)-Floor must be a non-negative integer*"
    }

    It 'exits 2 on an unrecognized dash argument' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-cohorts' -CheckpointPath 'state.json' -Remaining @('-Verbosity')

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -Be "$($script:UsagePrefix)unrecognized parameter '-Verbosity'."
    }

    It 'exits 2 on an unexpected positional argument' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-cohorts' -CheckpointPath 'state.json' -Remaining @('extra')

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -Be "$($script:UsagePrefix)unexpected argument 'extra'."
    }

    It 'reads no file and runs no git command on a usage error' {
        $null = Invoke-ParallelAdmissionCli -Subcommand 'assess'

        Should -Invoke Invoke-ParallelAdmissionGit -Times 0 -Exactly
        Should -Invoke Read-ParallelAdmissionJsonText -Times 0 -Exactly
    }
}

Describe 'guard-run' {
    BeforeEach {
        $script:GuardCheckpointText = '{"mode": "open", "mutations": [{"op": "add", "item_key": 1101}]}'
        Mock Read-ParallelAdmissionJsonText { return $script:GuardCheckpointText }
        Mock Get-ParallelAdmissionUtcNow { [datetime]::new(2026, 11, 3, 12, 0, 0, [System.DateTimeKind]::Utc) }
        Mock Invoke-ParallelAdmissionGit { throw 'guard-run runs no git command' }
    }

    It 'exits 0 with one JSON object for an open run' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'guard-run' -CheckpointPath 'artifacts/orchestration/parallel-orchestrator-state.json' -ManifestMode 'open'

        $outcome.ExitCode | Should -Be 0
        $outcome.Stderr | Should -BeNullOrEmpty
        $json = [System.Text.Json.JsonDocument]::Parse($outcome.Stdout).RootElement
        $json.GetProperty('result').GetString() | Should -Be 'open'
        $json.GetProperty('checked_at').GetString() | Should -Be '2026-11-03T12-00'
    }

    It 'rejects run_closed when <Case>' -ForEach @(
        @{ Case = 'the manifest is closed'; Manifest = 'closed'; Text = '{"mode": "open", "mutations": []}' }
        @{ Case = 'the checkpoint is closed'; Manifest = 'closed'; Text = '{"mode": "closed", "mutations": []}' }
        @{ Case = 'a close mutation is recorded'; Manifest = 'open'; Text = '{"mode": "open", "mutations": [{"op": "close", "item_key": null}]}' }
        @{ Case = 'the modes disagree'; Manifest = 'open'; Text = '{"mode": "closed", "mutations": []}' }
        @{ Case = 'the checkpoint mode is missing'; Manifest = 'open'; Text = '{"mutations": []}' }
        @{ Case = 'the manifest mode is unknown'; Manifest = 'pending'; Text = '{"mode": "open"}' }
        @{ Case = 'the checkpoint is not JSON'; Manifest = 'open'; Text = 'not json' }
    ) {
        $script:GuardCheckpointText = $Text

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'guard-run' -CheckpointPath 'state.json' -ManifestMode $Manifest

        $outcome.ExitCode | Should -Be 1
        $outcome.Stdout | Should -BeNullOrEmpty
        $outcome.Stderr | Should -BeLike 'PARALLEL_ADMISSION_REJECTED: run_closed: *'
        $outcome.Stderr | Should -Not -Match 'PARALLEL_MUTATION_REJECTED'
        @($outcome.Stderr -split "`n").Count | Should -Be 1
    }

    It 'rejects run_closed when the checkpoint cannot be read' {
        Mock Read-ParallelAdmissionJsonText { throw [System.IO.FileNotFoundException]::new('Could not find file state.json.') }

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'guard-run' -CheckpointPath 'state.json' -ManifestMode 'open'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'PARALLEL_ADMISSION_REJECTED: run_closed: checkpoint state.json could not be read*'
        $outcome.Stderr | Should -Not -Match 'PARALLEL_MUTATION_REJECTED'
    }
}

Describe 'assess' {
    BeforeEach {
        $script:GitResponse = Get-AssessGitResponse
        Mock Invoke-ParallelAdmissionGit {
            param([string[]] $GitArgs)
            $key = $GitArgs -join ' '
            if ($script:GitResponse.ContainsKey($key)) { return [pscustomobject]@{ ExitCode = 0; Output = [string[]]@($script:GitResponse[$key]) } }
            return [pscustomobject]@{ ExitCode = 1; Output = [string[]]@() }
        }
        $script:PlannerText = '{"items": [{"feature_folder": "docs/features/active/sample-1101", "complexity_band": "C3", "blast_radius": {"paths": ["scripts/powershell/**"]}}]}'
        Mock Read-ParallelAdmissionJsonText { return $script:PlannerText }
        $script:AssessArguments = @{ Subcommand = 'assess'; Branch = $script:AssessBranch; FeatureFolder = $script:AssessFolder }
    }

    It 'prints exactly the assess keys' {
        $outcome = Invoke-ParallelAdmissionCli @script:AssessArguments

        $outcome.ExitCode | Should -Be 0
        $json = ConvertFrom-EmittedJson $outcome.Stdout
        @($json.EnumerateObject() | ForEach-Object { $_.Name }) | Should -Be @('band', 'base_commit', 'next_action', 'plan_hash', 'plan_path', 'preparation_status', 'research_path', 'resume_stage', 'spec_path', 'staleness')
        @($json.GetProperty('staleness').EnumerateObject() | ForEach-Object { $_.Name }) | Should -Be @('changed_cited_paths', 'removed_cited_paths', 'verdict')
        @($json.GetProperty('band').EnumerateObject() | ForEach-Object { $_.Name }) | Should -Be @('source', 'value')
    }

    It 'admits a cleared and fresh item with admit_prepared' {
        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('preparation_status').GetString() | Should -Be 'cleared'
        $json.GetProperty('staleness').GetProperty('verdict').GetString() | Should -Be 'fresh'
        $json.GetProperty('next_action').GetString() | Should -Be 'admit_prepared'
        $json.GetProperty('resume_stage').ValueKind | Should -Be ([System.Text.Json.JsonValueKind]::Null)
        $json.GetProperty('plan_path').GetString() | Should -Be $script:AssessPlan
    }

    It 'records the plan blob hash printed by rev-parse' {
        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('plan_hash').GetString() | Should -Be 'abc123'
        Should -Invoke Invoke-ParallelAdmissionGit -ParameterFilter { ($GitArgs -join ' ') -eq "rev-parse $($script:AssessBranch):$($script:AssessPlan)" } -Times 1 -Exactly
    }

    It 'falls back to the merge base when no receipt records a base commit' {
        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('base_commit').GetString() | Should -Be 'base000'
    }

    It 'takes the base commit from the newest preparation receipt' {
        $receipt = '{"schema_version": 1, "stage": "cleared", "plan_hash": "abc123", "base_commit": "receipt999", "preflight_status": "PREFLIGHT: ALL CLEAR", "recorded_at": "2026-11-02T11-00"}'
        $script:GitResponse = Get-AssessGitResponse -Receipt $receipt

        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('base_commit').GetString() | Should -Be 'receipt999'
        $json.GetProperty('next_action').GetString() | Should -Be 'admit_prepared'
        Should -Invoke Invoke-ParallelAdmissionGit -ParameterFilter { ($GitArgs -join ' ') -eq 'merge-base origin/main origin/feature/sample-1101' } -Times 0 -Exactly
    }

    It 'resumes at preflight when the receipt plan hash differs from the current blob hash' {
        $receipt = '{"stage": "cleared", "plan_hash": "old999", "base_commit": "receipt999", "preflight_status": "PREFLIGHT: ALL CLEAR"}'
        $script:GitResponse = Get-AssessGitResponse -Receipt $receipt

        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('preparation_status').GetString() | Should -Be 'plan'
        $json.GetProperty('resume_stage').GetString() | Should -Be 'preflight'
    }

    It 'resumes a stale item at preflight with the changed cited paths' {
        $script:GitResponse = Get-AssessGitResponse -Changed @('.claude/hooks/sample-hook.ps1', 'README.md')

        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('staleness').GetProperty('verdict').GetString() | Should -Be 'stale'
        @($json.GetProperty('staleness').GetProperty('changed_cited_paths').EnumerateArray() | ForEach-Object { $_.GetString() }) | Should -Be @('.claude/hooks/sample-hook.ps1')
        $json.GetProperty('next_action').GetString() | Should -Be 'resume_preparation'
        $json.GetProperty('resume_stage').GetString() | Should -Be 'preflight'
    }

    It 'resumes at plan when a cited path was removed on main' {
        $script:GitResponse = Get-AssessGitResponse -Changed @('.claude/hooks/sample-hook.ps1') -AbsentOnMain @('.claude/hooks/sample-hook.ps1')

        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('staleness').GetProperty('verdict').GetString() | Should -Be 'premise_falsified'
        $json.GetProperty('resume_stage').GetString() | Should -Be 'plan'
    }

    It 'resumes a half-prepared item at plan' {
        $script:GitResponse = Get-AssessGitResponse -Omit @($script:AssessPlan, "$($script:AssessFolder)/evidence/other/preflight-fixes.2026-11-02T10-00.md")

        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('preparation_status').GetString() | Should -Be 'spec'
        $json.GetProperty('staleness').GetProperty('verdict').ValueKind | Should -Be ([System.Text.Json.JsonValueKind]::Null)
        $json.GetProperty('next_action').GetString() | Should -Be 'resume_preparation'
        $json.GetProperty('resume_stage').GetString() | Should -Be 'plan'
    }

    It 'sends an unprepared item to full_preparation' {
        $everyFile = (Get-AssessGitResponse)["ls-tree -r --name-only $($script:AssessBranch) -- $($script:AssessFolder)"]
        $script:GitResponse = Get-AssessGitResponse -Omit $everyFile

        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('preparation_status').GetString() | Should -Be 'none'
        $json.GetProperty('next_action').GetString() | Should -Be 'full_preparation'
    }

    It 'takes the band from the planner checkpoint item' {
        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments -PlannerCheckpointPath 'artifacts/orchestration/parallel-planner-state.json').Stdout

        $json.GetProperty('band').GetProperty('value').GetString() | Should -Be 'C3'
        $json.GetProperty('band').GetProperty('source').GetString() | Should -Be 'planner_checkpoint'
        Should -Invoke Read-ParallelAdmissionJsonText -Times 1 -Exactly
    }

    It 'counts the planner declared radius as cited paths' {
        $script:GitResponse = Get-AssessGitResponse -Changed @('scripts/powershell/PoshQC/PoshQC.psm1')

        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments -PlannerCheckpointPath 'planner.json').Stdout

        $json.GetProperty('staleness').GetProperty('verdict').GetString() | Should -Be 'stale'
    }

    It 'takes the caller band over the planner checkpoint band' {
        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments -Band 'C1' -PlannerCheckpointPath 'planner.json').Stdout

        $json.GetProperty('band').GetProperty('value').GetString() | Should -Be 'C1'
        $json.GetProperty('band').GetProperty('source').GetString() | Should -Be 'caller'
    }

    It 'requires an assessment when no band source exists' {
        $json = ConvertFrom-EmittedJson (Invoke-ParallelAdmissionCli @script:AssessArguments).Stdout

        $json.GetProperty('band').GetProperty('source').GetString() | Should -Be 'assessment'
    }

    It 'exits 1 with the failure prefix when the branch cannot be listed' {
        $script:GitResponse.Remove("ls-tree -r --name-only $($script:AssessBranch) -- $($script:AssessFolder)")

        $outcome = Invoke-ParallelAdmissionCli @script:AssessArguments

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'parallel admission failed: git ls-tree*'
    }

    It 'fetches origin once before reading the branch' {
        $script:GitCallOrder = [System.Collections.Generic.List[string]]::new()
        Mock Invoke-ParallelAdmissionGit {
            param([string[]] $GitArgs)
            $key = $GitArgs -join ' '
            $script:GitCallOrder.Add($key)
            if ($script:GitResponse.ContainsKey($key)) { return [pscustomobject]@{ ExitCode = 0; Output = [string[]]@($script:GitResponse[$key]) } }
            return [pscustomobject]@{ ExitCode = 1; Output = [string[]]@() }
        }

        $null = Invoke-ParallelAdmissionCli @script:AssessArguments

        Should -Invoke Invoke-ParallelAdmissionGit -ParameterFilter { ($GitArgs -join ' ') -ceq 'fetch --quiet origin' } -Times 1 -Exactly
        $script:GitCallOrder[0] | Should -BeExactly 'fetch --quiet origin'
    }

    It 'surfaces the git stderr line when the branch cannot be listed' {
        $listKey = "ls-tree -r --name-only $($script:AssessBranch) -- $($script:AssessFolder)"
        $script:GitResponse.Remove($listKey)
        Mock Invoke-ParallelAdmissionGit {
            param([string[]] $GitArgs)
            $key = $GitArgs -join ' '
            if ($key -ceq "ls-tree -r --name-only $($script:AssessBranch) -- $($script:AssessFolder)") {
                return [pscustomobject]@{ ExitCode = 128; Output = [string[]]@(); Stderr = [string[]]@("fatal: Not a valid object name $($script:AssessBranch)") }
            }
            if ($script:GitResponse.ContainsKey($key)) { return [pscustomobject]@{ ExitCode = 0; Output = [string[]]@($script:GitResponse[$key]) } }
            return [pscustomobject]@{ ExitCode = 1; Output = [string[]]@() }
        }

        $outcome = Invoke-ParallelAdmissionCli @script:AssessArguments

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeExactly 'parallel admission failed: git ls-tree -r --name-only origin/feature/sample-1101 -- docs/features/active/sample-1101 exited 128: fatal: Not a valid object name origin/feature/sample-1101'
    }

    It 'exits 1 with the failure prefix when the receipt is not a JSON object' {
        $script:GitResponse = Get-AssessGitResponse -Receipt '[1, 2]'

        $outcome = Invoke-ParallelAdmissionCli @script:AssessArguments

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'parallel admission failed: Preparation receipt*must be a JSON object.'
    }
}

Describe 'order-cohorts' {
    BeforeEach {
        Mock Invoke-ParallelAdmissionGit { throw 'order-cohorts runs no git command' }
    }

    It 'lifts the after item and prints the cohorts and the precedence edges' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'order-cohorts' -Cohorts '[[1101, 1102], [1103]]' -Edges '1102:1103' -Precedence '1101:1102'

        $outcome.ExitCode | Should -Be 0
        $json = ConvertFrom-EmittedJson $outcome.Stdout
        @($json.GetProperty('cohorts').EnumerateArray() | ForEach-Object { @($_.EnumerateArray() | ForEach-Object { $_.GetInt64() }) -join ',' }) | Should -Be @('1101', '1103', '1102')
        @($json.GetProperty('precedence_edges').EnumerateArray() | ForEach-Object { $_.GetString() }) | Should -Be @('1101:1102')
    }

    It 'accepts cohort objects and keeps a pinned item in place' {
        $cohorts = '{"cohorts": [{"index": 0, "item_keys": [1101, 1102]}]}'

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'order-cohorts' -Cohorts $cohorts -Precedence '1101:1102' -Pinned '1102' -Floor '0'

        $outcome.ExitCode | Should -Be 0
        $json = ConvertFrom-EmittedJson $outcome.Stdout
        $json.GetProperty('cohorts').GetArrayLength() | Should -Be 1
    }

    It 'rejects precedence_cycle' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'order-cohorts' -Cohorts '[[1101], [1102]]' -Precedence '1101:1102 1102:1101'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'PARALLEL_ADMISSION_REJECTED: precedence_cycle: *'
    }

    It 'rejects precedence_unknown_item' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'order-cohorts' -Cohorts '[[1101], [1102]]' -Precedence '1101:4242'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'PARALLEL_ADMISSION_REJECTED: precedence_unknown_item: *4242*'
    }

    It 'exits 2 on a malformed <Name> token' -ForEach @(
        @{ Name = 'Edges'; Arguments = @{ Edges = '1101-1102' } }
        @{ Name = 'Precedence'; Arguments = @{ Precedence = 'a:b' } }
        @{ Name = 'Pinned'; Arguments = @{ Pinned = 'x' } }
    ) {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'order-cohorts' -Cohorts '[[1101]]' @Arguments

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -BeLike "$($script:UsagePrefix)-$Name entries must be*"
    }

    It 'exits 1 with the failure prefix when the cohorts are not a table' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'order-cohorts' -Cohorts '"text"'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'parallel admission failed: -Cohorts must be*'
    }
}

Describe 'test-cohorts' {
    BeforeEach {
        Mock Invoke-ParallelAdmissionGit { throw 'test-cohorts runs no git command' }
        $script:CohortCheckpointText = @'
{"recolor_generation": 1,
 "items": [{"issue_num": 1101, "state": "scheduled", "merge_status": "not_started"}, {"issue_num": 1102, "state": "scheduled"}],
 "cohorts": [{"index": 0, "generation": 1, "item_keys": [1101]}, {"index": 1, "generation": 1, "item_keys": [1102]}],
 "precedence": [{"before": 1101, "after": 1102, "source": "operator", "recorded_at": "2026-11-03T10-00"}]}
'@
        Mock Read-ParallelAdmissionJsonText { return $script:CohortCheckpointText }
    }

    It 'exits 0 when the table honors every active precedence entry' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-cohorts' -CheckpointPath 'state.json'

        $outcome.ExitCode | Should -Be 0
        $json = ConvertFrom-EmittedJson $outcome.Stdout
        $json.GetProperty('result').GetString() | Should -Be 'satisfied'
        $json.GetProperty('active_precedence')[0].GetProperty('before').GetInt64() | Should -Be 1101
    }

    It 'rejects precedence_violated when the after item shares the before item cohort' {
        $script:CohortCheckpointText = $script:CohortCheckpointText.Replace('"item_keys": [1101]}, {"index": 1, "generation": 1, "item_keys": [1102]}', '"item_keys": [1101, 1102]}')

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-cohorts' -CheckpointPath 'state.json'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -Be 'PARALLEL_ADMISSION_REJECTED: precedence_violated: item 1102 in cohort 0 must follow item 1101 in cohort 0'
    }

    It 'rejects precedence_unknown_item for an entry that names no item' {
        $script:CohortCheckpointText = $script:CohortCheckpointText.Replace('"after": 1102', '"after": 4242')

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-cohorts' -CheckpointPath 'state.json'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'PARALLEL_ADMISSION_REJECTED: precedence_unknown_item: *'
    }

    It 'exits 1 with the failure prefix when the checkpoint is not an object' {
        $script:CohortCheckpointText = '[]'

        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'test-cohorts' -CheckpointPath 'state.json'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'parallel admission failed: Parallel checkpoint at state.json must be a JSON object.'
    }
}

Describe 'record' {
    BeforeEach {
        Mock Invoke-ParallelAdmissionGit { throw 'record runs no git command' }
        $script:RecordEntry = '{"edges": [{"a": 1101, "b": 1103, "reason": "path_overlap", "cost": 2}], "tolerated_overlaps": [], "precedence": [{"before": 1101, "after": 1102, "source": "operator", "recorded_at": "2026-11-03T10-00"}], "items": [{"issue_num": 1102, "branch_name": "feature/b-1102", "plan_path": "p2", "plan_hash": "bbbb", "base_commit": "c2", "preparation_status": "cleared", "complexity_band": "C2", "state": "scheduled"}]}'
    }

    It 'prints the scheduling record content and runs no git command' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'record' -RunFolder 'docs/features/parallel/admission-seed' -Entry $script:RecordEntry

        $outcome.ExitCode | Should -Be 0
        $json = ConvertFrom-EmittedJson $outcome.Stdout
        @($json.EnumerateObject() | ForEach-Object { $_.Name }) | Should -Be @('edges', 'items', 'parallel_slug', 'precedence', 'schema_version', 'tolerated_overlaps')
        $json.GetProperty('parallel_slug').GetString() | Should -Be 'admission-seed'
        $json.GetProperty('items')[0].GetProperty('plan_hash').GetString() | Should -Be 'bbbb'
        $outcome.Stdout.Contains("`r") | Should -BeFalse
        Should -Invoke Invoke-ParallelAdmissionGit -Times 0 -Exactly
    }

    It 'exits 2 when the run folder is not under docs/features/parallel' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'record' -RunFolder 'docs/features/active/x' -Entry '{}'

        $outcome.ExitCode | Should -Be 2
        $outcome.Stderr | Should -BeLike "$($script:UsagePrefix)-RunFolder must be docs/features/parallel/<slug>*"
    }

    It 'exits 1 with the failure prefix when the entry is not a JSON object' {
        $outcome = Invoke-ParallelAdmissionCli -Subcommand 'record' -RunFolder 'docs/features/parallel/admission-seed' -Entry '[]'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -Be 'parallel admission failed: -Entry must be a JSON object.'
    }

    It 'recomputes when the committed record is missing on the plan branch' {
        Mock Invoke-ParallelAdmissionGit { return [pscustomobject]@{ ExitCode = 128; Output = [string[]]@() } }

        $reuse = Get-ParallelAdmissionRecordedEdge -Slug 'admission-seed' -IssueNum 1102 -CurrentPlanHash 'bbbb'

        $reuse.action | Should -Be 'recompute'
        $reuse.reason | Should -Be 'record_missing'
    }
}

Describe 'reuse-edges' {
    BeforeEach {
        # An in-memory committed record: 1102 has two edges, 1101 and 1103 share one.
        $script:ReuseRecord = '{"schema_version": 1, "parallel_slug": "admission-seed", "edges": [{"a": 1101, "b": 1102, "reason": "path_overlap"}, {"a": 1101, "b": 1103, "reason": "module_overlap"}, {"a": 1102, "b": 1104, "reason": "path_overlap"}], "tolerated_overlaps": [], "precedence": [], "items": [{"issue_num": 1102, "plan_hash": "c2c2"}]}'
        $script:ReuseShow = @{ ExitCode = 0 }
        Mock Invoke-ParallelAdmissionGit {
            if ($script:ReuseShow.ExitCode -ne 0) { return [pscustomobject]@{ ExitCode = $script:ReuseShow.ExitCode; Output = [string[]]@() } }
            return [pscustomobject]@{ ExitCode = 0; Output = [string[]]@($script:ReuseRecord -split "`n") }
        }
        $script:ReuseArguments = @{ Subcommand = 'reuse-edges'; Slug = 'admission-seed'; IssueNum = '1102' }
    }

    It 'reuses only the edges touching the item for a matching plan hash' {
        $outcome = Invoke-ParallelAdmissionCli @script:ReuseArguments -PlanHash 'c2c2'

        $outcome.ExitCode | Should -Be 0
        $json = ConvertFrom-EmittedJson $outcome.Stdout
        @($json.EnumerateObject() | ForEach-Object { $_.Name }) | Should -Be @('action', 'edges', 'reason')
        $json.GetProperty('action').GetString() | Should -Be 'reuse'
        $json.GetProperty('reason').GetString() | Should -Be 'plan_hash_matches'
        @($json.GetProperty('edges').EnumerateArray() | ForEach-Object { '{0}:{1}' -f $_.GetProperty('a').GetInt64(), $_.GetProperty('b').GetInt64() }) | Should -Be @('1101:1102', '1102:1104')
        $outcome.Stdout.Contains("`r") | Should -BeFalse
    }

    It 'recomputes with <Reason> when <Case>' -ForEach @(
        @{ Case = 'the plan hash changed'; Arguments = @{ PlanHash = 'ffff' }; ExitCode = 0; Reason = 'plan_hash_changed' }
        @{ Case = 'the item is not listed'; Arguments = @{ PlanHash = 'c2c2'; IssueNum = '4242' }; ExitCode = 0; Reason = 'unknown_item' }
        @{ Case = 'git show exits 128'; Arguments = @{ PlanHash = 'c2c2' }; ExitCode = 128; Reason = 'record_missing' }
    ) {
        $script:ReuseShow.ExitCode = $ExitCode
        $splat = $script:ReuseArguments.Clone()
        foreach ($key in $Arguments.Keys) { $splat[$key] = $Arguments[$key] }

        $outcome = Invoke-ParallelAdmissionCli @splat

        $outcome.ExitCode | Should -Be 0
        $json = ConvertFrom-EmittedJson $outcome.Stdout
        $json.GetProperty('action').GetString() | Should -Be 'recompute'
        $json.GetProperty('reason').GetString() | Should -Be $Reason
        $json.GetProperty('edges').GetArrayLength() | Should -Be 0
    }

    It 'reads the record once by ref from <Expected> and runs no fetch' -ForEach @(
        @{ Arguments = @{}; Expected = 'origin/parallel/admission-seed-plan' }
        @{ Arguments = @{ Ref = 'origin/parallel/other-plan' }; Expected = 'origin/parallel/other-plan' }
    ) {
        $null = Invoke-ParallelAdmissionCli @script:ReuseArguments -PlanHash 'c2c2' @Arguments

        Should -Invoke Invoke-ParallelAdmissionGit -ParameterFilter { ($GitArgs -join ' ') -ceq "show ${Expected}:docs/features/parallel/admission-seed/parallel-scheduling.json" } -Times 1 -Exactly
        Should -Invoke Invoke-ParallelAdmissionGit -Times 1 -Exactly
        Should -Invoke Invoke-ParallelAdmissionGit -ParameterFilter { $GitArgs[0] -ceq 'fetch' } -Times 0 -Exactly
    }

    It 'exits 1 with the failure prefix when the record is not a JSON object' {
        $script:ReuseRecord = '[]'

        $outcome = Invoke-ParallelAdmissionCli @script:ReuseArguments -PlanHash 'c2c2'

        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'parallel admission failed: Scheduling record*'
        $outcome.Stdout | Should -BeNullOrEmpty
    }
}
