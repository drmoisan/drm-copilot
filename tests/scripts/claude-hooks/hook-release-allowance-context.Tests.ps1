#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pure unit table of hook-release-allowance-context.ps1 (issue #1201), both surface copies.

.DESCRIPTION
    Each surface's preimplementation gate is dot-sourced first, so the reused helpers
    (Split-OrchestrationCommandLine, ConvertTo-OrchestrationCommandToken,
    ConvertTo-OrchestrationCleanupComparablePath, Test-CommandLineTokenLiteral) resolve, and then that
    root's hook-release-allowance-context.ps1. The rows cover every parser rule (spec AC-1 and the
    remaining rules of the configuration section), branch matching (AC-2), the relevance test
    (decision AD-3), and the segment shapes of spec step 8. The functions under test are pure: no
    row reads a file, starts a process, or reads the environment.
#>

Describe 'hook-release-allowance-context.ps1 (<Surface>)' -ForEach @(
    @{ Surface = 'Claude'; GateRelativePath = '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'; ContextRelativePath = '.claude/hooks/hook-release-allowance-context.ps1'; Seam = @('Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText', 'Get-EpicScopeCheckpointText'); ExtraSeam = @('Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent') }
    @{ Surface = 'Codex'; GateRelativePath = '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'; ContextRelativePath = '.codex/hooks/hook-release-allowance-context.ps1'; Seam = @('Get-EpicScopeCheckpointText'); ExtraSeam = @('Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText') }
) {
    BeforeAll {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        . (Join-Path $repoRoot $GateRelativePath)
        . (Join-Path $repoRoot $ContextRelativePath)
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam $Seam -Surface $Surface
        Register-EpicStateBaselineMock -Seam $ExtraSeam -Surface $Surface
        $script:ReleaseRoot = '/synthetic-worktrees/release'
        $script:ValidAllowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json"]}'

        function ConvertTo-ReleaseAllowanceTestDocument {
            # Wraps one allowance object text in a valid root document.
            param([Parameter(Mandatory)][string] $Allowance)
            return '{"schema_version": 1, "allowances": [' + $Allowance + ']}'
        }

        function Get-ReleaseAllowanceTestShape {
            # Tokenizes one segment and classifies it against the synthetic root.
            param([Parameter(Mandatory)][string] $Segment)
            return Get-ReleaseAllowanceSegmentShape -Token ([string[]]@(ConvertTo-OrchestrationCommandToken -Segment $Segment)) -WorktreeRoot $script:ReleaseRoot
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface $Surface -Seam $Seam }

    Context 'ConvertFrom-ReleaseAllowanceConfig (spec AC-1)' {
        It 'accepts the example document with one allowance' {
            # Arrange
            $text = '{ "schema_version": 1, "allowances": [ { "id": "release-version-bump", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json", "CHANGELOG.md"] } ] }'

            # Act
            $result = ConvertFrom-ReleaseAllowanceConfig -Text $text

            # Assert
            $result.Valid | Should -BeTrue -Because $result.Detail
            @($result.Allowances).Count | Should -Be 1
            $result.Allowances[0].Id | Should -BeExactly 'release-version-bump'
            $result.Allowances[0].BranchPatterns | Should -Be @('release/v*')
            $result.Allowances[0].AllowedPaths | Should -Be @('package.json', 'CHANGELOG.md')
        }

        It 'rejects <Label> naming <Token>' -ForEach @(
            @{ Label = 'invalid JSON'; Text = '{'; Token = 'JSON' }
            @{ Label = 'a non-object root'; Text = '[]'; Token = 'JSON object' }
            @{ Label = 'a missing schema_version'; Text = '{"allowances": []}'; Token = "'schema_version'" }
            @{ Label = 'a missing allowances'; Text = '{"schema_version": 1}'; Token = "'allowances'" }
            @{ Label = 'an unknown root key'; Text = '{"schema_version": 1, "allowances": [], "extra": 1}'; Token = "'extra'" }
            @{ Label = 'schema_version 2'; Text = '{"schema_version": 2, "allowances": []}'; Token = 'schema_version' }
            @{ Label = 'schema_version "1"'; Text = '{"schema_version": "1", "allowances": []}'; Token = 'schema_version' }
            @{ Label = 'schema_version 1.0'; Text = '{"schema_version": 1.0, "allowances": []}'; Token = 'schema_version' }
            @{ Label = 'empty allowances'; Text = '{"schema_version": 1, "allowances": []}'; Token = 'allowances is empty' }
            @{ Label = 'allowances given as a string'; Text = '{"schema_version": 1, "allowances": "x"}'; Token = 'allowances is not an array' }
            @{ Label = 'a non-object allowance'; Text = '{"schema_version": 1, "allowances": ["x"]}'; Token = 'allowances entry 0 is not an object' }
            @{ Label = 'an unknown allowance key'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json"], "extra": 1}'; Token = "'extra'" }
            @{ Label = 'a missing id'; Allowance = '{"branch_patterns": ["release/v*"], "allowed_paths": ["package.json"]}'; Token = "'id'" }
            @{ Label = 'a missing branch_patterns'; Allowance = '{"id": "a", "allowed_paths": ["package.json"]}'; Token = "'branch_patterns'" }
            @{ Label = 'a missing allowed_paths'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"]}'; Token = "'allowed_paths'" }
            @{ Label = 'an empty id'; Allowance = '{"id": "", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json"]}'; Token = 'id is empty' }
            @{ Label = 'a whitespace-only id'; Allowance = '{"id": "   ", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json"]}'; Token = 'id is empty' }
            @{ Label = 'a non-string id'; Allowance = '{"id": 5, "branch_patterns": ["release/v*"], "allowed_paths": ["package.json"]}'; Token = 'id is not a string' }
            @{ Label = 'a duplicate id'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json"]}, {"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json"]}'; Token = "id 'a' duplicates" }
            @{ Label = 'branch_patterns given as a string'; Allowance = '{"id": "a", "branch_patterns": "release/v*", "allowed_paths": ["package.json"]}'; Token = 'branch_patterns is not an array' }
            @{ Label = 'empty branch_patterns'; Allowance = '{"id": "a", "branch_patterns": [], "allowed_paths": ["package.json"]}'; Token = 'branch_patterns is empty' }
            @{ Label = 'a non-string pattern'; Allowance = '{"id": "a", "branch_patterns": [1], "allowed_paths": ["package.json"]}'; Token = 'branch_patterns element 0 is not a string' }
            @{ Label = 'an empty-string pattern'; Allowance = '{"id": "a", "branch_patterns": [""], "allowed_paths": ["package.json"]}'; Token = "branch_patterns entry ''" }
            @{ Label = 'a pattern containing ['; Allowance = '{"id": "a", "branch_patterns": ["release/[v]*"], "allowed_paths": ["package.json"]}'; Token = "branch_patterns entry 'release/[v]*'" }
            @{ Label = 'a pattern containing a backtick'; Allowance = '{"id": "a", "branch_patterns": ["release/v`1"], "allowed_paths": ["package.json"]}'; Token = 'branch_patterns entry ''release/v`1''' }
            @{ Label = 'a pattern containing a space'; Allowance = '{"id": "a", "branch_patterns": ["release v1"], "allowed_paths": ["package.json"]}'; Token = "branch_patterns entry 'release v1'" }
            @{ Label = 'allowed_paths given as a string'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": "package.json"}'; Token = 'allowed_paths is not an array' }
            @{ Label = 'empty allowed_paths'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": []}'; Token = 'allowed_paths is empty' }
            @{ Label = 'a non-string path'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": [1]}'; Token = 'allowed_paths element 0 is not a string' }
            @{ Label = 'a path with *'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["*.json"]}'; Token = "allowed_paths entry '*.json'" }
            @{ Label = 'a path with ?'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["package?.json"]}'; Token = "allowed_paths entry 'package?.json'" }
            @{ Label = 'a path with a trailing /'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["docs/"]}'; Token = "allowed_paths entry 'docs/' has a trailing slash" }
            @{ Label = 'a path with a leading /'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["/package.json"]}'; Token = "allowed_paths entry '/package.json' has a leading slash" }
            @{ Label = 'a path with a .. segment'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["docs/../package.json"]}'; Token = "allowed_paths entry 'docs/../package.json'" }
            @{ Label = 'a path with a . segment'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["docs/./package.json"]}'; Token = "allowed_paths entry 'docs/./package.json'" }
            @{ Label = 'the path .'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["."]}'; Token = "allowed_paths entry '.'" }
            @{ Label = 'a drive-letter path'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["C:/package.json"]}'; Token = "allowed_paths entry 'C:/package.json' has a drive letter" }
            @{ Label = 'a path with a backslash'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["docs\\package.json"]}'; Token = 'contains a backslash' }
            @{ Label = 'an empty segment in a path'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["docs//package.json"]}'; Token = "allowed_paths entry 'docs//package.json'" }
            @{ Label = 'an empty path'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": [""]}'; Token = "allowed_paths entry '' is empty" }
            @{ Label = 'a duplicate path'; Allowance = '{"id": "a", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json", "package.json"]}'; Token = "allowed_paths entry 'package.json' duplicates" }
        ) {
            # Arrange: an Allowance row is wrapped in a valid root document.
            $document = if ($Allowance) { ConvertTo-ReleaseAllowanceTestDocument -Allowance $Allowance } else { $Text }

            # Act
            $result = ConvertFrom-ReleaseAllowanceConfig -Text $document

            # Assert
            $result.Valid | Should -BeFalse -Because "row '$Label' breaks a rule"
            $result.Detail.Contains($Token) | Should -BeTrue -Because "the detail '$($result.Detail)' must name $Token"
        }
    }

    Context 'Test-ReleaseAllowanceBranchMatch (spec AC-2)' {
        It 'returns <Expected> for <Branch> against <Pattern>' -ForEach @(
            @{ Branch = 'release/v1.2.3'; Pattern = 'release/v*'; Expected = $true }
            @{ Branch = 'Release/v1.2.3'; Pattern = 'release/v*'; Expected = $false }
            @{ Branch = 'hotfix/release/v1'; Pattern = 'release/v*'; Expected = $false }
            @{ Branch = 'release/v1'; Pattern = 'release/v?'; Expected = $true }
            @{ Branch = 'release/v10'; Pattern = 'release/v?'; Expected = $false }
            @{ Branch = ''; Pattern = 'release/v*'; Expected = $false }
        ) {
            # Act and Assert
            Test-ReleaseAllowanceBranchMatch -Branch $Branch -Pattern $Pattern | Should -Be $Expected
        }
    }

    Context 'Test-ReleaseAllowanceCommandRelevant (decision AD-3)' {
        It 'returns <Expected> for <Command>' -ForEach @(
            @{ Command = 'git -C v add a'; Expected = $true }
            @{ Command = 'git -c v commit -m x'; Expected = $true }
            @{ Command = 'git --git-dir v add a'; Expected = $true }
            @{ Command = 'git --work-tree v commit -m x'; Expected = $true }
            @{ Command = 'git --namespace v add a'; Expected = $true }
            @{ Command = 'git --config-env v commit -m x'; Expected = $true }
            @{ Command = 'git --git-dir=v add a'; Expected = $true }
            @{ Command = 'pytest && git add a'; Expected = $true }
            @{ Command = 'git add ''a'; Expected = $true }
            @{ Command = 'git status'; Expected = $false }
            @{ Command = 'git -C add status'; Expected = $false }
            @{ Command = 'echo git add a'; Expected = $false }
            @{ Command = 'pytest'; Expected = $false }
            @{ Command = ''; Expected = $false }
        ) {
            # Act and Assert
            Test-ReleaseAllowanceCommandRelevant -Command $Command | Should -Be $Expected
        }
    }

    Context 'Get-ReleaseAllowanceSegmentShape accepted forms (spec step 8)' {
        It 'accepts <Segment> as <Kind>' -ForEach @(
            @{ Segment = 'git add package.json CHANGELOG.md'; Kind = 'add'; Paths = @('package.json', 'CHANGELOG.md') }
            @{ Segment = 'git add -- package.json'; Kind = 'add'; Paths = @('package.json') }
            @{ Segment = 'git add -- -A'; Kind = 'add'; Paths = @('-A') }
            @{ Segment = 'git -C /synthetic-worktrees/release add package.json'; Kind = 'add'; Paths = @('package.json') }
            @{ Segment = 'git -C /synthetic-worktrees/release/ add package.json'; Kind = 'add'; Paths = @('package.json') }
            @{ Segment = 'git commit -m ''release'''; Kind = 'commit'; Paths = @() }
            @{ Segment = 'git commit --message ''release'''; Kind = 'commit'; Paths = @() }
            @{ Segment = 'git commit --message=release'; Kind = 'commit'; Paths = @() }
            @{ Segment = 'git commit -F msg.txt'; Kind = 'commit'; Paths = @() }
            @{ Segment = 'git commit --file msg.txt'; Kind = 'commit'; Paths = @() }
            @{ Segment = 'git commit --file=msg.txt'; Kind = 'commit'; Paths = @() }
            @{ Segment = 'git commit -s -m ''a'' -m ''b'''; Kind = 'commit'; Paths = @() }
            @{ Segment = 'git commit --signoff -m ''release'''; Kind = 'commit'; Paths = @() }
        ) {
            # Act
            $shape = Get-ReleaseAllowanceTestShape -Segment $Segment

            # Assert
            $shape.Kind | Should -BeExactly $Kind
            $shape.Code | Should -BeNullOrEmpty -Because $shape.Detail
            @($shape.Paths) | Should -Be @($Paths)
        }
    }

    Context 'Get-ReleaseAllowanceSegmentShape target root comparison (decision AD-5)' {
        It 'accepts a -C value equal to the target root in different letter case' {
            # Act
            $shape = Get-ReleaseAllowanceTestShape -Segment 'git -C /SYNTHETIC-WORKTREES/RELEASE add package.json'

            # Assert
            $shape.Kind | Should -BeExactly 'add'
            $shape.Code | Should -BeNullOrEmpty -Because $shape.Detail
        }
    }

    Context 'Get-ReleaseAllowanceSegmentShape rejected forms (spec step 8)' {
        It 'rejects <Segment> with <Code>' -ForEach @(
            @{ Segment = 'git -c user.name=x commit -m a'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '-c' is not allowed" }
            @{ Segment = 'git --git-dir .git add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--git-dir' is not allowed" }
            @{ Segment = 'git --work-tree . add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--work-tree' is not allowed" }
            @{ Segment = 'git --namespace n add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--namespace' is not allowed" }
            @{ Segment = 'git --config-env a=B commit -m x'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--config-env' is not allowed" }
            @{ Segment = 'git --git-dir=.git add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--git-dir=.git' is not allowed" }
            @{ Segment = 'git --work-tree=. add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--work-tree=.' is not allowed" }
            @{ Segment = 'git --namespace=n add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--namespace=n' is not allowed" }
            @{ Segment = 'git --config-env=a=B commit -m x'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--config-env=a=B' is not allowed" }
            @{ Segment = 'git -C/x add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '-C/x' is not allowed" }
            @{ Segment = 'git --bare add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--bare' is not allowed" }
            @{ Segment = 'git -p add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '-p' is not allowed" }
            @{ Segment = 'git --no-pager add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--no-pager' is not allowed" }
            @{ Segment = 'git --exec-path add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '--exec-path' is not allowed" }
            @{ Segment = 'git -C'; Kind = 'other'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "git global option '-C' is not allowed" }
            @{ Segment = 'git -C sub add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "-C 'sub' is not the target worktree root" }
            @{ Segment = 'git -C /synthetic-worktrees/other add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "-C '/synthetic-worktrees/other' is not the target worktree root" }
            @{ Segment = 'git add -A'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-A' is not allowed for git add" }
            @{ Segment = 'git add --all'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--all' is not allowed for git add" }
            @{ Segment = 'git add -u'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-u' is not allowed for git add" }
            @{ Segment = 'git add --update'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--update' is not allowed for git add" }
            @{ Segment = 'git add -f package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-f' is not allowed for git add" }
            @{ Segment = 'git add --force package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--force' is not allowed for git add" }
            @{ Segment = 'git add -p'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-p' is not allowed for git add" }
            @{ Segment = 'git add --patch'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--patch' is not allowed for git add" }
            @{ Segment = 'git add -i'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-i' is not allowed for git add" }
            @{ Segment = 'git add --interactive'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--interactive' is not allowed for git add" }
            @{ Segment = 'git add --pathspec-from-file=list'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--pathspec-from-file=list' is not allowed for git add" }
            @{ Segment = 'git add -N package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-N' is not allowed for git add" }
            @{ Segment = 'git add --intent-to-add package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--intent-to-add' is not allowed for git add" }
            @{ Segment = 'git add -e'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-e' is not allowed for git add" }
            @{ Segment = 'git add --edit'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--edit' is not allowed for git add" }
            @{ Segment = 'git add --chmod=+x package.json'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--chmod=+x' is not allowed for git add" }
            @{ Segment = 'git add package.json -- CHANGELOG.md'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--' is not allowed for git add" }
            @{ Segment = 'git add'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_PATH_NOT_ALLOWED'; Detail = 'git add has no path operand' }
            @{ Segment = 'git add --'; Kind = 'add'; Code = 'RELEASE_ALLOWANCE_PATH_NOT_ALLOWED'; Detail = 'git add has no path operand' }
            @{ Segment = 'git commit -mvalue'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-mvalue' is not allowed for git commit" }
            @{ Segment = 'git commit -Fvalue'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-Fvalue' is not allowed for git commit" }
            @{ Segment = 'git commit -m'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-m' is not allowed for git commit" }
            @{ Segment = 'git commit --message'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--message' is not allowed for git commit" }
            @{ Segment = 'git commit -F'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '-F' is not allowed for git commit" }
            @{ Segment = 'git commit --file'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'; Detail = "option '--file' is not allowed for git commit" }
            @{ Segment = 'git commit -m x --'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_PATH_NOT_ALLOWED'; Detail = "git commit pathspec '--' is not allowed" }
            @{ Segment = 'git commit -m x package.json'; Kind = 'commit'; Code = 'RELEASE_ALLOWANCE_PATH_NOT_ALLOWED'; Detail = "git commit pathspec 'package.json' is not allowed" }
        ) {
            # Act
            $shape = Get-ReleaseAllowanceTestShape -Segment $Segment

            # Assert
            $shape.Kind | Should -BeExactly $Kind
            $shape.Code | Should -BeExactly $Code
            $shape.Detail | Should -BeExactly $Detail
        }

        It 'rejects the git commit option <Option> (row <Index>)' -ForEach @(
            $optionIndex = 0
            '--trailer', '-a', '--all', '--amend', '-n', '--no-verify', '-c', '-C', '--reuse-message=HEAD', '--reedit-message=HEAD', '--fixup=HEAD',
            '--squash=HEAD', '--allow-empty', '--allow-empty-message', '-o', '--only', '-i', '--include', '--author=x', '--date=x', '-e', '--edit',
            '--pathspec-from-file=x', '-p', '--patch', '-S', '--gpg-sign', '--no-gpg-sign', '--cleanup=strip', '-v', '--dry-run' | ForEach-Object { @{ Option = $_; Index = $optionIndex }; $optionIndex++ }
        ) {
            # Act
            $shape = Get-ReleaseAllowanceTestShape -Segment "git commit $Option -m x"

            # Assert
            $shape.Code | Should -BeExactly 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'
            $shape.Detail | Should -BeExactly "option '$Option' is not allowed for git commit"
        }

        It 'classifies <Segment> as other' -ForEach @(
            @{ Segment = 'echo done' }
            @{ Segment = 'git status' }
            @{ Segment = 'git' }
            @{ Segment = 'git -C add' }
        ) {
            # Act
            $shape = Get-ReleaseAllowanceTestShape -Segment $Segment

            # Assert
            $shape.Kind | Should -BeExactly 'other'
        }

        It 'rejects every -C value when the target root is empty' {
            # Act
            $shape = Get-ReleaseAllowanceSegmentShape -Token @('git', '-C', '/synthetic-worktrees/release', 'add', 'package.json') -WorktreeRoot ''

            # Assert
            $shape.Code | Should -BeExactly 'RELEASE_ALLOWANCE_OPTION_NOT_ALLOWED'
        }
    }
}
