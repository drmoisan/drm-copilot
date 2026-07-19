Set-StrictMode -Version Latest

# Structural test for the four legacy-discovery agent personas (#365, epic child #9007).
#
# This test verifies the four domain-neutral persona definitions under `.claude/agents/`
# against repository conventions and the epic-wide naming-collision and domain-neutrality
# invariants. Following the `test-name-uniqueness.Tests.ps1` precedent, reusable detection
# helpers (frontmatter extraction, field presence, banned-substring scan, body-content
# reference scan, slug-collision check) are defined in `BeforeAll` and exercised with
# in-memory positive and negative fixtures, so the detection logic is proven independently of
# the repository files. The same helpers then run over the four real persona files.
#
# The seven assertions mirror the spec's `## Structural Test` section:
#   1. Existence            4. Model membership       7. AC4 body-content references
#   2. Frontmatter validity 5. Naming non-collision
#   3. Name equals slug     6. Banned-substring scan

BeforeAll {
    # Resolve the repository root by walking up from this file's own location until a directory
    # containing a `.claude` folder is found. This keeps resolution CWD-independent so the suite
    # behaves identically in the terminal and the VS Code Test Explorer.
    $script:RepoRoot = $PSScriptRoot
    while ($null -ne $script:RepoRoot -and
        -not (Test-Path -Path (Join-Path -Path $script:RepoRoot -ChildPath '.claude') -PathType Container)) {
        $script:RepoRoot = Split-Path -Path $script:RepoRoot -Parent
    }
    if ($null -eq $script:RepoRoot) {
        throw "Unable to resolve the repository root by walking up from '$PSScriptRoot'."
    }
    $script:AgentsDir = Join-Path -Path $script:RepoRoot -ChildPath '.claude' -AdditionalChildPath 'agents'

    # The four expected persona slugs.
    $script:ExpectedSlugs = @(
        'legacy-parity-analyst',
        'runtime-characterization-analyst',
        'requirements-reconciler',
        'migration-coverage-reviewer'
    )

    # The `code-modernization` plugin agent names; the four slugs must be disjoint from this set.
    $script:PluginAgentNames = @(
        'legacy-analyst',
        'business-rules-extractor',
        'architecture-critic',
        'scaffolder',
        'security-auditor',
        'test-engineer',
        'version-delta-analyst'
    )

    # Banned domain-specific substrings (case-insensitive). Any hit is a Blocking failure.
    $script:BannedSubstrings = @(
        'taskmaster',
        'tmw',
        'outlook',
        'vsto',
        'email',
        'task-management',
        'task management'
    )

    # Required body-content references per persona: consumed schema(s), produced schema, and the
    # literal phrase 'domain profile'. Confirmed against the spec Per-Persona Design section.
    $script:RequiredReferences = @{
        'legacy-parity-analyst'            = @('Feature Contract', 'Parity Matrix', 'Evidence Reference', 'domain profile')
        'runtime-characterization-analyst' = @('Runtime Characterization Scenario', 'Evidence Reference', 'Feature Contract', 'domain profile')
        'requirements-reconciler'          = @('Unspecified Behavior Record', 'Product Decision Record', 'Evidence Reference', 'Feature Contract', 'domain profile')
        'migration-coverage-reviewer'      = @('Coverage Ledger', 'Feature Contract', 'Evidence Reference', 'domain profile')
    }

    <#
    .SYNOPSIS
        Extracts the `---`-delimited YAML frontmatter block from a persona document.
    .OUTPUTS
        [string] the frontmatter body, or $null when no delimited block is present.
    #>
    function Get-FrontmatterBlock {
        param([Parameter(Mandatory = $true)][string]$Content)

        if ($Content -match '(?s)\A\s*---\r?\n(.*?)\r?\n---\r?\n') {
            return $Matches[1]
        }
        return $null
    }

    <#
    .SYNOPSIS
        Returns the document body that follows the frontmatter block.
    .OUTPUTS
        [string] the body text, or the whole content when no frontmatter is present.
    #>
    function Get-BodyText {
        param([Parameter(Mandatory = $true)][string]$Content)

        if ($Content -match '(?s)\A\s*---\r?\n.*?\r?\n---\r?\n(.*)\z') {
            return $Matches[1]
        }
        return $Content
    }

    <#
    .SYNOPSIS
        Returns the list of required frontmatter fields that are absent from a frontmatter block.
    .OUTPUTS
        [System.Collections.Generic.List[string]] of missing field names (empty when all present).
    #>
    function Get-MissingFrontmatterField {
        param([Parameter(Mandatory = $true)][AllowEmptyString()][AllowNull()][string]$Frontmatter)

        $required = @('name', 'description', 'model', 'tools', 'memory')
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

    <#
    .SYNOPSIS
        Extracts a single-line scalar frontmatter field value.
    .OUTPUTS
        [string] the trimmed value, or $null when the field is absent or not scalar.
    #>
    function Get-FrontmatterScalar {
        param(
            [Parameter(Mandatory = $true)][string]$Frontmatter,
            [Parameter(Mandatory = $true)][string]$Field
        )

        if ($Frontmatter -match "(?m)^\s*$Field\s*:\s*(.+?)\s*$") {
            return $Matches[1].Trim()
        }
        return $null
    }

    <#
    .SYNOPSIS
        Case-insensitive banned-substring scan over arbitrary text.
    .OUTPUTS
        [System.Collections.Generic.List[string]] of matched banned substrings (empty when clean).
    #>
    function Find-BannedSubstring {
        param(
            [Parameter(Mandatory = $true)][string]$Text,
            [Parameter(Mandatory = $true)][string[]]$Banned
        )

        $lower = $Text.ToLowerInvariant()
        $hits = [System.Collections.Generic.List[string]]::new()
        foreach ($term in $Banned) {
            if ($lower.Contains($term.ToLowerInvariant())) {
                $hits.Add($term)
            }
        }
        return $hits
    }

    <#
    .SYNOPSIS
        Returns the list of required reference tokens absent from a persona body.
    .OUTPUTS
        [System.Collections.Generic.List[string]] of missing tokens (empty when all present).
    #>
    function Get-MissingReference {
        param(
            [Parameter(Mandatory = $true)][string]$Body,
            [Parameter(Mandatory = $true)][string[]]$Required
        )

        $missing = [System.Collections.Generic.List[string]]::new()
        foreach ($token in $Required) {
            if ($Body -notmatch [regex]::Escape($token)) {
                $missing.Add($token)
            }
        }
        return $missing
    }

    <#
    .SYNOPSIS
        Reports whether a slug is present in a candidate name set (collision check).
    .OUTPUTS
        [bool] $true when the slug collides with a member of the set.
    #>
    function Test-SlugCollision {
        param(
            [Parameter(Mandatory = $true)][string]$Slug,
            [Parameter(Mandatory = $true)][string[]]$NameSet
        )

        return ($NameSet -contains $Slug)
    }

    # ---- In-memory fixtures (no temporary files, per general-unit-test policy) ----

    # Positive fixture: a compliant synthetic persona.
    $script:PositiveFixture = @'
---
name: sample-analyst
description: Domain-neutral sample persona used only for fixture testing.
model: sonnet
tools:
  - Read
  - Grep
  - Glob
  - "Write(discovery/**)"
memory: project
---

# Sample Analyst

Schemas consumed: Feature Contract, Parity Matrix, Evidence Reference.
Schema produced: Parity Matrix.
Reads the domain profile to obtain domain specificity.
'@

    # Negative fixture (a): contains a banned domain-specific substring in the body.
    $script:BannedFixture = @'
---
name: sample-analyst
description: Synthetic persona used only to exercise the banned-substring scan.
model: sonnet
tools:
  - Read
  - Grep
  - Glob
  - "Write(discovery/**)"
memory: project
---

# Sample Analyst

This body references Outlook behavior, which is a domain-specific leak and must be flagged.
'@

    # Negative fixture (b): a slug that collides with a plugin agent name.
    $script:CollidingFixtureSlug = 'legacy-analyst'

    # Negative fixture (c): a body missing the required schema and domain-profile references.
    $script:MissingReferencesFixture = @'
---
name: sample-analyst
description: Synthetic persona whose body omits the required references.
model: sonnet
tools:
  - Read
  - Grep
  - Glob
  - "Write(discovery/**)"
memory: project
---

# Sample Analyst

This body describes a role in the abstract but names no consumed schema, no produced schema,
and no profile.
'@

    # Negative fixture (d): frontmatter missing the required `model` field.
    $script:MissingFieldFixture = @'
---
name: sample-analyst
description: Synthetic persona whose frontmatter omits the model field.
tools:
  - Read
memory: project
---

# Sample Analyst

Body text.
'@
}

Describe "legacy-discovery-agent-roles structural test" {

    Context "detection logic (in-memory fixtures)" {
        It "extracts frontmatter and reports all required fields present in the positive fixture" {
            # Arrange / Act
            $frontmatter = Get-FrontmatterBlock -Content $script:PositiveFixture
            $missing = Get-MissingFrontmatterField -Frontmatter $frontmatter

            # Assert
            $frontmatter | Should -Not -BeNullOrEmpty
            $missing.Count | Should -Be 0
        }

        It "flags a missing frontmatter field in the negative fixture" {
            # Arrange / Act
            $frontmatter = Get-FrontmatterBlock -Content $script:MissingFieldFixture
            $missing = Get-MissingFrontmatterField -Frontmatter $frontmatter

            # Assert
            $missing | Should -Contain 'model'
        }

        It "detects a banned substring in the banned negative fixture" {
            # Arrange / Act
            $hits = Find-BannedSubstring -Text $script:BannedFixture -Banned $script:BannedSubstrings

            # Assert
            $hits.Count | Should -BeGreaterThan 0
            $hits | Should -Contain 'outlook'
        }

        It "reports no banned substring in the positive fixture" {
            # Arrange / Act
            $hits = Find-BannedSubstring -Text $script:PositiveFixture -Banned $script:BannedSubstrings

            # Assert
            $hits.Count | Should -Be 0
        }

        It "detects a colliding slug against the plugin name set" {
            # Arrange / Act / Assert
            (Test-SlugCollision -Slug $script:CollidingFixtureSlug -NameSet $script:PluginAgentNames) |
                Should -BeTrue
        }

        It "reports no collision for a distinct slug against the plugin name set" {
            # Arrange / Act / Assert
            (Test-SlugCollision -Slug 'legacy-parity-analyst' -NameSet $script:PluginAgentNames) |
                Should -BeFalse
        }

        It "flags missing body-content references in the missing-references negative fixture" {
            # Arrange
            $body = Get-BodyText -Content $script:MissingReferencesFixture
            $required = @('Feature Contract', 'Parity Matrix', 'Evidence Reference', 'domain profile')

            # Act
            $missing = Get-MissingReference -Body $body -Required $required

            # Assert
            $missing.Count | Should -BeGreaterThan 0
        }

        It "reports no missing body-content references in the positive fixture" {
            # Arrange
            $body = Get-BodyText -Content $script:PositiveFixture
            $required = @('Feature Contract', 'Parity Matrix', 'Evidence Reference', 'domain profile')

            # Act
            $missing = Get-MissingReference -Body $body -Required $required

            # Assert
            $missing.Count | Should -Be 0
        }
    }

    Context "real persona files" {
        It "assertion 1 - each of the four persona files exists" {
            # Arrange
            $missingFiles = [System.Collections.Generic.List[string]]::new()

            # Act
            foreach ($slug in $script:ExpectedSlugs) {
                $path = Join-Path -Path $script:AgentsDir -ChildPath "$slug.md"
                if (-not (Test-Path -Path $path -PathType Leaf)) {
                    $missingFiles.Add($slug)
                }
            }

            # Assert
            $missingFiles.Count | Should -Be 0 -Because ("missing: " + ($missingFiles -join ', '))
        }

        It "assertion 2 - each persona declares all required frontmatter fields" {
            # Arrange
            $failures = [System.Collections.Generic.List[string]]::new()

            # Act
            foreach ($slug in $script:ExpectedSlugs) {
                $content = Get-Content -Path (Join-Path -Path $script:AgentsDir -ChildPath "$slug.md") -Raw
                $frontmatter = Get-FrontmatterBlock -Content $content
                $missing = Get-MissingFrontmatterField -Frontmatter $frontmatter
                if ($missing.Count -gt 0) {
                    $failures.Add("$slug missing: $($missing -join ', ')")
                }
            }

            # Assert
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 3 - each persona name equals its slug and file basename" {
            # Arrange
            $failures = [System.Collections.Generic.List[string]]::new()

            # Act
            foreach ($slug in $script:ExpectedSlugs) {
                $content = Get-Content -Path (Join-Path -Path $script:AgentsDir -ChildPath "$slug.md") -Raw
                $frontmatter = Get-FrontmatterBlock -Content $content
                $name = Get-FrontmatterScalar -Frontmatter $frontmatter -Field 'name'
                if ($name -ne $slug) {
                    $failures.Add("$slug name='$name'")
                }
            }

            # Assert
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 4 - each persona model is one of haiku, sonnet, or opus" {
            # Arrange
            $allowed = @('haiku', 'sonnet', 'opus')
            $failures = [System.Collections.Generic.List[string]]::new()

            # Act
            foreach ($slug in $script:ExpectedSlugs) {
                $content = Get-Content -Path (Join-Path -Path $script:AgentsDir -ChildPath "$slug.md") -Raw
                $frontmatter = Get-FrontmatterBlock -Content $content
                $model = Get-FrontmatterScalar -Frontmatter $frontmatter -Field 'model'
                if ($allowed -notcontains $model) {
                    $failures.Add("$slug model='$model'")
                }
            }

            # Assert
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 5 - the four slugs collide with neither the plugin set nor other agent basenames" {
            # Arrange: other existing agent basenames, excluding the four expected slugs.
            $allBasenames = @((Get-ChildItem -Path $script:AgentsDir -Filter '*.md' -File).BaseName)
            $otherBasenames = @($allBasenames | Where-Object { $script:ExpectedSlugs -notcontains $_ })
            $failures = [System.Collections.Generic.List[string]]::new()

            # Act
            foreach ($slug in $script:ExpectedSlugs) {
                if (Test-SlugCollision -Slug $slug -NameSet $script:PluginAgentNames) {
                    $failures.Add("$slug collides with plugin set")
                }
                if (Test-SlugCollision -Slug $slug -NameSet $otherBasenames) {
                    $failures.Add("$slug collides with an existing agent basename")
                }
            }

            # Assert
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 6 - each persona full text contains no banned domain-specific substring" {
            # Arrange
            $failures = [System.Collections.Generic.List[string]]::new()

            # Act
            foreach ($slug in $script:ExpectedSlugs) {
                $content = Get-Content -Path (Join-Path -Path $script:AgentsDir -ChildPath "$slug.md") -Raw
                $hits = Find-BannedSubstring -Text $content -Banned $script:BannedSubstrings
                if ($hits.Count -gt 0) {
                    $failures.Add("$slug hits: $($hits -join ', ')")
                }
            }

            # Assert
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }

        It "assertion 7 - each persona body names its consumed schemas, produced schema, and the domain profile" {
            # Arrange
            $failures = [System.Collections.Generic.List[string]]::new()

            # Act
            foreach ($slug in $script:ExpectedSlugs) {
                $content = Get-Content -Path (Join-Path -Path $script:AgentsDir -ChildPath "$slug.md") -Raw
                $body = Get-BodyText -Content $content
                $required = $script:RequiredReferences[$slug]
                $missing = Get-MissingReference -Body $body -Required $required
                if ($missing.Count -gt 0) {
                    $failures.Add("$slug missing: $($missing -join ', ')")
                }
            }

            # Assert
            $failures.Count | Should -Be 0 -Because ($failures -join '; ')
        }
    }
}
