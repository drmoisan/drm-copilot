Set-StrictMode -Version Latest

# Regression guard for issue #198.
#
# The VS Code `pspester.pester-test` Test Explorer adapter folds discovered
# test IDs to UPPERCASE during static discovery. Sibling Describe/Context/It
# names - including `-ForEach`/`-TestCases` expansions - that differ from one
# another only by letter case collide to a single adapter ID, and the adapter
# drops or misreports the duplicate. `Invoke-Pester` does not fold case, so the
# engine reports green and hides the defect.
#
# This file enumerates every `*.Tests.ps1` under the repository `tests/` tree,
# parses each with the PowerShell AST, computes a per-child "adapter
# discriminator" that mirrors how the adapter forms IDs, and asserts that no two
# children within the same parent scope share a folded discriminator. The same
# helper function (`Get-AdapterIdCollision`) is exercised by deterministic
# in-memory fixtures so the detection logic is proven independently of the
# repository suite.

BeforeAll {
    # Resolve the `tests/` root by walking up from this file's own location,
    # not from the current working directory. This keeps the scan
    # CWD-independent so the suite behaves identically in the terminal and the
    # VS Code Test Explorer.
    $script:TestsRoot = $PSScriptRoot
    while ($null -ne $script:TestsRoot -and (Split-Path -Path $script:TestsRoot -Leaf) -ne 'tests') {
        $script:TestsRoot = Split-Path -Path $script:TestsRoot -Parent
    }
    if ($null -eq $script:TestsRoot) {
        throw "Unable to resolve the 'tests' root by walking up from '$PSScriptRoot'."
    }

    <#
    .SYNOPSIS
        Extracts the literal string value of an argument expression, when present.
    .DESCRIPTION
        Returns the literal value for a StringConstantExpressionAst or other
        ConstantExpressionAst. Returns $null for any expression that is not a
        literal constant (for example a variable or a sub-expression).
    .PARAMETER Expression
        The argument AST whose literal value is requested.
    .OUTPUTS
        [object] The literal value, or $null when the expression is not literal.
    #>
    function Get-LiteralArgumentValue {
        param(
            [Parameter(Mandatory = $true)]
            [AllowNull()]
            [System.Management.Automation.Language.Ast]$Expression
        )

        if ($Expression -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
            return $Expression.Value
        }
        if ($Expression -is [System.Management.Automation.Language.ConstantExpressionAst]) {
            return $Expression.Value
        }
        return $null
    }

    <#
    .SYNOPSIS
        Converts a literal hashtable AST into an ordered dictionary of its
        literal key/value pairs, or $null when any key/value is non-literal.
    .PARAMETER Hashtable
        The HashtableAst to convert.
    #>
    function ConvertTo-LiteralHashtableRow {
        param(
            [Parameter(Mandatory = $true)]
            [System.Management.Automation.Language.HashtableAst]$Hashtable
        )

        $row = [ordered]@{}
        foreach ($pair in $Hashtable.KeyValuePairs) {
            $keyValue = Get-LiteralArgumentValue -Expression $pair.Item1
            # A hashtable value is wrapped in a pipeline/command expression.
            $valueExpression = $null
            if ($pair.Item2 -is [System.Management.Automation.Language.PipelineAst]) {
                $pipelineElements = $pair.Item2.PipelineElements
                if ($pipelineElements.Count -eq 1 -and
                    $pipelineElements[0] -is [System.Management.Automation.Language.CommandExpressionAst]) {
                    $valueExpression = $pipelineElements[0].Expression
                }
            }
            if ($null -eq $keyValue -or $null -eq $valueExpression) {
                return $null
            }
            $literalValue = Get-LiteralArgumentValue -Expression $valueExpression
            if ($null -eq $literalValue) {
                return $null
            }
            $row[[string]$keyValue] = [string]$literalValue
        }
        return $row
    }

    <#
    .SYNOPSIS
        Collects the literal HashtableAst nodes from a `-ForEach`/`-TestCases`
        argument expression, regardless of array literal shape.
    .DESCRIPTION
        Handles the three literal array shapes that Pester accepts: a bare
        ArrayLiteralAst, an ArrayExpressionAst (`@( ... )`) wrapping a single
        comma-separated ArrayLiteralAst, and an ArrayExpressionAst whose
        SubExpression contains one statement per hashtable (the multi-line,
        comma-free form used by the fixed Invoke-FullRelease.Tests.ps1). A single
        HashtableAst argument is also accepted as a one-row array. Returns $null
        for any shape that is not composed solely of literal hashtables - for
        example a variable reference or a function-call expression.
    .PARAMETER Argument
        The `-ForEach`/`-TestCases` argument AST.
    .OUTPUTS
        [System.Collections.Generic.List[object]] of HashtableAst, or $null.
    #>
    function Get-LiteralHashtableElement {
        param(
            [Parameter(Mandatory = $true)]
            [AllowNull()]
            [System.Management.Automation.Language.Ast]$Argument
        )

        $hashtables = [System.Collections.Generic.List[object]]::new()

        # A single literal hashtable expands to a one-row data set.
        if ($Argument -is [System.Management.Automation.Language.HashtableAst]) {
            $hashtables.Add($Argument)
            return $hashtables
        }

        # A bare array literal: elements must all be literal hashtables.
        if ($Argument -is [System.Management.Automation.Language.ArrayLiteralAst]) {
            foreach ($element in $Argument.Elements) {
                if ($element -isnot [System.Management.Automation.Language.HashtableAst]) {
                    return $null
                }
                $hashtables.Add($element)
            }
            return $hashtables
        }

        # An array expression `@( ... )`: each statement is a pipeline whose
        # single command expression is either a comma-separated ArrayLiteralAst
        # or one hashtable per line.
        if ($Argument -is [System.Management.Automation.Language.ArrayExpressionAst]) {
            foreach ($statement in $Argument.SubExpression.Statements) {
                if ($statement -isnot [System.Management.Automation.Language.PipelineAst]) {
                    return $null
                }
                $pipelineElements = $statement.PipelineElements
                if ($pipelineElements.Count -ne 1 -or
                    $pipelineElements[0] -isnot [System.Management.Automation.Language.CommandExpressionAst]) {
                    return $null
                }
                $expression = $pipelineElements[0].Expression
                if ($expression -is [System.Management.Automation.Language.HashtableAst]) {
                    $hashtables.Add($expression)
                }
                elseif ($expression -is [System.Management.Automation.Language.ArrayLiteralAst]) {
                    foreach ($element in $expression.Elements) {
                        if ($element -isnot [System.Management.Automation.Language.HashtableAst]) {
                            return $null
                        }
                        $hashtables.Add($element)
                    }
                }
                else {
                    return $null
                }
            }
            return $hashtables
        }

        return $null
    }

    <#
    .SYNOPSIS
        Parses a literal array of literal hashtables into ordered data rows.
    .DESCRIPTION
        Accepts the argument AST supplied to `-ForEach` or `-TestCases`. When the
        argument is a literal array of literal hashtables (in any of the shapes
        recognized by Get-LiteralHashtableElement) with literal keys and literal
        values, returns a list of ordered dictionaries (one per row). Returns
        $null for any shape that is not a literal array of literal hashtables -
        for example a variable reference or a function-call expression. This
        intentional limitation scopes the guard to the literal pattern that
        caused issue #198; non-literal data is skipped, not failed.
    .PARAMETER Argument
        The `-ForEach`/`-TestCases` argument AST.
    .OUTPUTS
        [System.Collections.Generic.List[object]] of ordered dictionaries, or $null.
    #>
    function ConvertTo-LiteralDataRow {
        param(
            [Parameter(Mandatory = $true)]
            [AllowNull()]
            [System.Management.Automation.Language.Ast]$Argument
        )

        $hashtables = Get-LiteralHashtableElement -Argument $Argument
        if ($null -eq $hashtables) {
            return $null
        }

        $rows = [System.Collections.Generic.List[object]]::new()
        # Convert each literal hashtable element into an ordered data row.
        foreach ($hashtable in $hashtables) {
            $row = ConvertTo-LiteralHashtableRow -Hashtable $hashtable
            if ($null -eq $row) {
                return $null
            }
            $rows.Add($row)
        }
        return $rows
    }

    <#
    .SYNOPSIS
        Computes the folded adapter discriminators for a single block invocation.
    .DESCRIPTION
        Mirrors the adapter's ID-formation rules. The base discriminator is the
        block name uppercased (invariant-culture upper), with any `<Key>`
        placeholder tokens substituted by the corresponding data value when a
        literal `-ForEach`/`-TestCases` row is expanded. For each data row the
        function appends, for each data key, an uppercased `KEY=VALUE` segment.
        A plain (non-data-driven) block yields a single discriminator: its
        uppercased name. A data-driven block yields one discriminator per row.
    .PARAMETER Name
        The block's positional name / `-Name` value (literal string).
    .PARAMETER DataRows
        Optional list of ordered dictionaries from a literal `-ForEach`/
        `-TestCases` argument, or $null for a plain block.
    .OUTPUTS
        [System.Collections.Generic.List[string]] of folded discriminators.
    #>
    function Get-BlockDiscriminator {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Name,

            [Parameter(Mandatory = $false)]
            [AllowNull()]
            [object]$DataRows
        )

        $results = [System.Collections.Generic.List[string]]::new()
        $invariantUpper = [System.Globalization.CultureInfo]::InvariantCulture.TextInfo

        # Plain block: a single discriminator equal to the uppercased name.
        if ($null -eq $DataRows) {
            $results.Add($invariantUpper.ToUpper($Name))
            return $results
        }

        # Data-driven block: one discriminator per literal row.
        foreach ($row in $DataRows) {
            $expandedName = $Name
            # Substitute <Key> placeholder tokens with the row's data value.
            foreach ($key in $row.Keys) {
                $token = '<' + $key + '>'
                $expandedName = $expandedName.Replace($token, [string]$row[$key])
            }
            $segments = [System.Collections.Generic.List[string]]::new()
            $segments.Add($invariantUpper.ToUpper($expandedName))
            # Append an uppercased KEY=VALUE segment for each data key, in order.
            foreach ($key in $row.Keys) {
                $segment = $invariantUpper.ToUpper([string]$key + '=' + [string]$row[$key])
                $segments.Add($segment)
            }
            $results.Add(($segments -join '>>'))
        }
        return $results
    }

    <#
    .SYNOPSIS
        Detects folded adapter-ID collisions among sibling test blocks.
    .DESCRIPTION
        Parses the supplied script text with the PowerShell AST, finds all
        `Describe`/`Context`/`It` CommandAst invocations, computes each child's
        folded adapter discriminators (using the same helpers as the suite
        scan), and reports any case where two children within the same parent
        scope share a discriminator. This is the single code path exercised by
        both the in-memory fixture tests and the repository suite scan.
    .PARAMETER ScriptText
        The PowerShell source to analyze (parsed with `[Parser]::ParseInput`).
    .PARAMETER SourceLabel
        A human-readable label (file path or fixture name) included in collision
        messages.
    .OUTPUTS
        [System.Collections.Generic.List[string]] of collision messages; empty
        when no collision is found.
    #>
    function Get-AdapterIdCollision {
        param(
            [Parameter(Mandatory = $true)]
            [string]$ScriptText,

            [Parameter(Mandatory = $true)]
            [string]$SourceLabel
        )

        $tokens = $null
        $parseErrors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput(
            $ScriptText, [ref]$tokens, [ref]$parseErrors)

        $blockCommands = @('Describe', 'Context', 'It')
        # Find every Describe/Context/It invocation in the script.
        $commandAsts = $ast.FindAll(
            {
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $null -ne $node.GetCommandName() -and
                $blockCommands -contains $node.GetCommandName()
            }, $true)

        # Group discriminators by their nearest enclosing Describe/Context parent.
        $scopes = @{}
        $collisions = [System.Collections.Generic.List[string]]::new()

        foreach ($command in $commandAsts) {
            $name = $null
            $dataArgument = $null
            $elements = $command.CommandElements

            # The first positional string element after the command name is the
            # block name unless an explicit -Name parameter is supplied.
            for ($i = 1; $i -lt $elements.Count; $i++) {
                $element = $elements[$i]
                if ($element -is [System.Management.Automation.Language.CommandParameterAst]) {
                    $parameterName = $element.ParameterName
                    # -Name <value>: the value is the next element.
                    if ($parameterName -ieq 'Name' -and ($i + 1) -lt $elements.Count) {
                        $name = Get-LiteralArgumentValue -Expression $elements[$i + 1]
                        $i++
                        continue
                    }
                    # -ForEach / -TestCases <value>: capture the data argument.
                    if (($parameterName -ieq 'ForEach' -or $parameterName -ieq 'TestCases') -and
                        ($i + 1) -lt $elements.Count) {
                        $dataArgument = $elements[$i + 1]
                        $i++
                        continue
                    }
                    continue
                }
                # First non-parameter element is the positional name.
                if ($null -eq $name) {
                    $name = Get-LiteralArgumentValue -Expression $element
                }
            }

            # Skip invocations whose name is not a literal string.
            if ($null -eq $name) {
                continue
            }

            # Resolve the literal data rows; non-literal data is skipped (not
            # failed), scoping the guard to the issue-198 literal pattern.
            $dataRows = $null
            if ($null -ne $dataArgument) {
                $dataRows = ConvertTo-LiteralDataRow -Argument $dataArgument
            }

            # Identify the nearest enclosing Describe/Context as the parent scope.
            $parentScope = $command.Parent
            while ($null -ne $parentScope) {
                if ($parentScope -is [System.Management.Automation.Language.CommandAst] -and
                    $null -ne $parentScope.GetCommandName() -and
                    @('Describe', 'Context') -contains $parentScope.GetCommandName()) {
                    break
                }
                $parentScope = $parentScope.Parent
            }
            $scopeKey = if ($null -eq $parentScope) { '<root>' } else { $parentScope.GetHashCode().ToString() }

            if (-not $scopes.ContainsKey($scopeKey)) {
                $scopes[$scopeKey] = [System.Collections.Generic.HashSet[string]]::new()
            }
            $seen = $scopes[$scopeKey]

            # Each child contributes one or more folded discriminators.
            $discriminators = Get-BlockDiscriminator -Name $name -DataRows $dataRows
            foreach ($discriminator in $discriminators) {
                if (-not $seen.Add($discriminator)) {
                    $message = [string]::Format(
                        "{0}: colliding folded discriminator '{1}'.", $SourceLabel, $discriminator)
                    $collisions.Add($message)
                }
            }
        }

        return $collisions
    }
}

Describe "test-name-uniqueness adapter-ID collision guard" {
    Context "detection logic (in-memory fixtures)" {
        It "detects two sibling It names that differ only by letter case" {
            # Arrange: two sibling It names that fold to the same uppercased ID.
            $fixture = @'
Describe "outer" {
    It "value is rejected" { $true | Should -BeTrue }
    It "VALUE IS REJECTED" { $true | Should -BeTrue }
}
'@

            # Act
            $collisions = Get-AdapterIdCollision -ScriptText $fixture -SourceLabel 'case-only-fixture'

            # Assert
            $collisions.Count | Should -BeGreaterThan 0
            ($collisions -join "`n") | Should -Match 'VALUE IS REJECTED'
        }

        It "detects a literal -ForEach whose rows differ only by data-value case" {
            # Arrange: two -ForEach rows whose data values fold to the same value.
            $fixture = @'
Describe "outer" {
    It "token <Token> is rejected" -ForEach @(
        @{ Token = "yes" }
        @{ Token = "YES" }
    ) { $true | Should -BeTrue }
}
'@

            # Act
            $collisions = Get-AdapterIdCollision -ScriptText $fixture -SourceLabel 'foreach-case-fixture'

            # Assert
            $collisions.Count | Should -BeGreaterThan 0
            ($collisions -join "`n") | Should -Match 'TOKEN=YES'
        }

        It "reports no collision when a literal -ForEach disambiguates rows with a distinct data key" {
            # Arrange: ConfirmToken differs only by case but CaseLabel disambiguates,
            # mirroring the fixed Invoke-FullRelease.Tests.ps1 pattern.
            $fixture = @'
Describe "outer" {
    It "token '<ConfirmToken>' (<CaseLabel>) is rejected" -ForEach @(
        @{ ConfirmToken = "YES"; CaseLabel = "uppercase" }
        @{ ConfirmToken = "Yes"; CaseLabel = "titlecase" }
    ) { $true | Should -BeTrue }
}
'@

            # Act
            $collisions = Get-AdapterIdCollision -ScriptText $fixture -SourceLabel 'disambiguated-fixture'

            # Assert
            $collisions.Count | Should -Be 0
        }

        It "skips a non-literal -ForEach argument without raising a collision" {
            # Arrange: -ForEach bound to a variable is not a literal array of
            # literal hashtables, so it is skipped (documented limitation).
            $fixture = @'
Describe "outer" {
    $cases = @( @{ Token = "yes" }, @{ Token = "YES" } )
    It "token <Token> is rejected" -ForEach $cases { $true | Should -BeTrue }
}
'@

            # Act
            $collisions = Get-AdapterIdCollision -ScriptText $fixture -SourceLabel 'non-literal-fixture'

            # Assert
            $collisions.Count | Should -Be 0
        }
    }

    Context "repository suite scan" {
        It "reports zero folded adapter-ID collisions across all tests/**/*.Tests.ps1" {
            # Arrange: enumerate every test file under the resolved tests root.
            $testFiles = Get-ChildItem -Path $script:TestsRoot -Recurse -Filter '*.Tests.ps1' -File
            $testFiles | Should -Not -BeNullOrEmpty

            $allCollisions = [System.Collections.Generic.List[string]]::new()
            # Act: run the shared detection helper over each file's content.
            foreach ($file in $testFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $relativePath = $file.FullName.Substring($script:TestsRoot.Length).TrimStart('\', '/')
                $fileCollisions = Get-AdapterIdCollision -ScriptText $content -SourceLabel $relativePath
                foreach ($collision in $fileCollisions) {
                    $allCollisions.Add($collision)
                }
            }

            # Assert: the fixed repository suite must have no collisions.
            $allCollisions.Count | Should -Be 0 -Because ($allCollisions -join "`n")
        }
    }
}
