#Requires -Version 7.0
<#
.SYNOPSIS
    Run-scope grading of coverage reports in .claude/hooks/validate-feature-review-coverage.ps1
    (issue #1228, spec D11).

.DESCRIPTION
    A report whose write time falls inside a selection record of its suite
    (artifacts/test-execution/run-scope.<suite>.json, written by the test-execution launcher) is
    per-file evidence, so the hook applies no repo-wide line or branch floor to it; every other
    report keeps the repo-wide check. The delegation prompt comes from an in-memory
    ReadTranscriptHead seam, the registered worktrees from an in-memory WorktreeListInvoker seam,
    and git output from an in-memory GitInvoker seam. File content goes through a Pester mock of
    Get-ArtifactFileContent over an in-memory table and report times through a mock of
    Get-FeatureReviewReportLastWriteUtc, so no test reads or creates a file. Fixture roots are
    /-rooted forward-slash paths.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-feature-review-coverage.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'
    $script:RealGetChangedLanguageSet = ${function:Get-ChangedLanguageSet}
    $script:RealGetJacocoRepoCoverage = ${function:Get-JacocoRepoCoverage}
    $script:RealGetLcovRepoCoverage = ${function:Get-LcovRepoCoverage}
    Mock Get-ArtifactFileContent { $null }
    Mock Get-ChangedLanguageSet { $null }
    Mock Get-JacocoRepoCoverage { $null }
    Mock Get-LcovRepoCoverage { $null }

    $script:RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1228'
    $script:Folder = 'docs/features/active/sample'
    $script:Stamp = '2026-11-24T12-00'
    $script:Policy = "$script:Folder/policy-audit.$script:Stamp.md"
    $script:Code = "$script:Folder/code-review.$script:Stamp.md"
    $script:Feature = "$script:Folder/feature-audit.$script:Stamp.md"
    $script:PesterReport = 'artifacts/pester/powershell-coverage.xml'
    $script:PythonReport = 'artifacts/python/lcov.info'
    $script:Summary = 'artifacts/pr_context.summary.txt'
    $script:CommitSeconds = 1795521600L
    $script:CommitTime = [DateTimeOffset]::FromUnixTimeSeconds($script:CommitSeconds).UtcDateTime
    $script:ReportTime = $script:CommitTime.AddMinutes(1)
    $script:LowPesterReport = '<report name="selection"><counter type="LINE" missed="47974" covered="1002"/></report>'
    $script:LowPythonReport = "SF:scripts/sample.py`nLF:100`nLH:50`nBRF:100`nBRH:10`nend_of_record"
    $script:SessionIdentity = 'branch: main'
    $script:ItemIdentity = "Canonical issue number for this feature is 1228.`nbranch: bug/sample-1228"
    $porcelainText = @(
        'worktree /synthetic-worktrees/main', 'branch refs/heads/main', '',
        'worktree /synthetic-worktrees/main/.claude/worktrees/bug-1228', 'branch refs/heads/bug/sample-1228', ''
    ) -join "`n"
    $script:ListInvoker = { param($SessionRoot) $null = $SessionRoot; $porcelainText }.GetNewClosure()
    $commitText = "$script:CommitSeconds"
    $script:GitInvoker = { param([string] $Root, [string[]] $Pathspec) $null = $Root, $Pathspec; [pscustomobject]@{ ExitCode = 0; Output = $commitText } }.GetNewClosure()

    function Get-TranscriptReader {
        # Returns a ReadTranscriptHead seam that serves one user entry with the given prompt text.
        param([string] $Prompt)
        $lines = [string[]]@((@{ type = 'user'; message = @{ role = 'user'; content = $Prompt } } | ConvertTo-Json -Compress -Depth 5))
        return { param([string] $Path) $null = $Path; $lines }.GetNewClosure()
    }

    function Set-ArtifactTable {
        # Serves Get-ArtifactFileContent from an in-memory table keyed by the joined path.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([hashtable] $File)
        $table = $File
        Mock Get-ArtifactFileContent {
            param([string] $Path, [string] $Root)
            $key = if ([string]::IsNullOrWhiteSpace($Root)) { $Path } else { "$Root/$Path" }
            if ($table.ContainsKey($key)) { return @{ Exists = $true; Text = $table[$key]; Lines = [string[]]@($table[$key] -split "`n") } }
            return @{ Exists = $false; Text = $null; Lines = @() }
        }.GetNewClosure()
    }

    function Set-ReportTime {
        # Serves last-write times by path through the Get-FeatureReviewReportLastWriteUtc seam.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([hashtable] $Time)
        $times = $Time
        Mock Get-FeatureReviewReportLastWriteUtc { param([string] $Path) if ($times.ContainsKey($Path)) { $times[$Path] } else { $null } }.GetNewClosure()
    }

    function Get-RunScopeText {
        # Returns a run-scope record text whose window runs from Start to End.
        param([string] $Suite = 'pester', [string] $Scope = 'selection', [datetime] $Start = $script:ReportTime.AddMinutes(-2), [datetime] $End = $script:ReportTime.AddSeconds(5))
        return ([ordered]@{ schema_version = 1; suite = $Suite; runner = $Suite; scope = $Scope; started_utc = $Start.ToString('o'); completed_utc = $End.ToString('o') } | ConvertTo-Json -Compress)
    }

    function Get-CaseTable {
        # Builds the artifact table: the three review artifacts, the summary, the report, and an optional record.
        param([string] $Prefix = '', [string] $PolicyText, [string] $SummaryText, [string] $ReportPath, [string] $ReportText, [string] $RecordPath, [string] $RecordText)
        $table = @{
            "$Prefix$script:Policy"  = $PolicyText
            "$Prefix$script:Code"    = 'code review'
            "$Prefix$script:Feature" = 'feature audit'
            "$Prefix$script:Summary" = $SummaryText
            "$Prefix$ReportPath"     = $ReportText
        }
        if ($RecordPath) { $table["$Prefix$RecordPath"] = $RecordText }
        return $table
    }

    function Invoke-CoverageCase {
        # Runs the hook entry function with an envelope advertising the three review paths.
        param([string] $Prompt = $script:SessionIdentity)
        $output = "Review complete.`npolicy-audit-path: $script:Policy`ncode-review-path: $script:Code`nfeature-audit-path: $script:Feature"
        $raw = [ordered]@{
            session_id = 'rs-1228'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $false
            agent_transcript_path = 'transcripts/subagents/agent-1228.jsonl'; last_assistant_message = $output
        } | ConvertTo-Json -Compress
        return Invoke-FeatureReviewCoverageValidation -InputText $raw -SessionRoot $script:SessionRoot -ReadTranscriptHead (Get-TranscriptReader -Prompt $Prompt) -WorktreeListInvoker $script:ListInvoker -GitInvoker $script:GitInvoker
    }
}

Describe 'epic-state baseline isolation (issue #1228)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
}

Describe 'validate-feature-review-coverage run-scope grading in the session root (issue #1228)' {
    BeforeAll {
        # The outermost BeforeAll null-mocks these seams (isolation form); the grading rows use the real readers.
        Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
        Mock Get-JacocoRepoCoverage -MockWith $script:RealGetJacocoRepoCoverage
        Mock Get-LcovRepoCoverage -MockWith $script:RealGetLcovRepoCoverage
    }

    BeforeEach {
        Set-ReportTime -Time @{ $script:PesterReport = $script:ReportTime; $script:PythonReport = $script:ReportTime }
    }

    It 'RSCOPE-HOOK-SELECTION-ACCEPTED: accepts a below-floor PowerShell report covered by a selection record with a PASS row' {
        # Arrange
        Set-ArtifactTable -File (Get-CaseTable -PolicyText 'PowerShell pester line coverage PASS' -SummaryText '- .claude/hooks/sample.ps1 (+1/-0)' -ReportPath $script:PesterReport -ReportText $script:LowPesterReport -RecordPath 'artifacts/test-execution/run-scope.pester.json' -RecordText (Get-RunScopeText))

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-ArtifactFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq 'artifacts/test-execution/run-scope.pester.json' }
        Should -Invoke Get-FeatureReviewReportLastWriteUtc -Times 1 -Exactly -ParameterFilter { $Path -eq $script:PesterReport }
    }

    It 'RSCOPE-HOOK-FULL-REJECTED: rejects the same report when the record scope is full' {
        # Arrange
        Set-ArtifactTable -File (Get-CaseTable -PolicyText 'PowerShell pester line coverage PASS' -SummaryText '- .claude/hooks/sample.ps1 (+1/-0)' -ReportPath $script:PesterReport -ReportText $script:LowPesterReport -RecordPath 'artifacts/test-execution/run-scope.pester.json' -RecordText (Get-RunScopeText -Scope 'full'))

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*repo-wide coverage is 2.05%*'
        $result.Message | Should -BeLike '*no FAIL verdict*'
    }

    It 'RSCOPE-HOOK-NO-RECORD-REJECTED: rejects the report when no run-scope record exists' {
        # Arrange
        Set-ArtifactTable -File (Get-CaseTable -PolicyText 'PowerShell pester line coverage PASS' -SummaryText '- .claude/hooks/sample.ps1 (+1/-0)' -ReportPath $script:PesterReport -ReportText $script:LowPesterReport)

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*repo-wide coverage is 2.05%*no FAIL verdict*'
        Should -Invoke Get-FeatureReviewReportLastWriteUtc -Times 0 -Exactly
    }

    It 'RSCOPE-HOOK-OUTSIDE-WINDOW-REJECTED: rejects the report when it was written after the selection run ended' {
        # Arrange
        $record = Get-RunScopeText -Start $script:ReportTime.AddMinutes(-10) -End $script:ReportTime.AddMinutes(-5)
        Set-ArtifactTable -File (Get-CaseTable -PolicyText 'PowerShell pester line coverage PASS' -SummaryText '- .claude/hooks/sample.ps1 (+1/-0)' -ReportPath $script:PesterReport -ReportText $script:LowPesterReport -RecordPath 'artifacts/test-execution/run-scope.pester.json' -RecordText $record)

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*repo-wide coverage is 2.05%*'
    }

    It 'RSCOPE-HOOK-BRANCH-SELECTION-ACCEPTED: accepts a Python report below the line and branch floors under a covering selection record' {
        # Arrange
        Set-ArtifactTable -File (Get-CaseTable -PolicyText 'Python pytest coverage PASS' -SummaryText '- scripts/sample.py (+1/-0)' -ReportPath $script:PythonReport -ReportText $script:LowPythonReport -RecordPath 'artifacts/test-execution/run-scope.pytest.json' -RecordText (Get-RunScopeText -Suite 'pytest'))

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
    }

    It 'RSCOPE-HOOK-VERDICT-STILL-REQUIRED: blocks a selection report whose audit carries no verdict' {
        # Arrange
        Set-ArtifactTable -File (Get-CaseTable -PolicyText 'PowerShell pester line coverage recorded' -SummaryText '- .claude/hooks/sample.ps1 (+1/-0)' -ReportPath $script:PesterReport -ReportText $script:LowPesterReport -RecordPath 'artifacts/test-execution/run-scope.pester.json' -RecordText (Get-RunScopeText))

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*neither a PASS nor a FAIL*'
    }
}

Describe 'validate-feature-review-coverage run-scope grading in an item worktree (issue #1228)' {
    BeforeAll {
        Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
        Mock Get-JacocoRepoCoverage -MockWith $script:RealGetJacocoRepoCoverage
        Mock Get-LcovRepoCoverage -MockWith $script:RealGetLcovRepoCoverage
    }

    It 'RSCOPE-HOOK-ITEM-ROOT-ACCEPTED: reads the record beneath the item root and accepts the covered selection report' {
        # Arrange
        $table = Get-CaseTable -Prefix "$script:ItemRoot/" -PolicyText 'PowerShell pester line coverage PASS' -SummaryText '- .claude/hooks/sample.ps1 (+1/-0)' -ReportPath $script:PesterReport -ReportText $script:LowPesterReport -RecordPath 'artifacts/test-execution/run-scope.pester.json' -RecordText (Get-RunScopeText)
        Set-ArtifactTable -File $table
        Set-ReportTime -Time @{ "$script:ItemRoot/$script:Summary" = $script:CommitTime; "$script:ItemRoot/$script:PesterReport" = $script:ReportTime }

        # Act
        $result = Invoke-CoverageCase -Prompt $script:ItemIdentity

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-ArtifactFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq 'artifacts/test-execution/run-scope.pester.json' -and $PesterBoundParameters['Root'] -eq $script:ItemRoot }
        Should -Invoke Get-ArtifactFileContent -Times 0 -Exactly -ParameterFilter { $Path -eq 'artifacts/test-execution/run-scope.pester.json' -and [string]::IsNullOrEmpty($PesterBoundParameters['Root']) }
    }

    It 'RSCOPE-HOOK-STALE-SELECTION-REJECTED: blocks a covered selection report older than the newest PowerShell commit' {
        # Arrange
        $staleTime = $script:CommitTime.AddHours(-1)
        $record = Get-RunScopeText -Start $staleTime.AddMinutes(-2) -End $staleTime.AddMinutes(1)
        Set-ArtifactTable -File (Get-CaseTable -Prefix "$script:ItemRoot/" -PolicyText 'PowerShell pester line coverage PASS' -SummaryText '- .claude/hooks/sample.ps1 (+1/-0)' -ReportPath $script:PesterReport -ReportText $script:LowPesterReport -RecordPath 'artifacts/test-execution/run-scope.pester.json' -RecordText $record)
        Set-ReportTime -Time @{ "$script:ItemRoot/$script:Summary" = $script:CommitTime; "$script:ItemRoot/$script:PesterReport" = $staleTime }

        # Act
        $result = Invoke-CoverageCase -Prompt $script:ItemIdentity

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*is stale*'
    }
}

Describe 'run-scope record contract between the launcher and the hook (issue #1228)' {
    It 'RSCOPE-CONTRACT-LAUNCHER-RECORD: a launcher pester selection record makes the hook grade the PowerShell report as selection' {
        # Arrange
        . (Join-Path $script:RepoRoot '.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1')
        $started = [datetime]::new(2026, 11, 24, 12, 0, 0, [System.DateTimeKind]::Utc)
        $text = New-TestSuiteRunScopeRecord -Suite 'pester' -Runner 'pester' -Scope (Get-TestSuiteRunScope -Runner 'pester' -ArgumentList @('-TestPath', 'tests/a.Tests.ps1')) -StartedUtc $started -CompletedUtc $started.AddMinutes(3)

        # Act
        $scope = Get-FeatureReviewCoverageReportScope -Language 'PowerShell' -RecordText $text -GetReportWriteUtc { [datetime]::new(2026, 11, 24, 12, 2, 0, [System.DateTimeKind]::Utc) }

        # Assert
        $scope | Should -BeExactly 'selection'
    }
}

Describe 'run-scope record documentation (issue #1228)' {
    BeforeAll {
        function Get-SectionText {
            # Returns the text from a heading line up to the next heading of the same or a higher level.
            param([Parameter(Mandatory)] [string] $Text, [Parameter(Mandatory)] [string] $Heading)
            $level = ($Heading -split ' ')[0].Length
            $lines = $Text -split "`r?`n"
            $start = [array]::IndexOf($lines, $Heading)
            if ($start -lt 0) { return '' }
            $body = [System.Collections.Generic.List[string]]::new()
            for ($index = $start + 1; $index -lt $lines.Count; $index++) {
                if ($lines[$index] -match '^(#+) ' -and $Matches[1].Length -le $level) { break }
                $body.Add($lines[$index])
            }
            return ($body -join "`n")
        }

        $resources = 'extensions/drm-copilot/resources'
        $script:BriefCopy = @('.claude/skills', '.agents/skills', "$resources/claude-customizations/.claude/skills", "$resources/codex-and-agents-customizations/.agents/skills") | ForEach-Object { "$_/execution-environment/SKILL.md" }
        $script:PolicyCopy = @('.claude/skills', '.agents/skills', "$resources/claude-customizations/.claude/skills", "$resources/codex-and-agents-customizations/.agents/skills") | ForEach-Object { "$_/test-execution-policy/SKILL.md" }
    }

    It 'RSCOPE-DOC-BRIEF: <_> names the run-scope record in its hook and test-execution sections' -ForEach @(
        '.claude/skills/execution-environment/SKILL.md'
        '.agents/skills/execution-environment/SKILL.md'
        'extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md'
        'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md'
    ) {
        # Arrange
        $text = Get-Content -LiteralPath (Join-Path $script:RepoRoot $_) -Raw

        # Act
        $hookSection = Get-SectionText -Text $text -Heading '## Hook Execution Context'
        $policySection = Get-SectionText -Text $text -Heading '## Test Execution Policy'

        # Assert
        $script:BriefCopy | Should -Contain $_
        $hookSection.Contains('run-scope.<suite>.json') | Should -BeTrue -Because "$_ must name the record in ## Hook Execution Context"
        $policySection.Contains('TEST_EXECUTION_RUN_SCOPE_UNWRITTEN:') | Should -BeTrue -Because "$_ must name the write-failure line in ## Test Execution Policy"
    }

    It 'RSCOPE-DOC-POLICY: <_> names the run-scope record in its run-scope subsection' -ForEach @(
        '.claude/skills/test-execution-policy/SKILL.md'
        '.agents/skills/test-execution-policy/SKILL.md'
        'extensions/drm-copilot/resources/claude-customizations/.claude/skills/test-execution-policy/SKILL.md'
        'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/test-execution-policy/SKILL.md'
    ) {
        # Arrange
        $text = Get-Content -LiteralPath (Join-Path $script:RepoRoot $_) -Raw

        # Act
        $section = Get-SectionText -Text $text -Heading '### Run-scope record'

        # Assert
        $script:PolicyCopy | Should -Contain $_
        $section.Contains('run-scope.<suite>.json') | Should -BeTrue -Because "$_ must name the record in ### Run-scope record"
    }
}
