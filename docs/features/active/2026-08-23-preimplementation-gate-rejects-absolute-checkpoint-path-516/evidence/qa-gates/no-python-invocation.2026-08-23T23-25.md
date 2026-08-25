# No Interpreter Invocation Introduced Into Any Hook Copy (issue #516)

Timestamp: 2026-08-24T16-49
Command: read the `enforcement-hooks-no-python-invocation.Tests.ps1` testsuite element from `artifacts/pester/pester-junit.xml` produced by the [P4-T4] full-suite run
EXIT_CODE: 0

## Suite Result

```text
suite:  tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
tests=27 failures=0 errors=0
```

**Zero failures. Acceptance condition satisfied.**

## Every Case and Its Result

```text
[pass] allowlist policy.ships an empty allowlist
[pass] detection class 1 - constant interpreter command.detects a bare python invocation
[pass] detection class 1 - constant interpreter command.detects an ampersand-invoked python invocation
[pass] detection class 1 - constant interpreter command.detects a dot-invoked python invocation
[pass] detection class 1 - constant interpreter command.detects a quoted python constant invocation
[pass] detection class 1 - constant interpreter command.detects python3, py, and poetry as interpreter commands
[pass] detection class 1 - constant interpreter command.detects an interpreter name written in mixed case
[pass] detection class 2 - subprocess start targeting an interpreter.detects a subprocess start whose FilePath is an interpreter
[pass] detection class 2 - subprocess start targeting an interpreter.detects a subprocess start whose first positional argument is an interpreter
[pass] detection class 2 - subprocess start targeting an interpreter.reports no finding for a subprocess start targeting an unrelated executable
[pass] detection class 3 - dynamic invocation fail-closed.detects an ampersand-invoked variable that is not a scriptblock parameter
[pass] detection class 3 - dynamic invocation fail-closed.detects an ampersand-invoked expression in the command position
[pass] detection class 4 - arbitrary text execution.detects an Invoke-Expression call
[pass] detection class 4 - arbitrary text execution.detects the built-in alias of Invoke-Expression
[pass] non-detection - constructs that must never be reported.reports no finding for interpreter names inside string literals
[pass] non-detection - constructs that must never be reported.reports no finding for interpreter names inside comments
[pass] non-detection - constructs that must never be reported.reports no finding for function names beginning with Invoke-Python
[pass] non-detection - constructs that must never be reported.reports no finding for a scriptblock-parameter seam invocation
[pass] non-detection - constructs that must never be reported.reports no finding when a seam variable differs from its parameter by letter case
[pass] non-detection - constructs that must never be reported.reports no finding for dot-sourcing a sibling helper path variable
[pass] non-detection - constructs that must never be reported.reports no finding for dot-sourcing an inline sibling helper path
[pass] carve-out boundaries - the inline sibling-load exemption stays tight.still reports a dot-sourced expression that is not a Join-Path call
[pass] carve-out boundaries - the inline sibling-load exemption stays tight.still reports a Join-Path load that does not resolve a ps1 sibling
[pass] carve-out boundaries - the inline sibling-load exemption stays tight.still reports an ampersand-invoked inline sibling-load expression
[pass] repository scan.enumerates only the two guarded roots and never the bundled mirror
[pass] repository scan.reports no Python invocation beyond the allowlist across the guarded tree
[pass] repository scan.carries no stale allowlist entry
```

## Why This Is a Meaningful Confirmation

The load-bearing case is `repository scan.reports no Python invocation beyond the allowlist across the guarded tree`. It is an AST scan over the guarded hook roots — `.claude/hooks/` and `.codex/hooks/`, which contain both canonical copies edited by this item — run against an **empty allowlist**, as the companion case `allowlist policy.ships an empty allowlist` confirms. Any interpreter invocation introduced into either canonical hook copy would therefore fail the scan outright, with no allowlist entry available to mask it.

The scan is also a genuinely discriminating instrument rather than a vacuous one: 14 detection cases across four classes confirm it fires on real invocations, including dynamic and mixed-case forms, and 10 non-detection and carve-out cases confirm it does not fire spuriously and that its exemptions stay narrow. A suite that only ever reported "no finding" would prove nothing; this one demonstrates both directions in the same run.

The change this item makes introduces no command invocation of any kind. The two replaced predicate bodies contain only a `-cmatch` comparison, a `foreach` over an in-memory array, a `-match` comparison built with `[regex]::Escape`, and `return` statements. No process is started, no interpreter is named, and no text is executed.

The suite was run without modification. `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` is one of the six run-only files, and [P5-T2] confirms it is absent from the changed-path union.

Output Summary: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` reports 27 tests, 0 failures, 0 errors in the [P4-T4] full-suite run. All 27 cases pass, including the empty-allowlist repository scan over the two guarded hook roots that contain both canonical copies edited by this item. No interpreter invocation was introduced into any hook copy. The suite was executed without modification.
