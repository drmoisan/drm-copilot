#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit rows for the regeneration allowance functions of hook-epic-regeneration.ps1 (issue #1156).

.DESCRIPTION
    Runs the same rows against the Claude copy (.claude/hooks) and the Codex copy (.codex/hooks),
    each loaded with its own surface's dependencies: the gate helpers file, the fan-in file, and
    HookTargetWorktree.psm1 on Claude or hook-target-worktree.ps1 on Codex. No function of either
    file is mocked, so every allowance row runs the real delegation to Get-EpicFanInAllowance. The
    config text, the file-existence check, and the staged index are in-memory script blocks. Two
    parity contexts compare the inline config and glob functions with RegenerationConfig.psm1 and
    RegenerationClassifier.psm1. No row creates a file, changes the working directory, or sets
    global state.
#>

Describe 'hook-epic-regeneration.ps1 <Surface> copy (issue #1156)' -ForEach @(
    @{ Surface = 'Claude'; HookDirectory = '.claude/hooks' }
    @{ Surface = 'Codex'; HookDirectory = '.codex/hooks' }
) {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $script:HookPath = Join-Path $script:RepoRoot "$HookDirectory/hook-epic-regeneration.ps1"
        . (Join-Path $script:RepoRoot "$HookDirectory/enforce-orchestration-preimplementation-gate-helpers.ps1")
        if ($Surface -eq 'Claude') {
            Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/HookTargetWorktree.psm1')
        } else {
            . (Join-Path $script:RepoRoot '.codex/hooks/hook-target-worktree.ps1')
        }
        . (Join-Path $script:RepoRoot "$HookDirectory/hook-epic-fan-in.ps1")
        . $script:HookPath

        $script:Root = '/synthetic-worktrees/integration'
        $script:Branch = 'epic/sample-epic-integration'
        $script:ValidText = '{"version":1,"regeneration":{"command":["gen-tool","--write"],"paths":["gen/**"]}}'
        $script:WildText = '{"version":1,"regeneration":{"command":["gen-tool"],"paths":["**","*"]}}'

        function Get-RegenerationScope {
            # Return a resolved epic scope object on the integration branch, or on another HEAD.
            param([string] $Branch = $script:Branch, [string] $WorktreeRoot = $script:Root)
            $checkpoint = [pscustomobject]@{ route_id = 'epic'; epic_feature_folder = 'sample-epic'; integration_branch = $script:Branch; features = @() }
            return [pscustomobject]@{ IsEpicScope = $true; Checkpoint = $checkpoint; WorktreeRoot = $WorktreeRoot; Branch = $Branch; MergeInProgress = $true; Reason = 'epic-scope' }
        }

        function Get-IndexReader {
            # Return a staged-index reader over the given NUL-terminated names.
            param([string[]] $Name = @())
            $text = if ($Name.Count -eq 0) { '' } else { ($Name -join [char]0) + [char]0 }
            return { param([string] $WorktreeRoot) [pscustomobject]@{ ExitCode = 0; Output = $text; Root = $WorktreeRoot } }.GetNewClosure()
        }

        function Get-TextConfigReader {
            # Return a config reader that runs Read-EpicRegenerationConfig over in-memory text; $null text means absent.
            param([AllowNull()][string] $Text)
            $configText = $Text
            $exists = $null -ne $Text
            $testPath = { param($Path) $exists }.GetNewClosure()
            $readText = { param($Path) $configText }.GetNewClosure()
            # The closure reaches the function through its captured script block, not by name lookup.
            $readConfig = ${function:Read-EpicRegenerationConfig}
            return { param([string] $WorktreeRoot) & $readConfig -WorktreeRoot $WorktreeRoot -TestPath $testPath -ReadText $readText }.GetNewClosure()
        }

        function Get-RegenerationAllowance {
            # Return the allowance for one command, with the given config text and staged names.
            param([string] $Command, [AllowNull()][string] $ConfigText = $script:ValidText, [string[]] $Staged = @(), [string[]] $FilePath = @(''), [object] $Scope = (Get-RegenerationScope))
            return (Get-EpicRegenerationAllowance -Scope $Scope -FilePath $FilePath -Command $Command -StagedIndexReader (Get-IndexReader -Name $Staged) -ConfigReader (Get-TextConfigReader -Text $ConfigText))
        }

        function Get-SeamDefaultCommand {
            # Return the commands of one seam parameter's default script block in Read-EpicRegenerationConfig.
            param([string] $ParameterName)
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HookPath, [ref]$null, [ref]$null)
            $function = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -ceq 'Read-EpicRegenerationConfig' }, $true)
            $parameter = @($function.Body.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -ceq $ParameterName })[0]
            $block = $parameter.DefaultValue.ScriptBlock
            return [pscustomobject]@{
                ParameterName = $block.ParamBlock.Parameters[0].Name.VariablePath.UserPath
                Commands      = @($block.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
            }
        }
    }

    Context 'file shape' {
        It 'the two surface files are byte-identical' {
            # Act
            $claude = (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot '.claude/hooks/hook-epic-regeneration.ps1') -Algorithm SHA256).Hash
            $codex = (Get-FileHash -LiteralPath (Join-Path $script:RepoRoot '.codex/hooks/hook-epic-regeneration.ps1') -Algorithm SHA256).Hash

            # Assert
            $codex | Should -BeExactly $claude
        }

        It 'holds no Import-Module command, no dot-source, and no $PSScriptRoot reference' {
            # Arrange
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HookPath, [ref]$null, [ref]$null)

            # Act
            $commands = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true))
            $imports = @($commands | Where-Object { $_.GetCommandName() -ceq 'Import-Module' })
            $dotSources = @($commands | Where-Object { $_.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot })
            $scriptRoot = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.VariablePath.UserPath -ceq 'PSScriptRoot' }, $true))

            # Assert
            $imports.Count | Should -Be 0
            $dotSources.Count | Should -Be 0
            $scriptRoot.Count | Should -Be 0
        }

        It 'holds only function definitions at top level' {
            # Arrange
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:HookPath, [ref]$null, [ref]$null)

            # Act
            $statements = @($ast.EndBlock.Statements)

            # Assert
            $statements.Count | Should -Be 4
            @($statements | Where-Object { $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] }).Count | Should -Be 0
            ($null -eq $ast.BeginBlock -and $null -eq $ast.ProcessBlock -and $null -eq $ast.ParamBlock) | Should -BeTrue
        }

        It 'the TestPath default runs one Test-Path -LiteralPath bound to its parameter' {
            # Act
            $seam = Get-SeamDefaultCommand -ParameterName 'TestPath'

            # Assert
            $seam.Commands.Count | Should -Be 1
            $seam.Commands[0].GetCommandName() | Should -BeExactly 'Test-Path'
            ($seam.Commands[0].CommandElements | ForEach-Object { $_.Extent.Text }) -join ' ' | Should -BeExactly ('Test-Path -LiteralPath $' + $seam.ParameterName)
        }

        It 'the ReadText default runs one Get-Content -LiteralPath bound to its parameter with -Raw' {
            # Act
            $seam = Get-SeamDefaultCommand -ParameterName 'ReadText'

            # Assert
            $seam.Commands.Count | Should -Be 1
            $seam.Commands[0].GetCommandName() | Should -BeExactly 'Get-Content'
            ($seam.Commands[0].CommandElements | ForEach-Object { $_.Extent.Text }) -join ' ' | Should -BeExactly ('Get-Content -LiteralPath $' + $seam.ParameterName + ' -Raw')
        }
    }

    Context 'admitted commands' {
        It 'admits <Command>' -ForEach @(
            @{ Command = 'git add -- gen/a.json'; Staged = @() }
            @{ Command = 'git add gen/a.json'; Staged = @() }
            @{ Command = 'git add -- gen/a.json gen/sub/b.json'; Staged = @() }
            @{ Command = 'git commit -F msg.txt'; Staged = @('gen/a.json', 'gen/b.json') }
            @{ Command = 'git commit --file msg.txt'; Staged = @('gen/a.json') }
            @{ Command = 'git commit -m msg'; Staged = @('gen/a.json') }
            @{ Command = 'git commit --message msg'; Staged = @('gen/a.json') }
            @{ Command = 'git commit -F msg.txt --trailer Regenerated-By:tool'; Staged = @('gen/a.json') }
            @{ Command = 'git commit -m msg -- gen/a.json'; Staged = @() }
        ) {
            # Act
            $result = Get-RegenerationAllowance -Command $Command -Staged $Staged

            # Assert
            $result.Allowed | Should -BeTrue -Because $result.Detail
        }
    }

    Context 'denied commands with the gen/** config' {
        It 'denies <Name>' -ForEach @(
            @{ Name = 'an option outside the five'; Command = 'git commit --author name -F msg.txt'; Staged = @('gen/a.json') }
            @{ Name = 'a staged index with one path outside the patterns'; Command = 'git commit -F msg.txt'; Staged = @('gen/a.json', 'src/x.ps1') }
            @{ Name = 'an empty staged index and no paths'; Command = 'git commit -F msg.txt'; Staged = @() }
            @{ Name = 'git add -- with no path'; Command = 'git add --'; Staged = @() }
            @{ Name = 'git commit -a'; Command = 'git commit -a -m msg'; Staged = @('gen/a.json') }
            @{ Name = 'git commit --all'; Command = 'git commit --all -m msg'; Staged = @('gen/a.json') }
            @{ Name = 'git commit --amend'; Command = 'git commit --amend -m msg'; Staged = @('gen/a.json') }
            @{ Name = 'git commit --no-verify'; Command = 'git commit --no-verify -m msg'; Staged = @('gen/a.json') }
            @{ Name = 'a chained command'; Command = 'git add -- gen/a.json && git commit -m msg'; Staged = @('gen/a.json') }
            @{ Name = 'a path outside the patterns'; Command = 'git add -- src/x.ps1'; Staged = @() }
        ) {
            # Act
            $result = Get-RegenerationAllowance -Command $Command -Staged $Staged

            # Assert
            $result.Allowed | Should -BeFalse -Because $result.Detail
            $result.Detail | Should -Not -BeLike 'allowance error*'
        }

        It 'denies a <Tool> call' -ForEach @(@{ Tool = 'Write' }, @{ Tool = 'Edit' }) {
            # Act
            $result = Get-RegenerationAllowance -Command '' -FilePath @('gen/a.json')

            # Assert
            $result.Allowed | Should -BeFalse
        }

        It 'denies a matching add when the worktree HEAD is not the integration branch' {
            # Act
            $result = Get-RegenerationAllowance -Command 'git add -- gen/a.json' -Scope (Get-RegenerationScope -Branch 'feature/other')

            # Assert
            $result.Allowed | Should -BeFalse
        }

        It 'denies a matching add for the <State> config state and admits it for the valid document' -ForEach @(
            @{ State = 'file absent'; Text = $null }
            @{ State = 'regeneration key absent'; Text = '{"version":1}' }
            @{ State = 'regeneration null'; Text = '{"version":1,"regeneration":null}' }
            @{ State = 'invalid document'; Text = '{"version":"1","regeneration":{"command":["gen-tool"],"paths":["gen/**"]}}' }
        ) {
            # Act
            $denied = Get-RegenerationAllowance -Command 'git add -- gen/a.json' -ConfigText $Text
            $admitted = Get-RegenerationAllowance -Command 'git add -- gen/a.json' -ConfigText $script:ValidText

            # Assert
            $denied.Allowed | Should -BeFalse
            $admitted.Allowed | Should -BeTrue -Because $admitted.Detail
        }
    }

    Context 'operand and shape denials with a match-everything config' {
        It 'denies <Command>' -ForEach @(
            @{ Command = 'git add -A -- gen/a.json'; Staged = @() }
            @{ Command = 'git add -u gen/a.json'; Staged = @() }
            @{ Command = 'git add --all gen/a.json'; Staged = @() }
            @{ Command = 'git add -- -A'; Staged = @() }
            @{ Command = 'git add -- gen/a.json -- gen/b.json'; Staged = @() }
            @{ Command = 'git commit -m msg -- -x'; Staged = @() }
            @{ Command = 'git commit -F msg.txt'; Staged = @('-x') }
        ) {
            # Act
            $result = Get-RegenerationAllowance -Command $Command -Staged $Staged -ConfigText $script:WildText

            # Assert
            $result.Allowed | Should -BeFalse -Because $result.Detail
            $result.Detail | Should -Not -BeLike 'allowance error*'
        }

        It 'denies the forbidden path shape <Operand> for git add and git commit' -ForEach @(
            @{ Operand = 'gen\a.json' }
            @{ Operand = 'gen/*.json' }
            @{ Operand = 'gen/a?.json' }
            @{ Operand = 'gen/[a].json' }
            @{ Operand = '/gen/a.json' }
            @{ Operand = 'C:/gen/a.json' }
            @{ Operand = 'gen//a.json' }
            @{ Operand = './gen/a.json' }
            @{ Operand = 'gen/../a.json' }
            @{ Operand = "''" }
        ) {
            # Act
            $add = Get-RegenerationAllowance -Command "git add -- $Operand" -ConfigText $script:WildText
            $commit = Get-RegenerationAllowance -Command "git commit -m msg -- $Operand" -ConfigText $script:WildText

            # Assert
            $add.Allowed | Should -BeFalse -Because $add.Detail
            $commit.Allowed | Should -BeFalse -Because $commit.Detail
            $add.Detail | Should -Not -BeLike 'allowance error*'
            $commit.Detail | Should -Not -BeLike 'allowance error*'
        }

        It 'admits a plain path under the match-everything config, so the denials above come from the operand rules' {
            # Act
            $result = Get-RegenerationAllowance -Command 'git add -- gen/a.json' -ConfigText $script:WildText

            # Assert
            $result.Allowed | Should -BeTrue -Because $result.Detail
        }
    }

    Context 'config reader wiring' {
        It 'invokes the config reader once with the scope worktree root' {
            # Arrange
            $calls = [System.Collections.Generic.List[string]]::new()
            $reader = { param([string] $WorktreeRoot) $calls.Add($WorktreeRoot); , [string[]]@('gen/**') }.GetNewClosure()
            $scope = Get-RegenerationScope -WorktreeRoot '/synthetic-worktrees/integration'

            # Act
            $result = Get-EpicRegenerationAllowance -Scope $scope -FilePath @('') -Command 'git add -- gen/a.json' -StagedIndexReader (Get-IndexReader) -ConfigReader $reader

            # Assert
            $result.Allowed | Should -BeTrue -Because $result.Detail
            $calls.Count | Should -Be 1
            $calls[0] | Should -BeExactly '/synthetic-worktrees/integration'
        }
    }

    Context 'Read-EpicRegenerationConfig' {
        It 'returns $null for an absent file without calling the text reader' {
            # Arrange
            $reads = [System.Collections.Generic.List[string]]::new()
            $readText = { param($Path) $reads.Add($Path); $script:ValidText }.GetNewClosure()

            # Act
            $result = Read-EpicRegenerationConfig -WorktreeRoot '/synthetic-root' -TestPath { param($Path) $false } -ReadText $readText

            # Assert
            $null -eq $result | Should -BeTrue
            $reads.Count | Should -Be 0
        }

        It 'returns $null for a text reader that throws' {
            # Act
            $result = Read-EpicRegenerationConfig -WorktreeRoot '/synthetic-root' -TestPath { param($Path) $true } -ReadText { param($Path) throw 'unreadable' }

            # Assert
            $null -eq $result | Should -BeTrue
        }

        It 'returns $null for <Name>' -ForEach @(
            @{ Name = 'an absent regeneration key'; Text = '{"version":1}' }
            @{ Name = 'regeneration null'; Text = '{"version":1,"regeneration":null}' }
            @{ Name = 'an invalid document'; Text = '{"version":1,"regeneration":{"command":[],"paths":["gen/**"]}}' }
        ) {
            # Arrange
            $configText = $Text

            # Act
            $result = Read-EpicRegenerationConfig -WorktreeRoot '/synthetic-root' -TestPath { param($Path) $true } -ReadText ({ param($Path) $configText }.GetNewClosure())

            # Assert
            $null -eq $result | Should -BeTrue
        }

        It 'returns the patterns of a valid document' {
            # Act
            $result = Read-EpicRegenerationConfig -WorktreeRoot '/synthetic-root' -TestPath { param($Path) $true } -ReadText { param($Path) '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**","docs/*.md"]}}' }

            # Assert
            ($result -join '|') | Should -BeExactly 'gen/**|docs/*.md'
        }

        It 'passes exactly <Expected> to both seams for root <Root>' -ForEach @(
            @{ Root = '/synthetic-root'; Expected = '/synthetic-root/config/orchestration-regeneration.json' }
            @{ Root = '/synthetic-root/'; Expected = '/synthetic-root/config/orchestration-regeneration.json' }
        ) {
            # Arrange
            $tested = [System.Collections.Generic.List[string]]::new()
            $read = [System.Collections.Generic.List[string]]::new()
            $testPath = { param($Path) $tested.Add($Path); $true }.GetNewClosure()
            $readText = { param($Path) $read.Add($Path); '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**"]}}' }.GetNewClosure()

            # Act
            $null = Read-EpicRegenerationConfig -WorktreeRoot $Root -TestPath $testPath -ReadText $readText

            # Assert
            @($tested) | Should -BeExactly @($Expected)
            @($read) | Should -BeExactly @($Expected)
        }
    }

    Context 'Get-EpicRegenerationConfigPattern' {
        It 'returns $null for <Name>' -ForEach @(
            @{ Name = 'rule 1, not an object'; Text = '["gen/**"]' }
            @{ Name = 'rule 1, unparseable text'; Text = '{"version":' }
            @{ Name = 'rule 2, version a string'; Text = '{"version":"1","regeneration":{"command":["g"],"paths":["gen/**"]}}' }
            @{ Name = 'rule 2, version a boolean'; Text = '{"version":true,"regeneration":{"command":["g"],"paths":["gen/**"]}}' }
            @{ Name = 'rule 2, version fractional'; Text = '{"version":1.5,"regeneration":{"command":["g"],"paths":["gen/**"]}}' }
            @{ Name = 'rule 3, regeneration not an object'; Text = '{"version":1,"regeneration":["g"]}' }
            @{ Name = 'rule 4, unknown key'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**"],"extra":1}}' }
            @{ Name = 'rule 5, empty command'; Text = '{"version":1,"regeneration":{"command":[],"paths":["gen/**"]}}' }
            @{ Name = 'rule 5, whitespace command element'; Text = '{"version":1,"regeneration":{"command":[" "],"paths":["gen/**"]}}' }
            @{ Name = 'rule 6, empty paths'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":[]}}' }
            @{ Name = 'rule 6, non-string pattern'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":[1]}}' }
            @{ Name = 'rule 7, .. segment'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen/../x"]}}' }
            @{ Name = 'rule 8, empty idempotency_check'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**"],"idempotency_check":[]}}' }
            @{ Name = 'rule 9, unit_gate of strings'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**"],"unit_gate":["t"]}}' }
            @{ Name = 'an absent regeneration key'; Text = '{"version":1}' }
            @{ Name = 'regeneration null'; Text = '{"version":1,"regeneration":null}' }
        ) {
            # Act
            $result = Get-EpicRegenerationConfigPattern -Text $Text

            # Assert
            $null -eq $result | Should -BeTrue
        }

        It 'returns the patterns of a valid document in order' {
            # Act
            $result = Get-EpicRegenerationConfigPattern -Text '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**","docs/*.md"],"idempotency_check":["c"],"unit_gate":[["t","1"]]}}'

            # Assert
            $result.Count | Should -Be 2
            $result[0] | Should -BeExactly 'gen/**'
            $result[1] | Should -BeExactly 'docs/*.md'
        }

        It 'keeps a one-element paths list as an array' {
            # Act
            $result = Get-EpicRegenerationConfigPattern -Text $script:ValidText

            # Assert
            , $result | Should -BeOfType ([string[]])
            $result.Count | Should -Be 1
            $result[0] | Should -BeExactly 'gen/**'
        }
    }

    Context 'parity with RegenerationConfig.psm1' {
        BeforeAll {
            Import-Module (Join-Path $script:RepoRoot '.claude/lib/regeneration/RegenerationConfig.psm1') -ErrorAction Stop
        }

        AfterAll {
            Remove-Module -Name RegenerationConfig -Force -ErrorAction SilentlyContinue
        }

        It 'agrees on validity for <Name>' -ForEach @(
            @{ Name = 'a valid document'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**"]}}' }
            @{ Name = 'a full valid document'; Text = '{"version":1,"regeneration":{"command":["g","-w"],"paths":["gen/**","a/*.md"],"idempotency_check":["c"],"unit_gate":[["t"],["u","1"]]}}' }
            @{ Name = 'version string'; Text = '{"version":"1","regeneration":{"command":["g"],"paths":["gen/**"]}}' }
            @{ Name = 'version 2'; Text = '{"version":2,"regeneration":{"command":["g"],"paths":["gen/**"]}}' }
            @{ Name = 'version fractional'; Text = '{"version":1.0,"regeneration":{"command":["g"],"paths":["gen/**"]}}' }
            @{ Name = 'regeneration absent'; Text = '{"version":1}' }
            @{ Name = 'regeneration null'; Text = '{"version":1,"regeneration":null}' }
            @{ Name = 'unknown key'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**"],"x":1}}' }
            @{ Name = 'command missing'; Text = '{"version":1,"regeneration":{"paths":["gen/**"]}}' }
            @{ Name = 'paths missing'; Text = '{"version":1,"regeneration":{"command":["g"]}}' }
            @{ Name = 'leading slash'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["/gen"]}}' }
            @{ Name = 'drive letter'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["C:/gen"]}}' }
            @{ Name = 'square bracket'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen/[a]"]}}' }
            @{ Name = 'empty segment'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen//a"]}}' }
            @{ Name = 'dot segment'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["./gen"]}}' }
            @{ Name = 'unit_gate empty argv'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**"],"unit_gate":[[]]}}' }
            @{ Name = 'idempotency_check non-string'; Text = '{"version":1,"regeneration":{"command":["g"],"paths":["gen/**"],"idempotency_check":[1]}}' }
            @{ Name = 'not an object'; Text = '[1]' }
            @{ Name = 'unparseable'; Text = '{' }
        ) {
            # Act
            $library = ConvertFrom-RegenerationConfigText -Text $Text
            $libraryValid = ($null -ne $library.Config) -and (@($library.Errors).Count -eq 0)
            $inline = Get-EpicRegenerationConfigPattern -Text $Text

            # Assert
            ($null -ne $inline) | Should -Be $libraryValid
        }
    }

    Context 'parity with RegenerationClassifier.psm1' {
        BeforeAll {
            Import-Module (Join-Path $script:RepoRoot '.claude/lib/regeneration/RegenerationClassifier.psm1') -ErrorAction Stop
        }

        AfterAll {
            Remove-Module -Name RegenerationClassifier, BlastRadiusGlob -Force -ErrorAction SilentlyContinue
        }

        It 'agrees for path <Path> and pattern <Pattern>' -ForEach @(
            @{ Path = 'a.json'; Pattern = '**/a.json' }
            @{ Path = 'gen/a.json'; Pattern = '**/a.json' }
            @{ Path = 'gen/a/b.json'; Pattern = 'gen/*.json' }
            @{ Path = 'gen/b.json'; Pattern = 'gen/*.json' }
            @{ Path = 'gen/ab.json'; Pattern = 'gen/a?.json' }
            @{ Path = 'gen/a/.json'; Pattern = 'gen/a?.json' }
            @{ Path = 'gen/x/y/z.json'; Pattern = 'gen/**' }
            @{ Path = 'Gen/a.json'; Pattern = 'gen/**' }
            @{ Path = 'gen\a.json'; Pattern = 'gen/**' }
            @{ Path = 'gen/a.json'; Pattern = 'gen/a.json' }
            @{ Path = 'gen/a.jsonx'; Pattern = 'gen/a.json' }
            @{ Path = 'gen/a+b.json'; Pattern = 'gen/a+b.json' }
        ) {
            # Act
            $library = Test-RegenerationPathMatch -Path $Path -Pattern @($Pattern)
            $inline = Test-EpicRegenerationPathMatch -Path $Path -Pattern @($Pattern)

            # Assert
            $inline | Should -Be $library
        }
    }
}
