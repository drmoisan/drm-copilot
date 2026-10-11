#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Classification coverage for the issue #824 structural matcher (T-INV).

.DESCRIPTION
    Drives Get-CommandLineInvocation, Resolve-CommandLineInvocation, Test-CommandLineInvocation,
    Test-CommandLineMention, and Get-CommandLineGlobalOption in hook-command-invocation.ps1.
    Classification is Structural, Indeterminate, or no match, and never rests on substring
    containment. IV-16 is the negative control: it reinstates substring presence through a
    mock of Test-CommandLineWordPresent and shows that R-824-MAIN would then classify.

    Every row runs against the Claude and the Codex copy. Each case is a pure string case:
    no temporary file, no child process, and no live executable. IV-17 reads the hook folders
    to confirm that the removed raw-containment helper is referenced nowhere.
#>

BeforeDiscovery {
    $script:Runtimes = @(
        @{ Runtime = 'claude'; HookRoot = '.claude/hooks' }
        @{ Runtime = 'codex'; HookRoot = '.codex/hooks' }
    )
    $script:Path = '/repo/worktrees/item-a-101'
    $script:TrueRows = @(
        @{ Command = 'gh issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'gh   issue    create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'GH Issue Create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = '& gh issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = '; gh issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = '| gh issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = '(gh issue create)'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = '"gh" issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = "'gh' issue create"; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = "`ngh issue create"; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = '/usr/bin/gh issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'C:\tools\gh.exe issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = '"C:\Program Files\GitHub CLI\gh.exe" issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'bash -c "\"gh\" issue create"'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'gh -R x issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'gh --repo=x issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'gh --unmodeled issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'g=gh; $g issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 's=issue; gh $s create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = "git -C ""a b"" worktree remove $script:Path"; Word = 'git'; Sub = @('worktree', 'remove') }
    )
    $script:FalseRows = @(
        @{ Command = 'pwsh -NoProfile -Command ''Write-Output "through issue"; New-Object Text.StringBuilder'''; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'pwsh -NoProfile -f ./scripts/legit-push.ps1'; Word = 'git'; Sub = @('push') }
        @{ Command = 'pwsh -NoProfile -Command ''git worktree list --porcelain | Select-String -NotMatch "removed"'''; Word = 'git'; Sub = @('worktree', 'remove') }
        @{ Command = 'pwsh -NoProfile -Command ''Select-String -Path README.md -Pattern "high priority" | ForEach-Object { "create" }'''; Word = 'gh'; Sub = @('pr', 'create') }
        @{ Command = 'gh issue newline'; Word = 'gh'; Sub = @('issue', 'new') }
        @{ Command = 'gh issue list'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = '$a $b $c'; Word = 'gh'; Sub = @('issue', 'create') }
    )
    $script:Sinks = @(
        @{ Sink = 'Write-Output'; Command = 'pwsh -c ''Write-Output "gh issue create"''' }
        @{ Sink = 'Write-Host'; Command = 'pwsh -c ''Write-Host "gh issue create"''' }
        @{ Sink = 'Write-Verbose'; Command = 'pwsh -c ''Write-Verbose "gh issue create"''' }
        @{ Sink = 'Write-Information'; Command = 'pwsh -c ''Write-Information "gh issue create"''' }
        @{ Sink = 'Select-String'; Command = 'pwsh -c ''Select-String "gh issue create"''' }
        @{ Sink = 'echo'; Command = 'bash -c ''echo "gh issue create"''' }
        @{ Sink = 'printf'; Command = 'bash -c ''printf "gh issue create"''' }
        @{ Sink = 'grep'; Command = 'bash -c ''grep "gh issue create"''' }
        @{ Sink = 'rg'; Command = 'bash -c ''rg "gh issue create"''' }
    )
    $script:TerminalRows = foreach ($option in @('--version', '-v', '--help', '-h', '--html-path', '--man-path', '--info-path', '--exec-path')) {
        foreach ($sub in @('add', 'commit', 'worktree remove')) {
            @{ Command = "git $option $sub x"; Word = 'git'; Sub = @($sub -split ' ') }
        }
    }
    $script:TerminalRows += @(
        @{ Command = 'gh --version issue create'; Word = 'gh'; Sub = @('issue', 'create') }
        @{ Command = 'gh --help issue create'; Word = 'gh'; Sub = @('issue', 'create') }
    )
}

Describe 'hook-command-invocation classification, <Runtime> copy (issue #824)' -ForEach $script:Runtimes {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot "$HookRoot/hook-command-invocation.ps1")
        $script:P = '/repo/worktrees/item-a-101'
        $script:R824Main = 'pwsh -NoProfile -Command ''$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'''

        function Get-DeclaredParameterName {
            <# Return a function's declared parameter names, common parameters removed. #>
            param([Parameter(Mandatory)][string] $Name)
            $command = Get-Command -Name $Name -CommandType Function
            $common = @([System.Management.Automation.PSCmdlet]::CommonParameters) +
            @([System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
            return @($command.Parameters.Keys | Where-Object { $common -notcontains $_ } | Sort-Object)
        }

        function Get-Match {
            <# Return the Get-CommandLineInvocation matches as an array. #>
            param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText, [string] $Word = 'git', [string[]] $Sub = @('add'))
            return @(Get-CommandLineInvocation -CommandText $CommandText -CommandWord $Word -SubcommandPath $Sub)
        }
    }

    It 'IV-01 pins the Get-CommandLineInvocation parameter list and OutputType' -Tag 'Issue824' {
        $command = Get-Command -Name 'Get-CommandLineInvocation' -CommandType Function

        (Get-DeclaredParameterName -Name 'Get-CommandLineInvocation') -join ',' | Should -Be 'CommandText,CommandWord,SubcommandPath'
        @($command.OutputType).Count | Should -Be 1
        $command.OutputType[0].Type | Should -Be ([pscustomobject[]])
    }

    It 'IV-02 carries every documented match property' -Tag 'Issue824' {
        $match = (Get-Match -CommandText 'git add .')[0]

        $names = @($match.PSObject.Properties.Name)

        foreach ($name in @('Status', 'Reason', 'Segment', 'OperandIndex', 'GlobalOptions', 'Operands', 'OperandsComplete')) {
            $names | Should -Contain $name
        }
    }

    It 'IV-03 records global options in order, the operands, and the operand index' -Tag 'Issue824' {
        $match = (Get-Match -CommandText 'git -C a -c x=y add f')[0]

        $match.Status | Should -Be 'Structural'
        ($match.GlobalOptions | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ';' | Should -Be '-C=a;-c=x=y'
        ($match.Operands -join ',') | Should -Be 'f'
        $match.OperandIndex | Should -Be 6
        $match.OperandsComplete | Should -BeTrue
    }

    It 'IV-04 returns every structural match in source order' -Tag 'Issue824' {
        $matchList = Get-Match -CommandText 'git add a; git add b'

        $matchList.Count | Should -Be 2
        ($matchList | ForEach-Object { $_.Operands[0] }) -join ',' | Should -Be 'a,b'
    }

    It 'IV-05 classifies <Command> Indeterminate with reason <Reason> and operand index -1' -Tag 'Issue824' -ForEach @(
        @{ Command = 'echo "git add x'; Reason = 'Unbalanced' }
        @{ Command = 'git --unmodeled add x'; Reason = 'Opaque' }
        @{ Command = 'pwsh -EncodedCommand ###'; Reason = 'Opaque' }
        @{ Command = 'c=git; $c add x'; Reason = 'DynamicPosition' }
        @{ Command = 'pwsh -c ''iex "git add x"'''; Reason = 'NotProvenInert' }
        @{ Command = 'eval eval eval eval eval git add x'; Reason = 'DepthLimit' }
    ) {
        $matchList = Get-Match -CommandText $Command

        # Every match is Indeterminate with no operand position, and one carries the reason.
        $matchList.Count | Should -BeGreaterThan 0
        @($matchList | Where-Object { $_.Status -ne 'Indeterminate' -or $_.OperandIndex -ne -1 }).Count | Should -Be 0
        @($matchList | Where-Object { $_.Reason -eq $Reason }).Count | Should -Be 1
    }

    It 'IV-06-<Sink> proves a sink payload inert, so gh issue create does not match' -Tag 'Issue824' -ForEach $script:Sinks {
        Get-Match -CommandText $Command -Word 'gh' -Sub @('issue', 'create') | Should -BeNullOrEmpty
    }

    It 'IV-07 classifies the non-sink payload <Command> NotProvenInert' -Tag 'Issue824' -ForEach @(
        @{ Command = 'pwsh -c ''Invoke-Expression "gh issue create"''' }
        @{ Command = 'pwsh -c ''1 | ForEach-Object { "gh issue create" }''' }
        @{ Command = 'bash -c ''cat "gh issue create"''' }
        @{ Command = 'pwsh -c ''Write-Output "gh issue create" | Out-File x.ps1''' }
    ) {
        $matchList = Get-Match -CommandText $Command -Word 'gh' -Sub @('issue', 'create')

        @($matchList | Where-Object { $_.Status -eq 'Indeterminate' -and $_.Reason -eq 'NotProvenInert' }).Count | Should -Be 1
    }

    It 'IV-08 does not prove a redirected echo payload inert' -Tag 'Issue824' {
        $matchList = Get-Match -CommandText 'bash -c ''echo gh issue create > x.sh''' -Word 'gh' -Sub @('issue', 'create')

        $matchList.Count | Should -Be 1
        $matchList[0].Status | Should -Be 'Indeterminate'
    }

    It 'IV-09 treats the terminal option in <Command> as a resolved non-match' -Tag 'Issue824' -ForEach $script:TerminalRows {
        Get-Match -CommandText $Command -Word $Word -Sub $Sub | Should -BeNullOrEmpty
    }

    It 'IV-10 absorbs --exec-path=<value> as one global option' -Tag 'Issue824' {
        $match = (Get-Match -CommandText "git --exec-path=/opt/git worktree remove $script:P" -Sub @('worktree', 'remove'))[0]

        $match.Status | Should -Be 'Structural'
        $match.GlobalOptions[0].Name | Should -Be '--exec-path'
        $match.GlobalOptions[0].Value | Should -Be '/opt/git'
        ($match.Operands -join ',') | Should -Be $script:P
    }

    It 'IV-11 exposes the DC-11 option tables' -Tag 'Issue824' {
        $git = Get-CommandLineGlobalOption -CommandWord 'git'
        $gh = Get-CommandLineGlobalOption -CommandWord 'gh'
        $npx = Get-CommandLineGlobalOption -CommandWord 'npx'
        $sorted = { param($list) (@($list) | Sort-Object) -join ',' }

        & $sorted $git.WithArgument | Should -Be (& $sorted @('-C', '-c', '--git-dir', '--work-tree', '--namespace'))
        & $sorted $git.Terminal | Should -Be (& $sorted @('--version', '-v', '--help', '-h', '--html-path', '--man-path', '--info-path', '--exec-path'))
        @($git.Standalone) | Should -Contain '--exec-path'
        & $sorted $gh.Terminal | Should -Be (& $sorted @('--version', '--help'))
        @($npx.Terminal).Count | Should -Be 0
    }

    It 'IV-12 reports Status and OperandIndex through Resolve-CommandLineInvocation' -Tag 'Issue824' {
        $structural = Resolve-CommandLineInvocation -CommandText 'git add .' -CommandWord 'git' -SubcommandPath @('add')
        $indeterminate = Resolve-CommandLineInvocation -CommandText 'echo "git add' -CommandWord 'git' -SubcommandPath @('add')

        (@($structural.PSObject.Properties.Name) | Sort-Object) -join ',' | Should -Be 'OperandIndex,Segment,Status'
        $structural.Status | Should -Be 'Structural'
        $structural.OperandIndex | Should -Be 2
        $indeterminate.Status | Should -Be 'Indeterminate'
        $indeterminate.OperandIndex | Should -Be -1
        Resolve-CommandLineInvocation -CommandText 'git status' -CommandWord 'git' -SubcommandPath @('add') | Should -BeNullOrEmpty
    }

    It 'IV-13 reports a mention only for whole-token presence' -Tag 'Issue824' {
        Test-CommandLineMention -CommandText 'echo "run git add"' -CommandWord 'git' -SubcommandPath @('add') | Should -BeTrue
        Test-CommandLineMention -CommandText 'echo "digit address"' -CommandWord 'git' -SubcommandPath @('add') | Should -BeFalse
    }

    It 'IV-14 classifies the fixture AC-4 true row <Command>' -Tag 'Issue824' -ForEach $script:TrueRows {
        Test-CommandLineInvocation -CommandText $Command -CommandWord $Word -SubcommandPath $Sub | Should -BeTrue
    }

    It 'IV-15 does not classify the fixture AC-4 false row <Command>' -Tag 'Issue824' -ForEach $script:FalseRows {
        Test-CommandLineInvocation -CommandText $Command -CommandWord $Word -SubcommandPath $Sub | Should -BeFalse
    }

    It 'IV-16 classifies R-824-MAIN only when substring presence is reinstated' -Tag 'Issue824', 'NegativeControl' {
        $delivered = Test-CommandLineInvocation -CommandText $script:R824Main -CommandWord 'gh' -SubcommandPath @('issue', 'new')
        Mock Test-CommandLineWordPresent { $RawText.IndexOf($Word, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 }

        $substring = Test-CommandLineInvocation -CommandText $script:R824Main -CommandWord 'gh' -SubcommandPath @('issue', 'new')

        $delivered | Should -BeFalse -Because 'the delivered presence test is whole-token'
        $substring | Should -BeTrue -Because 'substring presence finds gh in through and new in New-Object'
    }

    It 'IV-17 leaves no raw-containment helper and no checkpoint-only contract sentence' -Tag 'Issue824' {
        $files = foreach ($folder in @('.claude/hooks', '.codex/hooks')) {
            Get-ChildItem -LiteralPath (Join-Path $script:RepoRoot $folder) -Filter '*.ps1' -File
        }

        Get-Command -Name ('Test-CommandLine' + 'RawContainment') -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        @($files | Select-String -SimpleMatch -Pattern ('Test-CommandLine' + 'RawContainment')).Count | Should -Be 0
        @($files | Select-String -SimpleMatch -Pattern ('only forces a ' + 'checkpoint check')).Count | Should -Be 0
    }

    It 'IV-18 classifies the leaf-normalized command word in <_>' -Tag 'Issue824' -ForEach @('/usr/bin/git add .', 'git.exe add .', 'C:\Git\cmd\git.exe add .') {
        (Get-Match -CommandText $_)[0].Status | Should -Be 'Structural'
    }

    It 'IV-19 classifies a backslash-newline continuation structurally' -Tag 'Issue824' {
        (Get-Match -CommandText ("git \`n" + 'add .'))[0].Status | Should -Be 'Structural'
    }

    It 'IV-20 skips transparent wrappers before the command word' -Tag 'Issue824' {
        (Get-Match -CommandText 'timeout 5 gh issue create' -Word 'gh' -Sub @('issue', 'create'))[0].Status | Should -Be 'Structural'
        (Get-Match -CommandText 'env gh issue create' -Word 'gh' -Sub @('issue', 'create'))[0].Status | Should -Be 'Structural'
        Get-Match -CommandText 'env FOO=1 npm test' -Word 'gh' -Sub @('issue', 'create') | Should -BeNullOrEmpty
    }

    It 'IV-21 classifies a stdin heredoc to bash as Opaque and a script-file bash as no match' -Tag 'Issue824' {
        $heredoc = @('bash <<''EOF''', 'gh issue create', 'EOF') -join "`n"

        $matchList = Get-Match -CommandText $heredoc -Word 'gh' -Sub @('issue', 'create')

        $matchList[0].Status | Should -Be 'Indeterminate'
        $matchList[0].Reason | Should -Be 'Opaque'
        Get-Match -CommandText 'bash x.sh' -Word 'gh' -Sub @('issue', 'create') | Should -BeNullOrEmpty
    }

    It 'IV-22 does not classify a dynamic command word whose text carries no governed word' -Tag 'Issue824' {
        Get-Match -CommandText '$EDITOR notes.md' | Should -BeNullOrEmpty
    }

    It 'IV-23 does not classify a commit-message heredoc body as gh pr create' -Tag 'Issue824', 'R-733-714' {
        $r733 = @('git commit -m "$(cat <<''EOF''', 'fix(hooks): route the matcher through the process that created the payload', 'The change runs through every segment.', 'EOF', ')"') -join "`n"
        $literal = @('git commit -m "$(cat <<''EOF''', 'use gh pr create here', 'EOF', ')"') -join "`n"

        Get-Match -CommandText $r733 -Word 'gh' -Sub @('pr', 'create') | Should -BeNullOrEmpty
        Get-Match -CommandText $literal -Word 'gh' -Sub @('pr', 'create') | Should -BeNullOrEmpty
    }

    It 'IV-24 pins the Resolve-CommandLineInvocation parameter list and OutputType' -Tag 'Issue824' {
        $command = Get-Command -Name 'Resolve-CommandLineInvocation' -CommandType Function

        (Get-DeclaredParameterName -Name 'Resolve-CommandLineInvocation') -join ',' | Should -Be 'CommandText,CommandWord,SubcommandPath'
        @($command.OutputType).Count | Should -Be 1
        $command.OutputType[0].Type | Should -Be ([pscustomobject])
    }
}
