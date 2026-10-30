Set-StrictMode -Version Latest

# Structural test for the four legacy-discovery agent personas (#365, #980).
#
# Issue #980 made `.github/agents/<role>.agent.md` the canonical contract for the four
# constrained specialist roles. The Claude personas under `.claude/agents/` are generated
# from those contracts: the body is copied verbatim and each Copilot tool identifier
# `drmcopilotextension/<operation>` becomes the Claude MCP identifier
# `mcp__drm-copilot__<operation>`. The personas declare no model, because the existing
# resolver selects the exact deployment, and no general Write/Edit/Bash grant.
#
# Following the `test-name-uniqueness.Tests.ps1` precedent, reusable detection helpers are
# defined in `BeforeAll` and exercised against in-memory fixtures before running over the
# real persona files. No temporary files are created.

BeforeAll {
    # Walk up from this file to the directory containing `.claude` so resolution is
    # CWD-independent in the terminal and the VS Code Test Explorer.
    $script:RepoRoot = $PSScriptRoot
    while ($null -ne $script:RepoRoot -and
        -not (Test-Path -Path (Join-Path -Path $script:RepoRoot -ChildPath '.claude') -PathType Container)) {
        $script:RepoRoot = Split-Path -Path $script:RepoRoot -Parent
    }
    if ($null -eq $script:RepoRoot) {
        throw "Unable to resolve the repository root by walking up from '$PSScriptRoot'."
    }
    $script:AgentsDir = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'agents'
    $script:CanonicalDir = Join-Path -Path $script:RepoRoot -ChildPath '.github' -AdditionalChildPath 'agents'
    $script:BundleAgentsDir = Join-Path -Path $script:RepoRoot -ChildPath 'extensions' -AdditionalChildPath `
        'drm-copilot', 'resources', 'claude-customizations', '.claude', 'agents'

    $script:ExpectedSlugs = @(
        'legacy-parity-analyst',
        'runtime-characterization-analyst',
        'requirements-reconciler',
        'migration-coverage-reviewer'
    )

    # The `code-modernization` plugin agent names; the four slugs must be disjoint from this set.
    $script:PluginAgentNames = @(
        'legacy-analyst', 'business-rules-extractor', 'architecture-critic', 'scaffolder',
        'security-auditor', 'test-engineer', 'version-delta-analyst'
    )

    # Banned domain-specific substrings (case-insensitive). Any hit is a Blocking failure.
    $script:BannedSubstrings = @('taskmaster', 'tmw', 'outlook', 'vsto', 'email', 'task-management', 'task management')

    # Required body references per persona: owned artifact kinds, the validated profile, and
    # the shared finalize operation. Confirmed against the canonical `.github/agents` contracts.
    $script:RequiredReferences = @{
        'legacy-parity-analyst'            = @('inventory-snapshot', 'coverage-ledger', 'feature-contract',
            'evidence-reference', 'required-output-manifest', 'validated profile', 'finalize_discovery_agent')
        'runtime-characterization-analyst' = @('runtime-characterization-scenario', 'evidence-reference',
            'evidence-payload', 'required-output-manifest', 'validated profile', 'finalize_discovery_agent')
        'requirements-reconciler'          = @('parity-matrix', 'product-decision', 'acceptance-specification',
            'unspecified-behavior', 'required-output-manifest', 'validated profile', 'finalize_discovery_agent')
        'migration-coverage-reviewer'      = @('coverage-report', 'parity-report', 'completion-report',
            'validation-report', 'required-output-manifest', 'validated profile', 'finalize_discovery_agent')
    }

    # Parity ownership: only the reconciler may list the parity-matrix output row.
    $script:ParityRowPattern = '(?m)^\| parity-matrix \|'

    function Get-FrontmatterBlock {
        <# Extracts the `---`-delimited YAML frontmatter block, or $null when absent. #>
        param([Parameter(Mandatory = $true)][string]$Content)

        if ($Content -match '(?s)\A\s*---\r?\n(.*?)\r?\n---\r?\n') {
            return $Matches[1]
        }
        return $null
    }

    function Get-BodyText {
        <# Returns the document body after the frontmatter, or the whole content when absent. #>
        param([Parameter(Mandatory = $true)][string]$Content)

        if ($Content -match '(?s)\A\s*---\r?\n.*?\r?\n---\r?\n(.*)\z') {
            return $Matches[1]
        }
        return $Content
    }

    function Get-MissingFrontmatterField {
        <# Returns the required frontmatter fields (name, description, tools, memory) that are absent. #>
        param([Parameter(Mandatory = $true)][AllowEmptyString()][AllowNull()][string]$Frontmatter)

        $required = @('name', 'description', 'tools', 'memory')
        $missing = [System.Collections.Generic.List[string]]::new()
        if ([string]::IsNullOrWhiteSpace($Frontmatter)) {
            foreach ($field in $required) { $missing.Add($field) }
            return $missing
        }
        foreach ($field in $required) {
            if ($Frontmatter -notmatch "(?m)^\s*$field\s*:") {
                $missing.Add($field)
            }
        }
        return $missing
    }

    function Get-FrontmatterScalar {
        <# Extracts a single-line scalar frontmatter value, or $null when absent. #>
        param(
            [Parameter(Mandatory = $true)][string]$Frontmatter,
            [Parameter(Mandatory = $true)][string]$Field
        )

        if ($Frontmatter -match "(?m)^\s*$Field\s*:\s*(.+?)\s*$") {
            return $Matches[1].Trim()
        }
        return $null
    }

    function Get-FrontmatterToolList {
        <# Returns the `tools:` list items of a frontmatter block, quotes stripped. #>
        param([Parameter(Mandatory = $true)][string]$Frontmatter)

        $tools = [System.Collections.Generic.List[string]]::new()
        $inTools = $false
        foreach ($line in $Frontmatter -split "`r?`n") {
            # The list runs from the `tools:` key to the next top-level key.
            if ($line -match '^tools\s*:') { $inTools = $true; continue }
            if ($inTools -and $line -match '^\S') { break }
            if ($inTools -and $line -match '^\s+-\s*(.+?)\s*$') {
                $tools.Add($Matches[1].Trim('"', "'"))
            }
        }
        return $tools
    }

    function Find-BannedSubstring {
        <# Case-insensitive banned-substring scan; returns the matched terms. #>
        param(
            [Parameter(Mandatory = $true)][string]$Text,
            [Parameter(Mandatory = $true)][string[]]$Banned
        )

        $lower = $Text.ToLowerInvariant()
        $hits = [System.Collections.Generic.List[string]]::new()
        foreach ($term in $Banned) {
            if ($lower.Contains($term.ToLowerInvariant())) { $hits.Add($term) }
        }
        return $hits
    }

    function Get-MissingReference {
        <# Returns the required reference tokens absent from a persona body. #>
        param(
            [Parameter(Mandatory = $true)][string]$Body,
            [Parameter(Mandatory = $true)][string[]]$Required
        )

        $missing = [System.Collections.Generic.List[string]]::new()
        foreach ($token in $Required) {
            if ($Body -notmatch [regex]::Escape($token)) { $missing.Add($token) }
        }
        return $missing
    }

    function Test-SlugCollision {
        <# Reports whether a slug is present in a candidate name set. #>
        param(
            [Parameter(Mandatory = $true)][string]$Slug,
            [Parameter(Mandatory = $true)][string[]]$NameSet
        )

        return ($NameSet -contains $Slug)
    }

    function Test-ConstrainedToolList {
        <# True when every tool is a drm-copilot MCP identifier and none is a general grant. #>
        param([Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Tools)

        if ($Tools.Count -eq 0) { return $false }
        foreach ($tool in $Tools) {
            if ($tool -notmatch '^mcp__drm-copilot__[a-z_]+$') { return $false }
        }
        return $true
    }

    function ConvertTo-ExpectedClaudeFrontmatter {
        <# Applies the generation rewrite to a canonical frontmatter block. #>
        param([Parameter(Mandatory = $true)][string]$CanonicalFrontmatter)

        return [regex]::Replace(
            $CanonicalFrontmatter,
            '(?m)^  - drmcopilotextension/([A-Za-z0-9_]+)$',
            '  - "mcp__drm-copilot__$1"')
    }

    function Get-PersonaContent {
        <# Reads one real persona file as raw text. #>
        param([Parameter(Mandatory = $true)][string]$Slug)

        return Get-Content -Path (Join-Path -Path $script:AgentsDir -ChildPath "$Slug.md") -Raw
    }

    # ---- In-memory fixtures (no temporary files, per general-unit-test policy) ----

    $script:PositiveFixture = @'
---
name: sample-analyst
description: Domain-neutral sample persona used only for fixture testing.
tools:
  - "mcp__drm-copilot__read_discovery_source"
  - "mcp__drm-copilot__finalize_discovery_agent"
memory: project
---

# Sample Analyst

| Artifact kind | Profile key | Selection |
| --- | --- | --- |
| coverage-ledger | coverage_ledger | Selected component members |
| required-output-manifest | reports | Exact invocation manifest |

Derive facts from the validated profile and call `finalize_discovery_agent`.
'@

    $script:BannedFixture = @'
---
name: sample-analyst
description: Synthetic persona used only to exercise the banned-substring scan.
tools:
  - "mcp__drm-copilot__read_discovery_source"
memory: project
---

This body references Outlook behavior, which is a domain-specific leak and must be flagged.
'@

    $script:CollidingFixtureSlug = 'legacy-analyst'

    $script:BroadGrantFixture = @'
---
name: sample-analyst
description: Synthetic persona that retains a superseded general write grant.
model: sonnet
tools:
  - Read
  - "Write(discovery/**)"
memory: project
---

Body text.
'@
}

Describe "legacy-discovery-agent-roles structural test" {

    Context "detection logic (in-memory fixtures)" {
        It "reports all required fields present and extracts the MCP tool list from the positive fixture" {
            # Arrange / Act
            $frontmatter = Get-FrontmatterBlock -Content $script:PositiveFixture
            $missing = Get-MissingFrontmatterField -Frontmatter $frontmatter
            $tools = Get-FrontmatterToolList -Frontmatter $frontmatter

            # Assert
            $frontmatter | Should -Not -BeNullOrEmpty
            $missing.Count | Should -Be 0
            $tools.Count | Should -Be 2
            (Test-ConstrainedToolList -Tools $tools) | Should -BeTrue
            (Get-FrontmatterScalar -Frontmatter $frontmatter -Field 'model') | Should -BeNullOrEmpty
        }

        It "rejects a general write grant and a hardcoded model in the broad-grant fixture" {
            # Arrange / Act
            $frontmatter = Get-FrontmatterBlock -Content $script:BroadGrantFixture
            $tools = Get-FrontmatterToolList -Frontmatter $frontmatter

            # Assert
            (Test-ConstrainedToolList -Tools $tools) | Should -BeFalse
            (Get-FrontmatterScalar -Frontmatter $frontmatter -Field 'model') | Should -Be 'sonnet'
        }

        It "detects a banned substring in the banned fixture and none in the positive fixture" {
            # Arrange / Act
            $hits = Find-BannedSubstring -Text $script:BannedFixture -Banned $script:BannedSubstrings
            $clean = Find-BannedSubstring -Text $script:PositiveFixture -Banned $script:BannedSubstrings

            # Assert
            $hits | Should -Contain 'outlook'
            $clean.Count | Should -Be 0
        }

        It "detects a colliding slug and accepts a distinct slug against the plugin name set" {
            (Test-SlugCollision -Slug $script:CollidingFixtureSlug -NameSet $script:PluginAgentNames) | Should -BeTrue
            (Test-SlugCollision -Slug 'legacy-parity-analyst' -NameSet $script:PluginAgentNames) | Should -BeFalse
        }

        It "reports missing and present body references against the positive fixture" {
            # Arrange
            $body = Get-BodyText -Content $script:PositiveFixture

            # Act
            $missing = Get-MissingReference -Body $body -Required @('coverage-ledger', 'parity-matrix')
            $present = Get-MissingReference -Body $body -Required @('coverage-ledger', 'validated profile')

            # Assert
            $missing | Should -Be @('parity-matrix')
            $present.Count | Should -Be 0
        }

        It "rewrites a Copilot tool identifier to the Claude MCP identifier" {
            $canonical = "name: x`ntools:`n  - drmcopilotextension/read_discovery_source`nmemory: project"
            $expected = "name: x`ntools:`n  - `"mcp__drm-copilot__read_discovery_source`"`nmemory: project"

            (ConvertTo-ExpectedClaudeFrontmatter -CanonicalFrontmatter $canonical) | Should -BeExactly $expected
        }
    }

    Context "real persona files" {
        It "assertion 1 - each of the four persona files exists with a canonical source and bundle mirror" {
            foreach ($slug in $script:ExpectedSlugs) {
                (Join-Path -Path $script:AgentsDir -ChildPath "$slug.md") | Should -Exist
                (Join-Path -Path $script:CanonicalDir -ChildPath "$slug.agent.md") | Should -Exist
                (Join-Path -Path $script:BundleAgentsDir -ChildPath "$slug.md") | Should -Exist
            }
        }

        It "assertion 2 - each persona declares name, description, tools and memory" {
            $failures = [System.Collections.Generic.List[string]]::new()
            foreach ($slug in $script:ExpectedSlugs) {
                $missing = Get-MissingFrontmatterField -Frontmatter (Get-FrontmatterBlock -Content (Get-PersonaContent -Slug $slug))
                if ($missing.Count -gt 0) { $failures.Add("$slug missing: $($missing -join ', ')") }
            }
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 3 - each persona name equals its slug and file basename" {
            $failures = [System.Collections.Generic.List[string]]::new()
            foreach ($slug in $script:ExpectedSlugs) {
                $name = Get-FrontmatterScalar -Frontmatter (Get-FrontmatterBlock -Content (Get-PersonaContent -Slug $slug)) -Field 'name'
                if ($name -ne $slug) { $failures.Add("$slug name='$name'") }
            }
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 4 - each persona declares no model override and only drm-copilot MCP tools" {
            $failures = [System.Collections.Generic.List[string]]::new()
            foreach ($slug in $script:ExpectedSlugs) {
                $frontmatter = Get-FrontmatterBlock -Content (Get-PersonaContent -Slug $slug)
                $tools = Get-FrontmatterToolList -Frontmatter $frontmatter
                if ($null -ne (Get-FrontmatterScalar -Frontmatter $frontmatter -Field 'model')) {
                    $failures.Add("$slug declares a model override")
                }
                if (-not (Test-ConstrainedToolList -Tools $tools)) {
                    $failures.Add("$slug tools: $($tools -join ', ')")
                }
                foreach ($required in @('mcp__drm-copilot__read_discovery_source', 'mcp__drm-copilot__finalize_discovery_agent')) {
                    if ($tools -notcontains $required) { $failures.Add("$slug lacks $required") }
                }
            }
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 5 - the four slugs collide with neither the plugin set nor other agent basenames" {
            $allBasenames = @((Get-ChildItem -Path $script:AgentsDir -Filter '*.md' -File).BaseName)
            $otherBasenames = @($allBasenames | Where-Object { $script:ExpectedSlugs -notcontains $_ })
            $failures = [System.Collections.Generic.List[string]]::new()
            foreach ($slug in $script:ExpectedSlugs) {
                if (Test-SlugCollision -Slug $slug -NameSet $script:PluginAgentNames) { $failures.Add("$slug collides with plugin set") }
                if (Test-SlugCollision -Slug $slug -NameSet $otherBasenames) { $failures.Add("$slug collides with an existing agent basename") }
            }
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 6 - each persona full text contains no banned domain-specific substring" {
            $failures = [System.Collections.Generic.List[string]]::new()
            foreach ($slug in $script:ExpectedSlugs) {
                $hits = Find-BannedSubstring -Text (Get-PersonaContent -Slug $slug) -Banned $script:BannedSubstrings
                if ($hits.Count -gt 0) { $failures.Add("$slug hits: $($hits -join ', ')") }
            }
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 7 - each persona body names its owned artifact kinds, the validated profile and finalize" {
            $failures = [System.Collections.Generic.List[string]]::new()
            foreach ($slug in $script:ExpectedSlugs) {
                $missing = Get-MissingReference -Body (Get-BodyText -Content (Get-PersonaContent -Slug $slug)) -Required $script:RequiredReferences[$slug]
                if ($missing.Count -gt 0) { $failures.Add("$slug missing: $($missing -join ', ')") }
            }
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 8 - parity-matrix output is owned by the reconciler, not the legacy analyst" {
            (Get-BodyText -Content (Get-PersonaContent -Slug 'requirements-reconciler')) | Should -Match $script:ParityRowPattern
            (Get-BodyText -Content (Get-PersonaContent -Slug 'legacy-parity-analyst')) | Should -Not -Match $script:ParityRowPattern
            (Get-BodyText -Content (Get-PersonaContent -Slug 'legacy-parity-analyst')) | Should -Match 'parity reconciliation belongs to the Requirements Reconciler'
        }

        It "assertion 9 - each persona is the generated rewrite of its canonical contract and is mirrored byte-identically" {
            $failures = [System.Collections.Generic.List[string]]::new()
            foreach ($slug in $script:ExpectedSlugs) {
                $content = Get-PersonaContent -Slug $slug
                $canonical = Get-Content -Path (Join-Path -Path $script:CanonicalDir -ChildPath "$slug.agent.md") -Raw
                $expectedFrontmatter = ConvertTo-ExpectedClaudeFrontmatter -CanonicalFrontmatter (Get-FrontmatterBlock -Content $canonical)
                if ((Get-FrontmatterBlock -Content $content) -cne $expectedFrontmatter) { $failures.Add("$slug frontmatter differs from the canonical rewrite") }
                if ((Get-BodyText -Content $content) -cne (Get-BodyText -Content $canonical)) { $failures.Add("$slug body differs from the canonical contract") }
                if ($content -match 'drmcopilotextension' -or $content -match 'Write\(') { $failures.Add("$slug retains an untranslated or broad grant") }
                $bundled = Get-Content -Path (Join-Path -Path $script:BundleAgentsDir -ChildPath "$slug.md") -Raw
                if ($bundled -cne $content) { $failures.Add("$slug bundle mirror differs") }
            }
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }
    }
}
