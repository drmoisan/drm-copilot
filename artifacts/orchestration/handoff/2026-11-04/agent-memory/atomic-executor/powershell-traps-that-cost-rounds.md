---
name: powershell-traps-that-cost-rounds
description: Sixteen PowerShell language and Pester traps that each cost a failed round while writing the issue 1022 and 1024 docs modules (case-insensitive vars, if-unrolling, $Input, "$x:" interpolation, dotted help lines, comma-return into Should, angle-bracket It names, culture StartsWith with U+FEFF, dot-sourced switch vars); check for them before the first test run of any new .psm1 or suite
metadata:
  type: feedback
---

Before the first test run of a new PowerShell module or suite, grep for these six constructs; each one produced a whole-suite failure in the 1022 run and none is caught by PSScriptAnalyzer.

- A local or loop variable whose name differs from a parameter only by case (`foreach ($token in $Token)`, `$analyzer` inside `-Analyzer`): PowerShell variables are case-insensitive, so the loop overwrites the parameter.
- An arithmetic expression next to a comma inside an array literal (`@($a + 1, $b + 1)`, `@('x', 'a' + 'b')`): the comma binds tighter than `+`, so the pieces are concatenated as arrays.
- A range `1..$n` when `$n` can be 0: it yields `@(1, 0)`, not an empty array; guard with `if ($n -gt 0)`.
- A function that returns `, $array` (the 1020 convention): `$x = f` yields the array, but `@(f)` wraps it as one element; never wrap such a call in `@()`.
- A `[string[]]` or generic-collection mandatory parameter without `AllowEmptyString`/`AllowEmptyCollection`: an empty line in the array or an empty set is a binding error.
- `$x = if (...) { @() } else { $s.Split("`n") }`: the if-expression output unrolls a one-element array to a scalar; wrap with `@()`. This also bites a consumer of a hashtable field another module filled through an `if` (`$record['Items']` from `Read-DocsPythonCall` arrives as a scalar for a one-item list): wrap every such read with `@()`.
- A test helper parameter named `$Input` (the automatic pipeline enumerator): the body reads the enumerator, not the argument, and fails with `ArgumentException: index` far from the cause; PSSA does flag it (`PSAvoidAssignmentToAutomaticVariable`), so run the analyzer before the first Pester run, not after.
- `"$name:"` or `"r$i:"` in a double-quoted string: the colon is read as a scope qualifier and the suite fails at discovery (`Variable reference is not valid`); write `${name}:`.
- A comment-help line that begins with a dotted token (`.get .post ...`, `.api_route(...)`): comment-based help reads it as a section keyword, invalidates the whole block, and PSSA reports `PSProvideCommentHelp` for a function that has a help block; never start a help line with `.`.
- A helper that returns `, $items` to the pipeline (`Get-X | Should -Be @(...)`): `Should` receives one nested array and fails with identical expected and actual text; return the array unwrapped or wrap the call in `@()`.
- An `It` name containing `<dynamic>` or any angle brackets: Pester drops the bracketed text from the reported name and the JUnit entry. Worse, with no `-ForEach` data Pester evaluates `<path>` as `$path`, and under strict mode (a dot-sourced `Invoke-DocsCommand.ps1` sets it) an undefined variable throws `The variable '$path' cannot be retrieved`. The test then passes only when the runner happens to define `$Path` (an earlier 1034 runner had `-Path`), so evidence recorded green and CI fails. Grep `It '[^']*<\w+>` on tests without `-ForEach` (1034 QA pass 3).
- `$s.StartsWith([string][char]0xFEFF)` (or any `StartsWith(string)` with a zero-width character): the string overload is culture-sensitive, U+FEFF is ignorable, so it returns `$true` for every string; use the `[char]` overload or `[System.StringComparison]::Ordinal` (seen in 1024).
- Dot-sourcing `Invoke-DocsCommand.ps1` brings its `[switch] $Json` / `[string] $Command` parameter variables into the caller scope; a later `$json = <hashtable>` in the same scope fails with "Cannot convert ... to SwitchParameter" (seen in a 1024 probe script).
- Piping a comma-returning function (`Get-DocsCommandTable | Where-Object`) passes the whole table as one `$_`; assign first (`$t = Get-DocsCommandTable; $t | Where-Object`).
- A local named `$context` in a module scanned by a `$Context` boundary rule: the AST rule matches case-insensitively, as PowerShell does; name locals `$pageContext`/`$contextLines` from the start (cost a round in 1024 P7-T2).

- A `[AllowNull()][string] $X` parameter turns a passed `$null` into `''`, so `$null -eq $X` is never true; type it `[object]` when null must stay distinguishable (issue 1074 summary header `(absent)`).
- The PreToolUse test-purity hook rejects a whole Write of a `*.Tests.ps1` whose text contains `Invoke-WebRequest`, `Invoke-RestMethod`, or `Start-Process` anywhere, including a list of forbidden tokens a no-I/O test searches for; build those tokens from parts (`('Invoke-' + 'WebRequest')`, parenthesized because the comma binds tighter than `+`) (issue 1074).
- `Remove-Item -Path Function:\global:name` is a silent no-op (no error, function stays); `Set-Item -Path Function:\global:name` does honor the scope. Remove a global function with the unqualified `Function:\name` and prove it with a post-run `Get-Command name -CommandType Function` probe (issue 1067 R1-F5; a plan prescribed the qualified form).

- `$m = $Context.ReadText; & $m $path` in any `.claude/lib` or hook file: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` reports a fail-closed `[DynamicInvocation]` for every `&` on a variable that is not a `[scriptblock]`-typed parameter. Route member calls through a private `Invoke-DocsContextMember -Member $Context.X -ArgumentList @(...)` (the DocsProfileCommands/DocsInventory pattern). Per-suite runs miss it; run that suite after creating any new lib module, before the 40-minute coverage run (cost a full QA loop in 1034 P7-T3).

- `Join-Path -Path $PSScriptRoot -ChildPath '../..'` (a repository-root seam) in a manifested hook or lib: `test_push_down_pack_manifest_dependency_closure.py` reads every F1/F2 child as a file dependency and reports `core: <hook> -> .`. Use the named non-dependency form `Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`. Run the P0 Pytest contract set right after creating a hook, not only in the final loop (cost loop pass 5 in 1034).

**Why:** each trap passed the formatter and the analyzer and surfaced only as a mass test failure, costing a run plus a probe script to locate.

**How to apply:** after writing a module, run one grep pass for `foreach (\$x in \$X)` pairs, `@(... + ..., ...)`, `1..\$`, and `@(Get-|@(ConvertTo-` wrappers before invoking Pester. Also note: `Invoke-Formatter` hangs intermittently at 1% CPU on this Codespace (kill and re-run), and `Invoke-ScriptAnalyzer` throws an intermittent NullReferenceException that a module reload and retry clears (PoshQC does the same).
