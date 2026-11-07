#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Claude and Codex feature-review narrowing parity (issue #1094, RF-6).

.DESCRIPTION
    Runs one case table against Test-LanguageCoverageRow of the Claude hook
    (.claude/hooks/validate-feature-review-coverage.ps1) and of the Codex hook
    (.codex/hooks/validate-feature-review-coverage.ps1). Each hook is dot-sourced in its own
    child scope, so the two function sets do not shadow each other.

    FRN-ACCEPT pins the lines the policy-audit template prescribes. FRN-REJECT pins every other
    narrowing form, including the no-pre-change-run record outside its three positions.
    FRN-SECTION pins the two sanctioned skips. FRN-PARITY pins the shared definition text of
    Get-CoverageNarrowingLine.

    Determinism: every case is a pure string case. No temporary file, no child process, no
    clock, and no disk read beyond dot-sourcing and parsing the hook files.
#>

BeforeDiscovery {
    # Built from its code point so that this file stays ASCII.
    $checkMark = [char]0x2705

    $surfaces = @(
        @{ Surface = 'Claude'; HookRelativePath = '.claude/hooks/validate-feature-review-coverage.ps1' }
        @{ Surface = 'Codex'; HookRelativePath = '.codex/hooks/validate-feature-review-coverage.ps1' }
    )

    $acceptTable = @(
        @{ Case = 'the PowerShell baseline artifact line'; Language = 'PowerShell'; Line = '- PowerShell baseline coverage artifact: N/A - no pre-change run' }
        @{ Case = 'the TypeScript baseline artifact line'; Language = 'TypeScript'; Line = '- TypeScript baseline coverage artifact: N/A - no pre-change run' }
        @{ Case = 'the PowerShell comparison line'; Language = 'PowerShell'; Line = '- PowerShell: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS. Evidence: artifacts/pester/powershell-coverage.xml.' }
        @{ Case = 'the TypeScript comparison line'; Language = 'TypeScript'; Line = '- TypeScript: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS. Evidence: coverage/lcov.info.' }
        @{ Case = 'the Python comparison line'; Language = 'Python'; Line = '- Python: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS. Evidence: artifacts/python/lcov.info.' }
        @{ Case = 'the Python comparison line with no production file changed'; Language = 'Python'; Line = '- Python: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: N/A - no production file changed. Disposition: PASS. Evidence: artifacts/python/lcov.info.' }
        @{ Case = 'a table row with the record in the fifth cell'; Language = 'PowerShell'; Line = '| Pester | 1 file | 2 tests | ok | N/A - no pre-change run | 90% lines | 90% |' }
        @{ Case = 'a table row quoting the record in backticks'; Language = 'Python'; Line = '| **Comprehensive Coverage** | ' + $checkMark + ' PASS | Both validators are pinned for the `N/A - no pre-change run` record: two Python tests. |' }
    )

    $rejectTable = @(
        @{ Case = 'a bare N/A'; Language = 'Python'; Line = 'Python coverage N/A' }
        @{ Case = 'N/A - out of scope'; Language = 'Python'; Line = 'Python coverage N/A - out of scope' }
        @{ Case = 'a post-change artifact out of scope'; Language = 'PowerShell'; Line = '- PowerShell post-change coverage artifact: N/A - out of scope' }
        @{ Case = 'not applicable'; Language = 'TypeScript'; Line = 'TypeScript coverage PASS (not applicable)' }
        @{ Case = 'UNVERIFIED'; Language = 'Python'; Line = 'Python coverage UNVERIFIED' }
        @{ Case = 'informational only'; Language = 'Python'; Line = 'Python coverage PASS (informational only)' }
        @{ Case = 'Change N/A with a numeric baseline'; Language = 'Python'; Line = '- Python: Baseline: 80% -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS.' }
        @{ Case = 'the record with Post-change N/A'; Language = 'Python'; Line = '- Python: Baseline: N/A - no pre-change run -> Post-change: N/A. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS.' }
        @{ Case = 'the record with Disposition N/A'; Language = 'Python'; Line = '- Python: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: N/A.' }
        @{ Case = 'the record with new code out of scope'; Language = 'Python'; Line = '- Python: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: N/A - out of scope. Disposition: PASS.' }
        @{ Case = 'a lowercase record'; Language = 'Python'; Line = 'python coverage baseline: n/a - no pre-change run' }
        @{ Case = 'the record on a post-change artifact line'; Language = 'Python'; Line = '- Python post-change coverage artifact: N/A - no pre-change run' }
        @{ Case = 'the record at Post-change'; Language = 'Python'; Line = '- Python: Baseline: N/A - no pre-change run -> Post-change: N/A - no pre-change run. Change: N/A. New/changed-code coverage: 90%. Disposition: PASS.' }
        @{ Case = 'no production file changed with a numeric baseline'; Language = 'Python'; Line = '- Python: Baseline: 80% -> Post-change: 90% lines. Change: 10. New/changed-code coverage: N/A - no production file changed. Disposition: PASS.' }
        @{ Case = 'the record on a plain coverage row'; Language = 'Python'; Line = 'Python coverage N/A - no pre-change run' }
        @{ Case = 'the record at Change with a numeric baseline'; Language = 'Python'; Line = '- Python: Baseline: 80% -> Post-change: 90% lines. Change: N/A - no pre-change run. New/changed-code coverage: 90%. Disposition: PASS.' }
        @{ Case = 'the record at new code coverage'; Language = 'Python'; Line = '- Python: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: N/A - no pre-change run. Disposition: PASS.' }
        @{ Case = 'the record at Disposition'; Language = 'Python'; Line = '- Python: Baseline: N/A - no pre-change run -> Post-change: 90% lines. Change: N/A. New/changed-code coverage: 90%. Disposition: N/A - no pre-change run.' }
        @{ Case = 'the record after a Post-change coverage label'; Language = 'Python'; Line = '- Python Post-change coverage: N/A - no pre-change run' }
        @{ Case = 'the record after a bold Post-change label'; Language = 'Python'; Line = '- Python coverage **Post-change:** N/A - no pre-change run' }
        @{ Case = 'a table row with the record in the sixth cell'; Language = 'PowerShell'; Line = '| Pester | 1 file | 2 tests | ok | 90% lines | N/A - no pre-change run | 90% |' }
        @{ Case = 'a bare N/A on a .NET line'; Language = 'CSharp'; Line = '.NET coverage N/A'; PassLine = 'C# coverage PASS' }
    )

    $sectionTable = @(
        @{ Case = 'a narrowing line under the rejected section'; Language = 'Python'; AuditText = "## Rejected Scope Narrowing`nPython coverage N/A`n## Next`nPython coverage PASS" }
        @{ Case = 'a PowerShell branch line'; Language = 'PowerShell'; AuditText = "PowerShell branch coverage N/A`nPowerShell coverage PASS" }
    )

    function Get-SurfaceCaseSet {
        # Crosses the surfaces with one case table, so both hooks run the same rows.
        param(
            [object[]] $Surfaces,
            [object[]] $Table
        )
        foreach ($surface in $Surfaces) {
            foreach ($row in $Table) {
                $passLine = if ($row.ContainsKey('PassLine')) { $row.PassLine } else { "$($row.Language) coverage PASS" }
                $auditText = if ($row.ContainsKey('AuditText')) { $row.AuditText } else { "$($row.Line)`n$passLine" }
                @{ Surface = $surface.Surface; HookRelativePath = $surface.HookRelativePath; Case = $row.Case; Language = $row.Language; AuditText = $auditText }
            }
        }
    }

    $script:AcceptCases = @(Get-SurfaceCaseSet -Surfaces $surfaces -Table $acceptTable)
    $script:RejectCases = @(Get-SurfaceCaseSet -Surfaces $surfaces -Table $rejectTable)
    $script:SectionCases = @(Get-SurfaceCaseSet -Surfaces $surfaces -Table $sectionTable)
}

Describe 'feature-review coverage narrowing parity (issue #1094)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $script:ClaudeHook = Join-Path $script:RepoRoot '.claude/hooks/validate-feature-review-coverage.ps1'
        $script:ClaudeRules = Join-Path $script:RepoRoot '.claude/hooks/validate-feature-review-coverage-rules.ps1'
        $script:CodexHook = Join-Path $script:RepoRoot '.codex/hooks/validate-feature-review-coverage.ps1'

        # Baseline isolation for the closure seams of the two hooks (epic-state discovery guard): no
        # seam reads live repository state. The cases call only the row rule.
        . $script:ClaudeHook
        Mock Get-ArtifactFileContent { $null }
        if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Mock Get-ChangedLanguageSet { $null } }
        if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-JacocoRepoCoverage { $null } }
        if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-LcovRepoCoverage { $null } }

        function Invoke-SurfaceRowRule {
            # Dot-sources one hook in a child scope and returns the row rule result.
            param(
                [string] $HookRelativePath,
                [string] $AuditText,
                [string] $Language
            )
            $hookPath = Join-Path $script:RepoRoot $HookRelativePath
            return (& { param($HookPath, $Text, $RowLanguage) . $HookPath; Test-LanguageCoverageRow -AuditText $Text -Language $RowLanguage } $hookPath $AuditText $Language)
        }

        function Get-NarrowingDefinitionText {
            # Returns the Get-CoverageNarrowingLine definition text with normalized line endings.
            param([string] $Path)
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$parseErrors)
            $definitions = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Get-CoverageNarrowingLine' }, $true))
            if ($definitions.Count -ne 1) { throw "Expected one Get-CoverageNarrowingLine in '$Path', found $($definitions.Count)." }
            return ($definitions[0].Extent.Text -replace "`r`n", "`n")
        }
    }

    It 'FRN-ACCEPT: <Surface> accepts <Case>' -ForEach $script:AcceptCases {
        # Act
        $result = Invoke-SurfaceRowRule -HookRelativePath $HookRelativePath -AuditText $AuditText -Language $Language

        # Assert
        $result.Ok | Should -BeTrue -Because "the $Surface hook reported: $($result.Reason)"
    }

    It 'FRN-REJECT: <Surface> rejects <Case>' -ForEach $script:RejectCases {
        # Act
        $result = Invoke-SurfaceRowRule -HookRelativePath $HookRelativePath -AuditText $AuditText -Language $Language

        # Assert
        $result.Ok | Should -BeFalse -Because "the $Surface hook must report this line as narrowing"
        $result.Reason | Should -Match 'narrows scope'
    }

    It 'FRN-SECTION: <Surface> does not report <Case>' -ForEach $script:SectionCases {
        # Act
        $result = Invoke-SurfaceRowRule -HookRelativePath $HookRelativePath -AuditText $AuditText -Language $Language

        # Assert
        $result.Ok | Should -BeTrue -Because "the $Surface hook reported: $($result.Reason)"
    }

    It 'FRN-PARITY: both hooks hold equal Get-CoverageNarrowingLine definition text' {
        # Act
        $claudeDefinition = Get-NarrowingDefinitionText -Path $script:ClaudeRules
        $codexDefinition = Get-NarrowingDefinitionText -Path $script:CodexHook

        # Assert
        $codexDefinition | Should -BeExactly $claudeDefinition
    }
}
