<#
    Test-support helpers for the enforcement-hook Python-invocation guard (issue #475).

    PURPOSE. The `.claude/**` payload ships to destinations not guaranteed to have a
    Python interpreter, a Poetry environment, or `scripts/dev_tools` importable, so a
    hook that shells out to `python` fails obscurely or blocks every operation there.
    These helpers prove structurally that no enforcement hook or hook library invokes
    a Python interpreter on any path.

    STRUCTURAL, NOT BEHAVIORAL (SD-3). Detection parses source text with the AST and
    classifies every `CommandAst`. Nothing here mutates `$env:PATH`, saves or
    restores PATH, probes for a live `python`, or defines a shadow `function python`.

    ALLOWLIST POLICY - THE TABLE IS EMPTY AND MUST REMAIN EMPTY.
    `$script:PythonInvocationAllowlist` is authored with ZERO entries: every Python
    invocation site in the guarded tree is removed within issue #475. Entries may be
    added ONLY by an explicit owner decision recorded in the feature specification; an
    implementer failing this guard must remove the invocation and must NEVER add an
    entry to work around it. Assertion B fails any stale entry.

    BASH-MIGRATION ORACLE INTENT. The suite consuming these helpers is the intended
    behavioral oracle for the eventual bash migration of the hook surface; the
    detection classes and carve-outs are the contract migration must reproduce.

    DETECTION CLASSES (all case-insensitive).
      1. Constant command whose `GetCommandName()` is exactly `python`, `python3`,
         `py`, or `poetry`, in bare, `&`, `.`, and quoted forms.
      2. `Start-Process` whose `-FilePath`, or first positional argument, is one of
         those constants.
      3. Dynamic invocation (command position is not a literal constant), reported
         fail-closed, subject to the two carve-outs below.
      4. Any `Invoke-Expression`, including its built-in alias `iex`; recognizing
         only the long form would leave the check trivially bypassable.

    CARVE-OUTS FOR CLASS 3 (both deliberate, both documented).
      (a) A command-position variable whose name matches a `[scriptblock]`-typed
          parameter declared anywhere in the same file: the approved injectable-seam
          pattern of `.claude/rules/powershell.md` (`& $Invoker`, `& $ProfileReader`,
          `& $RequiredArtifactReader`, `& $FileExistsCheck`), 25 sites in the tree.
      (b) The sibling-script helper-load pattern under the dot-source (`.`) operator,
          in both forms the guarded tree uses: dot-sourcing a variable that is NOT a
          `[scriptblock]` parameter (`enforce-completion-consistency.ps1:47`,
          `enforce-parallel-drift-gate.ps1:67`), and dot-sourcing an inline
          `Join-Path $PSScriptRoot '<sibling>.ps1'` expression
          (`enforce-pr-author-skill.ps1:142`). Both load an in-repo `.ps1` sibling and
          can never be an interpreter; the inline form is matched tightly by
          `Test-SiblingScriptLoadExpression`. A dot-sourced expression of any other
          shape, and any `&`-invocation of a non-scriptblock variable, stay
          fail-closed.

    RESIDUAL GAP (accepted, recorded rather than silently ignored). Carve-out (a)
    matches on parameter NAME within file scope, not true dataflow binding, so a
    non-parameter variable sharing a name with a `[scriptblock]` parameter would be
    carved out. Accepted: binding analysis here is disproportionate, and an
    interpreter invocation is a constant-command construct (class 1). The
    spec-sanctioned fallback, should AST binding prove unreliable, is to flag dynamic
    invocations only when the name matches `(?i)python|poetry|py\b`; NOT in use.

    SCOPE. Test support only: NOT mirrored, NOT in `core.json`, NOT a coverage target.
#>


# ALLOWLIST - INTENTIONALLY EMPTY. Read "ALLOWLIST POLICY" above before touching it.
# A would-be entry: @{ Path = '.claude/hooks/example.ps1'; Function = 'Invoke-Example' }
$script:PythonInvocationAllowlist = @()
# Command names denoting a Python interpreter or the Poetry launcher.
$script:PythonInterpreterCommandName = @('python', 'python3', 'py', 'poetry')

function Get-PythonInvocationAllowlist {
    <#
    .SYNOPSIS
        Returns the (empty by design) allowlist. A would-be entry is a hashtable
        with `Path` (repo-root-relative) and `Function` ('<script>' at file scope).
    .OUTPUTS
        [object[]] The allowlist entries.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param()

    return , @($script:PythonInvocationAllowlist)
}

function Get-LiteralCommandValue {
    <#
    .SYNOPSIS
        Returns an expression's literal string value, or $null when not a constant.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Management.Automation.Language.Ast]$Expression
    )

    # StringConstantExpressionAst derives from ConstantExpressionAst, so this one
    # check covers both bare and quoted literals.
    if ($Expression -is [System.Management.Automation.Language.ConstantExpressionAst]) {
        return [string]$Expression.Value
    }
    return $null
}

function Get-VariableName {
    <#
    .SYNOPSIS
        Returns a variable's name without sigil or scope. `UnqualifiedPath` is NOT a
        public member of `VariablePath` (only `UserPath` is) and silently reads as
        '', which collapsed every seam name and carved out every dynamic invocation;
        this reads `UserPath` and strips the scope itself.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.VariableExpressionAst]$Variable
    )

    $userPath = [string]$Variable.VariablePath.UserPath
    $separator = $userPath.LastIndexOf(':')
    if ($separator -ge 0) {
        return $userPath.Substring($separator + 1)
    }
    return $userPath
}

function Get-ScriptBlockParameterName {
    <#
    .SYNOPSIS
        Collects every `[scriptblock]`-typed parameter name declared in a script,
        forming the name set used by carve-out (a). Names exclude the sigil and any
        scope qualifier and compare case-insensitively. Returns a single-element
        wrapper around the HashSet; the wrapper only suppresses enumeration.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.Ast]$Ast
    )

    $names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    $parameters = $Ast.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.ParameterAst]
        }, $true)

    foreach ($parameter in $parameters) {
        foreach ($attribute in $parameter.Attributes) {
            if ($attribute -isnot [System.Management.Automation.Language.TypeConstraintAst]) {
                continue
            }
            if ([string]$attribute.TypeName.Name -ieq 'scriptblock') {
                $null = $names.Add((Get-VariableName -Variable $parameter.Name))
            }
        }
    }

    # The unary comma suppresses pipeline enumeration. Without it an empty set
    # would emit nothing (yielding $null at the call site) and a populated set
    # would degrade to a case-SENSITIVE array, breaking carve-out (a) both ways.
    return , $names
}

function Get-EnclosingFunctionName {
    <#
    .SYNOPSIS
        Returns the nearest enclosing function name, or '<script>' at file scope.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.Ast]$Node
    )

    $parent = $Node.Parent
    while ($null -ne $parent) {
        if ($parent -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
            return [string]$parent.Name
        }
        $parent = $parent.Parent
    }
    return '<script>'
}

function ConvertTo-PythonInvocationFinding {
    <#
    .SYNOPSIS
        Converts a flagged CommandAst into a finding record. Pure projection: it
        reads the node and changes no state, hence `ConvertTo-` rather than `New-`.
    .OUTPUTS
        [pscustomobject] The finding record.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.CommandAst]$Command,

        [Parameter(Mandatory = $true)]
        [ValidateSet('ConstantCommand', 'StartProcess', 'DynamicInvocation', 'InvokeExpression')]
        [string]$Kind,

        [Parameter(Mandatory = $true)]
        [string]$Detail
    )

    $line = [int]$Command.Extent.StartLineNumber
    $functionName = Get-EnclosingFunctionName -Node $Command

    return [pscustomobject]@{
        Path     = $SourceLabel
        Line     = $line
        Function = $functionName
        Kind     = $Kind
        Detail   = $Detail
        Message  = ('{0}:{1} [{2}] in {3}: {4}' -f $SourceLabel, $line, $Kind, $functionName, $Detail)
    }
}

function Get-StartProcessTargetName {
    <#
    .SYNOPSIS
        Returns the literal target executable of a `Start-Process` invocation,
        preferring `-FilePath` and falling back to the first positional argument.
    .OUTPUTS
        [string] The literal target, or $null when neither is a literal constant.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.CommandAst]$Command
    )

    $elements = $Command.CommandElements
    $filePathValue = $null
    $firstPositional = $null

    for ($index = 1; $index -lt $elements.Count; $index++) {
        $element = $elements[$index]

        if ($element -is [System.Management.Automation.Language.CommandParameterAst]) {
            if ($element.ParameterName -ine 'FilePath') {
                continue
            }
            # `-FilePath:value` binds the argument to the parameter node itself.
            if ($null -ne $element.Argument) {
                $filePathValue = Get-LiteralCommandValue -Expression $element.Argument
            }
            elseif (($index + 1) -lt $elements.Count) {
                $filePathValue = Get-LiteralCommandValue -Expression $elements[$index + 1]
                $index++
            }
            continue
        }

        if ($null -eq $firstPositional) {
            $firstPositional = Get-LiteralCommandValue -Expression $element
        }
    }

    if ($null -ne $filePathValue) {
        return $filePathValue
    }
    return $firstPositional
}

function Test-SiblingScriptLoadExpression {
    <#
    .SYNOPSIS
        Indicates whether an expression is an inline sibling-script load,
        `(Join-Path $PSScriptRoot '<name>.ps1')`. Carve-out (b), inline form:
        deliberately tight, requiring a parenthesized single `Join-Path` command
        with a `$PSScriptRoot` argument and a literal argument ending in `.ps1`.
        Anything else stays a fail-closed finding.
    .OUTPUTS
        [bool] $true when the expression is a sibling-script load.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Language.Ast]$Expression
    )

    if ($Expression -isnot [System.Management.Automation.Language.ParenExpressionAst]) {
        return $false
    }
    $pipeline = $Expression.Pipeline
    if ($pipeline -isnot [System.Management.Automation.Language.PipelineAst]) {
        return $false
    }
    if ($pipeline.PipelineElements.Count -ne 1) {
        return $false
    }
    $inner = $pipeline.PipelineElements[0]
    if ($inner -isnot [System.Management.Automation.Language.CommandAst]) {
        return $false
    }
    if ([string]$inner.GetCommandName() -ine 'Join-Path') {
        return $false
    }

    $hasScriptRoot = $false
    $hasScriptFile = $false
    foreach ($element in $inner.CommandElements) {
        if ($element -is [System.Management.Automation.Language.VariableExpressionAst] -and
            ((Get-VariableName -Variable $element) -ieq 'PSScriptRoot')) {
            $hasScriptRoot = $true
            continue
        }
        $literal = Get-LiteralCommandValue -Expression $element
        if ($null -ne $literal -and $literal.EndsWith('.ps1', [System.StringComparison]::OrdinalIgnoreCase)) {
            $hasScriptFile = $true
        }
    }

    return ($hasScriptRoot -and $hasScriptFile)
}

function Get-PythonInvocationFinding {
    <#
    .SYNOPSIS
        Detects Python-interpreter invocations in PowerShell source text by parsing
        it with the AST and classifying every `CommandAst` against detection classes
        1-4, applying carve-outs (a) and (b). This is the single code path exercised
        by both the in-memory fixtures and the repository scan. Returns the finding
        records, empty when the source is clean.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$ScriptText,

        [Parameter(Mandatory = $true)]
        [string]$SourceLabel
    )

    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$tokens, [ref]$parseErrors)

    $findings = [System.Collections.Generic.List[object]]::new()
    $scriptBlockParameters = Get-ScriptBlockParameterName -Ast $ast

    $commands = $ast.FindAll({
            param($node)
            $node -is [System.Management.Automation.Language.CommandAst]
        }, $true)

    $dotOperator = [System.Management.Automation.Language.TokenKind]::Dot

    foreach ($command in $commands) {
        if ($command.CommandElements.Count -lt 1) {
            continue
        }
        $first = $command.CommandElements[0]

        # Class 3: dynamic invocation, command position is a variable.
        if ($first -is [System.Management.Automation.Language.VariableExpressionAst]) {
            $variableName = Get-VariableName -Variable $first

            # Carve-out (a): approved injectable [scriptblock] parameter seam.
            if ($scriptBlockParameters.Contains($variableName)) {
                continue
            }
            # Carve-out (b): dot-sourcing a path variable (sibling helper load).
            if ($command.InvocationOperator -eq $dotOperator) {
                continue
            }

            $detail = "ampersand-invoked variable `$$variableName is not a [scriptblock] parameter, so its target cannot be verified statically (fail-closed)"
            $findings.Add((ConvertTo-PythonInvocationFinding -SourceLabel $SourceLabel -Command $command -Kind 'DynamicInvocation' -Detail $detail))
            continue
        }

        $commandName = $command.GetCommandName()

        # Carve-out (b), inline form: `. (Join-Path $PSScriptRoot '<sibling>.ps1')`.
        if ($command.InvocationOperator -eq $dotOperator -and
            (Test-SiblingScriptLoadExpression -Expression $first)) {
            continue
        }

        # Class 3 continued: any other non-constant command position.
        if ([string]::IsNullOrEmpty($commandName)) {
            $detail = 'command position is not a literal constant, so its target cannot be verified statically (fail-closed)'
            $findings.Add((ConvertTo-PythonInvocationFinding -SourceLabel $SourceLabel -Command $command -Kind 'DynamicInvocation' -Detail $detail))
            continue
        }

        # Class 1: constant Python or Poetry command.
        if ($script:PythonInterpreterCommandName -contains $commandName) {
            $detail = "invokes the '$commandName' interpreter, which a destination repository is not guaranteed to have"
            $findings.Add((ConvertTo-PythonInvocationFinding -SourceLabel $SourceLabel -Command $command -Kind 'ConstantCommand' -Detail $detail))
            continue
        }

        # Class 4: arbitrary text execution.
        if ($commandName -ieq 'Invoke-Expression' -or $commandName -ieq 'iex') {
            $detail = "'$commandName' executes arbitrary text, so a Python invocation cannot be ruled out statically (fail-closed)"
            $findings.Add((ConvertTo-PythonInvocationFinding -SourceLabel $SourceLabel -Command $command -Kind 'InvokeExpression' -Detail $detail))
            continue
        }

        # Class 2: subprocess start targeting a Python or Poetry executable.
        $target = if ($commandName -ieq 'Start-Process') { Get-StartProcessTargetName -Command $command } else { $null }
        if ($null -ne $target -and ($script:PythonInterpreterCommandName -contains $target)) {
            $detail = "starts the '$target' interpreter as a subprocess, which a destination repository is not guaranteed to have"
            $findings.Add((ConvertTo-PythonInvocationFinding -SourceLabel $SourceLabel -Command $command -Kind 'StartProcess' -Detail $detail))
        }
    }

    return , $findings.ToArray()
}

function Test-PythonInvocationAllowlistMatch {
    <#
    .SYNOPSIS
        Indicates whether an allowlist entry covers a finding (Path and Function
        both match, case-insensitively).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Finding,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Entry
    )

    return (([string]$Entry['Path'] -ieq [string]$Finding.Path) -and
        ([string]$Entry['Function'] -ieq [string]$Finding.Function))
}

function Select-UnallowedPythonInvocationFinding {
    <#
    .SYNOPSIS
        Returns findings no allowlist entry covers (Assertion A input).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Finding,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Allowlist
    )

    $residual = [System.Collections.Generic.List[object]]::new()
    foreach ($item in $Finding) {
        $covered = @($Allowlist | Where-Object { Test-PythonInvocationAllowlistMatch -Finding $item -Entry $_ })
        if ($covered.Count -eq 0) {
            $residual.Add($item)
        }
    }
    return , $residual.ToArray()
}

function Get-UnusedPythonInvocationAllowlistEntry {
    <#
    .SYNOPSIS
        Returns allowlist entries matching no detected finding (Assertion B input).
        Vacuously empty while the allowlist is empty; retained so any future entry
        that goes stale fails the suite instead of masking a removed site.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Finding,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Allowlist
    )

    $stale = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $Allowlist) {
        $used = @($Finding | Where-Object { Test-PythonInvocationAllowlistMatch -Finding $_ -Entry $entry })
        if ($used.Count -eq 0) {
            $stale.Add($entry)
        }
    }
    return , $stale.ToArray()
}
