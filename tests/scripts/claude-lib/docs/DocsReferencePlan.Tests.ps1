#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Example tests for DocsReferencePlan.psm1.

.DESCRIPTION
    Pins the family page names, the unrendered architecture-component count, the output
    directory resolution and its findings, the path_or_glob coverage rule, first-match owner and
    directory-mode precedence, the longest-root audience, the page-scoped findings and the
    snapshot conversion findings. Every input is an in-memory string or dictionary; the only
    committed files read are the runtime schema files (read-only, through the test support).
#>

BeforeAll {
    $script:LibRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../.claude/lib/docs'
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsReferencePlan.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsJson.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $script:LibRoot -ChildPath 'DocsSurface.psm1') -Force -ErrorAction Stop
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsReference.TestSupport.psm1') -Force -ErrorAction Stop

    $script:ComposedSet = New-DocsReferenceComposedSchemaSet

    function Get-TestElement {
        # Builds one valid element with a fixed source text.
        param(
            [string] $Kind = 'cli-command',
            [string] $Declaration = 'tool run',
            [string] $Path = 'src/tool.py',
            [AllowNull()] [string] $ParentId = $null,
            [AllowNull()] [System.Collections.IDictionary] $Property = $null
        )
        $range = if ($Kind -ceq 'architecture-component') { $null } else { [int[]]@(1, 1) }
        return New-DocsSurfaceElement -Kind $Kind -Path $Path -Declaration $Declaration -Name 'name' -AnalyzerId 'test-analyzer' -AnalysisMethod 'scanner' -SourceText "line one`n" -ParentId $ParentId -LineRange $range -Property $Property
    }

    function Get-TestSnapshotText {
        # Serializes a schema-valid snapshot holding the given element records.
        param([AllowEmptyCollection()] [object[]] $Element = @())
        $snapshot = [ordered]@{
            '$schema'      = 'urn:drm-copilot:docs:1.0.0:surface-inventory-snapshot'
            schema_version = '1.0.0'
            artifact_kind  = 'surface-inventory-snapshot'
            id             = 'example-repo.snapshot'
            extensions     = [ordered]@{}
            repository     = 'example-repo'
            revision       = $null
            profile_sha256 = 'a' * 64
            analyzers      = [object[]]@([ordered]@{ id = 'test-analyzer'; version = '1'; analysis_method = 'scanner' })
            inputs         = [object[]]@()
            elements       = [object[]] $Element
            diagnostics    = [object[]]@()
            captured_at    = '2026-01-02T03:04:05Z'
        }
        return ConvertTo-DocsJsonText -Value $snapshot
    }

    function Get-TestProfile {
        # Returns a minimal profile dictionary with the fields the page plan reads.
        param(
            [object[]] $DirectoryMode = @([ordered]@{ path_or_glob = 'docs/reference'; mode = 'reference' }),
            [string[]] $Mode = @('tutorial', 'how-to', 'reference', 'explanation'),
            [object[]] $Root = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = [string[]]@('users', 'admins') }),
            [object[]] $Owner = @([ordered]@{ path_or_glob = 'docs/reference/**'; owner = 'docs-team' })
        )
        return [ordered]@{
            repository          = [ordered]@{ id = 'example-repo' }
            documentation_roots = $Root
            page_owners         = $Owner
            diataxis_policy     = [ordered]@{ modes = $Mode; directory_modes = $DirectoryMode }
        }
    }

    function Get-TestCode {
        param([AllowEmptyCollection()] [object[]] $Finding)
        return [string[]]@($Finding | ForEach-Object { [string] $_['code'] })
    }
}

AfterAll {
    Get-Module -Name 'Docs*', 'DiscoveryEncoding' | Remove-Module -Force -ErrorAction SilentlyContinue
}

Describe 'Get-DocsReferenceCandidatePagePath' {
    It 'returns exactly the four family pages under the output directory and no index page' {
        # Act
        $paths = Get-DocsReferenceCandidatePagePath -OutputDirectory 'docs/reference'

        # Assert
        $paths | Should -Be @('docs/reference/api-reference.md', 'docs/reference/cli-reference.md', 'docs/reference/config-reference.md', 'docs/reference/http-reference.md')
        @($paths | Where-Object { $_ -match '/(?:index|README)\.md$' }).Count | Should -Be 0
    }

    It 'adds the listed split pages one level beneath a family stem and no other listed path (issue #1173 B5)' {
        # Arrange (split directories are now listed, so their pages are candidates)
        $listed = @(
            'docs/reference/cli-reference/beta.md', 'docs/reference/api-reference/alpha.md', 'docs/reference/api-reference.md',
            'docs/reference/api-reference/deep/x.md', 'docs/reference/api-reference/notes.txt', 'docs/reference/other/y.md',
            'docs/reference/guide.md', 'docs/reference/api-reference/.md'
        )

        # Act
        $paths = Get-DocsReferenceCandidatePagePath -OutputDirectory 'docs/reference' -ListedPath $listed

        # Assert
        $paths | Should -Be @(
            'docs/reference/api-reference.md', 'docs/reference/api-reference/alpha.md', 'docs/reference/cli-reference.md',
            'docs/reference/cli-reference/beta.md', 'docs/reference/config-reference.md', 'docs/reference/http-reference.md'
        )
    }
}

Describe 'Get-DocsReferencePagePlan' {
    It 'plans one page per family with elements, with the fixed titles, and no index page' {
        # Arrange
        $element = @(
            (Get-TestElement -Kind 'cli-command'), (Get-TestElement -Kind 'http-route' -Declaration 'GET /items'),
            (Get-TestElement -Kind 'config-key' -Declaration 'server.port'), (Get-TestElement -Kind 'public-symbol' -Declaration 'Get-Thing')
        )

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile) -Element $element -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        @($plan.Page | ForEach-Object { $_.Path }) | Should -Be @('docs/reference/api-reference.md', 'docs/reference/cli-reference.md', 'docs/reference/config-reference.md', 'docs/reference/http-reference.md')
        @($plan.Page | ForEach-Object { $_.Title }) | Should -Be @('API reference', 'CLI reference', 'Configuration reference', 'HTTP reference')
        $plan.Finding.Count | Should -Be 0
    }

    It 'renders architecture-component on no page and counts it in Unrendered' {
        # Arrange
        $element = @((Get-TestElement -Kind 'architecture-component' -Declaration 'core'), (Get-TestElement -Kind 'architecture-component' -Declaration 'edge'), (Get-TestElement -Kind 'config-key' -Declaration 'k'))

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile) -Element $element -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        $plan.Unrendered | Should -Be 2
        @($plan.Page | ForEach-Object { $_.Path }) | Should -Be @('docs/reference/config-reference.md')
        @($plan.Page[0].Element | Where-Object { $_['kind'] -ceq 'architecture-component' }).Count | Should -Be 0
    }

    It 'plans an existing page whose family has no elements with an empty element list' {
        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile) -Element @() -OutputDirectory 'docs/reference' -ExistingPagePath @('docs/reference/http-reference.md', 'docs/other.md') -ProfilePath 'docs/profile.json'

        # Assert
        @($plan.Page | ForEach-Object { $_.Path }) | Should -Be @('docs/reference/http-reference.md')
        $plan.Page[0].Element.Count | Should -Be 0
    }

    It 'orders commands by declaration, each followed by its options, and an orphan option last with REFERENCE_PARENT_MISSING' {
        # Arrange
        $beta = Get-TestElement -Declaration 'tool beta'
        $alpha = Get-TestElement -Declaration 'tool alpha'
        $alphaOption = Get-TestElement -Kind 'cli-option' -Declaration '--zeta' -ParentId $alpha['element_id']
        $alphaOption2 = Get-TestElement -Kind 'cli-option' -Declaration '--alpha' -ParentId $alpha['element_id']
        $missingParent = Get-DocsElementId -Kind 'cli-command' -Path 'src/gone.py' -Declaration 'gone'
        $orphan = Get-TestElement -Kind 'cli-option' -Declaration '--aaa' -ParentId $missingParent

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile) -Element @($orphan, $beta, $alphaOption, $alpha, $alphaOption2) -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        @($plan.Page[0].Element | ForEach-Object { $_['declaration'] }) | Should -Be @('tool alpha', '--alpha', '--zeta', 'tool beta', '--aaa')
        $warning = @($plan.Finding | Where-Object { $_['code'] -ceq 'REFERENCE_PARENT_MISSING' })
        $warning.Count | Should -Be 1
        $warning[0]['severity'] | Should -BeExactly 'warning'
        $warning[0]['related_ids'] | Should -Be @($orphan['element_id'])
        $warning[0]['artifact_path'] | Should -BeExactly 'docs/reference/cli-reference.md'
    }

    It 'orders HTTP routes by template then method' {
        # Arrange
        $element = @((Get-TestElement -Kind 'http-route' -Declaration 'POST /b'), (Get-TestElement -Kind 'http-route' -Declaration 'GET /b'), (Get-TestElement -Kind 'http-route' -Declaration 'PUT /a'))

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile) -Element $element -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        @($plan.Page[0].Element | ForEach-Object { $_['declaration'] }) | Should -Be @('PUT /a', 'GET /b', 'POST /b')
    }

    It 'orders configuration keys by declaration, then path, ordinally' {
        # Arrange
        $element = @((Get-TestElement -Kind 'config-key' -Declaration 'b' -Path 'src/a.toml'), (Get-TestElement -Kind 'config-key' -Declaration 'B' -Path 'src/z.toml'), (Get-TestElement -Kind 'config-key' -Declaration 'b' -Path 'src/0.toml'))

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile) -Element $element -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        @($plan.Page[0].Element | ForEach-Object { $_['declaration'] + '@' + $_['path'] }) | Should -Be @('B@src/z.toml', 'b@src/0.toml', 'b@src/a.toml')
    }

    It 'takes the owner of the first covering page_owners entry in profile order' {
        # Arrange
        $owners = @([ordered]@{ path_or_glob = 'docs/other'; owner = 'x' }, [ordered]@{ path_or_glob = 'docs/reference'; owner = 'first' }, [ordered]@{ path_or_glob = 'docs'; owner = 'second' })

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile -Owner $owners) -Element @(Get-TestElement) -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        $plan.Page[0].Owner | Should -BeExactly 'first'
    }

    It 'leaves the owner null when no page_owners entry covers the page' {
        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile -Owner @([ordered]@{ path_or_glob = 'docs/guides'; owner = 'x' })) -Element @(Get-TestElement) -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        $plan.Page[0].Owner | Should -BeNullOrEmpty
    }

    It 'reports a page REFERENCE_MODE_CONFLICT when the first covering directory mode is not reference' {
        # Arrange
        $modes = @([ordered]@{ path_or_glob = 'docs/**'; mode = 'how-to' }, [ordered]@{ path_or_glob = 'docs/reference'; mode = 'reference' })

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile -DirectoryMode $modes) -Element @(Get-TestElement) -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        Get-TestCode -Finding $plan.Page[0].Finding | Should -Be @('REFERENCE_MODE_CONFLICT')
        $plan.Page[0].Finding[0]['severity'] | Should -BeExactly 'error'
        $plan.Page[0].Finding[0]['artifact_path'] | Should -BeExactly 'docs/reference/cli-reference.md'
        $plan.Page[0].Finding[0]['related_paths'] | Should -Be @('docs/profile.json')
    }

    It 'reports no conflict when the first covering directory mode is reference and a later one differs' {
        # Arrange
        $modes = @([ordered]@{ path_or_glob = 'docs/reference'; mode = 'reference' }, [ordered]@{ path_or_glob = 'docs/**'; mode = 'how-to' })

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile -DirectoryMode $modes) -Element @(Get-TestElement) -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        $plan.Page[0].Finding.Count | Should -Be 0
    }

    It 'reports no conflict when no directory mode covers the page' {
        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile -DirectoryMode @([ordered]@{ path_or_glob = 'docs/guides'; mode = 'how-to' })) -Element @(Get-TestElement) -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        $plan.Page[0].Finding.Count | Should -Be 0
    }

    It 'takes the ordinal-sorted audience of the longest covering root' {
        # Arrange
        $roots = @([ordered]@{ id = 'docs-root'; path = 'docs'; audience_ids = [string[]]@('users') }, [ordered]@{ id = 'ref-root'; path = 'docs/reference'; audience_ids = [string[]]@('ops', 'admins', 'b-team') })

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile -Root $roots) -Element @(Get-TestElement) -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        $plan.Page[0].RootId | Should -BeExactly 'ref-root'
        $plan.Page[0].Audience | Should -Be @('admins', 'b-team', 'ops')
    }

    It 'gives a tie between equally long covering roots to the first in profile order' {
        # Arrange
        $roots = @([ordered]@{ id = 'first'; path = 'docs'; audience_ids = [string[]]@('a') }, [ordered]@{ id = 'second'; path = 'docs'; audience_ids = [string[]]@('b') })

        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile -Root $roots) -Element @(Get-TestElement) -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        $plan.Page[0].RootId | Should -BeExactly 'first'
        $plan.Page[0].Audience | Should -Be @('a')
    }

    It 'reports REFERENCE_OUTPUT_OUTSIDE_ROOTS when no documentation root covers the page' {
        # Act
        $plan = Get-DocsReferencePagePlan -Profile (Get-TestProfile -Root @([ordered]@{ id = 'site'; path = 'site'; audience_ids = [string[]]@('a') })) -Element @(Get-TestElement) -OutputDirectory 'docs/reference' -ExistingPagePath @() -ProfilePath 'docs/profile.json'

        # Assert
        Get-TestCode -Finding $plan.Page[0].Finding | Should -Be @('REFERENCE_OUTPUT_OUTSIDE_ROOTS')
        $plan.Page[0].RootId | Should -BeNullOrEmpty
        $plan.Page[0].Audience.Count | Should -Be 0
    }
}

Describe 'Resolve-DocsReferenceOutputDirectory' {
    It 'returns an -OutputDirectory override unchanged' {
        # Act
        $result = Resolve-DocsReferenceOutputDirectory -Profile (Get-TestProfile) -ProfilePath 'docs/profile.json' -OutputDirectory 'site/api'

        # Assert
        $result.OutputDirectory | Should -BeExactly 'site/api'
        $result.Finding.Count | Should -Be 0
    }

    It 'returns the single non-glob reference entry among glob and other-mode entries' {
        # Arrange
        $modes = @([ordered]@{ path_or_glob = 'docs/ref/*'; mode = 'reference' }, [ordered]@{ path_or_glob = 'docs/guides'; mode = 'how-to' }, [ordered]@{ path_or_glob = 'docs/api'; mode = 'reference' }, [ordered]@{ path_or_glob = 'docs/x[0-9]'; mode = 'reference' })

        # Act
        $result = Resolve-DocsReferenceOutputDirectory -Profile (Get-TestProfile -DirectoryMode $modes) -ProfilePath 'docs/profile.json'

        # Assert
        $result.OutputDirectory | Should -BeExactly 'docs/api'
        $result.Finding.Count | Should -Be 0
    }

    It 'reports REFERENCE_OUTPUT_DIR_UNRESOLVED for <Case>' -ForEach @(
        @{ Case = 'zero non-glob reference entries'; Modes = @(@{ path_or_glob = 'docs/ref?'; mode = 'reference' }, @{ path_or_glob = 'docs/a'; mode = 'how-to' }) }
        @{ Case = 'two non-glob reference entries'; Modes = @(@{ path_or_glob = 'docs/a'; mode = 'reference' }, @{ path_or_glob = 'docs/b'; mode = 'reference' }) }
    ) {
        # Act
        $result = Resolve-DocsReferenceOutputDirectory -Profile (Get-TestProfile -DirectoryMode $Modes) -ProfilePath 'docs/profile.json'

        # Assert
        $result.OutputDirectory | Should -BeNullOrEmpty
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_OUTPUT_DIR_UNRESOLVED')
        $result.Finding[0]['pointer'] | Should -BeExactly '/diataxis_policy/directory_modes'
        $result.Finding[0]['artifact_path'] | Should -BeExactly 'docs/profile.json'
    }

    It 'reports a global REFERENCE_MODE_CONFLICT when reference is not a profile mode, even with an override' {
        # Act
        $result = Resolve-DocsReferenceOutputDirectory -Profile (Get-TestProfile -Mode @('tutorial', 'how-to')) -ProfilePath 'docs/profile.json' -OutputDirectory 'docs/api'

        # Assert
        $result.OutputDirectory | Should -BeNullOrEmpty
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_MODE_CONFLICT')
        $result.Finding[0]['pointer'] | Should -BeExactly '/diataxis_policy/modes'
    }
}

Describe 'Test-DocsReferencePathCovered' {
    It 'returns <Expected> for path <Path> and pattern <Pattern>' -ForEach @(
        @{ Path = 'docs/reference'; Pattern = 'docs/reference'; Expected = $true }
        @{ Path = 'docs/reference/a.md'; Pattern = 'docs/reference'; Expected = $true }
        @{ Path = 'docs/referenceX/a.md'; Pattern = 'docs/reference'; Expected = $false }
        @{ Path = 'docs/Reference/a.md'; Pattern = 'docs/reference'; Expected = $false }
        @{ Path = 'docs/reference/a.md'; Pattern = 'docs/*'; Expected = $true }
        @{ Path = 'docs/reference/deep/a.md'; Pattern = 'docs/*.md'; Expected = $true }
        @{ Path = 'docs/reference/a.md'; Pattern = 'docs/*.MD'; Expected = $false }
        @{ Path = 'docs/a.md'; Pattern = 'docs/?.md'; Expected = $true }
        @{ Path = 'docs/ab.md'; Pattern = 'docs/?.md'; Expected = $false }
        @{ Path = 'docs/v1/a.md'; Pattern = 'docs/v[0-9]/*'; Expected = $true }
        @{ Path = 'docs/vx/a.md'; Pattern = 'docs/v[0-9]/*'; Expected = $false }
        @{ Path = 'docs/vx/a.md'; Pattern = 'docs/v[!0-9]/*'; Expected = $true }
        @{ Path = 'docs/v1/a.md'; Pattern = 'docs/v[!0-9]/*'; Expected = $false }
        @{ Path = 'docs/a+b.md'; Pattern = 'docs/a+b.md'; Expected = $true }
        @{ Path = 'docs/aab.md'; Pattern = 'docs/a+b.*'; Expected = $false }
        @{ Path = 'docs/[x.md'; Pattern = 'docs/[x*'; Expected = $true }
        @{ Path = 'docs/a.md'; Pattern = ''; Expected = $false }
    ) {
        Test-DocsReferencePathCovered -Path $Path -Pattern $Pattern | Should -Be $Expected
    }
}

Describe 'ConvertFrom-DocsReferenceSnapshotText' {
    It 'returns the rebuilt elements ordered by element_id with no finding' {
        # Arrange
        $element = @((Get-TestElement -Declaration 'b'), (Get-TestElement -Declaration 'a'), (Get-TestElement -Kind 'config-key' -Declaration 'k'))
        [string[]] $expected = @($element | ForEach-Object { [string] $_['element_id'] })
        [Array]::Sort($expected, [System.StringComparer]::Ordinal)

        # Act
        $result = ConvertFrom-DocsReferenceSnapshotText -Text (Get-TestSnapshotText -Element $element) -ArtifactPath 'docs/snapshot.json' -ComposedSchemaSet $script:ComposedSet

        # Assert
        $result.Finding.Count | Should -Be 0
        @($result.Element | ForEach-Object { $_['element_id'] }) | Should -Be $expected
        $result.Snapshot['repository'] | Should -BeExactly 'example-repo'
    }

    It 'passes schema findings through unchanged' {
        # Act
        $result = ConvertFrom-DocsReferenceSnapshotText -Text '{"elements": [}' -ArtifactPath 'docs/snapshot.json' -ComposedSchemaSet $script:ComposedSet

        # Assert
        Get-TestCode -Finding $result.Finding | Should -Be @('DOCS_JSON_INVALID')
        $result.Snapshot | Should -BeNullOrEmpty
        $result.Element.Count | Should -Be 0
    }

    It 'reports a schema violation as DOCS_SCHEMA_INVALID' {
        # Act
        $result = ConvertFrom-DocsReferenceSnapshotText -Text '{"artifact_kind": "surface-inventory-snapshot"}' -ArtifactPath 'docs/snapshot.json' -ComposedSchemaSet $script:ComposedSet

        # Assert
        @(Get-TestCode -Finding $result.Finding | Where-Object { -not $_.StartsWith('DOCS_SCHEMA_') }).Count | Should -Be 0
        $result.Finding.Count | Should -BeGreaterThan 0
    }

    It 'reports REFERENCE_SNAPSHOT_INVALID for a repeated element_id' {
        # Arrange
        $first = Get-TestElement -Declaration 'a'
        $second = Get-TestElement -Declaration 'a'
        $second['name'] = 'other name'

        # Act
        $result = ConvertFrom-DocsReferenceSnapshotText -Text (Get-TestSnapshotText -Element @($first, $second)) -ArtifactPath 'docs/snapshot.json' -ComposedSchemaSet $script:ComposedSet

        # Assert
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_SNAPSHOT_INVALID')
        $result.Finding[0]['pointer'] | Should -BeExactly '/elements/1/element_id'
        $result.Element.Count | Should -Be 0
    }

    It 'reports REFERENCE_SNAPSHOT_INVALID for a repeated property name' {
        # Arrange
        $element = Get-TestElement -Declaration 'a' -Property ([ordered]@{ type = 'int' })
        $element['properties'] = [object[]]@([ordered]@{ name = 'type'; value = 'int' }, [ordered]@{ name = 'type'; value = 'str' })

        # Act
        $result = ConvertFrom-DocsReferenceSnapshotText -Text (Get-TestSnapshotText -Element @($element)) -ArtifactPath 'docs/snapshot.json' -ComposedSchemaSet $script:ComposedSet

        # Assert
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_SNAPSHOT_INVALID')
        $result.Finding[0]['pointer'] | Should -BeExactly '/elements/0/properties/1/name'
    }

    It 'reports REFERENCE_SNAPSHOT_INVALID for an element that cannot be rebuilt' {
        # Arrange
        $element = Get-TestElement -Declaration 'a'
        $element['declaration'] = 'changed'

        # Act
        $result = ConvertFrom-DocsReferenceSnapshotText -Text (Get-TestSnapshotText -Element @($element)) -ArtifactPath 'docs/snapshot.json' -ComposedSchemaSet $script:ComposedSet

        # Assert
        Get-TestCode -Finding $result.Finding | Should -Be @('REFERENCE_SNAPSHOT_INVALID')
        $result.Finding[0]['pointer'] | Should -BeExactly '/elements/0'
        $result.Finding[0]['message'] | Should -Match 'DOCS_ELEMENT_ID_MISMATCH'
    }
}
