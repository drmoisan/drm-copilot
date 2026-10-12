#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-feature-review-coverage.ps1 SubagentStop hook.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-feature-review-coverage.ps1'
    . $hookPath
    $script:RealGetChangedLanguageSet = ${function:Get-ChangedLanguageSet}
    $script:RealGetJacocoRepoCoverage = ${function:Get-JacocoRepoCoverage}
    $script:RealGetLcovRepoCoverage = ${function:Get-LcovRepoCoverage}
    Mock Get-ArtifactFileContent { $null }
    if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Mock Get-ChangedLanguageSet { $null } }
    if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-JacocoRepoCoverage { $null } }
    if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-LcovRepoCoverage { $null } }
}

Describe 'validate-feature-review-coverage.ps1' {
    BeforeAll {
        Mock Get-ChangedLanguageSet -MockWith $script:RealGetChangedLanguageSet
        Mock Get-JacocoRepoCoverage -MockWith $script:RealGetJacocoRepoCoverage
        Mock Get-LcovRepoCoverage -MockWith $script:RealGetLcovRepoCoverage
    }

    Context 'required artifact tokens' {
        It 'blocks when required review artifact tokens are missing' {
            $raw = [ordered]@{ session_id = 't1-896'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $false; last_assistant_message = 'Review complete.' } | ConvertTo-Json -Compress

            $result = Invoke-FeatureReviewCoverageValidation -InputText $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'policy-audit-path'
            $result.Message | Should -Match 'code-review-path'
            $result.Message | Should -Match 'feature-audit-path'
        }

        It 'blocks when required review artifacts do not share the same timestamp' {
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                if ($Path -eq 'docs/features/active/foo/policy-audit.2026-05-04T08-00.md') {
                    return @{ Exists = $true; Text = 'Python coverage PASS'; Lines = @('Python coverage PASS') }
                }
                if ($Path -eq 'docs/features/active/foo/code-review.2026-05-04T08-01.md') {
                    return @{ Exists = $true; Text = 'code'; Lines = @('code') }
                }
                if ($Path -eq 'docs/features/active/foo/feature-audit.2026-05-04T08-00.md') {
                    return @{ Exists = $true; Text = 'feature'; Lines = @('feature') }
                }
                if ($Path -eq 'artifacts/pr_context.summary.txt') {
                    return @{ Exists = $false; Text = $null; Lines = @() }
                }
                return @{ Exists = $false; Text = $null; Lines = @() }
            }
            $raw = [ordered]@{
                session_id = 't1-896'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $false; last_assistant_message = @"
policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md
code-review-path: docs/features/active/foo/code-review.2026-05-04T08-01.md
feature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-FeatureReviewCoverageValidation -InputText $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'same feature folder and timestamp'
        }
    }

    Context 'coverage verdict enforcement' {
        It 'blocks when a changed language lacks an explicit PASS or FAIL coverage verdict' {
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                switch ($Path) {
                    'docs/features/active/foo/policy-audit.2026-05-04T08-00.md' {
                        return @{
                            Exists = $true
                            Text   = @"
## Test Coverage Detail
Python coverage artifact present.
"@
                            Lines  = @('## Test Coverage Detail', 'Python coverage artifact present.')
                        }
                    }
                    'docs/features/active/foo/code-review.2026-05-04T08-00.md' {
                        return @{ Exists = $true; Text = 'code'; Lines = @('code') }
                    }
                    'docs/features/active/foo/feature-audit.2026-05-04T08-00.md' {
                        return @{ Exists = $true; Text = 'feature'; Lines = @('feature') }
                    }
                    'artifacts/pr_context.summary.txt' {
                        return @{ Exists = $true; Text = '- src/foo.py (+1/-0)'; Lines = @('- src/foo.py (+1/-0)') }
                    }
                    default {
                        return @{ Exists = $false; Text = $null; Lines = @() }
                    }
                }
            }
            $raw = [ordered]@{
                session_id = 't1-896'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $false; last_assistant_message = @"
policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md
code-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md
feature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-FeatureReviewCoverageValidation -InputText $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'PASS nor a FAIL verdict'
        }

        It 'allows termination when required artifacts exist and no changed languages need coverage validation' {
            Mock -CommandName Get-ArtifactFileContent -MockWith {
                param([string]$Path)
                if ($Path -eq 'artifacts/pr_context.summary.txt') {
                    return @{ Exists = $false; Text = $null; Lines = @() }
                }
                return @{ Exists = $true; Text = 'ok'; Lines = @('ok') }
            }
            $raw = [ordered]@{
                session_id = 't1-896'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $false; last_assistant_message = @"
policy-audit-path: docs/features/active/foo/policy-audit.2026-05-04T08-00.md
code-review-path: docs/features/active/foo/code-review.2026-05-04T08-00.md
feature-audit-path: docs/features/active/foo/feature-audit.2026-05-04T08-00.md
"@
            } | ConvertTo-Json -Compress

            $result = Invoke-FeatureReviewCoverageValidation -InputText $raw

            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }

    Context 'E4 static structure (issue #896)' {
        It 'E4-ST4: <File> defines exactly its assigned functions' -ForEach @(
            @{ File = '.claude/hooks/validate-feature-review-coverage.ps1'; Functions = @('Invoke-FeatureReviewCoverageValidation') }
            @{ File = '.claude/hooks/validate-feature-review-coverage-metrics.ps1'; Functions = @('Get-ArtifactFileContent', 'Get-FeatureReviewClaudeMdText', 'Get-JacocoBranchCoverage', 'Get-JacocoRepoCoverage', 'Get-LanguageBranchCoverage', 'Get-LanguageRepoCoverage', 'Get-LcovBranchCoverage', 'Get-LcovRepoCoverage') }
            @{ File = '.claude/hooks/validate-feature-review-coverage-rules.ps1'; Functions = @('Get-ChangedLanguageSet', 'Get-ReviewArtifactInfo', 'Get-ReviewArtifactPathFromOutput', 'Test-LanguageCoverageRow') }
        ) {
            # Arrange
            $path = Join-Path $PSScriptRoot "../../../$File"
            $tokens = $null
            $parseErrors = $null

            # Act
            $ast = [System.Management.Automation.Language.Parser]::ParseFile([System.IO.Path]::GetFullPath($path), [ref]$tokens, [ref]$parseErrors)
            $defined = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object Name | Sort-Object)

            # Assert
            @($parseErrors).Count | Should -Be 0
            ($defined -join ',') | Should -Be ((@($Functions) | Sort-Object) -join ',') -Because "$File must define exactly its assigned functions"
        }

        It 'E4-ST1: <File> has no legacy transport or exit-1 block path' -ForEach @(
            @{ File = '.claude/hooks/validate-feature-review-coverage.ps1' }
            @{ File = '.claude/hooks/validate-feature-review-coverage-metrics.ps1' }
            @{ File = '.claude/hooks/validate-feature-review-coverage-rules.ps1' }
            @{ File = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1' }
            @{ File = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-metrics.ps1' }
            @{ File = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage-rules.ps1' }
        ) {
            # Arrange: the legacy variable name is built so that this file does not carry it literally.
            $path = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../../$File"))
            $legacyName = 'CLAUDE_' + 'HOOK_INPUT'
            $tokens = $null
            $parseErrors = $null

            # Act
            $text = Get-Content -Raw -LiteralPath $path
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$parseErrors)
            $writeErrors = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq 'Write-Error' }, $true))
            $exitOnes = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.ExitStatementAst] -and $null -ne $node.Pipeline -and $node.Pipeline.Extent.Text -eq '1' }, $true))

            # Assert
            $text.Contains($legacyName) | Should -BeFalse -Because "$File must not read the legacy environment transport"
            $writeErrors.Count | Should -Be 0 -Because "$File must not block through Write-Error"
            $exitOnes.Count | Should -Be 0 -Because "$File must not block with exit 1"
        }

        It 'E4-ST1: <File> dot-sources the E1 helper through the guarded pattern' -ForEach @(
            @{ File = '.claude/hooks/validate-feature-review-coverage.ps1' }
            @{ File = 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1' }
        ) {
            # Arrange
            $path = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../../$File"))
            $guarded = "try { . (Join-Path `$PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord `$_ }"

            # Act
            $text = Get-Content -Raw -LiteralPath $path

            # Assert
            $text.Contains($guarded) | Should -BeTrue -Because "$File must dot-source subagentstop-envelope.ps1 through the guarded pattern"
        }

        It 'E4-ST2: Invoke-FeatureReviewCoverageValidation takes InputText and passes it to the E1 reader' {
            # Arrange
            $path = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-feature-review-coverage.ps1'))

            # Act
            $keys = @((Get-Command Invoke-FeatureReviewCoverageValidation).Parameters.Keys)
            $text = Get-Content -Raw -LiteralPath $path

            # Assert
            $keys | Should -Contain 'InputText'
            $keys | Should -Not -Contain 'RawPayload'
            $keys | Should -Not -Contain 'AssistantText'
            $text.Contains('Read-SubagentStopEnvelope -InputText $InputText') | Should -BeTrue
        }

        It 'E4-ST6: the Issue824 suite declares no Get-ArtifactFileContent mock inside an It block' {
            # Arrange
            $path = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'validate-feature-review-coverage.Issue824.Tests.ps1'))
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$parseErrors)
            $isCommand = { param($node, [string] $Name) $node -is [System.Management.Automation.Language.CommandAst] -and $node.GetCommandName() -eq $Name }

            # Act
            $itMocks = @($ast.FindAll({ param($node) & $isCommand $node 'It' }, $true) | ForEach-Object {
                    $_.FindAll({ param($node) (& $isCommand $node 'Mock') -and @($node.CommandElements | Where-Object { $_.Extent.Text -eq 'Get-ArtifactFileContent' }).Count -gt 0 }, $true)
                })
            $describe = $ast.Find({ param($node) & $isCommand $node 'Describe' }, $true)
            $describeBody = @($describe.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.ScriptBlockExpressionAst] })[0].ScriptBlock
            $beforeAll = $describeBody.Find({ param($node) (& $isCommand $node 'BeforeAll') -and $node.Parent.Parent.Parent -eq $describeBody }, $true)
            $helpers = @($beforeAll.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object Name)

            # Assert
            @($parseErrors).Count | Should -Be 0
            $itMocks.Count | Should -Be 0 -Because 'Get-ArtifactFileContent mocks belong in BeforeEach blocks'
            $helpers | Should -Contain 'Get-ArtifactFileResult'
            $helpers | Should -Contain 'Set-ReviewArtifactMap'
            (Get-Content -Raw -LiteralPath $path).Contains('[scriptblock]::Create') | Should -BeFalse
        }
    }

    Context 'E4-CORPUS (issue #896 corpus gate)' {
        BeforeAll {
            # Reject transformation for SANCTIONED-S1-S2 rule3 rows: drop the Rejected Scope
            # Narrowing heading (S2) and, in each sanctioned PowerShell branch narrowing line,
            # replace every 'branch' word with 'line' (S1).
            $script:ConvertToE4CorpusReject = {
                param([string] $Text, [string] $Language)
                $converted = foreach ($line in ($Text -split "`r?`n")) {
                    if ($line -match '^##\s+Rejected Scope Narrowing\b') { continue }
                    $isS1 = $Language -eq 'PowerShell' -and $line -match '(?i)(PowerShell|pester)' -and $line -match '(?i)(coverage|lcov|line[s]?\s+hit|pester)' -and $line -match '(?i)(informational only|context only|out of plan scope|out of scope|not applicable|\bN/A\b|\bUNVERIFIED\b)' -and $line -match '(?i)\bbranch\b' -and $line -notmatch '(?i)\bline\s+coverage\b'
                    if ($isS1) { $line -replace '(?i)\bbranch\b', 'line' } else { $line }
                }
                return ($converted -join "`n")
            }
        }

        It 'E4-CORPUS-1: <Rule> form 1 is accepted and its true-positive counterpart is rejected' -Tag 'E4-CORPUS' -ForEach @(
            @{ Rule = 'rule1'; Kind = 'Accept' }
            @{ Rule = 'rule1'; Kind = 'Reject' }
        ) {
            # Arrange: FIX-1 exemplar, active-equivalent path of a remediation-handoff audit artifact
            $path = 'docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/code-review.md'
            if ($Kind -eq 'Reject') { $path = $path -replace '\d{4}-\d{2}-\d{2}T\d{2}-\d{2}', 'undated' }

            # Act
            $result = Get-ReviewArtifactInfo -Path $path -Stem 'code-review'

            # Assert
            if ($Kind -eq 'Accept') {
                $result | Should -Not -BeNullOrEmpty
                $result.Timestamp | Should -Match '^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$'
            }
            else {
                $result | Should -BeNullOrEmpty -Because 'an audit folder without a timestamp is not a review artifact location'
            }
        }

        It 'E4-CORPUS-2: <Rule> form 2 is accepted and its true-positive counterpart is rejected' -Tag 'E4-CORPUS' -ForEach @(
            @{ Rule = 'rule3'; Kind = 'Accept' }
            @{ Rule = 'rule3'; Kind = 'Reject' }
        ) {
            # Arrange: FIX-2 exemplar (ExemplarForm FULL) from docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T16-45.md
            $auditText = @'
- `coverage.xml` (regenerated Pester JACOCO artifact, repo root, pre-existing tracked file)
| PowerShell | 4 files | 36 tests | PASS 36 pass, 0 fail | n/a (per-hook) | orch-output 89.0% line; task-researcher 88.1% line | covered by 36 new/updated tests |
**Note:** No C# source files and no TypeScript source files were changed in the branch diff. C# and TypeScript coverage verdicts are N/A because those languages have zero changed files on the branch (acceptable per scope invariant). The repo-root `coverage.xml` is a Pester (PowerShell) JACOCO report, not a C# artifact.
- PowerShell coverage artifact: `artifacts/pester/powershell-coverage.xml` (PRESENT, but scopes other hooks); changed-hook coverage is in repo-root `coverage.xml` (JACOCO): `validate-orchestrator-output` LINE 65/73 = 89.0%; `validate-task-researcher-output` LINE 52/59 = 88.1%.
**Non-negotiable verdict rule:** This audit reports PASS only with numeric baseline and post-change coverage for every language in scope (Python, PowerShell), verified from coverage artifacts.
## Executive Summary
All applicable toolchain stages pass: Black (clean), Ruff (clean), Pyright (clean), Pytest (25 pass), Pester (36 pass), bundle-sync contract tests (13 pass). Mirror parity is satisfied: all 8 changed canonical `.claude` files are byte-identical in both bundled mirrors. Coverage thresholds are met for all changed files in both languages.
- PASS `powershell.md`
- PASS PowerShell: `powershell-code-change` + `powershell-unit-test`
## Rejected Scope Narrowing
## 1. General Unit Test Policy Compliance
| Independence | PASS | Python tests use isolated text fixtures; PowerShell tests dot-source the hook and pass per-test in-memory objects. 25 + 36 tests pass in any order. |
| Fast execution | PASS | Python suite 0.05s; Pester suite 1.51s. |
| Baseline Coverage Documented | PASS | `evidence/baseline/baseline-python.2026-06-16T11-00.md` (validator 85.21% line / 77.42% branch); `evidence/baseline/baseline-pester.2026-06-16T11-00.md`. |
| Comprehensive Coverage | PASS | `_validate_human_interaction` branches: non-object block, non-list requirements, non-object requirement, response-outside-enum, exception-empty-runbook, exception-missing-runbook, well-formed scope_change + runbook-backed exception. PowerShell: six rejection branches plus absent-key and runbook-exists paths. |
- PowerShell: Post-change `validate-orchestrator-output.ps1` 89.0% line (65/73), `validate-task-researcher-output.ps1` 88.1% line (52/59) from repo-root `coverage.xml` JACOCO. Pester reports line/command coverage; a separate branch counter is not emitted by the Pester JACOCO format for these files, so branch coverage is not separately measurable under this toolchain. Line thresholds met. Disposition: PASS. Evidence: `coverage.xml`, `evidence/qa-gates/p7-poshqc-final.2026-06-16T11-00.md`.
## 2. General Code Change Policy Compliance
| Simplicity first | PASS | Validator follows the established helper-plus-error-list pattern; PowerShell hook uses a single linear rejection-order loop. |
## 3. Language-Specific Code Change Policy Compliance
### 3.2 PowerShell (`powershell.md`)
## 4. Language-Specific Unit Test Policy Compliance
| PowerShell Pester 5, injectable seams | PASS | `$FileExistsCheck` and `$ReadFileContent` seams used; no temporary files. 36 tests pass. |
## 5. Test Coverage Detail
- PowerShell `validate-orchestrator-output.ps1`: 65/73 lines (89.0%). PASS.
- PowerShell `validate-task-researcher-output.ps1`: 52/59 lines (88.1%). PASS.
## 6. Test Execution Metrics
| Pester (two changed hooks) | `Invoke-Pester` on the two hook test files | 36 passed, 0 failed | 1.51s |
## 7. Code Quality Checks
## Evidence Location Compliance
## 8. Gaps and Exceptions
- PowerShell branch coverage is not separately measurable: the Pester JACOCO export emits a LINE counter (line/command coverage) but no distinct BRANCH counter for these hook files. Line coverage (89.0% / 88.1%) exceeds the >= 85% threshold; branch coverage cannot be independently asserted under the current PowerShell toolchain. This is a tooling limitation documented in `evidence/qa-gates/p7-coverage-delta.2026-06-16T11-00.md`, not a coverage shortfall. Verdict for PowerShell coverage is PASS on the available metric.
## 9. Summary of Changes
## 10. Compliance Verdict
**PASS.** Both prior remediation findings (F1 file-size, F2 schema reference) are resolved. All applicable toolchain stages pass for every language with changed files. Coverage thresholds are met for all new and modified files in Python and PowerShell. Mirror parity is satisfied. No scope narrowing was attempted. No blocking findings remain.
## Appendix A: Test Inventory
## Appendix B: Toolchain Commands Reference
Invoke-Pester (tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1, validate-task-researcher-output.Tests.ps1)
'@
            if ($Kind -eq 'Reject') { $auditText = & $script:ConvertToE4CorpusReject $auditText 'PowerShell' }

            # Act
            $result = Test-LanguageCoverageRow -AuditText $auditText -Language 'PowerShell' -RepoWidePct $null -BranchPct $null

            # Assert
            if ($Kind -eq 'Accept') {
                [string]$result.Reason | Should -Not -Match 'narrows scope' -Because 'sanctioned narrowing text is accepted'
            }
            else {
                $result.Ok | Should -BeFalse
                [string]$result.Reason | Should -Match 'narrows scope' -Because 'the unsanctioned counterpart is still a scope narrowing'
            }
        }

        It 'E4-CORPUS-3: <Rule> form 3 is accepted and its true-positive counterpart is rejected' -Tag 'E4-CORPUS' -ForEach @(
            @{ Rule = 'rule3'; Kind = 'Accept' }
            @{ Rule = 'rule3'; Kind = 'Reject' }
        ) {
            # Arrange: FIX-3 exemplar (ExemplarForm REDUCED) from docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md
            $auditText = @'
## Rejected Scope Narrowing
The delegating prompt supplied five orientation questions but stated verbatim that they are "Offered as orientation, not as scope limits or conclusions to ratify." It separately directed that "Every language with changed files in the branch diff is in scope for its full toolchain and coverage check. The diff touches Python, TypeScript, PowerShell, JSON, and Markdown," and that the audit must cover "the full branch diff against the merge base, not only the remediation delta." No instruction attempted to narrow the audit to a plan, task, phase, or file subset, and no instruction marked any language's coverage as out of scope, informational only, or not applicable.
## Executive Summary
This is the re-audit of remediation cycle 1. The branch corrects the blast-radius truth table that the Claude push-down publishes into a destination workspace, corrects the exported constant that supplies a destination's payload modules, adds four read-by-mandate exclusions to both committed copies, amends the governing rule with its byte-identical bundled mirror, and adds a three-class key-partition drift gate in Python mirrored in PowerShell and complemented by two TypeScript assertions. The remediation commit `a95ae362` additionally added a directional separator-free invariant in both language mirrors, corrected the Pester byte-equality comparison form, corrected two acceptance-criterion texts, corrected a risk-mitigation sentence, and corrected an evidence artifact's recorded command.
- **R4 is delivered and closes the gap generally for its stated scope, not only for one witness.** Injecting `Directory.Build.props` into the self-hosted `shared_surfaces` now fails the Python case with `assert not ['Directory.Build.props']` and fails the Pester case with `Expected $null or empty, but got 'Directory.Build.props'`. The two assert the same relation, computed the same way, and both were observed failing on the same injected witness in this review.
## 1. General Unit Test Policy Compliance
| **Independence** | PASS | The new Python cases read two committed files at module import and assert over frozensets. No case mutates shared state or depends on another's ordering. The new Pester case reads `$script:CommittedConfig` and `$script:BundledConfig` from the Describe-level `BeforeAll` and accumulates into a locally constructed list. |
| **Baseline Coverage Documented** | PASS | Python baseline 92.60% statements and 85.19% branches in `evidence/baseline/python-pytest-coverage.2026-08-21T22-51.md`. TypeScript baseline 96.66% lines and 90.04% branches in `evidence/baseline/typescript-jest-coverage.2026-08-21T22-52.md`. PowerShell baseline 96.21% lines in `evidence/baseline/powershell-poshqc-test.2026-08-21T23-03.md`. All three were captured in Phase 0 before any edit. |
| **No Coverage Regression** | PASS | The reviewer reran all three coverage commands at branch head `a95ae362`. Python post-change 92.60% statements and 85.19% branches, delta 0.00 and 0.00. TypeScript post-change 96.66% lines and 90.04% branches, delta 0.00 and 0.00. PowerShell post-change 96.21% lines with LINE covered 5792 and missed 228, delta 0.00. |
| **New Code Coverage** | PASS | The only changed production file is `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`, whose lcov record at head reads `LF:468 LH:468`, that is 100.00% lines, and `BRF:48 BRH:46`, that is 95.83% branches. The two new Python modules and the changed PowerShell file are test code and sit outside the coverage denominator by construction. |
- Python: Baseline: 92.60% statements -> Post-change: 92.60% statements. Change: 0.00 points on statements and 0.00 points on branches, branches holding at 85.19%. New/changed-code coverage: 100.00% of changed production lines, of which there are zero. Disposition: PASS. Evidence: `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T02-58.md` and `artifacts/python/coverage.json` regenerated at head.
| **Actionable failure messages** | PASS | The Python directional case names the missing entries, the self-hosted label, and the bundled label. The reviewer observed the rendered message: `config/blast-radius.json separator-free shared_surfaces entries ['Directory.Build.props'] are missing from extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json separator-free shared_surfaces`. The Pester case accumulates into a list so its message names all missing entries rather than the first. |
| **Uniform tier thresholds applied** | PASS | Line coverage >= 85% and branch coverage >= 75% were applied uniformly to Python and TypeScript. PowerShell was held to the line threshold only, per the Pester exemption recorded in `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`. No tier-specific lower threshold was used. |
## 2. General Code Change Policy Compliance
| **Naming conventions** | PASS | `snake_case` Python functions, `SCREAMING_SNAKE_CASE` module constants, `PascalCase` PowerShell variables in the Pester file matching the file's existing style, `camelCase` TypeScript locals. |
| **Docstring coverage** | PASS | Both new Python modules carry module docstrings with Purpose, Responsibilities, Side effects, and Naming sections. Every public function carries an Args, Returns, and where applicable Raises block. |
## 5. Test Coverage Detail
### Directional separator-free invariant (1 pytest case, 1 Pester case, added by the remediation)
Python `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle` computes the separator-free subset of each copy's `shared_surfaces` and asserts `self_hosted - bundled` is empty. The Pester case `requires every separator-free self-hosted shared surface to reach the bundled copy` computes the same two subsets and accumulates every self-hosted entry not in the bundled subset with `-cnotcontains`. The two compute the same relation.
| Perturbation | Python | Pester |
### Three-class key partition (15 pytest cases, 5 Pester cases)
## 6. Test Execution Metrics
| Python full | `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term --cov-report=json:artifacts/python/coverage.json --cov-report=lcov:artifacts/python/lcov.info` | 4077 passed, 5 skipped | 20.60s | 0 |
Test-count deltas against the pre-remediation head: Python 4076 to 4077 and Pester 3110 to 3111, each accounted for by exactly one added case. Skipped-test accounting: the five Python skips are pre-existing `test_parallel_manifest_bash_parity.py` cases that declare no accessor expectation; the nine Pester skips are likewise pre-existing. None is in the changed area.
## 8. Gaps and Exceptions
**G8 - Informational. The two directional mirrors differ in their malformed-key behaviour.** The Python case reads through the `shared_surfaces` accessor, which returns an empty tuple for an absent or non-list key, so a renamed key would make it pass vacuously; the separate non-vacuity floor case is what catches that. The Pester case indexes the hashtable directly, so a renamed key raises rather than passing. Both fail loudly overall, but not in the same way and not through the same case. The Pester file carries no non-vacuity floor of its own.
## 10. Compliance Verdict
| Python line coverage | 92.60% | >= 85% | PASS |
| Python branch coverage | 85.19% | >= 75% | PASS |
## Appendix B: Toolchain Commands Reference
  --cov-report=json:artifacts/python/coverage.json \
  --cov-report=lcov:artifacts/python/lcov.info
'@
            if ($Kind -eq 'Reject') { $auditText = & $script:ConvertToE4CorpusReject $auditText 'Python' }

            # Act
            $result = Test-LanguageCoverageRow -AuditText $auditText -Language 'Python' -RepoWidePct $null -BranchPct $null

            # Assert
            if ($Kind -eq 'Accept') {
                [string]$result.Reason | Should -Not -Match 'narrows scope' -Because 'sanctioned narrowing text is accepted'
            }
            else {
                $result.Ok | Should -BeFalse
                [string]$result.Reason | Should -Match 'narrows scope' -Because 'the unsanctioned counterpart is still a scope narrowing'
            }
        }

        It 'E4-CORPUS-4: <Rule> form 4 is accepted and its true-positive counterpart is rejected' -Tag 'E4-CORPUS' -ForEach @(
            @{ Rule = 'rule3'; Kind = 'Accept' }
            @{ Rule = 'rule3'; Kind = 'Reject' }
        ) {
            # Arrange: FIX-4 exemplar (ExemplarForm REDUCED) from docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md
            $auditText = @'
- TypeScript baseline coverage artifact: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/baseline/typescript-jest-coverage.2026-08-21T22-52.md`
- TypeScript post-change coverage artifact: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T02-58.md`, which regenerated `extensions/drm-copilot/coverage/lcov.info` at branch head `a95ae362`
## Rejected Scope Narrowing
The delegating prompt supplied five orientation questions but stated verbatim that they are "Offered as orientation, not as scope limits or conclusions to ratify." It separately directed that "Every language with changed files in the branch diff is in scope for its full toolchain and coverage check. The diff touches Python, TypeScript, PowerShell, JSON, and Markdown," and that the audit must cover "the full branch diff against the merge base, not only the remediation delta." No instruction attempted to narrow the audit to a plan, task, phase, or file subset, and no instruction marked any language's coverage as out of scope, informational only, or not applicable.
That artifact is an executor-side scoping record for the remediation cycle, not an instruction to this agent, but the audit treats it as non-binding regardless. TypeScript has five changed files in the branch diff against the merge base, so its full toolchain and its coverage figures were rerun by the reviewer at branch head and carry an explicit PASS verdict in section 1.2.1. The audit was performed as a full feature-versus-base review of `fb30a9a5..a95ae362`.
## Executive Summary
This is the re-audit of remediation cycle 1. The branch corrects the blast-radius truth table that the Claude push-down publishes into a destination workspace, corrects the exported constant that supplies a destination's payload modules, adds four read-by-mandate exclusions to both committed copies, amends the governing rule with its byte-identical bundled mirror, and adds a three-class key-partition drift gate in Python mirrored in PowerShell and complemented by two TypeScript assertions. The remediation commit `a95ae362` additionally added a directional separator-free invariant in both language mirrors, corrected the Pester byte-equality comparison form, corrected two acceptance-criterion texts, corrected a risk-mitigation sentence, and corrected an evidence artifact's recorded command.
## 1. General Unit Test Policy Compliance
| **Baseline Coverage Documented** | PASS | Python baseline 92.60% statements and 85.19% branches in `evidence/baseline/python-pytest-coverage.2026-08-21T22-51.md`. TypeScript baseline 96.66% lines and 90.04% branches in `evidence/baseline/typescript-jest-coverage.2026-08-21T22-52.md`. PowerShell baseline 96.21% lines in `evidence/baseline/powershell-poshqc-test.2026-08-21T23-03.md`. All three were captured in Phase 0 before any edit. |
| **No Coverage Regression** | PASS | The reviewer reran all three coverage commands at branch head `a95ae362`. Python post-change 92.60% statements and 85.19% branches, delta 0.00 and 0.00. TypeScript post-change 96.66% lines and 90.04% branches, delta 0.00 and 0.00. PowerShell post-change 96.21% lines with LINE covered 5792 and missed 228, delta 0.00. |
- TypeScript: Baseline: 96.66% lines -> Post-change: 96.66% lines. Change: 0.00 points on lines and 0.00 points on branches, branches holding at 90.04%. New/changed-code coverage: 100.00% lines and 95.83% branches on `claude-blast-radius-derive-core.ts`. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, record `SF:src\lib\push-down\claude-blast-radius-derive-core.ts` reading `LF:468 LH:468 BRF:48 BRH:46`.
| **Uniform tier thresholds applied** | PASS | Line coverage >= 85% and branch coverage >= 75% were applied uniformly to Python and TypeScript. PowerShell was held to the line threshold only, per the Pester exemption recorded in `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`. No tier-specific lower threshold was used. |
## 2. General Code Change Policy Compliance
| **Naming conventions** | PASS | `snake_case` Python functions, `SCREAMING_SNAKE_CASE` module constants, `PascalCase` PowerShell variables in the Pester file matching the file's existing style, `camelCase` TypeScript locals. |
| 8 Unit tests, TypeScript | `npm run test:coverage` | 195 suites, 2656 tests passed | 0 |
## 10. Compliance Verdict
| TypeScript line coverage | 96.66% | >= 85% | PASS |
| TypeScript branch coverage | 90.04% | >= 75% | PASS |
'@
            if ($Kind -eq 'Reject') { $auditText = & $script:ConvertToE4CorpusReject $auditText 'TypeScript' }

            # Act
            $result = Test-LanguageCoverageRow -AuditText $auditText -Language 'TypeScript' -RepoWidePct $null -BranchPct $null

            # Assert
            if ($Kind -eq 'Accept') {
                [string]$result.Reason | Should -Not -Match 'narrows scope' -Because 'sanctioned narrowing text is accepted'
            }
            else {
                $result.Ok | Should -BeFalse
                [string]$result.Reason | Should -Match 'narrows scope' -Because 'the unsanctioned counterpart is still a scope narrowing'
            }
        }
    }
}
