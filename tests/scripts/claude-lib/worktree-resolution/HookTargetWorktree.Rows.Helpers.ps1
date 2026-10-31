<#
.SYNOPSIS
    Shared behavior rows and the row dispatcher for the HookTargetWorktree resolver suites (issue #1009).

.DESCRIPTION
    Holds the behavior rows of the resolver once, as data, so the module suite
    (tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1) and the
    Codex twin suite (tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1) run the
    same rows against their own implementation. Each row names the function under test,
    its arguments, an invoker kind (Synthetic, Porcelain, Throwing, Empty, FailIfCalled,
    or none), an optional issue-reader kind (Map or Throwing), and the expected result.

    This file defines no function under test and holds no state. Invoke-HookTargetWorktreeRow
    calls the named function by name, so whichever implementation the dot-sourcing suite
    has loaded answers the row. Every porcelain text, including the CRLF row, is built in
    memory; no fixture file is read.
#>

function Get-HookTargetWorktreeHelperRows {
    <#
    .SYNOPSIS
        Return the rows for the normalization, relative-path, enclosing-root, and key helpers.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Returns a list of test rows; the plural name is the documented contract of the shared row helper.')]
    [CmdletBinding()]
    [OutputType([System.Array])]
    param()

    $normalize = 'ConvertTo-HookTargetWorktreeNormalizedPath'
    $relative = 'Get-HookTargetWorktreeRelativePath'
    $enclosing = 'Get-HookTargetWorktreeEnclosingRoot'
    $key = 'Get-HookTargetWorktreeKey'
    $roots = @('/repo', '/repo/.claude/worktrees/item', '/repo-wt/sibling')

    @(
        @{ Name = 'normalize converts backslashes to forward slashes'; Function = $normalize; Arguments = @{ Path = 'C:\repo\src\a.py' }; Expected = 'C:/repo/src/a.py' }
        @{ Name = 'normalize collapses repeated slashes'; Function = $normalize; Arguments = @{ Path = '/repo//src///a.py' }; Expected = '/repo/src/a.py' }
        @{ Name = 'normalize trims a trailing slash'; Function = $normalize; Arguments = @{ Path = '/repo/src/' }; Expected = '/repo/src' }
        @{ Name = 'normalize keeps the bare slash root'; Function = $normalize; Arguments = @{ Path = '/' }; Expected = '/' }
        @{ Name = 'normalize keeps a bare drive root'; Function = $normalize; Arguments = @{ Path = 'C:\' }; Expected = 'C:/' }
        @{ Name = 'normalize keeps a drive-rooted forward-slash path'; Function = $normalize; Arguments = @{ Path = 'C:/Users/dev/repo' }; Expected = 'C:/Users/dev/repo' }
        @{ Name = 'normalize preserves a case variant'; Function = $normalize; Arguments = @{ Path = '/Repo/SRC' }; Expected = '/Repo/SRC' }
        @{ Name = 'normalize returns empty for blank input'; Function = $normalize; Arguments = @{ Path = '  ' }; Expected = '' }
        @{ Name = 'relative path inside a nested root'; Function = $relative; Arguments = @{ Path = '/repo/.claude/worktrees/item/src/a.py'; WorktreeRoot = '/repo/.claude/worktrees/item' }; Expected = 'src/a.py' }
        @{ Name = 'relative path of the root itself is empty'; Function = $relative; Arguments = @{ Path = '/repo/'; WorktreeRoot = '/repo' }; Expected = '' }
        @{ Name = 'relative path outside a root that shares a prefix is null'; Function = $relative; Arguments = @{ Path = '/repo-wt/sibling/a.py'; WorktreeRoot = '/repo' }; Expected = $null }
        @{ Name = 'relative path matches a backslash case variant'; Function = $relative; Arguments = @{ Path = 'C:\Repo\SRC\a.py'; WorktreeRoot = 'c:/repo' }; Expected = 'SRC/a.py' }
        @{ Name = 'relative path under the bare slash root'; Function = $relative; Arguments = @{ Path = '/a/b'; WorktreeRoot = '/' }; Expected = 'a/b' }
        @{ Name = 'relative path of a blank path is null'; Function = $relative; Arguments = @{ Path = ''; WorktreeRoot = '/repo' }; Expected = $null }
        @{ Name = 'enclosing root of a nested worktree path'; Function = $enclosing; Arguments = @{ Path = '/repo/.claude/worktrees/item/src/a.py'; Roots = $roots }; Expected = '/repo/.claude/worktrees/item' }
        @{ Name = 'enclosing root of a sibling worktree path'; Function = $enclosing; Arguments = @{ Path = '/repo-wt/sibling/x.py'; Roots = $roots }; Expected = '/repo-wt/sibling' }
        @{ Name = 'enclosing root of a main worktree path'; Function = $enclosing; Arguments = @{ Path = '/repo/src/a.py'; Roots = $roots }; Expected = '/repo' }
        @{ Name = 'enclosing root of a path outside every root is null'; Function = $enclosing; Arguments = @{ Path = '/elsewhere/a.py'; Roots = $roots }; Expected = $null }
        @{ Name = 'enclosing root matches a drive-rooted case variant'; Function = $enclosing; Arguments = @{ Path = 'C:\REPO\src\a.py'; Roots = @('', 'c:/repo') }; Expected = 'c:/repo' }
        @{ Name = 'enclosing root with no roots is null'; Function = $enclosing; Arguments = @{ Path = '/repo/a.py'; Roots = @() }; Expected = $null }
        @{ Name = 'key of the item worktree'; Function = $key; Arguments = @{ WorktreeRoot = '/repo/.claude/worktrees/item' }; Expected = 'item-52f211a6' }
        @{ Name = 'key shape is leaf dash eight hex'; Function = $key; Arguments = @{ WorktreeRoot = '/repo-wt/sibling/' }; ExpectedPattern = '^sibling-[0-9a-f]{8}$' }
        @{ Name = 'key sanitizes the leaf'; Function = $key; Arguments = @{ WorktreeRoot = '/repo-wt/my wt' }; ExpectedPattern = '^my_wt-[0-9a-f]{8}$' }
        @{ Name = 'key of a backslash root equals the key of its forward-slash form'; Function = $key; Arguments = @{ WorktreeRoot = 'C:\repo\item\' }; SameAs = 'C:/repo/item' }
    )
}

function Get-HookTargetWorktreePorcelainRows {
    <#
    .SYNOPSIS
        Return the rows for ConvertFrom-HookTargetWorktreePorcelain.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Returns a list of test rows; the plural name is the documented contract of the shared row helper.')]
    [CmdletBinding()]
    [OutputType([System.Array])]
    param()

    $function = 'ConvertFrom-HookTargetWorktreePorcelain'
    $lines = @(
        'worktree /repo', 'HEAD 1111111111111111111111111111111111111111', 'branch refs/heads/main', '',
        'worktree /repo/.claude/worktrees/item', 'HEAD 2222222222222222222222222222222222222222', 'branch refs/heads/bug/item', '',
        'worktree /repo-wt/sibling', 'HEAD 3333333333333333333333333333333333333333', 'branch refs/heads/bug/sibling', ''
    )
    $three = @(
        @{ Root = '/repo'; Branch = 'main'; Prunable = $false }
        @{ Root = '/repo/.claude/worktrees/item'; Branch = 'bug/item'; Prunable = $false }
        @{ Root = '/repo-wt/sibling'; Branch = 'bug/sibling'; Prunable = $false }
    )

    @(
        @{ Name = 'porcelain main and linked stanzas'; Function = $function; Arguments = @{ Text = ($lines -join "`n") }; ExpectedRecords = $three }
        @{ Name = 'porcelain CRLF line endings'; Function = $function; Arguments = @{ Text = ($lines -join "`r`n") }; ExpectedRecords = $three }
        @{ Name = 'porcelain skips a bare stanza'; Function = $function; Arguments = @{ Text = "worktree /srv/bare.git`nbare`n`nworktree /repo`nHEAD 1111111111111111111111111111111111111111`nbranch refs/heads/main`n" }; ExpectedRecords = @(@{ Root = '/repo'; Branch = 'main'; Prunable = $false }) }
        @{ Name = 'porcelain detached stanza has no branch'; Function = $function; Arguments = @{ Text = "worktree /repo-wt/detached`nHEAD 4444444444444444444444444444444444444444`ndetached`n" }; ExpectedRecords = @(@{ Root = '/repo-wt/detached'; Branch = $null; Prunable = $false }) }
        @{ Name = 'porcelain prunable stanza'; Function = $function; Arguments = @{ Text = "worktree /repo-wt/gone`nHEAD 5555555555555555555555555555555555555555`nbranch refs/heads/gone`nprunable gitdir file points to non-existent location`n" }; ExpectedRecords = @(@{ Root = '/repo-wt/gone'; Branch = 'gone'; Prunable = $true }) }
        @{ Name = 'porcelain tolerates repeated blank lines'; Function = $function; Arguments = @{ Text = "`n`nworktree /repo`nbranch refs/heads/main`n`n`n`nworktree /repo-wt/b`nbranch refs/heads/b`n`n" }; ExpectedRecords = @(@{ Root = '/repo'; Branch = 'main'; Prunable = $false }, @{ Root = '/repo-wt/b'; Branch = 'b'; Prunable = $false }) }
        @{ Name = 'porcelain of empty text has no record'; Function = $function; Arguments = @{ Text = '' }; ExpectedRecords = @() }
    )
}

function Get-HookTargetWorktreeResolverRows {
    <#
    .SYNOPSIS
        Return the rows for Resolve-HookTargetWorktree parameters, precedence, and path resolution.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Returns a list of test rows; the plural name is the documented contract of the shared row helper.')]
    [CmdletBinding()]
    [OutputType([System.Array])]
    param()

    $function = 'Resolve-HookTargetWorktree'
    $item = '/repo/.claude/worktrees/item'
    $sibling = '/repo-wt/sibling'

    @(
        @{ Name = 'declares the seven parameters with SessionRoot mandatory'; Function = $function; Check = 'ParameterSet'; ExpectedParameters = @('SessionRoot', 'FilePath', 'CommandOperandPath', 'CommandBranch', 'DelegationPrompt', 'CheckpointIssueReader', 'WorktreeListInvoker'); ExpectedMandatory = @('SessionRoot') }
        @{ Name = 'FilePath decides over CommandOperand and DelegationIdentity'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; FilePath = @("$item/src/a.py"); CommandBranch = 'bug/sibling'; DelegationPrompt = 'branch: bug/sibling' }; Expected = @{ WorktreeRoot = $item; Source = 'FilePath'; Ambiguous = $false; ReasonCode = $null; InvokerCalls = 1 } }
        @{ Name = 'a relative FilePath decides before a present branch and never calls the invoker'; Function = $function; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = '/repo'; FilePath = @('src/a.py'); CommandBranch = 'bug/sibling' }; Expected = @{ WorktreeRoot = '/repo'; Source = 'SessionRoot'; Ambiguous = $false; DetailNonEmpty = $true; InvokerCalls = 0 } }
        @{ Name = 'CommandOperand decides over DelegationIdentity'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; CommandBranch = 'bug/item'; DelegationPrompt = 'branch: bug/sibling' }; Expected = @{ WorktreeRoot = $item; Source = 'CommandOperand'; Ambiguous = $false; ReasonCode = $null; InvokerCalls = 1 } }
        @{ Name = 'a CommandOperandPath resolves through the CommandOperand source'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; CommandOperandPath = @("$sibling/x.ps1") }; Expected = @{ WorktreeRoot = $sibling; Source = 'CommandOperand'; Ambiguous = $false; ReasonCode = $null; Candidates = @() } }
        @{ Name = 'a CommandBranch resolves through the CommandOperand source'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; CommandBranch = 'bug/sibling' }; Expected = @{ WorktreeRoot = $sibling; Source = 'CommandOperand'; Ambiguous = $false; ReasonCode = $null } }
        @{ Name = 'a relative-only CommandOperandPath maps to the session root without the invoker'; Function = $function; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = '/repo'; CommandOperandPath = @('src/a.ps1') }; Expected = @{ WorktreeRoot = '/repo'; Source = 'SessionRoot'; InvokerCalls = 0 } }
        @{ Name = 'no source present returns the session root without the invoker'; Function = $function; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = '/repo'; FilePath = @('', ' ') }; Expected = @{ WorktreeRoot = '/repo'; Source = 'SessionRoot'; Ambiguous = $false; ReasonCode = $null; DetailNonEmpty = $true; InvokerCalls = 0 } }
        @{ Name = 'the no-source session root is normalized'; Function = $function; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = 'C:\repo\' }; Expected = @{ WorktreeRoot = 'C:/repo'; Source = 'SessionRoot'; InvokerCalls = 0 } }
        @{ Name = 'a relative path maps to the session root without the invoker'; Function = $function; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = '/repo'; FilePath = @('src/a.py') }; Expected = @{ WorktreeRoot = '/repo'; Source = 'SessionRoot'; Ambiguous = $false; InvokerCalls = 0 } }
        @{ Name = 'an absolute path in the nested worktree resolves to it'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; FilePath = @("$item/src/a.py") }; Expected = @{ WorktreeRoot = $item; Source = 'FilePath'; Ambiguous = $false; ReasonCode = $null; Candidates = @(); DetailNonEmpty = $false } }
        @{ Name = 'an absolute path in the sibling worktree resolves to it'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; FilePath = @("$sibling/a.py") }; Expected = @{ WorktreeRoot = $sibling; Source = 'FilePath'; Ambiguous = $false } }
        @{ Name = 'an absolute path in the main worktree resolves to it'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; FilePath = @('/repo/src/a.py') }; Expected = @{ WorktreeRoot = '/repo'; Source = 'FilePath'; Ambiguous = $false } }
        @{ Name = 'two paths in one worktree call the invoker once'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; FilePath = @("$item/a.py", "$item/b.py") }; Expected = @{ WorktreeRoot = $item; Source = 'FilePath'; InvokerCalls = 1 } }
        @{ Name = 'a backslash case-variant path matches a drive-rooted worktree'; Function = $function; InvokerKind = 'Porcelain'; Porcelain = "worktree C:/repo`nbranch refs/heads/main`n`nworktree C:/repo/.claude/worktrees/item`nbranch refs/heads/bug/item`n"; Arguments = @{ SessionRoot = 'C:\repo'; FilePath = @('c:\REPO\.claude\worktrees\ITEM\src\a.py') }; Expected = @{ WorktreeRoot = 'C:/repo/.claude/worktrees/item'; Source = 'FilePath'; Ambiguous = $false } }
        @{ Name = 'a path outside every worktree falls back to the session root'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; FilePath = @('/elsewhere/a.py') }; Expected = @{ WorktreeRoot = '/repo'; Source = 'SessionRoot'; Ambiguous = $false; ReasonCode = $null; DetailNonEmpty = $true } }
        @{ Name = 'a throwing invoker falls back to the session root'; Function = $function; InvokerKind = 'Throwing'; Arguments = @{ SessionRoot = '/repo'; FilePath = @("$item/a.py") }; Expected = @{ WorktreeRoot = '/repo'; Source = 'SessionRoot'; Ambiguous = $false; ReasonCode = $null; DetailNonEmpty = $true; InvokerCalls = 1 } }
        @{ Name = 'an empty invoker falls back to the session root'; Function = $function; InvokerKind = 'Empty'; Arguments = @{ SessionRoot = '/repo'; FilePath = @("$item/a.py") }; Expected = @{ WorktreeRoot = '/repo'; Source = 'SessionRoot'; Ambiguous = $false; ReasonCode = $null; DetailNonEmpty = $true; InvokerCalls = 1 } }
    )
}

function Get-HookTargetWorktreeIdentityRows {
    <#
    .SYNOPSIS
        Return the ambiguity, not-derivable, branch, and delegation-identity rows for Resolve-HookTargetWorktree.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Returns a list of test rows; the plural name is the documented contract of the shared row helper.')]
    [CmdletBinding()]
    [OutputType([System.Array])]
    param()

    $function = 'Resolve-HookTargetWorktree'
    $item = '/repo/.claude/worktrees/item'
    $sibling = '/repo-wt/sibling'
    $ambiguous = 'TARGET_WORKTREE_AMBIGUOUS'
    $notDerivable = 'TARGET_WORKTREE_NOT_DERIVABLE'
    $issueLine = 'Canonical issue number for this feature is 1009.'
    $duplicateBranch = "worktree /repo`nbranch refs/heads/main`n`nworktree /repo-wt/a`nbranch refs/heads/dup`n`nworktree /repo-wt/b`nbranch refs/heads/dup`n"

    @(
        @{ Name = 'disagreeing file paths are ambiguous'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; FilePath = @('/repo/src/a.py', "$sibling/b.py") }; Expected = @{ WorktreeRoot = $null; Source = 'FilePath'; Ambiguous = $true; ReasonCode = $ambiguous; Candidates = @('/repo', $sibling) } }
        @{ Name = 'a relative and a nested path disagree'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; FilePath = @('src/a.py', "$item/b.py") }; Expected = @{ WorktreeRoot = $null; Ambiguous = $true; ReasonCode = $ambiguous; Candidates = @('/repo', $item) } }
        @{ Name = 'a branch matching no worktree is not derivable'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; CommandBranch = 'bug/none' }; Expected = @{ WorktreeRoot = $null; Source = 'CommandOperand'; Ambiguous = $false; ReasonCode = $notDerivable; DetailNonEmpty = $true } }
        @{ Name = 'a branch matching one worktree resolves to it'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; CommandBranch = ' bug/item ' }; Expected = @{ WorktreeRoot = $item; Source = 'CommandOperand'; ReasonCode = $null } }
        @{ Name = 'a branch matching two worktrees is ambiguous'; Function = $function; InvokerKind = 'Porcelain'; Porcelain = $duplicateBranch; Arguments = @{ SessionRoot = '/repo'; CommandBranch = 'dup' }; Expected = @{ WorktreeRoot = $null; Ambiguous = $true; ReasonCode = $ambiguous; Candidates = @('/repo-wt/a', '/repo-wt/b') } }
        @{ Name = 'an operand path and a branch that disagree are ambiguous'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; CommandOperandPath = @('/repo/src/a.ps1'); CommandBranch = 'bug/item' }; Expected = @{ WorktreeRoot = $null; Source = 'CommandOperand'; Ambiguous = $true; ReasonCode = $ambiguous; Candidates = @('/repo', $item); InvokerCalls = 1 } }
        @{ Name = 'an operand path and a branch that agree resolve'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; CommandOperandPath = @("$item/x.ps1"); CommandBranch = 'bug/item' }; Expected = @{ WorktreeRoot = $item; Source = 'CommandOperand'; Ambiguous = $false } }
        @{ Name = 'ambiguous operand paths stay ambiguous with a branch'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; CommandOperandPath = @('/repo/a.ps1', "$item/b.ps1"); CommandBranch = 'bug/item' }; Expected = @{ WorktreeRoot = $null; ReasonCode = $ambiguous } }
        @{ Name = 'an operand path with an unknown branch is not derivable'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; CommandOperandPath = @("$item/x.ps1"); CommandBranch = 'bug/none' }; Expected = @{ WorktreeRoot = $null; ReasonCode = $notDerivable } }
        @{ Name = 'a branch label in the prompt resolves through DelegationIdentity'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "work item`nbranch: bug/item.`n" }; Expected = @{ WorktreeRoot = $item; Source = 'DelegationIdentity'; ReasonCode = $null } }
        @{ Name = 'two branch labels are ambiguous'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "branch: bug/item`nbranch: bug/sibling" }; Expected = @{ WorktreeRoot = $null; Source = 'DelegationIdentity'; Ambiguous = $true; ReasonCode = $ambiguous } }
        @{ Name = 'the canonical issue line resolves with a checkpoint issue reader'; Function = $function; InvokerKind = 'Synthetic'; ReaderKind = 'Map'; ReaderMap = @{ $item = '#1009' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = $issueLine }; Expected = @{ WorktreeRoot = $item; Source = 'DelegationIdentity'; ReasonCode = $null } }
        @{ Name = 'an issue-only prompt without a reader is not derivable'; Function = $function; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = $issueLine }; Expected = @{ WorktreeRoot = $null; Source = 'DelegationIdentity'; ReasonCode = $notDerivable; InvokerCalls = 0 } }
        @{ Name = 'an issue recorded by no worktree is not derivable'; Function = $function; InvokerKind = 'Synthetic'; ReaderKind = 'Map'; ReaderMap = @{ $item = '42' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = $issueLine }; Expected = @{ WorktreeRoot = $null; ReasonCode = $notDerivable } }
        @{ Name = 'an issue recorded by two worktrees is ambiguous'; Function = $function; InvokerKind = 'Synthetic'; ReaderKind = 'Map'; ReaderMap = @{ $item = '1009'; $sibling = '01009' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = $issueLine }; Expected = @{ WorktreeRoot = $null; Ambiguous = $true; ReasonCode = $ambiguous; Candidates = @($item, $sibling) } }
        @{ Name = 'a throwing reader records no issue'; Function = $function; InvokerKind = 'Synthetic'; ReaderKind = 'Throwing'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = $issueLine }; Expected = @{ WorktreeRoot = $null; ReasonCode = $notDerivable } }
        @{ Name = 'several issue numbers are ambiguous'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "$issueLine Canonical issue number for this feature is #1010." }; Expected = @{ WorktreeRoot = $null; Ambiguous = $true; ReasonCode = $ambiguous } }
        @{ Name = 'a repeated issue number is one issue'; Function = $function; InvokerKind = 'Synthetic'; ReaderKind = 'Map'; ReaderMap = @{ $item = '1009' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "$issueLine Canonical issue number for this feature is #01009." }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null } }
        @{ Name = 'a branch whose worktree records another issue is ambiguous'; Function = $function; InvokerKind = 'Synthetic'; ReaderKind = 'Map'; ReaderMap = @{ $sibling = '42' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "branch: bug/sibling`n$issueLine" }; Expected = @{ WorktreeRoot = $null; Ambiguous = $true; ReasonCode = $ambiguous; Candidates = @($sibling) } }
        @{ Name = 'a branch and an issue recorded elsewhere are ambiguous'; Function = $function; InvokerKind = 'Synthetic'; ReaderKind = 'Map'; ReaderMap = @{ $item = '1009' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "branch: bug/sibling`n$issueLine" }; Expected = @{ WorktreeRoot = $null; Ambiguous = $true; ReasonCode = $ambiguous; Candidates = @($sibling, $item) } }
        @{ Name = 'a branch and an agreeing issue resolve'; Function = $function; InvokerKind = 'Synthetic'; ReaderKind = 'Map'; ReaderMap = @{ $item = '1009' }; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "branch: bug/item`n$issueLine" }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null } }
        @{ Name = 'a branch with an issue recorded nowhere stays authoritative'; Function = $function; InvokerKind = 'Synthetic'; ReaderKind = 'Map'; ReaderMap = @{}; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "branch: bug/item`n$issueLine" }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null } }
        @{ Name = 'a branch with an issue and no reader stays authoritative'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = "branch: bug/item`n$issueLine" }; Expected = @{ WorktreeRoot = $item; ReasonCode = $null } }
        @{ Name = 'a present identity naming no worktree never returns the session root'; Function = $function; InvokerKind = 'Synthetic'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = 'branch: bug/none' }; Expected = @{ WorktreeRoot = $null; Source = 'DelegationIdentity'; ReasonCode = $notDerivable } }
        @{ Name = 'a prompt with no identity signal is not derivable'; Function = $function; InvokerKind = 'FailIfCalled'; Arguments = @{ SessionRoot = '/repo'; DelegationPrompt = 'resume the work' }; Expected = @{ WorktreeRoot = $null; Source = 'DelegationIdentity'; ReasonCode = $notDerivable; InvokerCalls = 0 } }
    )
}

function Invoke-HookTargetWorktreeRow {
    <#
    .SYNOPSIS
        Run one shared row against whichever implementation the calling suite has loaded.
    .DESCRIPTION
        Builds the row's invoker and issue reader, calls the named function by name, and
        returns the output with the invoker call count. A ParameterSet row returns the
        declared and mandatory parameter names instead of calling the function.
    .PARAMETER Row
        The row hashtable.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)] [hashtable] $Row
    )

    if ($Row.ContainsKey('Check') -and $Row.Check -eq 'ParameterSet') {
        $command = Get-Command -Name $Row.Function -CommandType Function
        $common = @([System.Management.Automation.PSCmdlet]::CommonParameters) + @([System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
        $declared = @($command.Parameters.Keys | Where-Object { $common -notcontains $_ })
        $mandatory = @($declared | Where-Object { @($command.Parameters[$_].ParameterSets.Values | Where-Object { $_.IsMandatory }).Count -gt 0 })
        return [pscustomobject]@{ Output = $declared; Mandatory = $mandatory; InvokerCalls = 0 }
    }

    $synthetic = @(
        'worktree /repo', 'HEAD 1111111111111111111111111111111111111111', 'branch refs/heads/main', '',
        'worktree /repo/.claude/worktrees/item', 'HEAD 2222222222222222222222222222222222222222', 'branch refs/heads/bug/item', '',
        'worktree /repo-wt/sibling', 'HEAD 3333333333333333333333333333333333333333', 'branch refs/heads/bug/sibling', ''
    ) -join "`n"
    $calls = @{ Made = 0 }
    $porcelain = if ($Row.ContainsKey('Porcelain')) { $Row.Porcelain } else { $synthetic }
    $kind = if ($Row.ContainsKey('InvokerKind')) { $Row.InvokerKind } else { 'None' }
    $arguments = @{}
    if ($Row.ContainsKey('Arguments')) { foreach ($name in $Row.Arguments.Keys) { $arguments[$name] = $Row.Arguments[$name] } }

    $invoker = switch ($kind) {
        'Throwing' { { param($SessionRoot) [void] $SessionRoot; $calls.Made++; throw 'synthetic worktree list failure' }.GetNewClosure() }
        'Empty' { { param($SessionRoot) [void] $SessionRoot; $calls.Made++; '' }.GetNewClosure() }
        'FailIfCalled' { { param($SessionRoot) [void] $SessionRoot; $calls.Made++; throw 'the worktree list invoker must not be called for this row' }.GetNewClosure() }
        'None' { $null }
        default { { param($SessionRoot) [void] $SessionRoot; $calls.Made++; $porcelain }.GetNewClosure() }
    }
    if ($null -ne $invoker) { $arguments['WorktreeListInvoker'] = $invoker }

    if ($Row.ContainsKey('ReaderKind')) {
        $readerMap = if ($Row.ContainsKey('ReaderMap')) { $Row.ReaderMap } else { @{} }
        $arguments['CheckpointIssueReader'] = if ($Row.ReaderKind -eq 'Throwing') {
            { param($WorktreeRoot) [void] $WorktreeRoot; throw 'synthetic checkpoint read failure' }
        } else {
            { param($WorktreeRoot) $readerMap[$WorktreeRoot] }.GetNewClosure()
        }
    }

    $output = @(& $Row.Function @arguments)
    return [pscustomobject]@{ Output = $output; InvokerCalls = $calls.Made }
}
