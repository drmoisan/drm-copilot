#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Coverage of the payload-aware command iterator and the presence predicate (issue #824, T-PAY).

.DESCRIPTION
    Drives Read-CommandLineInvocationSegment and Test-CommandLineWordPresent from
    hook-command-payload.ps1 and the PowerShell adapter in hook-command-payload-powershell.ps1.
    Both modules are loaded only through hook-command-invocation.ps1, which dot-sources them.

    Every row runs against the Claude and the Codex copy. Each case is a pure string case:
    no temporary file, no child process, no live executable, and no disk read beyond
    dot-sourcing the files under test. The base64 payloads are computed in the test.
#>

BeforeDiscovery {
    $script:Runtimes = @(
        @{ Runtime = 'claude'; HookRoot = '.claude/hooks' }
        @{ Runtime = 'codex'; HookRoot = '.codex/hooks' }
    )
}

Describe 'hook-command-payload iterator, <Runtime> copy (issue #824)' -ForEach $script:Runtimes {
    BeforeAll {
        $repoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $repoRoot "$HookRoot/hook-command-invocation.ps1")

        function Get-InvocationRecord {
            <# Return the iterator records for one command text as an array. #>
            param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)
            return @(Read-CommandLineInvocationSegment -CommandText $CommandText)
        }

        function Get-DeclaredParameterName {
            <# Return a function's declared parameter names, common parameters removed. #>
            param([Parameter(Mandatory)][string] $Name)
            $command = Get-Command -Name $Name -CommandType Function
            $common = @([System.Management.Automation.PSCmdlet]::CommonParameters) +
            @([System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
            return @($command.Parameters.Keys | Where-Object { $common -notcontains $_ } | Sort-Object)
        }

        function ConvertTo-EncodedCommandText {
            <# Return the base64 UTF-16LE encoding pwsh -EncodedCommand expects. #>
            param([Parameter(Mandatory)][string] $Text)
            return [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Text))
        }
    }

    It 'PY-01 carries every documented record property' -Tag 'Issue824' {
        $record = (Get-InvocationRecord -CommandText 'git status')[0]
        $expected = @('Index', 'RootIndex', 'Depth', 'Origin', 'Wrapper', 'Dialect', 'RawText', 'RootRawText', 'Tokens',
            'CommandWord', 'Literal', 'Unbalanced', 'Opaque', 'OpaqueReason', 'Delimiter', 'PresenceText')

        $names = @($record.PSObject.Properties.Name)

        foreach ($name in $expected) { $names | Should -Contain $name }
    }

    It 'PY-02 pins the parameter list, the MaxDepth default of 4, and the OutputType' -Tag 'Issue824' {
        $command = Get-Command -Name 'Read-CommandLineInvocationSegment' -CommandType Function
        $maxDepth = @($command.ScriptBlock.Ast.Body.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'MaxDepth' })[0]

        (Get-DeclaredParameterName -Name 'Read-CommandLineInvocationSegment') -join ',' | Should -Be 'CommandText,MaxDepth'
        $maxDepth.DefaultValue.Extent.Text | Should -Be '4'
        @($command.OutputType).Count | Should -Be 1
        $command.OutputType[0].Type | Should -Be ([pscustomobject[]])
    }

    It 'PY-03 returns one TopLevel record for git status' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText 'git status'

        $records.Count | Should -Be 1
        $records[0].Origin | Should -Be 'TopLevel'
        $records[0].Depth | Should -Be 0
        $records[0].CommandWord | Should -Be 'git'
        $records[0].Dialect | Should -Be 'Posix'
    }

    It 'PY-04 extracts the bash -c payload as a depth-1 WrapperPayload record' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText "bash -c 'git add .'"

        $records.Count | Should -Be 2
        $records[1].CommandWord | Should -Be 'git'
        $records[1].Depth | Should -Be 1
        $records[1].Origin | Should -Be 'WrapperPayload'
        $records[1].Wrapper | Should -Be 'bash'
        $records[1].Dialect | Should -Be 'Posix'
        $records[1].RootIndex | Should -Be 0
    }

    It 'PY-05 extracts the payload of <_>' -Tag 'Issue824' -ForEach @("sh -c 'git add .'", "zsh -c 'git add .'", "dash -c 'git add .'", "ksh -c 'git add .'", "bash -lc 'git add .'") {
        $records = Get-InvocationRecord -CommandText $_

        @($records | Where-Object { $_.Depth -eq 1 -and $_.CommandWord -eq 'git' }).Count | Should -Be 1
    }

    It 'PY-06 marks the Y1 payload record gh as non-literal' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText "bash -c 'gh ""`$@""' _ issue create"

        $payload = @($records | Where-Object { $_.Depth -eq 1 })[0]
        $payload.CommandWord | Should -Be 'gh'
        $payload.Literal | Should -BeFalse
    }

    It 'PY-07 extracts a PowerShell git record from <_>' -Tag 'Issue824' -ForEach @(
        "pwsh -Command 'git add .'", "pwsh -c 'git add .'", "pwsh -com 'git add .'",
        "pwsh -CommandWithArgs 'git add .'", "pwsh -cwa 'git add .'", "powershell -Command 'git add .'"
    ) {
        $records = Get-InvocationRecord -CommandText $_

        $payload = @($records | Where-Object { $_.Depth -eq 1 -and $_.CommandWord -eq 'git' })
        $payload.Count | Should -Be 1
        $payload[0].Dialect | Should -Be 'PowerShell'
    }

    It 'PY-08 skips -NoProfile and joins the remaining tokens of -Command' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText 'pwsh -NoProfile -Command git add .'

        $payload = @($records | Where-Object { $_.Depth -eq 1 })[0]
        $payload.CommandWord | Should -Be 'git'
        ($payload.Tokens -join ' ') | Should -Be 'git add .'
    }

    It 'PY-09 decodes the encoded form <_>' -Tag 'Issue824' -ForEach @('-EncodedCommand', '-e', '-ec') {
        $command = "pwsh $_ $(ConvertTo-EncodedCommandText -Text 'git add .')"

        $records = Get-InvocationRecord -CommandText $command

        $payload = @($records | Where-Object { $_.Depth -eq 1 })
        $payload.Count | Should -Be 1
        $payload[0].CommandWord | Should -Be 'git'
        $payload[0].Dialect | Should -Be 'PowerShell'
    }

    It 'PY-10 marks an undecodable encoded payload Opaque with DecodeFailure' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText 'pwsh -EncodedCommand ###'

        $records.Count | Should -Be 1
        $records[0].Opaque | Should -BeTrue
        $records[0].OpaqueReason | Should -Be 'DecodeFailure'
    }

    It 'PY-11 reports a PowerShell parse error as an Unbalanced record' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText "pwsh -c 'git add .; if ('"

        @($records | Where-Object { $_.Unbalanced }).Count | Should -Be 1
    }

    It 'PY-12 expands four eval wrappers and stops at the fifth with DepthLimit' -Tag 'Issue824' {
        $four = Get-InvocationRecord -CommandText 'eval eval eval eval git add .'
        $five = Get-InvocationRecord -CommandText 'eval eval eval eval eval git add .'

        @($four | Where-Object { $_.CommandWord -eq 'git' -and $_.Depth -eq 4 }).Count | Should -Be 1
        @($five | Where-Object { $_.CommandWord -eq 'git' }).Count | Should -Be 0
        @($five | Where-Object { $_.Opaque -and $_.OpaqueReason -eq 'DepthLimit' }).Count | Should -Be 1
    }

    It 'PY-13 extracts the eval payload' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText 'eval git add .'

        $records[1].CommandWord | Should -Be 'git'
        $records[1].Wrapper | Should -Be 'eval'
        $records[1].Origin | Should -Be 'WrapperPayload'
    }

    It 'PY-14 records the xargs-injected command for <_>' -Tag 'Issue824' -ForEach @('echo x | xargs git add', 'xargs -n 1 git add', 'xargs -I {} git add {}') {
        $records = Get-InvocationRecord -CommandText $_

        $injected = @($records | Where-Object { $_.Origin -eq 'ArgumentInjector' })
        $injected.Count | Should -Be 1
        $injected[0].CommandWord | Should -Be 'git'
        $injected[0].Wrapper | Should -Be 'xargs'
    }

    It 'PY-15 records a double-quoted command substitution body' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText 'echo "$(git add .)"'

        $body = @($records | Where-Object { $_.Origin -eq 'Substitution' })
        $body.Count | Should -Be 1
        $body[0].CommandWord | Should -Be 'git'
        $body[0].Depth | Should -Be 1
    }

    It 'PY-16 marks the script-file form <_> Opaque with NoPayload' -Tag 'Issue824' -ForEach @('bash x.sh', 'pwsh -File x.ps1') {
        $records = Get-InvocationRecord -CommandText $_

        $records.Count | Should -Be 1
        $records[0].Opaque | Should -BeTrue
        $records[0].OpaqueReason | Should -Be 'NoPayload'
    }

    It 'PY-17 joins a backslash-newline continuation before segmenting' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText ("gh issue \`n" + 'create')

        $records.Count | Should -Be 1
        ($records[0].Tokens -join ',') | Should -Be 'gh,issue,create'
    }

    It 'PY-18 leaf-normalizes <Command> to <Word>' -Tag 'Issue824' -ForEach @(
        @{ Command = '/usr/bin/git status'; Word = 'git' }
        @{ Command = 'C:\tools\gh.exe pr list'; Word = 'gh' }
        @{ Command = 'GH.EXE x'; Word = 'GH' }
    ) {
        $records = Get-InvocationRecord -CommandText $Command

        $records[0].CommandWord | Should -BeExactly $Word
    }

    It 'PY-19 reports Literal <Literal> for <Command>' -Tag 'Issue824' -ForEach @(
        @{ Command = 'git add $x'; Depth = 0; Word = 'git'; Literal = $false }
        @{ Command = 'git add x'; Depth = 0; Word = 'git'; Literal = $true }
        @{ Command = "pwsh -c 'git add (Join-Path a b)'"; Depth = 1; Word = 'git'; Literal = $false }
        @{ Command = "pwsh -c 'git @a'"; Depth = 1; Word = 'git'; Literal = $false }
        @{ Command = "pwsh -c '`$x = 1'"; Depth = 1; Word = ''; Literal = $false }
    ) {
        $records = Get-InvocationRecord -CommandText $Command

        $match = @($records | Where-Object { $_.Depth -eq $Depth -and $_.CommandWord -eq $Word })
        $match.Count | Should -BeGreaterThan 0
        $match[0].Literal | Should -Be $Literal
    }

    It 'PY-20 carries the scanner Delimiter onto the record' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText 'a && b'

        $records[0].Delimiter | Should -Be '&&'
        $records[1].Delimiter | Should -Be ''
    }

    It 'PY-21 numbers records in pre-order and points each at its root' -Tag 'Issue824' {
        $records = Get-InvocationRecord -CommandText "bash -c 'a; b'; c"

        ($records.Index -join ',') | Should -Be '0,1,2,3'
        ($records.RootIndex -join ',') | Should -Be '0,0,0,3'
    }

    It 'PY-22 reports presence of <Word> in <Text> as <Expected>' -Tag 'Issue824' -ForEach @(
        @{ Text = 'run gh now'; Word = 'gh'; Expected = $true }
        @{ Text = 'through'; Word = 'gh'; Expected = $false }
        @{ Text = 'New-Object'; Word = 'new'; Expected = $false }
        @{ Text = 'worktrees'; Word = 'worktree'; Expected = $false }
        @{ Text = 'Remove-Item'; Word = 'remove'; Expected = $false }
        @{ Text = 'GH'; Word = 'gh'; Expected = $true }
        @{ Text = 'a-gh'; Word = 'gh'; Expected = $false }
        @{ Text = 'gh-x'; Word = 'gh'; Expected = $false }
        @{ Text = '(issue #1)'; Word = 'issue'; Expected = $true }
        @{ Text = ''; Word = 'gh'; Expected = $false }
    ) {
        Test-CommandLineWordPresent -RawText $Text -Word $Word | Should -Be $Expected
    }

    It 'PY-23 pins the Test-CommandLineWordPresent parameter list and OutputType' -Tag 'Issue824' {
        $command = Get-Command -Name 'Test-CommandLineWordPresent' -CommandType Function

        (Get-DeclaredParameterName -Name 'Test-CommandLineWordPresent') -join ',' | Should -Be 'RawText,Word'
        @($command.OutputType).Count | Should -Be 1
        $command.OutputType[0].Type | Should -Be ([bool])
    }

    It 'PY-24 sets PresenceText per origin' -Tag 'Issue824' {
        $topLevel = Get-InvocationRecord -CommandText 'git status'
        $payload = Get-InvocationRecord -CommandText "bash -c 'git add .'"
        $injected = Get-InvocationRecord -CommandText 'echo x | xargs git add'
        $commit = @(
            'git commit -m "$(cat <<''EOF'''
            'fix(hooks): route the matcher through the process that created the payload'
            'EOF'
            ')"'
        ) -join "`n"
        $substitution = @(Get-InvocationRecord -CommandText $commit | Where-Object { $_.Origin -eq 'Substitution' })

        $topLevel[0].PresenceText | Should -Be 'git status'
        $payload[1].PresenceText | Should -Be $payload[1].RootRawText
        @($injected | Where-Object { $_.Origin -eq 'ArgumentInjector' })[0].PresenceText | Should -Be 'echo x | xargs git add'
        $substitution.Count | Should -Be 1
        $substitution[0].PresenceText | Should -Not -Match 'route the matcher' -Because 'the heredoc body is blanked in TokenText'
    }
}
