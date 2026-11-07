#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for scripts/dev-tools/ProcessReductionChain.psm1 (issue #1097).

.DESCRIPTION
    Fixtures are in-memory strings built here, and no test creates a file. The read-seam
    test mocks the ledger reader and the filesystem cmdlets inside InModuleScope, so the
    mocks hold under a PoshQC-hosted run.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    Import-Module (Join-Path $script:RepoRoot 'scripts/dev-tools/ProcessReductionChain.psm1') -Force

    $script:Fence = '`' * 4

    function Get-TestPatchSection {
        param([string] $Path, [int] $Start, [string[]] $Before = @(), [string[]] $Removed = @(), [string[]] $Added = @(), [string[]] $After = @())
        $old = $Before.Count + $Removed.Count + $After.Count
        $new = $Before.Count + $Added.Count + $After.Count
        $lines = @("diff --git a/$Path b/$Path", "--- a/$Path", "+++ b/$Path", "@@ -$Start,$old +$Start,$new @@")
        $lines += @($Before | ForEach-Object { " $_" })
        $lines += @($Removed | ForEach-Object { "-$_" })
        $lines += @($Added | ForEach-Object { "+$_" })
        $lines += @($After | ForEach-Object { " $_" })
        $lines -join "`n"
    }

    function Get-TestBlock {
        param([string] $Path, [string] $Current, [string] $Prior)
        "### Revert Block: $Path`n`n$($script:Fence)Current`n$Current`n$($script:Fence)`n`n$($script:Fence)Prior`n$Prior`n$($script:Fence)`n"
    }

    function Get-TestEntry {
        param([string] $Name, [string[]] $Block = @(), [switch] $Patch)
        $text = "# $Name`n`n## Summary`n`nA sample entry.`n"
        if ($Patch) {
            $text += "`n## Stored Patch`n`n``patches/$([System.IO.Path]::GetFileNameWithoutExtension($Name)).patch```n"
        }
        if ($Block.Count -gt 0) {
            $text += "`n## Prior Text`n`n" + ($Block -join "`n")
        }
        [pscustomobject]@{ Name = $Name; Text = $text }
    }

    function Get-TestHunk {
        param([string[]] $Current, [string[]] $Prior, [int] $Start = 1)
        [pscustomobject]@{ Path = 'docs/a.md'; Kind = 'modify'; Current = $Current; Prior = $Prior; Start = $Start }
    }
}

AfterAll {
    Remove-Module ProcessReductionChain -ErrorAction SilentlyContinue
}

Describe 'Get-ProcessReductionPatchHunk' {
    It 'PRC-HUNK-PARSES-SECTIONS reads two hunks, a spaced path, a create, a delete, and the no-newline marker' {
        # Arrange
        $spaced = 'docs/my file.md'
        $patch = @(
            (Get-TestPatchSection -Path 'docs/a.md' -Start 2 -Before @('one') -Removed @('two') -Added @('TWO') -After @('three')),
            '@@ -10,2 +10,3 @@',
            ' ten',
            '+ten and a half',
            ' eleven',
            "diff --git a/$spaced b/$spaced",
            "--- a/$spaced`t",
            "+++ b/$spaced`t",
            '@@ -1 +1 @@',
            '-old last',
            '\ No newline at end of file',
            '+new last',
            '\ No newline at end of file',
            'diff --git a/docs/new.md b/docs/new.md',
            'new file mode 100644',
            'index 000000000..1111111',
            '--- /dev/null',
            '+++ b/docs/new.md',
            '@@ -0,0 +1,2 @@',
            '+created one',
            '+created two',
            'diff --git a/docs/old.md b/docs/old.md',
            'deleted file mode 100644',
            '--- a/docs/old.md',
            '+++ /dev/null',
            '@@ -1 +0,0 @@',
            '-removed line'
        ) -join "`n"

        # Act
        $hunks = @(Get-ProcessReductionPatchHunk -PatchText $patch)

        # Assert
        $hunks.Count | Should -Be 5
        $hunks[0].Path | Should -BeExactly 'docs/a.md'
        $hunks[0].Kind | Should -BeExactly 'modify'
        $hunks[0].Start | Should -Be 2
        $hunks[0].Current | Should -Be @('one', 'TWO', 'three')
        $hunks[0].Prior | Should -Be @('one', 'two', 'three')
        $hunks[1].Start | Should -Be 10
        $hunks[1].Current | Should -Be @('ten', 'ten and a half', 'eleven')
        $hunks[1].Prior | Should -Be @('ten', 'eleven')
        $hunks[2].Path | Should -BeExactly $spaced -Because 'the tab git appends to a spaced name is removed'
        $hunks[2].Current | Should -Be @('new last')
        $hunks[2].Prior | Should -Be @('old last')
        $hunks[3].Kind | Should -BeExactly 'create'
        $hunks[3].Path | Should -BeExactly 'docs/new.md'
        $hunks[3].Prior.Count | Should -Be 0
        $hunks[4].Kind | Should -BeExactly 'delete'
        $hunks[4].Path | Should -BeExactly 'docs/old.md'
        $hunks[4].Prior | Should -Be @('removed line')
    }

    It 'PRC-HUNK-REJECTS-UNSUPPORTED throws naming the section for a <Case>' -ForEach @(
        @{ Case = 'binary section'; Line = 'GIT binary patch'; Pattern = '*diff --git a/img.png b/img.png*binary*' },
        @{ Case = 'quoted path'; Line = '--- "a/img\tname.png"'; Pattern = '*diff --git a/img.png b/img.png*quoted*' },
        @{ Case = 'malformed hunk line'; Line = "--- a/img.png`n+++ b/img.png`n@@ -1 +1 @@`n?odd"; Pattern = '*malformed hunk line*' },
        @{ Case = 'hunk before its headers'; Line = '@@ -1 +1 @@'; Pattern = '*before its --- and +++ lines*' }
    ) {
        $patch = "diff --git a/img.png b/img.png`n$Line"

        { Get-ProcessReductionPatchHunk -PatchText $patch } | Should -Throw -ExpectedMessage $Pattern
    }
}

Describe 'Invoke-ProcessReductionHunkRevert' {
    It 'PRC-HUNK-REVERT-RESTORES-PREIMAGE replaces the Current lines with the Prior lines' {
        $hunk = Get-TestHunk -Current @('one', 'TWO', 'three') -Prior @('one', 'two', 'three') -Start 2

        $result = Invoke-ProcessReductionHunkRevert -Text "zero`r`none`r`nTWO`r`nthree`r`nfour`r`n" -Hunk $hunk

        $result | Should -BeExactly "zero`none`ntwo`nthree`nfour`n"
    }

    It 'PRC-HUNK-REVERT-LINE-ALIGNED does not match Current inside a longer line' {
        $hunk = Get-TestHunk -Current @('beta') -Prior @('gamma')

        { Invoke-ProcessReductionHunkRevert -Text "alphabeta`nbeta-rule`n" -Hunk $hunk } | Should -Throw -ExpectedMessage '*was not found*'
    }

    It 'PRC-HUNK-REVERT-NEAREST-OCCURRENCE replaces the occurrence nearest the recorded start' {
        $hunk = Get-TestHunk -Current @('same') -Prior @('restored') -Start 5

        $result = Invoke-ProcessReductionHunkRevert -Text "same`na`nb`nc`nsame`nd" -Hunk $hunk

        $result | Should -BeExactly "same`na`nb`nc`nrestored`nd"
    }

    It 'PRC-HUNK-REVERT-NEAREST-OCCURRENCE throws when two occurrences are equally near' {
        $hunk = Get-TestHunk -Current @('same') -Prior @('restored') -Start 3

        { Invoke-ProcessReductionHunkRevert -Text "same`na`nb`nc`nsame" -Hunk $hunk } | Should -Throw -ExpectedMessage '*twice at the same distance*'
    }

    It 'PRC-HUNK-REVERT-THROWS-WHEN-ABSENT throws for <Case>' -ForEach @(
        @{ Case = 'Current text that is absent'; Current = @('missing'); Pattern = '*was not found*' },
        @{ Case = 'a hunk with no Current lines'; Current = @(); Pattern = '*has no Current lines*' }
    ) {
        $hunk = Get-TestHunk -Current $Current -Prior @('old')

        { Invoke-ProcessReductionHunkRevert -Text "present`n" -Hunk $hunk } | Should -Throw -ExpectedMessage $Pattern
    }
}

Describe 'Get-ProcessReductionDerivedSource' {
    It 'PRC-DERIVED-MAPS-<Case> returns <Expected>' -ForEach @(
        @{ Case = 'CLAUDE-BUNDLE'; Path = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/x/SKILL.md'; Source = '.claude/skills/x/SKILL.md'; Same = $true; Expected = '.claude/skills/x/SKILL.md' },
        @{ Case = 'AGENTS-BUNDLE'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/x/SKILL.md'; Source = '.agents/skills/x/SKILL.md'; Same = $true; Expected = '.agents/skills/x/SKILL.md' },
        @{ Case = 'GITHUB-BUNDLE'; Path = 'extensions/drm-copilot/resources/customizations/.github/prompts/p.prompt.md'; Source = '.github/prompts/p.prompt.md'; Same = $true; Expected = '.github/prompts/p.prompt.md' },
        @{ Case = 'FEATURE-TEMPLATES'; Path = 'extensions/drm-copilot/resources/feature-templates/bug/plan.md'; Source = 'docs/features/templates/bug/plan.md'; Same = $true; Expected = 'docs/features/templates/bug/plan.md' },
        @{ Case = 'TEMPLATES'; Path = 'extensions/drm-copilot/resources/templates/policy_audit/AGENTS.md'; Source = 'docs/features/templates/policy_audit/AGENTS.md'; Same = $true; Expected = 'docs/features/templates/policy_audit/AGENTS.md' },
        @{ Case = 'AGENTS-SKILL-MIRROR'; Path = '.agents/skills/x/SKILL.md'; Source = '.claude/skills/x/SKILL.md'; Same = $true; Expected = '.claude/skills/x/SKILL.md' },
        @{ Case = 'GITHUB-SKILL-MIRROR'; Path = '.github/skills/x/SKILL.md'; Source = '.claude/skills/x/SKILL.md'; Same = $true; Expected = '.claude/skills/x/SKILL.md' },
        @{ Case = 'GENERATED-VARIANT'; Path = '.codex/agents/atomic-planner-c3-elevated.toml'; Source = ''; Same = $false; Expected = 'generated' },
        @{ Case = 'GENERATED-BUNDLE-COPY'; Path = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml'; Source = ''; Same = $false; Expected = 'generated' },
        @{ Case = 'NON-IDENTICAL-COPY'; Path = '.agents/skills/x/SKILL.md'; Source = '.claude/skills/x/SKILL.md'; Same = $false; Expected = $null },
        @{ Case = 'MISSING-SOURCE'; Path = '.agents/skills/codex-only/SKILL.md'; Source = ''; Same = $false; Expected = $null },
        @{ Case = 'UNMAPPED'; Path = '.codex/agents/atomic-planner.toml'; Source = ''; Same = $false; Expected = $null }
    ) {
        # Arrange: a CRLF copy still counts as identical after line-ending normalization
        $liveText = @{ $Path = "line one`r`nline two`r`n" }
        if ($Source) {
            $liveText[$Source] = if ($Same) { "line one`nline two`n" } else { "line one`nother`n" }
        }

        # Act
        $result = Get-ProcessReductionDerivedSource -Path $Path -LiveText $liveText

        # Assert
        Should -ActualValue $result -Be $Expected
    }
}

Describe 'Invoke-ProcessReductionChain' {
    It 'PRC-CHAIN-NEWEST-FIRST reverts entries newest-first when they are supplied oldest-first' {
        $first = Get-TestEntry -Name '0001-a.md' -Block (Get-TestBlock -Path 'docs/a.md' -Current 'two' -Prior 'one')
        $second = Get-TestEntry -Name '0002-b.md' -Block (Get-TestBlock -Path 'docs/a.md' -Current 'three' -Prior 'two')

        $result = Invoke-ProcessReductionChain -Entry @($first, $second) -PatchText @{} -LiveText @{ 'docs/a.md' = "head`nthree`ntail`n" }

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.FinalText['docs/a.md'] | Should -BeExactly "head`none`ntail`n"
    }

    It 'PRC-CHAIN-REPORTS-MISSING-LATER-RECORD names the earlier entry and the path once' {
        $first = Get-TestEntry -Name '0001-a.md' -Block (Get-TestBlock -Path 'docs/a.md' -Current 'the rule' -Prior 'the old rule')

        $result = Invoke-ProcessReductionChain -Entry @($first) -PatchText @{} -LiveText @{ 'docs/a.md' = "the edited rule`n" }

        $result.IsValid | Should -BeFalse
        @($result.Errors).Count | Should -Be 1 -Because ($result.Errors -join '; ')
        $result.Errors[0] | Should -BeLike '0001-a.md: docs/a.md: *'
    }

    It 'PRC-CHAIN-IGNORES-EDIT-OUTSIDE-REGIONS keeps a later edit that lies outside every region' {
        $first = Get-TestEntry -Name '0001-a.md' -Block (Get-TestBlock -Path 'docs/a.md' -Current 'the rule' -Prior 'the old rule')

        $result = Invoke-ProcessReductionChain -Entry @($first) -PatchText @{} -LiveText @{ 'docs/a.md' = "a later line`nthe rule`n" }

        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.FinalText['docs/a.md'] | Should -BeExactly "a later line`nthe old rule`n"
    }

    It 'PRC-CHAIN-CREATED-FILE-ENDS-ABSENT removes a created file edited after creation and restores a deleted one' {
        # Arrange
        $patch = @(
            'diff --git a/docs/new.md b/docs/new.md', 'new file mode 100644', '--- /dev/null', '+++ b/docs/new.md', '@@ -0,0 +1 @@', '+created',
            'diff --git a/docs/old.md b/docs/old.md', 'deleted file mode 100644', '--- a/docs/old.md', '+++ /dev/null', '@@ -1 +0,0 @@', '-kept'
        ) -join "`n"
        $entry = Get-TestEntry -Name '0001-a.md' -Patch
        $liveText = @{ 'docs/new.md' = "created`nedited later`n"; 'docs/old.md' = $null }

        # Act
        $result = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{ '0001-a.patch' = $patch } -LiveText $liveText

        # Assert
        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.FinalText['docs/new.md'] | Should -BeNullOrEmpty
        $result.FinalText.ContainsKey('docs/new.md') | Should -BeTrue
        $result.FinalText['docs/old.md'] | Should -BeExactly "kept`n"
    }

    It 'PRC-CHAIN-ENTRY-TEXT-FROM-CHAIN-STATE parses an earlier entry from the text a later patch restored' {
        # Arrange: entry 0002's patch changed 'new' to 'newer' in docs/a.md and in entry 0001's Current fence
        $entryPath = 'docs/engineering/process-reductions/0001-a.md'
        $first = Get-TestEntry -Name '0001-a.md' -Block (Get-TestBlock -Path 'docs/a.md' -Current 'newer' -Prior 'old')
        $second = Get-TestEntry -Name '0002-b.md' -Patch
        $fenceStart = @($first.Text.Split("`n")).IndexOf("$($script:Fence)Current") + 1
        $patch = @(
            (Get-TestPatchSection -Path 'docs/a.md' -Start 1 -Removed @('new') -Added @('newer')),
            (Get-TestPatchSection -Path $entryPath -Start $fenceStart -Before @("$($script:Fence)Current") -Removed @('new') -Added @('newer'))
        ) -join "`n"
        $liveText = @{ 'docs/a.md' = "newer`n"; $entryPath = $first.Text }

        # Act
        $result = Invoke-ProcessReductionChain -Entry @($first, $second) -PatchText @{ '0002-b.patch' = $patch } -LiveText $liveText

        # Assert
        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.FinalText['docs/a.md'] | Should -BeExactly "old`n"
    }

    It 'PRC-CHAIN-PATCH-ENTRY-BLOCKS-CONSISTENT reports a patch entry block whose <Side> text is absent' -ForEach @(
        @{ Side = 'Current'; Current = 'not in the file'; Prior = '' },
        @{ Side = 'Prior'; Current = 'new'; Prior = 'never restored' }
    ) {
        $patch = Get-TestPatchSection -Path 'docs/a.md' -Start 1 -Removed @('old') -Added @('new')
        $entry = Get-TestEntry -Name '0001-a.md' -Patch -Block (Get-TestBlock -Path 'docs/a.md' -Current $Current -Prior $Prior)

        $result = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{ '0001-a.patch' = $patch } -LiveText @{ 'docs/a.md' = "new`n" }

        @($result.Errors).Count | Should -Be 1 -Because ($result.Errors -join '; ')
        $result.Errors[0] | Should -BeLike "0001-a.md: docs/a.md: the revert block $Side text is absent*"
    }

    It 'PRC-CHAIN-SKIPS-DERIVED-PATHS leaves a byte-identical mirror and a generated variant to revert steps 2 and 3' {
        # Arrange: the mirror and variant sections are stale, so reverting them would fail
        $patch = @(
            (Get-TestPatchSection -Path '.claude/skills/x/SKILL.md' -Start 1 -Removed @('old') -Added @('new')),
            (Get-TestPatchSection -Path '.agents/skills/x/SKILL.md' -Start 1 -Removed @('old') -Added @('stale')),
            (Get-TestPatchSection -Path '.codex/agents/x-c1.toml' -Start 1 -Removed @('old') -Added @('stale'))
        ) -join "`n"
        $entry = Get-TestEntry -Name '0001-a.md' -Patch
        $liveText = @{ '.claude/skills/x/SKILL.md' = "new`n"; '.agents/skills/x/SKILL.md' = "new`n"; '.codex/agents/x-c1.toml' = "new`n" }

        # Act
        $result = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{ '0001-a.patch' = $patch } -LiveText $liveText

        # Assert
        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.FinalText['.claude/skills/x/SKILL.md'] | Should -BeExactly "old`n"
        $result.FinalText['.agents/skills/x/SKILL.md'] | Should -BeExactly "new`n"
        $result.FinalText['.codex/agents/x-c1.toml'] | Should -BeExactly "new`n"
    }

    It 'PRC-CHAIN-END-STATE-PREIMAGES reports a pre-image of the oldest entry that is missing at the end' {
        $blocks = @((Get-TestBlock -Path 'docs/a.md' -Current 'b' -Prior 'x'), (Get-TestBlock -Path 'docs/a.md' -Current 'x' -Prior 'y'))
        $entry = Get-TestEntry -Name '0001-a.md' -Block $blocks

        $result = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{} -LiveText @{ 'docs/a.md' = "a`nb`n" }

        @($result.Errors).Count | Should -Be 1 -Because ($result.Errors -join '; ')
        $result.Errors[0] | Should -BeExactly '0001-a.md: docs/a.md: the end state lacks a pre-image of the entry.'
    }

    It 'PRC-CHAIN-REPORTS-UNLEDGERED-CONTEXT-EDIT reports a line added inside hunk context and accepts the rebased hunk' {
        # Arrange: a commit with no entry added 'added rule' between the hunk's context lines
        $entry = Get-TestEntry -Name '0001-a.md' -Patch
        $live = @{ 'docs/a.md' = "first`nadded rule`nsecond`nnew`nthird`n" }
        $stale = Get-TestPatchSection -Path 'docs/a.md' -Start 1 -Before @('first', 'second') -Removed @('old') -Added @('new') -After @('third')
        $rebased = Get-TestPatchSection -Path 'docs/a.md' -Start 1 -Before @('first', 'added rule', 'second') -Removed @('old') -Added @('new') -After @('third')

        # Act
        $staleResult = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{ '0001-a.patch' = $stale } -LiveText $live
        $rebasedResult = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{ '0001-a.patch' = $rebased } -LiveText $live

        # Assert
        @($staleResult.Errors).Count | Should -Be 1 -Because ($staleResult.Errors -join '; ')
        $staleResult.Errors[0] | Should -BeLike '0001-a.md: docs/a.md: *was not found*'
        $rebasedResult.IsValid | Should -BeTrue -Because ($rebasedResult.Errors -join '; ')
        $rebasedResult.FinalText['docs/a.md'] | Should -BeExactly "first`nadded rule`nsecond`nold`nthird`n"
    }

    It 'PRC-CHAIN-REPORTS-STEP-FAILURES names <Case>' -ForEach @(
        @{ Case = 'a stored patch that was not supplied'; PatchName = 'other.patch'; PatchBody = ''; Live = "new`n"; Pattern = '0001-a.md: patches/0001-a.patch: the stored patch was not supplied.' },
        @{ Case = 'a stored patch that does not parse'; PatchName = '0001-a.patch'; PatchBody = "diff --git a/x b/x`nGIT binary patch"; Live = "new`n"; Pattern = '0001-a.md: patches/0001-a.patch: *binary*' },
        @{ Case = 'a modified file that is absent'; PatchName = '0001-a.patch'; PatchBody = 'MODIFY'; Live = $null; Pattern = '0001-a.md: docs/a.md: the file is absent at this step.' },
        @{ Case = 'a deleted file that exists'; PatchName = '0001-a.patch'; PatchBody = "diff --git a/docs/a.md b/docs/a.md`ndeleted file mode 100644`n--- a/docs/a.md`n+++ /dev/null`n@@ -1 +0,0 @@`n-old"; Live = "new`n"; Pattern = '0001-a.md: docs/a.md: the file the entry deleted exists at this step.' }
    ) {
        $body = if ($PatchBody -ceq 'MODIFY') { Get-TestPatchSection -Path 'docs/a.md' -Start 1 -Removed @('old') -Added @('new') } else { $PatchBody }
        $entry = Get-TestEntry -Name '0001-a.md' -Patch

        $result = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{ $PatchName = $body } -LiveText @{ 'docs/a.md' = $Live }

        $result.IsValid | Should -BeFalse
        $result.Errors[0] | Should -BeLike $Pattern
    }

    It 'PRC-CHAIN-REPORTS-STEP-FAILURES names a block whose file is absent' {
        $entry = Get-TestEntry -Name '0001-a.md' -Block (Get-TestBlock -Path 'docs/a.md' -Current 'new' -Prior 'old')

        $result = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{} -LiveText @{}

        @($result.Errors).Count | Should -Be 1 -Because ($result.Errors -join '; ')
        $result.Errors[0] | Should -BeExactly '0001-a.md: docs/a.md: the file is absent at this step.'
    }
}

Describe 'Read-ProcessReductionChainInput' {
    It 'PRC-READ-COLLECTS-INPUT reads patch-only, block-only, and mapped source paths, with $null for a missing file' {
        InModuleScope ProcessReductionChain {
            # Arrange: mock bodies build their own text, because they do not see test variables
            $bundle = 'extensions/drm-copilot/resources/customizations/.github/prompts/p.prompt.md'
            Mock Read-ProcessReductionLedger {
                $fence = '`' * 4
                $text = "## Prior Text`n`n### Revert Block: docs/block-only.md`n`n${fence}Current`nnew`n${fence}`n`n${fence}Prior`nold`n${fence}`n"
                [pscustomobject]@{ IndexText = ''; Entries = @([pscustomobject]@{ Name = '0001-a.md'; Text = $text }); PatchNames = @('0001-a.patch') }
            }
            Mock Test-Path { $LiteralPath -notlike '*missing*' }
            Mock Get-Content {
                $path = 'extensions/drm-copilot/resources/customizations/.github/prompts/p.prompt.md'
                "diff --git a/$path b/$path`n--- a/$path`n+++ b/$path`n@@ -1 +1 @@`n-old`n+new`ndiff --git a/docs/missing.md b/docs/missing.md`n--- a/docs/missing.md`n+++ b/docs/missing.md`n@@ -1 +1 @@`n-old`n+new"
            } -ParameterFilter { $LiteralPath -like '*.patch' }
            Mock Get-Content { 'live ' + ($LiteralPath -replace '\\', '/') } -ParameterFilter { $LiteralPath -notlike '*.patch' }

            # Act
            $chainInput = Read-ProcessReductionChainInput -RepositoryRoot 'repo-root'

            # Assert
            @($chainInput.Entries).Count | Should -Be 1
            $chainInput.PatchText['0001-a.patch'] | Should -BeLike "diff --git a/$bundle*"
            $chainInput.LiveText[$bundle] | Should -BeLike "live repo-root*/$bundle"
            $chainInput.LiveText['docs/block-only.md'] | Should -BeLike 'live repo-root*/docs/block-only.md'
            $chainInput.LiveText['.github/prompts/p.prompt.md'] | Should -BeLike 'live repo-root*/.github/prompts/p.prompt.md' -Because 'the mapped source of a bundle path is read'
            $chainInput.LiveText['docs/engineering/process-reductions/0001-a.md'] | Should -BeLike 'live repo-root*'
            $chainInput.LiveText.ContainsKey('docs/missing.md') | Should -BeTrue
            $chainInput.LiveText['docs/missing.md'] | Should -BeNullOrEmpty
            Should -Invoke Read-ProcessReductionLedger -Times 1 -Exactly -ParameterFilter { $LedgerPath -like 'repo-root*process-reductions' }
        }
    }
}

Describe 'Later landings' {
    It 'PRC-LANDING-SPLITS-PRIOR-TEXT returns two later landings last heading first, then first, and ignores a fenced heading' {
        # Arrange: the #3 block's Current holds a heading line inside its fence
        $blocks = @((Get-TestBlock -Path 'docs/a.md' -Current 'a1' -Prior 'a0'), '### Later Landing: #2', '', (Get-TestBlock -Path 'docs/b.md' -Current 'b1' -Prior 'b0'), '### Later Landing: #3', '', (Get-TestBlock -Path 'docs/c.md' -Current '### Later Landing: #4' -Prior 'c0'))
        $entry = Get-TestEntry -Name '0001-a.md' -Block $blocks

        # Act
        $landings = @(Get-ProcessReductionLanding -Text $entry.Text)
        $bare = @(Get-ProcessReductionLanding -Text (Get-TestEntry -Name '0002-b.md' -Patch).Text)

        # Assert
        @($landings | ForEach-Object { $_.Label }) | Should -Be @('#3', '#2', 'first')
        @($landings[0].Block).Count | Should -Be 1
        $landings[0].Block[0].Current | Should -BeExactly '### Later Landing: #4'
        $landings[1].Block[0].Path | Should -BeExactly 'docs/b.md'
        $landings[2].Block[0].Path | Should -BeExactly 'docs/a.md'
        $bare.Count | Should -Be 1 -Because 'an entry with no Prior Text has only its first landing'
        $bare[0].Label | Should -BeExactly 'first'
        @($bare[0].Block).Count | Should -Be 0
    }

    It 'PRC-LANDING-EMPTY-THROWS throws naming a later landing with no block, and the chain reports it' {
        # Arrange
        $entry = Get-TestEntry -Name '0001-a.md' -Block @((Get-TestBlock -Path 'docs/a.md' -Current 'a1' -Prior 'a0'), '### Later Landing: #2', '', 'Prose only.')

        # Act
        $result = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{} -LiveText @{ 'docs/a.md' = "a1`n" }

        # Assert
        { Get-ProcessReductionLanding -Text $entry.Text } | Should -Throw "*Later landing '#2' holds no revert block*"
        @($result.Errors).Count | Should -Be 1 -Because ($result.Errors -join '; ')
        $result.Errors[0] | Should -BeExactly "0001-a.md: Later landing '#2' holds no revert block."
    }

    It 'PRC-CHAIN-LATER-LANDING-OVERLAPS-OWN-PATCH reverts a later landing over its own patch hunk before the patch' {
        # Arrange: the patch changed 'old' to 'new', and the later landing changed 'new' to 'newer'
        $patch = @{ '0001-a.patch' = (Get-TestPatchSection -Path 'docs/a.md' -Start 1 -Removed @('old') -Added @('new')) }
        $block = Get-TestBlock -Path 'docs/a.md' -Current 'newer' -Prior 'new'
        $withHeading = Get-TestEntry -Name '0001-a.md' -Patch -Block @('### Later Landing: #2', '', $block)
        $withoutHeading = Get-TestEntry -Name '0001-a.md' -Patch -Block @($block)
        $live = @{ 'docs/a.md' = "newer`n" }

        # Act
        $headed = Invoke-ProcessReductionChain -Entry @($withHeading) -PatchText $patch -LiveText $live
        $unheaded = Invoke-ProcessReductionChain -Entry @($withoutHeading) -PatchText $patch -LiveText $live

        # Assert
        $headed.IsValid | Should -BeTrue -Because ($headed.Errors -join '; ')
        $headed.FinalText['docs/a.md'] | Should -BeExactly "old`n"
        $unheaded.IsValid | Should -BeFalse
        @($unheaded.Errors | Where-Object { $_ -like '0001-a.md: docs/a.md: *' }).Count | Should -BeGreaterThan 0 -Because ($unheaded.Errors -join '; ')
    }

    It 'PRC-CHAIN-LATER-LANDINGS-NEWEST-FIRST reverts the last later landing first, then the earlier one, then the first landing' {
        # Arrange: v0 to v1 first, v1 to v2 in #2, v2 to v3 in #3
        $blocks = @((Get-TestBlock -Path 'docs/a.md' -Current 'v1' -Prior 'v0'), '### Later Landing: #2', '', (Get-TestBlock -Path 'docs/a.md' -Current 'v2' -Prior 'v1'), '### Later Landing: #3', '', (Get-TestBlock -Path 'docs/a.md' -Current 'v3' -Prior 'v2'))
        $entry = Get-TestEntry -Name '0001-a.md' -Block $blocks

        # Act
        $result = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{} -LiveText @{ 'docs/a.md' = "v3`n" }

        # Assert
        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.FinalText['docs/a.md'] | Should -BeExactly "v0`n"
    }

    It 'PRC-CHAIN-LATER-LANDING-ON-BLOCK-ENTRY reverts a block entry later landing and prefixes its errors with the label' {
        # Arrange
        $entry = Get-TestEntry -Name '0001-a.md' -Block @((Get-TestBlock -Path 'docs/a.md' -Current 'a1' -Prior 'a0'), '### Later Landing: #2', '', (Get-TestBlock -Path 'docs/b.md' -Current 'b1' -Prior 'b0'))

        # Act
        $valid = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{} -LiveText @{ 'docs/a.md' = "a1`n"; 'docs/b.md' = "b1`n" }
        $broken = Invoke-ProcessReductionChain -Entry @($entry) -PatchText @{} -LiveText @{ 'docs/a.md' = "a1`n"; 'docs/b.md' = "moved`n" }

        # Assert
        $valid.IsValid | Should -BeTrue -Because ($valid.Errors -join '; ')
        $valid.FinalText['docs/a.md'] | Should -BeExactly "a0`n"
        $valid.FinalText['docs/b.md'] | Should -BeExactly "b0`n"
        @($broken.Errors).Count | Should -Be 1 -Because ($broken.Errors -join '; ')
        $broken.Errors[0] | Should -BeExactly "0001-a.md (later landing #2): docs/b.md: Current text of revert block 'docs/b.md' was not found."
    }

    It 'PRC-CHAIN-LATER-LANDING-OVER-HIGHER-ENTRY-FAILS reports a later landing that edited a region a higher entry records' {
        # Arrange: 0001 x0 to x1, 0002 x1 to x2, then a later landing of 0001 x2 to x3
        $first = Get-TestEntry -Name '0001-a.md' -Block @((Get-TestBlock -Path 'docs/a.md' -Current 'x1' -Prior 'x0'), '### Later Landing: #3', '', (Get-TestBlock -Path 'docs/a.md' -Current 'x3' -Prior 'x2'))
        $second = Get-TestEntry -Name '0002-b.md' -Block (Get-TestBlock -Path 'docs/a.md' -Current 'x2' -Prior 'x1')

        # Act
        $result = Invoke-ProcessReductionChain -Entry @($first, $second) -PatchText @{} -LiveText @{ 'docs/a.md' = "x3`n" }

        # Assert
        $result.IsValid | Should -BeFalse
        @($result.Errors | Where-Object { $_ -like '0002-b.md: docs/a.md: *' }).Count | Should -Be 1 -Because ($result.Errors -join '; ')
    }

    It 'PRC-CHAIN-STOP-BEFORE stops after the named entry later landings and before its patch, and rejects an unknown name' {
        # Arrange
        $patch = @{ '0001-a.patch' = (Get-TestPatchSection -Path 'docs/a.md' -Start 1 -Removed @('old') -Added @('new')) }
        $first = Get-TestEntry -Name '0001-a.md' -Patch -Block @('### Later Landing: #2', '', (Get-TestBlock -Path 'docs/a.md' -Current 'newer' -Prior 'new'))
        $second = Get-TestEntry -Name '0002-b.md' -Block (Get-TestBlock -Path 'docs/c.md' -Current 'c1' -Prior 'c0')
        $live = @{ 'docs/a.md' = "newer`n"; 'docs/c.md' = "c1`n" }

        # Act
        $result = Invoke-ProcessReductionChain -Entry @($first, $second) -PatchText $patch -LiveText $live -StopBefore '0001-a.md'

        # Assert
        $result.IsValid | Should -BeTrue -Because ($result.Errors -join '; ')
        $result.FinalText['docs/a.md'] | Should -BeExactly "new`n" -Because 'the later landing is reverted and the patch is not'
        $result.FinalText['docs/c.md'] | Should -BeExactly "c0`n"
        { Invoke-ProcessReductionChain -Entry @($first, $second) -PatchText $patch -LiveText $live -StopBefore '0009-z.md' } | Should -Throw "*StopBefore '0009-z.md' names no supplied entry*"
    }
}
