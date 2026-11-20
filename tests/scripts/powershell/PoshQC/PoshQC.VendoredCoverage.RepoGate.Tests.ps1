Set-StrictMode -Version Latest

# Repository gate for the vendored push-down coverage exception (issue #1049). Reads tracked files only and
# compares whitespace-collapsed text, so a reflowed line does not change the result. Changes no state.

BeforeDiscovery {
    $script:RuleCopies = @(
        'scripts/harness-generation/sources/rules/general-unit-test.md'
        '.claude/rules/general-unit-test.md'
        '.agents/skills/general-unit-test/SKILL.md'
        '.github/instructions/general-unit-test.instructions.md'
        'extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md'
        'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md'
        'extensions/drm-copilot/resources/customizations/.github/instructions/general-unit-test.instructions.md'
    ) | ForEach-Object { @{ RelativePath = $_ } }
    $script:FeatureReviewCopies = @(
        @{ RelativePath = 'scripts/harness-generation/sources/agents/feature-review.md'; SectionCount = 2 }
        @{ RelativePath = '.claude/agents/feature-review.md'; SectionCount = 1 }
        @{ RelativePath = '.codex/agents/feature-review.toml'; SectionCount = 1 }
        @{ RelativePath = 'extensions/drm-copilot/resources/claude-customizations/.claude/agents/feature-review.md'; SectionCount = 1 }
        @{ RelativePath = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml'; SectionCount = 1 }
    )
    $script:BriefCopies = @(
        '.claude/skills/execution-environment/SKILL.md'
        '.agents/skills/execution-environment/SKILL.md'
        'extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md'
        'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md'
    ) | ForEach-Object { @{ RelativePath = $_ } }
    $script:ReadmeCopies = @(
        'scripts/powershell/PoshQC/README.md'
        'extensions/drm-copilot/resources/powershell/PoshQC/README.md'
    ) | ForEach-Object { @{ RelativePath = $_ } }
}

BeforeAll {
    $script:RepoRoot = (Resolve-Path -Path (Join-Path $PSScriptRoot '../../../..')).Path

    # Reads a tracked file and collapses every whitespace run to one space.
    function script:Get-CollapsedText {
        param([string] $RelativePath)
        $text = Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath) -Raw
        return ($text -replace '\s+', ' ')
    }

    # Returns the text of every section headed exactly by Heading, up to the next level-one or level-two heading.
    function script:Get-MarkdownSection {
        param([string] $RelativePath, [string] $Heading)
        $lines = @(Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath))
        $sections = [System.Collections.Generic.List[string]]::new()
        $current = $null
        foreach ($line in $lines) {
            if ($line -match '^#{1,2} ') {
                if ($null -ne $current) { $sections.Add(($current -join "`n")); $current = $null }
                if ($line.TrimEnd() -ceq $Heading) { $current = [System.Collections.Generic.List[string]]::new() }
                continue
            }
            if ($null -ne $current) { $current.Add($line) }
        }
        if ($null -ne $current) { $sections.Add(($current -join "`n")) }
        # Callers wrap the result in @(), so a single section is still read as a one-element array.
        return $sections.ToArray()
    }

    # Returns the paragraph of a section that starts with Prefix, collapsed to single spaces.
    function script:Get-ParagraphStartingWith {
        param([string] $Section, [string] $Prefix)
        foreach ($paragraph in @($Section -split "`n\s*`n")) {
            $trimmed = $paragraph.Trim()
            if ($trimmed.StartsWith($Prefix, [StringComparison]::Ordinal)) { return ($trimmed -replace '\s+', ' ') }
        }
        return ''
    }
}

Describe 'Vendored push-down coverage repository gate (issue #1049)' {
    It 'repository coverage configuration does not declare exempt_unchanged_push_down_files' {
        $config = Get-Content -LiteralPath (Join-Path $script:RepoRoot 'config/poshqc-coverage.json') -Raw | ConvertFrom-Json

        @($config.PSObject.Properties.Name) | Should -Not -Contain 'exempt_unchanged_push_down_files'
    }

    It 'repository root has no .push-down-manifest.json' {
        Test-Path -LiteralPath (Join-Path $script:RepoRoot '.push-down-manifest.json') | Should -BeFalse
    }

    It 'every general-unit-test copy carries the vendored push-down paragraph: <RelativePath>' -ForEach $script:RuleCopies {
        $sections = @(Get-MarkdownSection -RelativePath $RelativePath -Heading '## Coverage Exclusion Policy')
        $sections.Count | Should -Be 1
        $section = $sections[0] -replace '\s+', ' '

        foreach ($literal in @(
                'Vendored push-down files', '.push-down-manifest.json', 'derived by tooling at measurement time',
                'stay in the denominator', 'tested upstream', 'owned and tested', 'recreated duplicate tests',
                'the exception does not apply there', 'vendored-coverage-exemptions.json')) {
            $section.Contains($literal) | Should -BeTrue -Because "the section must contain '$literal'"
        }
    }

    It 'every general-unit-test copy carries both Blocking enforcement clauses: <RelativePath>' -ForEach $script:RuleCopies {
        $section = @(Get-MarkdownSection -RelativePath $RelativePath -Heading '## Coverage Exclusion Policy')[0]
        $enforcement = Get-ParagraphStartingWith -Section $section -Prefix '**Enforcement:**'

        $enforcement.Contains('hand-written') | Should -BeTrue
        $enforcement.Contains('payload_version') | Should -BeTrue
    }

    It 'no general-unit-test copy says not used in this repository: <RelativePath>' -ForEach $script:RuleCopies {
        (Get-CollapsedText -RelativePath $RelativePath).Contains('not used in this repository') | Should -BeFalse
    }

    It 'feature-review coverage step names the exemption report: <RelativePath>' -ForEach $script:FeatureReviewCopies {
        $sections = @(Get-MarkdownSection -RelativePath $RelativePath -Heading '## Coverage Verification')
        $sections.Count | Should -Be $SectionCount

        foreach ($section in $sections) {
            ($section -replace '\s+', ' ').Contains('vendored-coverage-exemptions.json') | Should -BeTrue
        }
    }

    It 'feature-review coverage step carries both Blocking clauses: <RelativePath>' -ForEach $script:FeatureReviewCopies {
        $sections = @(Get-MarkdownSection -RelativePath $RelativePath -Heading '## Coverage Verification')
        $sections.Count | Should -Be $SectionCount

        foreach ($section in $sections) {
            $collapsed = $section -replace '\s+', ' '
            $collapsed.Contains('hand-written') | Should -BeTrue
            $collapsed.Contains('payload_version') | Should -BeTrue
        }
    }

    It 'every brief copy names the vendored push-down exception: <RelativePath>' -ForEach $script:BriefCopies {
        (Get-CollapsedText -RelativePath $RelativePath).Contains('exempt_unchanged_push_down_files') | Should -BeTrue
    }

    It 'README states the ownership policy: <RelativePath>' -ForEach $script:ReadmeCopies {
        $text = Get-CollapsedText -RelativePath $RelativePath

        foreach ($literal in @('tested upstream', 'owned and tested', 'recreated duplicate tests')) {
            $text.Contains($literal) | Should -BeTrue -Because "the README must contain '$literal'"
        }
    }
}
