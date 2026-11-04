---
name: pssa-and-array-semantics-gotchas
description: PSScriptAnalyzer 1.25 null-reference and hang triggers on this Codespace, test-helper naming rules PSSA enforces on *.Tests.ps1, and the PowerShell comma-return versus @() wrapping rule that broke a whole first Pester run (issues 1023, 1034)
metadata:
  type: project
---

Two tool behaviors cost several turns each during the issue 1023 execution (2026-11-03).

**PSScriptAnalyzer 1.25.0 (pwsh 7.6.9, Linux Codespace).** `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1`
throws `Object reference not set to an instance of an object` for a whole file, and a later run over the
same folder hangs at ~2% CPU for minutes, when a module contains either `[OutputType(..., [object])]`
(an `[object]` entry in a multi-type list) or `foreach ($x in (<command invocation>))`. Both forms are
legal PowerShell; the rule crash is the analyzer's. Assign the command result to a variable first, and
declare `[object[]]` rather than `[object]`. Always run the analyzer under `timeout` and per file
(`-Path <one file>`) so a hang is bounded and attributable.

**`return , $array` versus `@(<command>)`.** Measured on pwsh 7.6.9: for a function that returns
`, $arr`, `$x = f` and `foreach ($i in (f))` enumerate correctly, but `@(f)` wraps the array into a
one-element array (even an empty one, so `.Count` is 1 instead of 0), and `f | Where-Object` hands the
whole array to the next command as a single item. A function whose output is consumed by a pipeline or
by `@()` must return the array without the comma; a function consumed by assignment or passed as a
parameter should keep the comma. Every 1020 docs module returns findings with the comma, so a test
helper must wrap those calls as `(f).Count`, never `@(f).Count`.

**PSSA on test files (issue 1034, 2026-11-04).** The PoshQC settings also lint `*.Tests.ps1`: a test
helper named `New-Test*` (with or without `[CmdletBinding()]`) raises PSUseShouldProcessForStateChangingFunctions,
`[hashtable]::new(...)` in a helper raises PSUseLiteralInitializerForHashtable, and a plural noun such as
`Get-TestPins` raises PSUseSingularNouns. Name helpers `Get-Test*`/`ConvertTo-Test*` with singular nouns and
use `@{}` literals in tests; a function returning `, $array` needs `[OutputType([string[]], [object[]])]`.

**Why:** the first Pester run of the new suites failed 45 of 434 tests on these two causes alone, and
the analyzer hang looked like host load until the per-file bisect isolated it.

**How to apply:** when a new PowerShell module or Pester suite is written, run the per-file bounded
analyzer before the suite, and grep the suite for `@(Get-Docs`, `@(Test-Docs` and `| Where-Object` on
comma-returning functions before the first run.
