Set-StrictMode -Version Latest

# Contract guard for issue #1167: the atomic-plan-contract copies define the test
# cadence once in `## Test Cadence (Mandatory)`, and every referring surface names
# that section in the narrowest scope that holds its requirement. A sweep fails when
# a harness surface prescribes a full-suite run per task, and byte-identity rows pin
# the edited Copilot files that no other parity test covers. Files are read in
# place with whitespace runs collapsed; the suite writes nothing.

BeforeDiscovery {
    $resources = 'extensions/drm-copilot/resources'
    $anchor = '## Test Cadence (Mandatory)'

    # The removed run-class tokens of issue #1094 and the QA-gate ban; no cadence text may hold them.
    $runClassForbidden = @(
        'targeted Pester', 'targeted Pytest', 'targeted xUnit', 'targeted MSTest', 'targeted tests',
        'run tests after each', 'relevant tests using', 'running tests frequently',
        'smallest applicable subset', 'relevant tests pass', 'repro and regression test',
        'Run the regression to confirm', 'Targeted runs are allowed'
    )
    # The per-task full-suite prescriptions that issue #1167 removed.
    $script:PerTaskSweepToken = @(
        "Each task's toolchain loop",
        'Required toolchain for Python tasks',
        'Required toolchain for PowerShell tasks',
        'Required toolchain for C# tasks',
        'Run required toolchains as specified or implied',
        'If the repo policy requires a toolchain loop',
        'repeat until clean'
    )

    <#
    .SYNOPSIS
        Returns the bundle path of a repository surface.
    .OUTPUTS
        [string] The repository-relative path of its bundle copy.
    #>
    function Get-TcwBundlePath {
        [CmdletBinding()]
        [OutputType([string])]
        param([Parameter(Mandatory = $true)][string] $Path)

        if ($Path.StartsWith('.claude/')) { return "$resources/claude-customizations/$Path" }
        if ($Path.StartsWith('.agents/') -or $Path.StartsWith('.codex/') -or $Path -eq 'AGENTS.md') { return "$resources/codex-and-agents-customizations/$Path" }
        if ($Path.StartsWith('.github/')) { return "$resources/customizations/$Path" }
        if ($Path.StartsWith('docs/features/templates/')) { return "$resources/feature-templates/" + $Path.Substring('docs/features/templates/'.Length) }
        throw "No bundle mapping for '$Path'."
    }

    <#
    .SYNOPSIS
        Returns one check that reads a section, a bullet, or the whole file.
    .OUTPUTS
        [hashtable] The check definition.
    #>
    function Get-TcwCheck {
        [CmdletBinding()]
        [OutputType([hashtable])]
        param(
            [AllowNull()][string] $Heading = $null,
            [AllowNull()][string] $Prefix = $null,
            [string[]] $Required = @(),
            [string[]] $Forbidden = @(),
            [AllowNull()][string] $NextHeading = $null
        )

        return @{ Heading = $Heading; Prefix = $Prefix; Required = $Required; Forbidden = $Forbidden; NextHeading = $NextHeading }
    }

    <#
    .SYNOPSIS
        Returns one wording row per base file and per bundle copy.
    .OUTPUTS
        [System.Object[]] The rows.
    #>
    function Get-TcwRow {
        [CmdletBinding()]
        [OutputType([System.Object[]])]
        param(
            [Parameter(Mandatory = $true)][string] $Group,
            [Parameter(Mandatory = $true)][hashtable[]] $Base,
            [Parameter(Mandatory = $true)][hashtable[]] $Check
        )

        return @(foreach ($entry in $Base) {
                $entryCheck = @($Check)
                if ($entry.ContainsKey('Extra')) { $entryCheck += @($entry.Extra) }
                @{ Id = "$Group-$($entry.Id)"; Path = $entry.Path; Check = $entryCheck }
                if (-not ($entry.ContainsKey('Bundle') -and -not $entry.Bundle)) {
                    @{ Id = "$Group-$($entry.Id)-BUNDLE"; Path = (Get-TcwBundlePath -Path $entry.Path); Check = $entryCheck }
                }
            })
    }

    $fileForbidden = Get-TcwCheck -Forbidden $runClassForbidden
    $contractBase = @(
        @{ Id = 'CLAUDE'; Path = '.claude/skills/atomic-plan-contract/SKILL.md' }
        @{ Id = 'AGENTS'; Path = '.agents/skills/atomic-plan-contract/SKILL.md' }
        @{ Id = 'GITHUB'; Path = '.github/skills/atomic-plan-contract/SKILL.md' }
    )
    $canonicalRequired = @(
        'task check', "the task's test selection", 'mirrored test files', 'imports, dot-sources, or names',
        'A task check is not a gate', 'measures no coverage', "never part of the task's test selection",
        'the rule that produced it', 'append-only', '[phase-gate]', 'after the task ID',
        'between Phase 0 and the final QA phase', 'stages 1 to 6', 'restart from step 1', 'one clean pass',
        'Phase 0 baseline', 'no-SKIPPED rule', 'Integration and golden suites run in CI only',
        'one `Invoke-PoshQCParallelTest` run', 'one `pytest -n auto` run', 'Jest through its normal parallel workers',
        'task-check.P<N>-T<M>.<timestamp>.md', 'phase-gate.P<N>.<timestamp>.md',
        # Issue #1158 (C1): the task's Pester selection runs through the launcher pester suite with -TestPath.
        '-TestPath'
    )
    # Decision D15: the expect-fail phase and the no-change phase provisions.
    $script:CanonicalD15Token = @(
        'expected failures', 'confirmed failing', 'every other test passes',
        'no-change phase', 'changes no tracked file', 'the next gate covers it'
    )
    $script:CanonicalCheck = Get-TcwCheck -Heading $anchor -Required ($canonicalRequired + $script:CanonicalD15Token) -Forbidden ($runClassForbidden + $script:PerTaskSweepToken) -NextHeading '## Final QA Loop (Required for Code/Test Changes)'
    $script:WordingRow = @(
        Get-TcwRow -Group 'CANONICAL' -Base $contractBase -Check @($script:CanonicalCheck)
        Get-TcwRow -Group 'CANONICAL-REF' -Base $contractBase -Check @(
            Get-TcwCheck -Heading '## Final QA Loop (Required for Code/Test Changes)' -Required @($anchor)
            Get-TcwCheck -Heading '## Short-Path Minimal Plan Contract' -Required @($anchor)
        )
    )

    $policyRequired = @($anchor, 'phase-gate and final-QA requirement', 'run in CI', 'from step 1')
    # Finding CR2: the stop condition names the stages the loop runs, not all seven.
    $stopCheck = Get-TcwCheck -Heading '## Mandatory Toolchain Loop' -Required @('every stage it runs') -Forbidden @('all seven stages')
    $script:WordingRow += Get-TcwRow -Group 'POLICY' -Base @(
        @{ Id = 'CLAUDE-RULE'; Path = '.claude/rules/general-code-change.md'; Extra = @($stopCheck) }
        @{ Id = 'AGENTS-SKILL'; Path = '.agents/skills/general-code-change/SKILL.md'; Extra = @($stopCheck) }
        @{ Id = 'AGENTS-MD'; Path = 'AGENTS.md' }
    ) -Check @((Get-TcwCheck -Heading '## Mandatory Toolchain Loop' -Required $policyRequired), $fileForbidden)
    $script:WordingRow += Get-TcwRow -Group 'POLICY' -Base @(
        @{ Id = 'INSTRUCTION'; Path = '.github/instructions/general-code-change.instructions.md' }
    ) -Check @(
        (Get-TcwCheck -Heading '## 8. After Making Changes' -Required $policyRequired)
        (Get-TcwCheck -Heading '## Bugfix Workflow (all languages, defects only)' -Required @($anchor))
        $fileForbidden
    )

    $orchestrateBase = @(
        @{ Id = 'CLAUDE'; Path = '.claude/skills/orchestrate/SKILL.md' }
        @{ Id = 'AGENTS'; Path = '.agents/skills/orchestrate/SKILL.md' }
    )
    $remediationHeading = '## Remediation Loop (R1' + [char] 0x2013 + 'R5)'
    $r3Prefix = '- **R3 ' + [char] 0x2014 + ' Remediation execution:**'
    $script:WordingRow += Get-TcwRow -Group 'REMEDIATION' -Base $orchestrateBase -Check @(
        (Get-TcwCheck -Heading $remediationHeading -Prefix $r3Prefix -Required @($anchor, 'Delegate to') -Forbidden @("Each task's toolchain loop"))
        $fileForbidden
    )
    $script:WordingRow += Get-TcwRow -Group 'DELEGATION' -Base $orchestrateBase -Check @(
        (Get-TcwCheck -Heading '## Delegation Model' -Prefix '- `atomic-executor`' -Required @($anchor))
        $fileForbidden
    )

    $codexSuffix = @('', '-c1', '-c2', '-c3', '-c3-elevated', '-c4')
    $executorCheck = @(
        (Get-TcwCheck -Heading '## Execution Protocol' -Required @($anchor, '[phase-gate]'))
        (Get-TcwCheck -Heading '## Toolchain Commands' -Required @($anchor))
        $fileForbidden
    )
    $copilotExecutorCheck = @(
        (Get-TcwCheck -Heading '## 0. Highest Priority: Repository Policy Compliance (Non-Negotiable)' -Required @($anchor))
        (Get-TcwCheck -Heading '### 3.4 Verification (mandatory before check-off)' -Required @($anchor))
        $fileForbidden
    )
    $script:WordingRow += Get-TcwRow -Group 'EXECUTOR' -Base @(
        @{ Id = 'CLAUDE'; Path = '.claude/agents/atomic-executor.md' }
        foreach ($suffix in $codexSuffix) { @{ Id = "CODEX$($suffix.ToUpperInvariant())"; Path = ".codex/agents/atomic-executor$suffix.toml" } }
    ) -Check $executorCheck
    $script:WordingRow += Get-TcwRow -Group 'EXECUTOR' -Base @(
        @{ Id = 'AGENTS'; Path = '.agents/skills/atomic-executor/SKILL.md' }
    ) -Check @((Get-TcwCheck -Heading '## Execution Rules' -Required @($anchor)), $fileForbidden)
    $script:WordingRow += Get-TcwRow -Group 'EXECUTOR' -Base @(
        @{ Id = 'COPILOT'; Path = '.github/agents/atomic_executor.agent.md' }
        @{ Id = 'COPILOT-PY'; Path = '.github/agents/python-atomic-executor.agent.md'; Extra = @(Get-TcwCheck -Heading '### 7.1 Python policy and toolchain gates' -Required @('Phase-gate and final-QA toolchain')) }
        @{ Id = 'COPILOT-PS'; Path = '.github/agents/powershell-atomic-executor.agent.md'; Extra = @(Get-TcwCheck -Heading '### 7.1 PowerShell policy and toolchain gates' -Required @('Phase-gate and final-QA toolchain')) }
        @{ Id = 'COPILOT-CS'; Path = '.github/agents/csharp-atomic-executor.agent.md'; Extra = @(Get-TcwCheck -Heading '### 7.1 C# policy and toolchain gates' -Required @('Phase-gate and final-QA toolchain')) }
    ) -Check $copilotExecutorCheck

    $plannerRequired = @($anchor, '[phase-gate]', 'between Phase 0 and the final QA phase', 'expected failures', 'no-change phase')
    $script:WordingRow += Get-TcwRow -Group 'PLANNER' -Base @(
        @{ Id = 'CLAUDE'; Path = '.claude/agents/atomic-planner.md' }
    ) -Check @((Get-TcwCheck -Heading '## Plan Structure' -Required $plannerRequired), $fileForbidden)
    $script:WordingRow += Get-TcwRow -Group 'PLANNER' -Base @(
        foreach ($suffix in $codexSuffix) { @{ Id = "CODEX$($suffix.ToUpperInvariant())"; Path = ".codex/agents/atomic-planner$suffix.toml" } }
    ) -Check @((Get-TcwCheck -Heading '## Requirements' -Required $plannerRequired), $fileForbidden)
    $script:WordingRow += Get-TcwRow -Group 'PLANNER' -Base @(
        @{ Id = 'AGENTS'; Path = '.agents/skills/atomic-planner/SKILL.md' }
    ) -Check @((Get-TcwCheck -Heading '## Plan Requirements' -Required $plannerRequired), $fileForbidden)
    $script:WordingRow += Get-TcwRow -Group 'PLANNER' -Base @(
        @{ Id = 'COPILOT'; Path = '.github/agents/atomic_planning.agent.md' }
        @{ Id = 'COPILOT-PY'; Path = '.github/agents/python-atomic-planning.agent.md' }
        @{ Id = 'COPILOT-PS'; Path = '.github/agents/powershell-atomic-planning.agent.md' }
        @{ Id = 'COPILOT-CS'; Path = '.github/agents/csharp-atomic-planning.agent.md' }
    ) -Check @((Get-TcwCheck -Required $plannerRequired), $fileForbidden)

    $script:WordingRow += Get-TcwRow -Group 'RULE' -Base @(
        foreach ($name in 'python', 'powershell', 'typescript', 'csharp', 'shell') { @{ Id = "CLAUDE-$($name.ToUpperInvariant())"; Path = ".claude/rules/$name.md" } }
        foreach ($name in 'python', 'powershell', 'typescript', 'csharp') { @{ Id = "AGENTS-$($name.ToUpperInvariant())"; Path = ".agents/skills/$name/SKILL.md" } }
        @{ Id = 'CLAUDE-CSHARP-LEGACY'; Path = "$resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md"; Bundle = $false }
        @{ Id = 'AGENTS-CSHARP-LEGACY'; Path = "$resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md"; Bundle = $false }
    ) -Check @((Get-TcwCheck -Heading '## Toolchain' -Required @($anchor)), $fileForbidden)

    $script:WordingRow += Get-TcwRow -Group 'QAGATE' -Base @(
        foreach ($name in 'python', 'powershell', 'csharp') {
            @{ Id = "CLAUDE-$($name.ToUpperInvariant())"; Path = ".claude/skills/$name-qa-gate/SKILL.md" }
            @{ Id = "AGENTS-$($name.ToUpperInvariant())"; Path = ".agents/skills/$name-qa-gate/SKILL.md" }
        }
        @{ Id = 'CLAUDE-CSHARP-LEGACY'; Path = "$resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md"; Bundle = $false }
        @{ Id = 'AGENTS-CSHARP-LEGACY'; Path = "$resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md"; Bundle = $false }
    ) -Check @(
        (Get-TcwCheck -Heading '## When to Use This Skill' -Required @($anchor, 'a phase gate or the final QA loop'))
        (Get-TcwCheck -Forbidden ($runClassForbidden + @('planned batch')))
    )

    $promptBase = @(
        @{ Id = 'EXECUTE'; Path = '.github/prompts/execute-hard-lock.prompt.md' }
        @{ Id = 'CODEX-EXECUTE'; Path = '.github/codex/execute-hard-lock.prompt.md' }
        @{ Id = 'CODEX-RESUME'; Path = '.github/codex/resume-hard-lock.prompt.md' }
    )
    $script:WordingRow += Get-TcwRow -Group 'PROMPT' -Base $promptBase -Check @(
        (Get-TcwCheck -Required @($anchor) -Forbidden $runClassForbidden)
    )

    $script:WordingRow += Get-TcwRow -Group 'BRIEF' -Base @(
        @{ Id = 'CLAUDE'; Path = '.claude/skills/execution-environment/SKILL.md' }
        @{ Id = 'AGENTS'; Path = '.agents/skills/execution-environment/SKILL.md' }
        @{ Id = 'GITHUB'; Path = '.github/skills/execution-environment/SKILL.md' }
    ) -Check @(
        (Get-TcwCheck -Heading '## Test Isolation Checks' -Required @('task-check evidence', 'never as a gate result or coverage evidence', $anchor, '-TestPath'))
        (Get-TcwCheck -Heading '## Test Runtime' -Required @('its phase-gate QC loop') -Forbidden @('its full QC loop'))
        (Get-TcwCheck -Heading '## Contract Tests That Pin Mirrored Files' -Required @('test-cadence-wording.Tests.ps1'))
        # Issue #1158 (C1): a task check runs its Pester selection through the launcher pester suite with -TestPath.
        (Get-TcwCheck -Heading '## PowerShell Route and PoshQC MCP Limits' -Required @('-TestPath', 'run-test-suite.sh pester'))
    )

    # Gate layout per template under decision D15: the bug template gates its expect-fail
    # Phase 2 and its fix Phase 3, and its Phase 1 is a no-change phase without a gate.
    $templateLayout = @{
        bug      = @{ GateCount = 2; ExpectFailGate = 1; NoChangePhase = '**Phase 1' }
        feature  = @{ GateCount = 1; ExpectFailGate = 0; NoChangePhase = $null }
        refactor = @{ GateCount = 1; ExpectFailGate = 0; NoChangePhase = $null }
    }
    $script:TemplateRow = @(foreach ($name in 'bug', 'feature', 'refactor') {
            $path = "docs/features/templates/$name/plan.yyyy-MM-ddTHH-mm.md"
            $layout = $templateLayout[$name]
            foreach ($pair in @(@($name.ToUpperInvariant(), $path), @("$($name.ToUpperInvariant())-BUNDLE", (Get-TcwBundlePath -Path $path)))) {
                @{ Id = $pair[0]; Path = $pair[1]; GateCount = $layout.GateCount; ExpectFailGate = $layout.ExpectFailGate; NoChangePhase = $layout.NoChangePhase }
            }
        })

    $script:BundleRow = @(foreach ($entry in @(
                @{ Id = 'INSTRUCTION'; Path = '.github/instructions/general-code-change.instructions.md' }
                @{ Id = 'AGENTS-MD'; Path = 'AGENTS.md' }
            ) + $promptBase) {
            @{ Id = $entry.Id; Path = $entry.Path; Bundle = (Get-TcwBundlePath -Path $entry.Path) }
        })
}

Describe 'Test cadence wording' {
    BeforeAll {
        # Walk up from this file so the suite does not depend on the working directory.
        $script:RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))

        <#
        .SYNOPSIS
            Returns the lines of a repository file.
        .OUTPUTS
            [string[]] The file lines without terminators.
        #>
        function Get-TcwFileLine {
            [CmdletBinding()]
            [OutputType([string[]])]
            param([Parameter(Mandatory = $true)][string] $RelativePath)

            $path = Join-Path -Path $script:RepoRoot -ChildPath $RelativePath
            return [System.IO.File]::ReadAllText($path) -split '\r?\n'
        }

        <#
        .SYNOPSIS
            Returns the body of a named section and the heading line that ends it.
        .OUTPUTS
            [hashtable] Found, Body (the joined body text), and NextHeading.
        #>
        function Get-TcwSection {
            [CmdletBinding()]
            [OutputType([hashtable])]
            param(
                [Parameter(Mandatory = $true)][AllowEmptyString()][string[]] $Line,
                [Parameter(Mandatory = $true)][string] $Heading
            )

            $level = ($Heading -replace '^(#+).*$', '$1').Length
            $endPattern = '^#{1,' + $level + '} '
            $inFence = $false
            $start = -1
            $body = [System.Collections.Generic.List[string]]::new()
            $next = $null
            for ($index = 0; $index -lt $Line.Count; $index++) {
                $text = $Line[$index]
                $isFence = $text -match '^\s*(```|~~~)'
                if ($isFence) { $inFence = -not $inFence }
                if ($start -lt 0) {
                    if (-not $inFence -and -not $isFence -and $text.TrimEnd() -ceq $Heading) { $start = $index }
                    continue
                }
                if (-not $inFence -and -not $isFence -and $text -match $endPattern) {
                    $next = $text.TrimEnd()
                    break
                }
                $body.Add($text)
            }

            return @{ Found = ($start -ge 0); Body = ($body -join "`n"); NextHeading = $next }
        }

        <#
        .SYNOPSIS
            Returns the bullet that begins with a prefix, with its continuation lines.
        .OUTPUTS
            [string] The bullet text, or $null when no line begins with the prefix.
        #>
        function Get-TcwBullet {
            [CmdletBinding()]
            [OutputType([string])]
            param(
                [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Body,
                [Parameter(Mandatory = $true)][string] $Prefix
            )

            $lines = $Body -split '\n'
            $start = -1
            for ($index = 0; $index -lt $lines.Count; $index++) {
                if ($lines[$index].StartsWith($Prefix, [System.StringComparison]::Ordinal)) { $start = $index; break }
            }
            if ($start -lt 0) { return $null }

            $taken = [System.Collections.Generic.List[string]]::new()
            $taken.Add($lines[$start])
            for ($index = $start + 1; $index -lt $lines.Count; $index++) {
                $text = $lines[$index]
                if ($text.StartsWith('- ') -or $text.Trim().Length -eq 0) { break }
                $taken.Add($text)
            }
            return ($taken -join "`n")
        }

        <#
        .SYNOPSIS
            Returns the tokens that a text holds, ignoring case.
        .OUTPUTS
            [System.Object[]] The tokens found in the text.
        #>
        function Get-TcwTokenHit {
            [CmdletBinding()]
            [OutputType([System.Object[]])]
            param(
                [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Content,
                [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]] $SearchToken
            )

            return @($SearchToken | Where-Object { $Content.IndexOf($_, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 })
        }

        <#
        .SYNOPSIS
            Returns a description of every way a file fails one check.
        .OUTPUTS
            [System.Object[]] The problem descriptions; empty when the check holds.
        #>
        function Get-TcwCheckProblem {
            [CmdletBinding()]
            [OutputType([System.Object[]])]
            param(
                [Parameter(Mandatory = $true)][AllowEmptyString()][string[]] $Line,
                [Parameter(Mandatory = $true)][hashtable] $Check
            )

            $scope = 'file'
            $text = $Line -join "`n"
            if ($Check.Heading) {
                $scope = $Check.Heading
                $section = Get-TcwSection -Line $Line -Heading $Check.Heading
                if (-not $section.Found) { return @("missing section '$($Check.Heading)'") }
                if ($Check.NextHeading -and $section.NextHeading -cne $Check.NextHeading) {
                    return @("section '$($Check.Heading)' is followed by '$($section.NextHeading)', not '$($Check.NextHeading)'")
                }
                $text = $section.Body
                if ($Check.Prefix) {
                    $scope = "$($Check.Heading) / $($Check.Prefix)"
                    $text = Get-TcwBullet -Body $section.Body -Prefix $Check.Prefix
                    if ($null -eq $text) { return @("missing bullet '$($Check.Prefix)' in '$($Check.Heading)'") }
                }
            }

            $collapsed = $text -replace '\s+', ' '
            $missing = @($Check.Required | Where-Object { -not $collapsed.Contains($_) })
            $held = @(Get-TcwTokenHit -Content $collapsed -SearchToken @($Check.Forbidden))
            return @(
                foreach ($token in $missing) { "missing '$token' in $scope" }
                foreach ($token in $held) { "forbidden '$token' in $scope" }
            )
        }
    }

    It 'TCW-<Id> carries its cadence wording' -ForEach $script:WordingRow {
        # Arrange
        $fileLine = Get-TcwFileLine -RelativePath $Path

        # Act
        $problem = @(foreach ($item in $Check) { Get-TcwCheckProblem -Line $fileLine -Check $item })

        # Assert
        $problem | Should -BeNullOrEmpty -Because "$Path must reference the test cadence in the narrowest scope"
    }

    It 'TCW-CANONICAL-DISCRIMINATES reports each D15 token missing once the D15 bullets are removed' -ForEach @(@{ Check = $script:CanonicalCheck; Token = $script:CanonicalD15Token }) {
        # Arrange: drop the expect-fail and no-change bullets from in-memory lines only.
        $fileLine = @(Get-TcwFileLine -RelativePath '.claude/skills/atomic-plan-contract/SKILL.md' | Where-Object { -not ($_.Contains('no-change phase') -or $_.Contains('expected failures')) })

        # Act
        $problem = @(Get-TcwCheckProblem -Line $fileLine -Check $Check)
        $unreported = @($Token | Where-Object { $problem -notcontains "missing '$_' in $($Check.Heading)" })

        # Assert
        $Token.Count | Should -Be 6 -Because 'decision D15 adds six canonical tokens'
        $unreported | Should -BeNullOrEmpty -Because 'the canonical row must fail when the D15 wording is removed'
    }

    It 'TCW-TEMPLATE-<Id> ends each gated phase with its phase gate' -ForEach $script:TemplateRow {
        # Arrange
        $fileLine = Get-TcwFileLine -RelativePath $Path
        $checkbox = @(for ($index = 0; $index -lt $fileLine.Count; $index++) { if ($fileLine[$index] -match '^\s*- \[[ xX]\] ') { $index } })
        $phaseHead = @(for ($index = 0; $index -lt $fileLine.Count; $index++) { if ($fileLine[$index] -match '^(### Phase|\*\*Phase)') { $index } })

        # Act
        $gate = @($checkbox | Where-Object { $fileLine[$_].Contains('[phase-gate]') })
        $problem = [System.Collections.Generic.List[string]]::new()
        $expectFailGateCount = 0
        foreach ($gateIndex in $gate) {
            $text = $fileLine[$gateIndex]
            $start = @($phaseHead | Where-Object { $_ -lt $gateIndex })
            $start = if ($start.Count -gt 0) { $start[-1] } else { -1 }
            $stop = @($phaseHead | Where-Object { $_ -gt $gateIndex })
            $stop = if ($stop.Count -gt 0) { $stop[0] } else { $fileLine.Count }
            if (-not $text.Contains('phase-gate.P')) { $problem.Add("gate line $gateIndex names no phase-gate evidence") }
            if (-not $text.Contains('## Test Cadence (Mandatory)')) { $problem.Add("gate line $gateIndex names no cadence section") }
            if (@($checkbox | Where-Object { $_ -gt $gateIndex -and $_ -lt $stop }).Count -gt 0) { $problem.Add("gate line $gateIndex is not the last task of its phase") }
            if (@($checkbox | Where-Object { $_ -gt $gateIndex }).Count -eq 0) { $problem.Add("gate line $gateIndex has no later task") }
            if (@($checkbox | Where-Object { $_ -gt $start -and $_ -lt $gateIndex -and $fileLine[$_].Contains('[expect-fail]') }).Count -gt 0) {
                $expectFailGateCount++
                if (-not $text.Contains('expected failures')) { $problem.Add("gate line $gateIndex of an expect-fail phase names no expected failures") }
            }
        }
        $noChangeLine = @(if ($NoChangePhase) { $fileLine | Where-Object { $_.StartsWith($NoChangePhase, [System.StringComparison]::Ordinal) } })

        # Assert
        $gate.Count | Should -Be $GateCount -Because "$Path must hold $GateCount [phase-gate] checkbox lines"
        $problem | Should -BeNullOrEmpty -Because 'each gate must be the last task of its phase and name its evidence'
        $expectFailGateCount | Should -Be $ExpectFailGate -Because 'each gate of an expect-fail phase accepts only the expected failures'
        if ($NoChangePhase) {
            $noChangeLine.Count | Should -Be 1 -Because "$Path must hold one '$NoChangePhase' heading"
            $noChangeLine[0].Contains('no-change phase') | Should -BeTrue -Because 'the ungated preparation phase must be marked as a no-change phase'
        }
    }

    It 'TCW-BUNDLE-<Id> is byte-identical to its bundle copy' -ForEach $script:BundleRow {
        # Arrange
        $baseBytes = [System.IO.File]::ReadAllBytes((Join-Path -Path $script:RepoRoot -ChildPath $Path))
        $bundleBytes = [System.IO.File]::ReadAllBytes((Join-Path -Path $script:RepoRoot -ChildPath $Bundle))

        # Act
        $equal = [System.Linq.Enumerable]::SequenceEqual([byte[]] $baseBytes, [byte[]] $bundleBytes)

        # Assert
        $equal | Should -BeTrue -Because "$Bundle must be a byte copy of $Path"
    }

    Context 'Per-task full-suite sweep' {
        BeforeAll {
            $resourceRoot = 'extensions/drm-copilot/resources'
            $script:SweepRoot = @(
                '.claude/skills', '.claude/agents', '.agents/skills', '.github/agents', '.github/skills', '.github/prompts',
                '.github/codex', '.codex/agents', 'docs/features/templates', '.claude/rules', '.github/instructions', 'AGENTS.md', 'CLAUDE.md', '.github/copilot-instructions.md',
                "$resourceRoot/claude-customizations", "$resourceRoot/codex-and-agents-customizations", "$resourceRoot/customizations",
                "$resourceRoot/templates/policy_audit", "$resourceRoot/feature-templates"
            )

            <#
            .SYNOPSIS
                Returns the repository-relative paths of the swept surface files.
            .OUTPUTS
                [System.Object[]] The relative paths, with forward slashes.
            #>
            function Get-TcwSweepFile {
                [CmdletBinding()]
                [OutputType([System.Object[]])]
                param()

                $files = foreach ($root in $script:SweepRoot) {
                    $path = Join-Path -Path $script:RepoRoot -ChildPath $root
                    if (Test-Path -LiteralPath $path -PathType Leaf) { Get-Item -LiteralPath $path -Force }
                    else { Get-ChildItem -LiteralPath $path -Recurse -File -Force | Where-Object { $_.Extension -in '.md', '.toml' } }
                }
                return @($files | ForEach-Object { [System.IO.Path]::GetRelativePath($script:RepoRoot, $_.FullName).Replace('\', '/') })
            }
        }

        # The token list is discovery data, so each sweep row receives it as row data.
        It 'TCW-SWEEP-SURFACES finds no per-task full-suite prescription in any surface' -ForEach @(@{ SweepToken = $script:PerTaskSweepToken }) {
            # Arrange
            $files = Get-TcwSweepFile

            # Act
            $offending = @(foreach ($file in $files) {
                    $text = [System.IO.File]::ReadAllText((Join-Path -Path $script:RepoRoot -ChildPath $file)) -replace '\s+', ' '
                    $hits = @(Get-TcwTokenHit -Content $text -SearchToken $SweepToken)
                    if ($hits.Count -gt 0) { '{0}: {1}' -f $file, ($hits -join ', ') }
                })

            # Assert
            $files.Count | Should -BeGreaterThan 0 -Because 'the sweep must read the surfaces'
            $offending | Should -BeNullOrEmpty -Because 'a per-task full-suite prescription must not return to a harness surface'
        }

        It 'TCW-SWEEP-HELPER finds each per-task sweep token in in-memory text' -ForEach @(@{ SweepToken = $script:PerTaskSweepToken }) {
            # Arrange
            $tokens = $SweepToken

            # Act
            $missed = @(foreach ($token in $tokens) {
                    $hits = @(Get-TcwTokenHit -Content "A surface that states $($token.ToUpperInvariant()) in prose." -SearchToken $tokens)
                    if ($hits -cnotcontains $token) { $token }
                })

            # Assert
            $tokens.Count | Should -Be 7 -Because 'the plan names 7 per-task sweep tokens'
            $missed | Should -BeNullOrEmpty -Because 'a reintroduced token must fail the sweep'
        }
    }
}
