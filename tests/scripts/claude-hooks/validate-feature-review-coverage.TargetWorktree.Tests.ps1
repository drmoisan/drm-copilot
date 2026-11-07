#Requires -Version 7.0
<#
.SYNOPSIS
    Item-worktree resolution of the review artifacts, the PR context summary, the root CLAUDE.md,
    and the coverage reports in .claude/hooks/validate-feature-review-coverage.ps1 (issue #1105).

.DESCRIPTION
    The delegation prompt comes from an in-memory ReadTranscriptHead seam, the registered worktrees
    from an in-memory WorktreeListInvoker seam, and git output from an in-memory GitInvoker seam.
    File content goes through a Pester mock of Get-ArtifactFileContent over an in-memory table and
    report times through a mock of Get-FeatureReviewReportLastWriteUtc, so no test reads or creates
    a file. Fixture roots are /-rooted forward-slash paths.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-feature-review-coverage.ps1')
    $script:RealGetArtifactFileContent = ${function:Get-ArtifactFileContent}
    $script:RealGetChangedLanguageSet = ${function:Get-ChangedLanguageSet}
    Mock Get-ArtifactFileContent { $null }
    Mock Get-ChangedLanguageSet { $null }
    Mock Get-JacocoRepoCoverage { $null }
    Mock Get-LcovRepoCoverage { $null }

    $script:SessionRoot = '/synthetic-worktrees/main'
    $script:ItemRoot = '/synthetic-worktrees/main/.claude/worktrees/bug-1105'
    $script:Folder = 'docs/features/active/sample'
    $script:Stamp = '2026-11-07T15-00'
    $script:Policy = "$script:Folder/policy-audit.$script:Stamp.md"
    $script:Code = "$script:Folder/code-review.$script:Stamp.md"
    $script:Feature = "$script:Folder/feature-audit.$script:Stamp.md"
    $script:Remediation = "$script:Folder/remediation-inputs.$script:Stamp.md"
    $script:Report = 'artifacts/pester/powershell-coverage.xml'
    $script:CommitSeconds = 1762525200L
    $script:CommitTime = [DateTimeOffset]::FromUnixTimeSeconds($script:CommitSeconds).UtcDateTime
    $script:Identity = "Canonical issue number for this feature is 1105.`nbranch: bug/sample-1105"
    $porcelainText = @(
        'worktree /synthetic-worktrees/main', 'branch refs/heads/main', '',
        'worktree /synthetic-worktrees/main/.claude/worktrees/bug-1105', 'branch refs/heads/bug/sample-1105', ''
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

    function Get-ReviewTable {
        # Builds an artifact table holding the four review artifacts beneath the given prefix.
        param([string] $Prefix, [string] $PolicyText = 'Policy audit body.')
        return @{
            "$Prefix$script:Policy"      = $PolicyText
            "$Prefix$script:Code"        = 'code review'
            "$Prefix$script:Feature"     = 'feature audit'
            "$Prefix$script:Remediation" = 'remediation inputs'
        }
    }

    function Invoke-CoverageCase {
        # Runs the hook entry function with an envelope advertising the given review paths.
        param([string] $Prefix = '', [string] $Prompt = $script:Identity, [switch] $StopHookActive, [scriptblock] $CheckpointIssueReader)
        $output = "Review complete.`npolicy-audit-path: $Prefix$script:Policy`ncode-review-path: $Prefix$script:Code`nfeature-audit-path: $Prefix$script:Feature`nremediation-inputs-path: $Prefix$script:Remediation"
        $raw = [ordered]@{
            session_id = 'tw-1105'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = [bool] $StopHookActive
            agent_transcript_path = 'transcripts/subagents/agent-1105.jsonl'; last_assistant_message = $output
        } | ConvertTo-Json -Compress
        $arguments = @{ InputText = $raw; SessionRoot = $script:SessionRoot; ReadTranscriptHead = (Get-TranscriptReader -Prompt $Prompt); WorktreeListInvoker = $script:ListInvoker; GitInvoker = $script:GitInvoker }
        if ($null -ne $CheckpointIssueReader) { $arguments['CheckpointIssueReader'] = $CheckpointIssueReader }
        return Invoke-FeatureReviewCoverageValidation @arguments
    }
}

Describe 'validate-feature-review-coverage review artifacts target worktree (issue #1105)' {
    BeforeAll {
        Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
    }

    BeforeEach {
        Mock Get-FeatureReviewReportLastWriteUtc { param([string] $Path) if ($Path -eq "$script:ItemRoot/artifacts/pr_context.summary.txt") { $script:CommitTime } else { $null } }
    }

    It 'finds item-only policy-audit, code-review, feature-audit, and remediation-inputs artifacts' {
        # Arrange
        $table = Get-ReviewTable -Prefix "$script:ItemRoot/"
        $table["$script:ItemRoot/artifacts/pr_context.summary.txt"] = 'no changed files'
        Set-ArtifactTable -File $table

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-ArtifactFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq "$script:ItemRoot/$script:Remediation" }
        Should -Invoke Get-ArtifactFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq "$script:ItemRoot/$script:Policy" }
    }

    It 'blocks main-only artifacts with the probed item locations and resolver source without reading the main checkout' {
        # Arrange
        Set-ArtifactTable -File (Get-ReviewTable -Prefix '')

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*policy-audit-path '$script:Policy' was advertised for the policy audit artifact but no file exists at that location; Probed location: '$script:ItemRoot/$script:Policy' (item worktree resolved by DelegationPrompt)*"
        $result.Message | Should -BeLike "*code-review-path*Probed location: '$script:ItemRoot/$script:Code'*"
        $result.Message | Should -BeLike "*feature-audit-path*Probed location: '$script:ItemRoot/$script:Feature'*"
        Should -Invoke Get-ArtifactFileContent -Times 0 -Exactly -ParameterFilter { $Path -notlike "$script:ItemRoot/*" }
    }

    It 'blocks a main-only remediation-inputs artifact with the probed item location' {
        # Arrange
        $table = Get-ReviewTable -Prefix "$script:ItemRoot/"
        $table.Remove("$script:ItemRoot/$script:Remediation")
        $table[$script:Remediation] = 'main remediation inputs'
        Set-ArtifactTable -File $table

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*remediation-inputs-path '$script:Remediation' was advertised but no file exists at that location; Probed location: '$script:ItemRoot/$script:Remediation'*"
        Should -Invoke Get-ArtifactFileContent -Times 0 -Exactly -ParameterFilter { $Path -eq $script:Remediation }
    }

    It 'reads only the item copies when both checkouts hold the review artifacts' {
        # Arrange
        $table = Get-ReviewTable -Prefix "$script:ItemRoot/"
        foreach ($entry in @((Get-ReviewTable -Prefix '').GetEnumerator())) { $table[$entry.Key] = $entry.Value }
        $table["$script:ItemRoot/artifacts/pr_context.summary.txt"] = 'no changed files'
        Set-ArtifactTable -File $table

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-ArtifactFileContent -Times 0 -Exactly -ParameterFilter { $Path -like 'docs/*' }
    }

    It 'accepts absolute artifact paths inside the item worktree after conversion' {
        # Arrange
        $table = Get-ReviewTable -Prefix "$script:ItemRoot/"
        $table["$script:ItemRoot/artifacts/pr_context.summary.txt"] = 'no changed files'
        Set-ArtifactTable -File $table

        # Act
        $result = Invoke-CoverageCase -Prefix "$script:ItemRoot/" -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'rejects absolute artifact paths outside every registered worktree through the unchanged location rule' {
        # Arrange
        Set-ArtifactTable -File (Get-ReviewTable -Prefix '/elsewhere/')

        # Act
        $result = Invoke-CoverageCase -Prefix '/elsewhere/' -Prompt 'no identity'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*policy-audit-path '/elsewhere/$script:Policy' is outside the required docs/features/active/*"
        Should -Invoke Get-ArtifactFileContent -Times 0 -Exactly -ParameterFilter { $Path -like '/elsewhere/*' }
    }
}

Describe 'validate-feature-review-coverage summary, CLAUDE.md, and reports target worktree (issue #1105)' {
    BeforeAll {
        Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
    }

    BeforeEach {
        Mock Get-JacocoRepoCoverage { 95.0 }
        Mock Get-JacocoBranchCoverage { $null }
    }

    It 'reads the PR context summary, the root CLAUDE.md, and the coverage report only beneath the item root' {
        # Arrange
        $table = Get-ReviewTable -Prefix "$script:ItemRoot/" -PolicyText 'PowerShell pester line coverage PASS'
        $table["$script:ItemRoot/artifacts/pr_context.summary.txt"] = '- .claude/hooks/sample.ps1 (+1/-0)'
        $table['artifacts/pr_context.summary.txt'] = '- src/main-only.py (+1/-0)'
        $table['CLAUDE.md'] = 'main CLAUDE.md'
        Set-ArtifactTable -File $table
        Mock Get-FeatureReviewReportLastWriteUtc { $script:CommitTime }

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke Get-ArtifactFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq 'artifacts/pr_context.summary.txt' -and $Root -eq $script:ItemRoot }
        Should -Invoke Get-ArtifactFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq 'CLAUDE.md' -and $Root -eq $script:ItemRoot }
        Should -Invoke Get-ArtifactFileContent -Times 0 -Exactly -ParameterFilter { [string]::IsNullOrEmpty($Root) -and $Path -in @('artifacts/pr_context.summary.txt', 'CLAUDE.md') }
        Should -Invoke Get-JacocoRepoCoverage -Times 1 -Exactly -ParameterFilter { $Path -eq "$script:ItemRoot/$script:Report" }
    }

    It 'never reads a stale main-checkout report when the item root is resolved and its report is absent' {
        # Arrange
        $table = Get-ReviewTable -Prefix "$script:ItemRoot/" -PolicyText 'PowerShell pester line coverage PASS'
        $table["$script:ItemRoot/artifacts/pr_context.summary.txt"] = '- .claude/hooks/sample.ps1 (+1/-0)'
        Set-ArtifactTable -File $table
        Mock Get-FeatureReviewReportLastWriteUtc { param([string] $Path) if ($Path -eq "$script:ItemRoot/artifacts/pr_context.summary.txt") { $script:CommitTime } elseif ($Path -eq $script:Report) { $script:CommitTime.AddDays(-2) } else { $null } }

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*coverage report '$script:Report' is absent beneath the item worktree '$script:ItemRoot'*"
        Should -Invoke Get-JacocoRepoCoverage -Times 0 -Exactly
        Should -Invoke Get-FeatureReviewReportLastWriteUtc -Times 0 -Exactly -ParameterFilter { $Path -eq $script:Report }
    }

    It 'blocks on a stale item report before any coverage floor is read' {
        # Arrange
        $table = Get-ReviewTable -Prefix "$script:ItemRoot/" -PolicyText 'PowerShell pester line coverage PASS'
        $table["$script:ItemRoot/artifacts/pr_context.summary.txt"] = '- .claude/hooks/sample.ps1 (+1/-0)'
        Set-ArtifactTable -File $table
        Mock Get-FeatureReviewReportLastWriteUtc { param([string] $Path) if ($Path -like '*pr_context.summary.txt') { $script:CommitTime } else { $script:CommitTime.AddHours(-1) } }

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*is stale*'
        Should -Invoke Get-JacocoRepoCoverage -Times 0 -Exactly
    }

    It 'blocks repairably on an absent item PR context summary' {
        # Arrange
        Set-ArtifactTable -File (Get-ReviewTable -Prefix "$script:ItemRoot/")
        Mock Get-FeatureReviewReportLastWriteUtc { $null }

        # Act
        $result = Invoke-CoverageCase

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike "*PR context summary 'artifacts/pr_context.summary.txt' is absent beneath the item worktree*"
        $result.Message | Should -Not -BeLike '*cannot repair*'
    }
}

Describe 'validate-feature-review-coverage unresolved target worktree (issue #1105)' {
    It 'blocks repairably with TARGET_WORKTREE_NOT_DERIVABLE and reads no artifact or report from the session root' {
        # Arrange
        Set-ArtifactTable -File (Get-ReviewTable -Prefix '')
        Mock Get-JacocoRepoCoverage { 95.0 }

        # Act
        $result = Invoke-CoverageCase -Prompt 'branch: bug/unknown-branch'

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*TARGET_WORKTREE_NOT_DERIVABLE*the session root is not read*'
        $result.Message | Should -Not -BeLike '*cannot repair*'
        Should -Invoke Get-ArtifactFileContent -Times 0 -Exactly
        Should -Invoke Get-JacocoRepoCoverage -Times 0 -Exactly
    }

    It 'blocks repairably with TARGET_WORKTREE_AMBIGUOUS and reads no artifact or report from the session root' {
        # Arrange
        Set-ArtifactTable -File (Get-ReviewTable -Prefix '')
        Mock Get-JacocoRepoCoverage { 95.0 }

        # Act
        $result = Invoke-CoverageCase -Prompt "Canonical issue number for this feature is 1105.`nCanonical issue number for this feature is 1106."

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -BeLike '*TARGET_WORKTREE_AMBIGUOUS*'
        Should -Invoke Get-ArtifactFileContent -Times 0 -Exactly
        Should -Invoke Get-JacocoRepoCoverage -Times 0 -Exactly
    }

    It 'gives a not-derivable message that keeps the stem and reason code and never advises absolute paths' {
        # Arrange
        Set-ArtifactTable -File (Get-ReviewTable -Prefix '')

        # Act
        $result = Invoke-CoverageCase -Prompt 'branch: bug/unknown-branch'

        # Assert
        $result.Message | Should -BeLike 'validate-feature-review-coverage:*TARGET_WORKTREE_NOT_DERIVABLE*'
        $result.Message | Should -Not -BeLike '*absolute*'
    }
}

Describe 'validate-feature-review-coverage gate-admitted prompts in a main-checkout session (issue #1105)' {
    It 'passes an issue-line-only prompt whose checkpoint issue reader records the issue for the session root' {
        # Arrange
        Set-ArtifactTable -File (Get-ReviewTable -Prefix '')
        $sessionRoot = $script:SessionRoot
        $issueReader = { param($WorktreeRoot) if ($WorktreeRoot -eq $sessionRoot) { '1105' } else { $null } }.GetNewClosure()

        # Act
        $result = Invoke-CoverageCase -Prompt 'Canonical issue number for this feature is 1105.' -StopHookActive -CheckpointIssueReader $issueReader

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-ArtifactFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:Policy -and [string]::IsNullOrEmpty($Root) }
        Should -Invoke Get-ArtifactFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:Remediation -and [string]::IsNullOrEmpty($Root) }
    }

    It 'passes a prompt whose first branch label names the session branch and whose later label names the item branch' {
        # Arrange
        Set-ArtifactTable -File (Get-ReviewTable -Prefix '')

        # Act
        $result = Invoke-CoverageCase -Prompt "branch: main`nbase branch: bug/sample-1105" -StopHookActive

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-ArtifactFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $script:Policy -and [string]::IsNullOrEmpty($Root) }
        Should -Invoke Get-ArtifactFileContent -Times 0 -Exactly -ParameterFilter { $Path -like "$script:ItemRoot/*" }
    }
}

Describe 'validate-feature-review-coverage metrics root parameter (issue #1105)' {
    It 'joins a report path beneath a non-empty root in the language dispatchers' {
        # Arrange
        Mock Get-LcovRepoCoverage { 90.0 }
        Mock Get-LcovBranchCoverage { 80.0 }

        # Act
        $null = Get-LanguageRepoCoverage -Language 'Python' -Root "$script:ItemRoot/"
        $null = Get-LanguageBranchCoverage -Language 'TypeScript' -Root $script:ItemRoot

        # Assert
        Should -Invoke Get-LcovRepoCoverage -Times 1 -Exactly -ParameterFilter { $Path -eq "$script:ItemRoot/artifacts/python/lcov.info" }
        Should -Invoke Get-LcovBranchCoverage -Times 1 -Exactly -ParameterFilter { $Path -eq "$script:ItemRoot/coverage/lcov.info" }
    }

    It 'joins the path beneath a non-empty root in the artifact reader' {
        # Arrange
        Mock Test-Path { $false }

        # Act
        $file = & $script:RealGetArtifactFileContent -Path 'CLAUDE.md' -Root "$script:ItemRoot\"

        # Assert
        $file.Exists | Should -BeFalse
        Should -Invoke Test-Path -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq "$script:ItemRoot/CLAUDE.md" }
    }

    It 'reads the root CLAUDE.md beneath a non-empty root' {
        # Arrange
        Set-ArtifactTable -File @{ "$script:ItemRoot/CLAUDE.md" = 'item claude' }

        # Act
        $result = Get-FeatureReviewClaudeMdText -Root $script:ItemRoot

        # Assert
        $result.Text | Should -Be 'item claude'
    }
}
