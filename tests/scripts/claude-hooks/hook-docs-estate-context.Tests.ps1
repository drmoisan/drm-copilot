#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the pure docs-estate predicates in .claude/hooks/hook-docs-estate-context.ps1
    (issue #1169).

.DESCRIPTION
    Dot-sources hook-cleanup-context.ps1 (the call-time source of
    Test-CleanupConsolidationRelativePath), hook-docs-only-diff.ps1 (the docs-init workflow
    constant), and the file under test, and removes every function they define in AfterAll. No row
    reads or writes a file, starts a process, or sets an environment variable.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:LoadedFiles = @('hook-cleanup-context.ps1', 'hook-docs-only-diff.ps1', 'hook-docs-estate-context.ps1') | ForEach-Object { Join-Path $script:RepoRoot ".claude/hooks/$_" }
    foreach ($file in $script:LoadedFiles) { . $file }

    function Get-TestProfileText {
        param(
            [object] $Kind = 'docs-profile',
            [object] $Roots = @(@{ id = 'docs-root'; path = 'docs' }),
            [object] $ArtifactPaths = @{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json'; inventory_snapshot = 'docs/documentation-estate/surface-inventory-snapshot.json' }
        )
        return ([ordered]@{ artifact_kind = $Kind; documentation_roots = $Roots; artifact_paths = $ArtifactPaths } | ConvertTo-Json -Depth 6 -Compress)
    }
}

AfterAll {
    foreach ($file in $script:LoadedFiles) {
        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors)
        foreach ($definition in $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) {
            Remove-Item -LiteralPath ('Function:\' + $definition.Name) -ErrorAction SilentlyContinue
        }
    }
}

Describe 'ConvertFrom-DocsEstateProfileText (issue #1169)' {
    It 'returns the profile object for a structurally valid profile' {
        # Act
        $result = ConvertFrom-DocsEstateProfileText -Text (Get-TestProfileText)

        # Assert
        $result | Should -Not -BeNullOrEmpty
        $result['artifact_kind'] | Should -BeExactly 'docs-profile'
    }

    It 'returns $null for <Case>' -ForEach @(
        @{ Case = 'null text'; Text = $null }
        @{ Case = 'empty text'; Text = '' }
        @{ Case = 'malformed JSON'; Text = '{"artifact_kind":' }
        @{ Case = 'a JSON array'; Text = '[1]' }
        @{ Case = 'another artifact kind'; Text = '{"artifact_kind":"docs-receipt","documentation_roots":[{"path":"docs"}],"artifact_paths":{}}' }
        @{ Case = 'an upper-case artifact kind'; Text = '{"artifact_kind":"Docs-Profile","documentation_roots":[{"path":"docs"}],"artifact_paths":{}}' }
        @{ Case = 'an empty documentation_roots array'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[],"artifact_paths":{}}' }
        @{ Case = 'a documentation root that is not an object'; Text = '{"artifact_kind":"docs-profile","documentation_roots":["docs"],"artifact_paths":{}}' }
        @{ Case = 'a rooted documentation root path'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[{"path":"/docs"}],"artifact_paths":{}}' }
        @{ Case = 'a documentation root path with ..'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[{"path":"docs/../src"}],"artifact_paths":{}}' }
        @{ Case = 'a documentation root path with a backslash'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[{"path":"docs\\a"}],"artifact_paths":{}}' }
        @{ Case = 'artifact_paths that is not an object'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[{"path":"docs"}],"artifact_paths":["a"]}' }
        @{ Case = 'a non-string artifact path'; Text = '{"artifact_kind":"docs-profile","documentation_roots":[{"path":"docs"}],"artifact_paths":{"validation_receipt":1}}' }
    ) {
        # Act
        $result = ConvertFrom-DocsEstateProfileText -Text $Text

        # Assert
        $null -eq $result | Should -BeTrue -Because "a profile with $Case is not structurally valid"
    }
}

Describe 'Test-DocsEstatePath (issue #1169)' {
    BeforeAll {
        $script:Profile1169 = ConvertFrom-DocsEstateProfileText -Text (Get-TestProfileText -Roots @(@{ path = 'docs' }, @{ path = 'guide' }) -ArtifactPaths @{ validation_receipt = 'estate/docs-validation-receipt.json'; flat = 'receipt.json' })
    }

    It 'admits <Label>' -ForEach @(
        @{ Label = 'a path under the docs/ root'; Path = 'docs/reference/a.md' }
        @{ Label = 'a non-Markdown path under the docs/ root'; Path = 'docs/documentation-estate/.vale.ini' }
        @{ Label = 'the docs-init workflow constant'; Path = '.github/workflows/_docs-quality.yml' }
    ) {
        # Act
        $result = Test-DocsEstatePath -RelativePath $Path -Profile $script:Profile1169 -InitWorkflowPath $script:DocsOnlyInitWorkflowPath

        # Assert
        $result | Should -BeTrue -Because "$Path is in the docs path set"
    }

    It 'rejects <Label>' -ForEach @(
        @{ Label = 'a path in an artifact_paths directory outside docs/'; Path = 'estate/docs-coverage-ledger.json' }
        @{ Label = 'a .md path under a root outside docs/'; Path = 'guide/start.md' }
        @{ Label = 'a non-Markdown path under a root outside docs/'; Path = 'guide/start.txt' }
        @{ Label = 'a source path'; Path = 'src/a.ps1' }
        @{ Label = 'a root without a following segment'; Path = 'docs' }
        @{ Label = 'a prefix-sharing root'; Path = 'docsx/a.md' }
        @{ Label = 'a prefix-sharing artifact directory'; Path = 'estatex/a.json' }
        @{ Label = 'a .. segment'; Path = 'docs/../src/a.ps1' }
        @{ Label = 'a backslash'; Path = 'docs\a.md' }
        @{ Label = 'a rooted path'; Path = '/docs/a.md' }
        @{ Label = 'an upper-case root (Docs)'; Path = 'Docs/a.md' }
        @{ Label = 'an upper-case workflow name'; Path = '.github/workflows/_Docs-quality.yml' }
        @{ Label = 'a root-level file next to a flat artifact path'; Path = 'other.json' }
        @{ Label = 'an empty path'; Path = '' }
    ) {
        # Act
        $result = Test-DocsEstatePath -RelativePath $Path -Profile $script:Profile1169 -InitWorkflowPath $script:DocsOnlyInitWorkflowPath

        # Assert
        $result | Should -BeFalse -Because "'$Path' is outside the docs path set"
    }

    It 'rejects every path when the profile is $null' {
        # Act
        $result = Test-DocsEstatePath -RelativePath 'docs/a.md' -Profile $null -InitWorkflowPath $script:DocsOnlyInitWorkflowPath

        # Assert
        $result | Should -BeFalse
    }

    It 'rejects the workflow path when no workflow constant is supplied' {
        # Act
        $result = Test-DocsEstatePath -RelativePath '.github/workflows/_docs-quality.yml' -Profile $script:Profile1169 -InitWorkflowPath ''

        # Assert
        $result | Should -BeFalse
    }

    Context 'narrow profile: root docs/reference and one docs/ artifact directory' {
        BeforeAll {
            $script:NarrowProfile = ConvertFrom-DocsEstateProfileText -Text (Get-TestProfileText -Roots @(@{ path = 'docs/reference' }) -ArtifactPaths @{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json' })
            $script:NarrowFlatProfile = ConvertFrom-DocsEstateProfileText -Text (Get-TestProfileText -Roots @(@{ path = 'docs/reference' }) -ArtifactPaths @{ validation_receipt = 'docs/documentation-estate/docs-validation-receipt.json'; flat = 'receipt.json' })
        }

        It 'admits <Label> (narrow profile)' -ForEach @(
            @{ Label = 'a docs/ artifact-directory path under no root'; Path = 'docs/documentation-estate/docs-coverage-ledger.json' }
            @{ Label = 'a path under the non-docs root docs/reference'; Path = 'docs/reference/b.md' }
        ) {
            # Act
            $result = Test-DocsEstatePath -RelativePath $Path -Profile $script:NarrowProfile -InitWorkflowPath $script:DocsOnlyInitWorkflowPath

            # Assert
            $result | Should -BeTrue -Because "$Path is in the narrow profile's docs path set"
        }

        It 'rejects <Label> (narrow profile)' -ForEach @(
            @{ Label = 'a docs/ path under no root and no artifact directory'; Path = 'docs/other/a.md' }
            @{ Label = 'a prefix-sharing root'; Path = 'docs/referencex/a.md' }
            @{ Label = 'a prefix-sharing artifact directory'; Path = 'docs/documentation-estatex/a.json' }
            @{ Label = 'an upper-case root segment'; Path = 'docs/Reference/a.md' }
        ) {
            # Act
            $result = Test-DocsEstatePath -RelativePath $Path -Profile $script:NarrowProfile -InitWorkflowPath $script:DocsOnlyInitWorkflowPath

            # Assert
            $result | Should -BeFalse -Because "'$Path' is outside the narrow profile's docs path set"
        }

        It 'rejects a docs/ path under no root when a flat artifact path is present (narrow profile)' {
            # Act
            $result = Test-DocsEstatePath -RelativePath 'docs/other/a.md' -Profile $script:NarrowFlatProfile -InitWorkflowPath $script:DocsOnlyInitWorkflowPath

            # Assert
            $result | Should -BeFalse -Because 'an artifact path with no directory admits no path'
        }
    }
}

Describe 'Get-DocsEstateDelegationLabel (issue #1169)' {
    It 'returns the branch and base of a prompt with one line each' {
        # Arrange
        $prompt = "Write the PR.`nbranch: docs/estate-refresh`nbase: epic/docs-integration`nCanonical issue number for this feature is 12.`ngh pr create --head docs/estate-refresh --base epic/docs-integration"

        # Act
        $result = Get-DocsEstateDelegationLabel -PromptText $prompt

        # Assert
        $result.Branch | Should -BeExactly 'docs/estate-refresh'
        $result.Base | Should -BeExactly 'epic/docs-integration'
    }

    It 'returns $null for <Case>' -ForEach @(
        @{ Case = 'a missing branch line'; Prompt = "base: main" }
        @{ Case = 'a missing base line'; Prompt = "branch: docs/a" }
        @{ Case = 'a duplicated branch line'; Prompt = "branch: docs/a`nbranch: docs/b`nbase: main" }
        @{ Case = 'a duplicated base line'; Prompt = "branch: docs/a`nbase: main`nbase: main" }
        @{ Case = 'a second branch label inside prose'; Prompt = "branch: docs/a`nbase: main`nsee Branch: docs/b" }
        @{ Case = 'a branch value with ..'; Prompt = "branch: docs/a..b`nbase: main" }
        @{ Case = 'a base value with ..'; Prompt = "branch: docs/a`nbase: main..x" }
        @{ Case = 'a base value with a space'; Prompt = "branch: docs/a`nbase: main x" }
        @{ Case = 'a branch label that is not line-anchored'; Prompt = "label branch: docs/a`nbase: main" }
        @{ Case = 'an upper-case branch label'; Prompt = "Branch: docs/a`nbase: main" }
        @{ Case = 'an empty prompt'; Prompt = '' }
    ) {
        # Act
        $result = Get-DocsEstateDelegationLabel -PromptText $Prompt

        # Assert
        $null -eq $result | Should -BeTrue -Because "a prompt with $Case is not a valid delegation label set"
    }
}
